/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpritesSignManager.d                                                       *
 * "Manages multiple sign objects within a map for reading and writing to     *
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
module MapElements.SpritesSignManager;

import GBAUtils.DataStore;
import pokegba.rom;
import GBAUtils.ISaveable;
import MapElements.SpriteSign;
import IO.Map;

public class SpritesSignManager : ISaveable
{
    public SpriteSign[] mapSigns;
    private Map loadedMap;
    private uint internalOffset;
    private uint originalSize;
    private ROM rom;

    public this(ROM rom, Map m, uint offset, uint count)
    {
        internalOffset = offset;
        this.rom = rom;
        this.loadedMap = m;
        
        rom.s(offset);
        mapSigns.length = 1;
        int i = 0;
        for (i = 0; i < count; i++)
        {
            mapSigns ~= new SpriteSign(rom);
        }
        originalSize = getSize();
    }

    public int getSpriteIndexAt(uint x, uint y)
    {
        int i = 0;
        foreach(SpriteSign s; mapSigns)
        {
            if (s.bX == x && s.bY == y)
            {
                return i;
            }
            i++;
        }

        return -1;

    }
    
    public int getSize()
    {
        return cast(uint)mapSigns.length * SpriteSign.getSize();
    }
    
    public void add(ubyte x, ubyte y)
    {
        mapSigns ~= new SpriteSign(rom, x, y);
    }
    
    public void remove(uint x, uint y)
    {
        std.algorithm.remove(mapSigns, getSpriteIndexAt(x,y));
    }

    public void save()
    {
        rom.floodBytes(internalOffset, rom.freespaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        if(originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());
            
            if(internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }
        loadedMap.mapSprites.pSigns = internalOffset & 0x1FFFFFF;
        loadedMap.mapSprites.bNumSigns = cast(ubyte)mapSigns.length;

        rom.s(internalOffset);
        foreach(SpriteSign s; mapSigns)
            s.save();
    }
}
