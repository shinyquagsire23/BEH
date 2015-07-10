module IO.Connection;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import Structures.ConnectionType;

public class Connection : ISaveable
{
    private GBARom rom;
    public uint lType, lOffset;
    public ubyte bBank, bMap;
    public ushort wFiller;
    
    public this(GBARom rom)
    {
        this.rom = rom;
        load();
    }
    
    public this(GBARom rom, ConnectionType c, byte bank, byte map)
    {
        this.rom = rom;
        lType = c;
        lOffset = 0;
        bBank = bank;
        bMap = map;
        wFiller = 0;
    }
    
    public void load()
    {
        lType = rom.getPointer(true);
        lOffset = rom.getSignedLong(true);
        bBank = rom.readByte();
        bMap = rom.readByte();
        wFiller = rom.readWord();
    }
    
    public void save()
    {
        rom.writePointer(lType);
        rom.writeSignedPointer(lOffset);
        rom.writeByte(bBank);
        rom.writeByte(bMap);
        rom.writeWord(wFiller);
    }
}
