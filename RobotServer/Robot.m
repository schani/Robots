// -*- objc -*-

#import <math.h>
#import <stdio.h>
#import <Foundation/NSString.h>

#import "Missile.h"
#import "RobotGame.h"

#import "Robot.h"

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

@implementation Robot

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	       name: (NSString*) theName;
{
    [super initWithGame: theGame position: thePosition speed: MakeVector2D(0.0, 0.0)];

    heading = 0.0;
    speedGoal = 0.0;

    name = [theName copy];

    return self;
}

- (void) dealloc
{
    [name release];

    [super dealloc];
}

- (void) accelerateWithHeading: (double) theHeading speedGoal: (double) theSpeedGoal
{
    if (Abs2D(&speed) <= 0.5 || AngleBetween(theHeading, heading - 0.002, heading + 0.002))
	heading = theHeading;

    speedGoal = theSpeedGoal / 100.0;
    if (speedGoal < 0.0)
	speedGoal = 0.0;
    else if (speedGoal > 100.0 / 100.0)
	speedGoal = 100.0 / 100.0;
}

- (void) fireMissileWithHeading: (double) theHeading range: (double) theRange
{
    Vector2D polarTarget = { theHeading, theRange },
	target;
    Missile *missile;

    Polar2DToRectangular(&target, &polarTarget);
    AddVectors2D(&target, &target, &position);

    missile = [[[Missile alloc] initWithGame: game owner: self target: target] autorelease];
    [game addActor: missile];
}

- (int) damage
{
    return damage;
}

- (void) takeDamage: (int) theDamage
{
    damage += theDamage;
    if (damage >= 100)
	[game removeRobot: self];
}

- (NSString*) name
{
    return name;
}

- (void) tick
{
    double absoluteSpeed;
    BOOL speedUp;
    Vector2D acceleration,
	polarSpeed;
    BOOL standStill = NO;

    [super tick];

    if (position.x < 1.0)
    {
	position.x = 1.0;
	standStill = YES;
    }
    else if (position.x > 999.0)
    {
	position.x = 999.0;
	standStill = YES;
    }
    if (position.y < 1.0)
    {
	position.y = 1.0;
	standStill = YES;
    }
    else if (position.y > 999.0)
    {
	position.y = 999.0;
	standStill = YES;
    }
    if (standStill)
    {
	speed.x = 0.0;
	speed.y = 0.0;
	speedGoal = 0.0;
	[self takeDamage: 2];
    }

    Rectangular2DToPolar(&polarSpeed, &speed);
    if (speedGoal + 0.1 / 100.0 >= polarSpeed.y
	&& speedGoal - 0.1 / 100.0 <= polarSpeed.y
	&& AngleBetween(polarSpeed.x, heading - 0.002, heading + 0.002))
	return;
    else if (speedGoal + 0.1 / 100.0 >= polarSpeed.y)
	speedUp = YES;
    else
	speedUp = NO;

    if (speedUp)
    {
	Vector2D polarAcceleration = { heading, 1.0 / 100.0 };

	Polar2DToRectangular(&acceleration, &polarAcceleration);
    }
    else
    {
	acceleration.x = 0.0;
	acceleration.y = 0.0;
    }

    MultScalar2D(&speed, 0.99, &speed);
    AddVectors2D(&speed, &speed, &acceleration);

    absoluteSpeed = Abs2D(&speed);
    if ((speedUp && absoluteSpeed > speedGoal) || (!speedUp && absoluteSpeed < speedGoal))
    {
	Rectangular2DToPolar(&polarSpeed, &speed);
	polarSpeed.y = speedGoal;
	Polar2DToRectangular(&speed, &polarSpeed);
    }
}

- (char*) writeToBlock: (char*) block
{
    block = [super writeToBlock: block];

    *(int*)block = damage;
    block += sizeof(int);

    return block;
}

@end
