; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; PORT INPUT AND OUTPUT ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; void portWrite(short addr, short byte); -- Send byte to a port
_portWrite:
	push bp
	mov bp, sp
	pusha
	
	mov dx, [bp + 4]
	mov ax, [bp + 6]
	xor ah, ah
	out dx, al
	
	popa
	mov si, bp
	pop bp
	ret 4


; ------------------------------------------------------------------
; unsigned short portRead(short addr) -- Receive byte from a port

_portRead:
	push bp
	mov bp, sp
	pusha
	
	mov dx, [bp + 4]
	in al, dx
	mov word [.tmp], ax
	
	popa
	mov ax, [.tmp]
	mov si, bp
	pop bp
	ret 2
	
	.tmp dw 0


; ------------------------------------------------------------------
; void serialSetup(short mode) -- Set up the serial port for transmitting data
; mode 0 = 9600bps, mode 1 = 1200bps

_serialSetup:
	push bp
	mov bp, sp
	pusha

	mov dx, 0			; Configure serial port 1
	mov ax, [bp + 4]
	cmp ax, 1
	je .slow_mode

	mov ah, 0
	mov al, 11100011b		; 9600 baud, no parity, 8 data bits, 1 stop bit
	jmp .finish

.slow_mode:
	mov ah, 0
	mov al, 10000011b		; 1200 baud, no parity, 8 data bits, 1 stop bit	

.finish:
	int 14h

	popa
	mov si, bp
	pop bp
	ret 2


; ------------------------------------------------------------------
; unsigned short serialWrite(short byte) -- Send a byte via the serial port
; Returns 1 if failure occurred

_serialWrite:
	push bp
	mov bp, sp
	pusha

	mov ah, 01h
	mov dx, 0			; COM1

	int 14h
	
	xor ax, 0100000000000000b
	cmp ax, 0100000000000000b
	je .noSuccess
	mov ax, 0
	jmp .success
.noSuccess:
	mov ax, 1
.success:
	mov [.tmp], ax
	popa
	mov ax, [.tmp]
	ret 2
	
	.tmp dw 0
	
	
; ------------------------------------------------------------------
; unsigned short serialRead() -- Get a byte from the serial port
; returns FF00 on error.

_serialRead:
	push bp
	mov bp, sp
	pusha
	
	mov ah, 02h
	mov dx, 0			; COM1
	
	int 14h
	
	xor ah, 01000000b
	cmp ah, 01000000b
	je .noSuccess
	xor ah, ah
	jmp .success
.noSuccess:
	mov ah, 11111111b
	mov al, 00h
.success:
	mov [.tmp], ax

	popa
	mov ax, [.tmp]
	mov sp, bp
	pop bp
	ret


	.tmp dw 0


; ==================================================================

