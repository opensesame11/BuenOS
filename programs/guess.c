#include "buenosapi.h"

unsigned int i;

int main( unsigned int argc, String argv[] ){
	#include "orgreplacement.h"
	vgaPrintString( "\r\nThe name of this program is " );
	vgaPrintString( argv[0] );
	vgaPrintString( "\r\n\nThe arguments pass to it are as follows: \r\n" );
	for(i = 0; i < argc; i++){
		vgaPrintString( "  argv[" );
		vgaPrintString( intToString( i ) );
		vgaPrintString( "]: " );
		vgaPrintString( argv[i] );
		vgaPrintString( "\r\n" );
	}
	return 0;
}

