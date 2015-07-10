/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * WildPokemon.d                                                              *
 * "Data structure describing a wild Pokémon entry in an environment."        *
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
module MapElements.WildPokemon;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class WildPokemon : ISaveable
{
    private GBARom rom;
    public ubyte bMinLV, bMaxLV;
    public ushort wNum;
    
    public this(GBARom rom)
    {
        this.rom = rom;
        bMinLV = rom.readByte();
        bMaxLV = rom.readByte();
        wNum = rom.readWord();
    }
    
    public this(GBARom rom, ubyte minLV, ubyte maxLV, ushort pokemon)
    {
        this.rom = rom;
        bMinLV = minLV;
        bMaxLV = maxLV;
        wNum   = pokemon;
    }
    
    public static uint getSize()
    {
        return 4;
    }
    
    public void save()
    {
        rom.writeByte(bMinLV);
        rom.writeByte(bMaxLV);
        rom.writeWord(wNum);
    }
}
