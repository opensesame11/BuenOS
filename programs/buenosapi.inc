; ================================================================== 
; BuenOS
; Copyright (C) 2006 - 2014 MikeOS Developers -- see doc/LICENSE.TXT ; 
; API LINK INCLUSIONS
; ==================================================================

;======DISK======

extern _getFileList
extern _loadFile
extern _writeFile
extern _fileExists
extern _createFile
extern _removeFile
extern _renameFile
extern _getFileSize

;======MATH======

extern _seedRandom
extern _getRandom
extern _bcdToInt

;======KEYBOARD======

extern _waitKey
extern _getKey

;======MISC======

extern _getAPIVersion
extern _getOSVersion
extern _shutdown
extern _restart
extern _pause
extern _runMemory
extern _fatalError

;======PORTS======

extern _portWrite
extern _portRead
extern _serialSetup
extern _serialWrite
extern _serialRead

;======STRING======

extern _stringLength
extern _stringReverse
extern _stringFindChar
extern _stringFindAndReplace
extern _stringUppercase
extern _stringLowercase
extern _stringCopy
extern _stringTrunctuate
extern _stringJoin
extern _stringChomp
extern _stringStrip
extern _stringEqual
extern _stringParse
extern _stringToInt
extern _intToString
extern _sIntToString
extern _setTimeFMT
extern _getTimeString
extern _setDateFMT
extern _getDateString
extern _stringFindToken

;======DISPLAY======

extern _vgaSetup
extern _vgaGetChar
extern _vgaGetPos
extern _vgaPrint
extern _vgaPrintString
extern _vgaSetPos
extern _vgaSetupCursor

;======SOUND======
	

