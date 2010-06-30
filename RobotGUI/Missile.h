// -*- objc -*-

#import "Actor.h"

@interface Missile : Actor
{
    Vector2D target;
    BOOL goneOff;
    double detonationRadius;
}

- (char*) initWithGame: (RobotGame*) theGame fromBlock: (char*) block;

- (char*) updateWithBlock: (char*) block;

- (void) drawInView: (PlayFieldView*) view;

@end
