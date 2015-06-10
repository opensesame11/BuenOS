#include "buenosapi.h"



void commandLine(){
	while(1){
		vgaPrintString( " W" );
		pause( 1 );
		vgaPrint( 'O' );
		pause( 1 );
		vgaPrint( 'W' );
		pause( 3 );
	}
	waitKey();
}
