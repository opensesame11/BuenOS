#include "buenosapi.h"

int main( int argc, String argv[] ){
	vgaPrintString( "This is a program!\r\nThe name of it is " );
	vgaPrintString( argv[0] );
	vgaPrintString( "\r\n" );
	return 0;
}
