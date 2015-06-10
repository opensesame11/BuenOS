#include "buenosapi.h"

char input;
unsigned short waow;
unsigned short msgLen;

void commandLine(){
	pause( 15 );
	vgaSetCursor( 0, 24 );
	vgaPrint( ' ' );
	waitKey();
}
