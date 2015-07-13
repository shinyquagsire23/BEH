/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * WildPokemonData.d                                                          *
 * "Stores data for all wild Pokémon in all areas of a map."                  *
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
module MapElements.WildPokemonData;

import GBAUtils.DataStore;
import pokegba.rom;
import GBAUtils.ISaveable;

import MapElements.WildDataType;
import MapElements.WildPokemon;

public class WildPokemonData : ISaveable
{
    private WildDataType type;
    private ROM rom;
    private uint pData;
    public byte bRatio;
    public byte bDNEnabled;
    public uint pPokemonData;
    public WildPokemon[][] aWildPokemon;
    public uint[] aDNPokemon;
    private static int[] numPokemon = [12, 5, 5, 10];

    public this(ROM rom, WildDataType t)
    {
        this.rom = rom;
        type = t;
        if(rom.internalOffset > 0x1FFFFFF || rom.internalOffset < 0x100)
        {
            return;
        }
        
        try
        {
            bRatio = rom.readByte();
            bDNEnabled = rom.readByte();
            rom.internalOffset += 0x2;
            pPokemonData = rom.getPointer();
            aWildPokemon = new WildPokemon[][](bDNEnabled > 0 ? 4 : 1, numPokemon[type]);
            aDNPokemon = new uint[4];
            
            for (int j = 0; j < 4; j++)
            {
                if (bDNEnabled == 0x1)
                    aDNPokemon[j] = rom.getPointer( (pPokemonData) + (j * 4), true);
                else
                    aDNPokemon[j] = -1;
            }

            
            for(int j = 0; j < (bDNEnabled > 0 ? 4 : 1); j++)
            {
                if(bDNEnabled == 0)
                    rom.s( pPokemonData);
                else
                    rom.s(aDNPokemon[j] & 0x1FFFFFF);
                
                for (int i = 0; i < numPokemon[type]; i++)
                {
                    aWildPokemon[j][i] = new WildPokemon(rom);
                }
            }
        }
        catch (Exception e)
        {
            //e.printStackTrace();
        }
    }

    public this(ROM rom, WildDataType t, byte ratio)
    {
        this.rom = rom;
        type = t;
        bRatio = ratio;
        pPokemonData = -1;
        bDNEnabled = 0;
        aWildPokemon = new WildPokemon[][](bDNEnabled > 0 ? 4 : 1, numPokemon[type]);

        rom.s( pPokemonData);
        for (int i = 0; i < numPokemon[type]; i++)
        {
            aWildPokemon[0][i] = new WildPokemon(rom, 1, 1, 0);
        }
    }
    
    public this(ROM rom, WildDataType t, bool enableDN)
    {
        this.rom = rom;
        type = t;
        bRatio = 0x21;
        bDNEnabled = (enableDN ? 0x1 : 0x0);
        pPokemonData = -1;
        aWildPokemon = new WildPokemon[][](bDNEnabled > 0 ? 4 : 1, numPokemon[type]);

        rom.s( pPokemonData);
        for(int j = 0; j < (bDNEnabled > 0 ? 4 : 1); j++)
        {	
            for (int i = 0; i < numPokemon[type]; i++)
            {
                aWildPokemon[j][i] = new WildPokemon(rom,1,1,0);
            }
        }
    }
    
    public this(WildPokemonData d)
    {
        this.rom = d.rom;
        try
        {
            this.aDNPokemon = d.aDNPokemon.dup();
        }
        catch(Exception e){return;}
        WildPokemon[][] pokeTransfer = new WildPokemon[][](d.aWildPokemon.length, numPokemon[d.type]);
        
        for(int j = 0; j < d.aWildPokemon.length; j++)
        {
            for(int i = 0; i < numPokemon[d.type]; i++)
            {
                pokeTransfer[j][i] = new WildPokemon(d.rom,d.aWildPokemon[j][i].bMinLV,d.aWildPokemon[j][i].bMaxLV,d.aWildPokemon[j][i].wNum);
            }
        }
        this.aWildPokemon = pokeTransfer.dup();
        
        this.bDNEnabled = d.bDNEnabled;
        this.bRatio = d.bRatio;
        this.pData = d.pData;
        this.pPokemonData = d.pPokemonData;
        this.type = d.type;
    }

    public void convertToDN()
    {
        bDNEnabled = 1;
        WildPokemon[][] pokeTransfer = new WildPokemon[][](4, numPokemon[type]);
        
        for(int j = 0; j < 4; j++)
        {
            for(int i = 0; i < numPokemon[type]; i++)
            {
                pokeTransfer[j][i] = new WildPokemon(rom,aWildPokemon[0][i].bMinLV,aWildPokemon[0][i].bMaxLV,aWildPokemon[0][i].wNum);
            }
        }
        
        aWildPokemon = pokeTransfer.dup();
    }

    public static int getSize()
    {
        return 8;
    }

    public int getWildDataSize()
    {
        return numPokemon[type] * WildPokemon.getSize();
    }

    public WildDataType getType()
    {
        return type;
    }

    public void save()
    {
        rom.writeByte(bRatio);
        rom.writeByte(bDNEnabled);
        rom.internalOffset += 0x2;

        if (pPokemonData == -1)
        {
            pPokemonData = rom.findFreespace((bDNEnabled == 1 ? 4*4 : getWildDataSize()), DataStore.FreespaceStart);
            rom.floodBytes(pPokemonData, 0, (bDNEnabled == 1 ? 4*4 : getWildDataSize())); //Prevent them from taking the same freespace
        }
        for(int i = 0; i < 4; i++)
            if(aDNPokemon[i] == -1 && bDNEnabled == 0x1)
        {
            aDNPokemon[i] = rom.findFreespace(getWildDataSize(), DataStore.FreespaceStart);
            rom.floodBytes(aDNPokemon[i], 0, getWildDataSize()); //Prevent them from taking the same freespace
        }

        rom.writePointer( pPokemonData);
        
        if(bDNEnabled == 1)
        {
            rom.s(pPokemonData);
            rom.writePointer(aDNPokemon[0]);
            rom.writePointer(aDNPokemon[1]);
            rom.writePointer(aDNPokemon[2]);
            rom.writePointer(aDNPokemon[3]);
        }
        
        for(int j = 0; j < (bDNEnabled > 0 ? 4 : 1); j++)
        {
            if(bDNEnabled == 0)
                rom.s( pPokemonData);
            else
                rom.s( aDNPokemon[j]);
            
            for (int i = 0; i < numPokemon[type]; i++)
            {
                try
                {
                    aWildPokemon[j][i].save();
                }
                catch(Exception e)
                {
                    //e.printStackTrace();
                }
            }
        }
    }
}
