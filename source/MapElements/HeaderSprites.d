/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * HeaderSprites.d                                                            *
 * "Stores header data for objects within a map for reading and writing to    *
 *  ROM."                                                                     *
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
module MapElements.HeaderSprites;

import pokegba.rom;

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
    private ROM rom;
    
    public this(ROM rom)
    {
        this(rom,rom.internalOffset);
    }	  
    
    public this(ROM rom, int offset)
    {
        pData = offset;
        this.rom = rom;
        rom.s(offset & 0x1FFFFFF);
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
        rom.s(pData & 0x1FFFFFF);
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
