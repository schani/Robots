// -*- objc -*-

#import <signal.h>
#import <stdlib.h>
#import <Foundation/Foundation.h>

#import "getopt.h"
#import "MainController.h"

void
usage (void)
{
    printf("Usage: RobotServer [OPTION]... <numRobots>\n");
    exit(0);
}


int
main (int argc, const char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSString *gameName = @"game";
    MainController *controller;
    BOOL guiMode = NO;
    int numRobots;

    while (1)
    {
	static struct option longOptions[] =
	    {
		{ "version", no_argument, 0, 256 },
		{ "help", no_argument, 0, 257 },
		{ "gui", no_argument, 0, 258 },
		{ "name", required_argument, 0, 'n' },
		{ 0, 0, 0, 0 }
	    };

	int option,
	    optionIndex;

	option = getopt_long(argc, argv, "n:", longOptions, &optionIndex);

	if (option == -1)
	    break;

	switch (option)
	{
	    case 'n' :
		gameName = [NSString stringWithCString: optarg];
		break;

	    case 256 :
		printf("ObjCRobots Server 0.0\n");
		exit(0);

	    case 257 :
		usage();
		break;

	    case 258 :
		guiMode = YES;
		break;
	}
    }

    if (optind + 1 != argc)
	usage();

    numRobots = atoi(argv[optind]);
    assert(numRobots >= 2);

    controller = [[[MainController alloc] initWithGameName: gameName numberOfRobots: numRobots
					  guiMode: guiMode] autorelease];

    signal(SIGPIPE, SIG_IGN);

    [controller mainLoop];

    [pool release];
    exit(0);
    return 0;
}
