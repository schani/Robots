// -*- c++ -*-

#ifndef __ROBOT_GAME_H__
#define __ROBOT_GAME_H__

#include <qlist.h>
#include <qsocknot.h>

#include "Actor.h"
#include "Robot.h"
#include "Missile.h"
#include "PlayField.h"

typedef QList<Actor> ActorQList;
typedef QList<Robot> RobotQList;
typedef QList<Missile> MissileQList;

class RobotGame : public QObject
{
    Q_OBJECT

public:
    RobotGame (QObject *parent = 0, const char *name = 0);

    ActorQList actors (void);

    void startGame (const QString &_theName, int numRobots);

    void updateWithMessage (void);

    PlayField* playField (void);

public slots:
    void messageArrived (int);

private:
    MissileQList missiles;
    RobotQList robots;

    QString theName;

    int pipeEnd;
    int childPID;

    int tick;

    int updateSpeed;

    QSocketNotifier *socketNotifier;

    QByteArray messageData;

    PlayField *thePlayField;
};

#endif
