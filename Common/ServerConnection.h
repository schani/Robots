// -*- objc -*-

#import <Foundation/NSString.h>

@class Request;
@class Response;

@interface ServerConnection : NSObject
{
@private
    int socketFD;

    int tick;
}

/*" Creating and deallocating "*/

- (id) initForGameWithName: (NSString*) name;
- (void) dealloc;

/*" Communicating with the server "*/

- (void) writeRequest: (Request*) theRequest;
- (Response*) readResponse;

/*" Querying attributes "*/

- (int) timeInTicks;

@end
