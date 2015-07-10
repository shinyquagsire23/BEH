module MapElements.SpritesSignManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.SpriteSign;
import IO.Map;

public class SpritesSignManager : ISaveable
{
    public SpriteSign[] mapSigns;
    private uint internalOffset;
    private uint originalSize;
    private Map loadedMap;
    private GBARom rom;

    public this(GBARom rom, Map m, uint offset, uint count)
    {
        internalOffset = offset;
        this.rom = rom;
        this.loadedMap = m;
        
        rom.Seek(offset);
        mapSigns.length = 1;
        int i = 0;
        for (i = 0; i < count; i++)
        {
            mapSigns ~= new SpriteSign(rom);
        }
        originalSize = getSize();
    }

    public int getSpriteIndexAt(uint x, uint y)
    {
        int i = 0;
        foreach(SpriteSign s; mapSigns)
        {
            if (s.bX == x && s.bY == y)
            {
                return i;
            }
            i++;
        }

        return -1;

    }
    
    public int getSize()
    {
        return cast(uint)mapSigns.length * SpriteSign.getSize();
    }
    
    public void add(ubyte x, ubyte y)
    {
        mapSigns ~= new SpriteSign(rom, x, y);
    }
    
    public void remove(uint x, uint y)
    {
        std.algorithm.remove(mapSigns, getSpriteIndexAt(x,y));
    }

    public void save()
    {
        rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        if(originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());
            
            if(internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }
        loadedMap.mapSprites.pSigns = internalOffset & 0x1FFFFFF;
        loadedMap.mapSprites.bNumSigns = cast(ubyte)mapSigns.length;

        rom.Seek(internalOffset);
        foreach(SpriteSign s; mapSigns)
            s.save();
    }
}
