// -*- objc -*-

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <stdio.h>

#import "ServerConnection.h"
#import "TrackerRobot.h"

int
main (int argc, const char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString *gameName = @"game";
    ServerConnection *connection;
    Robot *robot;

    if (argc > 2)
    {
	fprintf(stderr, "Usage: %s [<gameName>]\n", argv[0]);
	exit(1);
    }
    else if (argc == 2)
	gameName = [NSString stringWithCString: argv[1]];

    connection = [[ServerConnection alloc] initForGameWithName: gameName];
    robot = [[TrackerRobot alloc] initWithConnection: connection];   // instantiate your robot here

    [robot run];

    [pool release];
    exit(0);
    return 0;
}
