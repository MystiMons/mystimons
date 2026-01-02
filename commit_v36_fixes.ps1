# MYSTIMONS v3.6 FINAL FIXES - COMMIT SCRIPT
# Pascal Werner | 02.01.2026

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  MYSTIMONS v3.6 FINAL FIXES - COMMIT WORKFLOW" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Pfad zum Repo
$repoPath = "E:\_MYSTIMONS_AAA\MYSTIMONS"
Set-Location $repoPath

Write-Host "1. Checking current branch..." -ForegroundColor Yellow
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "   Current branch: $currentBranch" -ForegroundColor White

if ($currentBranch -eq "main") {
    Write-Host "   ⚠️  On main branch - creating feature branch..." -ForegroundColor Yellow
    
    # Erstelle Feature Branch
    $branchName = "feature/v36-final-fixes"
    Write-Host "   Creating branch: $branchName" -ForegroundColor Green
    git checkout -b $branchName
    
    Write-Host "   ✅ Branch created and switched" -ForegroundColor Green
} else {
    Write-Host "   ✅ On feature branch: $currentBranch" -ForegroundColor Green
}

Write-Host ""
Write-Host "2. Staging files..." -ForegroundColor Yellow

# Stage alle geänderten Files
git add "01_REGISTRY/creatures/STARTER_22_FINAL.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K11-K15_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K16-K20_v3.6_REVIEW-FIXES.md"
git add "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K21-K27_EPILOG_v3.6_REVIEW-FIXES.md"

Write-Host "   ✅ 4 files staged" -ForegroundColor Green

Write-Host ""
Write-Host "3. Committing..." -ForegroundColor Yellow

# Commit Message
$commitMsg = @"
chore: v3.6 final fixes - Canon-Klärungen integriert

ÄNDERUNGEN:
- Verdantis → Moosveil (Verdantis = Ur-Resonant)
- Embrix = Rex (nicht Brennan)
- Theo = 19 Jahre (nicht minderjährig)
- Ferron = Resonant (gebunden + dominiert)
- Finn/Sylphira: "Erste die sich traut" (kein Retcon)
- Finns Symptome vollständig definiert (gestaffelt)
- Nila-Mechanik: Resonanten-Chor + Mund-zu-Mund
- Einsammeln = bewusst vage
- Absorption = atmosphärisch (nicht erklären)

FILES:
- STARTER_22_FINAL.md (v1.0.1)
- K11-K15_v3.6_REVIEW-FIXES.md
- K16-K20_v3.6_REVIEW-FIXES.md
- K21-K27_EPILOG_v3.6_REVIEW-FIXES.md

Status: ✅ READY FOR CHATTI REVIEW
"@

git commit -m $commitMsg

Write-Host "   ✅ Committed" -ForegroundColor Green

Write-Host ""
Write-Host "4. Pushing to remote..." -ForegroundColor Yellow

# Push Branch
$currentBranch = git rev-parse --abbrev-ref HEAD
git push -u origin $currentBranch

Write-Host "   ✅ Pushed to origin/$currentBranch" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ COMMIT WORKFLOW COMPLETE!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Create PR on GitHub: $currentBranch -> main" -ForegroundColor White
Write-Host "2. Send CHATTI_REVIEW_REQUEST.md to ChatGPT" -ForegroundColor White
Write-Host "3. Wait for Chatti's confirmation" -ForegroundColor White
Write-Host "4. Merge PR after approval" -ForegroundColor White
Write-Host ""
