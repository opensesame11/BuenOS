; ==================================================================
; BILLSUTILSdotOS - Display API
; Copyright (C) 2015 Billy O'Connor & Assc.
; DISPLAY ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; void vgaSetup(int retBuffer); -- Set display to standard VGA 80x25
;								   text with no cursor and can clear
;								   screen buffer.

_vgaSetup:
	pop ax
	
	cmp ax, 0000h
	je .keepBuffer
	mov ax, 0003h
	jmp .clearBuffer
.keepBuffer:
	mov ax, 0083h
.clearBuffer:
	int 10h
	mov ax, 0100h
	mov cx, 2000h ;Invisible cursor
	int 10h
	
	ret

; ------------------------------------------------------------------
; void vgaPrintChar(int character); -- Print ASCII plaintext

_vgaPrintChar:
	pop ax
	
	cmp ah, 0 ;if LSB of character is nonzero then scroll after print
	je .noscroll
	mov ah, 0Eh
	jmp .scroll
.noscroll:
	mov ah, 0Ah
.scroll:
	int 10h
	
	ret
	
; ------------------------------------------------------------------
; void vgaPrintString(int stringAddress); -- Print null terminated string

_vgaPrintString:
	pop ax
	
	mov si, ax
	mov ax, 01h
.loop:
	lodsb
	cmp al, 0
	je .done
	call _vgaPrintChar
	jmp .loop
	
.done:
	ret

; ------------------------------------------------------------------
; void vgaSetCursor(int coordinates); -- Set cursor to a position

_vgaSetCursor:
	pop dx
	
	mov ah, 02h
	mov bh, 00h
	int 10h
	
	ret