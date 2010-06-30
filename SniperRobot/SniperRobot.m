// -*- objc -*-

#import <math.h>
#import <libc.h>

#import "Vector.h"

#import "SniperRobot.h"

/* sniper */
/* strategy: since a scan of the entire battlefield can be done in 90 */
/* degrees from a corner, sniper can scan the field quickly. */

@implementation SniperRobot

- (void) run
{
    double closest;        /* check for targets in range */
    double range;          /* range to target */
    double dir;            /* scan direction */
    int d;                 /* last damage check */

    /* initialize the corner info */
    /* x and y location of a corner, and starting scan degree */
    corners[0] = MakeVector2D(20, 20); cornerScan[0] = 0;
    corners[1] = MakeVector2D(20, 980); cornerScan[1] = 270;
    corners[2] = MakeVector2D(980, 980); cornerScan[2] = 180;
    corners[3] = MakeVector2D(980, 20); cornerScan[3] = 90;

    closest = 9999;
    [self newCorner];       /* start at a random corner */
    d = [self damage];      /* get current damage */
    dir = sc;               /* starting scan direction */

    while (1)
    {
	while (dir < sc + 90) {  /* scan through 90 degree range */
	    range = [self scanInDirection: dir radius: 1];   /* look at a direction */
	    if (range <= 700 && range > 0) {
		while (range > 0) {    /* keep firing while in range */
		    closest = range;     /* set closest flag */
		    [self fireMissileWithHeading: dir range: range];   /* fire! */
		    range = [self scanInDirection: dir radius: 1]; /* check target again */
		    if (d + 15 < [self damage])  /* sustained several hits, */
			range = 0;            /* goto new corner */
		}
		dir -= 10;             /* back up scan, in case */
	    }

	    dir += 2;                /* increment scan */
	    if (d != [self damage]) {     /* check for damage incurred */
		[self newCorner];           /* we're hit, move now */
		d = [self damage];
		dir = sc;
	    }
	}

	if (closest == 9999) {       /* check for any targets in range */
	    [self newCorner];           /* nothing, move to new corner */
	    d = [self damage];
	    dir = sc;
	} else                      /* targets in range, resume */
	    dir = sc;
	closest = 9999;
    }
}

/* new corner function to move to a different corner */
- (void) newCorner
{
    Vector2D target;
    double angle;
    int new;

    new = random() % 4;           /* pick a random corner */
    if (new == corner)       /* but make it different than the */
	corner = (new + 1) % 4;/* current corner */
    else
	corner = new;

    target = corners[corner];
    sc = cornerScan[corner];

    /* find the heading we need to get to the desired corner */
    angle = [self plotCourseTo: target];

    /* start drive train, full speed */
    [self accelerateWithHeading: angle speedGoal: 100];

    /* keep traveling until we are within 100 meters */
    /* speed is checked in case we run into wall, other robot */
    /* not terribly great, since were are doing nothing while moving */

    while ([self distanceBetween: MakeVector2D([self positionX], [self positionY])
		 and: target] > 130
	   && [self speed] > 0)
	[self nop];

    /* cut speed, and creep the rest of the way */

    [self accelerateWithHeading: angle speedGoal: 20];
    while ([self distanceBetween: MakeVector2D([self positionX], [self positionY])
		 and: target] > 40
	   && [self speed] > 0)
	[self nop];

    /* stop drive, should coast in the rest of the way */
    [self accelerateWithHeading: angle speedGoal: 0];
}

/* classical pythagorean distance formula */
- (double) distanceBetween: (Vector2D) vec1 and: (Vector2D) vec2
{
    Vector2D way;

    return Abs2D(SubVectors2D(&way, &vec1, &vec2));
}

/* plot course function, return degree heading to */
/* reach destination x, y; uses atan() trig function */

- (double) plotCourseTo: (Vector2D) target
{
    Vector2D position = MakeVector2D([self positionX], [self positionY]);
    Vector2D way,
	polarWay;

    Rectangular2DToPolar(&polarWay, SubVectors2D(&way, &target, &position));

    return polarWay.x * 180 / M_PI;
}

@end
