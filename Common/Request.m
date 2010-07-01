// -*- objc -*-

#import <math.h>

#import "Request.h"

@implementation Request

- (id) initWithType: (int) theType
{
    [super init];

    type = theType;

    return self;
}

- (id) initWithType: (int) theType
	doubleValue: (double) theDoubleValue1
	doubleValue: (double) theDoubleValue2
{
    [super init];

    type = theType;
    doubleValue1 = theDoubleValue1;
    doubleValue2 = theDoubleValue2;

    return self;
}

- (int) type
{
    return type;
}

- (double) doubleValue1
{
    return doubleValue1;
}

- (double) doubleValue2
{
    return doubleValue2;
}

@end

#ifdef _ROBOT_SERVER

#import <Foundation/Foundation.h>

#import "Vector.h"
#import "ServerRobot.h"
#import "RobotGame.h"
#import "Client.h"
#import "Response.h"

static BOOL
AngleBetween (double angle, double angle1, double angle2)
{
    while (angle < 0.0)
	angle += 2 * M_PI;
    while (angle1 < 0.0)
	angle1 += 2 * M_PI;
    while (angle2 < 0.0)
	angle2 += 2 * M_PI;

    angle = fmod(angle, 2 * M_PI);
    angle1 = fmod(angle1, 2 * M_PI);
    angle2 = fmod(angle2, 2 * M_PI);

    if (angle1 <= angle2)
    {
	if (angle >= angle1 && angle <= angle2)
	    return YES;
	else
	    return NO;
    }
    else
    {
	if (angle >= angle1 || angle <= angle2)
	    return YES;
	else
	    return NO;
    }

    return NO;
}

@implementation Request ( ServerAdditions )

- (void) takeOutForClient: (Client*) client
{
    RobotGame *game = [client game];

    switch (type)
    {
	case REQU_ACCELERATE :
	    [[client robot] accelerateWithHeading: doubleValue1 speedGoal: doubleValue2];
	    [client setResponse: [Response responseWithRobot: [client robot]]
		    andTick: [game timeInTicks] + 1];
	    break;

	case REQU_SCAN :
	    {
		Vector2D here = [[client robot] position];
		NSEnumerator *enumerator = [[game clients] objectEnumerator];
		Client *aClient;
		double nearest = 9999.0;

		while ((aClient = [enumerator nextObject]) != nil)
		{
		    Vector2D position,
			way,
			polarWay;

		    if (aClient == client)
			continue;

		    position = [[aClient robot] position];
		    Rectangular2DToPolar(&polarWay, SubVectors2D(&way, &position, &here));
		    if (AngleBetween(polarWay.x,
				     doubleValue1 - doubleValue2,
				     doubleValue1 + doubleValue2)
			&& polarWay.y < nearest)
			nearest = polarWay.y;
		}

		if (nearest > 2000.0 || nearest < 0.0)
		    nearest = -1.0;

		[client setResponse: [Response responseWithRobot: [client robot]
					       doubleValue: nearest]
			andTick: [game timeInTicks] + 1];
	    }
	    break;

	case REQU_FIRE :
	    [[client robot] fireMissileWithHeading: doubleValue1 range: doubleValue2];
	    [client setResponse: [Response responseWithRobot: [client robot]]
		    andTick: [game timeInTicks] + 1];
	    break;

	case REQU_NOP :
	    [client setResponse: [Response responseWithRobot: [client robot]]
		    andTick: [game timeInTicks] + 1];
	    break;
    }
}

@end

#endif
