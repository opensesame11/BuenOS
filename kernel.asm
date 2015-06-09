[BITS 16]

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

disk_buffer equ 6000h

vectorTable:
	jmp kernel
	jmp _vgaSetup
	jmp _vgaPrint
	jmp _vgaPrintString
	jmp _vgaSetCursor
	jmp _vgaSetupCursor
	jmp _pause
	jmp _getAPIVersion
	jmp _fatalError
	jmp os_string_length
	jmp os_string_reverse
	jmp os_find_char_in_string
	jmp os_string_charchange
	jmp os_string_uppercase
	jmp os_string_lowercase
	jmp os_string_copy
	jmp os_string_truncate
	jmp os_string_join
	jmp os_string_chomp
	jmp os_string_strip
	jmp os_string_compare
	jmp os_string_strincmp
	jmp os_string_parse
	jmp os_string_to_int
	jmp os_int_to_string
	jmp os_sint_to_string
	jmp os_long_int_to_string
	jmp os_set_time_fmt
	jmp os_get_time_string
	jmp os_set_date_fmt
	jmp os_get_date_string
	jmp os_string_tokenize
	jmp os_get_file_list
	jmp os_load_file
	jmp os_write_file
	jmp os_file_exists
	jmp os_create_file
	jmp os_remove_file
	jmp os_rename_file
	jmp os_get_file_size
	jmp os_wait_for_key
	jmp os_check_for_key
	jmp os_seed_random
	jmp os_get_random
	jmp os_bcd_to_int
	jmp os_long_int_negate
	jmp _portWrite
	jmp _portRead
	jmp _serialSetup
	jmp _serialWrite
	jmp _serialRead

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
	
	push 03h
	call _vgaSetup
	
	push bootscreen
	call _vgaPrintString
	
	jmp $ ;Instruction to prevent system execution of system variables
	
; ------------------------------------------------------------------
; System Variables -- Storage for system wide information
fmt_12_24 db 0
fmt_date db 0, '/'

bootscreen db "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# ", "|  .:;';;;;'#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.` `......,,:;:;;;,`| ", "#.;;;,....,'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+;:....,,,.  .,;+#### ", "|::::.  .'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#',` `..,::;::;:;,;+| ", "#;;,   ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.``,.,;:..`.....```.,;:,,,:'# ", "|';` `'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+: `,';:,:;::;;;;;;': .` .,....,;''';| ", "#+;..:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: ,:....`.:;+#+@@@@@@@@@@ ``  `,.:.,;';'# ", "|;',,@@@@@@@@@@@@@@@@@@@@@@@@@@+;:    .,,::::;;;+@@@@@;'++';@@+, :,     `..,;'| ", "#'#::@@@@@@@@@@@@@',.`           @  `'''';:,....;@@@@@@'  `.,++. @@;       .`.# ", "|#@':@@@@@#. .;;:,,..``.....`  @@@@+ :+#+'::.::,  `'   .,;''': ;@@@@@@:     .:| ", "#+#::,  '@@+:,``..,::,,,,,'## @,@@@@@'  ;+#+'''';;;'#@@+,,;@@@@@@@@@@@@@+```.,# ", "|     ;@@@;...,:;;;;;:..,@@@@:.@@@@@@@@@@`    ``,;'++@@@@@@@@@@@@@@@@@@@@@,:'#| ", "#   `,.+@'..,,,,..,:. .,..;', @@@@@@@@@@@@@#+++++#@@@@@@@@@@@@@@@@@@@@@@@@@@@@# ", "|@   ,,,''....``       .:;, ,'#@@@@@@@@@@@@@@@+++#######@@@@@@@@@@@@@@@@@@@@:'| ", "#@#   .,,@..``  `:'@@',.;@@@@;,@#';'+#@#':;'+'''#@@##+++++++##@@@@@@@@@@@@@@''# ", "|@@@ `  `+;,;@@@+` `;#@@@@@#+;#@;,..,:;';'''+@@@@@@@@@@@@#+++###@@@@@@@@@@@@@:| ", "#@@++   '@@@@@#+###@@@@@@@@@#':..  `.:++#@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@# ", "|@''#'`.@@@@+++'+####@@@@##+++';@@#'+#@++#+'''';::;;''+@@@@@@@@@#@@@@@@@@@@@@@| ", "#;;;+'''@@@+;;'''+++#####+'';;+@@@@@',.. ____ @@@@@@@@@@@@@@@@@@ ____   _____ # ", "|@+@##+;@@;,,,::;;;'''';;;;;;+@#,`.,;'+ |  _ \                  / __ \ / ____|| ", "#@@@@@:';@',`..,,:::;:;;;;:,...,'##@@@@ | |_) |_   _  ___ _ __ | |  | | (___  # ", "|++++#;;,.+;,```..,:;;;';;;:,.,+@@@@@@@ |  _ <| | | |/ _ \ '_ \| |  | |\___ \ | ", "#'''+++..``+;,.```.,:;;;::;:,.,'+###### | |_) | |_| |  __/ | | | |__| |____) |# ", "| .:';'';,,`:'..`` `.,::,,,,..``.,:;+#@ |____/ \__,_|\___|_| |_|\____/|_____/ | ", "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#", 0