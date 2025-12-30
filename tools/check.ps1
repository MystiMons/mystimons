# tools/check.ps1
[CmdletBinding()]
param(
  [string]$BindHost = "127.0.0.1",
  [int]$Port = 8000,

  # Backward/forward compatible naming:
  [Alias("MaxWaitSec")]
  [int]$WaitSeconds = 20
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Find-RepoRoot {
  param([string]$Start)
  $p = (Resolve-Path $Start).Path
  while ($true) {
    if (Test-Path (Join-Path $p ".git")) { return $p }
    $parent = Split-Path -Parent $p
    if ($parent -eq $p -or [string]::IsNullOrWhiteSpace($parent)) { break }
    $p = $parent
  }
  throw "RepoRoot not found (no .git) starting from: $Start"
}

function Try-ReadErrorBody {
  param($Err)
  try {
    if ($Err.Exception -and $Err.Exception.Response -and $Err.Exception.Response.GetResponseStream) {
      $stream = $Err.Exception.Response.GetResponseStream()
      if ($stream) {
        $reader = New-Object System.IO.StreamReader($stream)
        return $reader.ReadToEnd()
      }
    }
  } catch {}
  return $null
}

$RepoRoot = Find-RepoRoot (Get-Location).Path
$BaseUrl  = "http://$BindHost`:$Port"
$StatusUrl = "$BaseUrl/git/status"
$PushUrl   = "$BaseUrl/git/push"

Write-Host ("[check] RepoRoot: {0}" -f $RepoRoot)
Write-Host ("[check] StatusURL: {0}" -f $StatusUrl)

# 1) Ensure server reachable; if not, start dev.ps1
$reachable = $false
for ($i = 0; $i -lt $WaitSeconds; $i++) {
  try {
    Invoke-RestMethod -Method Get -Uri $StatusUrl -TimeoutSec 2 | Out-Null
    $reachable = $true
    break
  } catch {
    Start-Sleep -Seconds 1
  }
}

if (-not $reachable) {
  Write-Host "[check] Server nicht erreichbar -> starte tools/dev.ps1 ..."
  $dev = Join-Path $RepoRoot "tools\dev.ps1"
  if (-not (Test-Path $dev)) { throw "tools/dev.ps1 not found at: $dev" }

  & $dev -BindHost $BindHost -Port $Port | Out-Null

  # re-check
  $reachable = $false
  for ($i = 0; $i -lt $WaitSeconds; $i++) {
    try {
      Invoke-RestMethod -Method Get -Uri $StatusUrl -TimeoutSec 2 | Out-Null
      $reachable = $true
      break
    } catch {
      Start-Sleep -Seconds 1
    }
  }

  if (-not $reachable) {
    throw "[check] Server did not become ready. Check the uvicorn window for errors."
  }
}

# 2) /git/status
$st = Invoke-RestMethod -Method Get -Uri $StatusUrl -TimeoutSec 5
Write-Host ("[check] /git/status ok:{0} (branch={1}, dirty={2})" -f $st.ok, $st.branch, $st.dirty)

# 3) Guardrail test: POST /git/push on main must be blocked (403)
Write-Host "[check] Testing guardrail: POST /git/push (expect 403 on main) ..."

try {
  Invoke-RestMethod -Method Post -Uri $PushUrl -ContentType "application/json" -Body "{}" -TimeoutSec 10 | Out-Null
  Write-Warning "[check] Unerwartet: /git/push wurde NICHT geblockt."
  exit 4
} catch {
  $statusCode = $null
  try { $statusCode = [int]$_.Exception.Response.StatusCode } catch {
    try { $statusCode = [int]$_.Exception.Response.StatusCode.value__ } catch {}
  }

  $body = Try-ReadErrorBody $_
  $msg = $null
  if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $msg = $_.ErrorDetails.Message }
  if (-not $msg) { $msg = $_.Exception.Message }
  if ($body) { $msg = $body }

  if ($statusCode -eq 403 -or ($msg -match "403")) {
    Write-Host "[check] OK: Guardrail aktiv (403)."
  } else {
    if ($null -eq $statusCode) { $statusCode = "n/a" }
    Write-Warning "[check] Unerwarteter Fehlercode/Fehler:"
    Write-Host ("[check] status={0}" -f $statusCode)
    Write-Host ("[check] message={0}" -f $msg)
    exit 5
  }
}

Write-Host "[check] Done."
exit 0
