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

    # Print LOADING
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

    # DAP: load 8 sectors (4KB) from GAME_LBA to 0x8000
    mov byte ptr [dap_sz], 0x10
    mov byte ptr [dap_rsv], 0
    mov word ptr [dap_cnt], 8
    mov word ptr [dap_off], 0x8000
    mov word ptr [dap_seg], 0
    mov eax, dword ptr [game_lba]
    mov dword ptr [dap_lba], eax
    mov dword ptr [dap_lba+4], 0

    mov ah, 0x42
    mov dl, byte ptr [0x7DFE]
    mov si, offset dap
    int 0x13
    jc disk_err

    # Jump to loaded game at 0x8000
    ljmp 0x0000, 0x8000

disk_err:
    mov ah, 0x0E
    mov al, 0x45
    int 0x10
    mov al, 0x52
    int 0x10
    mov al, 0x52
    int 0x10
.h:
    hlt
    jmp .h

.align 4
dap:
dap_sz:  .byte 0x10
dap_rsv: .byte 0
dap_cnt: .word 0
dap_off: .word 0
dap_seg: .word 0
dap_lba: .quad 0

game_lba: .long 0

.fill 510-(.-_start), 1, 0
.word 0xAA55
