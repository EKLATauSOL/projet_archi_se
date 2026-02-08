# Projet Architecture des Systèmes Embarqués - Radar 2D

## Description du Projet

Ce projet implémente un **radar 2D** capable de cartographier une scène en utilisant un télémètre à ultrasons HC-SR04 monté sur un servomoteur. Le système est développé sur une carte FPGA **DE10-Lite** avec un processeur **Nios II** et des périphériques personnalisés en VHDL.

### Objectifs

L'objectif principal est de créer un système embarqué complet qui :
- Mesure la distance d'obstacles à l'aide d'un capteur ultrason HC-SR04.
- Contrôle la position d'un servomoteur pour balayer un angle de 180°.
- Cartographie l'environnement en effectuant des mesures régulières (balayage horizontal).
- Affiche les résultats en temps réel sur un terminal série (visualisation graphique simple) et sur les afficheurs 7 segments.

## Architecture du Système

Le projet est organisé autour du bus **Avalon** reliant le processeur Nios II à ses périphériques :

### 1. IP Télémètre Ultrason (HC-SR04)

Le télémètre ultrason permet de mesurer des distances entre 2 cm et 400 cm.

**Fichiers principaux :**
- `peripherique/telemetre_us.vhd` : Gestion des signaux Trigger et Echo, calcul de la distance.
- `peripherique/telemetre_us_avalon.vhd` : Interface de lecture pour le bus Avalon.
- `peripherique/tb_telemetre_us_avalon.vhd` : Banc de test complet pour la simulation Avalon.

**Fonctionnement :**
- Génération d'un Trigger de 10µs.
- Mesure du temps d'Echo.
- Exportation de la distance brute (en cm) vers le bus Avalon (lecture seule).

### 2. IP Servomoteur (PWM Générique / Avalon PWM)

Pour plus de flexibilité, le contrôle du servomoteur a été implémenté via un générateur PWM générique.

**Fichiers principaux :**
- `peripherique/avalon_pwm.vhd` : IP PWM avec registres pour la **Période** et le **Duty Cycle**.
- `peripherique/servomoteur.vhd` : Module de base pour la génération PWM du servomoteur.
- `peripherique/IP_Servo_Avalon.vhd` : Interface alternative (0-255) utilisée pour les tests simplifiés.

**Fonctionnement via Logiciel :**
- Le logiciel définit la période (ex: 20ms @ 50MHz = 1,000,000 cycles).
- La position est contrôlée en faisant varier le temps haut entre 0.5ms (0°) et 2.5ms (180°).

### 3. Système SoC-FPGA & Logiciel

Le système est assemblé dans **Platform Designer** (Qsys).

**Application Logicielle (`software/telemetre_soft/radar_2d.c`) :**
- Gère la boucle de balayage (0° -> 180° puis 180° -> 0°).
- Calcule les timings PWM correspondants aux angles.
- Lit la distance depuis l'IP Télémètre.
- Affiche une barre graphique dans la console Nios II Terminal.
- Met à jour les afficheurs 7 segments (HEX0-3) pour afficher la distance.

## Structure du Projet

```
projet_archi_se/
├── Mini_Projet/
│   ├── peripherique/              # IPs VHDL personnalisées
│   │   ├── telemetre_us.vhd       # Télémètre (Logique)
│   │   ├── telemetre_us_avalon.vhd # Télémètre (Bus Avalon)
│   │   ├── avalon_pwm.vhd         # PWM Générique (Utilisé pour le radar)
│   │   ├── servomoteur.vhd        # Servomoteur (Logique PWM)
│   │   ├── IP_Servo_Avalon.vhd    # Servomoteur (Bus Avalon simplified)
│   │   └── run_tb_*.do            # Scripts de simulation ModelSim
│   ├── nios2_system/              # Système Platform Designer
│   ├── software/                  # Code logiciel C
│   │   └── telemetre_soft/        # Application Radar 2D
│   │       └── radar_2d.c         # Code source principal
│   ├── DE10_Lite_Test_UL.vhd      # Top-level (Wrapper FPGA)
│   ├── mini_projet.qpf            # Projet Quartus
│   └── servomoteur_simulation.do   # Scripts de simulation racine
└── README.md
```

## Configuration Matérielle (DE10-Lite)

| Signal | Broche FPGA | Connecteur JP1 | Description |
|--------|-------------|----------------|-------------|
| **SERVO** | PIN_V10 | GPIO[0] | Commande PWM Servomoteur |
| **TRIG**  | PIN_W10 | GPIO[1] | Trigger HC-SR04 |
| **ECHO**  | PIN_W9  | GPIO[3] | Echo HC-SR04 |
| **CLK**   | PIN_P11 | - | Horloge 50 MHz |
| **RESET** | PIN_B8  | KEY0 | Reset Système |

## Utilisation

### 1. Compilation et Programmation
1. Ouvrir `Mini_Projet/mini_projet.qpf` dans **Quartus Prime**.
2. Compiler le projet (`Start Compilation`).
3. Programmer le FPGA via le **Programmer** (fichier `.sof`).

### 2. Lancement du Logiciel
1. Dans Quartus, ouvrir **Tools > Nios II Software Build Tools for Eclipse**.
2. Importer le projet dans `software/telemetre_soft`.
3. Générer le BSP (clic droit sur `_bsp > Nios II > Generate BSP`).
4. Compiler (`Build Project`).
5. Lancer l'application (`Run As > Nios II Hardware`).

### 3. Simulation ModelSim
Les scripts sont disponibles pour valider les composants individuellement :

```bash
# Dans la console ModelSim :
cd Mini_Projet

# Simulation du servomoteur (Avalon interface)
do servomoteur_simulation_avalon.do

# Simulation du télémètre
cd peripherique
do run_tb_telemetre_us_avalon.do
```

## Résultats

Le terminal affiche le balayage en temps réel :
```text
 45 deg |  25 cm : |||||||||||||||||||||||||
 50 deg |  26 cm : ||||||||||||||||||||||||||
...
```

## Auteurs

Projet réalisé dans le cadre de l'UE Architecture des Systèmes Embarqués.
