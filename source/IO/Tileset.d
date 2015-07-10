/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Tileset.d                                                                  *
 * "Stores data and Pixbufs for a particular tileset within a map."           *
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
module IO.Tileset;

import gdkpixbuf.Pixbuf;
import GBAUtils.GBARom;
import GBAUtils.Palette;
import GBAUtils.GBAImage;
import GBAUtils.Lz77;
import GBAUtils.DataStore;
import GBAUtils.GBAImageType;
import IO.TilesetHeader;
import core.exception;
import std.array;

public class Tileset
{
    private GBARom rom;
    private GBAImage image;
    private Pixbuf[][] bi;
    private Palette[][] palettes; 
    private Palette[][] palettesFromROM;
    private static Tileset lastPrimary;
    public TilesetHeader tilesetHeader;
    public static uint maxTime = 1; //Number of actual time palettes

    public int numBlocks;
    private Pixbuf[uint][] renderedTiles;
    private Pixbuf[uint][] customRenderedTiles;
    private ubyte[] localTSLZHeader = [ 10, 80, 9, 00, 32, 00, 00 ];
    private ubyte[] globalTSLZHeader = [ 10, 80, 9, 00, 32, 00, 00 ];
    
    public bool modified = false;

    
    public this(GBARom rom, int offset)
    {
        this.rom = rom;
        loadData(offset);
        numBlocks = (tilesetHeader.isPrimary ? DataStore.MainTSBlocks : DataStore.LocalTSBlocks); //INI RSE=0x207 : 0x88, FR=0x280 : 0x56
        renderTiles(offset);	
    }
    
    public void loadData(int offset)
    {
        tilesetHeader = new TilesetHeader(rom,offset);
    }
    
    public void renderGraphics()
    {
        uint imageDataPtr = tilesetHeader.pGFX;

        if(tilesetHeader.isPrimary)
            lastPrimary = this;
        ubyte[] uncompressedData = null;

        if(tilesetHeader.bCompressed == 1)
            uncompressedData = Lz77.decompressLZ77(rom, imageDataPtr);
        if(uncompressedData == null)
        {
            rom.writeBytes(tilesetHeader.pGFX, (tilesetHeader.isPrimary ? globalTSLZHeader : localTSLZHeader)); //Attempt to repair the LZ77 data
            uncompressedData = Lz77.decompressLZ77(rom, imageDataPtr);
            if(uncompressedData == null) //If repairs didn't go well, revert ROM and pull uncompressed data
            {
                uncompressedData = rom.readBytes(imageDataPtr, (tilesetHeader.isPrimary ? 128*DataStore.MainTSHeight : 128*DataStore.LocalTSHeight) / 2); //TODO: Hardcoded to FR tileset sizes
            }
        }
        
        //Clean rendered tiles
        renderedTiles.length = 0;
        customRenderedTiles.length = 0;
        renderedTiles.length = 0x40;
        customRenderedTiles.length = 0x40;
        
        image = new GBAImage(uncompressedData,palettes[0][0], 128, (tilesetHeader.isPrimary ? DataStore.MainTSHeight : DataStore.LocalTSHeight));
    }
    
    public void renderPalettes()
    {
        palettes = uninitializedArray!(Palette[][])(maxTime,16);
        bi = uninitializedArray!(Pixbuf[][])(maxTime,16);

        for(int i = 0; i < maxTime; i++)
        {
            for(int j = 0; j < 16; j++)
            {
                palettes[i][j] = new Palette(GBAImageType.c16, rom.readBytes((tilesetHeader.pPalettes)+((32*j) + (i * 0x200)),32));
            }
        }
        palettesFromROM = palettes.dup();
    }
    
    public void renderTiles(int offset)
    {
        renderPalettes();
        renderGraphics();
    }
    
    void startTileThreads()
    {
        //for(int i = 0; i < (tilesetHeader.isPrimary ? DataStore.MainTSPalCount : 13); i++)
            //tileLoader(renderedTiles, i); //TODO: Actually thread, if needed
    }
    
    public Pixbuf getTileWithCustomPal(int tileNum, Palette palette, bool xFlip, bool yFlip, int time)
    {
        int x = ((tileNum) % (bi[time][0].getWidth() / 8)) * 8;
        int y = ((tileNum) / (bi[time][0].getWidth() / 8)) * 8;
        Pixbuf toSend =  image.getPixbufFromPal(palette).newSubpixbuf(x, y, 8, 8);

        if(!xFlip && !yFlip)
            return toSend;
        if(xFlip)
            toSend = horizontalFlip(toSend);
        if(yFlip)
            toSend = verticalFlip(toSend);
        
        return toSend;
    }

    public Pixbuf getTile(int tileNum, int palette, bool xFlip, bool yFlip, int time)
    {
        if(palette < DataStore.MainTSPalCount)
        {
            /*if(tileNum in renderedTiles[palette+(time * 16)]) //Check to see if we've cached that tile
            {
                if(xFlip && yFlip)
                    return verticalFlip(horizontalFlip(renderedTiles[palette+(time * 16)][tileNum]));
                else if(xFlip)
                {
                    return horizontalFlip(renderedTiles[palette+(time * 16)][tileNum]);
                }
                else if(yFlip)
                {
                    return verticalFlip(renderedTiles[palette+(time * 16)][tileNum]);
                }
                
                return renderedTiles[palette+(time * 16)][tileNum];
            }*/
        }
        else if(palette < 13)
        {
            /*if(tileNum in customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)]) //Check to see if we've cached that tile
            {
                if(xFlip && yFlip)
                    return verticalFlip(horizontalFlip(customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)][tileNum]));
                else if(xFlip)
                {
                    return horizontalFlip(customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)][tileNum]);
                }
                else if(yFlip)
                {
                    return verticalFlip(customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)][tileNum]);
                }
                
                return customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)][tileNum];
            }*/
        }
        else
        {
            //	System.out.println("Attempted to read tile " + tileNum + " of palette " + palette + " in " + (tilesetHeader.isPrimary ? "global" : "local") + " tileset!");
            return new Pixbuf(GdkColorspace.RGB, true, 8, 8, 8);
        }
        
        int x = ((tileNum) % (128 / 8)) * 8;
        int y = ((tileNum) / (128 / 8)) * 8;
        Pixbuf toSend = bi[time][palette].newSubpixbuf(x, y, 8, 8);
        if(toSend is null)
        {
            toSend = new Pixbuf(GdkColorspace.RGB, true, 8, 8, 8);
            writefln("Attempted to read 8x8 at %u, %u, tileset is %u by %u, tileNum %x, " ~ (tilesetHeader.isPrimary ? "primary" : "secondary"), x, y, bi[time][palette].getWidth(), bi[time][palette].getHeight(), tileNum);
        }
        /*if(palette < DataStore.MainTSPalCount || renderedTiles.length > DataStore.MainTSPalCount)
            renderedTiles[palette+(time * 16)][tileNum] = toSend;
        else
            customRenderedTiles[(palette-DataStore.MainTSPalCount)+(time * 16)][tileNum] = toSend;*/

        if(!xFlip && !yFlip)
            return toSend;
        if(xFlip)
            toSend = horizontalFlip(toSend);
        if(yFlip)
            toSend = verticalFlip(toSend);
        
        return toSend;
    }
    
    public Palette[] getPalette(int time)
    {
        return palettes[time];
    }
    
    public Palette[][] getROMPalette()
    {
        return palettesFromROM.dup(); //No touchy the real palette!
    }
    
    public void resetPalettes()
    {
        palettes = getROMPalette();
    }
    
    public void setPalette(Palette[] pal, int time)
    {
        palettes[time] = pal;
    }
    
    public void setPalette(Palette pal, int index, int time)
    {
        palettes[time][index] = pal;
    }
    
    public void rerenderTileSet(int palette, int time)
    {
        bi[time][palette] = image.getPixbufFromPal(palettes[time][palette]);
    }
    
    public void renderPalettedTiles()
    {		
        for(int j = 0; j < maxTime; j++)
        {
            for (int i = 0; i < 16; i++)
            {
                writefln("Rendering tileset palette %u for time %u", i, j);
                rerenderTileSet(i,j);

            }
        }
    }
    public void resetCustomTiles()
    {
        customRenderedTiles.length = 0;
        customRenderedTiles.length = 0x40;
    }
    
    private Pixbuf horizontalFlip(Pixbuf img) 
    {
        return img.flip(true);
    }
    
    private Pixbuf verticalFlip(Pixbuf img) 
    {
        return img.flip(false);
    }

    public Pixbuf getTileSet(int palette, int time)
    {
        return bi[time][palette];
    }
    
    public Pixbuf getIndexedTileSet(int palette, int time)
    {
        return getTileSet(palette, time); //TODO
        //return image.getIndexedImage(palettes[time][palette], true);
    }
    
    public TilesetHeader getTilesetHeader()
    {
        return tilesetHeader;
    }

    public GBARom getROM()
    {
        return rom;
    }
    
    private void tileLoader(Pixbuf[uint][] buffer, int pal)
    {
        int k = (tilesetHeader.isPrimary ? DataStore.MainTSSize : DataStore.LocalTSSize);

        for (int i = 0; i < numBlocks; i++)
        {
            try
            {
                buffer[pal][i] = getTile(i, pal, false, false, 0);
            }
            catch (Exception e)
            {
                // e.printStackTrace();
                writefln("An error occured while writing tile %u with palette %u", i, pal);
            }
        }	
    }

    public void save()
    {
        for(int j = 0; j < 1; j++) //Caused issues last time I tested it...
        {
            for (int i = 0; i < (tilesetHeader.isPrimary ? DataStore.MainTSPalCount : 16); i++)
            {
                rom.Seek((tilesetHeader.pPalettes) + (32 * i + (j * 0x200)));
                palettes[j][i].save(rom);
            }
        }
        tilesetHeader.save();
    }
}
