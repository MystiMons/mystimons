#requires -Version 5.1
<#
tools/dev.ps1
MystiMons Development Environment - One-Button Entry-Point

Combines:
- Auto-detection of FastAPI app (ChatGPT)
- Tool dashboard & status checks (Claude)
- Foreground/detached server modes (ChatGPT)
- Stop/Check commands (Claude)

Usage:
  .\tools\dev.ps1              # Check tools, start server, show status
  .\tools\dev.ps1 -Check       # Only check tools, don't start server
  .\tools\dev.ps1 -Open        # Start server + open /docs in browser
  .\tools\dev.ps1 -Foreground  # Run server in this window (blocking)
  .\tools\dev.ps1 -Stop        # Stop running server (Python processes only)
  .\tools\dev.ps1 -Stop -Force # Stop ANY process on the port
  .\tools\dev.ps1 -Quiet       # Minimal output
#>

[CmdletBinding()]
param(
  [string]$BindHost = "127.0.0.1",
  [int]$Port = 8000,

  # Opens /docs after server is ready
  [switch]$Open,

  # Run uvicorn in this window (default: detached new window)
  [switch]$Foreground,

  # Disable reload (default: reload enabled)
  [switch]$NoReload,

  # Explicit ASGI import, e.g. "tools.tool_server.main:app"
  [string]$AppImport,

  # Only check tools, don't start server
  [switch]$Check,

  # Stop running server
  [switch]$Stop,

  # Force stop (kills any process on port, not just Python)
  [switch]$Force,

  # Minimal output
  [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ===============================
# Configuration
# ===============================
$script:Config = @{
  PythonMinVersion = [version]"3.10"
  GitMinVersion = [version]"2.30"
  RequiredPackages = @("fastapi", "uvicorn")
}

# ===============================
# Output Functions
# ===============================
function Write-Header([string]$Text) {
  if ($Quiet) { return }
  Write-Host ""
  Write-Host ("=" * 60) -ForegroundColor Cyan
  Write-Host "  $Text" -ForegroundColor Cyan
  Write-Host ("=" * 60) -ForegroundColor Cyan
}

function Write-Status([string]$Tool, [string]$Status, [string]$Detail = "") {
  if ($Quiet -and $Status -eq "OK") { return }
  
  $color = switch ($Status) {
    "OK"   { "Green" }
    "WARN" { "Yellow" }
    "FAIL" { "Red" }
    "INFO" { "Cyan" }
    default { "White" }
  }
  $icon = switch ($Status) {
    "OK"   { "[OK]" }
    "WARN" { "[!!]" }
    "FAIL" { "[X]" }
    "INFO" { "[i]" }
    default { "[ ]" }
  }
  
  $line = "{0,-6} {1,-15}" -f $icon, $Tool
  if ($Detail) { $line += " $Detail" }
  Write-Host $line -ForegroundColor $color
}

function Info([string]$Msg) { 
  if (-not $Quiet) { Write-Host "[dev] $Msg" -ForegroundColor Green }
}
function Warn([string]$Msg) { Write-Host "[dev] WARN: $Msg" -ForegroundColor Yellow }
function Fail([string]$Msg) { Write-Host "[dev] ERROR: $Msg" -ForegroundColor Red; exit 1 }

# ===============================
# Tool Detection Functions
# ===============================
function Find-Executable([string]$Name, [string[]]$AdditionalPaths = @()) {
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }
  
  foreach ($p in $AdditionalPaths) {
    if ($p -and (Test-Path -LiteralPath $p)) { return $p }
  }
  return $null
}

function Get-GitInfo {
  $paths = @(
    (Join-Path $env:ProgramFiles "Git\cmd\git.exe"),
    (Join-Path $env:ProgramFiles "Git\bin\git.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Git\cmd\git.exe")
  )
  
  $exe = Find-Executable "git" $paths
  if (-not $exe) { return @{ Found = $false } }
  
  try {
    $output = & $exe --version 2>&1
    $version = if ($output -match 'git version (\d+\.\d+\.\d+)') { [version]$Matches[1] } else { [version]"0.0.0" }
  } catch { $version = [version]"0.0.0" }
  
  return @{ Found = $true; Path = $exe; Version = $version }
}

function Get-PythonInfo([string]$RepoRoot = "") {
  # Priority: .venv first (project-specific), then system Python
  $paths = @()
  
  # .venv in repo root (highest priority)
  if ($RepoRoot -and (Test-Path $RepoRoot)) {
    $paths += (Join-Path $RepoRoot ".venv\Scripts\python.exe")  # Windows
    $paths += (Join-Path $RepoRoot ".venv\bin\python")          # Linux/Mac
    $paths += (Join-Path $RepoRoot "venv\Scripts\python.exe")   # Alternative name
    $paths += (Join-Path $RepoRoot "venv\bin\python")
  }
  
  # System Python paths
  $paths += @(
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python314\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python313\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python311\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python310\python.exe"),
    (Join-Path $env:ProgramFiles "Python314\python.exe"),
    (Join-Path $env:ProgramFiles "Python313\python.exe"),
    (Join-Path $env:ProgramFiles "Python312\python.exe")
  )
  
  $exe = Find-Executable "python" $paths
  if (-not $exe) { $exe = Find-Executable "python3" $paths }
  if (-not $exe) { return @{ Found = $false } }
  
  # Get version
  try {
    $output = & $exe --version 2>&1 | Select-Object -First 1
    $version = if ($output -match 'Python (\d+\.\d+\.\d+)') {
      [version]$Matches[1]
    } elseif ($output -match 'Python (\d+\.\d+)') {
      [version]("$($Matches[1]).0")
    } else {
      [version]"0.0.0"
    }
  } catch {
    $version = [version]"0.0.0"
  }
  
  # Check if it's from .venv
  $isVenv = $exe -match '[/\\]\.?venv[/\\]'
  
  return @{ Found = $true; Path = $exe; Version = $version; IsVenv = $isVenv }
}

function Get-GhInfo {
  $paths = @(
    (Join-Path $env:ProgramFiles "GitHub CLI\gh.exe"),
    (Join-Path $env:LOCALAPPDATA "GitHub CLI\gh.exe")
  )
  
  $exe = Find-Executable "gh" $paths
  if (-not $exe) { return @{ Found = $false } }
  
  try {
    $output = & $exe --version 2>&1 | Select-Object -First 1
    $version = if ($output -match 'gh version (\d+\.\d+\.\d+)') { [version]$Matches[1] } else { [version]"0.0.0" }
    $null = & $exe auth status 2>&1
    $authenticated = ($LASTEXITCODE -eq 0)
  } catch { 
    $version = [version]"0.0.0"
    $authenticated = $false
  }
  
  return @{ Found = $true; Path = $exe; Version = $version; Authenticated = $authenticated }
}

function Test-PythonPackage([string]$PythonExe, [string]$Package) {
  try {
    $null = & $PythonExe -c "import $Package" 2>&1
    return ($LASTEXITCODE -eq 0)
  } catch { return $false }
}

# ===============================
# Repository Functions
# ===============================
function Resolve-RepoRoot {
  # Try git first
  $git = Get-GitInfo
  if ($git.Found) {
    try {
      $p = & $git.Path rev-parse --show-toplevel 2>$null
      if ($LASTEXITCODE -eq 0 -and $p) { return $p.Trim() }
    } catch {}
  }
  
  # Fallback: walk up from current dir
  $d = (Get-Location).Path
  while ($true) {
    if (Test-Path -LiteralPath (Join-Path $d ".git")) { return $d }
    $parent = Split-Path -Path $d -Parent
    if (-not $parent -or $parent -eq $d) { break }
    $d = $parent
  }
  
  # Last fallback: script location
  if ($PSScriptRoot) {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  }
  
  return $null
}

function Find-AsgiAppImport([string]$RepoRoot) {
  # Heuristic: find a .py that defines "app = FastAPI" and use :app
  $candidates = Get-ChildItem -Path $RepoRoot -Recurse -Filter *.py -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(\.venv|venv|__pycache__|node_modules)\\' }

  foreach ($f in $candidates) {
    # Robust pattern: matches "app = FastAPI" with any spacing/typing
    $hit = Select-String -Path $f.FullName -Pattern '^\s*app\s*=\s*FastAPI\b' -ErrorAction SilentlyContinue
    if ($hit) {
      $rel = [IO.Path]::GetRelativePath($RepoRoot, $f.FullName)
      $mod = $rel -replace '\\','.' -replace '/','.' -replace '\.py$',''
      return "${mod}:app"
    }
  }
  return $null
}

# ===============================
# Server Functions
# ===============================
function Try-HttpJson([string]$Url, [int]$TimeoutSec = 2) {
  try {
    return Invoke-RestMethod -Method GET -Uri $Url -TimeoutSec $TimeoutSec
  } catch { return $null }
}

function Wait-ForServer([string]$HealthUrl, [int]$TimeoutSec = 20) {
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    $r = Try-HttpJson -Url $HealthUrl -TimeoutSec 1
    if ($null -ne $r) { return $true }
    Start-Sleep -Milliseconds 300
  }
  return $false
}

function Stop-ToolServer([int]$Port, [switch]$Force) {
  $netstat = netstat -ano 2>$null | Select-String ":$Port\s.*LISTENING"
  if (-not $netstat) {
    Info "No process found listening on port $Port"
    return $false
  }
  
  $stopped = $false
  foreach ($line in $netstat) {
    if ($line -match '\s+(\d+)$') {
      $procId = [int]$Matches[1]
      if ($procId -le 0) { continue }
      
      try {
        $proc = Get-Process -Id $procId -ErrorAction Stop
        $procName = $proc.ProcessName.ToLower()
        
        # Safety check: only kill python/pwsh processes (uvicorn runs in python)
        $safeProcNames = @("python", "python3", "pythonw", "pwsh", "powershell")
        $isSafe = $safeProcNames | Where-Object { $procName -like "*$_*" }
        
        if ($isSafe -or $Force) {
          Stop-Process -Id $procId -Force -ErrorAction Stop
          Info "Stopped $($proc.ProcessName) (PID: $procId)"
          $stopped = $true
        } else {
          Warn "Process on port $Port is '$($proc.ProcessName)' (PID: $procId) - not a Python process."
          Warn "Use -Force to kill anyway, or stop it manually."
        }
      } catch {
        Warn "Could not stop process $procId`: $_"
      }
    }
  }
  return $stopped
}

function Get-ServerStatus([string]$StatusUrl, [string]$HealthUrl = "", [string]$ExpectedRepoRoot = "") {
  $r = Try-HttpJson -Url $StatusUrl -TimeoutSec 2
  if ($null -eq $r) { return @{ Running = $false; Verified = $false } }
  
  # If we have a health URL and expected repo root, verify it's OUR server
  $verified = $true
  if ($HealthUrl -and $ExpectedRepoRoot) {
    $health = Try-HttpJson -Url $HealthUrl -TimeoutSec 2
    if ($health -and $health.repo_root) {
      # Normalize paths for comparison (trailing slashes, case)
      $serverRepo = $health.repo_root.TrimEnd('\', '/').ToLower()
      $expectedRepo = $ExpectedRepoRoot.TrimEnd('\', '/').ToLower()
      $verified = ($serverRepo -eq $expectedRepo)
    }
  }
  
  return @{ Running = $true; Response = $r; Verified = $verified }
}

# ===============================
# Main
# ===============================
$repoRoot = Resolve-RepoRoot
if (-not $repoRoot) { Fail "Repository root not found. Run from within the MystiMons repo." }

$baseUrl = "http://${BindHost}:${Port}"
$healthUrl = "$baseUrl/health"
$statusUrl = "$baseUrl/git/status"
$docsUrl = "$baseUrl/docs"

# Handle -Stop flag
if ($Stop) {
  Write-Header "Stopping Server"
  if (Stop-ToolServer -Port $Port -Force:$Force) {
    Info "Server stopped."
  } else {
    Info "No server was running on port $Port"
  }
  exit 0
}

Write-Header "MystiMons Development Environment"
if (-not $Quiet) {
  Write-Host "  Repository: $repoRoot" -ForegroundColor Gray
  Write-Host "  Target:     $baseUrl" -ForegroundColor Gray
  Write-Host ""
}

# ===============================
# Tool Checks
# ===============================
if (-not $Quiet) { Write-Host "Tools:" -ForegroundColor White }
$allToolsOk = $true

# Git
$git = Get-GitInfo
if ($git.Found) {
  $status = if ($git.Version -ge $script:Config.GitMinVersion) { "OK" } else { "WARN" }
  Write-Status "Git" $status "v$($git.Version) → $($git.Path)"
} else {
  Write-Status "Git" "FAIL" "Not found - https://git-scm.com/"
  $allToolsOk = $false
}

# Python (prefers .venv if available)
$python = Get-PythonInfo -RepoRoot $repoRoot
if ($python.Found) {
  $status = if ($python.Version -ge $script:Config.PythonMinVersion) { "OK" } else { "WARN" }
  $venvNote = if ($python.IsVenv) { " (.venv)" } else { "" }
  Write-Status "Python" $status "v$($python.Version)$venvNote"
  
  # Check packages
  $missing = @()
  foreach ($pkg in $script:Config.RequiredPackages) {
    if (-not (Test-PythonPackage $python.Path $pkg)) { $missing += $pkg }
  }
  
  if ($missing.Count -gt 0) {
    Write-Status "Packages" "WARN" "Missing: $($missing -join ', ')"
    if (-not $Quiet) {
      Write-Host "         Run: pip install $($missing -join ' ')" -ForegroundColor Yellow
    }
  } else {
    Write-Status "Packages" "OK" ($script:Config.RequiredPackages -join ", ")
  }
} else {
  Write-Status "Python" "FAIL" "Not found - https://python.org/"
  $allToolsOk = $false
}

# GitHub CLI (optional)
$gh = Get-GhInfo
if ($gh.Found) {
  $authStatus = if ($gh.Authenticated) { "(authenticated)" } else { "(run: gh auth login)" }
  $status = if ($gh.Authenticated) { "OK" } else { "WARN" }
  Write-Status "gh CLI" $status "v$($gh.Version) $authStatus"
} else {
  Write-Status "gh CLI" "INFO" "Not found (optional) - https://cli.github.com/"
}

if (-not $Quiet) { Write-Host "" }

# Exit early if just checking
if ($Check) {
  if ($allToolsOk) {
    Info "All required tools available."
    exit 0
  } else {
    Fail "Some required tools are missing."
  }
}

# Can't continue without Python
if (-not $python.Found) {
  Fail "Cannot start server - Python not found."
}

# ===============================
# Server Status / Start
# ===============================
if (-not $Quiet) { Write-Host "Server:" -ForegroundColor White }

$serverStatus = Get-ServerStatus -StatusUrl $statusUrl -HealthUrl $healthUrl -ExpectedRepoRoot $repoRoot

if ($serverStatus.Running) {
  if (-not $serverStatus.Verified) {
    Write-Status "Status" "WARN" "Server on $baseUrl is for DIFFERENT repo!"
    Write-Status "Action" "INFO" "Run: .\tools\dev.ps1 -Stop -Force"
    Warn "Then restart with: .\tools\dev.ps1"
  } else {
    Write-Status "Status" "OK" "Already running on $baseUrl"
    if ($serverStatus.Response.branch) {
      Write-Status "Branch" "INFO" $serverStatus.Response.branch
    }
    $dirty = if ($serverStatus.Response.dirty -eq $true) { "WARN" } else { "OK" }
    $dirtyText = if ($serverStatus.Response.dirty -eq $true) { "Dirty" } else { "Clean" }
    Write-Status "Tree" $dirty $dirtyText
  }
  
  if ($Open -and $serverStatus.Verified) { Start-Process $docsUrl | Out-Null }
} else {
  Write-Status "Status" "INFO" "Not running - starting..."
  
  # Determine app import
  if (-not $AppImport) {
    $AppImport = Find-AsgiAppImport -RepoRoot $repoRoot
  }
  if (-not $AppImport) {
    Fail "Could not auto-detect FastAPI 'app'. Provide -AppImport like: tools.tool_server.main:app"
  }
  
  Info "ASGI app: $AppImport"
  
  # Build uvicorn args
  $uvArgs = @("-m", "uvicorn", $AppImport, "--host", $BindHost, "--port", $Port.ToString())
  if (-not $NoReload) {
    $uvArgs += @("--reload", "--reload-dir", $repoRoot)
  }
  
  if ($Foreground) {
    Info "Starting server in foreground (Ctrl+C to stop)..."
    if (-not $Quiet) { Write-Host "" }
    & $python.Path @uvArgs
    exit $LASTEXITCODE
  }
  
  # Detached mode: new window
  # PS5.1 compatible (no ?. operator)
  $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
  $psExe = if ($pwshCmd) { $pwshCmd.Source } else { (Get-Command powershell).Source }
  
  $argLine = ($uvArgs | ForEach-Object {
    if ($_ -match '\s') { '"' + $_.Replace('"','\"') + '"' } else { $_ }
  }) -join ' '
  
  # Escape single quotes in paths for -Command string
  $repoRootEsc = $repoRoot.Replace("'", "''")
  $pythonPathEsc = $python.Path.Replace("'", "''")
  
  Info "Starting server in new window..."
  Start-Process -FilePath $psExe -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-NoExit",
    "-Command",
    "Set-Location '$repoRootEsc'; Write-Host 'MystiMons Tool Server' -ForegroundColor Cyan; & '$pythonPathEsc' $argLine"
  ) | Out-Null
  
  if (Wait-ForServer -HealthUrl $healthUrl -TimeoutSec 20) {
    Write-Status "Status" "OK" "Started on $baseUrl"
    $serverStatus = Get-ServerStatus -StatusUrl $statusUrl -HealthUrl $healthUrl -ExpectedRepoRoot $repoRoot
    if ($serverStatus.Response.branch) {
      Write-Status "Branch" "INFO" $serverStatus.Response.branch
    }
    if ($Open) { Start-Process $docsUrl | Out-Null }
  } else {
    Write-Status "Status" "WARN" "Started but not responding - check server window"
  }
}

if (-not $Quiet) { Write-Host "" }

# ===============================
# Endpoints & Commands
# ===============================
if (-not $Quiet) {
  Write-Host "Endpoints:" -ForegroundColor White
  Write-Host "  GET    /git/status           Repository status" -ForegroundColor Gray
  Write-Host "  POST   /git/push             Push to remote" -ForegroundColor Gray
  Write-Host "  GET    /health               Health check" -ForegroundColor Gray
  Write-Host "  GET    /docs                 API documentation (Swagger)" -ForegroundColor Gray
  Write-Host ""
  
  Write-Host "Quick Commands:" -ForegroundColor White
  Write-Host "  .\tools\flow.ps1 -Branch <n> -Message <msg> -Files @(...)" -ForegroundColor Gray
  Write-Host "  .\tools\flow.ps1 ... -AutoPR           # Auto-create PR" -ForegroundColor Gray
  Write-Host "  .\tools\flow.ps1 ... -AutoPR -OpenPR   # Create + open in browser" -ForegroundColor Gray
  Write-Host "  .\tools\dev.ps1 -Stop                  # Stop server (safe)" -ForegroundColor Gray
  Write-Host "  .\tools\dev.ps1 -Stop -Force           # Force stop any process" -ForegroundColor Gray
  Write-Host "  .\tools\dev.ps1 -Check                 # Check tools only" -ForegroundColor Gray
  Write-Host ""
}

# ===============================
# Final Status
# ===============================
$serverReady = $serverStatus.Running -and ($serverStatus.Verified -ne $false)

if ($allToolsOk -and $serverReady) {
  if (-not $Quiet) {
    Write-Host ("=" * 60) -ForegroundColor Green
    Write-Host "  Ready to develop!" -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Green
  }
  exit 0
} elseif ($allToolsOk -and $serverStatus.Running -and -not $serverStatus.Verified) {
  if (-not $Quiet) {
    Write-Host ("=" * 60) -ForegroundColor Yellow
    Warn "Server running but for WRONG repo - restart needed"
    Write-Host ("=" * 60) -ForegroundColor Yellow
  }
  exit 1
} elseif ($allToolsOk) {
  if (-not $Quiet) {
    Write-Host ("=" * 60) -ForegroundColor Yellow
    Warn "Tools OK, but server may not be fully ready"
    Write-Host ("=" * 60) -ForegroundColor Yellow
  }
  exit 0
} else {
  if (-not $Quiet) {
    Write-Host ("=" * 60) -ForegroundColor Red
  }
  Fail "Setup incomplete - see above"
}
