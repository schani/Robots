// -*- c++ -*-

#ifndef __PLAY_FIELD_H__
#define __PLAY_FIELD_H__

#include <qwidget.h>

class RobotGame;

class PlayField : public QWidget
{
    Q_OBJECT

public:
    PlayField (RobotGame &theGame, QWidget *parent = 0, const char *name = 0);

protected:
    void paintEvent (QPaintEvent*);

private:
    RobotGame &game;
};

#endif
