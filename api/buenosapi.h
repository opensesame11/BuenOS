#ifndef __AS386_16__
#define __AS386_16__
#endif
#ifndef BUENOSAPI

typedef void String;
typedef char bcd;

typedef struct{
	void *arg1;
	void *arg2;
	void *arg3;
	void *arg4;
} parsedString_t;

typedef struct{
	unsigned int x;
	unsigned int y;
} cursorPos_t;

typedef struct{
	//return struct of getFileList
} fileList_t;

void vgaSetup(char mode);
void vgaPrint(char character);
void vgaPrintString(void* string);
void vgaSetPos(unsigned int x, unsigned int y);
void vgaSetupCursor(unsigned int attribute);
	//---- TODO ----//
//void vgaSetAttrib(unsigned int attribute);
//unsigned int vgaGetAttrib(unsigned int x, unsigned int y);
cursorPos_t* vgaGetPos();

void pause(unsigned int time);
unsigned int getAPIVersion();
void* getOSVersion();
void fatalError(String* errorMsg);
	//---- TODO ----//
//void shutdown();
//void restart();

void getFileList(String* fileList);
unsigned int loadFile(String* filename, unsigned int destAddress);
unsigned int writeFile(String* filename, unsigned int srcAddress, unsigned int size);//returns 0 on success
unsigned int fileExists(String* filename);
unsigned int createFile(String* filename);
unsigned int removeFile(String* filename);
unsigned int renameFile(String* oldName, String* newName);
unsigned int getFileSize(String* filename);

void portWrite(unsigned int port, char toPort);
char portRead(unsigned int port);
void serialSetup(unsigned int mode);
void serialWrite(char toPort);
char serialRead();

unsigned int stringLength(String* string);
void stringReverse(String* string);
unsigned int stringFindChar(String* string, char find);//returns location of character's first appearance in string
void stringFindAndReplace(String* string, char findAndReplace);
void stringUppercase(String* string);
void stringLowercase(String* string);
void stringCopy(String* source, String* dest);
void stringTrunctuate(String* string, unsigned int length);
void stringJoin(String* sourceOne, String* sourceTwo, String* dest);
void stringChomp(String* string);
void stringStrip(String* string, char remove);//strips remove from string
unsigned int stringEqual(String* stringOne, String* stringTwo);
//String* stringParse[](String* string);
unsigned int stringToInt(String* string);
String* intToString(unsigned int value);
String* sIntToString(signed int value);
void setTimeFMT(unsigned int format);
String* getTimeString();
void setDateFMT(unsigned int format);
String* getDateString();
String* stringFindToken(String* string, char character, unsigned int offset);

void seedRandom();
unsigned int getRandom();
unsigned int bcdToInt(bcd value);

char waitKey();
char getKey();

#endif
