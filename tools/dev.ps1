param(
  [int]$Port = 8000,
  [string]$BindHost = "127.0.0.1",
  [switch]$NoReload
)

$ErrorActionPreference = "Stop"

# Move to repo root (script location: <repo>\tools\dev.ps1)
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $RepoRoot

Write-Host "[dev] RepoRoot: $RepoRoot"

# Optional venv detection (if you use one)
$venvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$python = if (Test-Path $venvPython) { $venvPython } else { "python" }

# Verify python exists
try {
  & $python --version | Out-Host
} catch {
  Write-Error "[dev] Python not found. Install Python or create .venv in repo root."
  exit 1
}

# Quick import check (fast fail)
try {
  & $python -m py_compile (Join-Path $RepoRoot "server\app.py") | Out-Host
} catch {
  Write-Error "[dev] Syntax check failed: server/app.py"
  exit 1
}

# Start uvicorn
$reloadArg = if ($NoReload) { @() } else { @("--reload") }
Write-Host "[dev] Starting uvicorn on http://$BindHost`:$Port"

# Start server in a new PowerShell window so you keep this terminal for checks
$uvicornCmd = "uvicorn server.app:app --host $BindHost --port $Port " + ($reloadArg -join " ")
Start-Process -FilePath "powershell" -ArgumentList @("-NoExit", "-Command", "cd `"$RepoRoot`"; $uvicornCmd") | Out-Null

# Wait for healthcheck
$StatusUrl = "http://$BindHost`:$Port/git/status"
Write-Host "[dev] Waiting for /git/status ..."

$ok = $false
for ($i=0; $i -lt 30; $i++) {
  try {
    $r = Invoke-RestMethod -Method Get -Uri $StatusUrl -TimeoutSec 2
    if ($r.ok -eq $true) {
      $ok = $true
      Write-Host "[dev] OK: /git/status ok:true (branch=$($r.branch), dirty=$($r.dirty))"
      break
    }
  } catch {
    Start-Sleep -Milliseconds 500
  }
}

if (-not $ok) {
  Write-Warning "[dev] Server did not become ready. Check the uvicorn window for errors."
  exit 2
}

Write-Host "[dev] Done. Use /git/push for feature branches; main is protected."
