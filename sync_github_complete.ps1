# COMPLETE GITHUB SYNC - Alle Änderungen pushen
# Pascal Werner | 03.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  COMPLETE GITHUB SYNC" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

# STEP 1: Git Status
Write-Host "1. Checking Git Status..." -ForegroundColor Yellow
Write-Host ""
git status
Write-Host ""

# STEP 2: Check Branch
Write-Host "2. Current Branch:" -ForegroundColor Yellow
$currentBranch = git branch --show-current
Write-Host "   $currentBranch" -ForegroundColor White
Write-Host ""

# STEP 3: Stage ALL Changes
Write-Host "3. Staging ALL changes..." -ForegroundColor Yellow
git add -A
Write-Host "   ✅ All files staged" -ForegroundColor Green
Write-Host ""

# STEP 4: Show what will be committed
Write-Host "4. Files to commit:" -ForegroundColor Yellow
git status --short
Write-Host ""

# STEP 5: Commit
Write-Host "5. Committing..." -ForegroundColor Yellow

$commitMsg = @"
fix: complete v3.6.2 sync + K9 restore + all Moosveil fixes

ALLE ÄNDERUNGEN:
- K01-K10_v3.6.2_FINAL-FIXES.md (neue Doku)
- K9_DIE_BEFREIUNG_v3.5_SAMMY.md (wiederhergestellt)
- CREATURES_MASTER.md (Verdantis → Moosveil)
- K2, K9, K17 v3.5 (Verdantis → Moosveil)
- Bindungs-Timing: K24 (finalisiert)
- Theo: 19 Jahre (finalisiert)
- LAW-008 + LAW-006 korrigiert

STATUS: Alle Chatti-Blocker gelöst, bereit für Schreiben
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green
Write-Host ""

# STEP 6: Push
Write-Host "6. Pushing to GitHub..." -ForegroundColor Yellow
git push origin $currentBranch
Write-Host "   ✅ Pushed to origin/$currentBranch" -ForegroundColor Green
Write-Host ""

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ GITHUB SYNC COMPLETE!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Local → GitHub synchronized!" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Check GitHub repo online" -ForegroundColor White
Write-Host "2. Merge any open PRs" -ForegroundColor White
Write-Host "3. Pull latest from main" -ForegroundColor White
Write-Host "4. READY TO WRITE! 🔥" -ForegroundColor White
Write-Host ""
