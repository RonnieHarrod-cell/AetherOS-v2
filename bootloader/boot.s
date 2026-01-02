.section ". text. boot"
. global _start

_start: 
    // Initialize stack pointer
    ldr x0, =__stack_end
    mov sp, x0

    // Clear BSS section
    ldr x0, =__bss_start
    ldr x1, =__bss_end
    mov x2, xzr

clear_bss:
    cmp x0, x1
    b.eq bss_done
    str x2, [x0], #8
    b clear_bss

bss_done:
    // Jump to kernel main
    bl kernel_main
    
    // Halt
    b . 