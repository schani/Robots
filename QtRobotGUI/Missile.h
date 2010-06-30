// -*- c++ -*-

#ifndef __MISSILE_H__
#define __MISSILE_H__

#include "Actor.h"

class Missile : public Actor
{
public:
    Missile (RobotGame &theGame, char *block);

    char* updateWithBlock (char *block);

    void paintWithPainter (QPainter &painter);

private:
    Vector2D target;
    bool goneOff;
    double detonationRadius;
};

#endif
