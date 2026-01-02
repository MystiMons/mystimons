# v3.6.2 FINAL-FIXES COMMIT
# Pascal Werner | 03.01.2026
# Löst alle Chatti-Blocker

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  v3.6.2 FINAL-FIXES COMMIT" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

# STEP 1: Run Verdantis Fix
Write-Host "1. Running Verdantis → Moosveil Fix..." -ForegroundColor Yellow
.\fix_verdantis_to_moosveil.ps1
Write-Host ""

# STEP 2: Stage Files (nur die die existieren!)
Write-Host "2. Staging all fixes..." -ForegroundColor Yellow
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K01-K10_v3.6.2_FINAL-FIXES.md"

# Nur Files die lokal existieren
if (Test-Path "01_REGISTRY/creatures/CREATURES_MASTER.md") {
    git add "01_REGISTRY/creatures/CREATURES_MASTER.md"
}
if (Test-Path "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K2_DER_SCHREI_v3.5_SAMMY.md") {
    git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K2_DER_SCHREI_v3.5_SAMMY.md"
}
if (Test-Path "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K17_THEO_v3.5_SAMMY.md") {
    git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K17_THEO_v3.5_SAMMY.md"
}

Write-Host "   ✅ Done" -ForegroundColor Green

# STEP 3: Commit
Write-Host ""
Write-Host "3. Committing..." -ForegroundColor Yellow

$commitMsg = @"
fix: v3.6.2 FINAL-FIXES - Chatti blocker gelöst

BLOCKER 1 GELÖST: Verdantis → Moosveil (lokale Files)
- CREATURES_MASTER.md: name + reunion K17
- K2_DER_SCHREI_v3.5: Bild + Canon-Check
- K17_THEO_v3.5: 7 Stellen gefixt
(K9 nur auf GitHub, automatisch beim Merge)

BLOCKER 2 GELÖST: Bindungs-Timing finalisiert
- K24 = Bindung (emotionaler Climax)
- K25 = Bewährung (Kampf-Proof)
- Begründung dokumentiert

ZUSÄTZLICHE FIXES:
- Theo Alter: 19 Jahre (finalisiert)
- LAW-008: Nur für Aetherion (nicht Absorption)
- LAW-006: K27 Reminder (keine Kinder on-screen)

DOKUMENTATION:
- K01-K10_v3.6.2_FINAL-FIXES.md (vollständig)

Status: Bereit für Chatti Final-Review
"@

git commit -m $commitMsg
Write-Host "   ✅ Committed" -ForegroundColor Green

# STEP 4: Push
Write-Host ""
Write-Host "4. Pushing..." -ForegroundColor Yellow
git push origin chore/cleanup-v34-fixed
Write-Host "   ✅ Pushed" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ DONE! PR UPDATED!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE:" -ForegroundColor Yellow
Write-Host "K9 ist nur auf GitHub und wird automatisch beim Merge dabei sein." -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Check PR on GitHub" -ForegroundColor White
Write-Host "2. Send CHATTI_FINAL_REVIEW_v362.md to ChatGPT" -ForegroundColor White
Write-Host "3. Wait for GREEN LIGHT" -ForegroundColor White
Write-Host "4. Merge PR" -ForegroundColor White
Write-Host "5. SAMMY WRITES KAPITEL 1! 🔥" -ForegroundColor White
Write-Host ""
