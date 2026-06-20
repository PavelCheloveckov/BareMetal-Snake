.code16
GAME_START:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw $0x9000, %ax
    movw %ax, %ss
    movw $0xFFFE, %sp
    sti
    movb $0x00, %ah
    movb $0x13, %al
    int $0x10
    movw $0xA000, %ax    
    movw %ax, %es
    xorw %di, %di
    movw $32000, %cx
    movw $0x0000, %ax   
    rep stosw 
    movb $40, head_x
    movb $12, head_y
    movb $1, direction
    movw $80, %ax
    mulb %ah
    movb head_x, %al
    movb $0, %ah
    addw $12*80+40, %ax
    movw %ax, snake_body + 0
    addw $1, %ax
    movw %ax, snake_body + 2
    addw $1, %ax
    movw %ax, snake_body + 4
    movw $2, head_idx
    movw $0, tail_idx
    movb $3, snake_len
    call random_apple
draw_pixel:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    pushw %di
    
    pushw %ax
    movb %bh, %al
    movb $0, %ah
    movw $320, %cx
    mulw %cx
    movb %bl, %bh
    movb $0, %bh
    addw %bx, %ax
    movw %ax, %di
    
    movw $0xA000, %dx
    movw %dx, %es
    popw %ax
    movb %al, %es:(%di)
    
    popw %di
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret
draw_rect:
    pushw %cx
    pushw %si
    pushw %bx
    pushw %dx
.rect_loop_y:
    pushw %bx
    pushw %dx
.rect_loop_x:
    call draw_pixel
    incb %bl
    decw %dx
    jnz .rect_loop_x
    popw %dx
    popw %bx
    incb %bh
    decw %si
    jnz .rect_loop_y
    
    popw %dx
    popw %bx
    popw %si
    popw %cx
    ret

game_loop:
    movb head_y, %al
    movb $80, %bl
    mulb %bl
    movb head_x, %bl
    movb $0, %bh
    addw %bx, %ax
    movw %ax, head_pos
    movb $0x02, %al
    movb head_x, %bl
    movb $4, %ah
    mulb %ah
    movb %al, %bl
    movb head_y, %bh
    movb $8, %al
    mulb %al
    movb %al, %bh
    movw $4, %dx
    movw $8, %si
    call draw_rect
    movb $0x04, %al
    movw apple_pos, %ax
    movb %al, %bl
    movb $80, %ah
    divb %ah
    movb $4, %ah
    mulb %ah
    movb %al, %bl
    movb %ah, %bh
    movb $8, %al
    mulb %al
    movb %al, %bh
    movw $4, %dx
    movw $8, %si
    call draw_rect
    movw $3, %cx
    call wait_ticks
key_loop:
    movb $0x01, %ah
    int $0x16
    jz no_key
    movb $0x00, %ah
    int $0x16
    cmpb $0x48, %ah
    je key_up
    cmpb $0x50, %ah
    je key_down
    cmpb $0x4B, %ah
    je key_left
    cmpb $0x4D, %ah
    je key_right
    jmp key_loop
no_key:
    movb direction, %al
    cmpb $0, %al
    je move_up
    cmpb $1, %al
    je move_right
    cmpb $2, %al
    je move_down
    jmp move_left
move_up:
    decb head_y
    cmpb $0xFF, head_y
    jne check_apple
    movb $24, head_y
    jmp check_apple
move_right:
    incb head_x
    cmpb $80, head_x
    jne check_apple
    movb $0, head_x
    jmp check_apple
move_down:
    incb head_y
    cmpb $25, head_y
    jne check_apple
    movb $0, head_y
    jmp check_apple
move_left:
    decb head_x
    cmpb $0xFF, head_x
    jne check_apple
    movb $79, head_x
check_apple:
    movw head_pos, %ax
    cmpw apple_pos, %ax
    je eat_apple
    jmp move_done
eat_apple:
    incb snake_len
    call random_apple
    jmp move_done_no_erase
move_done:
    incw head_idx
    andw $0x00FF, head_idx
    movw head_idx, %bx
    addw %bx, %bx
    movw head_pos, %ax
    movw %ax, snake_body(%bx)
    movw tail_idx, %bx
    addw %bx, %bx
    movw snake_body(%bx), %di
    movb $0x00, %al
    movw %di, %ax
    movb %al, %bl
    movb $80, %ah
    divb %ah
    movb %al, %bl
    movb %ah, %bh
    movb $4, %ah
    movb %bl, %al
    mulb %ah
    movb %al, %bl
    movb %bh, %al
    movb $8, %ah
    mulb %ah
    movb %al, %bh
    movb $0x00, %al
    movw $4, %dx
    movw $8, %si
    call draw_rect 
    incw tail_idx
    andw $0x00FF, tail_idx
    jmp game_loop
move_done_no_erase:
    incw head_idx
    andw $0x00FF, head_idx
    movw head_idx, %bx
    addw %bx, %bx
    movw head_pos, %ax
    movw %ax, snake_body(%bx)
    jmp game_loop
pos_to_coords:
    pushw %ax
    movb %al, %bl
    movb $80, %ah
    divb %ah
    movb %al, %bl
    movb %ah, %bh
    popw %ax
    ret

wait_vsync:
    pushw %dx
    pushw %ax
    movw $0x3DA, %dx
.retrace:
    inb %dx, %al
    testb $8, %al
    jz .retrace
.display:
    inb %dx, %al
    testb $8, %al
    jnz .display
    popw %ax
    popw %dx
    ret

# Подпрограмма ожидания CX тиков
wait_ticks:
    pushw %ax
    pushw %bx
    pushw %dx
    pushw %es
    xorw %ax, %ax
    movw %ax, %es
    movw $0x46C, %bx
    movw %es:(%bx), %ax
    movw %ax, %dx
.tick_loop:
    movw %es:(%bx), %ax
    subw %dx, %ax
    cmpw %cx, %ax
    jb .tick_loop
    popw %es
    popw %dx
    popw %bx
    popw %ax
    ret
key_up:
    cmpb $2, direction
    je no_key
    movb $0, direction
    jmp key_loop
key_right:
    cmpb $3, direction
    je no_key
    movb $1, direction
    jmp key_loop
key_down:
    cmpb $0, direction
    je no_key
    movb $2, direction
    jmp key_loop
key_left:
    cmpb $1, direction
    je no_key
    movb $3, direction
    jmp key_loop

random_apple:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    movb $0x00, %ah
    int $0x1A
    movw %dx, %ax
    movw $2000, %bx
    xorw %dx, %dx
    divw %bx
    movw %dx, apple_pos
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

head_x:     .byte 42
head_y:     .byte 12
direction:  .byte 1
head_pos:   .word 0
snake_len:  .byte 3
head_idx:   .word 2
tail_idx:   .word 0
apple_pos:  .word 0
snake_body: .fill 256, 2, 0
