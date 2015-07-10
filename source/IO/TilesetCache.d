/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * TilesetCache.d                                                             *
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
module IO.TilesetCache;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ROMManager;
import IO.Map;
import IO.Tileset;

public class TilesetCache
{
    private static Tileset[uint] cache;
    private GBARom rom;
    
    private this(){}
    
    public static void contains(int offset)
    {
        
    }
    
    /**
     * Pulls a tileset from the tileset cache. Create a new tileset if one is not cached.
     * @param offset Tileset data offset
     * @return
     */
    public static Tileset get(uint offset)
    {
        if(offset in cache)
        {
            Tileset t = cache[offset];
            if(t.modified)
            {
                t.loadData(offset);
                t.renderTiles(offset);
                t.modified = false;
            }
            return t;
        }
        else
        {
            Tileset t =  new Tileset(ROMManager.getActiveROM(), offset);
            cache[offset] = t;
            return t;
        }
    }

    public static void clearCache()
    {
        foreach(uint t; cache.keys())
            cache.remove(t);
    }

    public static void saveAllTilesets()
    {
        foreach(Tileset t; cache.values())
            t.save();
    }
    
    public static void switchTileset(Map loadedMap)
    {
        get(loadedMap.getMapData().globalTileSetPtr).resetPalettes();
        get(loadedMap.getMapData().localTileSetPtr).resetPalettes();
        for(int j = 1; j < 5; j++)
            for(int i = DataStore.MainTSPalCount-1; i < 13; i++)
                get(loadedMap.getMapData().globalTileSetPtr).getPalette(j-1)[i] = get(loadedMap.getMapData().localTileSetPtr).getROMPalette()[j-1][i];
        for(int j = 0; j < 4; j++)
            get(loadedMap.getMapData().localTileSetPtr).setPalette(get(loadedMap.getMapData().globalTileSetPtr).getPalette(j),j);
        get(loadedMap.getMapData().localTileSetPtr).renderPalettedTiles();
        get(loadedMap.getMapData().globalTileSetPtr).renderPalettedTiles();
        get(loadedMap.getMapData().localTileSetPtr).startTileThreads();
        get(loadedMap.getMapData().globalTileSetPtr).startTileThreads();
    }
}
