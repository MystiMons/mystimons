# RECOVERY: Stage deletions + add new files
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  FIXING COMMIT - STAGING ALL CHANGES" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

Write-Host "Current branch:" -ForegroundColor Yellow
git branch --show-current
Write-Host ""

Write-Host "1. Staging DELETIONS (v3.4-FIXED files)..." -ForegroundColor Yellow
# Stage alle Deletions
git add -u "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*.md"
Write-Host "   ✅ Deletions staged" -ForegroundColor Green
Write-Host ""

Write-Host "2. Staging NEW FILES (v3.6-REVIEW-FIXES)..." -ForegroundColor Yellow
# Stage K01-K10 v3.6 files
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K01_DER_KLANG_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K02_DER_SCHREI_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K03_DER_WEG_NACH_AQUARION_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K04_KORALLENWACHT_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K05_DIE_SPUR_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K06_DIE_FLUCHT_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K07_GLUTFELS_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K08_MITTERNACHTSFENSTER_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K09_DIE_BEFREIUNG_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K10_KONSEQUENZEN_v3.6_REVIEW-FIXES.md"

# Stage K11-K27 KEY-FIXES (already created)
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K11-K15_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K16-K20_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K21-K27_EPILOG_v3.6_REVIEW-FIXES.md"

Write-Host "   ✅ New outlines staged" -ForegroundColor Green
Write-Host ""

Write-Host "3. Staging REVIEWS..." -ForegroundColor Yellow
# Stage all review files
git add "02_NARRATIVE/book_01/OUTLINES/REVIEWS/*.md"
Write-Host "   ✅ Reviews staged" -ForegroundColor Green
Write-Host ""

Write-Host "4. Staging STARTER_22_FINAL.md..." -ForegroundColor Yellow
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
Write-Host "   ✅ Registry update staged" -ForegroundColor Green
Write-Host ""

Write-Host "5. Status check..." -ForegroundColor Yellow
git status
Write-Host ""

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ ALL CHANGES STAGED!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEP:" -ForegroundColor Yellow
Write-Host "Run: git commit -m 'chore: v3.6 outlines + cleanup v3.4-FIXED'" -ForegroundColor White
Write-Host "Then: git push -u origin chore/cleanup-v34-fixed" -ForegroundColor White
Write-Host ""
