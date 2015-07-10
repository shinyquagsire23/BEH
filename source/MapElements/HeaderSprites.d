module MapElements.HeaderSprites;

import GBAUtils.GBARom;

public class HeaderSprites 
{
    public ubyte bNumNPC;
    public ubyte bNumExits;
    public ubyte bNumTraps;
    public ubyte bNumSigns;
    public uint pNPC;
    public uint pExits;
    public uint pTraps;
    public uint pSigns;
    private uint pData;
    private GBARom rom;
    
    public this(GBARom rom)
    {
        this(rom,rom.internalOffset);
    }	  
    
    public this(GBARom rom, int offset)
    {
        pData = offset;
        this.rom = rom;
        rom.Seek(offset & 0x1FFFFFF);
        bNumNPC=rom.readByte();
        bNumExits=rom.readByte();
        bNumTraps=rom.readByte();
        bNumSigns=rom.readByte();
        pNPC=rom.getPointer();
        pExits=rom.getPointer();
        pTraps=rom.getPointer();
        pSigns=rom.getPointer();
    }

    public void save()
    {
        rom.Seek(pData & 0x1FFFFFF);
        rom.writeByte(bNumNPC);
        rom.writeByte(bNumExits);
        rom.writeByte(bNumTraps);
        rom.writeByte(bNumSigns);
        
        rom.writePointer(pNPC);
        rom.writePointer(pExits);
        rom.writePointer(pTraps);
        rom.writePointer(pSigns);
    }
}
