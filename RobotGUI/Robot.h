// -*- objc -*-

#import "Actor.h"

@interface Robot : Actor
{
    int damage;
}

- (int) damage;

- (char*) updateWithBlock: (char*) block;

- (void) drawInView: (PlayFieldView*) view;

@end
