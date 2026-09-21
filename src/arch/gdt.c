#include "gdt.h"

GDTEntry g_GDT[] = {
    // NULL descriptor
    GDT_ENTRY(0,0,0,0),

    // kernel 64 bit code segment
    GDT_ENTRY(0, 
            0xFFFFFFFFFFFFFFFF, // full 64 bit range
            GDT_ACCESS_PRESENT | GDT_ACCESS_RING0 | GDT_ACCESS_CODE_SEGMENT | GDT_ACCESS_CODE_READABLE,
            GDT_FLAG_64BIT | GDT_FLAG_GRANULARITY_4K),
    
    // kernel 64 bit data segment
    GDT_ENTRY(0, 
            0xFFFFFFFFFFFFFFFF, // full 64 bit range
            GDT_ACCESS_PRESENT | GDT_ACCESS_RING0 | GDT_ACCESS_DATA_SEGMENT | GDT_ACCESS_DATA_WRITEABLE,
            GDT_FLAG_64BIT | GDT_FLAG_GRANULARITY_4K),
};

GDTDescriptor g_GDTDescriptor = {
    sizeof(g_GDT) - 1, g_GDT
};

// to be implemented in gdt_impl.asm
extern void x86_64_GDT_Load(GDTDescriptor* descriptor, uint16_t codeSegment, uint16_t dataSegment);

void x86_64_GDTInitialize()
{
    x86_64_GDT_Load(&g_GDTDescriptor, x86_64_GDT_CODE_SEGMENT, x86_64_GDT_DATA_SEGMENT);
}
