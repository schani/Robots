// -*- c++ -*-

#include <qpainter.h>
#include <qpixmap.h>
#include <qapp.h>

#include "RobotGame.h"

#include "PlayField.h"

PlayField::PlayField (RobotGame &theGame, QWidget *parent, const char *name)
    : QWidget(parent, name), game(theGame)
{
    setPalette(QPalette(white));
}

void
PlayField::paintEvent (QPaintEvent *)
{
    QPainter p(this);

    QPixmap pixmap(size());

    pixmap.fill(this, 0, 0);

    QPainter painter;

    painter.begin(&pixmap);
    painter.setWindow(0, 0, 10000, 10000);

    for (int i = 0; i < game.actors().count(); ++i)
	game.actors().at(i)->paintWithPainter(painter);

    painter.end();

    p.drawPixmap(0, 0, pixmap);

    QApplication::syncX();
}
