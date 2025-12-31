#requires -Version 5.1
<#
tools/flow.ps1
One-command helper to:
- create/checkout branch
- verify clean working tree
- stage selected files
- commit
- call local tool-server endpoint /git/push
- handle PR creation/lookup via GitHub CLI (gh)

Works in Windows PowerShell 5.1 and PowerShell 7+ (no PS7-only operators).
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Branch,

  [Parameter(Mandatory=$true)]
  [string]$Message,

  [Parameter()]
  [string[]]$Files = @("README.md"),

  [Parameter()]
  [string]$Remote = "origin",

  [Parameter()]
  [string]$BindHost = "127.0.0.1",

  [Parameter()]
  [int]$Port = 8001,

  [Parameter()]
  [int]$MaxWaitSec = 20,

  [Parameter()]
  [switch]$NoPush,

  [Parameter()]
  [switch]$NoAutoStart,

  [Parameter()]
  [switch]$SkipSmokeTest,

  # PR-related switches
  [Parameter()]
  [switch]$AutoPR,        # Automatically create PR if none exists

  [Parameter()]
  [switch]$Draft,         # Create PR as draft (only with -AutoPR)

  [Parameter()]
  [switch]$OpenPR,        # Open PR URL in browser after creation/lookup

  [Parameter()]
  [string]$PRTitle,       # Custom PR title (default: commit message)

  [Parameter()]
  [string]$PRBody         # Custom PR body (default: empty)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ===============================
# Logging Functions
# ===============================
function Info([string]$Msg) { Write-Host ("[flow] {0}" -f $Msg) }
function Warn([string]$Msg) { Write-Warning ("[flow] {0}" -f $Msg) }
function Fail([string]$Msg) { Write-Host ("[flow] ERROR: {0}" -f $Msg) -ForegroundColor Red; exit 1 }
function Success([string]$Msg) { Write-Host ("[flow] {0}" -f $Msg) -ForegroundColor Green }

# ===============================
# Utility Functions
# ===============================
function Quote-Arg([string]$a) {
  if ($null -eq $a) { return '""' }
  if ($a -match '[\s"`]' ) {
    $escaped = $a -replace '"','\"'
    return '"' + $escaped + '"'
  }
  return $a
}

function Normalize-Args([object[]]$Arguments) {
  @($Arguments) | Where-Object { $_ -ne $null -and ("$_") -ne "" } | ForEach-Object { "$_" }
}

function Invoke-Exe {
  param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [Parameter(Mandatory=$true)][string[]]$Arguments,
    [Parameter(Mandatory=$true)][string]$WorkingDirectory
  )

  if (-not (Test-Path -LiteralPath $WorkingDirectory -PathType Container)) {
    Fail ("WorkingDirectory does not exist: {0}" -f $WorkingDirectory)
  }

  $outFile = Join-Path $env:TEMP ("mm_flow_out_{0}.txt" -f ([guid]::NewGuid().ToString("N")))
  $errFile = Join-Path $env:TEMP ("mm_flow_err_{0}.txt" -f ([guid]::NewGuid().ToString("N")))

  try {
    $argList = Normalize-Args $Arguments
    $argString = ($argList | ForEach-Object { Quote-Arg $_ }) -join " "

    $p = Start-Process -FilePath $FilePath `
      -ArgumentList $argString `
      -WorkingDirectory $WorkingDirectory `
      -NoNewWindow -Wait -PassThru `
      -RedirectStandardOutput $outFile `
      -RedirectStandardError  $errFile

    $stdout = if (Test-Path -LiteralPath $outFile) { Get-Content -LiteralPath $outFile -Raw } else { "" }
    $stderr = if (Test-Path -LiteralPath $errFile) { Get-Content -LiteralPath $errFile -Raw } else { "" }

    return [pscustomobject]@{
      ExitCode = $p.ExitCode
      StdOut   = $stdout
      StdErr   = $stderr
    }
  }
  finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $outFile, $errFile
  }
}

# ===============================
# Git Functions
# ===============================
function Resolve-GitExe {
  $cmd = Get-Command git -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }

  $candidates = @(
    (Join-Path $env:ProgramFiles       "Git\cmd\git.exe"),
    (Join-Path $env:ProgramFiles       "Git\bin\git.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Git\cmd\git.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Git\bin\git.exe")
  ) | Where-Object { $_ -and $_ -ne "" }

  foreach ($p in $candidates) {
    if (Test-Path -LiteralPath $p) { return $p }
  }

  return $null
}

function Find-RepoRoot([string]$StartDir) {
  $d = (Resolve-Path -LiteralPath $StartDir).Path
  while ($true) {
    if (Test-Path -LiteralPath (Join-Path $d ".git")) { return $d }
    $parent = Split-Path -Path $d -Parent
    if (-not $parent -or $parent -eq $d) { break }
    $d = $parent
  }
  return $null
}

function Get-RepoRoot([string]$GitExe) {
  try {
    $r = Invoke-Exe -FilePath $GitExe -Arguments @("rev-parse","--show-toplevel") -WorkingDirectory (Get-Location).Path
    if ($r.ExitCode -eq 0) { return $r.StdOut.Trim() }
  } catch { }

  $fallback = Find-RepoRoot (Get-Location).Path
  if ($fallback) { return $fallback }

  $scriptRoot = Split-Path -Parent $PSCommandPath
  $fallback2 = Find-RepoRoot $scriptRoot
  if ($fallback2) { return $fallback2 }

  return $null
}

function Git([string[]]$Arguments, [string]$RepoRoot) {
  $r = Invoke-Exe -FilePath $script:GitExe -Arguments $Arguments -WorkingDirectory $RepoRoot
  return $r
}

function Get-Porcelain([string]$RepoRoot) {
  $r = Git @("status","--porcelain") $RepoRoot
  if ($r.ExitCode -ne 0) { Fail ("git status failed: {0}{1}" -f $r.StdErr, $r.StdOut) }
  $lines = @()
  foreach ($ln in ($r.StdOut -split "`r?`n")) {
    if ($ln.Trim().Length -gt 0) { $lines += $ln }
  }
  return $lines
}

function Ensure-Clean([string]$RepoRoot, [string[]]$AllowedPaths) {
  $porc = @(Get-Porcelain $RepoRoot)
  if ($porc.Count -eq 0) { return }

  $dirtyPaths = @()
  foreach ($ln in $porc) {
    if ($ln.Length -ge 4) {
      $dirtyPaths += $ln.Substring(3).Trim()
    }
  }

  $allowedSet = @{}
  foreach ($p in $AllowedPaths) {
    if ($p) { $allowedSet[$p.Replace("\","/")] = $true }
  }

  $unexpected = @()
  foreach ($p in $dirtyPaths) {
    $norm = $p.Replace("\","/")
    if (-not $allowedSet.ContainsKey($norm)) { $unexpected += $p }
  }

  if ($unexpected.Count -gt 0) {
    $list = ($unexpected | Sort-Object | Get-Unique) -join "`n"
    Fail ("Working tree not clean. Commit/restore first:`n{0}" -f $list)
  }
}

function Ensure-Branch([string]$RepoRoot, [string]$Branch) {
  $exists = Git @("show-ref","--verify","--quiet","refs/heads/$Branch") $RepoRoot
  if ($exists.ExitCode -eq 0) {
    $co = Git @("checkout",$Branch) $RepoRoot
    if ($co.ExitCode -ne 0) { Fail ("git checkout failed: {0}{1}" -f $co.StdErr, $co.StdOut) }
  } else {
    $co = Git @("checkout","-b",$Branch) $RepoRoot
    if ($co.ExitCode -ne 0) { Fail ("git checkout -b failed: {0}{1}" -f $co.StdErr, $co.StdOut) }
  }
}

function Stage-Files([string]$RepoRoot, [string[]]$Files) {
  if ($Files.Count -eq 0) { Fail "Files list is empty. Provide -Files @('path1','path2')." }

  $gitArgs = @("add","--") + $Files
  $add = Git $gitArgs $RepoRoot
  if ($add.ExitCode -ne 0) { Fail ("git add failed: {0}{1}" -f $add.StdErr, $add.StdOut) }

  $diff = Git @("diff","--cached","--quiet") $RepoRoot
  if ($diff.ExitCode -eq 0) { return $false }
  if ($diff.ExitCode -eq 1) { return $true }
  Fail ("git diff --cached failed: {0}{1}" -f $diff.StdErr, $diff.StdOut)
}

function Commit([string]$RepoRoot, [string]$Message) {
  $c = Git @("commit","-m",$Message) $RepoRoot
  if ($c.ExitCode -eq 0) { return $true }

  $combined = ("{0}{1}" -f $c.StdErr, $c.StdOut)
  if ($combined -match "nothing to commit" -or $combined -match "no changes added to commit") {
    return $false
  }

  Fail ("git commit failed: {0}" -f $combined)
}

function Get-RemoteUrl([string]$RepoRoot, [string]$Remote) {
  $r = Git @("remote","get-url",$Remote) $RepoRoot
  if ($r.ExitCode -ne 0) { return $null }
  return $r.StdOut.Trim()
}

# ===============================
# URL Parsing Functions (from ChatGPT, improved)
# ===============================
function Get-OriginHttpsRepo([string]$RepoRoot) {
  # Robust URL parsing for various git remote formats
  $r = Invoke-Exe -FilePath $script:GitExe -Arguments @("config","--get","remote.origin.url") -WorkingDirectory $RepoRoot
  if ($r.ExitCode -ne 0) { return $null }
  $u = $r.StdOut.Trim()
  if ([string]::IsNullOrWhiteSpace($u)) { return $null }
  
  # HTTPS format: https://github.com/user/repo.git
  if ($u -match '^https://([^/]+)/([^/]+)/([^/]+?)(\.git)?$') {
    return ("https://{0}/{1}/{2}" -f $Matches[1], $Matches[2], $Matches[3])
  }
  # SSH format: git@github.com:user/repo.git
  if ($u -match '^git@([^:]+):([^/]+)/(.+?)(\.git)?$') {
    return ("https://{0}/{1}/{2}" -f $Matches[1], $Matches[2], $Matches[3])
  }
  # SSH URL format: ssh://git@github.com/user/repo.git
  if ($u -match '^ssh://git@([^/]+)/([^/]+)/(.+?)(\.git)?$') {
    return ("https://{0}/{1}/{2}" -f $Matches[1], $Matches[2], $Matches[3])
  }
  return $null
}

function Get-DefaultBranchFromGit([string]$RepoRoot) {
  # Try to get default branch from git (fallback when gh not available)
  $r = Invoke-Exe -FilePath $script:GitExe -Arguments @("rev-parse","--abbrev-ref","origin/HEAD") -WorkingDirectory $RepoRoot
  if ($r.ExitCode -ne 0) { return $null }
  $s = $r.StdOut.Trim()
  if ($s -match '^origin/(.+)$') { return $Matches[1] }
  return $null
}

function Get-CompareUrl([string]$RepoRoot, [string]$Base, [string]$Head) {
  # Generate GitHub compare URL with expand=1 for easier PR creation
  $repo = Get-OriginHttpsRepo -RepoRoot $RepoRoot
  if (-not $repo) { return $null }
  return ("{0}/compare/{1}...{2}?expand=1" -f $repo, $Base, $Head)
}

function Build-CompareUrl([string]$RemoteUrl, [string]$Branch) {
  # Simple compare URL (legacy fallback)
  if (-not $RemoteUrl) { return $null }

  $url = $RemoteUrl.Trim()
  if ($url.EndsWith(".git")) { $url = $url.Substring(0, $url.Length - 4) }

  if ($url -match '^git@github\.com:') {
    $url = $url -replace '^git@github\.com:','https://github.com/'
  }

  return ("{0}/pull/new/{1}" -f $url, $Branch)
}

function Find-PrLink([string]$Text) {
  # GitHub returns PR URL in push output when branch has open PR
  # Example: "Create a pull request for 'feature/x' on GitHub by visiting:
  #           https://github.com/user/repo/pull/new/feature/x"
  # Or when PR exists: "https://github.com/user/repo/pull/123"
  if (-not $Text) { return $null }
  
  # Match existing PR URL
  if ($Text -match '(https://github\.com/[^/]+/[^/]+/pull/\d+)') {
    return $Matches[1]
  }
  # Match "create PR" URL
  if ($Text -match '(https://github\.com/[^/]+/[^/]+/pull/new/[^\s]+)') {
    return $Matches[1]
  }
  return $null
}

# ===============================
# Tool Server Functions
# ===============================
function Try-GetStatus([string]$Url) {
  try {
    $r = Invoke-RestMethod -Method Get -Uri $Url -TimeoutSec 2
    return $r
  } catch {
    return $null
  }
}

function Ensure-ToolServer([string]$RepoRoot, [string]$StatusUrl, [int]$MaxWaitSec, [switch]$NoAutoStart) {
  # Quick check if server is already running
  $r = Try-GetStatus $StatusUrl
  if ($null -ne $r -and $r.ok -eq $true) {
    Info ("Server ready (branch={0}, dirty={1})" -f $r.branch, $r.dirty)
    return
  }

  if ($NoAutoStart) {
    Fail ("Tool server not reachable at {0}. Start it via .\tools\dev.ps1 and retry." -f $StatusUrl)
  }

  # Use dev.ps1 for all server start logic (single source of truth)
  $dev = Join-Path $RepoRoot "tools\dev.ps1"
  if (-not (Test-Path -LiteralPath $dev)) {
    Fail ("tools\dev.ps1 not found at: {0}" -f $dev)
  }

  Info "Starting tool server via dev.ps1..."
  & $dev -BindHost $BindHost -Port $Port -Quiet
  
  if ($LASTEXITCODE -ne 0) {
    Fail "dev.ps1 failed to start server. Run .\tools\dev.ps1 manually to see errors."
  }

  # Verify server is now reachable
  $r = Try-GetStatus $StatusUrl
  if ($null -ne $r -and $r.ok -eq $true) {
    Info ("Server ready (branch={0}, dirty={1})" -f $r.branch, $r.dirty)
    return
  }

  Fail ("Server started but not responding at {0}. Check .\tools\dev.ps1 output." -f $StatusUrl)
}

# ===============================
# GitHub CLI (gh) Functions
# ===============================
function Resolve-GhExecutable {
  $cmd = Get-Command gh -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }
  return $null
}

function Test-GhAvailable {
  return ($null -ne (Resolve-GhExecutable))
}

function Invoke-Gh([string[]]$Arguments, [string]$RepoRoot) {
  $ghExe = Resolve-GhExecutable
  if (-not $ghExe) { return $null }
  
  $r = Invoke-Exe -FilePath $ghExe -Arguments $Arguments -WorkingDirectory $RepoRoot
  return $r
}

function Get-DefaultBranch([string]$RepoRoot) {
  # Try gh first
  $ghExe = Resolve-GhExecutable
  if ($ghExe) {
    $r = Invoke-Gh @("repo","view","--json","defaultBranchRef","-q",".defaultBranchRef.name") $RepoRoot
    if ($null -ne $r -and $r.ExitCode -eq 0) {
      $branch = $r.StdOut.Trim()
      if ($branch -ne "") { return $branch }
    }
  }
  
  # Fallback to git
  $gitBranch = Get-DefaultBranchFromGit $RepoRoot
  if ($gitBranch) { return $gitBranch }
  
  # Ultimate fallback
  return "main"
}

function Try-GetPrUrlViaGh([string]$RepoRoot, [string]$Head) {
  # Get existing PR URL via gh CLI
  $ghExe = Resolve-GhExecutable
  if (-not $ghExe) { return $null }
  
  $r = Invoke-Exe -FilePath $ghExe -Arguments @("pr","view","--head",$Head,"--json","url","--jq",".url") -WorkingDirectory $RepoRoot
  if ($r.ExitCode -ne 0) { return $null }
  $u = $r.StdOut.Trim()
  if ($u -match '^https?://') { return $u }
  return $null
}

function Get-ExistingPR([string]$RepoRoot, [string]$HeadBranch) {
  # Returns PR URL if exists, $null otherwise
  return Try-GetPrUrlViaGh -RepoRoot $RepoRoot -Head $HeadBranch
}

function Test-HasDiffFromBase([string]$RepoRoot, [string]$BaseBranch, [string]$HeadBranch) {
  # Check if there are commits on head that aren't on base
  $r = Git @("rev-list","--count","$BaseBranch..$HeadBranch") $RepoRoot
  if ($r.ExitCode -ne 0) { return $true }  # assume yes if we can't check
  $count = 0
  [int]::TryParse($r.StdOut.Trim(), [ref]$count) | Out-Null
  return ($count -gt 0)
}

function New-PullRequest {
  param(
    [string]$RepoRoot,
    [string]$BaseBranch,
    [string]$HeadBranch,
    [string]$Title,
    [string]$Body,
    [switch]$Draft
  )

  $ghArgs = @("pr","create","--base",$BaseBranch,"--head",$HeadBranch)
  
  if ($Title) {
    $ghArgs += @("--title",$Title)
  } else {
    $ghArgs += @("--fill")  # use commit message as title
  }
  
  if ($Body) {
    $ghArgs += @("--body",$Body)
  }
  
  if ($Draft) {
    $ghArgs += @("--draft")
  }
  
  $ghArgs += @("--json","url","-q",".url")
  
  $r = Invoke-Gh $ghArgs $RepoRoot
  if ($null -eq $r -or $r.ExitCode -ne 0) {
    $err = if ($r) { "{0}{1}" -f $r.StdErr, $r.StdOut } else { "gh command failed" }
    Warn ("Failed to create PR: {0}" -f $err)
    return $null
  }
  
  return $r.StdOut.Trim()
}

function Open-Url([string]$Url) {
  if (-not $Url) { return }
  try {
    Start-Process $Url
  } catch {
    Warn ("Could not open URL in browser: {0}" -f $Url)
  }
}

function Handle-PullRequest {
  param(
    [string]$RepoRoot,
    [string]$Branch,
    [string]$CommitMessage,
    [switch]$AutoPR,
    [switch]$Draft,
    [switch]$OpenPR,
    [string]$PRTitle,
    [string]$PRBody
  )

  # Get default branch (works with or without gh)
  $baseBranch = Get-DefaultBranch $RepoRoot
  Info ("Base branch: {0}" -f $baseBranch)

  # Check if branch is same as base (nothing to PR)
  if ($Branch -eq $baseBranch) {
    Warn "Cannot create PR: branch is same as base branch."
    return
  }

  # Generate compare URL (works without gh)
  $compareUrl = Get-CompareUrl -RepoRoot $RepoRoot -Base $baseBranch -Head $Branch
  if (-not $compareUrl) {
    # Fallback
    $remoteUrl = Get-RemoteUrl -RepoRoot $RepoRoot -Remote "origin"
    $compareUrl = Build-CompareUrl -RemoteUrl $remoteUrl -Branch $Branch
  }

  # Check if gh is available
  if (-not (Test-GhAvailable)) {
    Warn "GitHub CLI (gh) not found. Install from https://cli.github.com/"
    if ($compareUrl) {
      Info ("Open PR manually: {0}" -f $compareUrl)
      if ($OpenPR) { Open-Url $compareUrl }
    }
    return
  }

  # Check if there are commits to PR
  if (-not (Test-HasDiffFromBase $RepoRoot $baseBranch $Branch)) {
    Info "Nothing to PR: no commits ahead of $baseBranch"
    return
  }

  # Check for existing PR
  $existingPR = Get-ExistingPR $RepoRoot $Branch
  if ($existingPR) {
    Success ("PR exists: {0}" -f $existingPR)
    if ($OpenPR) { Open-Url $existingPR }
    return
  }

  # No existing PR
  if ($AutoPR) {
    # Create new PR
    Info "Creating PR..."
    $title = if ($PRTitle) { $PRTitle } else { $CommitMessage }
    $newPR = New-PullRequest -RepoRoot $RepoRoot -BaseBranch $baseBranch -HeadBranch $Branch `
      -Title $title -Body $PRBody -Draft:$Draft
    
    if ($newPR) {
      $prType = if ($Draft) { "Draft PR" } else { "PR" }
      Success ("{0} created: {1}" -f $prType, $newPR)
      if ($OpenPR) { Open-Url $newPR }
    } else {
      # Fallback to compare URL
      if ($compareUrl) {
        Info ("Create PR manually: {0}" -f $compareUrl)
        if ($OpenPR) { Open-Url $compareUrl }
      }
    }
  } else {
    # Just show the compare URL
    Info "No PR exists for this branch."
    if ($compareUrl) {
      Info ("Create PR: {0}" -f $compareUrl)
      if ($OpenPR) { Open-Url $compareUrl }
    }
  }
}

# ===============================
# Main
# ===============================
$script:GitExe = Resolve-GitExe
if (-not $script:GitExe) {
  Fail "git not found. Install Git for Windows and open a new terminal so PATH is refreshed."
}
Info ("GitExe: {0}" -f $script:GitExe)

$repoRoot = Get-RepoRoot $script:GitExe
if (-not $repoRoot) { Fail "Repo root not found. Run this script from within the repo (or below it)." }
Info ("RepoRoot: {0}" -f $repoRoot)

# 0) Ensure tree clean except the files we intend to touch (+ this script itself)
$allowed = @()
$allowed += ($Files | ForEach-Object { $_.Replace("\","/") })
$allowed += @("tools/flow.ps1")
Ensure-Clean -RepoRoot $repoRoot -AllowedPaths $allowed

# 1) Checkout/create branch
Info ("Creating/checkout branch: {0}" -f $Branch)
Ensure-Branch -RepoRoot $repoRoot -Branch $Branch

# 2) Stage files
Info ("git add: {0}" -f ($Files -join ", "))
$staged = Stage-Files -RepoRoot $repoRoot -Files $Files
if (-not $staged) {
  Info "No staged changes. Nothing to commit."
  exit 0
}

# 3) Commit
Info ("git commit -m {0}" -f $Message)
$didCommit = Commit -RepoRoot $repoRoot -Message $Message
if (-not $didCommit) {
  Info "Nothing to commit. Exiting."
  exit 0
}

if ($NoPush) {
  Info "NoPush set. Skipping push and PR handling."
  exit 0
}

# 4) Ensure tool server available, then call /git/push
$statusUrl = "http://$BindHost`:$Port/git/status"
$pushUrl   = "http://$BindHost`:$Port/git/push"

Ensure-ToolServer -RepoRoot $repoRoot -StatusUrl $statusUrl -MaxWaitSec $MaxWaitSec -NoAutoStart:$NoAutoStart

$body = @{
  remote         = $Remote
  branch         = $Branch
  set_upstream   = $true
  force          = $false
  tags           = $false
  dry_run        = $false
  run_smoke_test = (-not $SkipSmokeTest)
} | ConvertTo-Json -Depth 5

Info ("POST /git/push (remote={0}, branch={1})" -f $Remote, $Branch)
try {
  $resp = Invoke-RestMethod -Method Post -Uri $pushUrl -ContentType "application/json" -Body $body
} catch {
  $msg = $_.Exception.Message
  if ($_.Exception.Response -and $_.Exception.Response.GetResponseStream()) {
    try {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $raw = $reader.ReadToEnd()
      if ($raw) { $msg = $raw }
    } catch { }
  }
  Fail ("POST /git/push failed: {0}" -f $msg)
}

if ($resp.ok -ne $true) {
  Fail ("/git/push returned ok!=true: {0}" -f ($resp | ConvertTo-Json -Depth 5))
}

Success ("Pushed OK. Branch: {0}" -f $resp.branch)

# 5) Handle PR
# First check if push output contains a PR link (GitHub sometimes includes it)
$pushOutput = ""
if ($resp.stdout) { $pushOutput += $resp.stdout }
if ($resp.stderr) { $pushOutput += "`n" + $resp.stderr }
$foundPrLink = Find-PrLink $pushOutput

if ($foundPrLink) {
  Success ("PR: {0}" -f $foundPrLink)
  if ($OpenPR) { Open-Url $foundPrLink }
} else {
  # Full PR handling (check existing, create if -AutoPR, etc.)
  Handle-PullRequest -RepoRoot $repoRoot -Branch $Branch -CommitMessage $Message `
    -AutoPR:$AutoPR -Draft:$Draft -OpenPR:$OpenPR `
    -PRTitle $PRTitle -PRBody $PRBody
}

exit 0
