; ==================================================================
; BILLSUTILSdotOS - Display API
; Copyright (C) 2015 Billy O'Connor & Assc.
; DISPLAY ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; void vgaSetup(unsigned short mode); - Sets up a basic 80x25 VGA display for fallback

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
; unsigned short vgaGetChar(unsigned short x, unsigned short y); - Returns character at x,y on screen

_vgaGetChar:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	call _vgaGetPos
	push bx
	push ax

	mov ax, [bp+6]
	mov bx, [bp+4]

	push bx
	push ax
	call _vgaSetCursor
	inc sp
	inc sp
	inc sp
	inc sp

	mov ah, 08h
	int 10h
	mov [.temp], ax

	call _vgaSetCursor
	inc sp
	inc sp
	inc sp
	inc sp

	popa
	pop si
	pop di
	pop bp
	mov ax, [.temp]
	ret

	.temp dw 0

; ------------------------------------------------------------------
; unsigned short vgaGetPos(); - Returns cursor position pointer

_vgaGetPos:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov ah, 03h
	mov bh, 0
	int 10h

	mov ax, dx
	xor ax, 00FFh
	mov bx, dx
	shr bx, 4

	mov [.x], ax
	mov [.y], bx

	popa
	pop si
	pop di
	pop bp
	mov ax, .x
	ret

	.x dw 0
	.y dw 0


; ------------------------------------------------------------------
; void vgaPrint(unsigned short character); - Print single character

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
; void vgaPrintString(unsigned short stringAddr); - Prints null-terminated string

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
; void vgaSetCursor(unsigned short x, unsigned short y); - Move cursor to position

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
; void vgaSetupCursor(unsigned short topLine, unsigned short bottomLine, unsigned short blink); - Change cursor style

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
