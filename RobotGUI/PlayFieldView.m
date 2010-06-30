// -*- objc -*-

#import "Actor.h"
#import "RobotGame.h"

#import "PlayFieldView.h"

@implementation PlayFieldView

- (void) dealloc
{
    //    [game release];

    [super dealloc];
}

- (void) setGame: (RobotGame*) theGame
{
    /*
    [game release];

    game = [theGame retain];
    */

    game = theGame;
}

- (void) drawRect: (NSRect) rect
{
    NSRect bounds = [self bounds];
    NSEnumerator *enumerator;
    Actor *actor;

    PSsetgray(1.0);
    PSsetlinewidth(0.0);
    NSRectFill(rect);

    [self scaleUnitSquareToSize: NSMakeSize(bounds.size.width / 1000.0,
					    bounds.size.height / 1000.0)];

    enumerator = [[game actors] objectEnumerator];
    while ((actor = [enumerator nextObject]) != nil)
	[actor drawInView: self];
}

@end
