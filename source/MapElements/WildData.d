/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * WildData.d                                                                 *
 * "Stores information about multiple wild Pokémon within a map for reading   *
 *  and writing to ROM."                                                      *
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
module MapElements.WildData;

import GBAUtils.DataStore;
import pokegba.rom;

import MapElements.WildPokemonData;
import MapElements.WildDataHeader;
import MapElements.WildDataType;

public class WildData
{
    public WildPokemonData[] aWildPokemon = new WildPokemonData[4];
    public WildDataHeader wildDataHeader;
    private ROM rom;
    
    public this(ROM rom, WildDataHeader h)
    {
        this.rom = rom;
        wildDataHeader = h;
        
        rom.Seek(h.pGrass);
        if(h.pGrass != 0)
            aWildPokemon[0] = new WildPokemonData(rom, WildDataType.GRASS);
        
        rom.Seek(h.pWater);
        if(h.pWater != 0)
            aWildPokemon[1] = new WildPokemonData(rom, WildDataType.WATER);
        
        rom.Seek(h.pTrees);
        if(h.pTrees != 0)
            aWildPokemon[2] = new WildPokemonData(rom, WildDataType.TREE);
        
        rom.Seek(h.pFishing);
        if(h.pFishing != 0)
            aWildPokemon[3] = new WildPokemonData(rom, WildDataType.FISHING);
    }
    
    public this(ROM rom, ubyte bank, ubyte map)
    {
        this.rom = rom;
        wildDataHeader = new WildDataHeader(rom, bank, map);
    }
    
    public void addWildData(WildDataType t)
    {
        addWildData(t, 0x15);
    }
    
    public void removeWildData(WildDataType t)
    {
        WildPokemonData d = null;
        if(aWildPokemon[t] is null)
            return;
        uint size;
        uint pkmnData;
        switch(t)
        {
            case WildDataType.WATER:
                d = aWildPokemon[1];
                size = d.getWildDataSize();
                pkmnData = d.pPokemonData;
                rom.floodBytes(wildDataHeader.pWater, DataStore.FreespaceByte, WildPokemonData.getSize());
                wildDataHeader.pWater = 0;
                aWildPokemon[1] = null;
                break;
            case WildDataType.TREE:
                d = aWildPokemon[2];
                size = d.getWildDataSize();
                pkmnData = d.pPokemonData;
                rom.floodBytes(wildDataHeader.pTrees, DataStore.FreespaceByte, WildPokemonData.getSize());
                wildDataHeader.pTrees = 0;
                aWildPokemon[2] = null;
                break;
            case WildDataType.FISHING:
                d = aWildPokemon[3];
                size = d.getWildDataSize();
                pkmnData = d.pPokemonData;
                rom.floodBytes(wildDataHeader.pFishing, DataStore.FreespaceByte, WildPokemonData.getSize());
                wildDataHeader.pFishing = 0;
                aWildPokemon[3] = null;
                break;
            case WildDataType.GRASS:
            default:
                d = aWildPokemon[0];
                size = d.getWildDataSize();
                pkmnData = d.pPokemonData;
                rom.floodBytes(wildDataHeader.pGrass, DataStore.FreespaceByte, WildPokemonData.getSize());
                wildDataHeader.pGrass = 0;
                aWildPokemon[0] = null;
                break;
        }
        rom.floodBytes(pkmnData, DataStore.FreespaceByte, size);
    }
    
    public void addWildData(WildDataType t, byte ratio)
    {
        WildPokemonData d = new WildPokemonData(rom, t, ratio);
        switch(t)
        {
            case WildDataType.GRASS:
                aWildPokemon[0] = d;
                break;
            case WildDataType.WATER:
                aWildPokemon[1] = d;
                break;
            case WildDataType.TREE:
                aWildPokemon[2] = d;
                break;
            case WildDataType.FISHING:
                aWildPokemon[3] = d;
                break;
            default:
                break;
        }
    }
    
    public void save(int headerloc)
    {
        if(aWildPokemon[0].aWildPokemon != null)
        {
            if(wildDataHeader.pGrass == 0 || wildDataHeader.pGrass > 0x1FFFFFF)
                wildDataHeader.pGrass = rom.findFreespace(DataStore.FreespaceStart, 8);
            rom.floodBytes(wildDataHeader.pGrass, 0, 8); //Prevent these bytes from being used by wild data
            rom.Seek( wildDataHeader.pGrass);
            aWildPokemon[0].save();
        }
        if(aWildPokemon[1].aWildPokemon != null)
        {
            if(wildDataHeader.pWater == 0 || wildDataHeader.pWater > 0x1FFFFFF)
                wildDataHeader.pWater = rom.findFreespace(DataStore.FreespaceStart, 8);
            rom.floodBytes(wildDataHeader.pWater, 0, 8); //Prevent these bytes from being used by wild data
            rom.Seek( wildDataHeader.pWater);
            aWildPokemon[1].save();
        }
        if(aWildPokemon[2].aWildPokemon != null)
        {
            if(wildDataHeader.pTrees == 0 || wildDataHeader.pTrees > 0x1FFFFFF)
                wildDataHeader.pTrees = rom.findFreespace(DataStore.FreespaceStart, 8);
            rom.floodBytes(wildDataHeader.pTrees, 0, 8); //Prevent these bytes from being used by wild data
            rom.Seek( wildDataHeader.pTrees);
            aWildPokemon[2].save();
        }
        if(aWildPokemon[3].aWildPokemon != null)
        {
            if(wildDataHeader.pFishing == 0 || wildDataHeader.pFishing > 0x1FFFFFF)
                wildDataHeader.pFishing = rom.findFreespace(DataStore.FreespaceStart, 8);
            rom.floodBytes(wildDataHeader.pFishing, 0, 8); //Prevent these bytes from being used by wild data
            rom.Seek( wildDataHeader.pFishing);
            aWildPokemon[3].save();
        }
        wildDataHeader.save(headerloc);
    }
}
