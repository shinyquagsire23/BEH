/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * WildDataCache.d                                                            *
 * "Caches various maps WildDatas for quicker loading."                       *
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
module MapElements.WildDataCache;

import GBAUtils.DataStore;
import pokegba.rom;

import MapElements.WildData;
import MapElements.WildDataHeader;

public class WildDataCache //TODO: Actually thread this
{
    private static WildData[uint] dataCache;
    private static uint initialNum;
    private static ROM rom;
    
    public this(ROM rom)
    {
        WildDataCache.rom = rom;
    }
    
    public static void gatherData()
    {
        uint pData = DataStore.WildPokemon;
        int count = 0;
        while(true)
        {
            WildDataHeader h = new WildDataHeader(rom, pData);
            if(h.bBank == 0xFF && h.bMap == 0xFF)
                break;
            
            WildData d = new WildData(rom,h);
            int num = (h.bBank & 0xFF) + ((h.bMap & 0xFF)<<8);
            dataCache[num] = d;
            pData += (4 * 5);
            count++;
        }
        initialNum = count;
    }
    
    public static void save()
    {
        uint pData = DataStore.WildPokemon;
        if(initialNum < dataCache.length)
        {
            pData = rom.findFreespace(DataStore.FreespaceStart, WildDataHeader.getSize() * cast(uint)dataCache.length);
            rom.repoint(DataStore.WildPokemon, pData, 14); //TODO: Maybe make this configurable?
            rom.floodBytes(DataStore.WildPokemon, cast(ubyte)0xFF, initialNum * WildDataHeader.getSize()); //TODO Make configurable
        }
        
        foreach(WildData d; dataCache.values())
        {
            d.save(pData);
            pData += (4 * 5);
        }
    }
    
    public static WildData getWildData(int bank, int map)
    {
        int num = (bank & 0xFF) + ((map & 0xFF)<<8);
        return dataCache[num];
    }
    
    public static void setWildData(int bank, int map, WildData d)
    {
        int num = (bank & 0xFF) + ((map & 0xFF)<<8);
        WildData data = getWildData(bank, map);
        data.aWildPokemon = d.aWildPokemon.dup();
        data.wildDataHeader = d.wildDataHeader;
        //dataCache.put(num, d);
    }
    
    public static WildData createWildDataIfNotExists(ubyte bank, ubyte map)
    {
        if((bank & 0xFF) + ((map & 0xFF)<<8) in dataCache)
            return getWildData(bank,map);
        else
        {
            WildData d = new WildData(rom, bank, map);
            dataCache[(bank & 0xFF) + ((map & 0xFF)<<8)] = d;
            return d;
        }
    }
    
    public void run()
    {
        gatherData();
    }
}
