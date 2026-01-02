# MystiMons Cleanup Old Outlines (PowerShell)
# Löscht alte v3_4_FIXED Outline-Files

$ErrorActionPreference = "Stop"

$OLD_FILES = @(
    "K1_OUTLINE_v3_4_FIXED.md",
    "K2_OUTLINE_v3_4_FIXED.md",
    "K3_OUTLINE_v3_4_FIXED.md",
    "K4_OUTLINE_v3_4_FIXED.md",
    "K5_OUTLINE_v3_4_FIXED.md",
    "K6_OUTLINE_v3_4_FIXED.md",
    "K7_OUTLINE_v3_4_FIXED.md",
    "K8_OUTLINE_v3_4_FIXED.md",
    "K9_OUTLINE_v3_4_FIXED.md"
)

$BASE_PATH = "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES"

Write-Host "======================================"
Write-Host "  Cleanup Old Outline Files"
Write-Host "======================================"
Write-Host ""

# Checkout cleanup branch
Write-Host "→ Checking out cleanup branch..."
git checkout chore/cleanup-old-outlines

Write-Host ""
Write-Host "🗑️ Deleting old files..."
Write-Host ""

foreach ($FILE in $OLD_FILES) {
    $FILEPATH = "$BASE_PATH\$FILE"
    
    if (Test-Path $FILEPATH) {
        Write-Host "   ✓ Deleting $FILE"
        Remove-Item $FILEPATH
        git add $FILEPATH
    } else {
        Write-Host "   ⚠️ Not found: $FILE"
    }
}

Write-Host ""
Write-Host "→ Committing..."
git commit -m "chore: remove old v3_4_FIXED outline files"

Write-Host ""
Write-Host "→ Pushing..."
git push -u origin chore/cleanup-old-outlines

Write-Host ""
Write-Host "======================================"
Write-Host "  ✅ CLEANUP COMPLETE!"
Write-Host "======================================"
Write-Host ""
Write-Host "Next: Create PR on GitHub:"
Write-Host "  chore/cleanup-old-outlines → main"
Write-Host ""
Write-Host "Zurück zu main:"
Write-Host "  git checkout main"
