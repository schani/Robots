// -*- objc -*-

#import <sys/types.h>
#import <sys/time.h>
#import <unistd.h>
#import <stdio.h>
#import <assert.h>
#import <ctype.h>
#ifdef _NEXT
#import <libc.h>
#endif
#import <Foundation/NSUtilities.h>

#import "Actor.h"
#import "Request.h"
#import "Response.h"
#import "Client.h"
#import "Robot.h"

#import "RobotGame.h"

int
WriteN (int fd, char *buf, int size)
{
    int haveWritten = 0;

    while (haveWritten < size)
    {
	int result = write(fd, buf + haveWritten, size - haveWritten);

	if (result <= 0)
	    return result;
	haveWritten += result;
    }

    return haveWritten;
}

@implementation RobotGame

- (id) initWithGuiMode: (BOOL) theGuiMode
{
    [super init];

    clients = [[NSMutableArray arrayWithCapacity: 4] retain];
    robots = [[NSMutableArray arrayWithCapacity: 4] retain];
    actors = [[NSMutableArray arrayWithCapacity: 8] retain];

    tick = 0;

    gameOver = NO;

    guiMode = theGuiMode;

    return self;
}

- (void) dealloc
{
    [clients release];
    [actors release];
    [robots release];

    [super dealloc];
}

- (void) addClient: (Client*) theClient
{
    [clients addObject: theClient];
    [actors addObject: [theClient robot]];
    [robots addObject: [theClient robot]];
}

- (void) removeRobot: (Robot*) theRobot
{
    NSEnumerator *enumerator = [clients objectEnumerator];
    Client *client;

    [actors removeObject: theRobot];
    
    while ((client = [enumerator nextObject]) != nil)
	if ([client robot] == theRobot)
	{
	    [clients removeObject: client];
	    break;
	}

    if ([clients count] <= 1)
    {
	gameOver = YES;

	if (!guiMode)
	{
	    Robot *winner = [[clients objectAtIndex: 0] robot];

	    fprintf(stderr, "game over after %d ticks\nrobot %s won with %d damage\n",
		    tick, [[winner name] cString], [winner damage]);
	}
    }
}

- (NSArray*) robots
{
    return robots;
}

- (NSArray*) actors
{
    return actors;
}

- (void) addActor: (Actor*) theActor
{
    [actors addObject: theActor];
}

- (void) removeActor: (Actor*) theActor
{
    [actors removeObject: theActor];
}

- (NSArray*) clients
{
    return clients;
}

- (void) tick
{
    NSEnumerator *enumerator;
    Actor *actor;
    Client *client;

    enumerator = [clients objectEnumerator];
    while ((client = [enumerator nextObject]) != nil)
    {
	if ([client haveResponse])
	{
	    Response *response;
	    int tickOfResponse;

	    [client getResponse: &response andTick: &tickOfResponse];

	    if (tickOfResponse == tick)
		[client writeResponse];
	}
    }

    while (YES)
    {
	BOOL anotherLoop = NO;

	enumerator = [clients objectEnumerator];
	while ((client = [enumerator nextObject]) != nil)
	    if (![client haveResponse])
	    {
		while (YES)
		{
		    fd_set readSet;
		    struct timeval timeout;

		    FD_ZERO(&readSet);
		    FD_SET([client socketFD], &readSet);
		    timeout.tv_sec = 0;
		    timeout.tv_usec = 100000;

		    if (select([client socketFD] + 1, &readSet, 0, 0, &timeout) != 1)
		    {
			fprintf(stderr, "client timed out\n");
			break;
		    }
		    else
		    {
			Request *request = [client readRequest];

			[request takeOutForClient: client];
			
			anotherLoop = YES;
			
			break;
		    }
		}
	    }

	if (!anotherLoop)
	    break;
    }

    enumerator = [[NSArray arrayWithArray: actors] objectEnumerator];
    while ((actor = [enumerator nextObject]) != nil)
	[actor tick];

    if (guiMode)
	[self transferState];

    ++tick;
}

- (int) timeInTicks
{
    return tick;
}

- (BOOL) isGameOver
{
    return gameOver;
}

- (void) transferState
{
    char buffer[8192],
	*pointer = buffer;
    int i,
	length;

    for (i = 0; i < [robots count]; ++i)
	pointer = [(Robot*)[robots objectAtIndex: i] writeToBlock: pointer];
    for (i = 0; i < [actors count]; ++i)
	if (![robots containsObject: [actors objectAtIndex: i]])
	    pointer = [(Actor*)[actors objectAtIndex: i] writeToBlock: pointer];

    length = pointer - buffer;

    if (WriteN(3, (char*)&length, sizeof(int)) <= 0)
	gameOver = YES;
    else
	if (WriteN(3, buffer, length) <= 0)
	    gameOver = YES;

    if (gameOver)
	fprintf(stderr, "gui killed game\n");
}

@end
