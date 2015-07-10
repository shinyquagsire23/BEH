module IO.TilesetHeader;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class TilesetHeader : ISaveable 
{
    public byte bCompressed;
    public bool isPrimary;
    public byte b2;
    public byte b3;
    public uint pGFX;
    public uint pPalettes;
    public uint pBlocks;
    public uint pBehavior;
    public uint pAnimation;
    public uint hdrSize;//This is internal and does not go into the ROM
    private int bOffset;
    private GBARom rom;
    
    public this(GBARom rom, int offset)
    {
        this.rom = rom;
        bOffset=offset;
        rom.Seek(bOffset);
        bCompressed=rom.readByte();
        isPrimary=(rom.readByte() == 0);//Reflect this when saving
        b2=rom.readByte();
        b3=rom.readByte();
        
        pGFX = rom.getPointer();
        pPalettes = rom.getPointer();
        pBlocks = rom.getPointer();
        if (DataStore.EngineVersion == 1) 
        {
            pAnimation = rom.getPointer();
            pBehavior = rom.getPointer();
        }
        else 
        {
            pBehavior = rom.getPointer();
            pAnimation = rom.getPointer();
        }
        hdrSize=rom.internalOffset-offset;
        
    }
    
    
    public void save()
    {
        rom.Seek(bOffset);
        rom.writeByte(bCompressed);
        rom.writeByte((isPrimary ? 0x0 : 0x1));
        rom.writeByte(b2);
        rom.writeByte(b3);
        
        rom.writePointer(pGFX);
        rom.writePointer(pPalettes);
        rom.writePointer(pBlocks);
        rom.writePointer(pAnimation);
        rom.writePointer(pBehavior);
    }
}
