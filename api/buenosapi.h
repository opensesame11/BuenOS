#ifndef __AS386_16__
#define __AS386_16__
#endif
#ifndef BUENOSAPI
#define BUENOSAPI

typedef void* String;
typedef char bcd;

typedef struct{
	unsigned int argc;
	String argv[256];
} parsedString_t;

typedef struct{
	char x;
	char y;
} cursorPos_t;


void vgaSetup(char mode);
void vgaPrint(char character);
void vgaPrintString(void string);
void vgaSetPos(unsigned int x, unsigned int y);
void vgaSetupCursor(unsigned int attribute);
cursorPos_t* vgaGetPos();
	//---- TODO ----//
//void vgaSetAttrib(unsigned int attribute);
//unsigned int vgaGetAttrib(unsigned int x, unsigned int y);

void pause(unsigned int time);
unsigned int getAPIVersion();
String getOSVersion();
void fatalError(String errorMsg);
void shutdown();
void restart();

void getFileList(String* fileList);
unsigned int loadFile( String filename, unsigned int address );//returns file size (0 is failure)
unsigned int writeFile(String filename, unsigned int address, unsigned int size);
unsigned int fileExists(String filename);
unsigned int createFile(String filename);
unsigned int removeFile(String filename);
unsigned int renameFile(String oldName, String newName);
unsigned int getFileSize(String filename);

void portWrite(unsigned int port, char toPort);
char portRead(unsigned int port);
void serialSetup(unsigned int mode);
void serialWrite(char toPort);
char serialRead();

unsigned int stringLength(String string);
void stringReverse(String string);
unsigned int stringFindChar(String string, char find);//returns location of character's first appearance in string
void stringFindAndReplace(String string, char findAndReplace);
void stringUppercase(String string);
void stringLowercase(String string);
void stringCopy(String source, String dest);
void stringTrunctuate(String string, unsigned int length);
void stringJoin(String sourceOne, String sourceTwo, String dest);
void stringChomp(String string);
void stringStrip(String string, char remove);//strips remove from string
unsigned int stringEqual(String stringOne, String stringTwo);
parsedString_t* stringParse(String string);
unsigned int stringToInt(String string);
String intToString(unsigned int value);
String sIntToString(signed int value);
void setTimeFMT(unsigned int format);
String getTimeString();
void setDateFMT(unsigned int format);
String getDateString();
String stringFindToken(String string, char character, unsigned int offset);

void seedRandom();
unsigned int getRandom();
unsigned int bcdToInt(bcd value);

char waitKey();
char getKey();

#endif
