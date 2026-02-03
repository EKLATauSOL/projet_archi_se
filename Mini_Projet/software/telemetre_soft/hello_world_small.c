#include "sys/alt_stdio.h"
#include "system.h"
#include "io.h"
#include "unistd.h"

int main()
{
  alt_putstr("Hello from Nios II!\n");
  alt_putstr("Telemeter Test:\n");

  while(1) {
      // Lecture de la distance avec la bonne macro
      int dist = IORD(TELEMETRE_US_AVALON_0_BASE, 0);

      // Affichage (en Hexa)
      // Note: Pour afficher en decimal avec alt_printf, c'est compliqué (pas de %d).
      // On affiche en Hexa pour verifier si ca bouge.
      alt_printf("Distance Hex: %x \n", dist);

      // Pause 100ms
      usleep(100000);
  }

  return 0;
}
