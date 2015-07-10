/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * WildDataHeader.d                                                           *
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
module MapElements.WildDataHeader;

import GBAUtils.GBARom;

public class WildDataHeader
{
    public ubyte bBank, bMap;
    public uint pGrass, pWater, pTrees, pFishing;
    private GBARom rom;
    
    public this(GBARom rom)
    {
        this(rom,rom.internalOffset);
    }
    
    public this(GBARom rom, uint offset)
    {
        loadWildData(rom, offset);
    }
    
    public this(GBARom rom, ubyte bank, ubyte map)
    {
        this.rom = rom;
        
        bBank = bank;
        bMap = map;
        pGrass = 0;
        pWater = 0;
        pTrees = 0;
        pFishing = 0;
    }
    
    public static int getSize()
    {
        return 20;
    }
    
    private void loadWildData(GBARom rom, uint offset)
    {
        this.rom = rom;
        
        rom.Seek(offset);
        bBank = rom.readByte();
        bMap = rom.readByte();
        rom.internalOffset+=2; //Filler bytes
        pGrass = rom.getPointer();
        pWater = rom.getPointer();
        pTrees = rom.getPointer();
        pFishing = rom.getPointer();
    }
    
    public void save(uint headerloc)
    {
        rom.Seek(headerloc);
        rom.writeByte(bBank);
        rom.writeByte(bMap);
        rom.internalOffset+=2; //Filler bytes
        
        if(pGrass != 0)
            rom.writePointer(pGrass);
        else
            rom.writePointer(0);
        
        if(pWater != 0)
            rom.writePointer(pWater);
        else
            rom.writePointer(0);
        
        if(pTrees != 0)
            rom.writePointer(pTrees);
        else
            rom.writePointer(0);
        
        if(pFishing != 0)
            rom.writePointer(pFishing);
        else
            rom.writePointer(0);
    }
}
