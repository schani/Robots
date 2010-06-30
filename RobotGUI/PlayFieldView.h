// -*- objc -*-

#import <AppKit/AppKit.h>

@class RobotGame;

@interface PlayFieldView : NSView
{
    RobotGame *game;
}

- (void) dealloc;

- (void) setGame: (RobotGame*) theGame;

- (void) drawRect: (NSRect) rect;

@end
