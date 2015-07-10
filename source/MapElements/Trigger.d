/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Trigger.d                                                                  *
 * "brief description of file"                                                *
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
module MapElements.Trigger;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class Trigger : ISaveable
{
    public ubyte bX;
    public ubyte b2;
    public ubyte bY;
    public ubyte b4;
    public ushort h3;
    public ushort hFlagCheck;
    public ushort hFlagValue;
    public ushort h6;
    public uint pScript;

    private GBARom rom;

    void LoadTriggers(GBARom rom)
    {
        this.rom = rom;

        bX = rom.readByte();
        b2 = rom.readByte();
        bY = rom.readByte();
        b4 = rom.readByte();
        h3 = rom.readWord();
        hFlagCheck = rom.readWord();
        hFlagValue = rom.readWord();
        h6 = rom.readWord();
        pScript = rom.getPointer();
    }

    public this(GBARom rom, uint offset)
    {
        rom.Seek(offset);
        LoadTriggers(rom);
    }

    public this(GBARom rom)
    {
        LoadTriggers(rom);
    }

    public this(GBARom rom, ubyte x, ubyte y)
    {
        this.rom = rom;

        bX = 0;
        b2 = 0;
        bY = 0;
        b4 = 0;
        h3 = 0;
        hFlagCheck = 0;
        hFlagValue = 0;
        h6 = 0;
        pScript = 0;
    }

    public static uint getSize()
    {
        return 16;
    }

    public void save()
    {
        rom.writeByte(bX);
        rom.writeByte(b2);
        rom.writeByte(bY);
        rom.writeByte(b4);
        rom.writeWord(h3);
        rom.writeWord(hFlagCheck);
        rom.writeWord(hFlagValue);
        rom.writeWord(h6);
        rom.writePointer(pScript + (pScript == 0 ? 0 : 0x08000000));
    }
}
