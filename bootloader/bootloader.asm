org 0x7c00
BITS 16

VGA.Width equ 80
VGA.Height equ 25

    xor ax, ax
    mov ds, ax                      ; set data segment
    mov ss, ax                      ; set stack segment
    mov sp, 0x9c00                  ; set stack pointer

    mov ax, 0xb800                  ; text video memory
    mov es, ax

    call clear_screen

    cld
    mov si, os_loaded_msg
    call sprint

    ; set up keyboard handler
    cli                             ; disable interrupts
    mov bx, 0x09                    ; hardware interrupt # (irq1???)
    shl bx, 2                       ; multiply by 4
    xor ax, ax
    mov gs, ax                      ; start of memory
    mov [gs:bx], word keyhandler    ; IVT points to our handler
    mov [gs:bx+2], ds               ; segment
    sti                             ; enable interrupts

    jmp $                           ; loop forever

;------------------------------------------------------------------
keyhandler:
    in al, 0x60                     ; get key data
    mov bl, al                      ; save it
    mov byte [port60], al

    in al, 0x61                     ; keyboard control
    mov ah, al
    or al, 0x80                     ; disable bit 7
    out 0x61, al                    ; send it back
    xchg ah, al                     ; get original
    out 0x61, al                    ; send that back

    mov al, 0x20                    ; end of interrupt
    out 0x20, al

    and bl, 0x80                    ; key released
    jnz .done                       ; don't repeat

    mov ax, [port60]
    cmp ax, 0x1c
    je .newline
    mov word [reg16], ax
    call printreg16
    jmp .done
.newline:
    mov si, carriage_return
    call sprint
.done:
    iret

;------------------------------------------------------------------
dochar:
    call cprint                     ; print one character

sprint:
    lodsb                           ; string char to AL
    cmp al, 0
    jne dochar                      ; else, we're done
    call move_cursor
    ret

cprint:
    cmp al, 0x0A
    je .newline

    mov ah, 0x0F                    ; attrib = white on black
    mov cx, ax                      ; save char/attribute
    movzx ax, byte [ypos]
    mov dx, 160                     ; 2 bytes (char/attrib)
    mul dx                          ; for 80 columns
    movzx bx, byte [xpos]
    shl bx, 1                       ; times 2 to skip attrib

    mov di, 0                       ; start of video memory
    add di, ax                      ; add y offset
    add di, bx                      ; add x offset

    mov ax, cx                      ; restore char/attribute
    stosw                           ; write char/attribute

    movzx ax, byte [xpos]
    cmp ax, VGA.Width - 1
    je .newline

    add byte [xpos], 1              ; advance to right
    jmp .done

.newline:
    mov byte [xpos], 0              ; cr
    mov al, byte [ypos]
    cmp al, (VGA.Height - 1)        ; already on the bottom line?
    je .at_bottom
    add byte [ypos], 1
    jmp .done

.at_bottom:
    call scroll_up
.done:
    ret

;------------------------------------------------------------------
move_cursor:
    movzx ax, byte [ypos]
    movzx bx, byte [xpos]
	mov dl, VGA.Width
	mul dl
	add bx, ax

	mov dx, 0x03D4
	mov al, 0x0F
	out dx, al

	inc dl
	mov al, bl
	out dx, al

	dec dl
	mov al, 0x0E
	out dx, al

	inc dl
	mov al, bh
	out dx, al

	ret

;------------------------------------------------------------------
clear_screen:
    push ax
    push cx
    push di
    push es

    mov ax, 0xb800                  ; text video memory
    mov es, ax

    mov cx, VGA.Width * VGA.Height
    xor di, di
    mov ax, 0x0F20
    rep stosw

    pop es
    pop di
    pop cx
    pop ax

    ret

;------------------------------------------------------------------
scroll_up:
    push ax
    push cx
    push si
    push di
    push ds
    push es

    mov ax, 0xb800                  ; text video memory
    mov es, ax
    mov ds, ax

    xor di, di
    mov si, 160

    mov cx, 1920
    rep movsw
    mov cx, 80
    mov ax, 0x0F20
    rep stosw

    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop ax

    ret

;------------------------------------------------------------------
printreg16:
   mov di, outstr16
   mov ax, [reg16]
   mov si, hexstr
   mov cx, 4   ;four places
hexloop:
   rol ax, 4   ;leftmost will
   mov bx, ax   ; become
   and bx, 0x0f   ; rightmost
   mov bl, [si + bx];index into hexstr
   mov [di], bl
   inc di
   dec cx
   jnz hexloop
 
   mov si, outstr16
   call sprint
 
   ret

;------------------------------------------------------------------
xpos                    db 0
ypos                    db 0
port60                  dw 0
os_loaded_msg           db 'LameOS loaded.', 0x0A, 0
carriage_return         db 0x0A, 0
hexstr                  db '0123456789ABCDEF'
outstr16                db '0000', 0    ; register value string
reg16                   dw 0            ; pass values to printreg16

TIMES 510 - ($ - $$) db 0	            ; Fill the rest of sector with 0
DW 0xAA55			                    ; Add boot signature at the end of bootloader
