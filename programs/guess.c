#include "buenosapi.h"

int main( int argc, char **argv ){
	#include "orgreplacement.h"
	vgaPrintString( "This is a program!\r\nThe name of it is " );
	vgaPrintString( argv[0] );
	vgaPrintString( "\r\n" );
	return 0;
}

