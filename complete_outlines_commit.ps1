# COMPLETE v3.6 + v3.6.1 COMMIT
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  COMPLETE OUTLINES COMMIT (v3.6 + v3.6.1)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

Write-Host "1. Staging K01-K10 v3.6 + v3.6.1..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K0*_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K01-K10_v3.6.1_UPDATE.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "2. Staging K11-K27 v3.6..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K11-K15_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K16-K20_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K21-K27_EPILOG_v3.6_REVIEW-FIXES.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "3. Staging STARTER_22..." -ForegroundColor Yellow
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "4. Staging REVIEWS..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/REVIEWS/K*.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "5. Staging v3.4-FIXED DELETIONS..." -ForegroundColor Yellow
git add -u "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host ""
Write-Host "6. Committing..." -ForegroundColor Yellow

$commitMsg = @"
chore: v3.6 + v3.6.1 outlines complete (K01-K27)

ADDED:
- K01-K10 v3.6_REVIEW-FIXES (existing, from 01.01)
- K01-K10 v3.6.1_UPDATE (today's clarifications)
- K11-K15 v3.6_REVIEW-FIXES (bundled)
- K16-K20 v3.6_REVIEW-FIXES (bundled)
- K21-K27 + Epilog v3.6_REVIEW-FIXES (bundled)
- All AI review files (K01-K27)
- STARTER_22_FINAL.md v1.0.1 (Verdantis → Moosveil)

REMOVED:
- K1-K9 v3.4-FIXED (obsolete)

KEY UPDATES (v3.6.1):
- Embrix = REX (not Brennan!) - CRITICAL FIX
- Theo = 19 years old
- Finn/Sylphira: "First who dares" (no retcon)
- Ferron = Resonant (bound + dominated)
- Finn's symptoms fully defined
- Nila mechanism: Resonant-Choir + Word-of-Mouth
- Moosveil (not Verdantis - Verdantis = Ur-Resonant)

Status: Ready for Chatti final review
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green

Write-Host ""
Write-Host "7. Pushing..." -ForegroundColor Yellow
git push origin chore/cleanup-v34-fixed
Write-Host "   ✅ Pushed" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ DONE! CREATE PR NOW!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PR Link:" -ForegroundColor Yellow
Write-Host "https://github.com/MystiMons/mystimons/pull/new/chore/cleanup-v34-fixed" -ForegroundColor Cyan
Write-Host ""
Write-Host "THEN: Send CHATTI_REVIEW_REQUEST.md to ChatGPT" -ForegroundColor Yellow
Write-Host ""
