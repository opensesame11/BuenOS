; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; MATH ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; void seedRandom() -- Seed the random number generator based on clock

_seedRandom:
	push bp
	mov bp, sp
	push di
	push si
	push bx
	push ax

	mov bx, 0
	mov al, 0x02			; Minute
	out 0x70, al
	in al, 0x71

	mov bl, al
	shl bx, 8
	mov al, 0			; Second
	out 0x70, al
	in al, 0x71
	mov bl, al

	mov word [.randomSeed], bx	; Seed will be something like 0x4435 (if it
					; were 44 minutes and 35 seconds after the hour)
	pop ax
	pop bx
	pop si
	pop di
	pop bp
	ret


	.randomSeed	dw 0


; ------------------------------------------------------------------
; unsigned short getRandom(unsigned short min, unsigned short max) -- Returns a pointer to a random integer between low and high (inclusive)

_getRandom:
	push bp
	mov bp, sp
	push di
	push si
	
	mov ax, [bp+6]
	mov bx, [bp+4]
	
	push dx
	push bx
	push ax

	sub bx, ax			; We want a number between 0 and (high-low)
	call .generate_random
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx

	pop ax
	pop bx
	pop dx
	add cx, ax			; Add the low offset back
	
	mov [.MSB], bx
	mov [.LSB], ax
	
	mov ax, dx
	pop si
	pop di
	pop bp
	ret


.generate_random:
	push dx
	push bx

	mov ax, [_seedRandom.randomSeed]
	mov dx, 0x7383			; The magic number (random.org)
	mul dx				; DX:AX = AX * DX
	mov [_seedRandom.randomSeed], ax

	pop bx
 	pop dx
	ret
	
	.MSB dw 0
	.LSB dw 0


; ------------------------------------------------------------------
; void bcdToInt(unsigned short number)-- Converts binary coded decimal number to an integer

_bcdToInt:
	push bp
	mov bp, sp
	push di
	push si
	
	mov ax, [bp+4]
	
	pusha

	mov bl, al			; Store entire number for now

	and ax, 0Fh			; Zero-out high bits
	mov cx, ax			; CH/CL = lower BCD number, zero extended

	shr bl, 4			; Move higher BCD number into lower bits, zero fill msb
	mov al, 10
	mul bl				; AX = 10 * BL

	add ax, cx			; Add lower BCD to 10*higher
	mov [.tmp], ax

	popa
	mov ax, [.tmp]			; And return it in AX!
	
	pop si
	pop di
	pop bp
	ret


	.tmp	dw 0

; ==================================================================

