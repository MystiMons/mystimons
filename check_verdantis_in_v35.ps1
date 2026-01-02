# VERDANTIS CHECK - Alle v3.5 Files durchsuchen
# Pascal Werner | 03.01.2026

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERDANTIS CHECK (v3.5 Files)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS\02_NARRATIVE\book_01\OUTLINES\CHAPTER_OUTLINES

$found = $false

Get-ChildItem -Filter "*v3.5_SAMMY.md" | ForEach-Object {
    $content = Get-Content $_.Name -Raw -Encoding UTF8
    if ($content -match "Verdantis") {
        Write-Host "❌ FOUND in $($_.Name)" -ForegroundColor Red
        $found = $true
    }
}

if (-not $found) {
    Write-Host "✅ NO VERDANTIS FOUND!" -ForegroundColor Green
    Write-Host "   All v3.5 files are clean (Moosveil only)" -ForegroundColor White
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
