import std.algorithm: canFind;
import std.random;
import std.stdio;

struct Tile {
    int x;
    int y;
    byte type = 0;

    string toString() {
        if(type == 1) {
            return "#";
        }
        return ".";
    }
}

class Level {
    int width;
    int height;
    Tile[][] grid;

    // only try this many times to allocate non-overlapping room
    int attempts;

    this(int width, int height, int attempts = 1000) {
        this.width = width;
        this.height = height;
        this.attempts = attempts;
        this.grid = new Tile[][](height, width);
    }

    void allocateRoom(byte roomWidth, byte roomHeight) {
        int startx = uniform(0, this.width - roomWidth);
        int starty = uniform(0, this.height - roomHeight);
        // pre-check room is clear
        foreach(ref row; this.grid[starty .. starty + roomHeight]) {
            foreach(ref tile; row[startx .. startx + roomWidth]) {
                if(tile.type == 1) {
                    return;
                }
            }
        }

        // if we get here, the room is safe to alloc!
        foreach(ref row; this.grid[starty .. starty + roomHeight]) {
            foreach(ref tile; row[startx .. startx + roomWidth]) {
                tile.type = 1;
            }
        }
    }

    void allocateRooms() {
        for(int i = 0; i < this.attempts; ++i) {
            allocateRoom(uniform!("[)", byte, byte)(5, 10), uniform!("[)", byte, byte)(5, 10));
        }
    }

    void printLevel() {
        foreach(ref row; this.grid) {
            foreach(ref tile; row) {
                write(" ", tile, " ");
            }
            write("\n");
        }
    }
}

void main()
{
    Level level = new Level(50, 50, 200);
    level.allocateRooms();
    level.printLevel();
}
