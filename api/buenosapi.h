#ifndef __AS386_16__
#define __AS386_16__
#endif
#ifndef BUENOSAPI
#define BUENOSAPI
void vgaSetup(unsigned short mode);
void vgaPrint(unsigned short character);
void vgaPrintString(unsigned short stringAddr);
void vgaSetCursor(unsigned short x, unsigned short y);
void vgaSetupCursor(unsigned short topLine, unsigned short bottomLine, unsigned short blink);

void portWrite(unsigned short addr, unsigned short byte);
unsigned short portRead(unsigned short addr);
void serialSetup(unsigned short mode);
unsigned short serialWrite(unsigned short byte);
unsigned short serialRead();

unsigned short waitKey();
unsigned short getKey();

unsigned short getAPIVersion();
void pause(unsigned short time);
void fatalError(unsigned short msgAddr);
#endif
