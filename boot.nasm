;
; MBR test binary
;

[BITS 16]
; [ORG 0x7C00]

boot:
    mov al, '!'         ; character to print
    mov ah, 0x0e        ; \
    mov bh, 0x00        ;  } set registers to print char (used by interrupt)
    mov bl, 0x07        ; /

    int 0x10            ; call the video interrup
    jmp $               ; infinite loop

times 510-($-$$) db 0   ; fill the rest of the section with zeros

dw 0xaa55               ; Add boot signature at the end of bootloader
