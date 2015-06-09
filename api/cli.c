#include "buenosapi.h"

unsigned short commandLine(){
	vgaSetup(0x3);
	return 0xb;
}
