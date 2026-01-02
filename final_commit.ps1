# FINAL COMMIT - Add missing files + commit + push
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "Adding missing bundled files..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K11-K15_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K16-K20_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K21-K27_EPILOG_v3.6_REVIEW-FIXES.md"
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
Write-Host "✅ Bundled files added" -ForegroundColor Green

Write-Host ""
Write-Host "Committing..." -ForegroundColor Yellow

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
Write-Host "✅ Committed" -ForegroundColor Green

Write-Host ""
Write-Host "Pushing..." -ForegroundColor Yellow
git push origin chore/cleanup-v34-fixed
Write-Host "✅ Pushed" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ DONE! CREATE PR NOW!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PR Link:" -ForegroundColor Yellow
Write-Host "https://github.com/MystiMons/mystimons/pull/new/chore/cleanup-v34-fixed" -ForegroundColor Cyan
Write-Host ""
