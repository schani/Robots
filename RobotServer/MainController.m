// -*- objc -*-

#import <assert.h>
#import <sys/types.h>
#import <sys/time.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <sys/wait.h>
#import <sys/un.h>
#import <unistd.h>
#import <stdio.h>
#ifdef _NEXT
#import <libc.h>
#endif
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>

#import "RobotGame.h"
#import "Robot.h"
#import "Client.h"

#import "MainController.h"

#define SERVER_PORT 5678

@implementation MainController

- (id) initWithGameName: (NSString*) theName numberOfRobots: (int) theNumRobots guiMode: (BOOL) guiMode
{
    struct sockaddr_un myAddress;

    [super init];

    gameName = [theName copy];
    socketName = [[NSString stringWithFormat: @"/tmp/robots.%@.socket", gameName] retain];

    numRobots = theNumRobots;

    socketFD = socket(AF_UNIX, SOCK_STREAM, 0);
    assert(socketFD != -1);

    myAddress.sun_family = AF_UNIX;
    strcpy(myAddress.sun_path, [socketName cString]);
    assert(bind(socketFD, (struct sockaddr*)&myAddress,
		strlen(myAddress.sun_path) + sizeof(myAddress.sun_family)) != -1);
    assert(listen(socketFD, 8) != -1);

    game = [[RobotGame alloc] initWithGuiMode: guiMode];

    return self;
}

- (void) acceptClient
{
    struct sockaddr_un clientAddress;
    int addressSize = sizeof(clientAddress),
	connectionFD;

    fprintf(stderr, "waiting for client to connect\n");

    connectionFD = accept(socketFD, (struct sockaddr*)&clientAddress, &addressSize);
    assert(connectionFD != -1);

    [game addClient: [[[Client alloc] initWithGame: game
				      socketFD: connectionFD
				      robotName: [NSString stringWithFormat: @"Robot%d",
							   [[game clients] count] + 1]]
			 autorelease]];
}

- (void) mainLoop
{
    int i;

    for (i = 0; i < numRobots; ++i)
	[self acceptClient];

    while (![game isGameOver])
    {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[game tick];

	[pool release];
    }

    close(socketFD);
    unlink([socketName cString]);
}

@end
