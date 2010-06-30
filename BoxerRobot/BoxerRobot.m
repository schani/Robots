// -*- objc -*-

#ifdef _NEXT
#import <libc.h>
#endif
#import <stdlib.h>

#import "BoxerRobot.h"

@implementation BoxerRobot

- (void) run
{
    int mode = 0;
    int d;

    [self accelerateWithHeading: 0 speedGoal: 100];

    while(1)
    {
	if([self speed] < 10)    /* in case of collision */
	    if(mode)
	    {
		mode = 0 ;
		[self accelerateWithHeading: 0 speedGoal: 100];
	    }
	    else
	    {
		mode = 1 ;
		[self accelerateWithHeading: 90 speedGoal: 100];
	    }

	if(mode == 0)    /* check mode, for direction to 
			    scan  and to move */
	{
	    if([self positionX] > 880)
	    {
		[self accelerateWithHeading: 0 speedGoal: 0];
		while([self speed] > 49)
		{
		    [self nop];
		    mode = 0 ;
		}
		mode = 1 ;
		[self accelerateWithHeading: 90 speedGoal: 100];
	    }
	    if((d = [self scanInDirection: 90 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 90 range: d] ;
	    if((d = [self scanInDirection: 180 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 180 range: d] ;
	    if((d = [self scanInDirection: 90 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 90 range: d] ;
	    if((d = [self scanInDirection: 0 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 0 range: d] ;
	}

	else if(mode == 1)
	{
	    if([self positionY] > 880)
	    {
		[self accelerateWithHeading: 0 speedGoal: 0] ;
		while([self speed] > 49)
		{
		    [self nop];
		    mode = 1;
		}
		mode = 2 ;
		[self accelerateWithHeading: 180 speedGoal: 100] ;
	    }
	    if((d = [self scanInDirection: 180 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 180 range: d] ;
	    if((d = [self scanInDirection: 270 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 270 range: d] ;
	    if((d = [self scanInDirection: 180 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 180 range: d] ;
	    if((d = [self scanInDirection: 90 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 90 range: d] ;
	}

	else if(mode == 2)
	{
	    if([self positionX] < 120)
	    {
		[self accelerateWithHeading: 0 speedGoal: 0] ;
		while([self speed] > 49)
		{
		    [self nop];
		    mode = 2 ;
		}
		mode = 3 ;
		[self accelerateWithHeading: 270 speedGoal: 100] ;
	    }
	    if((d = [self scanInDirection: 270 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 270 range: d] ;
	    if((d = [self scanInDirection: 0 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 0 range: d] ;
	    if((d = [self scanInDirection: 270 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 270 range: d] ;
	    if((d = [self scanInDirection: 180 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 180 range: d] ;
	}

	else if(mode == 3)
	{
	    if([self positionY] < 120 || random() % 1000 == 37)
	    {
		[self accelerateWithHeading: 0 speedGoal: 0] ;
		while([self speed] > 49)
		{
		    [self nop];
		    mode = 3 ;
		}
		mode = 0 ;
		[self accelerateWithHeading: 0 speedGoal: 100] ;
	    }
	    if((d = [self scanInDirection: 0 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 0 range: d] ;
	    if((d = [self scanInDirection: 90 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 90 range: d] ;
	    if((d = [self scanInDirection: 0 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 0 range: d] ;
	    if((d = [self scanInDirection: 270 radius: 5]) > 41)
		if(d < 701) [self fireMissileWithHeading: 270 range: d] ;
	}
    }
}

@end
