/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * BorderMap.d                                                                *
 * "Stores map tile data for map borders."                                    *
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
module IO.BorderMap;

import pokegba.rom;
import GBAUtils.ISaveable;

import IO.BorderTileData;
import IO.Map;
import IO.MapData;

public class BorderMap : ISaveable
{
    private Map map;
    private MapData mapData;
    private BorderTileData mapTileData;
    public bool isEdited = false;
    
    public this(ROM rom, Map m)
    {
        map = m;
        mapData = map.getMapData();
        mapTileData = new BorderTileData(rom, mapData.borderTilePtr, mapData);
    }
    
    public MapData getMapData()
    {
        return mapData;
    }
    
    public BorderTileData getMapTileData()
    {
        return mapTileData;
    }
    
    public void save()
    {
        mapTileData.save();
    }
}
