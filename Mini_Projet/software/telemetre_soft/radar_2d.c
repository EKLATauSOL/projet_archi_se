#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

// --- CONSTANTES ---
#define PWM_PERIOD      1000000
#define PULSE_0_DEG     50000
#define PULSE_180_DEG   100000
#define DELAY_STEP_US   100000

const unsigned char table_7seg[] = { 
    0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90 
};

int angle_to_cycles(int angle) {
    if (angle < 0) angle = 0;
    if (angle > 180) angle = 180;

    return 50000 + (angle * 277); 
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
    printf("--- DEMARRAGE RADAR 2D ---\n");
    printf("Balayage 0 -> 180 degres avec Telemetre\n");

    IOWR_32DIRECT(PWM0_BASE, 4, PWM_PERIOD);

    int angle = 0;
    int sens = 1;

    while(1) {
        int cycles = angle_to_cycles(angle);
        IOWR_32DIRECT(PWM0_BASE, 0, cycles);

        usleep(DELAY_STEP_US);

        int dist_cm = IORD_32DIRECT(TELEMETRE_US_AVALON_0_BASE, 0);

        printf("%d° -> %d cm\n", angle, dist_cm);

        update_display(dist_cm);

        angle += (5 * sens);
        if (angle >= 180) {
            angle = 180;
            sens = -1;
            printf("--- Retour (180 -> 0) ---\n");
        } else if (angle <= 0) {
            angle = 0;
            sens = 1;
            printf("--- Aller (0 -> 180) ---\n");
        }
    }

    return 0;
}
