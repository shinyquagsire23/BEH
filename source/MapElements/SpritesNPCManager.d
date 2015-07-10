/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * SpritesNPCManager.d                                                        *
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
module MapElements.SpritesNPCManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.SpriteNPC;
import IO.Map;

public class SpritesNPCManager : ISaveable
{
    public SpriteNPC[] mapNPCs;
    private Map loadedMap;
    private uint internalOffset;
    private uint originalSize;
    private GBARom rom;
    
    public this(GBARom rom, Map m, int offset, int count)
    {
        this.rom = rom;
        internalOffset = offset;
        loadedMap = m;
        
        rom.Seek(offset);
        int i = 0;
        mapNPCs.length = 1;
        for (i = 0; i < count; i++)
        {
            mapNPCs ~= new SpriteNPC(rom);
        }
        originalSize = getSize();
    }

    public int[] GetSpriteIndices()
    {
        int i = 0;
        int[] indices = new int[](mapNPCs.length);
        for (i = 0; i < mapNPCs.length; i++)
        {
            indices[i] = mapNPCs[i].hSpriteSet;
        }
        return indices;
    }

    public int getSpriteIndexAt(int x, int y)
    {
        int i = 0;
        for (i = 0; i < mapNPCs.length; i++)
        {
            if (mapNPCs[i].bX == x && mapNPCs[i].bY == y)
            {
                return i;
            }
        }

        return -1;

    }

    public int getSize()
    {
        return cast(uint)mapNPCs.length * SpriteNPC.getSize();
    }
    
    public void add(ubyte x, ubyte y)
    {
        mapNPCs ~= new SpriteNPC(rom, x, y);
    }

    public void remove(int x, int y)
    {
        std.algorithm.remove(mapNPCs, getSpriteIndexAt(x,y));
    }

    public void save()
    {
        rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);

        // TODO make this a setting, ie always repoint vs keep pointers
        int i = getSize();
        if (originalSize < getSize())
        {
            internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());

            if (internalOffset < 0x08000000)
                internalOffset += 0x08000000;
        }

        loadedMap.mapSprites.pNPC = internalOffset;
        loadedMap.mapSprites.bNumNPC = cast(ubyte)mapNPCs.length;

        rom.Seek(internalOffset);
        foreach(SpriteNPC n; mapNPCs)
            n.save();
    }
}
