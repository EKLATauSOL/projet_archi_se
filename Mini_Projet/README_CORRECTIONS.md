# 🎯 RÉSUMÉ DES CORRECTIONS - IP SERVOMOTEUR

## 📌 Problème Initial

Vous étiez à l'étape de test du servomoteur sur la carte DE10-Lite, mais **ça ne fonctionnait pas**.

## 🔍 Causes Identifiées

### 1. **Incohérence des noms de signaux**
- Le fichier VHDL utilisait `CLOCK_50` mais le `.qsf` définissait `MAX10_CLK1_50`
- Le fichier VHDL utilisait `LED` mais le `.qsf` définissait `LEDR`
- → Le compilateur ne pouvait pas faire le lien entre les signaux

### 2. **Reset non fonctionnel**
- Le reset était fixé à `'1'` (jamais actif)
- Le servomoteur ne pouvait jamais se réinitialiser
- → Comportement imprévisible au démarrage

### 3. **Assignations de pins incomplètes**
- Manquait `KEY[1]`, `SW[8]`, `SW[9]`
- Manquait tous les afficheurs 7 segments
- → Warnings de compilation et signaux non connectés

### 4. **Problème potentiel de range**
- Le signal `duty_cycle` avait un range trop restrictif
- → Risque de dépassement et erreur de synthèse

## ✅ Solutions Appliquées

### Fichier `DE10_Lite_Servo_Test.vhd`
```vhdl
-- AVANT
entity DE10_Lite_Servo_Test is
    port (
        CLOCK_50 : in  std_logic;        -- ❌ Nom incorrect
        LED      : out std_logic_vector(9 downto 0);  -- ❌ Nom incorrect
        ...
    );
end entity;

architecture rtl of DE10_Lite_Servo_Test is
begin
    i_servo : entity work.servomoteur
        port map (
            clk      => CLOCK_50,
            reset_n  => '1',  -- ❌ Reset jamais actif
            ...
        );
end architecture;

-- APRÈS
entity DE10_Lite_Servo_Test is
    port (
        MAX10_CLK1_50 : in  std_logic;   -- ✅ Nom correct
        LEDR          : out std_logic_vector(9 downto 0);  -- ✅ Nom correct
        ...
    );
end entity;

architecture rtl of DE10_Lite_Servo_Test is
    signal reset_n : std_logic;
begin
    reset_n <= KEY(0);  -- ✅ Reset fonctionnel
    
    i_servo : entity work.servomoteur
        port map (
            clk      => MAX10_CLK1_50,  -- ✅ Nom correct
            reset_n  => reset_n,         -- ✅ Reset connecté
            ...
        );
    
    GPIO(35 downto 1) <= (others => '0');  -- ✅ Évite états flottants
end architecture;
```

### Fichier `mini_projet.qsf`
```tcl
# AJOUTÉ
set_location_assignment PIN_A7 -to KEY[1]
set_location_assignment PIN_B14 -to SW[8]
set_location_assignment PIN_F15 -to SW[9]

# + Toutes les assignations des afficheurs 7 segments (HEX0-HEX5)
```

### Fichier `peripherique/servomoteur.vhd`
```vhdl
-- AVANT
signal duty_cycle : integer range 0 to DUTY_MAX := 75000;  -- ❌ Range trop restrictif

-- APRÈS
signal duty_cycle : integer range 0 to CNT_PERIOD_MAX := 75000;  -- ✅ Range élargi
```

## 📚 Documents Créés

| Fichier | Description |
|---------|-------------|
| `CORRECTIONS_SERVO.md` | ✅ Résumé complet des corrections et procédure de test |
| `GUIDE_TEST_SERVO.md` | ✅ Guide détaillé de test avec diagnostic |
| `SCHEMA_CONNEXIONS.txt` | ✅ Schéma ASCII des connexions matérielles |
| `CHECKLIST_TEST.md` | ✅ Checklist imprimable pour validation |

## 🚀 Marche à Suivre

### 1. Compilation
```
1. Ouvrir Quartus Prime
2. Charger mini_projet.qpf
3. Vérifier Top Level = DE10_Lite_Servo_Test
4. Compiler (Ctrl+L)
5. Vérifier 0 erreurs
```

### 2. Connexions Matérielles
```
⚠️ IMPORTANT : NE PAS alimenter le servomoteur depuis le FPGA !

Alimentation externe 5V
    ├─ VCC servomoteur (rouge)
    └─ GND commun
        ├─ GND FPGA
        └─ GND servomoteur (marron/noir)

GPIO[0] (PIN_V10) ─── Signal servomoteur (orange/jaune)
```

### 3. Programmation
```
1. Connecter DE10-Lite en USB
2. Tools → Programmer
3. Charger le .sof
4. Programmer
```

### 4. Test
```
1. Appuyer sur KEY[0] (reset) → servomoteur à 90°
2. SW[7:0] = 00000000 → servomoteur à 0°
3. SW[7:0] = 01111111 → servomoteur à 90°
4. SW[7:0] = 11111111 → servomoteur à 180°
5. Les LEDs suivent les switches
```

## ⚠️ Points Critiques

### ❌ À NE JAMAIS FAIRE
- Alimenter le servomoteur depuis le FPGA (5V ou 3.3V)
- Oublier de connecter les masses ensemble
- Inverser la polarité de l'alimentation

### ✅ À TOUJOURS FAIRE
- Utiliser une alimentation externe 5V
- Connecter les masses (FPGA + alimentation)
- Vérifier les connexions au multimètre
- Relâcher KEY[0] après le reset

## 🔧 Diagnostic Rapide

| Symptôme | Cause Probable | Solution |
|----------|----------------|----------|
| Servomoteur ne bouge pas | Alimentation manquante | Vérifier 5V externe |
| Servomoteur ne bouge pas | Masse non commune | Connecter GND ensemble |
| Servomoteur vibre | Alimentation instable | Ajouter condensateur 100µF |
| LEDs éteintes | FPGA non programmé | Reprogrammer |
| Ne va pas aux extrémités | Servomoteur différent | Ajuster DUTY_MIN/MAX |

## 📊 Valeurs de Référence

```
Période PWM    : 20 ms (50 Hz)
Fréquence CLK  : 50 MHz

Position 0°    : duty = 30000 cycles = 0.6 ms
Position 90°   : duty = 75000 cycles = 1.5 ms
Position 180°  : duty = 120000 cycles = 2.4 ms

Formule : duty_cycle = 30000 + (position × 353)
```

## 🎯 Prochaines Étapes

Après validation du test standalone :

1. ✅ **Simulation Avalon**
   - Simuler `IP_Servo_Avalon.vhd` avec ModelSim
   - Vérifier les transactions sur le bus Avalon

2. ✅ **Intégration Platform Designer**
   - Créer un Custom Peripheral
   - Ajouter au système Nios II
   - Générer le système

3. ✅ **Test avec Nios II**
   - Programmer en C
   - Contrôler depuis le processeur
   - Valider l'intégration complète

4. ✅ **Application Radar 2D**
   - Combiner servomoteur + télémètre
   - Balayage 0-180°
   - Cartographie de l'environnement

## 📞 Support

Si vous rencontrez des problèmes :

1. Consultez `CHECKLIST_TEST.md` pour vérifier chaque étape
2. Consultez `GUIDE_TEST_SERVO.md` pour le diagnostic
3. Consultez `SCHEMA_CONNEXIONS.txt` pour les connexions
4. Vérifiez les valeurs à l'oscilloscope

## ✨ Résumé en 3 Points

1. **Fichiers corrigés** : Noms de signaux cohérents, reset fonctionnel, pins complètes
2. **Documentation créée** : 4 guides complets pour vous aider
3. **Prêt à tester** : Suivez CHECKLIST_TEST.md étape par étape

---

**Bon courage pour vos tests ! 🚀**
