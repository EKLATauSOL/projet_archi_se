/*
 * Radar 2D - Mini Projet ESIEA
 * Balayage Servomoteur 0-180? + Mesure T?l?m?tre
 * Correctif v3 : Force Overwrite (0.5ms - 2.5ms)
 */

#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

// --- CONSTANTES ---
#define PWM_PERIOD      1000000  // 20ms @ 50MHz
#define PULSE_MIN       25000    // 0.5ms (Min - 0 deg)
#define PULSE_MAX       125000   // 2.5ms (Max - 180 deg)
#define DELAY_STEP_US   100000   // 100ms par pas
#define PAS_ANGLE       5        // pas d'angle

const unsigned char table_7seg[] = { 
    0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90 
};

int angle_to_cycles(int angle) {
    if (angle < 0) angle = 0;
    if (angle > 180) angle = 180;
    
    return 25000 + (angle * 555); 
}

void update_display(int val) {
    if (val > 9999) val = 9999;
    int u = val % 10;
    int d = (val / 10) % 10;
    int c = (val / 100) % 10;

    unsigned int hex_val = (0xFF << 24) |            
                           (table_7seg[c] << 16) |   
                           (table_7seg[d] << 8)  |   
                           table_7seg[u];            

    IOWR_ALTERA_AVALON_PIO_DATA(HEX3_0_BASE, hex_val);
}

int main() {
    printf("--- DEMARRAGE RADAR ---\n");
    printf("Si le servo force en butee : Reduire PULSE_MAX ou Augmenter PULSE_MIN\n");

    IOWR_32DIRECT(PWM0_BASE, 4, PWM_PERIOD);

    int angle = 0;
    int sens = 1;

    while(1) {
        int cycles = angle_to_cycles(angle);
        IOWR_32DIRECT(PWM0_BASE, 0, cycles);
        
        usleep(DELAY_STEP_US);

        int dist_cm = IORD_32DIRECT(TELEMETRE_US_AVALON_0_BASE, 0);
        // printf("%d deg -> %d cm \n", angle, dist_cm);
        
        // Affichage "Graphique"
        printf("%3d deg | %3d cm : ", angle, dist_cm);
        
        // Limite d'affichage pour ne pas saturer la console (max 80 chars approx)
        int affichage_dist = (dist_cm > 80) ? 80 : dist_cm;
        
        for(int i=0; i<affichage_dist; i++) {
            printf("|");
        }
        if (dist_cm > 80) printf("..."); 
        printf("\n");
        update_display(dist_cm);

        angle += (PAS_ANGLE * sens);
        if (angle >= 180) {
            angle = 180;
            sens = -1;
            printf("--- Retour ---\n");
        } else if (angle <= 0) {
            angle = 0;
            sens = 1;
            printf("--- Aller ---\n");
     sens = 1;
            printf("--- Aller (0 -> 180) ---\n");
     sens = 1;
            printf("--- Aller (0 -> 180) ---\n");
        }
    }

    return 0;
}
