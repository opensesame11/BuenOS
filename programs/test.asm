BITS 16
%INCLUDE 'buenosapi.inc'
ORG 0x8000


test:
	push bp
	mov bp, sp
	push di
	push si
	push .string
	call _vgaPrintString	;0x0099
	inc sp
	inc sp
	pop si
	pop di
	pop bp
	ret

.string db "This is a program that proves the API is working!", 10, 13, 0
