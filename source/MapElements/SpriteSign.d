/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpriteSign.d                                                               *
 * "Stores data for sign objects for reading and writing to ROMs."            *
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
module MapElements.SpriteSign;

import pokegba.rom;
import GBAUtils.ISaveable;

public class SpriteSign : ISaveable
{
    //TODO I'm pretty sure some of these are word values...
    public ubyte bX;
    public ubyte b2;
    public ubyte bY;
    public ubyte b4;
    public ubyte b5;
    public ubyte b6;
    public ubyte b7;
    public ubyte b8;
    public uint pScript;
    private ROM rom;

    public this(ROM rom)
    {
        this(rom, rom.internalOffset);
    }

    public this(ROM rom, int offset)
    {
        this.rom = rom;
        
        rom.Seek(offset);
        bX = rom.readByte();
        b2 = rom.readByte();
        bY = rom.readByte();
        b4 = rom.readByte();
        b5 = rom.readByte();
        b6 = rom.readByte();
        b7 = rom.readByte();
        b8 = rom.readByte();
        pScript = rom.getPointer();
    }

    public this(ROM rom, byte x, byte y)
    {
        this.rom = rom;
        
        bX = x;
        b2 = 0;
        bY = y;
        b4 = 0;
        b5 = 0;
        b6 = 0;
        b7 = 0;
        b8 = 0;
        pScript = 0;
    }
    
    public static int getSize()
    {
        return 12;
    }

    public void save()
    {
        rom.writeByte(bX);
        rom.writeByte(b2);
        rom.writeByte(bY);
        rom.writeByte(b4);
        rom.writeByte(b5);
        rom.writeByte(b6);
        rom.writeByte(b7);
        rom.writeByte(b8);
        rom.writePointer(pScript + (pScript == 0 ? 0 : 0x08000000));
    }
}
