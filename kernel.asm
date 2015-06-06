[BITS 16]

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

disk_buffer equ 6000h

vectorTable: ;Since main is called first, the other's don't actually execute
	jmp kernel ;DO NOT INCLUDE IN API INCLUDE FILE
	jmp _vgaSetup ;Display.asm
	jmp _vgaPrintChar ;Display.asm
	jmp _vgaPrintString ;Display.asm
	jmp _vgaSetCursor ;Display.asm
	jmp _pause ;Misc.asm
	jmp _getAPIVersion ;Misc.asm
	jmp _fatalError ;Misc.asm
	jmp os_string_length ;String.asm
	jmp os_string_reverse ;String.asm
	jmp os_find_char_in_string ;String.asm
	jmp os_string_charchange ;String.asm
	jmp os_string_uppercase ;String.asm
	jmp os_string_lowercase ;String.asm
	jmp os_string_copy ;String.asm
	jmp os_string_truncate ;String.asm
	jmp os_string_join ;String.asm
	jmp os_string_chomp ;String.asm
	jmp os_string_strip ;String.asm
	jmp os_string_compare ;String.asm
	jmp os_string_strincmp ;String.asm
	jmp os_string_parse ;String.asm
	jmp os_string_to_int ;String.asm
	jmp os_int_to_string ;String.asm
	jmp os_sint_to_string ;String.asm
	jmp os_long_int_to_string ;String.asm
	jmp os_set_time_fmt ;String.asm
	jmp os_get_time_string ;String.asm
	jmp os_set_date_fmt ;String.asm
	jmp os_get_date_string ;String.asm
	jmp os_string_tokenize ;String.asm
	jmp os_get_file_list ;Disk.asm
	jmp os_load_file ;Disk.asm
	jmp os_write_file ;Disk.asm
	jmp os_file_exists ;Disk.asm
	jmp os_create_file ;Disk.asm
	jmp os_remove_file ;Disk.asm
	jmp os_rename_file ;Disk.asm
	jmp os_get_file_size ;Disk.asm
	jmp os_wait_for_key ;Keyboard.asm
	jmp os_check_for_key ;Keyboard.asm
	jmp os_seed_random ;Math.asm
	jmp os_get_random ;Math.asm
	jmp os_bcd_to_int ;Math.asm
	jmp os_long_int_negate ;Math.asm
	jmp _portWrite ;Ports.asm
	jmp _portRead ;Ports.asm
	jmp _serialSetup ;Ports.asm
	jmp _serialWrite ;Ports.asm
	jmp _serialRead ;Ports.asm

%include "api\disk.asm" ;Disk utilities
%include "api\math.asm" ;Math functions
%include "api\keyboard.asm" ;Keyboard functions
%include "api\misc.asm" ;Useful functions
%include "api\ports.asm" ;Serial port lib
%include "api\string.asm" ;String manipulation lib
%include "api\display.asm" ;Display configuration and output (WIP)
%include "api\sound.asm" ;Sound configuration and output (WIP)
%include "api\cli.asm" ;Command line interface (WIP)

kernel:
	cli
	mov ax, 0
	mov ss, ax
	mov ax, 500h ;Set stack to 0x0500 (the lowest free memory range) giving a stack size of 128kb
	mov sp, ax
	sti
	
	cld
	mov ax, 2000h
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ax, 1h
	push ax
	call _vgaSetup
	
	mov ax, bens_program
	call os_file_exists
	jnc wow
	
	mov cx, 0A000h
	call os_load_file
	call 0A00h:0000h
	
wow:
	mov ax, bens_program
	push ax
	call _vgaPrintString
	jmp $
	
bens_program db "CALC    BIN", 0
	
; ------------------------------------------------------------------
; System Variables -- Storage for system wide information
fmt_12_24 db 0
fmt_date db 0, '/'