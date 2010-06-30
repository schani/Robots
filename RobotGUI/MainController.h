// -*- objc -*-

#import <AppKit/AppKit.h>

@class RobotGame;

@interface MainController : NSObject
{
    id infoPanel;

    id robot1Color;
    id robot2Color;
    id robot3Color;
    id robot4Color;

    id robot1Damage;
    id robot2Damage;
    id robot3Damage;
    id robot4Damage;

    NSColorWell *robotColors[4];
    NSTextField *robotDamages[4];
}

+ (id) sharedInstance;

- (void) newGame: (id) sender;

- (void) infoPanel: (id) sender;

- (void) updateStatusWithGame: (RobotGame*) game;

@end
