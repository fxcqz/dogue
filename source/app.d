module grids.main;

import std.stdio;

import grids.level;


void main()
{
    // testing crap
    Level level = new Level(10, 10);
    Room room1 = new Room(5, 5, 2, 2);
    Room room2 = new Room(1, 1, 2, 2);
    room1.registerObject(level);
    room2.registerObject(level);
    writeln(level.grid);
    room1.deregisterObject(level);
    writeln(level.grid);
}
