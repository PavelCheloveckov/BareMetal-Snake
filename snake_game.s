.intel_syntax noprefix
.code16
GAME_START:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFE
    sti
    mov al, 0x03
    int 0x10
    mov ah, 0x01
    mov cx, 0x2000
    int 0x10
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0720
    rep stosw
    mov byte ptr [head_x], 40
    mov byte ptr [head_y], 12
    mov byte ptr [direction], 1
    mov ax, 80
    mul ah
    mov al, byte ptr [head_x]
    mov ah, 0
    add ax, 12*80+40
    mov word ptr [snake_body], ax
    add ax, 1
    mov word ptr [snake_body+2], ax
    add ax, 1
    mov word ptr [snake_body+4], ax
    mov word ptr [head_idx], 2
    mov word ptr [tail_idx], 0
    mov byte ptr [snake_len], 3
    call random_apple
game_loop:
    mov al, byte ptr [head_y]
    mov bl, 80
    mul bl
    mov bl, byte ptr [head_x]
    mov bh, 0
    add bx, ax
    mov word ptr [head_pos], bx
    shl bx, 1
    mov di, bx
    mov al, 0xDB
    mov ah, 0x0A
    mov word ptr es:[di], ax
    mov di, word ptr [apple_pos]
    shl di, 1
    mov al, 0x03
    mov ah, 0x0C
    mov word ptr es:[di], ax
    mov cx, 3
    call wait_ticks
key_loop:
    mov ah, 0x01
    int 0x16
    jz no_key
    mov ah, 0x00
    int 0x16
    cmp ah, 0x48
    je key_up
    cmp ah, 0x50
    je key_down
    cmp ah, 0x4B
    je key_left
    cmp ah, 0x4D
    je key_right
    jmp key_loop
no_key:
    mov al, byte ptr [direction]
    cmp al, 0
    je move_up
    cmp al, 1
    je move_right
    cmp al, 2
    je move_down
    jmp move_left
move_up:
    dec byte ptr [head_y]
    cmp byte ptr [head_y], 0xFF
    jne check_apple
    mov byte ptr [head_y], 24
    jmp check_apple
move_right:
    inc byte ptr [head_x]
    cmp byte ptr [head_x], 80
    jne check_apple
    mov byte ptr [head_x], 0
    jmp check_apple
move_down:
    inc byte ptr [head_y]
    cmp byte ptr [head_y], 25
    jne check_apple
    mov byte ptr [head_y], 0
    jmp check_apple
move_left:
    dec byte ptr [head_x]
    cmp byte ptr [head_x], 0xFF
    jne check_apple
    mov byte ptr [head_x], 79
check_apple:
    mov ax, word ptr [head_pos]
    cmp ax, word ptr [apple_pos]
    je eat_apple
    jmp move_done
eat_apple:
    inc byte ptr [snake_len]
    mov di, word ptr [apple_pos]
    shl di, 1
    mov al, 0xDB
    mov ah, 0x0A
    mov word ptr es:[di], ax
    call random_apple
    jmp move_done_no_erase
move_done:
    inc word ptr [head_idx]
    and word ptr [head_idx], 0x00FF
    mov bx, word ptr [head_idx]
    add bx, bx
    mov ax, word ptr [head_pos]
    mov word ptr [snake_body+bx], ax
    mov bx, word ptr [tail_idx]
    add bx, bx
    mov di, word ptr [snake_body+bx]
    shl di, 1
    mov ax, 0x0720
    mov word ptr es:[di], ax
    inc word ptr [tail_idx]
    and word ptr [tail_idx], 0x00FF
    jmp game_loop
move_done_no_erase:
    inc word ptr [head_idx]
    and word ptr [head_idx], 0x00FF
    mov bx, word ptr [head_idx]
    add bx, bx
    mov ax, word ptr [head_pos]
    mov word ptr [snake_body+bx], ax
    jmp game_loop

wait_vsync:
    push dx
    push ax
    mov dx, 0x3DA
.retrace:
    in al, dx
    test al, 8
    jz .retrace
.display:
    in al, dx
    test al, 8
    jnz .display
    pop ax
    pop dx
    ret

# Подпрограмма ожидания CX тиков
wait_ticks:
    push ax
    push bx
    push dx
    push es
    xor ax, ax
    mov es, ax
    mov bx, 0x46C
    mov ax, word ptr es:[bx]
    mov dx, ax
.tick_loop:
    mov ax, word ptr es:[bx]
    sub ax, dx
    cmp ax, cx
    jb .tick_loop
    pop es
    pop dx
    pop bx
    pop ax
    ret
key_up:
    cmp byte ptr [direction], 2
    je no_key
    mov byte ptr [direction], 0
    jmp key_loop
key_right:
    cmp byte ptr [direction], 3
    je no_key
    mov byte ptr [direction], 1
    jmp key_loop
key_down:
    cmp byte ptr [direction], 0
    je no_key
    mov byte ptr [direction], 2
    jmp key_loop
key_left:
    cmp byte ptr [direction], 1
    je no_key
    mov byte ptr [direction], 3
    jmp key_loop

random_apple:
    push ax
    push bx
    push cx
    push dx
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    mov bx, 2000
    xor dx, dx
    div bx
    mov word ptr [apple_pos], dx
    pop dx
    pop cx
    pop bx
    pop ax
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
