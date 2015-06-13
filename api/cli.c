#include "buenosapi.h"
#define sizeOfBuffer 71 //80 - 1 for cursor - 8 for prompt text = 71

char helpstring[] = "List of commands:\r\n  HELP -- Prints this message\r\n  CLEAR -- Clear's screen buffer\r\n  VERSION -- Prints BuenOS version and licensing information\r\n  DIR -- Lists files in root directory\r\n  SHUTDOWN -- Sends an APM shutdown signal\r\n";
char inputKey;
char tempBuffer[sizeOfBuffer + 1];
char inputBuffer[sizeOfBuffer + 1];//extra character for null
unsigned int isInput();
unsigned int counter;
unsigned int temp;
cursorPos_t* cursorPos;
char directoryListing[1024];
char exit;
void launchApplication( String filename );


void commandLine(){
	inputKey = 0;
	exit = 0;
	temp = 0;
	counter = 0;

	vgaSetup(3);
	vgaSetPos(0,0);
	vgaPrintString( getOSVersion() );

	while( 1 ){
		exit = 0;
		counter = 0;
		vgaPrintString( "BuenOS >" );//prompt input

		while( exit == 0 ){//fill input buffer
			inputKey = waitKey();

			if( isInput( inputKey ) ){
				if( inputKey == 27 ){//esc
					for( temp = 0; temp < counter; temp++){
						vgaPrintString( "\b \b" );
					}
					counter = 0;
					inputBuffer[counter] = 0;
				}
				else if( inputKey == 13 ){//enter
					exit = 1;//finish buffer loop
					inputBuffer[counter] = 0;//null terminate string
					vgaPrintString( "\r\n" );
				}

				else if( inputKey == 8 ){//backspace
					if( counter != 0 ){
						vgaPrintString( "\b \b" );
						counter--;
						inputBuffer[counter] = 0;
					}
				}
				else if( counter != sizeOfBuffer ){
					vgaPrint( inputKey );
					inputBuffer[counter] = inputKey;
					counter++;
				}
			}
		}
		stringUppercase( inputBuffer );
		stringChomp( inputBuffer );
		if( stringEqual( inputBuffer, "CLEAR" ) ) vgaSetup( 0x3 );
		else if( stringEqual( inputBuffer, "VERSION" ) ) vgaPrintString( getOSVersion() );
		else if( stringEqual( inputBuffer, "SHUTDOWN" ) ) shutdown();
		else if( stringEqual( inputBuffer, "DIR" ) ){
			getFileList( directoryListing );
			vgaPrintString( directoryListing );
			vgaPrintString( "\r\n" );
		}
		else if( stringEqual( inputBuffer, "HELP" ) ) vgaPrintString( helpstring );
		else launchApplication( inputBuffer );
	}
}

void launchApplication( String filename ){
	if( fileExists( filename ) ) loadFile( filename, 0x8000 );
	else{
		vgaPrintString( "File " );
		vgaPrintString( filename );
		vgaPrintString( " cannot be found.\r\n" );
	}
	return;
}

unsigned int isInput( char input ){
	if( input == 8 || input == 13 || input == 27 || ( input >= 32 && input <= 126 ) ) return 1;
	else return 0;
}
