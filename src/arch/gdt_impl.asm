; fasm's way of describing an x86_64 compatible object file
format ELF64

public x86_64_GDT_Load 

section '.text' executable
x86_64_GDT_Load:
    ; make new call frame
    push rbp        ; save old call frame
    mov rbp, rsp    ; initialize new call frame
    
    mov rax, [rbp + 8]
    lgdt [rax]

    mov rax, [rbp + 12]
    push rax 
    push .reload_cs
    retf

.reload_cs:
    ;reload data segmentsa
    mov ax, [rbp + 16]
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; restore old call frame 
    mov rsp, rbp 
    pop rbp 
    ret

