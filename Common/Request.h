// -*- objc -*-

#import <Foundation/NSObject.h>

@class LispCoder;

#define REQU_ACCELERATE        1
#define REQU_SCAN              2
#define REQU_FIRE              3
#define REQU_NOP               4

#define REQUEST_LENGTH   (sizeof(int) + 2 * sizeof(double))

@interface Request : NSObject
{
    int type;
    double doubleValue1;
    double doubleValue2;
}

- (id) initWithType: (int) theType;
- (id) initWithType: (int) theType
	doubleValue: (double) theDoubleValue1
	doubleValue: (double) theDoubleValue2;

- (int) type;
- (double) doubleValue1;
- (double) doubleValue2;

@end

#ifdef _ROBOT_SERVER

@class Client;

@interface Request ( ServerAdditions )

- (void) takeOutForClient: (Client*) client;

@end

#endif
