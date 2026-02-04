#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

// Table de conversion 0-9 pour DE10-Lite (Active LOW)
const unsigned char table_7seg[] = {
    0xC0, // 0
    0xF9, // 1
    0xA4, // 2
    0xB0, // 3
    0x99, // 4
    0x92, // 5
    0x82, // 6
    0xF8, // 7
    0x80, // 8
    0x90  // 9
};

// Fonction utilitaire
unsigned char get_seg_code(int v) {
    if (v >= 0 && v <= 9) return table_7seg[v];
    return 0xFF; // Éteint
}

int main() {
    printf("Systeme Complet : Servo + Telemetre + Affichage\n");

    // 1. Initialisation Période Servo (20ms)
    IOWR_32DIRECT(PWM0_BASE, 4, 1000000);

    int distance = 0;
    int compteur_servo = 0;
    int etape_servo = 0;

    while (1) {
        // --- A. LECTURE TÉLÉMÈTRE ---
        // (Vérifie bien le nom exact TELEMETRE...BASE dans ton system.h)
        distance = IORD_32DIRECT(TELEMETRE_US_AVALON_0_BASE, 0);

        // --- B. AFFICHAGE 7 SEGMENTS ---
        // Découpage Centaines / Dizaines / Unités
        int u = distance % 10;
        int d = (distance / 10) % 10;
        int c = (distance / 100) % 10;

        // On construit le mot de 32 bits pour HEX3-0
        // Format : [HEX3][HEX2][HEX1][HEX0]
        unsigned int hex_val = (0xFF << 24) |            // HEX3 éteint
                               (get_seg_code(c) << 16) | // HEX2 (Centaines)
                               (get_seg_code(d) << 8)  | // HEX1 (Dizaines)
                               get_seg_code(u);          // HEX0 (Unités)

        IOWR_ALTERA_AVALON_PIO_DATA(HEX3_0_BASE, hex_val);
        IOWR_ALTERA_AVALON_PIO_DATA(HEX5_4_BASE, 0xFFFF); // Eteindre HEX5-4

        // --- C. PILOTAGE SERVO (Toutes les 1 seconde environ) ---
        // On utilise un compteur pour ne pas bloquer l'affichage
        compteur_servo++;
        if (compteur_servo >= 100) { // 100 * 10ms = 1000ms = 1s
            compteur_servo = 0;

            if (etape_servo == 0) {
                printf("Servo 0 deg | Dist: %d cm\n", distance);
                IOWR_32DIRECT(PWM0_BASE, 0, 50000);
                etape_servo = 1;
            } else if (etape_servo == 1) {
                printf("Servo 90 deg | Dist: %d cm\n", distance);
                IOWR_32DIRECT(PWM0_BASE, 0, 75000);
                etape_servo = 2;
            } else {
                printf("Servo 180 deg | Dist: %d cm\n", distance);
                IOWR_32DIRECT(PWM0_BASE, 0, 100000);
                etape_servo = 0;
            }
        }

        // Pause courte (10ms) pour rafraîchir l'affichage rapidement
        usleep(10000);
    }

    return 0;
}
