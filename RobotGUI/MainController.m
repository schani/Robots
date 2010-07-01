// -*- objc -*-

#import "RobotGame.h"
#import "GUIRobot.h"

#import "MainController.h"

@implementation MainController

+ (id) sharedInstance
{
    return [[NSApplication sharedApplication] delegate];
}

- (void) newGame: (id) sender
{
    [[RobotGame alloc] init];
}

- (void) infoPanel: (id) sender
{
    if (infoPanel == nil)
	[NSBundle loadNibNamed: @"Info.nib" owner: self];

    [infoPanel makeKeyAndOrderFront: nil];
}

- (void) updateStatusWithGame: (RobotGame*) game
{
    NSArray *robots = [game robots];
    int numRobots = [robots count],
	i;

    robotColors[0] = robot1Color;
    robotColors[1] = robot2Color;
    robotColors[2] = robot3Color;
    robotColors[3] = robot4Color;

    robotDamages[0] = robot1Damage;
    robotDamages[1] = robot2Damage;
    robotDamages[2] = robot3Damage;
    robotDamages[3] = robot4Damage;

    if (numRobots > 4)
	numRobots = 4;
    for (i = 0; i < numRobots; ++i)
    {
	Robot *robot = [robots objectAtIndex: i];

	[robotColors[i] setColor: [[robots objectAtIndex: i] color]];

	if ([robot damage] >= 100)
	{
	    [robotDamages[i] setTextColor: [NSColor darkGrayColor]];
	    [robotDamages[i] setStringValue: @"100%"];
	}
	else
	{
	    [robotDamages[i] setTextColor: [NSColor blackColor]];
	    [robotDamages[i] setStringValue: [NSString stringWithFormat: @"%d%%", [robot damage]]];
	}
    }
    for (i = numRobots; i < 4; ++i)
    {
	[robotColors[i] setColor: [NSColor whiteColor]];
	[robotDamages[i] setTextColor: [NSColor darkGrayColor]];
	[robotDamages[i] setStringValue: @"0%"];
    }
}

@end
