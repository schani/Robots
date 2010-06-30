// -*- objc -*-

#import "Vector.h"
#import "Robot.h"

@interface CornerRobot : Robot
{
    Vector2D corners[4];
}

- (id) initWithConnection: (ServerConnection*) theConnection;

- (void) run;

- (double) headingForTarget: (Vector2D) target;
- (double) headingFromPosition: (Vector2D) position toTarget: (Vector2D) target;
- (double) distanceToTarget: (Vector2D) target;
- (int) nearestCorner;

@end
