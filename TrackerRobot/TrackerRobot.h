// -*- objc -*-

#import "Vector.h"

#import "Robot.h"

@interface TrackerRobot : Robot

- (void) run;

- (Vector2D) positionForScanAtHeading: (double) heading withDistance: (double) distance;
- (Vector2D) missileTargetForRobotAtPosition: (Vector2D) robotPosition withSpeed: (Vector2D) robotSpeed;

@end
