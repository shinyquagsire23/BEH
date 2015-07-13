/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpriteNPC.d                                                                *
 * "Stores data for NPC objects for reading and writing to ROMs."             *
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
module MapElements.SpriteNPC;

import pokegba.rom;
import GBAUtils.ISaveable;

public class SpriteNPC : ISaveable
{
    public ubyte b1;
    public ushort hSpriteSet;
    public ubyte b4;
    public ubyte bX;
    public ubyte b6;
    public ubyte bY;
    public ubyte b8;
    public ubyte b9;
    public ubyte bBehavior1;
    public ubyte b10;
    public ubyte bBehavior2;
    public ubyte bIsTrainer;
    public ubyte b14;
    public ubyte bTrainerLOS;
    public ubyte b16;
    public uint pScript;
    public ushort hFlag;
    public ubyte b23;
    public ubyte b24;

    // Non struct vars
    private ROM rom;

    public this(ROM rom)
    {
        this(rom, rom.internalOffset);
    }

    public this(ROM rom, uint offset)
    {
        this.rom = rom;
        rom.s(offset);
        b1 = rom.readByte();
        hSpriteSet = rom.readHalfword();
        b4 = rom.readByte();
        bX = rom.readByte();
        b6 = rom.readByte();
        bY = rom.readByte();
        b8 = rom.readByte();
        b9 = rom.readByte();
        bBehavior1 = rom.readByte();
        b10 = rom.readByte();
        bBehavior2 = rom.readByte();
        bIsTrainer = rom.readByte();
        b14 = rom.readByte();
        bTrainerLOS = rom.readByte();
        b16 = rom.readByte();
        pScript = rom.getPointer();
        hFlag = rom.readHalfword();
        b23 = rom.readByte();
        b24 = rom.readByte();
    }
    
    public this(ROM rom, ubyte x, ubyte y)
    {
        this.rom = rom;
        b1 = 0;
        hSpriteSet = 0;
        b4 = 0;
        bX = x;
        b6 = 0;
        bY = y;
        b8 = 0;
        b9 = 0;
        bBehavior1 = 0;
        b10 = 0;
        bBehavior2 = 0;
        bIsTrainer = 0;
        b14 = 0;
        bTrainerLOS = 0;
        b16 = 0;
        pScript = 0;
        hFlag = 0;
        b23 = 0;
        b24 = 0;
    }
    
    public static uint getSize()
    {
        return 24;
    }

    public void save()
    {
        rom.writeByte(b1);
        rom.writeHalfword(hSpriteSet);
        rom.writeByte(b4);
        rom.writeByte(bX);
        rom.writeByte(b6);
        rom.writeByte(bY);
        rom.writeByte(b8);
        rom.writeByte(b9);
        rom.writeByte(bBehavior1);
        rom.writeByte(b10);
        rom.writeByte(bBehavior2);
        rom.writeByte(bIsTrainer);
        rom.writeByte(b14);
        rom.writeByte(bTrainerLOS);
        rom.writeByte(b16);
        rom.writePointer(pScript + (pScript == 0 ? 0 : 0x08000000));
        rom.writeHalfword(hFlag);
        rom.writeByte(b23);
        rom.writeByte(b24);
    }
}
