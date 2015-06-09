[BITS 16]

global _main
_main:
	jmp kernel

%include "api/globaldefinitions.asm"

%DEFINE OS_VERSION "0.1"
%DEFINE API_VERSION 1

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
	mov ax, 0
	mov ss, ax
	mov ax, 500h ;Set stack to 0x0500 (the lowest free memory range) giving a stack size of 128kb *OMG HUGE*
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

	push errorMsg
	call _fatalError ;Next instructions are useless because fatalError(unsigned short msgAddr); hangs
	inc sp
	inc sp

	jmp $

; ------------------------------------------------------------------
; System Variables -- Storage for system wide information
fmt_12_24 db 0
fmt_date db 0, '/'

errorMsg db "ERROR: BuenOS has encountered a fatal error and has been forced to halt.", 0
bootscreen db "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# ", "|  .:;';;;;'#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.` `......,,:;:;;;,`| ", "#.;;;,....,'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+;:....,,,.  .,;+#### ", "|::::.  .'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#',` `..,::;::;:;,;+| ", "#;;,   ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:.``,.,;:..`.....```.,;:,,,:'# ", "|';` `'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+: `,';:,:;::;;;;;;': .` .,....,;''';| ", "#+;..:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: ,:....`.:;+#+@@@@@@@@@@ ``  `,.:.,;';'# ", "|;',,@@@@@@@@@@@@@@@@@@@@@@@@@@+;:    .,,::::;;;+@@@@@;'++';@@+, :,     `..,;'| ", "#'#::@@@@@@@@@@@@@',.`           @  `'''';:,....;@@@@@@'  `.,++. @@;       .`.# ", "|#@':@@@@@#. .;;:,,..``.....`  @@@@+ :+#+'::.::,  `'   .,;''': ;@@@@@@:     .:| ", "#+#::,  '@@+:,``..,::,,,,,'## @,@@@@@'  ;+#+'''';;;'#@@+,,;@@@@@@@@@@@@@+```.,# ", "|     ;@@@;...,:;;;;;:..,@@@@:.@@@@@@@@@@`    ``,;'++@@@@@@@@@@@@@@@@@@@@@,:'#| ", "#   `,.+@'..,,,,..,:. .,..;', @@@@@@@@@@@@@#+++++#@@@@@@@@@@@@@@@@@@@@@@@@@@@@# ", "|@   ,,,''....``       .:;, ,'#@@@@@@@@@@@@@@@+++#######@@@@@@@@@@@@@@@@@@@@:'| ", "#@#   .,,@..``  `:'@@',.;@@@@;,@#';'+#@#':;'+'''#@@##+++++++##@@@@@@@@@@@@@@''# ", "|@@@ `  `+;,;@@@+` `;#@@@@@#+;#@;,..,:;';'''+@@@@@@@@@@@@#+++###@@@@@@@@@@@@@:| ", "#@@++   '@@@@@#+###@@@@@@@@@#':..  `.:++#@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@# ", "|@''#'`.@@@@+++'+####@@@@##+++';@@#'+#@++#+'''';::;;''+@@@@@@@@@#@@@@@@@@@@@@@| ", "#;;;+'''@@@+;;'''+++#####+'';;+@@@@@',.. ____ @@@@@@@@@@@@@@@@@@ ____   _____ # ", "|@+@##+;@@;,,,::;;;'''';;;;;;+@#,`.,;'+ |  _ \                  / __ \ / ____|| ", "#@@@@@:';@',`..,,:::;:;;;;:,...,'##@@@@ | |_) |_   _  ___ _ __ | |  | | (___  # ", "|++++#;;,.+;,```..,:;;;';;;:,.,+@@@@@@@ |  _ <| | | |/ _ \ '_ \| |  | |\___ \ | ", "#'''+++..``+;,.```.,:;;;::;:,.,'+###### | |_) | |_| |  __/ | | | |__| |____) |# ", "| .:';'';,,`:'..`` `.,::,,,,..``.,:;+#@ |____/ \__,_|\___|_| |_|\____/|_____/ | ", "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#", 0

