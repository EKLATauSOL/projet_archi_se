# Résumé des Corrections pour le Test du Servomoteur

## ✅ Corrections Effectuées

### 1. Fichier `DE10_Lite_Servo_Test.vhd`
**Problèmes corrigés :**
- ❌ Signal `CLOCK_50` ne correspondait pas au `.qsf` (qui utilise `MAX10_CLK1_50`)
- ❌ Signal `LED` ne correspondait pas au `.qsf` (qui utilise `LEDR`)
- ❌ Reset fixé à '1' (servomoteur jamais réinitialisé)
- ❌ GPIO non utilisés laissés flottants

**Solutions appliquées :**
- ✅ Renommé `CLOCK_50` → `MAX10_CLK1_50`
- ✅ Renommé `LED` → `LEDR`
- ✅ Ajout d'un signal `reset_n` connecté à `KEY[0]`
- ✅ Initialisation `GPIO[35:1]` à '0'

### 2. Fichier `mini_projet.qsf`
**Problèmes corrigés :**
- ❌ Assignations manquantes pour `KEY[1]`, `SW[8]`, `SW[9]`
- ❌ Assignations manquantes pour tous les afficheurs 7 segments

**Solutions appliquées :**
- ✅ Ajout de toutes les assignations de pins manquantes
- ✅ Configuration complète des 6 afficheurs 7 segments

### 3. Fichier `peripherique/servomoteur.vhd`
**Problèmes corrigés :**
- ❌ Range du signal `duty_cycle` trop restrictif (risque de dépassement)

**Solutions appliquées :**
- ✅ Élargi le range de `duty_cycle` à `CNT_PERIOD_MAX` pour plus de robustesse

## 📋 Checklist de Test

### Avant de compiler
- [ ] Ouvrir Quartus Prime
- [ ] Charger le projet `mini_projet.qpf`
- [ ] Vérifier que le Top Level Entity = `DE10_Lite_Servo_Test`

### Compilation
- [ ] Lancer la compilation (Processing → Start Compilation)
- [ ] Vérifier qu'il n'y a pas d'erreurs
- [ ] Vérifier qu'il n'y a pas de warnings critiques

### Programmation
- [ ] Connecter la carte DE10-Lite
- [ ] Ouvrir le Programmer (Tools → Programmer)
- [ ] Charger le fichier `.sof`
- [ ] Programmer le FPGA

### Connexions Matérielles

#### ⚠️ IMPORTANT : Alimentation du Servomoteur
**NE PAS** alimenter le servomoteur depuis le FPGA !

**Configuration correcte :**
```
Alimentation 5V externe
    ├─ VCC servomoteur (fil rouge)
    └─ GND commun
        ├─ GND FPGA (JP1)
        └─ GND servomoteur (fil marron/noir)

GPIO[0] (PIN_V10) ─── Signal servomoteur (fil orange/jaune)
```

#### Connexions détaillées
- [ ] Alimentation 5V externe connectée au servomoteur (fil rouge)
- [ ] GND commun entre FPGA et alimentation externe
- [ ] Signal servomoteur connecté à GPIO[0] (PIN_V10)
- [ ] Vérifier que le servomoteur est bien fixé (ne bouge pas librement)

### Tests Fonctionnels

#### Test 1 : Reset
- [ ] Appuyer sur KEY[0]
- [ ] Le servomoteur doit se positionner à 90° (milieu)
- [ ] Relâcher KEY[0]

#### Test 2 : Position minimale (0°)
- [ ] Mettre tous les switches SW[7:0] à 0 (00000000)
- [ ] Les LEDs doivent afficher 00000000
- [ ] Le servomoteur doit aller à 0° (extrémité gauche)

#### Test 3 : Position centrale (90°)
- [ ] Mettre SW[7:0] à 01111111 (127 en décimal)
- [ ] Les LEDs doivent afficher 01111111
- [ ] Le servomoteur doit être au milieu (90°)

#### Test 4 : Position maximale (180°)
- [ ] Mettre tous les switches SW[7:0] à 1 (11111111)
- [ ] Les LEDs doivent afficher 11111111
- [ ] Le servomoteur doit aller à 180° (extrémité droite)

#### Test 5 : Vérification à l'oscilloscope (optionnel mais recommandé)
- [ ] Connecter l'oscilloscope sur GPIO[0]
- [ ] Réglages : 5ms/div, 2V/div
- [ ] Vérifier la période : 20 ms
- [ ] Vérifier les largeurs d'impulsion :
  - SW = 00000000 → ~0.6 ms
  - SW = 01111111 → ~1.5 ms
  - SW = 11111111 → ~2.4 ms

## 🔧 Diagnostic des Problèmes

### Le servomoteur ne bouge pas
**Causes possibles :**
1. Alimentation 5V manquante ou insuffisante
2. Masse non commune entre FPGA et alimentation
3. Signal non connecté à GPIO[0]
4. FPGA non programmé
5. KEY[0] maintenu appuyé (reset actif)

**Solutions :**
- Vérifier toutes les connexions avec un multimètre
- Vérifier la tension d'alimentation (doit être 5V ±0.5V)
- Vérifier que la LED de programmation du FPGA est allumée
- Relâcher KEY[0]

### Le servomoteur vibre ou fait du bruit
**Causes possibles :**
1. Alimentation instable
2. Condensateur de découplage manquant
3. Câbles trop longs ou mal blindés

**Solutions :**
- Ajouter un condensateur 100µF sur l'alimentation du servomoteur
- Utiliser des câbles courts (<30cm)
- Vérifier qu'il n'y a pas de faux contacts

### Le servomoteur ne va pas jusqu'aux extrémités
**C'est normal !** Les valeurs 0.6ms et 2.4ms sont des valeurs standard, mais certains servomoteurs utilisent :
- 1ms - 2ms (standard ancien)
- 0.5ms - 2.5ms (plage étendue)

**Pour ajuster :** Modifier dans `servomoteur.vhd` :
```vhdl
constant DUTY_MIN  : integer := 25000;  -- 0.5 ms
constant DUTY_MAX  : integer := 125000; -- 2.5 ms
```

### Les LEDs ne reflètent pas les switches
**Causes possibles :**
1. Erreur de compilation
2. Mauvaise programmation du FPGA

**Solutions :**
- Recompiler le projet
- Reprogrammer le FPGA
- Vérifier dans le fichier .qsf que les pins sont correctes

## 📊 Valeurs de Référence

### Timings PWM
| Position | Valeur SW[7:0] | Duty Cycle | Temps | Angle |
|----------|----------------|------------|-------|-------|
| Min      | 0 (0x00)       | 30000      | 0.6ms | 0°    |
| Milieu   | 127 (0x7F)     | 75000      | 1.5ms | 90°   |
| Max      | 255 (0xFF)     | 120000     | 2.4ms | 180°  |

### Formule
```
duty_cycle = 30000 + (position × 353)
période = 1000000 cycles = 20 ms
```

## 📁 Fichiers Modifiés

1. ✅ `DE10_Lite_Servo_Test.vhd` - Correction complète
2. ✅ `mini_projet.qsf` - Ajout assignations de pins
3. ✅ `peripherique/servomoteur.vhd` - Correction du range
4. ✅ `GUIDE_TEST_SERVO.md` - Guide détaillé créé

## 🎯 Prochaines Étapes

Après validation du test standalone :
1. Simuler `IP_Servo_Avalon.vhd` avec ModelSim
2. Intégrer dans Platform Designer
3. Tester avec le processeur Nios II
4. Développer l'application radar 2D complète

## ⚡ Commandes Rapides

### Compiler le projet
```
Quartus Prime → Processing → Start Compilation
ou Ctrl+L
```

### Programmer le FPGA
```
Quartus Prime → Tools → Programmer
```

### Vérifier les assignations de pins
```
Quartus Prime → Assignments → Pin Planner
```
