ENTRY(Reset_Handler)

MEMORY 
{
    .text :
    {
        . = ALIGN(8);
        *(.isr_vector) /* vector table */ 
        *(.text) /* code */
        *(.text*) /* any other code */
        *(.rodata) /* read only data */
        . = ALIGN(8);
        _etext = .;
    }
}
