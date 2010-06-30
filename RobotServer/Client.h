// -*- objc -*-

#import <Foundation/NSObject.h>

@class Robot;
@class RobotGame;
@class Response;
@class Request;

@interface Client : NSObject
{
    int socketFD;

    RobotGame *game;
    Robot *robot;

    Response *response;
    int tickOfResponse;
}

- (id) initWithGame: (RobotGame*) theGame socketFD: (int) theSocketFD robotName: (NSString*) robotName;
- (void) dealloc;

- (int) socketFD;

- (RobotGame*) game;
- (Robot*) robot;

- (Request*) readRequest;

- (BOOL) haveResponse;
- (void) getResponse: (Response**) theResponse andTick: (int*) theTick;
- (void) setResponse: (Response*) theResponse andTick: (int) theTick;
- (void) writeResponse;

@end
