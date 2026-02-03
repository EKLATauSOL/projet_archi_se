# Projet Architecture des Systèmes Embarqués - Radar 2D

## Description du Projet

Ce projet implémente un **radar 2D** capable de cartographier une scène en utilisant un télémètre à ultrasons HC-SR04 monté sur un servomoteur. Le système est développé sur une carte FPGA **DE10-Lite** avec un processeur **Nios II** et des périphériques personnalisés en VHDL.

### Objectifs

L'objectif principal est de créer un système embarqué complet qui :
- Mesure la distance d'obstacles à l'aide d'un capteur ultrason HC-SR04
- Contrôle la position d'un servomoteur pour balayer un angle de 180°
- Cartographie l'environnement en effectuant des mesures régulières
- Affiche les résultats sur un terminal série

## Architecture du Système

Le projet est organisé en trois composants principaux :

### 1. IP Télémètre Ultrason (HC-SR04)

Le télémètre ultrason permet de mesurer des distances entre 2 cm et 400 cm avec une résolution de 0,3 cm.

**Caractéristiques techniques :**
- Plage de mesure : 2-400 cm
- Résolution : 0,3 cm
- Angle de mesure : 15°
- Fréquence d'horloge : 50 MHz

**Fichiers principaux :**
- `peripherique/telemetre_us.vhd` : Partie opérative du télémètre
- `peripherique/telemetre_us_avalon.vhd` : Interface Avalon pour intégration au bus système
- `peripherique/tb_telemetre_us.vhd` : Banc de test pour simulation
- `peripherique/tb_telemetre_us_avalon.vhd` : Banc de test avec interface Avalon

**Principe de fonctionnement :**
1. Génération d'une impulsion TRIGGER de 10 μs
2. Émission de 8 impulsions ultrasoniques à 40 kHz
3. Mesure de la durée du signal ECHO (proportionnelle à la distance)
4. Calcul de la distance : chaque 58 μs correspond à 1 cm (aller-retour)

### 2. IP Servomoteur

Le servomoteur permet de faire pivoter le capteur ultrason sur 180° pour balayer l'environnement.

**Caractéristiques techniques :**
- Contrôle par signal PWM (période 20 ms)
- Plage angulaire : 0-180°
- Résolution : 8 bits (256 positions)
- Temps d'impulsion : 0,6 ms (0°) à 2,4 ms (180°)

**Fichiers principaux :**
- `peripherique/servomoteur.vhd` : Générateur PWM pour le contrôle du servomoteur
- `peripherique/IP_Servo_Avalon.vhd` : Interface Avalon pour intégration au bus système
- `peripherique/tb_servomoteur.vhd` : Banc de test pour simulation
- `peripherique/tb_IP_Servo_Avalon.vhd` : Banc de test avec interface Avalon

**Principe de fonctionnement :**
- Génération d'un signal PWM avec une période fixe de 20 ms
- Le rapport cyclique détermine l'angle du servomoteur
- Calcul automatique du duty cycle en fonction de la position demandée (0-255)

### 3. Système SoC-FPGA

Le système complet intègre un processeur Nios II avec les périphériques personnalisés via le bus Avalon.

**Composants du système :**
- Processeur Nios II
- Mémoire RAM
- UART pour communication série
- IP Télémètre (Custom Peripheral)
- IP Servomoteur (Custom Peripheral)
- Afficheurs 7 segments
- LEDs et switches

## Structure du Projet

```
projet_archi_se/
├── Mini_Projet/
│   ├── peripherique/              # IPs VHDL personnalisées
│   │   ├── telemetre_us.vhd       # Télémètre - partie opérative
│   │   ├── telemetre_us_avalon.vhd # Télémètre - interface Avalon
│   │   ├── servomoteur.vhd        # Servomoteur - partie opérative
│   │   ├── IP_Servo_Avalon.vhd    # Servomoteur - interface Avalon
│   │   ├── tb_*.vhd               # Bancs de test
│   │   ├── run_sim.do             # Scripts de simulation ModelSim
│   │   └── sim_avalon.do
│   ├── nios2_system/              # Système Platform Designer
│   │   └── nios2_system.qsys      # Configuration du SoC
│   ├── software/                  # Code logiciel embarqué
│   │   ├── telemetre_soft/        # Application principale
│   │   └── telemetre_soft_bsp/    # Board Support Package
│   ├── rapport/                   # Documentation et résultats
│   ├── DE10_Lite_Servo_Test.vhd   # Top-level pour test standalone
│   ├── mini_projet.qpf            # Projet Quartus
│   ├── mini_projet.qsf            # Configuration Quartus
│   ├── projet.pdf                 # Sujet du projet
│   └── project.txt                # Spécifications détaillées
└── README.md                      # Ce fichier
```

## Méthodologie de Développement

### Étape 1 : IP Télémètre Ultrason

1. **Simulation** : Développement et validation sur ModelSim
2. **Test standalone** : Vérification sur FPGA sans processeur
3. **Intégration Avalon** : Ajout de l'interface bus Avalon
4. **Test système** : Validation avec le processeur Nios II

### Étape 2 : IP Servomoteur

1. **Conception** : Développement du générateur PWM
2. **Simulation** : Validation des timings sur ModelSim
3. **Test standalone** : Vérification à l'oscilloscope et avec le servomoteur
4. **Intégration Avalon** : Ajout de l'interface bus Avalon
5. **Test système** : Validation avec le processeur Nios II

### Étape 3 : Application Radar 2D

1. **Programmation** : Développement de l'application en C
2. **Balayage** : Rotation du servomoteur de 0° à 180°
3. **Acquisition** : Mesure de distance à chaque position
4. **Affichage** : Présentation des résultats sur terminal série

## Configuration Matérielle

### Connexions FPGA DE10-Lite

| Signal | Broche FPGA | Pin GPIO | Description |
|--------|-------------|----------|-------------|
| CLK | PIN_P11 | MAX10_CLK1_50 | Horloge 50 MHz |
| RST_N | PIN_B8 | KEY0 | Reset actif bas |
| TRIG | PIN_W10 | GPIO[1] | Trigger télémètre |
| ECHO | PIN_W9 | GPIO[3] | Echo télémètre |
| SERVO | PIN_V10 | GPIO[0] | Commande servomoteur |
| DIST_CM[9:0] | Voir manuel | LEDR[9:0] | Affichage distance |

### Alimentation

- Le capteur HC-SR04 nécessite une alimentation **5V** et **GND** depuis le connecteur GPIO (JP1)
- Le servomoteur nécessite également une alimentation externe **5V**

## Utilisation

### Compilation du Projet

1. Ouvrir le projet Quartus : `mini_projet.qpf`
2. Compiler le design complet
3. Programmer le FPGA avec le fichier `.sof` généré

### Compilation du Logiciel

1. Ouvrir Nios II Software Build Tools (SBT)
2. Importer le projet `telemetre_soft`
3. Compiler et télécharger sur le processeur Nios II
4. Ouvrir le terminal série pour visualiser les résultats

### Simulation

Pour simuler les IPs avec ModelSim :

```bash
# Simulation du télémètre
cd peripherique
vsim -do run_sim.do

# Simulation du télémètre avec interface Avalon
vsim -do run_sim_avalon.do

# Simulation du servomoteur
vsim -do sim_avalon.do
```

## Résultats Attendus

L'application finale affiche dans le terminal les mesures de distance pour chaque angle :

```
0° -> 60 cm
1° -> 61 cm
2° -> 60 cm
3° -> 61 cm
...
180° -> 45 cm
```

Ces données permettent de cartographier l'environnement en 2D et de détecter les obstacles présents dans le champ de vision du radar.

## Spécifications Techniques

### Télémètre HC-SR04

- **Vitesse du son** : 340 m/s
- **Temps pour 1 cm** : 58 μs (aller-retour)
- **Période de mesure** : 60 ms minimum entre deux mesures
- **Timeout** : 40 ms si aucun obstacle détecté

### Servomoteur

- **Période PWM** : 20 ms (50 Hz)
- **Duty cycle min** : 0,6 ms (0°) = 30 000 cycles @ 50 MHz
- **Duty cycle max** : 2,4 ms (180°) = 120 000 cycles @ 50 MHz
- **Pas de résolution** : 353 cycles par unité (pour 256 positions)

### Bus Avalon

- **Type** : Avalon Memory-Mapped (Avalon-MM)
- **Largeur de données** : 32 bits
- **Mode** : Slave pour les deux IPs
- **Signaux utilisés** : chipselect, read_n, write_n, readdata, writedata

## Technologies Utilisées

- **Langage HDL** : VHDL
- **Langage logiciel** : C
- **Outils de synthèse** : Intel Quartus Prime
- **Simulateur** : ModelSim
- **Processeur** : Nios II (soft-core)
- **FPGA** : Intel MAX10 (DE10-Lite)
- **Bus système** : Avalon
- **Outil de conception SoC** : Platform Designer (anciennement Qsys)

## Auteur

Projet réalisé dans le cadre du cours d'Architecture des Systèmes Embarqués.

## Licence

Projet académique - Usage éducatif uniquement.