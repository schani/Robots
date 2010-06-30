// -*- objc -*-

#import <math.h>

#import "ServerConnection.h"
#import "Request.h"
#import "Response.h"

#import "Robot.h"

@interface Robot ( Internals )

- (void) updateWithResponse: (Response*) theResponse;

@end

@implementation Robot

/*"
A Robot is a virtual entity which is designed to fight other robots on a battlefield.
The battlefield is 1000x1000 units large and is confined by solid walls. A robot
may move on the battlefield and may fire missiles. To detect other robots it
can scan a portion of the battlefield. 

In order to move, the robot has a built-in engine. By virtue of the -accelerateWithHeading:speedGoal:
method, the engine can be ordered to start accelerating with a specified heading to a specified
speed. Angles are always specified in degrees (0-360). Robot speed is specified in percents of
top speed (0-100).

To detect other robots, a robot can scan from its current position an interval between two angles. The
interval is specified by its center and its radius, i.e. scanning with direction 40 and radius 4 means
scanning the range (36,44). The radius may not be more than 10 degrees. A scan determines the
nearest robot within that range.

Another robot can be damaged by hitting it with a missile. A missile can be fired with a heading and
a range. The missile then travels the specified range with the specified heading, starting from the
position of the robot at the time the missile was fired and detonates after it has traveled the range.
The range cannot be larger than 700 units. A robot standing within 5 units of detonation suffers
10 damage points, a robot within 20 units 5 points and a robot within 40 units of the point of
detonation suffers 3 points damage. A robot that has taken 100 points of damage is destroyed and
therefore removed from the battlefield. Robots cannot be repaired. Damage does not impair robots, i.e.
a robot with 99 damage points performs as well as a robot that has not taken any damage at all.
Hitting a wall takes 2 damage points.

Time is measured in ticks. It takes one tick for a robot at full speed to travel 1 unit. A missile
travels exactly 10 units in one tick. Scanning as well as commencing acceleration takes exactly
one tick. Querying attributes of the robot (speed, position, ...) takes no time. All this means
that time is measured the same way for all robots, regardless of the machine
they run on and independent of the operating systems process management. It also means that
the robot server has to wait for each client for a command for every single tick. This comes down
to the fact that it is useless to let a robot process wait for some time if it wants to perform
no action for one tick. On the contrary, tournament rules specify
that if a robot does not send any command for 10 ms, it is disqualified. In order to do nothing,
the robot has to call -nop, which does exactly this and takes one tick to perform.

To write a robot, it is necessary to subclass Robot and override the method -run.
"*/

- (id) initWithConnection: (ServerConnection*) theConnection
/*"
Initializes the robot for communication with a robot server through theConnection.
"*/
{
    [super init];

    connection = [theConnection retain];

    tickOfLastMissile = -9999;

    [self nop];

    return self;
}

- (void) dealloc
/*"
Releases all memory occupied by the object.
"*/
{
    [connection release];

    [super dealloc];
}

- (void) accelerateWithHeading: (double) heading speedGoal: (double) speedGoal
/*"
Commences acceleration. If the current speed of the robot is less than 50 the heading is changed
to heading. Depending on whether the speedGoal is less or greater than the robot's current speed
the robot either slows down or accelerates. This command takes one tick. Please note that this
does not mean that the robot takes one tick to change heading and/or speed.
"*/
{
    Request *request;

    if (speedGoal < 0.0)
	speedGoal = 0.0;
    else if (speedGoal > 100.0)
	speedGoal = 100.0;

    request = [[[Request alloc] initWithType: REQU_ACCELERATE
				doubleValue: heading * M_PI / 180.0
				doubleValue: speedGoal] autorelease];

    [connection writeRequest: request];
    [self updateWithResponse: [connection readResponse]];
}

- (void) fireMissileWithHeading: (double) heading range: (double) range
/*"
Fires a missile with the heading heading for detonation within range units from the current
position. If the missile launcher is not loaded, this method waits until it is.
"*/
{
    Request *request;

    while (![self isLauncherLoaded])
	[self nop];

    if (range < 1.0)
	range = 1.0;
    else if (range > 700.0)
	range = 700.0;

    tickOfLastMissile = [connection timeInTicks];

    request = [[[Request alloc] initWithType: REQU_FIRE
				doubleValue: heading * M_PI / 180.0
				doubleValue: range] autorelease];
    [connection writeRequest: request];
    [self updateWithResponse: [connection readResponse]];
}

- (double) scanInDirection: (double) heading radius: (double) angle
/*"
Performs a scan in the range (heading-angle,heading+angle). Returns the distance
to the nearest robot within that range or a negative number if there is no robot.
"*/
{
    Request *request = [[[Request alloc] initWithType: REQU_SCAN
					 doubleValue: heading * M_PI / 180.0
					 doubleValue: angle * M_PI / 180.0] autorelease];
    Response *response;

    [connection writeRequest: request];
    response = [connection readResponse];
    [self updateWithResponse: response];

    return [response doubleValue1];
}

- (void) nop
/*"
Waits one tick.
"*/
{
    Request *request = [[[Request alloc] initWithType: REQU_NOP] autorelease];

    [connection writeRequest: request];
    [self updateWithResponse: [connection readResponse]];
}

- (int) damage
/*"
Returns the damage of the robot. This number is always non-negative and less than 100.
"*/
{
    return damage;
}

- (double) speed
/*"
Returns the speed of the robot, which is always non-negative and less or equal 100.
"*/
{
    return speed;
}

- (double) positionX
/*"
Returns the x-coordinate of the current position, which is non-negative and less or equal 1000.
"*/
{
    return positionX;
}

- (double) positionY
/*"
Returns the y-coordinate of the current position, which is non-negative and less or equal 1000.
"*/
{
    return positionY;
}

- (void) getPositionX: (double*) x y: (double*) y
/*"
Returns both coordinates of the current position in x and y.
"*/
{
    *x = positionX;
    *y = positionY;
}

- (int) timeInTicks
/*"
Returns the number of ticks since the game started.
"*/
{
    return [connection timeInTicks];
}

- (BOOL) isLauncherLoaded
/*"
Returns whether the missile launcher is loaded. Reloading the missile launcher takes 50 ticks.
"*/
{
    return tickOfLastMissile + 50 <= [connection timeInTicks];
}

- (void) run
/*"
This method should be overridden by subclasses to provide the behaviour of the robot.
"*/
{
    while (YES)
	[self nop];
}

@end

@implementation Robot ( Internals )

- (void) updateWithResponse: (Response*) theResponse
{
    positionX = [theResponse positionX];
    positionY = [theResponse positionY];
    speed = [theResponse speed];
    damage = [theResponse damage];
}

@end
