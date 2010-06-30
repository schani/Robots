// -*- objc -*-

#import <math.h>
#import <stdio.h>
#import <Foundation/NSAutoreleasePool.h>

#import "CornerRobot.h"

@implementation CornerRobot

- (id) initWithConnection: (ServerConnection*) theConnection
{
    [super initWithConnection: theConnection];

    corners[0].x = 50; corners[0].y = 50;
    corners[1].x = 50; corners[1].y = 950;
    corners[2].x = 950; corners[2].y = 950;
    corners[3].x = 950; corners[3].y = 50;

    return self;
}

- (void) run
{
    int corner,
	scanDir,
	cornerDir1,
	cornerDir2,
	heading;
    BOOL didSlowDown = NO;

    [self nop];

    corner = [self nearestCorner];

    /*
    [self accelerateWithHeading: [self headingForTarget: corners[corner]] speedGoal: 100];
    while ([self distanceToTarget: corners[corner]] > 70 && [self speed] > 0)
	[self nop];
	*/

    heading = [self headingForTarget: corners[corner]];
    [self accelerateWithHeading: heading speedGoal: 100];

    while (YES)
    {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	cornerDir1 = [self headingForTarget: corners[corner]];
	scanDir = cornerDir1 - 90;
	cornerDir2 = cornerDir1 + 180;

	while ([self distanceToTarget: corners[corner]] > 50 && [self speed] > 0)
	{
	    if (!didSlowDown && [self distanceToTarget: corners[corner]] < 80)
	    {
		[self accelerateWithHeading: heading speedGoal: 49];
		didSlowDown = YES;
	    }

	    if ([self isLauncherLoaded])
	    {
		int range;

		range = [self scanInDirection: scanDir radius: 2];
		if (range > 0 && range <= 700)
		    [self fireMissileWithHeading: scanDir range: range];
		else
		{
		    range = [self scanInDirection: cornerDir2 radius: 10];
		    if (range > 0 && range <= 700)
			[self fireMissileWithHeading: cornerDir2 range: range];
		    else
		    {
			range = [self scanInDirection: cornerDir1 radius: 10];
			if (range > 0 && range <= 700)
			    [self fireMissileWithHeading: cornerDir1 range: range];
		    }
		}
	    }
	    else
		[self nop];
	}

	[self accelerateWithHeading: 0 speedGoal: 0];

	while ([self speed] > 50)
	    [self nop];

	heading = [self headingFromPosition: corners[corner]
			toTarget: corners[(corner + 1) % 4]];
	[self accelerateWithHeading: heading speedGoal: 100];
	didSlowDown = NO;
	corner = (corner + 1) % 4;

	fprintf(stderr, "new corner (%d,%d). speed = %f heading = %d damage = %d\n",
		(int)corners[corner].x, (int)corners[corner].y, 
		[self speed], (int)heading, [self damage]);

	[pool release];
    }
}

- (double) headingForTarget: (Vector2D) target
{
    Vector2D position = { [self positionX], [self positionY] };

    return [self headingFromPosition: position toTarget: target];
}

- (double) headingFromPosition: (Vector2D) position toTarget: (Vector2D) target
{
    Vector2D way,
	polarWay;

    Rectangular2DToPolar(&polarWay, SubVectors2D(&way, &target, &position));

    return polarWay.x * 180 / M_PI;
}

- (double) distanceToTarget: (Vector2D) target
{
    Vector2D position = { [self positionX], [self positionY] },
	way;

    return Abs2D(SubVectors2D(&way, &target, &position));
}

- (int) nearestCorner
{
    double distance = [self distanceToTarget: corners[0]];
    int i,
	corner = 0;

    for (i = 1; i < 4; ++i)
	if ([self distanceToTarget: corners[i]] < distance)
	    corner = i;

    return corner;
}

@end
