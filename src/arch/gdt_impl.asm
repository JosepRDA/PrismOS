; fasm's way of describing an x86_64 compatible object file
format ELF64

public x86_64_GDT_Load 

section '.text' executable
x86_64_GDT_Load:
    lgdt [rdi]

    push rsi 
    lea rax, [.reload_cs]
    push rax
    retfq

.reload_cs:
    mov ax, dx
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ret

