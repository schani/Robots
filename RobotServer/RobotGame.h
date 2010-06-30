// -*- objc -*-

#import <Foundation/NSArray.h>

@class Client;
@class Actor;
@class Robot;

@interface RobotGame : NSObject
{
    NSMutableArray *actors;
    NSMutableArray *clients;
    NSMutableArray *robots;

    BOOL gameOver;

    int tick;

    BOOL guiMode;
}

- (id) initWithGuiMode: (BOOL) theGuiMode;
- (void) dealloc;

- (void) addClient: (Client*) theClient;
- (void) removeRobot: (Robot*) theRobot;
- (NSArray*) robots;

- (NSArray*) actors;
- (void) addActor: (Actor*) theActor;
- (void) removeActor: (Actor*) theActor;

- (NSArray*) clients;

- (void) tick;

- (int) timeInTicks;

- (BOOL) isGameOver;

- (void) transferState;

@end
