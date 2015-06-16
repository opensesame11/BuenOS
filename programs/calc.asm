BITS 16
%INCLUDE 'buenos.api'
ORG 0x8000


calculator:
	push string
	call 0x0ae0:0x0096
	inc sp
	inc sp
	ret

string db "This is a program that proves the API is working!", 10, 13, 0
