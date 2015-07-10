module IO.BorderTileData;

import GBAUtils.DataStore;
import GBAUtils.GBARom;

import IO.MapData;
import Structures.MapTile;

public class BorderTileData
{
    private uint originalPouinter;
    private uint originalSize;
    private uint dataLoc;
    private MapData mData;
    private GBARom rom;
    private MapTile[][] mapTiles;
    
    public this(GBARom rom, uint offset, MapData mData)
    {
        dataLoc = offset;
        this.mData = mData;
        this.rom = rom;
        mapTiles = new MapTile[][](mData.borderWidth, mData.borderHeight);
        for(uint x = 0; x < mData.borderWidth; x++)
        {
            for(uint y = 0; y < mData.borderHeight; y++)
            {
                mapTiles[x][y] = getTile(x,y);
            }
        }
        this.originalPouinter = mData.borderTilePtr;
        this.originalSize = getSize();
    }
    
    public uint getSize()
    {
        return ((mData.borderWidth * mData.borderHeight) * 2);
    }
    
    public MapTile getTile(uint x, uint y)
    {
        if(mapTiles[x][y] !is null)
            return mapTiles[x][y];
        else
        {
            uint index = (y*mData.borderWidth) + x;
            uint raw = rom.readWord(dataLoc + index*2);
            MapTile m = new MapTile(cast(ushort)(raw & 0x3FF),cast(ushort)(raw&0xFC00) >> 10);
            mapTiles[x][y] = m;
            return m;
        }
    }

    
    public MapTile[][] getTiles(uint x, uint y, uint width, uint height)
    {
        MapTile[][] m = new MapTile[][](width, height);
        for(uint i = x; i < x + width; i++)
        {
            for(uint j = y; j < y + width; j++)
            {
                m[i-x][j-y] = getTile(i,j);
            }
        }
        return m;
    }
    
    public void save()
    {
        rom.Seek(dataLoc);
        for(uint x = 0; x < mData.borderWidth; x++)
        {
            for(uint y = 0; y < mData.borderHeight; y++)
            {
                
                //uint index = ((y*mData.borderWidth) + x);
                rom.writeWord(cast(ushort)(mapTiles[y][x].getID() + ((mapTiles[y][x].getMeta() & 0x3F) << 10)));
            }
        }
    }
    
    public void resize(long xSize, long ySize)
    {
        /*MapTile[][] newMapTiles = new MapTile[xSize][ySize];
         mData.borderWidth = xSize;
         mData.borderHeight = ySize;
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
         
         mapTiles = newMapTiles;*/
    }
}
