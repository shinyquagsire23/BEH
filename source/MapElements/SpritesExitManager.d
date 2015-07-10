/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpritesExitManager.d                                                       *
 * "Manages multiple exit objects within a map for reading and writing to     *
 *  ROMs"                                                                     *
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
module MapElements.SpritesExitManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.SpriteExit;
import IO.Map;

public class SpritesExitManager : ISaveable
{
    public SpriteExit[] mapExits;
    private Map loadedMap;
    private uint internalOffset = 0;
    private uint originalSize;
    private GBARom rom;

    public this(GBARom rom, Map m, uint offset, uint count)
    {
        rom.Seek(offset);
        mapExits.length = 1;
        int i = 0;
        for (i = 0; i < count; i++)
        {
            mapExits ~= new SpriteExit(rom);
        }
        originalSize = getSize();
        internalOffset = offset;
        this.rom = rom;
        this.loadedMap = m;
    }

    public int getSpriteIndexAt(ubyte x, ubyte y)
    {
        int i = 0;
        foreach(SpriteExit exit; mapExits)
        {
            if (exit.bX == x && exit.bY == y)
            {
                return i;
            }
            i++;
        }

        return -1;

    }
    
    public int getSize()
    {
        return cast(uint)mapExits.length * SpriteExit.getSize();
    }

    public void add(ubyte x, ubyte y)
    {
        mapExits ~= new SpriteExit(rom, x,y);
    }

    public void remove(ubyte x, ubyte y)
    {
        std.algorithm.remove(mapExits, getSpriteIndexAt(x,y));
    }
    
    public void save()
    {
        rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        int i = getSize();
        if(originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());
            
            if(internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }
        
        loadedMap.mapSprites.pExits = internalOffset & 0x1FFFFFF;
        loadedMap.mapSprites.bNumExits = cast(ubyte)mapExits.length;

        rom.Seek(internalOffset);
        foreach(SpriteExit e; mapExits)
            e.save();
    }
}
