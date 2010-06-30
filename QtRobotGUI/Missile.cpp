// -*- c++ -*-

#include "Missile.h"

Missile::Missile (RobotGame &theGame, char *block)
    : Actor(theGame, (Vector2D){ 0, 0 }, (Vector2D){ 0, 0 }, blue)
{
}

char*
Missile::updateWithBlock (char *block)
{
    int robotNum;

    robotNum = *(int*)block;
    block += sizeof(int);

    block = Actor::updateWithBlock(block);

    target = *(Vector2D*)block;
    block += sizeof(Vector2D);

    goneOff = *(bool*)block;
    block += sizeof(bool);

    detonationRadius = *(double*)block;
    block += sizeof(double);

    return block;
}

void
Missile::paintWithPainter (QPainter &painter)
{
    painter.setPen(color());

    if (!goneOff)
    {
	Vector2D vector,
	    mySpeed = speed(),
	    myPosition = position();

	MultScalar2D(&vector, 0.5, &mySpeed);
	SubVectors2D(&vector, &myPosition, &vector);

	painter.drawLine((int)(vector.x * 10), (int)(vector.y * 10),
			 (int)(myPosition.x * 10), (int)(myPosition.y * 10));
	painter.drawLine((int)(target.x * 10 - 100), (int)(target.y * 10 - 100),
			 (int)(target.x * 10 + 100), (int)(target.y * 10 + 100));
	painter.drawLine((int)(target.x * 10 + 100), (int)(target.y * 10 - 100),
			 (int)(target.x * 10 - 100), (int)(target.y * 10 + 100));
    }
    else
	painter.drawEllipse((int)(10 * (target.x - detonationRadius)),
			    (int)(10 * (target.y - detonationRadius)),
			    (int)(detonationRadius * 20), (int)(detonationRadius * 20));
}
