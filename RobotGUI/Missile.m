// -*- objc -*-

#import "RobotGame.h"

#import "Missile.h"

@implementation Missile

- (char*) initWithGame: (RobotGame*) theGame fromBlock: (char*) block
{
    Vector2D thePosition = { 0.0, 0.0},
        theSpeed = { 0.0, 0.0 };
    int robotNum;

    robotNum = *(int*)block;
    block += sizeof(int);

    [super initWithGame: theGame
	   position: thePosition
	   speed: theSpeed
	   color: [[[theGame robots] objectAtIndex: robotNum] color]];

    return [self updateWithBlock: block];
}

- (char*) updateWithBlock: (char*) block
{
    block = [super updateWithBlock: block];

    target = *(Vector2D*)block;
    block += sizeof(Vector2D);

    goneOff = *(BOOL*)block;
    block += sizeof(BOOL);

    detonationRadius = *(double*)block;
    block += sizeof(double);

    return block;
}

- (void) drawInView: (PlayFieldView*) view
{
    [color set];

    if (!goneOff)
    {
	Vector2D vector;
	NSBezierPath *path = [NSBezierPath bezierPath];

	MultScalar2D(&vector, 0.5, &speed);
	SubVectors2D(&vector, &position, &vector);

	[path moveToPoint: NSMakePoint (vector.x, vector.y)];
	[path lineToPoint: NSMakePoint (position.x, position.y)];

	[path moveToPoint: NSMakePoint (target.x - 10, target.y - 10)];
	[path lineToPoint: NSMakePoint (target.x + 10, target.y + 10)];
	[path moveToPoint: NSMakePoint (target.x + 10, target.y - 10)];
	[path lineToPoint: NSMakePoint (target.x - 10, target.y + 10)];

	[path stroke];
    }
    else
    {
	[[NSBezierPath bezierPathWithOvalInRect: NSMakeRect (target.x - detonationRadius,
							     target.y - detonationRadius,
							     detonationRadius * 2,
							     detonationRadius * 2)] stroke];
    }
}

@end
