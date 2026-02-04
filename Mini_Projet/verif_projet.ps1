# Script de vérification rapide pour le projet servomoteur
# À exécuter dans le répertoire Mini_Projet

Write-Host "=== Vérification du projet Servomoteur ===" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier que les fichiers existent
Write-Host "[1/4] Vérification des fichiers..." -ForegroundColor Yellow
$files = @(
    "peripherique\servomoteur.vhd",
    "DE10_Lite_Servo_Test.vhd",
    "mini_projet.qsf",
    "mini_projet.qpf"
)

$allFilesExist = $true
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file MANQUANT!" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "ERREUR: Des fichiers sont manquants!" -ForegroundColor Red
    exit 1
}

# 2. Vérifier les assignations de pins dans le .qsf
Write-Host ""
Write-Host "[2/4] Vérification des assignations de pins..." -ForegroundColor Yellow
$qsfContent = Get-Content "mini_projet.qsf" -Raw

$requiredPins = @{
    "MAX10_CLK1_50" = "PIN_P11"
    "KEY[0]" = "PIN_B8"
    "GPIO[0]" = "PIN_V10"
}

$pinsOK = $true
foreach ($signal in $requiredPins.Keys) {
    $pin = $requiredPins[$signal]
    if ($qsfContent -match "set_location_assignment $pin -to $($signal -replace '\[', '\[' -replace '\]', '\]')") {
        Write-Host "  ✓ $signal -> $pin" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $signal -> $pin MANQUANT!" -ForegroundColor Red
        $pinsOK = $false
    }
}

if (-not $pinsOK) {
    Write-Host ""
    Write-Host "ATTENTION: Des assignations de pins sont manquantes!" -ForegroundColor Red
}

# 3. Vérifier le Top Level Entity
Write-Host ""
Write-Host "[3/4] Vérification du Top Level Entity..." -ForegroundColor Yellow
if ($qsfContent -match 'set_global_assignment -name TOP_LEVEL_ENTITY DE10_Lite_Servo_Test') {
    Write-Host "  ✓ Top Level = DE10_Lite_Servo_Test" -ForegroundColor Green
} else {
    Write-Host "  ✗ Top Level incorrect!" -ForegroundColor Red
}

# 4. Vérifier la syntaxe VHDL basique
Write-Host ""
Write-Host "[4/4] Vérification syntaxe VHDL..." -ForegroundColor Yellow

$servoContent = Get-Content "peripherique\servomoteur.vhd" -Raw
$testContent = Get-Content "DE10_Lite_Servo_Test.vhd" -Raw

$checks = @(
    @{File="servomoteur.vhd"; Pattern="entity servomoteur is"; Desc="Entité servomoteur"},
    @{File="servomoteur.vhd"; Pattern="architecture bhv of servomoteur is"; Desc="Architecture servomoteur"},
    @{File="DE10_Lite_Servo_Test.vhd"; Pattern="entity DE10_Lite_Servo_Test is"; Desc="Entité test"},
    @{File="DE10_Lite_Servo_Test.vhd"; Pattern="MAX10_CLK1_50"; Desc="Signal horloge"},
    @{File="DE10_Lite_Servo_Test.vhd"; Pattern="reset_n"; Desc="Signal reset"}
)

$syntaxOK = $true
foreach ($check in $checks) {
    $content = if ($check.File -eq "servomoteur.vhd") { $servoContent } else { $testContent }
    if ($content -match [regex]::Escape($check.Pattern)) {
        Write-Host "  ✓ $($check.Desc)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($check.Desc) MANQUANT!" -ForegroundColor Red
        $syntaxOK = $false
    }
}

# Résumé
Write-Host ""
Write-Host "=== Résumé ===" -ForegroundColor Cyan
if ($allFilesExist -and $pinsOK -and $syntaxOK) {
    Write-Host "✓ Tous les tests sont passés!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "  1. Ouvrir Quartus Prime" -ForegroundColor White
    Write-Host "  2. Ouvrir mini_projet.qpf" -ForegroundColor White
    Write-Host "  3. Compiler le projet (Ctrl+L)" -ForegroundColor White
    Write-Host "  4. Programmer le FPGA" -ForegroundColor White
    Write-Host "  5. Connecter le servomoteur selon GUIDE_TEST_SERVO.md" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "✗ Des problèmes ont été détectés!" -ForegroundColor Red
    Write-Host "Veuillez corriger les erreurs ci-dessus." -ForegroundColor Red
    exit 1
}
