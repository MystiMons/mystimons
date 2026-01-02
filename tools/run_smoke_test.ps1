param(
  [string]$BaseUrl = "http://127.0.0.1:8001",
  [string]$SetId = "SET-001",
  [string[]]$CandidatePaths = @(
    "README.md",
    "99_DECISIONS/DECISION_LOG.md",
    "99_DECISIONS/INTEGRATION_NOTES_2025-12-30.md"
  ),
  [switch]$IncludeCanonGateTest
)

$ErrorActionPreference = "Stop"

function Invoke-Json {
  param(
    [Parameter(Mandatory=$true)][string]$Method,
    [Parameter(Mandatory=$true)][string]$Url,
    $Body = $null
  )
  if ($null -ne $Body) {
    $json = $Body | ConvertTo-Json -Depth 20
    return Invoke-RestMethod -Method $Method -Uri $Url -ContentType "application/json" -Body $json
  } else {
    return Invoke-RestMethod -Method $Method -Uri $Url
  }
}

function Try-StageFromCurrent {
  param(
    [string]$ChangeId,
    [string]$Path,
    [string]$DecisionId = $null,
    [string]$Rationale = $null
  )

  # Some builds call it /changes/stage_from_current, others /changes/stage_from_current or /changes/stage_from_current.
  # We'll try the common one first:
  $endpoints = @(
    "$BaseUrl/changes/stage_from_current",
    "$BaseUrl/changes/stage_from_current",   # duplicate ok
    "$BaseUrl/changes/stage_from_current"    # keep as fallback slot
  ) | Select-Object -Unique

  $payload = @{
    change_id = $ChangeId
    path      = $Path
  }
  if ($DecisionId) { $payload.decision_id = $DecisionId }
  if ($Rationale)  { $payload.rationale   = $Rationale }

  foreach ($ep in $endpoints) {
    try {
      return Invoke-Json -Method "POST" -Url $ep -Body $payload
    } catch {
      # try next endpoint
    }
  }
  throw "stage_from_current endpoint not reachable (tried: $($endpoints -join ', '))."
}

Write-Host "== MystiMons Smoke Test =="

# 0) Health
$health = Invoke-Json -Method "GET" -Url "$BaseUrl/health"
Write-Host "Health ok: $($health.ok) | repo_root=$($health.repo_root)"

# 1) Open change
$open = Invoke-Json -Method "POST" -Url "$BaseUrl/changes/open" -Body @{
  title  = "Smoke test"
  intent = "Automated smoke test: stage -> validate -> commit"
  author = "Pommes"
}
$changeId = $open.change_id
Write-Host "Opened change_id: $changeId"

# 2) Optional: Canon gate test (expected 403 without decision_id)
if ($IncludeCanonGateTest) {
  Write-Host "Canon gate test: expecting 403 without decision_id ..."
  try {
    $null = Try-StageFromCurrent -ChangeId $changeId -Path "00_CANON/SINGLE_SOURCE_OF_TRUTH.md"
    Write-Host "WARNING: Canon gate did not block (unexpected)."
  } catch {
    Write-Host "Canon gate block OK (expected)."
  }

  Write-Host "Canon gate pass: staging with decision_id ..."
  $canon = Try-StageFromCurrent -ChangeId $changeId -Path "00_CANON/SINGLE_SOURCE_OF_TRUTH.md" -DecisionId "DEC-SMOKE-001" -Rationale "Smoke test"
  Write-Host "Canon staged: $($canon.staged)"
}

# 3) Pick a test file that exists (via /artifact)
$chosen = $null
$artifact = $null
foreach ($p in $CandidatePaths) {
  try {
    $artifact = Invoke-Json -Method "GET" -Url ("$BaseUrl/artifact?path=" + [uri]::EscapeDataString($p))
    $chosen = $p
    break
  } catch {
    # try next
  }
}
if (-not $chosen) {
  throw "Could not find any candidate test file via /artifact. Tried: $($CandidatePaths -join ', ')"
}
Write-Host "Chosen test file: $chosen"

# 4) Modify content (append a line)
$baseSha = $artifact.sha256
$content = $artifact.content

$stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$appendLine = "`nSMOKE_TEST: $stamp (change_id=$changeId)`n"
$newContent = $content + $appendLine

# 5) Stage modified file
$stage = Invoke-Json -Method "POST" -Url "$BaseUrl/changes/stage" -Body @{
  change_id    = $changeId
  path         = $chosen
  base_sha256  = $baseSha
  new_content  = $newContent
  decision_id  = $null
  rationale    = "Smoke test edit (append line)"
}
Write-Host "Staged: $($stage.staged) | new_sha256=$($stage.new_sha256)"

# 6) Validate (set-scoped by default)
$valPayload = @{
  change_id = $changeId
  strict    = $false
}
if ($SetId -and $SetId.Trim().Length -gt 0) { $valPayload.set_id = $SetId }

$val = Invoke-Json -Method "POST" -Url "$BaseUrl/changes/validate" -Body $valPayload
Write-Host "Validate ok: $($val.ok) | exit_code=$($val.exit_code)"

if (-not $val.ok) {
  Write-Host "---- Validator stdout ----"
  Write-Host $val.stdout
  throw "Validation failed; refusing to commit."
}

# 7) Commit (to a smoke branch)
$branch = "smoke/$($changeId.Substring(0,8))"
$commit = Invoke-Json -Method "POST" -Url "$BaseUrl/changes/commit" -Body @{
  change_id    = $changeId
  branch_name  = $branch
  message      = "chore(smoke): commit staged changes ($changeId)"
}

Write-Host "Commit result: committed=$($commit.committed) | branch=$($commit.branch)"
if ($commit.committed -and $commit.commit) {
  Write-Host "Commit hash: $($commit.commit)"
} else {
  Write-Host "Reason: $($commit.reason)"
}

Write-Host "== DONE =="
