; ================================================================== 
; BuenOS
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT ; 
; API LINK TABLE
; ==================================================================

;======DISK======

global _getFileList
_getFileList:
	push 0x0003
	ret
global _loadFile
_loadFile:
	push 0x0006
	ret
global _writeFile
_writeFile:
	push 0x0009
	ret
global _fileExists
_fileExists:
	push 0x000c
	ret
global _createFile
_createFile:
	push 0x000f
	ret
global _removeFile
_removeFile:
	push 0x0012
	ret
global _renameFile
_renameFile:
	push 0x0015
	ret
global _getFileSize
_getFileSize:
	push 0x0018
	ret

;======MATH======

global _seedRandom
_seedRandom:
	push 0x001b
	ret
global _getRandom
_getRandom:
	push 0x001e
	ret
global _bcdToInt
_bcdToInt:
	push 0x0021
	ret

;======KEYBOARD======

global _waitKey
_waitKey:
	push 0x0024
	ret
global _getKey
_getKey:
	push 0x0027
	ret

;======MISC======

global _getAPIVersion
_getAPIVersion:
	push 0x002a
	ret
global _getOSVersion
_getOSVersion:
	push 0x002d
	ret
global _shutdown
_shutdown:
	push 0x0030
	ret
global _restart
_restart:
	push 0x0033
	ret
global _pause
_pause:
	push 0x0036
	ret
global _runMemory
_runMemory:
	push 0x0039
	ret
global _fatalError
_fatalError:
	push 0x003c
	ret

;======PORTS======

global _portWrite
_portWrite:
	push 0x003f
	ret
global _portRead
_portRead:
	push 0x0042
	ret
global _serialSetup
_serialSetup:
	push 0x0045
	ret
global _serialWrite
_serialWrite:
	push 0x0048
	ret
global _serialRead
_serialRead:
	push 0x004b
	ret

;======STRING======

global _stringLength
_stringLength:
	push 0x004e
	ret
global _stringReverse
_stringReverse:
	push 0x0051
	ret
global _stringFindChar
_stringFindChar:
	push 0x0054
	ret
global _stringFindAndReplace
_stringFindAndReplace:
	push 0x0057
	ret
global _stringUppercase
_stringUppercase:
	push 0x005a
	ret
global _stringLowercase
_stringLowercase:
	push 0x005d
	ret
global _stringCopy
_stringCopy:
	push 0x0060
	ret
global _stringTrunctuate
_stringTrunctuate:
	push 0x0063
	ret
global _stringJoin
_stringJoin:
	push 0x0066
	ret
global _stringChomp
_stringChomp:
	push 0x0069
	ret
global _stringStrip
_stringStrip:
	push 0x006c
	ret
global _stringEqual
_stringEqual:
	push 0x006f
	ret
global _stringParse
_stringParse:
	push 0x0072
	ret
global _stringToInt
_stringToInt:
	push 0x0075
	ret
global _intToString
_intToString:
	push 0x0078
	ret
global _sIntToString
_sIntToString:
	push 0x007b
	ret
global _setTimeFMT
_setTimeFMT:
	push 0x007e
	ret
global _getTimeString
_getTimeString:
	push 0x0081
	ret
global _setDateFMT
_setDateFMT:
	push 0x0084
	ret
global _getDateString
_getDateString:
	push 0x0087
	ret
global _stringFindToken
_stringFindToken:
	push 0x008a
	ret

;======DISPLAY======

global _vgaSetup
_vgaSetup:
	push 0x008d
	ret
global _vgaGetChar
_vgaGetChar:
	push 0x0090
	ret
global _vgaGetPos
_vgaGetPos:
	push 0x0093
	ret
global _vgaPrint
_vgaPrint:
	push 0x0096
	ret
global _vgaPrintString
_vgaPrintString:
	push 0x0099
	ret
global _vgaSetPos
_vgaSetPos:
	push 0x009c
	ret
global _vgaSetupCursor
_vgaSetupCursor:
	push 0x009f
	ret

;======SOUND======
