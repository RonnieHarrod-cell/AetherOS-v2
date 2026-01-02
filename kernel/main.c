/* AetherOS Kernel - Main Entry Point
 * x86_64 Architecture
 * This is the main kernel entry point called by the bootloader
 */

#include "kernel.h"
#include "console.h"
#include "memory.h"

/* Kernel version information */
const char *kernel_version = "AetherOS v2.0.0";
const char *build_date = __DATE__;
const char *build_time = __TIME__;

/* Forward declarations */
void init_console(void);
void init_memory(void);
void init_interrupts(void);
void init_scheduler(void);
void init_vfs(void);
void init_device_manager(void);
void init_network_stack(void);

/**
 * kernel_main - Main kernel initialization function
 * Called by the bootloader after basic setup
 */
void kernel_main(void)
{
    /* Initialize early console for debugging */
    init_console();
    
    console_write("\n");
    console_write("=== AetherOS Kernel Booting ===\n");
    console_write(kernel_version);
    console_write(" ");
    console_write(build_date);
    console_write(" ");
    console_write(build_time);
    console_write("\n\n");
    
    /* Initialize memory management */
    console_write("[INIT] Initializing memory management...\n");
    init_memory();
    console_write("[OK] Memory management initialized\n");
    
    /* Initialize interrupt handling */
    console_write("[INIT] Initializing interrupt handling...\n");
    init_interrupts();
    console_write("[OK] Interrupt handling initialized\n");
    
    /* Initialize task scheduler */
    console_write("[INIT] Initializing task scheduler...\n");
    init_scheduler();
    console_write("[OK] Task scheduler initialized\n");
    
    /* Initialize virtual file system */
    console_write("[INIT] Initializing virtual file system...\n");
    init_vfs();
    console_write("[OK] Virtual file system initialized\n");
    
    /* Initialize device manager */
    console_write("[INIT] Initializing device manager...\n");
    init_device_manager();
    console_write("[OK] Device manager initialized\n");
    
    /* Initialize network stack */
    console_write("[INIT] Initializing network stack...\n");
    init_network_stack();
    console_write("[OK] Network stack initialized\n");
    
    console_write("\n=== Kernel Boot Complete ===\n\n");
    console_write("System ready. Waiting for user input...\n");
    
    /* Main kernel loop */
    while (1) {
        /* Halt and wait for interrupt */
        __asm__("hlt");
    }
}

/**
 * kernel_panic - Halt the kernel with an error message
 * @message: Error message to display
 */
void kernel_panic(const char *message)
{
    console_write("\n\n!!! KERNEL PANIC !!!\n");
    console_write("Message: ");
    console_write(message);
    console_write("\n\n");
    console_write("System halted.\n");
    
    /* Disable interrupts and halt */
    __asm__("cli");
    while (1) {
        __asm__("hlt");
    }
}