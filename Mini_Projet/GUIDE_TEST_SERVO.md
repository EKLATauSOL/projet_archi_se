# Guide de Test du Servomoteur sur DE10-Lite

## Problèmes Corrigés

### 1. ✅ Noms des signaux corrigés
- `CLOCK_50` → `MAX10_CLK1_50` (correspond au .qsf)
- `LED` → `LEDR` (correspond au .qsf)
- Ajout du signal `reset_n` connecté à `KEY[0]`

### 2. ✅ Assignations de pins complétées
- Ajout de `KEY[1]`, `SW[8]`, `SW[9]`
- Ajout de toutes les pins des afficheurs 7 segments (HEX0-HEX5)
- Initialisation des GPIO non utilisés à '0'

### 3. ✅ Reset fonctionnel
- Le reset est maintenant contrôlé par `KEY[0]` (actif bas)
- Appuyez sur KEY[0] pour réinitialiser le servomoteur à 90°

## Procédure de Test

### Étape 1 : Compilation
1. Ouvrir Quartus Prime
2. Ouvrir le projet `mini_projet.qpf`
3. Compiler le projet (Processing → Start Compilation)
4. Vérifier qu'il n'y a pas d'erreurs

### Étape 2 : Programmation du FPGA
1. Connecter la carte DE10-Lite via USB
2. Tools → Programmer
3. Charger le fichier `.sof` généré
4. Programmer le FPGA

### Étape 3 : Connexions Matérielles

#### Servomoteur (3 fils)
- **Rouge (VCC)** → Alimentation externe 5V (PAS le FPGA!)
- **Marron/Noir (GND)** → GND commun (FPGA + alimentation externe)
- **Orange/Jaune (Signal)** → GPIO[0] (PIN_V10)

⚠️ **IMPORTANT** : Le servomoteur consomme trop de courant pour être alimenté directement par le FPGA. Utilisez une alimentation externe 5V et connectez les masses ensemble.

#### Schéma de connexion
```
Alimentation 5V externe
    |
    +--- VCC (Rouge) du servomoteur
    |
    +--- GND commun
         |
         +--- GND FPGA (JP1 pin GND)
         +--- GND servomoteur (Marron/Noir)

GPIO[0] (PIN_V10) --- Signal servomoteur (Orange/Jaune)
```

### Étape 4 : Test Fonctionnel

#### Test 1 : Reset
1. Appuyer sur **KEY[0]** (reset)
2. Le servomoteur devrait se positionner à **90°** (position centrale)
3. Les LEDs devraient afficher la valeur des switches

#### Test 2 : Contrôle par switches
Tester différentes positions avec les switches SW[7:0] :

| Switches SW[7:0] | Valeur décimale | Angle attendu | Temps d'impulsion |
|------------------|-----------------|---------------|-------------------|
| 00000000         | 0               | 0°            | 0.6 ms            |
| 01111111         | 127             | ~90°          | 1.5 ms            |
| 11111111         | 255             | 180°          | 2.4 ms            |
| 00111111         | 63              | ~45°          | 1.05 ms           |
| 10111111         | 191             | ~135°         | 1.95 ms           |

#### Test 3 : Vérification à l'oscilloscope
1. Connecter l'oscilloscope sur GPIO[0] (PIN_V10)
2. Régler : 5ms/div, 2V/div
3. Vérifier :
   - **Période du signal** : 20 ms (50 Hz)
   - **Largeur d'impulsion** :
     - SW = 00000000 → ~0.6 ms
     - SW = 01111111 → ~1.5 ms
     - SW = 11111111 → ~2.4 ms

### Étape 5 : Diagnostic si ça ne fonctionne pas

#### Le servomoteur ne bouge pas du tout
- ✓ Vérifier l'alimentation 5V externe
- ✓ Vérifier que les masses sont communes
- ✓ Vérifier la connexion du signal sur GPIO[0]
- ✓ Appuyer sur KEY[0] pour sortir du reset
- ✓ Vérifier que le FPGA est bien programmé

#### Le servomoteur vibre ou fait du bruit
- ✓ Vérifier la qualité de l'alimentation 5V
- ✓ Ajouter un condensateur 100µF sur l'alimentation du servomoteur
- ✓ Vérifier les connexions (pas de faux contacts)

#### Le servomoteur ne va pas jusqu'à 0° ou 180°
- C'est normal ! Les valeurs 0.6ms et 2.4ms sont des valeurs standard
- Certains servomoteurs utilisent 1ms-2ms ou 0.5ms-2.5ms
- Vous pouvez ajuster les constantes dans `servomoteur.vhd` :
  ```vhdl
  constant DUTY_MIN  : integer := 25000;  -- 0.5 ms pour 0°
  constant DUTY_MAX  : integer := 125000; -- 2.5 ms pour 180°
  ```

#### Les LEDs ne s'allument pas
- ✓ Vérifier que les switches sont bien activés
- ✓ Le mapping LED/SW est direct : SW[0]→LEDR[0], etc.

## Valeurs de Référence

### Calculs PWM
- **Fréquence horloge** : 50 MHz
- **Période horloge** : 20 ns
- **Période PWM** : 20 ms = 1 000 000 cycles

### Duty Cycle
- **0.6 ms** = 30 000 cycles (0°)
- **1.5 ms** = 75 000 cycles (90°)
- **2.4 ms** = 120 000 cycles (180°)
- **Pas** = (120000 - 30000) / 255 = 353 cycles/unité

### Formule
```
duty_cycle = 30000 + (position × 353)
```
où position ∈ [0, 255]

## Prochaines Étapes

Une fois le test standalone validé :
1. ✅ Intégrer l'interface Avalon (`IP_Servo_Avalon.vhd`)
2. ✅ Simuler avec ModelSim
3. ✅ Ajouter au système Platform Designer
4. ✅ Tester avec le processeur Nios II

## Fichiers Modifiés

- ✅ `DE10_Lite_Servo_Test.vhd` - Correction des noms de signaux et ajout du reset
- ✅ `mini_projet.qsf` - Ajout des assignations de pins manquantes

## Notes Importantes

⚠️ **Alimentation** : Ne JAMAIS alimenter le servomoteur directement depuis le FPGA (risque de dommages)

⚠️ **Masse commune** : Toujours connecter les masses ensemble (FPGA + alimentation externe)

⚠️ **Reset** : KEY[0] est actif bas, le servomoteur fonctionne quand KEY[0] n'est PAS appuyé

✅ **Feedback visuel** : Les LEDs affichent la valeur des switches pour vérifier que tout fonctionne
