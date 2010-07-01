// -*- c++ -*-

#include "Robot.h"

Robot::Robot (RobotGame &theGame, Vector2D thePosition, Vector2D theSpeed,
	      const QColor &theColor)
    : Actor(theGame, thePosition, theSpeed, theColor),
      theDamage(0)
{
}

char*
Robot::updateWithBlock (char *block)
{
    block = Actor::updateWithBlock(block);

    theDamage = *(int*)block;
    block += sizeof(int);

    return block;
}

void
Robot::paintWithPainter (QPainter &painter)
{
    Vector2D myPosition = position(),
	mySpeed = speed();

    painter.setBrush(QBrush());
    painter.setPen(blue);
    painter.drawEllipse(int(10 * (myPosition.x - 10)), int(10 * (myPosition.y - 10)), 200, 200);
    painter.drawLine(int(10 * myPosition.x),
		     int(10 * myPosition.y),
		     int(10 * (myPosition.x + 50 * mySpeed.x)),
		     int(10 * (myPosition.y + 50 * mySpeed.y)));
}

int
Robot::damage (void)
{
    return theDamage;
}
