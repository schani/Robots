// -*- objc -*-

#import <AppKit/AppKit.h>

#import "Vector.h"

@class PlayFieldView;
@class RobotGame;

@interface Actor : NSObject
{
    RobotGame *game;

    Vector2D position;
    Vector2D speed;

    NSColor *color;
}

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	      speed: (Vector2D) theSpeed
	      color: (NSColor*) theColor;
- (void) dealloc;

- (char*) updateWithBlock: (char*) block;

- (void) drawInView: (PlayFieldView*) view;

- (NSColor*) color;

@end
