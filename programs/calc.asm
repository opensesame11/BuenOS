BITS 16
%INCLUDE 'buenos.api'
ORG 0x8000


calculator:
	push bp
	mov bp, sp
	push di
	push si
	push .string
	call 0x0099
	inc sp
	inc sp
	pop si
	pop di
	pop bp
	ret

.string db "This is a program that proves the API is working!", 10, 13, 0
