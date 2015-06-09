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
; void vgaPrint(short character); - Print single character as teletype

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

	mov ax, [bp+8]
	mov bx, [bp+6]
	mov dx, [bp+4]

	xor cx, cx ;set cx to 0
	xor dx, 0000000000000011h ;eliminate all but two bits
	shl dx, 13 ;move blink to bits 5 and 6 of high byte
	or cx, dx

	xor bx, 0000000000001111b
	or cx, dx

	xor ax, 0000000000001111b
	shl ax, 8
	or cx, ax

	mov ah, 01h
	int 10h

	popa
	pop si
	pop di
	pop bp
	ret
