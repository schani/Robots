// -*- objc -*-

#import <AppKit/psops.h>

#import "Robot.h"

@implementation Robot

- (int) damage
{
    return damage;
}

- (char*) updateWithBlock: (char*) block
{
    block = [super updateWithBlock: block];

    damage = *(int*)block;
    block += sizeof(int);

    return block;
}

- (void) drawInView: (PlayFieldView*) view
{
    [color set];
    PSarc(position.x, position.y, 10, 0, 360);
    PSmoveto(position.x, position.y);
    PSlineto(position.x + 50 * speed.x, position.y + 50 * speed.y);
    PSstroke();
}

@end
