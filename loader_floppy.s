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

    # "LOAD "
    movb $0x0E, %ah
    movb $0x4C, %al; int $0x10
    movb $0x4F, %al; int $0x10
    movb $0x41, %al; int $0x10
    movb $0x44, %al; int $0x10
    movb $0x20, %al; int $0x10

    movb $0x02, %ah
    movb $8, %al
    movb $0, %ch
    movb $2, %cl
    movb $0, %dh
    movb 0x7DFE, %dl
    movw $0x8000, %bx
    int $0x13
    jc disk_err

    jmp $0x0000, $0x8000

disk_err:
    movb $0x0E, %ah
    movb $0x45, %al; int $0x10
    movb $0x52, %al; int $0x10
    movb $0x52, %al; int $0x10
1:  hlt; jmp 1b

.fill 510-(.-_start), 1, 0
.word 0xAA55
