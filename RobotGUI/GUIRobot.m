// -*- objc -*-

#import "GUIRobot.h"

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
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect (position.x - 10, position.y - 10, 20, 20)];
    [color set];
    [path moveToPoint: NSMakePoint (position.x, position.y)];
    [path lineToPoint: NSMakePoint (position.x + 50 * speed.x, position.y + 50 * speed.y)];
    [path stroke];
}

@end
