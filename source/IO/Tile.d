/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Tile.d                                                                     *
 * "Stores information on a particular tile within a block."                  *
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
module IO.Tile;

public class Tile
{
    private uint tileNum;
    private uint pal;
    public bool xFlip;
    public bool yFlip;
    public this(int tileNum, int palette, bool xFlip, bool yFlip)
    {
        if(tileNum > 0x3FF)
            tileNum = 0x3FF;
        
        if(palette > 12)
            palette = 12;
        
        this.tileNum = tileNum;
        this.pal = palette;
        this.xFlip = xFlip;
        this.yFlip = yFlip;
    }
    
    public int getTileNumber()
    {
        return tileNum;
    }
    
    public int getPaletteNum()
    {
        return pal;
    }
    
    public void setTileNumber(int number)
    {
        if(number > 0x3FF)
            number = 0x3FF;
        
        tileNum = number;
    }
    
    public void setPaletteNum(int palette)
    {
        if(palette > 12)
            palette = 12;
        
        pal = palette;
    }

    public Tile getNewInstance()
    {
        return new Tile(tileNum, pal, xFlip, yFlip);
    }
}
