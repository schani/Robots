MOCFILES = PlayField.moc.cpp RobotGame.moc.cpp
CPPSOURCES = Actor.cpp Robot.cpp Missile.cpp RobotGame.cpp PlayField.cpp main.cpp $(MOCFILES)
CSOURCES = Vector.c
OBJECTS = $(CPPSOURCES:.cpp=.o) $(CSOURCES:.c=.o)

CFLAGS = -I/usr/local/qt/include

robotgui : $(OBJECTS)
	gcc -o robotgui $(OBJECTS) -lqt -lm

%.o : %.cpp
	gcc -c $(CFLAGS) $<

%.o : %.c
	gcc -c $(CFLAGS) $<

%.moc.cpp : %.h
	moc -o $@ $<

clean :
	rm -f $(OBJECTS) $(MOCFILES) robotgui
