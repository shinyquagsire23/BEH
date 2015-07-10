/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * TilesetRenderer.d                                                          *
 * "Renders the main block palette which maps use, given the local and global *
 *  tileset. Relies on an initialized BlockRenderer to render the blocks."    *
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
module IO.Render.TilesetRenderer;

import gdkpixbuf.Pixbuf;
import GBAUtils.DataStore;
import GBAUtils.PixbufExtend;
import IO.Tileset;
import IO.MapIO;
import std.algorithm;

public class TilesetRenderer
{
static:
    public Tileset globalTiles;
    public Tileset localTiles;
    public Pixbuf imgBuffer = null;
    public uint renderWidth = 8; //Width in 16x16 tiles
    
    public void setGlobalTileset(Tileset global) 
    {
        globalTiles = global;
        MapIO.blockRenderer.setGlobalTileset(global);
    }

    public void setLocalTileset(Tileset local) 
    {
        localTiles = local;
        MapIO.blockRenderer.setLocalTileset(local);
    }

    public void DrawTileset() 
    {
        imgBuffer = RerenderTiles(imgBuffer, 0, DataStore.MainTSBlocks+0x200,true);//(DataStore.EngineVersion == 1 ? 0x11D : 0x200), true);
        //new org.zzl.minegaming.GBAUtils.PictureFrame(imgBuffer).show();
        //Dimension d = new Dimension(16*renderWidth,(DataStore.MainTSSize / renderWidth)*(DataStore.LocalTSSize / renderWidth) *16);
        //imgBuffer = new BufferedImage(d.width,d.height,BufferedImage.TYPE_INT_ARGB);
    }
    
    public Pixbuf RerenderSecondary(Pixbuf i) 
    {
        return RerenderTiles(i, DataStore.MainTSBlocks);
    }
    
    public Pixbuf RerenderTiles(Pixbuf i, int startBlock) 
    {
        return RerenderTiles(i, startBlock, DataStore.MainTSBlocks+(DataStore.EngineVersion == 1 ? 0x11D : 1024), false);
    }
    
    public Pixbuf RerenderTiles(Pixbuf b, int startBlock, int endBlock, bool completeRender) 
    {
        //startBlock = DataStore.MainTSBlocks;
        uint width = 16*renderWidth;
        uint height = max((endBlock / renderWidth) * 16, ((DataStore.MainTSSize / renderWidth)+(DataStore.LocalTSSize / renderWidth))*16);
        if(completeRender || b is null) 
        {
            if(DataStore.EngineVersion == 0)
                height = 3048;
            b = new Pixbuf(GdkColorspace.RGB, true, 8, width, height);
        }
        
        for(int i = startBlock; i < endBlock; i++) 
        {
            int x = (i % renderWidth) * 16;
            int y = (i / renderWidth) * 16;

            b.drawImage(MapIO.blockRenderer.renderBlock(i,true), x, y);
        }
        return b;
    }
}
