# K9 WIEDERHERSTELLUNG - Commit & Push
# Pascal Werner | 03.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  K9 WIEDERHERSTELLUNG" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

# Check ob File existiert
Write-Host "1. Checking K9 file..." -ForegroundColor Yellow
$k9File = "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K9_DIE_BEFREIUNG_v3.5_SAMMY.md"

if (Test-Path $k9File) {
    Write-Host "   ✅ K9 file exists!" -ForegroundColor Green
} else {
    Write-Host "   ❌ K9 file NOT found!" -ForegroundColor Red
    exit 1
}

# Stage
Write-Host ""
Write-Host "2. Staging K9..." -ForegroundColor Yellow
git add $k9File
Write-Host "   ✅ Staged" -ForegroundColor Green

# Commit
Write-Host ""
Write-Host "3. Committing..." -ForegroundColor Yellow

$commitMsg = @"
fix: restore K9_DIE_BEFREIUNG_v3.5_SAMMY.md (mit Moosveil-Fix)

K9 wurde versehentlich gelöscht und wiederhergestellt.
Verdantis → Moosveil Fixes bereits integriert:
- "Finn fokussiert (Moosveil...)"
- "Moosveil-Spike bei Extremstress"

Status: K9 komplett + alle v3.6.2 Fixes vorhanden
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green

# Push
Write-Host ""
Write-Host "4. Pushing..." -ForegroundColor Yellow
git push origin main
Write-Host "   ✅ Pushed to main" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ K9 WIEDERHERGESTELLT!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "K9 ist jetzt wieder da mit allen Moosveil-Fixes!" -ForegroundColor White
Write-Host ""
Write-Host "NEXT:" -ForegroundColor Yellow
Write-Host "1. Merge PR (chore/cleanup-v34-fixed)" -ForegroundColor White
Write-Host "2. Send CHATTI_FINAL_REVIEW_v362.md" -ForegroundColor White
Write-Host "3. GREEN LIGHT!" -ForegroundColor White
Write-Host "4. SAMMY WRITES! 🔥" -ForegroundColor White
Write-Host ""
