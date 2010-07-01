// -*- objc -*-

#import <assert.h>
#import <unistd.h>
#import <libc.h>
//#import <mach/cthreads.h>

#import "GUIRobot.h"
#import "Missile.h"
#import "PlayFieldView.h"
#import "MainController.h"

#import "RobotGame.h"

#define MAX_MESSAGE_LENGTH    8192

int
ReadN (int fd, char *buf, int size)
{
    int haveRead = 0;

    while (haveRead < size)
    {
	int result = read(fd, buf + haveRead, size - haveRead);

	if (result <= 0)
	    return result;
	haveRead += result;
    }

    return haveRead;
}

@implementation RobotGame

- (id) init
{
    [super init];

    [NSBundle loadNibNamed: @"NewGame.nib" owner: self];

    return self;
}

/*
- (id) retain
{
    fprintf(stderr, "%p has been retained\n", self);
    return [super retain];
}

- (void) release
{
    fprintf(stderr, "%p has been released\n", self);
    [super release];
}
*/

- (void) dealloc
{
    [robots release];
    [missiles release];
    [threadConnection release];

    fprintf(stderr, "dealloced a game\n");

    [super dealloc];
}

- (void) startGame: (id) sender
{
    [self startGameWithName: [nameTextField stringValue] numberOfRobots: [[numPopUp selectedItem] tag]];
    [[sender window] close];
}

- (void) dontStartGame: (id) sender
{
    [[sender window] close];
    [self autorelease];
}

- (void) startGameWithName: (NSString*) name numberOfRobots: (int) numRobots
{
    Robot *robotObjects[numRobots];
    NSPort *port1,
	*port2;
    NSArray *threadArgs;
    int thePipe[2],
	i;

    for (i = 0; i < numRobots; ++i)
	robotObjects[i] = [[[Robot alloc] initWithGame: self
					  position: (Vector2D){ 0.0, 0.0 }
					  speed: (Vector2D){ 0.0, 0.0 }
					  color: [self colorForRobotWithNumber: i]] autorelease];

    robots = [[NSArray arrayWithObjects: robotObjects count: numRobots] retain];
    missiles = [[NSMutableArray arrayWithCapacity: 8] retain];

    tick = 0;
    updateSpeed = 5;

    gameStopped = NO;

    assert(pipe(thePipe) != -1);
    childPID = fork();
    assert(childPID != -1);
    if (childPID != 0)
    {
	close(thePipe[1]);
	pipeEnd = thePipe[0];
    }
    else
    {
	NSString *executableName;

	close(thePipe[0]);
	close(3);
	dup(thePipe[1]);
	close(thePipe[1]);

	executableName = [[NSBundle mainBundle] pathForResource: @"RobotServer" ofType: nil];
	execl([executableName cString], [executableName cString],
	      "--gui", "--name", [name cString],
	      [[NSString stringWithFormat: @"%d", numRobots] cString], NULL);
	assert(0);
    }

    [NSBundle loadNibNamed: @"PlayField.nib" owner: self];

    port1 = [NSPort port];
    port2 = [NSPort port];
    threadArgs = [NSArray arrayWithObjects: port2, port1, nil];

    threadConnection = [[NSConnection alloc] initWithReceivePort: port1 sendPort: port2];
    [threadConnection setRootObject: self];

    [NSThread detachNewThreadSelector: @selector(serverCommunicationThread:)
	      toTarget: self withObject: threadArgs];
}

- (void) stopGame: (id) sender
{
    gameStopped = YES;
}

- (int) pipeEnd
{
    return pipeEnd;
}

- (NSArray*) robots
{
    return robots;
}

- (NSArray*) actors
{
    NSMutableArray *actors = [NSMutableArray arrayWithCapacity: 16];
    int i;

    for (i = 0; i < [robots count]; ++i)
	if ([[robots objectAtIndex: i] damage] < 100)
	    [actors addObject: [robots objectAtIndex: i]];

    [actors addObjectsFromArray: missiles];

    return actors;
}

- (NSColor*) colorForRobotWithNumber: (int) number
{
    switch (number)
    {
	case 0 :
	    return [NSColor redColor];
	case 1 :
	    return [NSColor blueColor];
	case 2 :
	    return [NSColor greenColor];
	case 3 :
	    return [NSColor blackColor];
    }

    return nil;
}

- (void) updateWithMessageData: (NSData*) messageData
{
    int i;
    char *block;

    if (messageData == nil)
	return;

    block = (char*)[messageData bytes];
    [missiles removeAllObjects];

    for (i = 0; i < [robots count]; ++i)
	block = [[robots objectAtIndex: i] updateWithBlock: block];

    while (block < (char*)[messageData bytes] + [messageData length])
    {
	Missile *missile = [Missile alloc];

	block = [missile initWithGame: self fromBlock: block];
	[missiles addObject: [missile autorelease]];
    }

    [self robotGameUpdate];
}

- (void) robotGameUpdate
{
    [playFieldView setGame: self];
    [playFieldView setNeedsDisplay: YES];
    usleep (10000);
    [[MainController sharedInstance] updateStatusWithGame: self];
}

- (void) cleanUp
{
    fprintf(stderr, "killing server\n");

    assert(close(pipeEnd) != -1);
    [threadConnection autorelease];
    threadConnection = nil;
}

- (void) windowWillClose: (NSNotification*) notification
{
    gameStopped = YES;
    playFieldView = nil;
    [self autorelease];
}

- (void) serverCommunicationThread: (NSArray*) args
{
    NSAutoreleasePool *mainPool = [[NSAutoreleasePool alloc] init];
    NSConnection *serverConnection = [NSConnection
					 connectionWithReceivePort: [args objectAtIndex:0]
					 sendPort: [args objectAtIndex:1]];
    RobotGame *game = (RobotGame*)[serverConnection rootProxy];
    int fd = [game pipeEnd];
    char buffer[MAX_MESSAGE_LENGTH];
    int length;

    //    cthread_set_name(cthread_self(), "server comm");

    while (!gameStopped)
    {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int result;

	result = ReadN(fd, (char*)&length, sizeof(int));
	if (result <= 0)
	{
	    gameStopped = YES;

	    if (tick % updateSpeed != 0)
	    {
		NSData *messageData = [NSData dataWithBytes: buffer length: length];

		[game updateWithMessageData: messageData];
	    }

	    [game updateWithMessageData: nil];
	}
	else
	{
	    //fprintf(stderr, "packet\n");
	    assert(result == sizeof(int));
	    assert(length <= MAX_MESSAGE_LENGTH);

	    result = ReadN(fd, buffer, length);
	    assert(result == length);

	    if (++tick % updateSpeed == 0)
	    {
		NSData *messageData = [NSData dataWithBytes: buffer length: length];

		[game updateWithMessageData: messageData];
	    }
	}

	[pool release];
    }

    [game cleanUp];

    [serverConnection invalidate];

    [mainPool release];

    write(2, "end\n", 4);

    //    [NSThread exit];

    return;
}

@end
