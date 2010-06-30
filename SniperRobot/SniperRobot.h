// -*- objc -*-

#import "Vector.h"
#import "Robot.h"

@interface SniperRobot : Robot
{
    int corner;              /* current corner 0, 1, 2, or 3 */
    Vector2D corners[4];
    double cornerScan[4];
    double sc;               /* current scan start */
}

- (void) run;

- (void) newCorner;
- (double) distanceBetween: (Vector2D) vec1 and: (Vector2D) vec2;
- (double) plotCourseTo: (Vector2D) target;

@end
