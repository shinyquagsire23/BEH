module MapElements.SpritesExitManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.SpriteExit;
import IO.Map;

public class SpritesExitManager : ISaveable
{
    public SpriteExit[] mapExits;
    private Map loadedMap;
    private uint internalOffset = 0;
    private uint originalSize;
    private GBARom rom;

    public this(GBARom rom, Map m, uint offset, uint count)
    {
        rom.Seek(offset);
        mapExits.length = 1;
        int i = 0;
        for (i = 0; i < count; i++)
        {
            mapExits ~= new SpriteExit(rom);
        }
        originalSize = getSize();
        internalOffset = offset;
        this.rom = rom;
        this.loadedMap = m;
    }

    public int getSpriteIndexAt(ubyte x, ubyte y)
    {
        int i = 0;
        foreach(SpriteExit exit; mapExits)
        {
            if (exit.bX == x && exit.bY == y)
            {
                return i;
            }
            i++;
        }

        return -1;

    }
    
    public int getSize()
    {
        return cast(uint)mapExits.length * SpriteExit.getSize();
    }

    public void add(ubyte x, ubyte y)
    {
        mapExits ~= new SpriteExit(rom, x,y);
    }

    public void remove(ubyte x, ubyte y)
    {
        std.algorithm.remove(mapExits, getSpriteIndexAt(x,y));
    }
    
    public void save()
    {
        rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        int i = getSize();
        if(originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());
            
            if(internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }
        
        loadedMap.mapSprites.pExits = internalOffset & 0x1FFFFFF;
        loadedMap.mapSprites.bNumExits = cast(ubyte)mapExits.length;

        rom.Seek(internalOffset);
        foreach(SpriteExit e; mapExits)
            e.save();
    }
}
