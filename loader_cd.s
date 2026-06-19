.code16
_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7C00, %sp
    sti
    movb %dl, 0x7DFE

    # Print LOADING
    movb $0x0E, %ah
    movb $0x4C, %al
    int $0x10
    movb $0x4F, %al
    int $0x10
    movb $0x41, %al
    int $0x10
    movb $0x44, %al
    int $0x10
    movb $0x20, %al
    int $0x10

    # DAP: load 8 sectors (4KB) from GAME_LBA to 0x8000
    movb $0x10, dap_sz
    movb $0, dap_rsv
    movw $8, dap_cnt
    movw $0x8000, dap_off
    movw $0, dap_seg
    movl game_lba, %eax
    movl %eax, dap_lba
    movl $0, dap_lba+4

    movb $0x42, %ah
    movb 0x7DFE, %dl
    movw $dap, %si
    int $0x13
    jc disk_err

    # Jump to loaded game at 0x8000
    jmp $0x0000, $0x8000

disk_err:
    movb $0x0E, %ah
    movb $0x45, %al
    int $0x10
    movb $0x52, %al
    int $0x10
    movb $0x52, %al
    int $0x10
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
