[BITS 16]

;-------------BuenOS Bootloader----------------

jmp short bootloader
nop

;-------------------------------------------------------
OEMLabel		db "        "
BytesPerSector		dw 512
SectorsPerCluster	db 1
ReservedForBoot		dw 1
NumberOfFats		db 2
RootDirEntries		dw 224
LogicalSectors		dw 2880
MediaDesctiptor		db 0xF0
SectorsPerFat		dw 9
SectorsPerTrack		dw 18
Sides			dw 2
HiddenSectors		dd 0
LargeSectors		dd 0
DriveNo			dw 0
Signature		db 41
VolumeID		dd 0x00000000
VolumeLabel		db "BuenOS    "
FileSystem		db "FAT12   "
;-------------------------------------------------------

bootloader:
	mov ax, 0D04h			; Set up 4K of stack space above buffer
	cli				; Disable interrupts while changing stack
	mov ss, ax
	mov sp, 4096
	sti				; Restore interrupts

	mov ax, 07C0h			; Set data segment to where we're loaded
	mov ds, ax

	; NOTE: A few early BIOSes are reported to improperly set DL

	cmp dl, 0
	je no_change
	mov [bootdev], dl		; Save boot device number
	mov ah, 8			; Get drive parameters
	int 13h
	jc fatal_disk_error
	and cx, 3Fh			; Maximum sector number
	mov [SectorsPerTrack], cx	; Sector numbers start at 1
	movzx dx, dh			; Maximum head number
	add dx, 1			; Head numbers start at 0 - add 1 for total
	mov [Sides], dx

no_change:
	mov eax, 0			; Needed for some older BIOSes


; First, we need to load the root directory from the disk. Technical details:
; Start of root = ReservedForBoot + NumberOfFats * SectorsPerFat = logical 19
; Number of root = RootDirEntries * 32 bytes/entry / 512 bytes/sector = 14
; Start of user data = (start of root) + (number of root) = logical 33

floppy_ok:				; Ready to read first block of data
	mov ax, 19			; Root dir starts at logical sector 19
	call l2hts

	mov si, buffer			; Set ES:BX to point to our buffer (see end of code)
	mov bx, ds
	mov es, bx
	mov bx, si

	mov ah, 2			; Params for int 13h: read floppy sectors
	mov al, 14			; And read 14 of them

	pusha				; Prepare to enter loop


read_root_dir:
	popa				; In case registers are altered by int 13h
	pusha

	stc				; A few BIOSes do not set properly on error
	int 13h				; Read sectors using BIOS

	jnc search_dir			; If read went OK, skip ahead
	call reset_floppy		; Otherwise, reset floppy controller and try again
	jnc read_root_dir		; Floppy reset OK?

	jmp reboot			; If not, fatal double error


search_dir:
	popa

	mov ax, ds			; Root dir is now in [buffer]
	mov es, ax			; Set DI to this info
	mov di, buffer

	mov cx, word [RootDirEntries]	; Search all (224) entries
	mov ax, 0			; Searching at offset 0


next_root_entry:
	xchg cx, dx			; We use CX in the inner loop...

	mov si, kern_filename		; Start searching for kernel filename
	mov cx, 11
	rep cmpsb
	je found_file_to_load		; Pointer DI will be at offset 11

	add ax, 32			; Bump searched entries by 1 (32 bytes per entry)

	mov di, buffer			; Point to next entry
	add di, ax

	xchg dx, cx			; Get the original CX back
	loop next_root_entry

	mov si, file_not_found		; If kernel is not found, bail out
	call print_string
	jmp reboot


found_file_to_load:			; Fetch cluster and load FAT into RAM
	mov ax, word [es:di+0Fh]	; Offset 11 + 15 = 26, contains 1st cluster
	mov word [cluster], ax

	mov ax, 1			; Sector 1 = first sector of first FAT
	call l2hts

	mov di, buffer			; ES:BX points to our buffer
	mov bx, di

	mov ah, 2			; int 13h params: read (FAT) sectors
	mov al, 9			; All 9 sectors of 1st FAT

	pusha				; Prepare to enter loop


read_fat:
	popa				; In case registers are altered by int 13h
	pusha

	stc
	int 13h				; Read sectors using the BIOS

	jnc read_fat_ok			; If read went OK, skip ahead
	call reset_floppy		; Otherwise, reset floppy controller and try again
	jnc read_fat			; Floppy reset OK?

; ******************************************************************
fatal_disk_error:
; ******************************************************************
	mov si, disk_error		; If not, print error message and reboot
	call print_string
	jmp reboot			; Fatal double error


read_fat_ok:
	popa

	mov ax, 0ae0h
	mov es, ax
	mov bx, 0

;0x7c00 - 0x7dff 0x0200 size 512 bytes Bootloader
;0x7e00 - 0x9dff 0x2000 size 8192 bytes Disk buffer
;0x9e00 - 0xadff 0x1000 size 4096 bytes Stack
;0xae00 kernelStart


	mov ax, 0201h

	push ax				; Save in case we (or int calls) lose it


; Now we must load the FAT from the disk. Here's how we find out where it starts:
; FAT cluster 0 = media descriptor = 0F0h
; FAT cluster 1 = filler cluster = 0FFh
; Cluster start = ((cluster number) - 2) * SectorsPerCluster + (start of user)
;               = (cluster number) + 31

load_file_sector:
	mov ax, word [cluster]		; Convert sector to logical
	add ax, 31

	call l2hts			; Make appropriate params for int 13h

	mov ax, 2000h			; Set buffer past what we've already read
	mov es, ax
	mov bx, word [pointer]

	pop ax				; Save in case we (or int calls) lose it
	push ax

	stc
	int 13h

	jnc calculate_next_cluster	; If there's no error...

	call reset_floppy		; Otherwise, reset floppy and retry
	jmp load_file_sector


	; In the FAT, cluster values are stored in 12 bits, so we have to
	; do a bit of maths to work out whether we're dealing with a byte
	; and 4 bits of the next byte -- or the last 4 bits of one byte
	; and then the subsequent byte!

calculate_next_cluster:
	mov ax, [cluster]
	mov dx, 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				; DX = [cluster] mod 2
	mov si, buffer
	add si, ax			; AX = word in FAT for the 12 bit entry
	mov ax, word [ds:si]

	or dx, dx			; If DX = 0 [cluster] is even; if DX = 1 then it's odd

	jz even				; If [cluster] is even, drop last 4 bits of word
					; with next cluster; if odd, drop first 4 bits

odd:
	shr ax, 4			; Shift out first 4 bits (they belong to another entry)
	jmp short next_cluster_cont


even:
	and ax, 0FFFh			; Mask out final 4 bits


next_cluster_cont:
	mov word [cluster], ax		; Store cluster

	cmp ax, 0FF8h			; FF8h = end of file marker in FAT12
	jae end

	add word [pointer], 512		; Increase buffer pointer 1 sector length
	jmp load_file_sector


end:					; We've got the file to load!
	pop ax				; Clean up the stack (AX was pushed earlier)
	mov dl, byte [bootdev]		; Provide kernel with boot device info

	mov ax, 0003h
	int 10h
	jmp 2000h:0000h			; Jump to entry point of loaded kernel!


; ------------------------------------------------------------------
; BOOTLOADER SUBROUTINES, STRINGS AND POINTERS

reboot:
	mov ax, 0
	int 16h				; Wait for keystroke
	mov ax, 0
	int 19h				; Reboot the system


print_string:				; Output string in SI to screen
	pusha

	mov ah, 0Eh			; int 10h teletype function

.repeat:
	lodsb				; Get char from string
	cmp al, 0
	je .done			; If char is zero, end of string
	int 10h				; Otherwise, print it
	jmp short .repeat

.done:
	popa
	ret


reset_floppy:		; IN: [bootdev] = boot device; OUT: carry set on error
	push ax
	push dx
	mov ax, 0
	mov dl, byte [bootdev]
	stc
	int 13h
	pop dx
	pop ax
	ret


l2hts:			; Calculate head, track and sector settings for int 13h
			; IN: logical sector in AX, OUT: correct registers for int 13h
	push bx
	push ax

	mov bx, ax			; Save logical sector

	mov dx, 0			; First the sector
	div word [SectorsPerTrack]
	add dl, 01h			; Physical sectors start at 1
	mov cl, dl			; Sectors belong in CL for int 13h
	mov ax, bx

	mov dx, 0			; Now calculate the head
	div word [SectorsPerTrack]
	mov dx, 0
	div word [Sides]
	mov dh, dl			; Head/side
	mov ch, al			; Track

	pop ax
	pop bx

	mov dl, byte [bootdev]		; Set correct device

	ret


	kern_filename	db "KERNEL  BIN"
	disk_error	db "Floppy error! Press any key...", 0
	file_not_found	db "KERNEL.BIN not found", 0
	bootdev		db 0
	cluster		dw 0
	pointer		dw 0

	times 510-($-$$) db 0
	dw 0AA55h

buffer:
