; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT
;
; STRING MANIPULATION ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; unsigned short stringLength(unsigned short stringAddr) -- Return length of a string

_stringLength:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov bx, [bp+4]			; Move location of string to BX

	mov cx, 0			; Counter

.more:
	cmp byte [bx], 0		; Zero (end of string) yet?
	je .done
	inc bx				; If not, keep adding
	inc cx
	jmp .more


.done:
	mov word [.tmp_counter], cx	; Store count before restoring other registers
	popa

	pop si
	pop di
	pop bp
	mov ax, [.tmp_counter]		; Put count back into AX before returning
	ret


	.tmp_counter	dw 0


; ------------------------------------------------------------------
; unsigned short reverseString(unsigned short stringAddr) -- Reverse the characters in a string

_reverseString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+4]
	cmp byte [si], 0		; Don't attempt to reverse empty string
	je .end

	push si
	call _stringLength
	inc sp
	inc sp

	mov di, si
	add di, ax
	dec di				; DI now points to last char in string

.loop:
	mov byte al, [si]		; Swap bytes
	mov byte bl, [di]

	mov byte [si], bl
	mov byte [di], al

	inc si				; Move towards string centre
	dec di

	cmp di, si			; Both reached the centre?
	ja .loop

.end:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; unsigned short findCharInString(unsigned short stringAddr, unsignedShort char) -- Find location of character in a string

_findCharInString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+6]
	mov ax, [bp+4]

	mov cx, 1			; Counter -- start at first char (we count
					; from 1 in chars here, so that we can
					; return 0 if the source char isn't found)

.more:
	cmp byte [si], al
	je .done
	cmp byte [si], 0
	je .notfound
	inc si
	inc cx
	jmp .more

.done:
	mov [.tmp], cx
	popa
	mov ax, [.tmp]
	pop si
	pop di
	pop bp
	ret

.notfound:
	popa
	mov ax, 0
	pop si
	pop di
	pop bp
	ret


	.tmp	dw 0


; ------------------------------------------------------------------
; void stringFindAndReplace(unsigned short stringAddr, unsigned short charToFind, unsignedShort charToUse) -- Change instances of character in a string
; IN: SI = string, AL = char to find, BL = char to replace with

_stringFindAndReplace:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+8]
	mov ax, [bp+6]
	mov bx, [bp+4]

	mov cl, al

.loop:
	mov byte al, [si]
	cmp al, 0
	je .finish
	cmp al, cl
	jne .nochange

	mov byte [si], bl

.nochange:
	inc si
	jmp .loop

.finish:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringUppercase(unsigned short stringAddr) -- Convert zero-terminated string to upper case

_stringUppercase:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+4]			; Use SI to access string

.more:
	cmp byte [si], 0		; Zero-termination of string?
	je .done			; If so, quit

	cmp byte [si], 'a'		; In the lower case A to Z range?
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 20h		; If so, convert input char to upper case

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringLowercase(unsigned short stringAddr) -- Convert zero-terminated string to lower case

_stringLowercase:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+4]			; Use SI to access string

.more:
	cmp byte [si], 0		; Zero-termination of string?
	je .done			; If so, quit

	cmp byte [si], 'A'		; In the upper case A to Z range?
	jb .noatoz
	cmp byte [si], 'Z'
	ja .noatoz

	add byte [si], 20h		; If so, convert input char to lower case

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringCopy(unsigned short sourceAddr, unsigned short destAddr) -- Copy one string into another

_stringCopy:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+6]
	mov di, [bp+4]

.more:
	mov al, [si]			; Transfer contents (at least one byte terminator)
	mov [di], al
	inc si
	inc di
	cmp byte al, 0			; If source string is empty, quit out
	jne .more

.done:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringTrunctuate(unsigned short stringAddr, unsigned short length) -- Chop string down to specified number of characters

_stringTrunctuate:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+6]
	mov ax, [bp+4]

	add si, ax
	mov byte [si], 0

	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringJoin(unsigned short stringAddrOne, unsigned short stringAddrTwo, unsigned short StringAddrThree) -- Join two strings into a third string

_stringJoin:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov ax, [bp+8]
	mov bx, [bp+6]
	mov cx, [bp+4]

	push cx
	push ax
	call _stringCopy
	inc sp
	inc sp

	push ax
	call _stringLength		; Get length of first string
	inc sp
	inc sp

	add cx, ax			; Position at end of first string

	push cx
	push bx
	call _stringCopy
	inc sp
	inc sp

	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void stringChomp(unsigned short stringAddr) -- Strip leading and trailing spaces from a string

_stringChomp:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov ax, [bp+4]

	mov dx, ax			; Save string location

	mov di, ax			; Put location into DI
	mov cx, 0			; Space counter

.keepcounting:				; Get number of leading spaces into BX
	cmp byte [di], ' '
	jne .counted
	inc cx
	inc di
	jmp .keepcounting

.counted:
	cmp cx, 0			; No leading spaces?
	je .finished_copy

	mov si, di			; Address of first non-space character
	mov di, dx			; DI = original string start

.keep_copying:
	mov al, [si]			; Copy SI into DI
	mov [di], al			; Including terminator
	cmp al, 0
	je .finished_copy
	inc si
	inc di
	jmp .keep_copying

.finished_copy:
	push dx
	call _stringLength
	inc sp
	inc sp
	
	cmp ax, 0			; If empty or all blank, done, return 'null'
	je .done

	mov si, dx
	add si, ax			; Move to end of string

.more:
	dec si
	cmp byte [si], ' '
	jne .done
	mov byte [si], 0		; Fill end spaces with 0s
	jmp .more			; (First 0 will be the string terminator)

.done:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; void _stringStrip(unsigned short stringAddr, unsigned short charToRemove) -- Removes specified character from a string (max 255 chars)

_stringStrip:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+6]
	mov ax, [bp+4]

	mov di, si

	mov bl, al			; Copy the char into BL since LODSB and STOSB use AL
.nextchar:
	lodsb
	stosb
	cmp al, 0			; Check if we reached the end of the string
	je .finish			; If so, bail out
	cmp al, bl			; Check to see if the character we read is the interesting char
	jne .nextchar			; If not, skip to the next character

.skip:					; If so, the fall through to here
	dec di				; Decrement DI so we overwrite on the next pass
	jmp .nextchar

.finish:
	popa
	pop si
	pop di
	pop bp
	ret

; ------------------------------------------------------------------
; unsigned short stringEqual(unsigned short stringAddrOne, unsigned short stringAddrTwo) -- See if two strings match

_stringEqual:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+6]
	mov di, [bp+4]

.more:
	mov al, [si]			; Retrieve string contents
	mov bl, [di]

	cmp al, bl			; Compare characters at current location
	jne .not_same

	cmp al, 0			; End of first string? Must also be end of second
	je .terminated

	inc si
	inc di
	jmp .more


.not_same:				; If unequal lengths with same beginning, the byte
	popa				; comparison fails at shortest string terminator
	pop si
	pop di
	pop bp
	mov ax, 0
	ret


.terminated:				; Both strings terminated at the same position
	popa
	pop si
	pop di
	pop bp
	mov ax, 1
	ret


; ------------------------------------------------------------------
; unsigned short stringParse(unsigned short stringAddr) -- Take string (eg "run foo bar baz") and parses different elements into seperate strings. Max 4 elements
; ax = stringAddrOne; ax+1 = stringAddrTwo; etc.

_stringParse:
	push bp
	mov bp, sp
	push di
	push si

	mov si, [bp+4]

	mov ax, si			; AX = start of first string

	mov bx, 0			; By default, other strings start empty
	mov cx, 0
	mov dx, 0

	push ax				; Save to retrieve at end

.loop1:
	lodsb				; Get a byte
	cmp al, 0			; End of string?
	je .finish
	cmp al, ' '			; A space?
	jne .loop1
	dec si
	mov byte [si], 0		; If so, zero-terminate this bit of the string

	inc si				; Store start of next string in BX
	mov bx, si

.loop2:					; Repeat the above for CX and DX...
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loop3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	pop ax
	mov [.elementLocations], ax
	mov [.elementLocations+1], bx
	mov [.elementLocations+2], cx
	mov [.elementLocations+3], dx

	mov ax, .elementLocations
	pop si
	pop di
	pop bp
	ret

.elementLocations:	dw 0
			dw 0
			dw 0
			dw 0

; ------------------------------------------------------------------
; unsigned short stringToShort(unsigned short stringToConvert) -- Convert decimal string to integer value

_stringToShort:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov si, [bp+4]

	push si
	call _stringLength
	inc sp
	inc sp

	add si, ax			; Work from rightmost char in string
	dec si

	mov cx, ax			; Use string length as counter

	mov bx, 0			; BX will be the final number
	mov ax, 0


	; As we move left in the string, each char is a bigger multiple. The
	; right-most character is a multiple of 1, then next (a char to the
	; left) a multiple of 10, then 100, then 1,000, and the final (and
	; leftmost char) in a five-char number would be a multiple of 10,000

	mov word [.multiplier], 1	; Start with multiples of 1

.loop:
	mov ax, 0
	mov byte al, [si]		; Get character
	sub al, 48			; Convert from ASCII to real number

	mul word [.multiplier]		; Multiply by our multiplier

	add bx, ax			; Add it to BX

	push ax				; Multiply our multiplier by 10 for next char
	mov word ax, [.multiplier]
	mov dx, 10
	mul dx
	mov word [.multiplier], ax
	pop ax

	dec cx				; Any more chars?
	cmp cx, 0
	je .finish
	dec si				; Move back a char in the string
	jmp .loop

.finish:
	mov word [.tmp], bx
	popa
	mov word ax, [.tmp]

	pop si
	pop di
	pop bp

	ret


	.multiplier	dw 0
	.tmp		dw 0


; ------------------------------------------------------------------
; unsigned short shortToString(unsigned short value) -- Convert unsigned integer to string

_shortToString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov ax, [bp+4]

	mov cx, 0
	mov bx, 10			; Set BX 10, for division and mod
	mov di, .t			; Get our pointer ready

.push:
	mov dx, 0
	div bx				; Remainder in DX, quotient in AX
	inc cx				; Increase pop loop counter
	push dx				; Push remainder, so as to reverse order when popping
	test ax, ax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop dx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		; Zero-terminate string

	popa
	mov ax, .t			; Return location of string
	pop si
	pop di
	pop bp
	ret


	.t times 7 db 0


; ------------------------------------------------------------------
; unsigned short sShortToString(signed short value) -- Convert signed integer to string

_sShortToString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov ax, [bp+4]

	mov cx, 0
	mov bx, 10			; Set BX 10, for division and mod
	mov di, .t			; Get our pointer ready

	test ax, ax			; Find out if X > 0 or not, force a sign
	js .neg				; If negative...
	jmp .push			; ...or if positive
.neg:
	neg ax				; Make AX positive
	mov byte [.t], '-'		; Add a minus sign to our string
	inc di				; Update the index
.push:
	mov dx, 0
	div bx				; Remainder in DX, quotient in AX
	inc cx				; Increase pop loop counter
	push dx				; Push remainder, so as to reverse order when popping
	test ax, ax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop dx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		; Zero-terminate string

	popa
	mov ax, .t			; Return location of string

	push si
	push di
	push bp
	ret


	.t times 7 db 0


; ------------------------------------------------------------------
; void setTimeFMT(unsigned short format) -- Set time reporting format (eg '10:25 AM' or '2300 hours')
; IN: AL = format flag, 0 = 12-hr format

_setTimeFMT:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	cmp al, 0
	je .store
	mov al, 0FFh
.store:
	mov [fmt_12_24], al
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; unsigned short getTimeString() -- Get current time in a string (eg '10:25')

_getTimeString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov di, .fullTimeString		; Location to place time string

	clc				; For buggy BIOSes
	mov ah, 2			; Get time data from BIOS in BCD format
	int 1Ah
	jnc .read

	clc
	mov ah, 2			; BIOS was updating (~1 in 500 chance), so try again
	int 1Ah

.read:
	mov al, ch			; Convert hours to integer for AM/PM test
	xor ah, ah
	push ax
	call _bcdToInt
	inc sp
	inc sp
	mov dx, ax			; Save

	mov al,	ch			; Hour
	shr al, 4			; Tens digit - move higher BCD number into lower bits
	and ch, 0Fh			; Ones digit
	test byte [fmt_12_24], 0FFh
	jz .twelve_hr

	call .add_digit			; BCD already in 24-hour format
	mov al, ch
	call .add_digit
	jmp .minutes

.twelve_hr:
	cmp dx, 0			; If 00mm, make 12 AM
	je .midnight

	cmp dx, 10			; Before 1000, OK to store 1 digit
	jl .twelve_st1

	cmp dx, 12			; Between 1000 and 1300, OK to store 2 digits
	jle .twelve_st2

	mov ax, dx			; Change from 24 to 12-hour format
	sub ax, 12
	mov bl, 10
	div bl
	mov ch, ah

	cmp al, 0			; 1-9 PM
	je .twelve_st1

	jmp short .twelve_st2		; 10-11 PM

.midnight:
	mov al, 1
	mov ch, 2

.twelve_st2:
	call .add_digit			; Modified BCD, 2-digit hour
.twelve_st1:
	mov al, ch
	call .add_digit

	mov al, ':'			; Time separator (12-hr format)
	stosb

.minutes:
	mov al, cl			; Minute
	shr al, 4			; Tens digit - move higher BCD number into lower bits
	and cl, 0Fh			; Ones digit
	call .add_digit
	mov al, cl
	call .add_digit

	mov al, ' '			; Separate time designation
	stosb

	mov si, .hours_string		; Assume 24-hr format
	test byte [fmt_12_24], 0FFh
	jnz .copy

	mov si, .pm_string		; Assume PM
	cmp dx, 12			; Test for AM/PM
	jg .copy

	mov si, .am_string		; Was actually AM

.copy:
	lodsb				; Copy designation, including terminator
	stosb
	cmp al, 0
	jne .copy

	popa
	jmp .end


.add_digit:
	add al, '0'			; Convert to ASCII
	stosb				; Put into string buffer
	ret

.end:
	pop si
	pop di
	pop bp
	mov ax, .fullTimeString
	ret

	.hours_string	db 'hours', 0
	.am_string 	db 'AM', 0
	.pm_string 	db 'PM', 0
	.fullTimeString times 11 db 0


; ------------------------------------------------------------------
; void setDateFMT(unsigned short format) -- Set date reporting format (M/D/Y, D/M/Y or Y/M/D - 0, 1, 2)
; If format bit 7 = 1 = use name for months
; If format bit 7 = 0, high byte = separator character

_setDateFMT:
	push bp
	mov bp, sp
	push di
	push si
	pusha
	
	mov ax, [bp+4]
	
	test al, 80h			; ASCII months (bit 7)?
	jnz .fmt_clear

	and ax, 7F03h			; 7-bit ASCII separator and format number
	jmp short .fmt_test

.fmt_clear:
	and ax, 0003			; Ensure separator is clear

.fmt_test:
	cmp al, 3			; Only allow 0, 1 and 2
	jae .leave
	mov [fmt_date], ax

.leave:
	popa
	pop si
	pop di
	pop bp
	ret


; ------------------------------------------------------------------
; unsigned short getDateString() -- Get current date in a string (eg '12/31/2007')
; IN/OUT: BX = string location

_getDateString:
	push bp
	mov bp, sp
	push di
	push si
	pusha

	mov bx, .fullDateString

	mov di, bx			; Store string location for now
	mov bx, [fmt_date]		; BL = format code
	and bx, 7F03h			; BH = separator, 0 = use month names

	clc				; For buggy BIOSes
	mov ah, 4			; Get date data from BIOS in BCD format
	int 1Ah
	jnc .read

	clc
	mov ah, 4			; BIOS was updating (~1 in 500 chance), so try again
	int 1Ah

.read:
	cmp bl, 2			; YYYY/MM/DD format, suitable for sorting
	jne .try_fmt1

	mov ah, ch			; Always provide 4-digit year
	call .add_2digits
	mov ah, cl
	call .add_2digits		; And '/' as separator
	mov al, '/'
	stosb

	mov ah, dh			; Always 2-digit month
	call .add_2digits
	mov al, '/'			; And '/' as separator
	stosb

	mov ah, dl			; Always 2-digit day
	call .add_2digits
	jmp .done

.try_fmt1:
	cmp bl, 1			; D/M/Y format (military and Europe)
	jne .do_fmt0

	mov ah, dl			; Day
	call .add_1or2digits

	mov al, bh
	cmp bh, 0
	jne .fmt1_day

	mov al, ' '			; If ASCII months, use space as separator

.fmt1_day:
	stosb				; Day-month separator

	mov ah,	dh			; Month
	cmp bh, 0			; ASCII?
	jne .fmt1_month

	call .add_month			; Yes, add to string
	mov ax, ', '
	stosw
	jmp short .fmt1_century

.fmt1_month:
	call .add_1or2digits		; No, use digits and separator
	mov al, bh
	stosb

.fmt1_century:
	mov ah,	ch			; Century present?
	cmp ah, 0
	je .fmt1_year

	call .add_1or2digits		; Yes, add it to string (most likely 2 digits)

.fmt1_year:
	mov ah, cl			; Year
	call .add_2digits		; At least 2 digits for year, always

	jmp .done

.do_fmt0:				; Default format, M/D/Y (US and others)
	mov ah,	dh			; Month
	cmp bh, 0			; ASCII?
	jne .fmt0_month

	call .add_month			; Yes, add to string and space
	mov al, ' '
	stosb
	jmp short .fmt0_day

.fmt0_month:
	call .add_1or2digits		; No, use digits and separator
	mov al, bh
	stosb

.fmt0_day:
	mov ah, dl			; Day
	call .add_1or2digits

	mov al, bh
	cmp bh, 0			; ASCII?
	jne .fmt0_day2

	mov al, ','			; Yes, separator = comma space
	stosb
	mov al, ' '

.fmt0_day2:
	stosb

.fmt0_century:
	mov ah,	ch			; Century present?
	cmp ah, 0
	je .fmt0_year

	call .add_1or2digits		; Yes, add it to string (most likely 2 digits)

.fmt0_year:
	mov ah, cl			; Year
	call .add_2digits		; At least 2 digits for year, always


.done:
	mov ax, 0			; Terminate date string
	stosw

	popa
	mov ax, .fullDateString
	pop si
	pop di
	pop bp
	ret

	.fullDateString times 11 db 0


.add_1or2digits:
	test ah, 0F0h
	jz .only_one
	call .add_2digits
	jmp short .two_done
.only_one:
	mov al, ah
	and al, 0Fh
	call .add_digit
.two_done:
	ret

.add_2digits:
	mov al, ah			; Convert AH to 2 ASCII digits
	shr al, 4
	call .add_digit
	mov al, ah
	and al, 0Fh
	call .add_digit
	ret

.add_digit:
	add al, '0'			; Convert AL to ASCII
	stosb				; Put into string buffer
	ret

.add_month:
	push bx
	push cx
	mov al, ah			; Convert month to integer to index print table
	call _bcdToInt
	dec al				; January = 0
	mov bl, 4			; Multiply month by 4 characters/month
	mul bl
	mov si, .months
	add si, ax
	mov cx, 4
	rep movsb
	cmp byte [di-1], ' '		; May?
	jne .done_month			; Yes, eliminate extra space
	dec di
.done_month:
	pop cx
	pop bx
	ret


	.months db 'Jan.Feb.Mar.Apr.May JuneJulyAug.SeptOct.Nov.Dec.'


; ------------------------------------------------------------------
; unsigned short stringFindToken(unsigned short stringAddr, unsigned short character) -- Reads tokens separated by specified char from
; a string. Returns pointer to next token, or 0 if none left

_stringFindToken:
	push bp
	mov bp, sp
	push di
	push si
	
	mov si, [bp+6]
	mov ax, [bp+4]
	
	push si

.next_char:
	cmp byte [si], al
	je .return_token
	cmp byte [si], 0
	jz .no_more
	inc si
	jmp .next_char

.return_token:
	mov byte [si], 0
	inc si
	mov ax, si
	pop si
	pop si
	pop di
	pop bp
	ret

.no_more:
	mov ax, 0
	pop si
	pop si
	pop di
	pop bp
	ret


; ==================================================================

