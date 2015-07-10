module IO.MapHeader;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class MapHeader : ISaveable {
    public   uint pMap;
    public   uint pSprites;
    public   uint pScript;
    public   uint pConnect;
    public  ushort hSong;
    public  ushort hMap;
    public  ubyte bLabelID;
    public  ubyte bFlash;
    public  ubyte bWeather;
    public  ubyte bType;
    public  ubyte bUnused1;
    public  ubyte bUnused2;
    public  ubyte bLabelToggle;
    public  ubyte bUnused3;
    private uint bOffset;
    private GBARom rom;
    uint hdrSize;//This is internal and does not go into the ROM
    
    public this(GBARom rom, int offset)
    {
        bOffset=offset & 0x1FFFFFF;
        this.rom = rom;
        
        rom.Seek(bOffset);
        pMap = rom.getPointer();
        pSprites =rom.getPointer();
        pScript = rom.getPointer();
        pConnect = rom.getPointer();
        hSong = rom.readWord();
        hMap = rom.readWord();

        bLabelID= rom.readByte();
        bFlash= rom.readByte();
        bWeather= rom.readByte();
        bType= rom.readByte();
        bUnused1= rom.readByte();
        bUnused2= rom.readByte();
        bLabelToggle= rom.readByte();
        bUnused3= rom.readByte();
        hdrSize=rom.internalOffset-bOffset-0x8000000;
    }

    
    public void save()
    {
        rom.Seek(bOffset);
        rom.writePointer(pMap);
        rom.writePointer(pSprites);
        rom.writePointer(pScript);
        rom.writePointer(pConnect);
        rom.writeWord(hSong);
        rom.writeWord(hMap);

        rom.writeByte(bLabelID);
        rom.writeByte(bFlash);
        rom.writeByte(bWeather);
        rom.writeByte(bType);
        rom.writeByte(bUnused1);
        rom.writeByte(bUnused2);
        rom.writeByte(bLabelToggle);
        rom.writeByte(bUnused3);
    }
}
