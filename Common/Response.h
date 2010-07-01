// -*- objc -*-

#import <Foundation/NSObject.h>

@class LispCoder;
#ifdef _ROBOT_SERVER
@class Robot;
#endif

#define RESPONSE_LENGTH    (5 * sizeof(double) + sizeof(int))

@interface Response : NSObject
{
    double doubleValue1;
    double doubleValue2;

#ifdef _ROBOT_CLIENT
    double positionX;
    double positionY;
    double speed;
    int damage;
#else
    Robot *robot;
#endif
}

#ifdef _ROBOT_SERVER
+ (id) responseWithRobot: (Robot*) theRobot;
+ (id) responseWithRobot: (Robot*) theRobot doubleValue: (double) theDoubleValue;
+ (id) responseWithRobot: (Robot*) theRobot
	     doubleValue: (double) theDoubleValue1
	     doubleValue: (double) theDoubleValue2;

- (id) initWithRobot: (Robot*) theRobot;
- (id) initWithRobot: (Robot*) theRobot doubleValue: (double) theDoubleValue;
- (id) initWithRobot: (Robot*) theRobot
	 doubleValue: (double) theDoubleValue1
	 doubleValue: (double) theDoubleValue2;
- (void) dealloc;

- (void) writeToBlock: (char*) block;
#else
- (id) initFromBlock: (char*) block;
#endif

#ifdef _ROBOT_CLIENT
- (double) doubleValue1;
- (double) doubleValue2;

- (double) positionX;
- (double) positionY;
- (double) speed;
- (int) damage;
#endif

@end
