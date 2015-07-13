/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpriteExit.d                                                               *
 * "Stores data for exit objects for reading and writing to ROMs."            *
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
module MapElements.SpriteExit;

import pokegba.rom;
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
    private ROM rom;
    
    public this(ROM rom)
    {
        this(rom,rom.internalOffset);
    }
    
    public this(ROM rom, int offset)
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
    
    public this(ROM rom, ubyte x, ubyte y)
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
