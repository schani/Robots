// -*- c++ -*-

#ifndef __ACTOR_H__
#define __ACTOR_H__

#include <qpainter.h>
#include <qcolor.h>

#include "Vector.h"

class RobotGame;

class Actor
{
public:
    Actor (RobotGame &_theGame, Vector2D _thePosition, Vector2D _theSpeed,
	   const QColor &_theColor);

    virtual char* updateWithBlock (char *block);

    virtual void paintWithPainter (QPainter &painter) = 0;

    Vector2D position (void);
    Vector2D speed (void);

    const QColor& color (void);

private:
    RobotGame &theGame;

    Vector2D thePosition;
    Vector2D theSpeed;

    QColor theColor;
};

#endif
