BITS 16
ORG 0A000h

%INCLUDE 'billsapi.inc'

calculator:

mov si, string
call os_vga_printstring

ret

string db "This is a program that proves the API is working!", 0