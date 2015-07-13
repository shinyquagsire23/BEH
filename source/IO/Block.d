/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Block.d                                                                    *
 * "Stores image and metadata for a block within a blockset."                 *
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
module IO.Block;

import GBAUtils.DataStore;
import pokegba.rom;
import IO.MapIO;
import IO.Tile;


public class Block
{
    public Tile[2][2] tilesThirdLayer;
    public Tile[2][2] tilesForeground;
    public Tile[2][2] tilesBackground;
    public uint blockID;
    public uint backgroundMetaData;
    private ROM rom;
    
    public this(int blockID, ROM rom)
    {
        this(blockID, MapIO.blockRenderer.getBehaviorByte(blockID), rom);
    }
    
    public this(uint blockID, uint bgBytes, ROM rom)
    {
        this.blockID = blockID;
        this.backgroundMetaData = bgBytes;
        this.rom = rom;
        //		blockRenderer.getBehaviorByte(blockID)
        for(int i = 0; i < 2; i++)
        {
            for(int j = 0; j < 2; j++)
            {
                tilesForeground[i][j] = new Tile(0,0,false,false);
                tilesBackground[i][j] = new Tile(0,0,false,false);
            }
        }
    }
    
    public void setTile(int x, int y, Tile t)
    {
        try
        {
            if (x < 2)
                tilesBackground[x][y] = t.getNewInstance();
            else
                tilesForeground[x-2][y] = t.getNewInstance();
        }
        catch(Exception e){}
    }
    
    public Tile getTile(int x, int y)
    {
        try
        {
            if (x < 2)
                return tilesBackground[x][y].getNewInstance();
            else
                return tilesForeground[x-2][y].getNewInstance();
        }
        catch(Exception e)
        {
            return new Tile(0,0,false,false);
        }
    }
    
    public void setMetaData(int bytes)
    {
        backgroundMetaData = bytes;
    }
    
    public void save()
    {
        int pBlocks = MapIO.blockRenderer.getGlobalTileset().tilesetHeader.pBlocks;
        int pBehavior = MapIO.blockRenderer.getGlobalTileset().tilesetHeader.pBehavior;
        int blockNum = blockID;
        
        if (blockNum >= DataStore.MainTSBlocks)
        {
            blockNum -= DataStore.MainTSBlocks;
            pBlocks = MapIO.blockRenderer.getLocalTileset().tilesetHeader.pBlocks;
            pBehavior = MapIO.blockRenderer.getLocalTileset().tilesetHeader.pBehavior;
        }
        
        pBlocks += (blockNum * 16);
        rom.s(pBlocks);
        
        for (int i = 0; i < 2; i++)
        {
            for (int y1 = 0; y1 < 2; y1++)
            {
                for (int x1 = 0; x1 < 2; x1++)
                {
                    if(i == 0)
                    {
                        ushort toWrite = tilesBackground[x1][y1].getTileNumber() & 0x3FF;
                        toWrite |= (tilesBackground[x1][y1].getPaletteNum() & 0xF) << 12;
                        toWrite |= (tilesBackground[x1][y1].xFlip ? 0x1 : 0x0) << 10;
                        toWrite |= (tilesBackground[x1][y1].yFlip ? 0x1 : 0x0) << 11;
                        rom.writeHalfword(toWrite);
                    }
                    else
                    {
                        ushort toWrite = tilesForeground[x1][y1].getTileNumber() & 0x3FF;
                        toWrite |= (tilesForeground[x1][y1].getPaletteNum() & 0xF) << 12;
                        toWrite |= (tilesForeground[x1][y1].xFlip ? 0x1 : 0x0) << 10;
                        toWrite |= (tilesForeground[x1][y1].yFlip ? 0x1 : 0x0) << 11;
                        rom.writeHalfword(toWrite);
                    }
                }
            }
        }
        rom.s(pBehavior + (blockNum * 4));
        rom.writePointer(backgroundMetaData);
    }
    
}
