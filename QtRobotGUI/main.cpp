// -*- c++ -*-

#include <qapp.h>

#include "PlayField.h"
#include "RobotGame.h"

int
main (int argc, char *argv[])
{
    QApplication app(argc, argv);
    RobotGame game;
    PlayField *playField = game.playField();

    playField->resize(300, 300);
    app.setMainWidget(playField);
    playField->show();

    game.startGame("game", 2);

    return app.exec();
}
