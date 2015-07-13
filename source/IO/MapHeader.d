/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapHeader.d                                                                *
 * "Stores map header data for reading and writing to ROM."                   *
 *                                                                            *
 *                         This file is part of BEH.                          *
 *                                                                            *
 *       BEH is free software: you can redistribute it and/or modify it       *
 * under the terms of the GNU General Public License as published by the Free *
 *  Software Foundation, either version 3 of the License, or (at your option) *
 *                             any later version.                             *
 *                                                                            *
 *          BEH is distributed in the hope that it will be useful, but        *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *
 *   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licens  *
 *                             for more details.                              *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License along   *
 *      with BEH.  If not, see <http://www.gnu.org/licenses/>.                *
 *****************************************************************************/
module IO.MapHeader;

import pokegba.rom;
import GBAUtils.ISaveable;

public class MapHeader : ISaveable {
    public uint pMap;
    public uint pSprites;
    public uint pScript;
    public uint pConnect;
    public ushort hSong;
    public ushort hMap;
    public ubyte bLabelID;
    public ubyte bFlash;
    public ubyte bWeather;
    public ubyte bType;
    public ubyte bUnused1;
    public ubyte bUnused2;
    public ubyte bLabelToggle;
    public ubyte bUnused3;
    private uint bOffset;
    private ROM rom;
    uint hdrSize;//This is internal and does not go into the ROM
    
    public this(ROM rom, int offset)
    {
        bOffset=offset & 0x1FFFFFF;
        this.rom = rom;
        
        rom.Seek(bOffset);
        pMap = rom.getPointer();
        pSprites =rom.getPointer();
        pScript = rom.getPointer();
        pConnect = rom.getPointer();
        hSong = rom.readHalfword();
        hMap = rom.readHalfword();

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
        rom.writeHalfword(hSong);
        rom.writeHalfword(hMap);

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
