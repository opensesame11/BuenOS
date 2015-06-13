[BITS 16]

global _main
_main:
	jmp kernel

%include "api/globaldefinitions.asm"
%DEFINE API_VERSION 1
%DEFINE OS_VERSION "Barebones 1"

disk_buffer equ 6000h

%include "api/disk.asm" ;Disk utilities
%include "api/math.asm" ;Math functions
%include "api/keyboard.asm" ;Keyboard functions
%include "api/misc.asm" ;Useful functions
%include "api/ports.asm" ;Serial port lib
%include "api/string.asm" ;String manipulation lib
%include "api/display.asm" ;Display configuration and output (WIP)
%include "api/sound.asm" ;Sound configuration and output (WIP)

kernel:
	cli
	mov ax, 050h	;0x00000500
	mov ss, ax
	mov ax, 0a8ffh	;0x0000adff
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
	inc sp
	inc sp

	push bootscreen
	call _vgaPrintString
	inc sp
	inc sp

	extern _commandLine
	call _commandLine

	jmp $
; ------------------------------------------------------------------
; System Variables -- Storage for system wide information
fmt_12_24 db 0
fmt_date db 0, '/'

errorMsg 	db "ERROR: BuenOS has encountered a fatal error and has been forced to halt.", 0

bootscreen 	db "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# ",
		db "|  .:;';;;;'#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.` `......,,:;:;;;,`| ",
		db "#.;;;,....,'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+;:....,,,.  .,;+#### ",
		db "|::::.  .'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#',` `..,::;::;:;,;+| ",
		db "#;;,   ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.``,.,;:..`.....```.,;:,,,:'# ",
		db "|';` `'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+: `,';:,:;::;;;;;;': .` .,....,;''';| ",
		db "#+;..:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: ,:....`.:;+#+@@@@@@@@@@ ``  `,.:.,;';'# ",
		db "|;',,@@@@@@@@@@@@@@@@@@@@@@@@@@+;:    .,,::::;;;+@@@@@;'++';@@+, :,     `..,;'| ",
		db "#'#::@@@@@@@@@@@@@',.`           @  `'''';:,....;@@@@@@'  `.,++. @@;       .`.# ",
		db "|#@':@@@@@#. .;;:,,..``.....`  @@@@+ :+#+'::.::,  `'   .,;''': ;@@@@@@:     .:| ",
		db "#+#::,  '@@+:,``..,::,,,,,'## @,@@@@@'  ;+#+'''';;;'#@@+,,;@@@@@@@@@@@@@+```.,# ",
		db "|     ;@@@;...,:;;;;;:..,@@@@:.@@@@@@@@@@`    ``,;'++@@@@@@@@@@@@@@@@@@@@@,:'#| ",
		db "#   `,.+@'..,,,,..,:. .,..;', @@@@@@@@@@@@@#+++++#@@@@@@@@@@@@@@@@@@@@@@@@@@@@# ",
		db "|@   ,,,''....``       .:;, ,'#@@@@@@@@@@@@@@@+++#######@@@@@@@@@@@@@@@@@@@@:'| ",
		db "#@#   .,,@..``  `:'@@',.;@@@@;,@#';'+#@#':;'+'''#@@##+++++++##@@@@@@@@@@@@@@''# ",
		db "|@@@ `  `+;,;@@@+` `;#@@@@@#+;#@;,..,:;';'''+@@@@@@@@@@@@#+++###@@@@@@@@@@@@@:| ",
		db "#@@++   '@@@@@#+###@@@@@@@@@#':..  `.:++#@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@# ",
		db "|@''#'`.@@@@+++'+####@@@@##+++';@@#'+#@++#+'''';::;;''+@@@@@@@@@#@@@@@@@@@@@@@| ",
		db "#;;;+'''@@@+;;'''+++#####+'';;+@@@@@',.  ____                    ____   _____ # ",
		db "|@+@##+;@@;,,,::;;;'''';;;;;;+@#,`.,;'+ |  _ \                  / __ \ / ____|| ",
		db "#@@@@@:';@',`..,,:::;:;;;;:,...,'##@@@@ | |_) |_   _  ___ _ __ | |  | | (___  # ",
		db "|++++#;;,.+;,```..,:;;;';;;:,.,+@@@@@@@ |  _ <| | | |/ _ \ '_ \| |  | |\___ \ | ",
		db "#'''+++..``+;,.```.,:;;;::;:,.,'+###### | |_) | |_| |  __/ | | | |__| |____) |# ",
		db "| .:';'';,,`:'..`` `.,::,,,,..``.,:;+#@ |____/ \__,_|\___|_| |_|\____/|_____/ | ",
		db "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#", 0

os_version	db OS_VERSION

os_version_msg	db "BuenOS version ", OS_VERSION, 10, 13
		db "Copyright (C) 2015 BuenOS Team", 10, 13
		db "License: GNU GPLv2 (LICENSE.TXT)", 10, 13
		db "This is free software; "
		db "you are free to change and redistribute it.", 10, 13
		db "There is NO WARRANTY, to the "
		db "extent permitted by law.", 10, 13, 10, 0

