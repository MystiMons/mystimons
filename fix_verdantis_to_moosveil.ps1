# FIX-SCRIPT: Verdantis → Moosveil (NUR LOKALE FILES)
# Pascal Werner | 03.01.2026

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VERDANTIS → MOOSVEIL FIX (Lokale Files)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

cd E:\_MYSTIMONS_AAA\MYSTIMONS

# FILE 1: CREATURES_MASTER.md
Write-Host "1. Fixing CREATURES_MASTER.md..." -ForegroundColor Yellow
$file1 = "01_REGISTRY/creatures/CREATURES_MASTER.md"
if (Test-Path $file1) {
    $content1 = Get-Content $file1 -Raw -Encoding UTF8
    $content1 = $content1 -replace '## VERDANTIS \(Theos Partner\)','## MOOSVEIL (Theos Partner)'
    $content1 = $content1 -replace 'name: Verdantis','name: Moosveil'
    $content1 = $content1 -replace 'reunion: Kapitel 19','reunion: Kapitel 17'
    Set-Content -Path $file1 -Value $content1 -Encoding UTF8 -NoNewline
    Write-Host "   ✅ Done (3 replacements)" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipped (nicht lokal)" -ForegroundColor Yellow
}

# FILE 2: K2_DER_SCHREI_v3.5_SAMMY.md
Write-Host "2. Fixing K2_DER_SCHREI_v3.5_SAMMY.md..." -ForegroundColor Yellow
$file2 = "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K2_DER_SCHREI_v3.5_SAMMY.md"
if (Test-Path $file2) {
    $content2 = Get-Content $file2 -Raw -Encoding UTF8
    $content2 = $content2 -replace 'BILD 6: Verdantis neben ihm','BILD 6: Moosveil neben ihm'
    $content2 = $content2 -replace 'Verdantis bei ihm \(bestätigt\)','Moosveil bei ihm (bestätigt)'
    Set-Content -Path $file2 -Value $content2 -Encoding UTF8 -NoNewline
    Write-Host "   ✅ Done (2 replacements)" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipped (nicht lokal)" -ForegroundColor Yellow
}

# FILE 3: K9_DIE_BEFREIUNG_v3.5_SAMMY.md (nur auf GitHub!)
Write-Host "3. K9_DIE_BEFREIUNG_v3.5_SAMMY.md..." -ForegroundColor Yellow
$file3 = "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K9_DIE_BEFREIUNG_v3.5_SAMMY.md"
if (Test-Path $file3) {
    $content3 = Get-Content $file3 -Raw -Encoding UTF8
    $content3 = $content3 -replace 'Finn fokussiert \(Verdantis\.\.\.\)','Finn fokussiert (Moosveil...)'
    $content3 = $content3 -replace 'Verdantis-Spike bei Extremstress','Moosveil-Spike bei Extremstress'
    Set-Content -Path $file3 -Value $content3 -Encoding UTF8 -NoNewline
    Write-Host "   ✅ Done (2 replacements)" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipped (nur auf GitHub, nicht lokal)" -ForegroundColor Yellow
}

# FILE 4: K17_THEO_v3.5_SAMMY.md
Write-Host "4. Fixing K17_THEO_v3.5_SAMMY.md..." -ForegroundColor Yellow
$file4 = "02_NARRATIVE/book_01/OUTLINES/CHAPTER_OUTLINES/K17_THEO_v3.5_SAMMY.md"
if (Test-Path $file4) {
    $content4 = Get-Content $file4 -Raw -Encoding UTF8
    $content4 = $content4 -replace 'Nur Verdantis "verrät" ihn','Nur Moosveil "verrät" ihn'
    $content4 = $content4 -replace 'Verdantis\. Nicht "ein Natur-Resonant"','Moosveil. Nicht "ein Natur-Resonant"'
    $content4 = $content4 -replace "Verdantis' Echo","Moosveils Echo"
    $content4 = $content4 -replace 'Verdantis ist Präsenz/Person','Moosveil ist Präsenz/Person'
    $content4 = $content4 -replace '"Verdantis… wollte nicht\."','"Moosveil… wollte nicht."'
    $content4 = $content4 -replace 'gibt Verdantis Agency','gibt Moosveil Agency'
    $content4 = $content4 -replace 'Verdantis bei ihm \(bestätigt\)','Moosveil bei ihm (bestätigt)'
    Set-Content -Path $file4 -Value $content4 -Encoding UTF8 -NoNewline
    Write-Host "   ✅ Done (7 replacements)" -ForegroundColor Green
} else {
    Write-Host "   ⏭️ Skipped (nicht lokal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ✅ LOKALE FILES FIXED!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: K9 ist nur auf GitHub, wird beim Merge automatisch gefixt" -ForegroundColor Yellow
Write-Host ""
