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
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import IO.MapHeader;

public class MapData : ISaveable
{
    private GBARom rom;
    private MapHeader mapHeader;
    public uint mapWidth, mapHeight;
    public uint borderTilePtr, mapTilesPtr, globalTileSetPtr, localTileSetPtr;
    public ushort borderWidth, borderHeight;
    public uint secondarySize;
    
    public this(GBARom rom, MapHeader mHeader)
    {
        this.rom = rom;
        mapHeader = mHeader;
        load();
    }
    
    public void load()
    {
        mapWidth = rom.getPointer(mapHeader.pMap,true);
        mapHeight = rom.getPointer(mapHeader.pMap+0x4,true);
        borderTilePtr = rom.getPointer(mapHeader.pMap+0x8);
        mapTilesPtr = rom.getPointer(mapHeader.pMap+0xC);
        globalTileSetPtr = rom.getPointer(mapHeader.pMap+0x10);
        localTileSetPtr = rom.getPointer(mapHeader.pMap+0x14);
        borderWidth = rom.readWord(mapHeader.pMap+0x18);
        borderHeight = rom.readWord(mapHeader.pMap+0x1A);
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
        rom.Seek(mapHeader.pMap);
        rom.writePointer(mapWidth);
        rom.writePointer(mapHeight);
        rom.writePointer(borderTilePtr);
        rom.writePointer(mapTilesPtr);
        rom.writePointer(globalTileSetPtr);
        rom.writePointer(localTileSetPtr);
        //rom.writeBytes(mapHeader.pMap, new byte[]{(byte)(borderWidth), (byte)(borderHeight)}); //Isn't quite working yet :/
    }
}
