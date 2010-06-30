// -*- objc -*-

#import <stdlib.h>
#import <stdio.h>
#ifdef _NEXT
#import <libc.h>
#endif

#import "CounterRobot.h"

@implementation CounterRobot

- (void) run
{
    int angle,
	range,
	res,
	d;

    res = 1;
    d = [self damage];
    angle = random() % 360;
    while (YES)
    {
	while ((range = [self scanInDirection: angle radius: res]) > 0)
	{
	    if (range > 700)
	    {
		int i;

		[self accelerateWithHeading: angle speedGoal: 50];
		for (i = 0; i < 50; ++i)
		    [self nop];
		[self accelerateWithHeading: angle speedGoal: 0];
		if (d != [self damage])
		{
		    d = [self damage];
		    [self runAway];
		}
		angle -= 3;
	    }
	    else
	    {
		[self fireMissileWithHeading: angle range: range];
		while (![self isLauncherLoaded])
		    [self nop];
		if (d != [self damage])
		{
		    d = [self damage];
		    [self runAway];
		}
		angle -= 15;
	    }
	}
	if (d != [self damage])
	{
	    d = [self damage];
	    [self runAway];
	}

	angle += res;
	angle %= 360;
    }
}

- (void) runAway
{
    int x = [self positionX],
	y = [self positionY];
    int i;

    fprintf(stderr, "ouch! damage = %d\n", [self damage]);

    if (lastDir == 0)
    {
	if (y > 512)
	{
	    lastDir = 1;
	    [self accelerateWithHeading: 270 speedGoal: 100];
	    i = 0;
	    while (y - 100 < [self positionY] && i++ < 100)
		[self nop];
	    [self accelerateWithHeading: 270 speedGoal: 0];
	}
	else
	{
	    lastDir = 1;
	    [self accelerateWithHeading: 90 speedGoal: 100];
	    i = 0;
	    while (y + 100 > [self positionY] && i++ < 100)
		[self nop];
	    [self accelerateWithHeading: 90 speedGoal: 0];
	}
    }
    else
    {
	if (x > 512)
	{
	    lastDir = 0;
	    [self accelerateWithHeading: 180 speedGoal: 100];
	    i = 0;
	    while (x - 100 < [self positionX] && i++ < 100)
		[self nop];
	    [self accelerateWithHeading: 180 speedGoal: 0];
	}
	else
	{
	    lastDir = 0;
	    [self accelerateWithHeading: 0 speedGoal: 100];
	    i = 0;
	    while (x + 100 > [self positionX] && i++ < 100)
		[self nop];
	    [self accelerateWithHeading: 0 speedGoal: 0];
	}
    }
}

@end
