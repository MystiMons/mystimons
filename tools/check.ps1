# tools/check.ps1
[CmdletBinding()]
param(
  [string]$BindHost = "127.0.0.1",
  [int]$Port = 8000,
  [int]$WaitSeconds = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Find-RepoRoot {
  param([string]$Start)
  $p = (Resolve-Path $Start).Path
  while ($true) {
    if (Test-Path (Join-Path $p ".git")) { return $p }
    $parent = Split-Path -Parent $p
    if ($parent -eq $p -or [string]::IsNullOrWhiteSpace($parent)) { return $null }
    $p = $parent
  }
}

function Try-GetStatus {
  param([string]$Url)
  try {
    return Invoke-RestMethod -Method Get -Uri $Url -TimeoutSec 2
  } catch {
    return $null
  }
}

$repoRoot = Find-RepoRoot -Start (Get-Location).Path
if (-not $repoRoot) {
  throw "RepoRoot nicht gefunden (.git nicht in Elternverzeichnissen). Starte das Script aus dem Repo heraus."
}

$devScript = Join-Path $repoRoot "tools\dev.ps1"
if (-not (Test-Path $devScript)) {
  throw "dev.ps1 nicht gefunden unter: $devScript"
}

$statusUrl = "http://$BindHost`:$Port/git/status"
$pushUrl   = "http://$BindHost`:$Port/git/push"

Write-Host "[check] RepoRoot: $repoRoot"
Write-Host "[check] StatusURL: $statusUrl"

# 1) Server ggf. starten (wenn /git/status noch nicht erreichbar)
$st = Try-GetStatus -Url $statusUrl
if (-not $st) {
  Write-Host "[check] Server nicht erreichbar -> starte tools/dev.ps1 ..."
  # dev.ps1 startet i.d.R. uvicorn in eigenem Fenster; wir warten dann hier auf readiness
  & $devScript | Out-Null
}

# 2) Wait for readiness
$deadline = (Get-Date).AddSeconds($WaitSeconds)
do {
  Start-Sleep -Milliseconds 500
  $st = Try-GetStatus -Url $statusUrl
} until ($st -or (Get-Date) -ge $deadline)

if (-not $st) {
  Write-Warning "[check] Server wurde nicht rechtzeitig ready. Schau ins uvicorn/dev Fenster."
  exit 2
}

Write-Host ("[check] /git/status ok:true (branch={0}, dirty={1})" -f $st.branch, $st.dirty)

# 3) Guardrail: /git/push auf main muss blocken (403)
Write-Host "[check] Testing guardrail: POST /git/push (expect 403 on main) ..."
$ok = $false
try {
  $r = Invoke-RestMethod -Method Post -Uri $pushUrl -ContentType "application/json" -Body "{}" -TimeoutSec 15
  # Wenn wir hier landen, war es 2xx (unerwartet)
  Write-Warning "[check] Unerwartet: /git/push hat 2xx geliefert. Response:"
  $r | Format-List | Out-String | Write-Host
  exit 3
} catch {
  # Windows PowerShell: StatusCode oft über .Exception.Response
  $statusCode = $null
  try {
    if ($_.Exception -and $_.Exception.Response) {
      $statusCode = [int]$_.Exception.Response.StatusCode
    }
  } catch { }

  # Fallback: Fehlertext
  $msg = $null
  try {
    if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $msg = $_.ErrorDetails.Message }
    else { $msg = $_.Exception.Message }
  } catch { $msg = "unknown error" }

  if ($statusCode -eq 403 -or ($msg -match "403")) {
    Write-Host "[check] OK: Guardrail aktiv (403)."
    $ok = $true
  } else {
    Write-Warning "[check] Unerwarteter Fehlercode/Fehler:"
    Write-Host ("[check] status={0}" -f ($statusCode ?? "n/a"))
    Write-Host ("[check] message={0}" -f $msg)
    exit 4
  }
}

Write-Host "[check] Done."
exit 0
