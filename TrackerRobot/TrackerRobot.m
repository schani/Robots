// -*- objc -*-

#import <stdio.h>
#import <assert.h>
#import <math.h>

#import "Vector.h"

#import "TrackerRobot.h"

@implementation TrackerRobot

- (void) run
{
    Vector2D firstScanPosition;
    int firstScanTick = 0;
    BOOL hadHim = NO,
	haveFirstScan = NO;
    int scanDir = 0,
	notFound = 0;

    [self nop];

    while (YES)
    {
	double distance;

	scanDir = (scanDir + 1) % 360;
	distance = [self scanInDirection: scanDir radius: 1.0];

	if (distance > 0.0)
	{
	    if (!hadHim)
	    {
		fprintf(stderr, "found foe at %f distance %f\n", (double)scanDir, distance);
		hadHim = YES;
	    }

	    if ([self isLauncherLoaded] && haveFirstScan)
	    {
		Vector2D scanPosition = [self positionForScanAtHeading: scanDir
					      withDistance: distance],
		    robotSpeed,
		    missileTarget,
		    polarMissileTarget,
		    position = { [self positionX], [self positionY] };
		int deltaTick = [self timeInTicks] - firstScanTick;

		SubVectors2D(&robotSpeed, &scanPosition, &firstScanPosition);
		MultScalar2D(&robotSpeed, 1.0 / (double)deltaTick, &robotSpeed);
		missileTarget = [self missileTargetForRobotAtPosition: scanPosition
				      withSpeed: robotSpeed];
		Rectangular2DToPolar(&polarMissileTarget,
				     SubVectors2D(&missileTarget, &missileTarget, &position));

		if (polarMissileTarget.y < 45.0)
		    polarMissileTarget.y = 45.0;

		if (polarMissileTarget.y <= 700.0)
		    [self fireMissileWithHeading: polarMissileTarget.x * 180.0 / M_PI
			  range: polarMissileTarget.y];
	    }

	    haveFirstScan = YES;
	    firstScanTick = [self timeInTicks];
	    firstScanPosition = [self positionForScanAtHeading: scanDir withDistance: distance];

	    [self accelerateWithHeading: scanDir speedGoal: 49];
	    scanDir -= 4;

	    notFound = 0;
	}
	else if (hadHim)
	{
	    if (++notFound > 7)
	    {
		fprintf(stderr, "lost foe\n");
		[self accelerateWithHeading: 0 speedGoal: 0.0];
		hadHim = NO;
		haveFirstScan = NO;
	    }
	}
    }

    /*
	Vector2D target,
	    position,
	    way,
	    polarWay;

	target.x = random() % 1000;
	target.y = random() % 1000;

	[robot getPositionX: &position.x y: &position.y];

	fprintf(stderr, "position: %f,%f  target: %f,%f\n",
		position.x, position.y, target.x ,target.y);

	SubVectors2D(&way, &target, &position);
	Rectangular2DToPolar(&polarWay, &way);

	fprintf(stderr, "heading: %f\n", polarWay.x * 180.0 / M_PI);

	[robot accelerateWithHeading: polarWay.x speedGoal: 100.0];
	[robot fireMissileWithHeading: polarWay.x range: polarWay.y + 1.0];

	do
	{
	    [robot nop];
	    [robot getPositionX: &position.x y: &position.y];
	    SubVectors2D(&way, &target, &position);
	} while (Abs2D(&way) > 10.0);

	[robot accelerateWithHeading: 0.0 speedGoal: 0.0];
	do
	{
	    [robot nop];
	} while ([robot speed] > 1.0);
    }
    */
}

- (Vector2D) positionForScanAtHeading: (double) heading withDistance: (double) distance
{
    Vector2D way,
	polarWay = { heading * M_PI / 180.0, distance },
	result;

    Polar2DToRectangular(&way, &polarWay);
    result.x = [self positionX] + way.x;
    result.y = [self positionY] + way.y;

    return result;
}

- (Vector2D) missileTargetForRobotAtPosition: (Vector2D) robotPosition withSpeed: (Vector2D) robotSpeed
{
    double r0x = robotPosition.x,
	r0y = robotPosition.y,
	rsx = robotSpeed.x,
	rsy = robotSpeed.y,
	m0x = [self positionX],
	m0y = [self positionY],
	t,
	msx,
	msy;
    Vector2D result;

    t = (2*m0x*rsx - 2*r0x*rsx + 2*m0y*rsy - 2*r0y*rsy +
	 sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
	      4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
		 r0y + pow(r0y,2))*
	      (-100 + pow(rsx,2) + pow(rsy,2))))/(2.*(-100 + pow(rsx,2) + 
						      pow(rsy,2)));
    if (t >= 0.0)
    {
	msx = (2*m0y*m0y*rsx + 2*r0y*r0y*rsx + 2*(m0x - r0x)* r0y*rsy -
	       2*m0y*(2*r0y*rsx + (m0x - r0x)*rsy) + 
	       (m0x - r0x)*sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) -
				4*(m0x*m0x + m0y*m0y - 2*m0x*r0x + r0x*r0x - 2*m0y* r0y + r0y*r0y)*
				(-100 + rsx*rsx + rsy*rsy)))
	    / (2.*(m0x*m0x + m0y*m0y - 2*m0x*r0x + r0x*r0x - 2*m0y*r0y + r0y*r0y));
    
	msy = (-2*r0x*r0y*rsx + 2*pow(m0x,2)*rsy + 2*pow(r0x,2)*rsy - 
	       2*m0x*(m0y*rsx - r0y*rsx + 2*r0x*rsy) - 
	       r0y*sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
			4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
			   r0y + pow(r0y,2))*
			(-100 + pow(rsx,2) + pow(rsy,2))) + 
	       m0y*(2*r0x*rsx + sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) -
				     4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*
					m0y*r0y + pow(r0y,2))*
				     (-100 + pow(rsx,2) + pow(rsy,2)))))/
	    (2.*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*r0y + pow(r0y,2)));
    }
    else
    {
	t = -(-2*m0x*rsx + 2*r0x*rsx - 2*m0y*rsy + 2*r0y*rsy + 
	      sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
		   4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
		      r0y + pow(r0y,2))*
		   (-100 + pow(rsx,2) + pow(rsy,2))))/(2.*(-100 + pow(rsx,2) + 
							   pow(rsy,2)));

	msx = (2*pow(m0y,2)*rsx + 2*pow(r0y,2)*rsx + 2*(m0x - r0x)*r0y*
	       rsy - 
	       2*m0y*(2*r0y*rsx + (m0x - r0x)*rsy) + 
	       (-m0x + r0x)*sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
				 4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
				    r0y + pow(r0y,2))*
				 (-100 + pow(rsx,2) + pow(rsy,2))))/
	    (2.*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*r0y + pow(r0y,2)));

	msy = (2*m0y*r0x*rsx - 2*r0x*r0y*rsx + 2*pow(m0x,2)*rsy + 2*pow(
									r0x,2)*rsy - 
	       2*m0x*(m0y*rsx - r0y*rsx + 2*r0x*rsy) - 
	       m0y*sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
			4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
			   r0y + pow(r0y,2))*
			(-100 + pow(rsx,2) + pow(rsy,2))) + 
	       r0y*sqrt(4*pow(m0x*rsx - r0x*rsx + (m0y - r0y)*rsy,2) - 
			4*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*
			   r0y + pow(r0y,2))*
			(-100 + pow(rsx,2) + pow(rsy,2))))/
	    (2.*(pow(m0x,2) + pow(m0y,2) - 2*m0x*r0x + pow(r0x,2) - 2*m0y*r0y + pow(r0y,2)));
    }

    assert(t >= 0.0);

    result.x = m0x + t * msx;
    result.y = m0y + t * msy;

    return result;
}

@end
