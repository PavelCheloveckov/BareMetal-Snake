.intel_syntax noprefix
.code16
_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov byte ptr [0x7DFE], dl

    # "LOAD "
    mov ah, 0x0E
    mov al, 0x4C
    int 0x10
    mov al, 0x4F
    int 0x10
    mov al, 0x41
    int 0x10
    mov al, 0x44
    int 0x10
    mov al, 0x20
    int 0x10

    mov ah, 0x02
    mov al, 8
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, byte ptr [0x7DFE]
    mov bx, 0x8000
    int 0x13
    jc disk_err

    ljmp 0x0000, 0x8000

disk_err:
    mov ah, 0x0E
    mov al, 0x45
    int 0x10
    mov al, 0x52
    int 0x10
    mov al, 0x52
    int 0x10
1:  hlt
    jmp 1b

.fill 510-(.-_start), 1, 0
.word 0xAA55
