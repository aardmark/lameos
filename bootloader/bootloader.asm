org 0x7C00
use16

    mov si, hello
    call printfunc

forever:
    jmp forever

printfunc:
    lodsb       ; loads [si] into al
    or al, al   ; if al == 0
    jz .printfunc_end
    mov ah, byte 0x0e
    mov bx, word 0x03
    int 0x10
    jmp printfunc
.printfunc_end:
    ret

hello:  db 'Falcon OS successfully booted.',0

pad:    db 510 - ($ - $$) dup 0
        db 0x55, 0xaa
