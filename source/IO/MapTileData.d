module IO.MapTileData;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import Structures.MapTile;
import IO.MapData;

public class MapTileData : ISaveable
{
    private uint originalPointer;
    private uint originalSize;
    private MapData mData;
    private GBARom rom;
    private MapTile[][] mapTiles;
    public this(GBARom rom, MapData mData)
    {
        this.mData = mData;
        this.rom = rom;
        mapTiles = new MapTile[][](mData.mapWidth, mData.mapHeight);
        for(int x = 0; x < mData.mapWidth; x++)
        {
            for(int y = 0; y < mData.mapHeight; y++)
            {
                
                uint index = ((y*mData.mapWidth) + x);
                uint raw = rom.readWord(mData.mapTilesPtr + index*2);
                MapTile m = new MapTile(cast(ushort)(raw & 0x3FF),cast(ushort)((raw&0xFC00) >> 10));
                mapTiles[x][y] = m;
                
            }
        }
        this.originalPointer = mData.mapTilesPtr;
        this.originalSize = getSize();
    }
    
    public MapTile getTile(int x, int y)
    {
        if(x < 0 && y < 0)
            return mapTiles[0][0];
        else if(x < 0)
            return mapTiles[0][y];
        else if(y < 0)
            return mapTiles[x][0];
        
        if(x > mData.mapWidth && y > mData.mapHeight)
            return mapTiles[mData.mapWidth][mData.mapHeight];
        else if(x > mData.mapWidth)
            return mapTiles[mData.mapWidth][y];
        else if(y > mData.mapHeight)
            return mapTiles[x][mData.mapHeight];
        
        return mapTiles[x][y];
    }
    
    public MapTile[][] getTiles(int x, int y, int width, int height)
    {
        MapTile[][] m = new MapTile[][](width, height);
        for(int i = x; i < x + width; i++)
        {
            for(int j = y; j < y + width; j++)
            {
                m[i-x][j-y] = getTile(i,j);
            }
        }
        return m;
    }
    
    public int getSize()
    {
        return  ((mData.mapWidth * mData.mapHeight) * 2);
    }
    
    public void save()
    {
        for(int x = 0; x < mData.mapWidth; x++)
        {
            for(int y = 0; y < mData.mapHeight; y++)
            {
                
                int index =  ((y*mData.mapWidth) + x);
                rom.writeWord(mData.mapTilesPtr + index*2, cast(ushort)(mapTiles[x][y].getID() + ((mapTiles[x][y].getMeta() & 0x3F) << 10)));
            }
        }
    }
    
    public void resize(uint xSize, uint ySize)
    {
        MapTile[][] newMapTiles = new MapTile[][](xSize, ySize);
        mData.mapWidth = xSize;
        mData.mapHeight = ySize;
        rom.floodBytes(originalPointer, rom.freeSpaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        if(originalSize < getSize())
        {
            mData.mapTilesPtr = rom.findFreespace(DataStore.FreespaceStart, getSize());
        }
        
        for(int x = 0; x < xSize; x++)
            for(int y = 0; y < ySize; y++)
        {
            try
            {
                newMapTiles[x][y] = mapTiles[x][y];
            }
            catch(Exception e)
            {
                newMapTiles[x][y] = new MapTile(0,0);
            }
        }
        
        mapTiles = newMapTiles;
    }
}
