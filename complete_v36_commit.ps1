# COMPLETE FIX: Stage + Commit + Push
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  COMPLETE v3.6 OUTLINES COMMIT" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

Write-Host "1. Staging DELETIONS..." -ForegroundColor Yellow
git add -u "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "2. Staging NEW v3.6 FILES..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K*_v3.6_REVIEW-FIXES.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "3. Staging REVIEWS..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/REVIEWS/*.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "4. Staging STARTER_22..." -ForegroundColor Yellow
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host ""
Write-Host "5. Committing..." -ForegroundColor Yellow

$commitMsg = @"
chore: v3.6 outlines complete + remove v3.4-FIXED

ADDED:
- K01-K10 v3.6-REVIEW-FIXES (individual files)
- K11-K15 v3.6-REVIEW-FIXES (bundled)
- K16-K20 v3.6-REVIEW-FIXES (bundled)
- K21-K27 + Epilog v3.6-REVIEW-FIXES (bundled)
- All AI review files (K01-K27)
- STARTER_22_FINAL.md (Verdantis → Moosveil)

REMOVED:
- K1-K9 v3.4-FIXED (obsolete)

Status: Ready for final review + writing
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green

Write-Host ""
Write-Host "6. Force-pushing (fixing empty commit)..." -ForegroundColor Yellow
git push -f origin chore/cleanup-v34-fixed
Write-Host "   ✅ Pushed" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ COMPLETE!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT: Create PR on GitHub" -ForegroundColor Yellow
Write-Host "https://github.com/MystiMons/mystimons/pull/new/chore/cleanup-v34-fixed" -ForegroundColor Cyan
Write-Host ""
