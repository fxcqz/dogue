module grids.main;

import std.stdio;

import grids.level;


void main()
{
    // testing crap
    Level level = new Level(50, 50);
    level.allocateRooms();
    level.displayLevel();
}
