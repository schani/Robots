// -*- objc -*-

#import <stdlib.h>
#import <unistd.h>
#ifdef _NEXT
#import <libc.h>
#endif

#import "Vector.h"
#import "Robot.h"
#import "RobotGame.h"
#import "Response.h"
#import "Request.h"

#import "Client.h"

@implementation Client

- (id) initWithGame: (RobotGame*) theGame socketFD: (int) theSocketFD robotName: (NSString*) robotName
{
    Vector2D position = { random() % 1000, random() % 1000 };

    [super init];

    socketFD = theSocketFD;
    
    game = theGame;
    robot = [[Robot alloc] initWithGame: game position: position name: robotName];

    [game addActor: robot];

    response = nil;
    tickOfResponse = 0;

    return self;
}

- (void) dealloc
{
    [robot release];

    close(socketFD);

    [super dealloc];
}

- (int) socketFD
{
    return socketFD;
}

- (RobotGame*) game
{
    return game;
}

- (Robot*) robot
{
    return robot;
}

- (BOOL) haveResponse
{
    return response != nil;
}

- (void) getResponse: (Response**) theResponse andTick: (int*) theTick
{
    *theResponse = response;
    *theTick = tickOfResponse;
}

- (void) setResponse: (Response*) theResponse andTick: (int) theTick
{
    response = [theResponse retain];
    tickOfResponse = theTick;
}

- (Request*) readRequest
{
    char buffer[REQUEST_LENGTH];
    int haveRead = 0;

    while (haveRead < REQUEST_LENGTH)
	haveRead += read(socketFD, buffer + haveRead, REQUEST_LENGTH - haveRead);

    return [[[Request alloc] initWithType: *(int*)buffer
			     doubleValue: *(double*)(buffer + sizeof(int))
			     doubleValue: *(double*)(buffer + sizeof(int) + sizeof(double))]
	       autorelease];
}

- (void) writeResponse
{
    char buffer[RESPONSE_LENGTH];
    int written = 0;

    [response writeToBlock: buffer];

    while (written < RESPONSE_LENGTH)
	written += write(socketFD, buffer + written, RESPONSE_LENGTH - written);

    [response release];
    response = nil;
}

@end
