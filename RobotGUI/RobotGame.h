// -*- objc -*-

#import <AppKit/AppKit.h>

@interface RobotGame : NSObject
{
    NSArray *robots;
    NSMutableArray *missiles;

    NSConnection *threadConnection;

    int pipeEnd;
    int childPID;

    id nameTextField;
    id numPopUp;

    id playFieldView;

    int tick;

    int updateSpeed;

    BOOL gameStopped;
}

- (id) init;
- (void) dealloc;

- (void) startGame: (id) sender;
- (void) dontStartGame: (id) sender;
- (void) stopGame: (id) sender;

- (void) startGameWithName: (NSString*) name numberOfRobots: (int) numRobots;

- (int) pipeEnd;

- (NSArray*) robots;
- (NSArray*) actors;

- (NSColor*) colorForRobotWithNumber: (int) number;

- (void) updateWithMessageData: (NSData*) messageData;

- (void) robotGameUpdate;

- (void) cleanUp;

- (void) serverCommunicationThread: (NSArray*) args;

@end
