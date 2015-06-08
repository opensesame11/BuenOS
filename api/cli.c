#ifndef CODE16GCC_H
#define CODE16GCC_H
__asm__(".code16gcc\n");
#endif

extern void vgaSetup(short mode);
extern void vgaPrint(short character);

unsigned short commandLine(){
	vgaSetup(0x1);
	return 1;
}