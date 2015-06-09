#include "buenosapi.h"

void commandLine(){
	vgaSetup(0x13);
	pause(0xF0);
	vgaSetup(0x3);
	return;
}
