// -*- objc -*-

#import "Robot.h"

@interface CounterRobot : Robot
{
    int lastDir;
}

- (void) run;

- (void) runAway;

@end
