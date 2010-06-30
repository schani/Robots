// -*- objc -*-

#import <Foundation/NSObject.h>

@class RobotGame;

@interface MainController : NSObject
{
    NSString *gameName;
    NSString *socketName;

    RobotGame *game;

    int socketFD;

    int numRobots;
}

- (id) initWithGameName: (NSString*) theName numberOfRobots: (int) theNumRobots guiMode: (BOOL) guiMode;

- (void) acceptClient;

- (void) mainLoop;

@end
