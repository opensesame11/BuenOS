#include "buenosapi.h"
#define sizeOfBuffer 71 //80 - 1 for cursor - 8 for prompt text = 71

char helpString[] = "List of commands:\r\n  HELP -- Prints this message\r\n  CLEAR -- Clear's screen buffer\r\n  VERSION -- Prints BuenOS version and licensing information\r\n  ECHO -- Prints next argument to command line\r\n  DIR -- Lists files in root directory\r\n  SIZEOF -- Prints size of file in bytes\r\n  RENAME -- Renames first argument to second argument\r\n  DELETE -- Deletes specified file\r\n  SHUTDOWN -- Sends an APM shutdown signal\r\n  RESTART -- Sends a non-APM reboot signal\r\n";
char inputKey;
char inputBuffer[sizeOfBuffer + 1];//extra character for null
unsigned int counter;
unsigned int temp;
cursorPos_t* cursorPos;
char tempBuffer[1024];
char exit;
parsedString_t* stringParseInfo;

unsigned int isInput();
void runApplication( parsedString_t* arguments );

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

		while( ( exit == 0 && inputKey == 0 ) || exit == 0 ){//fill input buffer
			inputKey = getKey();

			if( isInput( inputKey ) ){
				if( inputKey == 27 ){//esc
					cursorPos = vgaGetPos();
					vgaSetPos( ( cursorPos->x - counter ), cursorPos->y );
					for( temp = 0; temp < counter; temp++){
						vgaPrint( ' ' );
					}
					vgaSetPos( ( cursorPos->x - counter ), cursorPos->y );
					counter = 0;
					inputBuffer[counter] = 0;
				}
				else if( inputKey == 13 ){//enter
					exit = 1;//finish buffer loop
					inputBuffer[counter] = 0;//null terminate string
					while( counter < sizeOfBuffer ){//null out remaining buffer
						inputBuffer[counter] = 0;
						counter++;
					}
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
		stringCopy( inputBuffer, tempBuffer );
		stringParseInfo = stringParse( tempBuffer );
		stringUppercase( stringParseInfo->argv[0] );

		if( stringLength( stringParseInfo->argv[0] ) != 0 ){
			if( stringEqual( stringParseInfo->argv[0], "HELP" ) )  vgaPrintString( helpString );
			else if( stringEqual( stringParseInfo->argv[0], "CLEAR" ) )  vgaSetup( 3 );
			else if( stringEqual( stringParseInfo->argv[0], "VERSION" ) )  vgaPrintString( getOSVersion() );
			else if( stringEqual( stringParseInfo->argv[0], "ECHO" ) ) {
				stringStrip( stringParseInfo->argv[1], '"' );
				vgaPrintString( stringParseInfo->argv[1] );
				vgaPrintString( "\r\n" );
			}
			else if( stringEqual( stringParseInfo->argv[0], "DIR" ) ){
				getFileList( tempBuffer );
				stringFindAndReplace( tempBuffer, ',', ' ' );
				stringParseInfo = stringParse( tempBuffer );
				temp = 0;
				while( temp <= stringParseInfo->argc ){
					vgaPrintString( stringParseInfo->argv[temp] );
					cursorPos = vgaGetPos();
					vgaSetPos( 12, cursorPos->y );
					vgaPrintString( intToString( getFileSize( stringParseInfo->argv[temp] ) ) );
					vgaPrintString( " bytes\r\n" );
					temp++;
				}
			}
			else if( stringEqual( stringParseInfo->argv[0], "SIZEOF" ) ){
				vgaPrintString( intToString( getFileSize( stringParseInfo->argv[1] ) ) );
				vgaPrintString( " bytes\r\n" );
			}
			else if( stringEqual( stringParseInfo->argv[0], "RENAME" ) ){
				stringUppercase( stringParseInfo->argv[1] );
				stringUppercase( stringParseInfo->argv[2] );
				if( fileExists( stringParseInfo->argv[1] ) && stringLength( stringParseInfo->argv[1] ) != 0 && stringLength( stringParseInfo->argv[2] ) != 0 ){
					if( stringEqual( stringParseInfo->argv[1], "KERNEL.BIN" ) ) vgaPrintString( "Nice try.\r\n" );
					else if( fileExists( stringParseInfo->argv[2] ) || renameFile( stringParseInfo->argv[1], stringParseInfo->argv[2] ) ){
						vgaPrintString( "File " );
						vgaPrintString( stringParseInfo->argv[1] );
						vgaPrintString( " could not be renamed to " );
						vgaPrintString( stringParseInfo->argv[2] );
						vgaPrintString( "\r\n" );
					}
					else{
						vgaPrintString( "File " );
						vgaPrintString( stringParseInfo->argv[1] );
						vgaPrintString( " successfully renamed to " );
						vgaPrintString( stringParseInfo->argv[2] );
						vgaPrintString( "\r\n" );
					}
				}
				else{
					vgaPrintString( "File " );
					vgaPrintString( stringParseInfo->argv[1] );
					vgaPrintString( " cannot be found.\r\n" );
				}
			}
			else if( stringEqual( stringParseInfo->argv[0], "DELETE" ) ){
				stringUppercase( stringParseInfo->argv[1] );
				if( fileExists( stringParseInfo->argv[1] ) && stringLength( stringParseInfo->argv[1] ) != 0 ){
					if( stringEqual( stringParseInfo->argv[1], "KERNEL.BIN" ) != 1 ){
						if( removeFile( stringParseInfo->argv[1] ) ){
							vgaPrintString( "File " );
							vgaPrintString( stringParseInfo->argv[1] );
							vgaPrintString( " could not be deleted\r\n" );
						}
						else{
							vgaPrintString( "File " );
							vgaPrintString( stringParseInfo->argv[1] );
							vgaPrintString( " successfully deleted\r\n" );
						}
					}
					else vgaPrintString( "OMG just stop it. I NEED THAT!\r\n\nIT'S NOT FUNNY! ARGH!\r\n\n\n" );
				}
			}
			else if( stringEqual( stringParseInfo->argv[0], "SHUTDOWN" ) )  shutdown();
			else if( stringEqual( stringParseInfo->argv[0], "RESTART" ) )  restart();
			else runApplication( stringParseInfo );
		}
	}
}

void runApplication( parsedString_t* arguments ){
	if( stringEqual( arguments->argv[0], "KERNEL.BIN" ) ) vgaPrintString( "Stop trying to execute KERNEL.BIN! It's NOT FUNNY!\r\n" );
	else if( fileExists( arguments->argv[0] ) ){
		temp = loadFile( arguments->argv[0], 0x8000 );
		vgaPrintString( intToString( temp ) );
		pause(18);
		if( temp != 0 ){
			runMemory( 0x8000, arguments );
		}
		else vgaPrintString( "File did not load correctly into memory.\r\n" );
	}
	else{
		vgaPrintString( "File " );
		vgaPrintString( arguments->argv[0] );
		vgaPrintString( " cannot be found.\r\n" );
	}
	return;
}

unsigned int isInput( char input ){
	if( input == 8 || input == 13 || input == 27 || ( input >= 32 && input <= 126 ) ) return 1;
	else return 0;
}
