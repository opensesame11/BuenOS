; ==================================================================
; BILLSUTILSdotOS
; Copyright (C) 2015 Billy O'Connor & Assc.
;
; MISCELLANEOUS ROUTINES
; ==================================================================

global _getAPIVersion
global _pause
global _fatalError

; ------------------------------------------------------------------
; _getAPIVersion -- Return current version of BILLSUTILSdotOS API
; IN: Nothing; OUT: AL = API version number

_getAPIVersion:
	mov al, API_VERSION
	ret


; ------------------------------------------------------------------
; _pause -- Delay execution for specified 110ms chunks
; IN: AX = 100 millisecond chunks to wait (max delay is 32767,
;     which multiplied by 55ms = 1802 seconds = 30 minutes)

_pause:
	pusha
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
; _fatalError -- Display error message and halt execution
; IN: AX = error message string location

_fatalError:
	push ax
	mov ax, 1
	call _vgaSetup
	pop ax
	call _vgaPrintString
	jmp $	;halt OS


; ==================================================================

