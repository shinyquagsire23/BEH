module MapElements.SpriteExit;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class SpriteExit : ISaveable 
{
    public ubyte bX;
    public ubyte b2;
    public ubyte bY;
    public ubyte b4;
    public ubyte b5;
    public ubyte b6;
    public ubyte bMap;
    public ubyte bBank;
    private GBARom rom;
    
    public this(GBARom rom)
    {
        this(rom,rom.internalOffset);
    }
    
    public this(GBARom rom, int offset)
    {
        this.rom = rom; 
        rom.Seek(offset);

        bX=rom.readByte();
        b2=rom.readByte();
        bY=rom.readByte();
        b4=rom.readByte();
        b5=rom.readByte();
        b6=rom.readByte();
        bMap=rom.readByte();
        bBank=rom.readByte();
    }
    
    public this(GBARom rom, ubyte x, ubyte y)
    {
        this.rom = rom; 
        
        bX = x;
        bY = y;
        b2 = 0;
        b4 = 0;
        b5 = 0;
        b6 = 0;
        bMap = 0;
        bBank = 0;
    }
    
    public static int getSize()
    {
        return 8;
    }
    
    public void save()
    {
        rom.writeByte(bX);
        rom.writeByte(b2);
        rom.writeByte(bY);
        rom.writeByte(b4);
        rom.writeByte(b5);
        rom.writeByte(b6);
        rom.writeByte(bMap);
        rom.writeByte(bBank);
    }
}
