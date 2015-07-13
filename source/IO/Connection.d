/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Connection.d                                                               *
 * "Stores connection data for reading and writing to ROM."                   *
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
module IO.Connection;

import pokegba.rom;
import GBAUtils.ISaveable;
import Structures.ConnectionType;

public class Connection : ISaveable
{
    private ROM rom;
    public uint lType, lOffset;
    public ubyte bBank, bMap;
    public ushort wFiller;
    
    public this(ROM rom)
    {
        this.rom = rom;
        load();
    }
    
    public this(ROM rom, ConnectionType c, byte bank, byte map)
    {
        this.rom = rom;
        lType = c;
        lOffset = 0;
        bBank = bank;
        bMap = map;
        wFiller = 0;
    }
    
    public void load()
    {
        lType = rom.getPointer(true);
        lOffset = rom.getSignedWord(true);
        bBank = rom.readByte();
        bMap = rom.readByte();
        wFiller = rom.readHalfword();
    }
    
    public void save()
    {
        rom.writePointer(lType);
        rom.writePointer(lOffset);
        rom.writeByte(bBank);
        rom.writeByte(bMap);
        rom.writeHalfword(wFiller);
    }
}
