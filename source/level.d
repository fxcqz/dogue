module grids.level;

import std.algorithm;
import std.conv;
import std.random;
import std.stdio;

int hashLevelPosition(Level level, int x, int y) {
    return y * level.width + x;
}

abstract class BaseLevelObject {
    /*
       * Base class for all objects present in the level that should exist in
       * the `world`. E.g. rooms, walls, npcs, etc.
    */
    public int width, height;
    public int x, y;
    // tracks height of object in the world
    public int heightIndex() { return 0; }
    // display char for this object type
    public char gridRepr() { return ' '; }
    // collision by type
    public string typeIdentifier() { return "base_object"; }
    // maps grid position (int) -> bucket position (ulong)
    protected ulong[int] belongsTo;

    this(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public void registerObject(Level level) {
        for(int j = this.y; j < this.height + this.y; ++j) {
            for(int i = this.x; i < this.width + this.x; ++i) {
                int pos = hashLevelPosition(level, i, j);
                if(canFind(level.grid[pos], this)) {
                    // skip if it already exists
                    continue;
                }
                this.belongsTo[pos] = level.grid[pos].length;
                level.grid[pos] ~= this;
            }
        }
    }

    public void deregisterObject(Level level)
    in {
        assert(this.belongsTo.length > 0);
    }
    out {
        assert(this.belongsTo.length == 0);
    }
    body {
        foreach(gridPos, bucketPos; this.belongsTo) {
            level.grid[gridPos] = remove(level.grid[gridPos], bucketPos);
        }
        // refresh belongsTo since all references have been removed
        this.belongsTo = (ulong[int]).init;
    }
}

class Floor : BaseLevelObject {
    override public int heightIndex() { return 1; }
    override public char gridRepr() { return '.'; }

    this(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
}

class Room : BaseLevelObject {
    override public int heightIndex() { return 2; }
    override public char gridRepr() { return '#'; }
    override public string typeIdentifier() { return "room"; }

    this(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
}

class Level {
    int width;
    int height;
    BaseLevelObject[][int] grid;
    Room[] rooms;

    this(int width, int height) {
        this.width = width;
        this.height = height;
        this.rooms = new Room[](0);
        for(int y = 0; y < height; ++y) {
            for(int x = 0; x < width; ++x){
                this.grid[y * width + x] = [new Floor(x, y, 1, 1)];
            }
        }
    }

    void allocateRooms(int attempts = 100) {
        for(int k = 0; k < attempts; ++k) {
            int roomWidth = uniform(5, to!int(this.width * 0.3));
            int x = uniform(0, this.width - roomWidth);
            int roomHeight = uniform(5, to!int(this.height * 0.3));
            int y = uniform(0, this.height - roomHeight);

            bool alloc = true;

            for(int j = y; j < y + roomHeight; ++j) {
                for(int i = x; i < x + roomWidth; ++i) {
                    if(this.grid[j * this.width + i].map!(x=>x.typeIdentifier).uniq.canFind("room")) {
                        alloc = false;
                    }
                }
            }

            if(alloc) {
                Room room = new Room(x, y, roomWidth, roomHeight);
                room.registerObject(this);
                this.rooms ~= room;
            }
        }
    }

    void displayLevel() {
        // dup grid since sort mutates which would make belongsTo offsets
        // inaccurate
        for(int y = 0; y < this.height; ++y) {
            for(int x = 0; x < this.width; ++x) {
                int pos = y * this.width + x;
                auto bucket = this.grid[pos].dup;
                sort!((a, b) => a.heightIndex > b.heightIndex)(bucket);
                write(bucket[0].gridRepr, " ");
            }
            write("\n");
        }
    }
}
