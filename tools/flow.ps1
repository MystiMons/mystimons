<#  tools/flow.ps1
    One-shot flow:
      - repo root autodetect
      - ensure git available
      - ensure working tree clean (optional override)
      - create/switch to branch
      - add files + commit
      - ensure tool server running (auto-start tools/dev.ps1 if needed)
      - call POST /git/push
      - print PR link (if found)

    Compatible with Windows PowerShell 5.1 and PowerShell 7+
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Branch,

  [Parameter(Mandatory=$true)]
  [string]$Message,

  [Parameter(Mandatory=$true)]
  [string[]]$Files,

  [string]$BindHost = "127.0.0.1",
  [int]$Port = 8000,

  [switch]$NoPush,

  # Set if you want to allow running with a dirty working tree BEFORE the commit step.
  # (Not recommended; default is strict.)
  [switch]$AllowDirty,
  
  [switch]$AllowEmptyCommit

)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$Msg) {
  Write-Host ("[flow] ERROR: {0}" -f $Msg) -ForegroundColor Red
  exit 1
}

function Info([string]$Msg) {
  Write-Host ("[flow] {0}" -f $Msg)
}

function Resolve-GitExe() {
  $cmd = Get-Command git -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }

  $candidates = @(
    "$env:ProgramFiles\Git\cmd\git.exe",
    "$env:ProgramFiles\Git\bin\git.exe",
    "$env:ProgramFiles(x86)\Git\cmd\git.exe",
    "$env:ProgramFiles(x86)\Git\bin\git.exe"
  )
  foreach ($p in $candidates) {
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Invoke-Exe {
  param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [Parameter(Mandatory=$true)][string[]]$Args,
    [Parameter(Mandatory=$true)][string]$WorkingDirectory
  )

  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $FilePath
  $psi.WorkingDirectory = $WorkingDirectory
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError  = $true
  $psi.CreateNoWindow = $true

  foreach ($a in $Args) { [void]$psi.ArgumentList.Add($a) }

  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi

  [void]$p.Start()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $p.WaitForExit()

  [pscustomobject]@{
    ExitCode = $p.ExitCode
    StdOut   = $stdout
    StdErr   = $stderr
  }
}

function Find-RepoRoot([string]$StartDir) {
  $d = (Resolve-Path $StartDir).Path
  while ($true) {
    if (Test-Path (Join-Path $d ".git")) { return $d }
    $parent = Split-Path $d -Parent
    if (-not $parent -or $parent -eq $d) { break }
    $d = $parent
  }
  return $null
}

# --- Resolve repo root
$repoRoot = $null
$gitExe = Resolve-GitExe
if (-not $gitExe) { Fail "git nicht verfügbar (weder PATH noch Standardpfade). Installiere Git for Windows." }

# Prefer git itself (works with submodules / worktrees)
try {
  $r = Invoke-Exe -FilePath $gitExe -Args @("rev-parse","--show-toplevel") -WorkingDirectory (Get-Location).Path
  if ($r.ExitCode -eq 0) {
    $repoRoot = $r.StdOut.Trim()
  }
} catch {
  # ignore; fallback below
}

if (-not $repoRoot) {
  $repoRoot = Find-RepoRoot -StartDir (Get-Location).Path
}

if (-not $repoRoot -or -not (Test-Path $repoRoot)) {
  Fail ("RepoRoot nicht gefunden. Starte das Script innerhalb des Repos. CurrentDir={0}" -f (Get-Location).Path)
}

Info ("RepoRoot: {0}" -f $repoRoot)
Info ("GitExe:   {0}" -f $gitExe)

# --- Preflight: ensure clean (optional)
$st = Invoke-Exe -FilePath $gitExe -Args @("status","--porcelain") -WorkingDirectory $repoRoot
if ($st.ExitCode -ne 0) { Fail ("git status failed: {0}" -f $st.StdErr) }

if (-not $AllowDirty -and $st.StdOut.Trim().Length -gt 0) {
  Fail ("Working tree not clean. Commit/restore first.`n{0}" -f $st.StdOut.Trim())
}

# --- Create/switch to branch
# If branch exists locally, switch; else create.
$exists = Invoke-Exe -FilePath $gitExe -Args @("rev-parse","--verify",$Branch) -WorkingDirectory $repoRoot
if ($exists.ExitCode -eq 0) {
  Info ("Switching to existing branch: {0}" -f $Branch)
  $co = Invoke-Exe -FilePath $gitExe -Args @("checkout",$Branch) -WorkingDirectory $repoRoot
} else {
  Info ("Creating branch: {0}" -f $Branch)
  $co = Invoke-Exe -FilePath $gitExe -Args @("checkout","-b",$Branch) -WorkingDirectory $repoRoot
}
if ($co.ExitCode -ne 0) { Fail ("git checkout failed: {0}" -f $co.StdErr) }

# --- Add files
# Validate file paths (relative to repo root)
foreach ($f in $Files) {
  $full = Join-Path $repoRoot $f
  if (-not (Test-Path $full)) {
    Fail ("File not found: {0} (expected at {1})" -f $f, $full)
  }
}

Info ("git add: {0}" -f ($Files -join ", "))
$addArgs = @("add","--") + $Files
$add = Invoke-Exe -FilePath $gitExe -Args $addArgs -WorkingDirectory $repoRoot
if ($add.ExitCode -ne 0) { Fail ("git add failed: {0}" -f $add.StdErr) }

# --- Ensure something staged
$diff = Invoke-Exe -FilePath $gitExe -Args @("diff","--cached","--quiet") -WorkingDirectory $repoRoot
# ExitCode 0 => no diff; 1 => has diff; other => error
if ($diff.ExitCode -eq 0) { Fail "No staged changes. Nothing to commit." }
if ($diff.ExitCode -ne 1) { Fail ("git diff --cached failed: {0}" -f $diff.StdErr) }

# --- Commit
Info ("git commit -m `"{0}`"" -f $Message)
$commit = Invoke-Exe -FilePath $gitExe -Args @("commit","-m",$Message) -WorkingDirectory $repoRoot
if ($commit.ExitCode -ne 0) { Fail ("git commit failed: {0}" -f $commit.StdErr) }

if ($NoPush) {
  Info "NoPush gesetzt. Abbruch vor /git/push."
  exit 0
}

# --- Ensure tool server running (auto-start tools/dev.ps1 if needed)
$statusUrl = "http://$BindHost`:$Port/git/status"
$pushUrl   = "http://$BindHost`:$Port/git/push"

function Try-GetStatus([int]$MaxTries, [int]$SleepMs) {
  for ($i=0; $i -lt $MaxTries; $i++) {
    try {
      $r = Invoke-RestMethod -Method Get -Uri $statusUrl -TimeoutSec 2
      if ($r -and $r.ok -eq $true) { return $true }
    } catch { }
    Start-Sleep -Milliseconds $SleepMs
  }
  return $false
}

if (-not (Try-GetStatus -MaxTries 2 -SleepMs 300)) {
  $dev = Join-Path $repoRoot "tools\dev.ps1"
  if (Test-Path $dev) {
    Info ("Server nicht erreichbar. Starte tools/dev.ps1 ...")
    & $dev | Out-Null
  } else {
    Fail ("Server nicht erreichbar und tools/dev.ps1 nicht gefunden unter: {0}" -f $dev)
  }
}

if (-not (Try-GetStatus -MaxTries 30 -SleepMs 500)) {
  Fail "Server wurde nicht ready. Checke das uvicorn-Fenster auf Errors."
}

Info ("/git/status ok: {0}" -f $statusUrl)

# --- POST /git/push
Info ("POST /git/push -> {0}" -f $pushUrl)
try {
  $body = @{ branch = $Branch } | ConvertTo-Json
  $resp = Invoke-RestMethod -Method Post -Uri $pushUrl -ContentType "application/json" -Body $body
} catch {
  Fail ("/git/push failed: {0}" -f $_.Exception.Message)
}

if (-not $resp -or $resp.ok -ne $true) {
  Fail ("/git/push returned non-ok: {0}" -f (($resp | ConvertTo-Json -Depth 6)))
}

Info "Push OK."

# --- Extract PR link (GitHub prints it in stderr typically)
$combined = ""
if ($resp.stdout) { $combined += [string]$resp.stdout + "`n" }
if ($resp.stderr) { $combined += [string]$resp.stderr + "`n" }

$pr = $null
$m = [regex]::Match($combined, 'https://github\.com/\S+/pull/new/\S+')
if ($m.Success) { $pr = $m.Value }

if ($pr) {
  Info ("PR: {0}" -f $pr)
  try { Start-Process $pr | Out-Null } catch { }
} else {
  Info "Kein PR-Link gefunden (stdout/stderr). Öffne GitHub und erstelle PR manuell."
}

Info "Done."
