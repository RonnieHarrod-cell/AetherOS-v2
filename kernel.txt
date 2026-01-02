ENTRY(_start)

SECTIONS
{
    .  = 0x80000;
    
    .text : { *(.text. boot) *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    
    __bss_start = .;
    .bss : { *(.bss) }
    __bss_end = .;
    
    __stack_end = .  + 0x10000;
}