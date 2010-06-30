// -*- c++ -*-

#ifndef __ROBOT_H__
#define __ROBOT_H__

#include "Actor.h"

class Robot : public Actor
{
public:
    Robot (RobotGame &theGame, Vector2D thePosition, Vector2D theSpeed,
	   const QColor &thecolor);

    char* updateWithBlock (char *block);

    void paintWithPainter (QPainter &painter);

    int damage (void);

private:
    int theDamage;
};

#endif
