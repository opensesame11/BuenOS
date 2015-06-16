; ==================================================================
; BILLSUTILSdotOS
; Copyright (C) 2015 Billy O'Connor & Assc.
;
; MISCELLANEOUS ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; unsigned short getAPIVersion() -- Return current version of BuenOS API

_getAPIVersion:
	push bp
	mov bp, sp
	push di
	push si
	mov al, API_VERSION

	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void* getOSVersion() -- Return OS Version String

_getOSVersion:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, os_version_msg

	pop si
	pop di
	pop bp
	ret

; ------------------------------------------------------------------
; void shutdown() -- Shutdown the system (Very uncleanly I guess)

_shutdown:
	push bp
	mov bp, sp
	push di
	push si

	mov ah, 53h
	mov al, 00h
	xor bx, bx
	int 15h
	jnc .cont
.error:
	push .error_msg
	call _fatalError
	inc sp
	inc sp
	pop si
	pop di
	pop bp
	ret
.cont:
	mov ah, 53h
	mov al, 01h
	xor bx, bx
	int 15h
	jc .error

	mov ah, 53h
	mov al, 08h
	mov bx, 0001h
	mov cx, 0001h
	int 15h
	jc .error

	mov ah, 53h
	mov al, 07h
	mov bx, 0001h
	mov cx, 03h
	int 15h

	pop si
	pop di
	pop bp
	ret

	.error_msg db "shutdown() call has failed... I don't even know how :P", 0

; ------------------------------------------------------------------
; unsigned int restart() -- Restarts the system

_restart:
	push bp
	mov bp, sp
	push di
	push si

	int 19h

	mov ax, 1			; If return value is ANYTHING than the call failed...
	pop si
	pop di
	pop bp
	ret

; ------------------------------------------------------------------
; void pause(short time) -- Delay execution for specified 110ms chunks
; time = 110 millisecond chunks to wait (max delay is 32767, which multiplied by 55ms = 1802 seconds = 30 minutes)

_pause:
	push bp
	mov bp, sp
	push di
	push si
	pusha
	mov ax, [bp+4]
	cmp ax, 0
	je .time_up			; If delay = 0 then bail out

	mov cx, 0
	mov [.counter_var], cx		; Zero the counter variable

	mov bx, ax
	mov ax, 0
	mov al, 2			; 2 * 55ms = 110mS
	mul bx				; Multiply by number of 110ms chunks required
	mov [.orig_req_delay], ax	; Save it

	mov ah, 0
	int 1Ah				; Get tick count

	mov [.prev_tick_count], dx	; Save it for later comparison

.checkloop:
	mov ah,0
	int 1Ah				; Get tick count again

	cmp [.prev_tick_count], dx	; Compare with previous tick count

	jne .up_date			; If it's changed check it
	jmp .checkloop			; Otherwise wait some more

.time_up:
	popa
	pop si
	pop di
	pop bp
	ret

.up_date:
	mov ax, [.counter_var]		; Inc counter_var
	inc ax
	mov [.counter_var], ax

	cmp ax, [.orig_req_delay]	; Is counter_var = required delay?
	jge .time_up			; Yes, so bail out

	mov [.prev_tick_count], dx	; No, so update .prev_tick_count

	jmp .checkloop			; And go wait some more


	.orig_req_delay		dw	0
	.counter_var		dw	0
	.prev_tick_count	dw	0

; ------------------------------------------------------------------
; unsigned int runMemory( unsigned int address, parsedString_t args ) -- Executes from address and passes parsed input in the stack

_runMemory:
	push bp
	mov bp, sp
	push di
	push si

	mov ax, [bp+4]
	push ax
	mov ax, [bp+6]
	call ax
	inc sp
	inc sp

	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void fatalError(short msgAddr) -- Display error message and halt execution

_fatalError:
	push bp
	mov bp, sp
	push di
	push si

	push 83h
	call _vgaSetup
	inc sp
	inc sp

	mov ax, [bp+4]
	push ax
	call _vgaPrintString
	inc sp
	inc sp

	mov ax, .append
	push ax
	call _vgaPrintString
	inc sp
	inc sp

	call _waitKey

	call _restart
	jmp $

	.append		db 10, 13, "Press any key to restart...", 10, 13, 0

