globalDefinitions:
	jmp _vgaSetup
		global _vgaSetup

	jmp _vgaPrint
		global _vgaPrint

	jmp _vgaPrintString
		global _vgaPrintString

	jmp _vgaSetCursor
		global _vgaSetCursor

	jmp _vgaSetupCursor
		global _vgaSetupCursor

	jmp _pause
		global _pause

	jmp _getAPIVersion
		global _getAPIVersion

	jmp _fatalError
		global _fatalError

	jmp _getFileList
		global _getFileList

	jmp _loadFile
		global _loadFile

	jmp _writeFile
		global _writeFile

	jmp _fileExists
		global _fileExists

	jmp _createFile
		global _createFile

	jmp _removeFile
		global _removeFile

	jmp _renameFile
		global _renameFile

	jmp _getFileSize
		global _getFileSize

	jmp _portWrite
		global _portWrite

	jmp _portRead
		global _portRead

	jmp _serialSetup
		global _serialSetup

	jmp _serialWrite
		global _serialWrite

	jmp _serialRead
		global _serialRead

	jmp _stringLength
		global _stringLength

	jmp _reverseString
		global _reverseString

	jmp _findCharInString
		global _findCharInString

	jmp _stringFindAndReplace
		global _stringFindAndReplace

	jmp _stringUppercase
		global _stringUppercase

	jmp _stringLowercase
		global _stringLowercase

	jmp _stringCopy
		global _stringCopy

	jmp _stringTrunctuate

		global _stringTrunctuate
	jmp _stringJoin
		global _stringJoin

	jmp _stringChomp
		global _stringChomp

	jmp _stringStrip
		global _stringStrip

	jmp _stringEqual
		global _stringEqual

	jmp _stringParse
		global _stringParse

	jmp _stringToShort
		global _stringToShort

	jmp _shortToString
		global _shortToString

	jmp _sShortToString
		global _sShortToString

	jmp _setTimeFMT
		global _setTimeFMT

	jmp _getTimeString
		global _getTimeString

	jmp _setDateFMT
		global _setDateFMT

	jmp _getDateString
		global _getDateString

	jmp _stringFindToken
		global _stringFindToken

	jmp _seedRandom
		global _seedRandom

	jmp _getRandom
		global _getRandom

	jmp _bcdToInt
		global _bcdToInt

	jmp _waitKey
		global _waitKey

	jmp _getKey
		global _getKey

;	jmp 
;		global 

