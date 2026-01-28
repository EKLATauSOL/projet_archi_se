#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

// Define Base Address if not in system.h yet (User needs to replace this)
#ifndef ACCEL_CTRL_0_BASE
#define ACCEL_CTRL_0_BASE 0x40000 // Placeholder, user MUST update after Qsys generation
#endif

#define REG_X      0
#define REG_Y      1
#define REG_Z      2
#define REG_STATUS 3

#define REG_DEVID  4 // Need to add this to VHDL if not present?
// Wait, my VHDL only exposes 0, 1, 2, 3 (Status).
// I cannot read DEVID with current VHDL unless I map it.
// I mapped:
// 00 -> X
// 01 -> Y
// 10 -> Z
// 11 -> Status
// I did NOT map DEVID.

// I should update VHDL to map DEVID to a register, say address 4 (requires changing address bits to 3) OR just hijack an address or change the read logic.
// But changing VHDL means recompiling Quartus (slow).

// Alternative: The STATUS register returns `data_ready`.
// If `data_ready` is 0, it returns 0. If 1, it returns 1.
// If I read -1 (0xFFFFFFFF) from STATUS, then it's definitely a bus read error (Avalon) or the logic driving readdata is wrong.
// Wait, `readdata` is 32 bits.
// `when "11" => avs_readdata <= (0 => ready, others => '0');`
// If I read offset 3, I should get 0 or 1.
// If I get -1, it implies `avs_readdata` is being driven to all 1s or `IORD` is reading garbage.

// Let's first check what REG_STATUS returns in C.

#include <fcntl.h>

int main() {
    printf("Test Accelerometre ADXL345\n");
    printf("Press 'q' to quit\n");
    
    // Set stdin to non-blocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
    
    volatile int * accel_ptr = (int *) ACCEL_CTRL_0_BASE;
    short x, y, z;
    int status;
    char c;
    
    while(1) {
        // Check input
        c = getchar();
        if (c == 'q') {
            printf("Exiting...\n");
            break;
        }
        
        status = IORD(ACCEL_CTRL_0_BASE, REG_STATUS);
        x = (short)IORD(ACCEL_CTRL_0_BASE, REG_X);
        y = (short)IORD(ACCEL_CTRL_0_BASE, REG_Y);
        z = (short)IORD(ACCEL_CTRL_0_BASE, REG_Z);
        
        printf("Status: 0x%X | X: %d, Y: %d, Z: %d\n", status, x, y, z);
        
        usleep(500000); // 500ms
    }
    
    return 0;
}
