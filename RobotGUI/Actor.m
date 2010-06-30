// -*- objc -*-

#import "Actor.h"

@implementation Actor

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	      speed: (Vector2D) theSpeed
	      color: (NSColor*) theColor
{
    [super init];

    game = theGame;
    position = thePosition;
    speed = theSpeed;
    color = [theColor retain];

    return self;
}

- (void) dealloc
{
    [color release];

    [super dealloc];
}

- (char*) updateWithBlock: (char*) block
{
    position = *(Vector2D*)block;
    block += sizeof(Vector2D);

    speed = *(Vector2D*)block;
    block += sizeof(Vector2D);

    return block;
}

- (void) drawInView: (PlayFieldView*) view
{
}

- (NSColor*) color
{
    return color;
}

@end
