; ==================================================================
; BILLSUTILSdotOS - Display API
; Copyright (C) 2015 Billy O'Connor & Assc.
; DISPLAY ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; void vgaSetup(short mode); - Sets up a basic 80x25 VGA display for fallback

_vgaSetup:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, [bp+4]
	mov ah, 00h
	int 10h

	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void vgaChangeAttributes(short attribute); - Change attributes of characters being output

_vgaChangeAttributes:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, [bp+4]

	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void vgaPrint(short character); - Print single character

_vgaPrint:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, [bp+4]
	mov ah, 0Eh
	int 10h

        pop si
        pop di
        pop bp
	ret

; ------------------------------------------------------------------
; void vgaPrintString(short stringAddr); - Prints null-terminated string

_vgaPrintString:
	push bp
	mov bp, sp
	push di
	push si

	mov si, [bp+4]

.loop:
	lodsb
	cmp al, 0
	je .done
	push ax
	call _vgaPrint
	inc sp
	inc sp
	jmp .loop
.done:
	pop si
	pop di
	pop bp
	ret

; ------------------------------------------------------------------
; void vgaSetCursor(short x, short y); - Move cursor to position

_vgaSetCursor:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, [bp+6]
	mov bx, [bp+4]
	mov dh, al
	mov dl, bl
	mov ah, 02h
	mov bh, 00h
	int 10h

	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void vgaSetupCursor(short topLine, short bottomLine, short blink); - Change cursor style

_vgaSetupCursor:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov bx, [bp+8];top
	mov cx, [bp+6];bottom
	mov dx, [bp+4];blink

	

	mov ah, 01h
	int 10h

	popa
	pop si
	pop di
	pop bp
	ret
