// -*- objc -*-

#import <Foundation/Foundation.h>

#import "ServerRobot.h"
#import "RobotGame.h"
#import "Client.h"

#import "Missile.h"

@implementation Missile

- (id) initWithGame: (RobotGame*) theGame
	      owner: (Robot*) theOwner
	     target: (Vector2D) theTarget
{
    Vector2D way,
	theSpeed,
	thePosition = [theOwner position];

    owner = theOwner;
    target = theTarget;
    MultScalar2D(&theSpeed, 10.0, Unity2D(&theSpeed, SubVectors2D(&way, &theTarget, &thePosition)));

    goneOff = NO;

    [super initWithGame: theGame position: thePosition speed: theSpeed];

    return self;
}

- (void) tick
{
    if (!goneOff)
    {
	Vector2D way;

	if (Abs2D(SubVectors2D(&way, &target, &position)) <= 10.0)
	{
	    NSEnumerator *enumerator;
	    Client *client;

	    enumerator = [[game clients] objectEnumerator];
	    while ((client = [enumerator nextObject]) != nil)
	    {
		Robot *robot = [client robot];
		Vector2D robotPosition = [robot position],
		    way;
		double distance;

		distance = Abs2D(SubVectors2D(&way, &robotPosition, &target));

		if (distance <= 5.0)
		    [robot takeDamage: 10];
		else if (distance <= 20.0)
		    [robot takeDamage: 5];
		else if (distance <= 40.0)
		    [robot takeDamage: 3];
	    }

	    goneOff = YES;
	    detonationRadius = 0.0;
	}

	[super tick];
    }
    else
    {
	detonationRadius += 0.5;
	if (detonationRadius >= 40.0)
	    [game removeActor: self];
    }
}

- (char*) writeToBlock: (char*) block
{
    *(int*)block = [[game robots] indexOfObject: owner];
    block += sizeof(int);

    block = [super writeToBlock: block];

    *(Vector2D*)block = target;
    block += sizeof(Vector2D);

    *(BOOL*)block = goneOff;
    block += sizeof(BOOL);

    *(double*)block = detonationRadius;
    block += sizeof(double);

    return block;
}

@end
