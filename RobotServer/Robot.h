// -*- objc -*-

#import "Actor.h"

@interface Robot : Actor
{
    double heading;
    double speedGoal;

    int damage;

    NSString *name;
}

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	       name: (NSString*) theName;

- (void) accelerateWithHeading: (double) theHeading speedGoal: (double) theSpeedGoal;

- (void) fireMissileWithHeading: (double) theHeading range: (double) theRange;

- (int) damage;
- (void) takeDamage: (int) theDamage;

- (NSString*) name;

- (void) tick;

- (char*) writeToBlock: (char*) block;

@end
