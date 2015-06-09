; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; KEYBOARD HANDLING ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; unsigned short waitKey() -- Waits for keypress and returns key

_waitKey:
	pusha

	mov ax, 0
	mov ah, 10h
	int 16h

	mov [.tmp_buf], ax
	popa
	mov ax, [.tmp_buf]
	ret


	.tmp_buf	dw 0


; ------------------------------------------------------------------
; unsigned short getKey() -- Scans keyboard for input, but doesn't wait
; Returns null if no keypress in buffer

_getKey:
	pusha

	mov ax, 0
	mov ah, 1			; BIOS call to check for key
	int 16h

	jz .nokey			; If no key, skip to end

	mov ax, 0			; Otherwise get it from buffer
	int 16h

	mov [.tmp_buf], ax		; Store resulting keypress

	popa				; But restore all other regs
	mov ax, [.tmp_buf]
	ret

.nokey:
	popa
	mov ax, 0			; Zero result if no key pressed
	ret


	.tmp_buf	dw 0


; ==================================================================

