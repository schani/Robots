// -*- c++ -*-

#include "RobotGame.h"

#include "Actor.h"

Actor::Actor (RobotGame &_theGame, Vector2D _thePosition, Vector2D _theSpeed,
	      const QColor &_theColor)
    : theGame(_theGame), thePosition(_thePosition), theSpeed(_theSpeed), theColor(_theColor)
{
}

char*
Actor::updateWithBlock (char *block)
{
    thePosition = *(Vector2D*)block;
    block += sizeof(Vector2D);

    theSpeed = *(Vector2D*)block;
    block += sizeof(Vector2D);

    return block;
}

Vector2D
Actor::position (void)
{
    return thePosition;
}

Vector2D
Actor::speed (void)
{
    return theSpeed;
}

const QColor&
Actor::color (void)
{
    return theColor;
}
