// -*- objc -*-

#import <netdb.h>
#import <sys/types.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <sys/un.h>
#import <assert.h>
#import <string.h>
#import <unistd.h>
#ifdef _NEXT
#import <libc.h>
#endif

#import "Request.h"
#import "Response.h"

#import "ServerConnection.h"

#define SERVER_PORT 5678

@implementation ServerConnection

/*"
ServerConnection forms a connection to a robot server which must run on the same machine.
"*/

- (id) initForGameWithName: (NSString*) name
/*"
Initializes the connection and connects to the robot server which hosts a game with the name
name.
"*/
{
    struct sockaddr_un serverAddress;

    socketFD = socket(AF_UNIX, SOCK_STREAM, 0);
    assert(socketFD != -1);

    serverAddress.sun_family = AF_UNIX;
    strcpy(serverAddress.sun_path, [[NSString stringWithFormat: @"/tmp/robots.%@.socket", name] cString]);

    assert(connect(socketFD, (struct sockaddr*)&serverAddress,
		   strlen(serverAddress.sun_path) + sizeof(serverAddress.sun_family)) != -1);

    tick = 0;

    return self;
}

- (void) dealloc
/*"
Frees all memory occupied by the receiver.
"*/
{
    close(socketFD);

    [super dealloc];
}

- (void) writeRequest: (Request*) theRequest
/*"
Sends the request theRequest to the server. You should not invoke this method directly.
"*/
{
    char buffer[REQUEST_LENGTH];
    int written = 0;

    *(int*)buffer = [theRequest type];
    *(double*)(buffer + sizeof(int)) = [theRequest doubleValue1];
    *(double*)(buffer + sizeof(int) + sizeof(double)) = [theRequest doubleValue2];

    while (written < REQUEST_LENGTH)
	written += write(socketFD, buffer + written, REQUEST_LENGTH - written);
}

- (Response*) readResponse
/*"
Reads a response from the server. You should not invoke this method directly.
"*/
{
    char buffer[RESPONSE_LENGTH];
    int haveRead = 0;

    while (haveRead < RESPONSE_LENGTH)
    {
	int result;

	result = read(socketFD, buffer + haveRead, RESPONSE_LENGTH - haveRead);
	if (result <= 0)        // game over or broken pipe
	    exit(0);
	haveRead += result;
    }

    ++tick;

    return [[[Response alloc] initFromBlock: buffer] autorelease];
}

- (int) timeInTicks
/*"
Returns the number of ticks since the begin of the game.
"*/
{
    return tick;
}

@end
