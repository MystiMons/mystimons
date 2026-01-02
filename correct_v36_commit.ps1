# CORRECT v3.6 + v3.6.1 COMMIT (KEEP v3.5!)
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  v3.6 + v3.6.1 FIXES COMMIT (v3.5 bleibt!)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

Write-Host "1. Staging v3.4-FIXED DELETIONS (obsolet)..." -ForegroundColor Yellow
git rm "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/*v3_4_FIXED.md" 2>$null
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "2. v3.5_SAMMY Files bleiben!" -ForegroundColor Green
Write-Host "   (Basis-Outlines, werden NICHT gelöscht)" -ForegroundColor White

Write-Host ""
Write-Host "3. Staging K01-K10 v3.6 + v3.6.1..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K0*_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K01-K10_v3.6.1_UPDATE.md"
Write-Host "   ✅ Done" -ForegroundColor Green

Write-Host "4. Staging K11-K27 v3.6 (KEY-FIXES)..." -ForegroundColor Yellow
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
chore: add v3.6 + v3.6.1 fixes/updates (v3.5 base remains)

STRUCTURE:
- v3.5_SAMMY (K01-K27) = Base outlines (UNCHANGED)
- v3.6_REVIEW-FIXES = AI review fixes
- v3.6.1_UPDATE = Additional clarifications

ADDED:
- K01-K10 v3.6_REVIEW-FIXES (complete revised outlines)
- K01-K10 v3.6.1_UPDATE (supplemental updates)
- K11-K15 v3.6_REVIEW-FIXES (KEY-FIXES document)
- K16-K20 v3.6_REVIEW-FIXES (KEY-FIXES document)
- K21-K27 v3.6_REVIEW-FIXES (KEY-FIXES document)
- All AI review files K01-K27
- STARTER_22_FINAL.md v1.0.1 (Verdantis → Moosveil)

REMOVED:
- K1-K9 v3.4_FIXED (obsolete)

KEY UPDATES (v3.6.1):
- Embrix = REX (not Brennan!) - CRITICAL FIX
- Theo = 19 years old
- Finn/Sylphira: "First who dares" (no retcon)
- Ferron = Resonant (bound + dominated)
- Finn's symptoms fully defined
- Nila mechanism: Resonant-Choir + Word-of-Mouth
- Moosveil (not Verdantis)

READING GUIDE:
K01-K10: Read v3.6_REVIEW-FIXES + v3.6.1_UPDATE
K11-K27: Read v3.5_SAMMY + v3.6_REVIEW-FIXES together

Status: Ready for Chatti review → Writing
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
Write-Host "FILES STRUCTURE:" -ForegroundColor Yellow
Write-Host "K01-K10: v3.6 (complete) + v3.6.1 (updates)" -ForegroundColor White
Write-Host "K11-K27: v3.5 (base) + v3.6 (fixes)" -ForegroundColor White
Write-Host ""
Write-Host "PR Link:" -ForegroundColor Yellow
Write-Host "https://github.com/MystiMons/mystimons/pull/new/chore/cleanup-v34-fixed" -ForegroundColor Cyan
Write-Host ""
Write-Host "THEN: Send CHATTI_REVIEW_REQUEST_UPDATED.md" -ForegroundColor Yellow
Write-Host ""
