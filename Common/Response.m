// -*- objc -*-

#ifdef _ROBOT_SERVER
#import "Vector.h"
#import "ServerRobot.h"
#endif

#import "Response.h"

@implementation Response

#ifdef _ROBOT_SERVER

+ (id) responseWithRobot: (Robot*) theRobot
{
    return [[[[self class] alloc] initWithRobot: theRobot] autorelease];
}

+ (id) responseWithRobot: (Robot*) theRobot doubleValue: (double) theDoubleValue
{
    return [[[[self class] alloc] initWithRobot: theRobot doubleValue: theDoubleValue] autorelease];
}

+ (id) responseWithRobot: (Robot*) theRobot
	     doubleValue: (double) theDoubleValue1
	     doubleValue: (double) theDoubleValue2
{
    return [[[[self class] alloc] initWithRobot: theRobot
				  doubleValue: theDoubleValue1
				  doubleValue: theDoubleValue2] autorelease];
}

- (id) initWithRobot: (Robot*) theRobot
{
    [super init];

    robot = [theRobot retain];

    return self;
}

- (id) initWithRobot: (Robot*) theRobot doubleValue: (double) theDoubleValue
{
    [super init];

    doubleValue1 = theDoubleValue;

    robot = [theRobot retain];

    return self;
}

- (id) initWithRobot: (Robot*) theRobot
	 doubleValue: (double) theDoubleValue1
	 doubleValue: (double) theDoubleValue2
{
    [super init];

    doubleValue1 = theDoubleValue1;
    doubleValue2 = theDoubleValue2;

    robot = [theRobot retain];

    return self;
}

- (void) dealloc
{
    [robot release];

    [super dealloc];
}

- (void) writeToBlock: (char*) block
{
    Vector2D position = [robot position],
	speed = [robot speed];

    *(double*)block = doubleValue1;
    block += sizeof(double);

    *(double*)block = doubleValue2;
    block += sizeof(double);

    *(double*)block = position.x;
    block += sizeof(double);

    *(double*)block = position.y;
    block += sizeof(double);

    *(double*)block = Abs2D(&speed) * 100.0;
    block += sizeof(double);

    *(int*)block = [robot damage];
}

#else

- (id) initFromBlock: (char*) block
{
    [super init];

    doubleValue1 = *(double*)block;
    block += sizeof(double);

    doubleValue2 = *(double*)block;
    block += sizeof(double);

    positionX = *(double*)block;
    block += sizeof(double);

    positionY = *(double*)block;
    block += sizeof(double);

    speed = *(double*)block;
    block += sizeof(double);

    damage = *(int*)block;

    return self;
}

#endif

#ifdef _ROBOT_CLIENT

- (double) doubleValue1
{
    return doubleValue1;
}

- (double) doubleValue2
{
    return doubleValue2;
}

- (double) positionX
{
    return positionX;
}

- (double) positionY
{
    return positionY;
}

- (double) speed
{
    return speed;
}

- (int) damage
{
    return damage;
}

#endif

@end
