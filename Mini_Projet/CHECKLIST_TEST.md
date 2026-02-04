# ✅ CHECKLIST RAPIDE - TEST SERVOMOTEUR

## 🔧 AVANT DE COMMENCER

- [ ] J'ai lu `CORRECTIONS_SERVO.md`
- [ ] J'ai lu `GUIDE_TEST_SERVO.md`
- [ ] J'ai consulté `SCHEMA_CONNEXIONS.txt`
- [ ] J'ai une alimentation externe 5V disponible
- [ ] J'ai un servomoteur fonctionnel
- [ ] J'ai des câbles de connexion

## 💻 COMPILATION

- [ ] Quartus Prime est installé et fonctionne
- [ ] Projet `mini_projet.qpf` ouvert
- [ ] Top Level Entity = `DE10_Lite_Servo_Test`
- [ ] Compilation lancée (Ctrl+L)
- [ ] ✅ Compilation réussie (0 erreurs)
- [ ] Fichier `.sof` généré dans `output_files/`

## 🔌 CONNEXIONS MATÉRIELLES

### Alimentation
- [ ] Alimentation externe 5V branchée
- [ ] Tension vérifiée au multimètre (4.5V - 5.5V)
- [ ] Servomoteur fil ROUGE → VCC alimentation externe
- [ ] Servomoteur fil MARRON/NOIR → GND alimentation externe

### Masse commune
- [ ] GND FPGA (JP1 pin 12) → GND alimentation externe
- [ ] Continuité vérifiée au multimètre

### Signal
- [ ] Servomoteur fil ORANGE/JAUNE → GPIO[0] (PIN_V10)
- [ ] Connexion bien serrée (pas de faux contact)

### ⚠️ VÉRIFICATIONS DE SÉCURITÉ
- [ ] Le servomoteur N'EST PAS alimenté par le FPGA
- [ ] Le 5V du FPGA N'EST PAS utilisé
- [ ] Le 3.3V du FPGA N'EST PAS utilisé
- [ ] Toutes les polarités sont correctes

## 📡 PROGRAMMATION FPGA

- [ ] Carte DE10-Lite connectée en USB
- [ ] Pilote USB-Blaster installé
- [ ] Quartus Programmer ouvert (Tools → Programmer)
- [ ] Fichier `.sof` chargé
- [ ] Hardware détecté (USB-Blaster)
- [ ] Programmation lancée
- [ ] ✅ Programmation réussie (100%)

## 🧪 TESTS FONCTIONNELS

### Test 1 : Vérification de base
- [ ] Alimentation 5V allumée
- [ ] Aucun bruit anormal du servomoteur
- [ ] LEDs du FPGA allumées
- [ ] Servomoteur en position (pas de vibration excessive)

### Test 2 : Reset
- [ ] Appuyer sur KEY[0]
- [ ] Servomoteur va à 90° (position centrale)
- [ ] Relâcher KEY[0]
- [ ] Servomoteur reste en position

### Test 3 : Position 0°
- [ ] Tous les switches SW[7:0] à 0 (vers le bas)
- [ ] Toutes les LEDs LEDR[7:0] éteintes
- [ ] Servomoteur à 0° (extrémité gauche)

### Test 4 : Position 90°
- [ ] SW[7] = 0, SW[6:0] = 1 (01111111)
- [ ] LEDs correspondantes allumées
- [ ] Servomoteur à ~90° (milieu)

### Test 5 : Position 180°
- [ ] Tous les switches SW[7:0] à 1 (vers le haut)
- [ ] Toutes les LEDs LEDR[7:0] allumées
- [ ] Servomoteur à 180° (extrémité droite)

### Test 6 : Balayage
- [ ] Bouger progressivement les switches de 0 à 255
- [ ] Le servomoteur suit le mouvement
- [ ] Pas de saccades excessives
- [ ] Pas de vibrations anormales

## 🔬 TESTS AVANCÉS (Optionnel)

### Oscilloscope
- [ ] Oscilloscope connecté sur GPIO[0]
- [ ] GND oscilloscope → GND commun
- [ ] Réglages : 5ms/div, 2V/div
- [ ] Signal PWM visible
- [ ] Période mesurée : 20 ms ± 0.1 ms
- [ ] Amplitude : ~3.3V
- [ ] SW = 0 → largeur ~0.6 ms
- [ ] SW = 127 → largeur ~1.5 ms
- [ ] SW = 255 → largeur ~2.4 ms

### Multimètre
- [ ] Tension alimentation : 5V ± 0.5V
- [ ] Continuité GND FPGA ↔ GND alimentation
- [ ] Pas de court-circuit VCC ↔ GND

## ❌ PROBLÈMES COURANTS

### Le servomoteur ne bouge pas
- [ ] Vérifier alimentation 5V (tension et courant)
- [ ] Vérifier masse commune
- [ ] Vérifier connexion signal GPIO[0]
- [ ] Vérifier que KEY[0] est relâché
- [ ] Reprogrammer le FPGA

### Le servomoteur vibre
- [ ] Ajouter condensateur 100µF sur alimentation
- [ ] Raccourcir les câbles
- [ ] Vérifier qualité alimentation
- [ ] Vérifier que le servomoteur n'est pas bloqué

### Les LEDs ne s'allument pas
- [ ] Vérifier que le FPGA est programmé
- [ ] Vérifier les switches
- [ ] Recompiler le projet
- [ ] Vérifier le fichier .qsf

### Le servomoteur ne va pas aux extrémités
- [ ] C'est peut-être normal (servomoteur différent)
- [ ] Ajuster DUTY_MIN et DUTY_MAX dans servomoteur.vhd
- [ ] Recompiler et tester

## ✅ VALIDATION FINALE

- [ ] Tous les tests fonctionnels passent
- [ ] Le servomoteur répond correctement aux switches
- [ ] Pas de comportement erratique
- [ ] Pas de bruit anormal
- [ ] Les LEDs reflètent bien les switches

## 📝 NOTES

Date du test : _______________
Heure : _______________

Problèmes rencontrés :
_______________________________________________________
_______________________________________________________
_______________________________________________________

Solutions appliquées :
_______________________________________________________
_______________________________________________________
_______________________________________________________

Observations :
_______________________________________________________
_______________________________________________________
_______________________________________________________

## 🎯 PROCHAINE ÉTAPE

Une fois tous les tests validés :
- [ ] Passer à l'intégration Avalon (`IP_Servo_Avalon.vhd`)
- [ ] Simuler avec ModelSim
- [ ] Intégrer dans Platform Designer
- [ ] Tester avec Nios II

---
**Signature de validation :** _______________
