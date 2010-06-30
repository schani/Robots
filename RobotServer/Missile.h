// -*- objc -*-

#import "Actor.h"

@class Robot;

@interface Missile : Actor
{
    Robot *owner;
    Vector2D target;
    BOOL goneOff;
    double detonationRadius;
}

- (id) initWithGame: (RobotGame*) theGame
	      owner: (Robot*) theOwner
	     target: (Vector2D) theTarget;

- (void) tick;

- (char*) writeToBlock: (char*) block;

@end
