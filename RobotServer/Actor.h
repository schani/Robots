// -*- objc -*-

#import <Foundation/NSObject.h>

#import "Vector.h"

@class RobotGame;

@interface Actor : NSObject
{
    RobotGame *game;

    Vector2D position;
    Vector2D speed;
}

- (id) initWithGame: (RobotGame*) theGame
	   position: (Vector2D) thePosition
	      speed: (Vector2D) theSpeed;

- (Vector2D) position;
- (Vector2D) speed;

- (void) tick;

- (char*) writeToBlock: (char*) block;

@end
