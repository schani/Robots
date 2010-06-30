// -*- c++ -*-

#include <unistd.h>
#include <assert.h>
#include <stdio.h>

#include "Robot.h"

#include "RobotGame.h"

#define MAX_MESSAGE_LENGTH      8192

int
ReadN (int fd, char *buf, int size)
{
    int haveRead = 0;

    while (haveRead < size)
    {
	int result = read(fd, buf + haveRead, size - haveRead);

	if (result <= 0)
	    return result;
	haveRead += result;
    }

    return haveRead;
}

RobotGame::RobotGame (QObject *parent, const char *name)
    : QObject(parent, name),
      socketNotifier(0),
      messageData(0)
{
    missiles.setAutoDelete(TRUE);
    robots.setAutoDelete(TRUE);

    thePlayField = new PlayField(*this);
}

ActorQList
RobotGame::actors (void)
{
    ActorQList theActors;

    for (int i = 0; i < robots.count(); ++i)
	if (robots.at(i)->damage() < 100)
	    theActors.append(robots.at(i));

    for (int i = 0; i < missiles.count(); ++i)
	theActors.append(missiles.at(i));

    return theActors;
}

void
RobotGame::startGame (const QString &_theName, int numRobots)
{
    theName = _theName;

    for (int i = 0; i < numRobots; ++i)
    {
	Vector2D position = { 0, 0 },
	    speed = { 0, 0 };

	robots.append(new Robot(*this, position, speed, blue));
    }

    tick = 0;
    updateSpeed = 5;

    int thePipe[2];

    assert(pipe(thePipe) != -1);
    childPID = fork();
    assert(childPID != -1);
    if (childPID != 0)
    {
	close(thePipe[1]);
	pipeEnd = thePipe[0];
    }
    else
    {
	close(thePipe[0]);
	close(3);
	dup(thePipe[1]);
	close(thePipe[1]);

	QString numString;

	execl("RobotServer", "RobotServer", "--gui", "--name", (const char*)theName,
	      (const char*)(numString.sprintf("%d", numRobots)), 0);
	assert(0);
    }

    socketNotifier = new QSocketNotifier(pipeEnd, QSocketNotifier::Read);
    QObject::connect(socketNotifier, SIGNAL(activated(int)),
		     this, SLOT(messageArrived(int)));
}

void
RobotGame::updateWithMessage (void)
{
    char *block = messageData.data();

    while (missiles.removeFirst())
	;

    for (int i = 0; i < robots.count(); ++i)
	block = robots.at(i)->updateWithBlock(block);

    while (block < messageData.data() + messageData.size())
    {
	Missile *missile = new Missile(*this, block);

	block = missile->updateWithBlock(block);
	missiles.append(missile);
    }

    thePlayField->repaint(FALSE);
}

PlayField*
RobotGame::playField (void)
{
    return thePlayField;
}

void
RobotGame::messageArrived (int)
{
    int length,
	result = ReadN(pipeEnd, (char*)&length, sizeof(int));

    if (result <= 0)
    {
	QObject::disconnect(socketNotifier, SIGNAL(activated(int)),
			    this, SLOT(messageArrived(int)));

	if (tick % updateSpeed != 0)
	    updateWithMessage();
    }
    else
    {
	assert(result == sizeof(int));
	assert(length <= MAX_MESSAGE_LENGTH);

	char *buffer = new char[length];

	result = ReadN(pipeEnd, buffer, length);
	assert(result == length);
	messageData.assign(buffer, length);

	if (++tick % updateSpeed == 0)
	    updateWithMessage();
    }
}
