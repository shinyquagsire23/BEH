/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * TilesetHeader.d                                                            *
 * "Stores tileset header data for reading and writing to ROM."               *
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
module IO.TilesetHeader;

import GBAUtils.DataStore;
import pokegba.rom;
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
    private ROM rom;
    
    public this(ROM rom, int offset)
    {
        this.rom = rom;
        bOffset=offset;
        rom.s(bOffset);
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
        rom.s(bOffset);
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
