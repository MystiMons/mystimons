# COMPLETE v3.6 + v3.6.1 COMMIT (DELETE v3.5 + v3.4)
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  COMPLETE OUTLINES COMMIT (v3.6 + v3.6.1)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

Write-Host "1. Staging v3.4-FIXED DELETIONS..." -ForegroundColor Yellow
git rm "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*v3_4_FIXED.md" 2>$null
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "2. Staging v3.5_SAMMY DELETIONS..." -ForegroundColor Yellow
git rm "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*v3.5_SAMMY.md" 2>$null
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "3. Staging K01-K10 v3.6 + v3.6.1..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K0*_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K01-K10_v3.6.1_UPDATE.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "4. Staging K11-K27 v3.6..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K11-K15_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K16-K20_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K21-K27_EPILOG_v3.6_REVIEW-FIXES.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "5. Staging STARTER_22..." -ForegroundColor Yellow
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "6. Staging REVIEWS..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/REVIEWS/K*.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host ""
Write-Host "7. Git status check..." -ForegroundColor Yellow
git status --short
Write-Host ""

Write-Host "8. Committing..." -ForegroundColor Yellow

$commitMsg = @"
chore: v3.6 + v3.6.1 outlines complete (replace v3.5 + v3.4)

ADDED:
- K01-K10 v3.6_REVIEW-FIXES (AI-reviewed, 01.01)
- K01-K10 v3.6.1_UPDATE (today's clarifications, 02.01)
- K11-K15 v3.6_REVIEW-FIXES (bundled)
- K16-K20 v3.6_REVIEW-FIXES (bundled)
- K21-K27 + Epilog v3.6_REVIEW-FIXES (bundled)
- All AI review files (K01-K27)
- STARTER_22_FINAL.md v1.0.1 (Verdantis → Moosveil)

REMOVED:
- K1-K27 v3.5_SAMMY (replaced by v3.6)
- K1-K9 v3.4_FIXED (obsolete)

KEY UPDATES (v3.6.1):
- Embrix = REX (not Brennan!) - CRITICAL FIX
- Theo = 19 years old
- Finn/Sylphira: "First who dares" (no retcon)
- Ferron = Resonant (bound + dominated)
- Finn's symptoms fully defined
- Nila mechanism: Resonant-Choir + Word-of-Mouth
- Moosveil (not Verdantis - Verdantis = Ur-Resonant)

v3.6 = AI-reviewed base (K01-K27)
v3.6.1 = Supplemental clarifications (K01-K10 only)
Together = Final canonical outlines

Status: Ready for Chatti final review → Writing
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green

Write-Host ""
Write-Host "9. Pushing..." -ForegroundColor Yellow
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
Write-Host "THEN: Send CHATTI_REVIEW_REQUEST_UPDATED.md to ChatGPT" -ForegroundColor Yellow
Write-Host ""
