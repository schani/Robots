// -*- objc -*-

#import "Actor.h"

@implementation Actor

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	      speed: (Vector2D) theSpeed
{
    [super init];

    game = theGame;
    position = thePosition;
    speed = theSpeed;

    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (Vector2D) position
{
    return position;
}

- (Vector2D) speed
{
    return speed;
}

- (void) tick
{
    AddVectors2D(&position, &position, &speed);
}

- (char*) writeToBlock: (char*) block
{
    *(Vector2D*)block = position;
    block += sizeof(Vector2D);

    *(Vector2D*)block = speed;
    block += sizeof(Vector2D);

    return block;
}

@end
