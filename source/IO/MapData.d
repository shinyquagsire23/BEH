/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapData.d                                                                  *
 * "Stores map tile data for maps."                                           *
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
module IO.MapData;

import GBAUtils.DataStore;
import pokegba.rom;
import GBAUtils.ISaveable;
import IO.MapHeader;

public class MapData : ISaveable
{
    private ROM rom;
    private MapHeader mapHeader;
    public uint mapWidth, mapHeight;
    public uint borderTilePtr, mapTilesPtr, globalTileSetPtr, localTileSetPtr;
    public ushort borderWidth, borderHeight;
    public uint secondarySize;
    
    public this(ROM rom, MapHeader mHeader)
    {
        this.rom = rom;
        mapHeader = mHeader;
        load();
    }
    
    public void load()
    {
        rom.s(mapHeader.pMap);
        mapWidth = rom.getPointer(true);
        mapHeight = rom.getPointer(true);
        borderTilePtr = rom.getPointer();
        mapTilesPtr = rom.getPointer();
        globalTileSetPtr = rom.getPointer();
        localTileSetPtr = rom.getPointer();
        borderWidth = rom.readHalfword();
        borderHeight = rom.readHalfword();
        secondarySize = borderWidth + 0xA0;
        //System.out.println(borderWidth + " " + borderHeight);
        if(DataStore.EngineVersion==0) //If this is a RSE game...
        {
            borderWidth = 2;
            borderHeight = 2;
            DataStore.LocalTSBlocks = secondarySize;
        }
        else
        {
            secondarySize = DataStore.LocalTSSize;
        }
    }
    
    
    public void save()
    {
        rom.s(mapHeader.pMap);
        rom.writePointer(mapWidth);
        rom.writePointer(mapHeight);
        rom.writePointer(borderTilePtr);
        rom.writePointer(mapTilesPtr);
        rom.writePointer(globalTileSetPtr);
        rom.writePointer(localTileSetPtr);
        rom.writeHalfword(borderWidth);
        rom.writeHalfword(borderHeight);
    }
}
