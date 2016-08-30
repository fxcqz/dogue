module grids.level;

import std.algorithm;
import std.stdio;

int hashLevelPosition(ref Level level, int x, int y) {
    return y * level.width + x;
}

abstract class BaseLevelObject {
    public int width, height;
    public int x, y;
    protected int[] belongsTo;

    this(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public void registerObject(ref Level level) {
        for(int j = this.y; j < this.height + this.y; ++j) {
            for(int i = this.x; i < this.width + this.x; ++i) {
                int pos = hashLevelPosition(level, i, j);
                if(canFind(level.grid[pos], this)) {
                    // skip if it already exists
                    continue;
                }
                this.belongsTo ~= pos;
                level.grid[pos] ~= this;
            }
        }
    }

    public void deregisterObject(ref Level level)
    in {
        assert(this.belongsTo.length > 0);
    }
    out {
        assert(this.belongsTo.length == 0);
    }
    body {
        foreach(idx; this.belongsTo) {
            level.grid[idx] = remove(level.grid[idx], countUntil(level.grid[idx], this));
        }
        this.belongsTo = [];
    }
}

class Room : BaseLevelObject {
    this(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
}

class Level {
    int width;
    int height;
    Object[][int] grid;

    this(int width, int height) {
        this.width = width;
        this.height = height;
        for(int y = 0; y < height; ++y) {
            for(int x = 0; x < width; ++x){
                this.grid[y * width + x] = new Object[](0);
            }
        }
    }
}
