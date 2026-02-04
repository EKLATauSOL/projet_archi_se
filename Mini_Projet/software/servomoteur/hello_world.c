#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

/*
 * L'adresse IP_SERVO_AVALON_BASE est définie dans votre system.h
 * après avoir généré le BSP.
*/

int main() {
    printf("Test du Servomoteur via Avalon\n");
    printf("------------------------------\n");

    while (1) {
        // Position 0 (0°)
        printf("Position: 0°\n");

        // Nouvelle ligne corrig�e
        IOWR_32DIRECT(PWM0_BASE, 0, 0);
        usleep(1000000); // 1 seconde

        // Position 127 (90°)
        printf("Position: 90°\n");
        IOWR_32DIRECT(PWM0_BASE, 0, 127);
        usleep(1000000);

        // Position 255 (180°)
        printf("Position: 180°\n");
        IOWR_32DIRECT(PWM0_BASE, 0, 255);
        usleep(1000000);
    }

    return 0;
}
