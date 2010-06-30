// -*- objc -*-

#import <Foundation/NSObject.h>

@class ServerConnection;
@class Response;

@interface Robot : NSObject
{
@private

    ServerConnection *connection;

    double positionX;
    double positionY;
    double speed;
    int damage;

    int tickOfLastMissile;
}

/*" Creating and deallocating "*/

- (id) initWithConnection: (ServerConnection*) theConnection;
- (void) dealloc;

/*" Commanding the robot "*/

- (void) accelerateWithHeading: (double) heading speedGoal: (double) speedGoal;
- (void) fireMissileWithHeading: (double) heading range: (double) radius;
- (double) scanInDirection: (double) heading radius: (double) angle;
- (void) nop;

/*" Querying the robot "*/

- (int) damage;
- (double) speed;
- (double) positionX;
- (double) positionY;
- (void) getPositionX: (double*) x y: (double*) y;
- (int) timeInTicks;

- (BOOL) isLauncherLoaded;

/*" Starting the robot "*/

- (void) run;

@end
