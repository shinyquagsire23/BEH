/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * TriggerManager.d                                                           *
 * "Manages multiple script trigger objects within a map for reading and      *
 *  writing to ROMs"                                                          *
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
module MapElements.TriggerManager;

import GBAUtils.DataStore;
import pokegba.rom;
import GBAUtils.ISaveable;
import MapElements.Trigger;
import IO.Map;

public class TriggerManager : ISaveable
{
    public Trigger[] mapTriggers;
    private Map loadedMap;
    private uint internalOffset;
    private uint originalSize;
    private ROM rom;

    public this(ROM rom, Map m, int count)
    {
        LoadTriggers(rom, m, count);

    }

    public this(ROM rom, Map m, int offset, int count)
    {
        rom.s(offset);
        LoadTriggers(rom, m, count);
    }

    public void LoadTriggers(ROM rom, Map m, int count)
    {
        internalOffset = rom.internalOffset;
        mapTriggers.length = 1;
        int i = 0;
        for (i = 0; i < count; i++)
        {
            mapTriggers[i] = new Trigger(rom);
            mapTriggers.length++;
        }
        originalSize = getSize();
        this.rom = rom;
        this.loadedMap = m;
    }

    public int getSpriteIndexAt(ubyte x, ubyte y)
    {
        int i = 0;
        for (i = 0; i < mapTriggers.length; i++)
        {
            if (mapTriggers[i].bX == x && mapTriggers[i].bY == y)
            {
                return i;
            }
        }

        return -1;
    }
    
    public int getSize()
    {
        return cast(uint)mapTriggers.length * Trigger.getSize();
    }

    public void add(ubyte x, ubyte y)
    {
        mapTriggers ~= new Trigger(rom, x, y);
    }

    public void remove(ubyte x, ubyte y)
    {
        std.algorithm.remove(mapTriggers, getSpriteIndexAt(x,y));
    }

    public void save()
    {
        rom.floodBytes(internalOffset, rom.freespaceByte, originalSize);

        // TODO make this a setting, ie always repoint vs keep pointers
        int i = getSize();
        if (originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());

            if (internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }

        loadedMap.mapSprites.pTraps = internalOffset & 0x1FFFFFF;
        loadedMap.mapSprites.bNumTraps = cast(ubyte) mapTriggers.length;

        rom.s(internalOffset);
        foreach(Trigger t; mapTriggers)
            t.save();
    }
}
