/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Map.d                                                                      *
 * "Stores all data associated with a particular map for reading and writing" *
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
module IO.Map;

import std.stdio;
import gdkpixbuf.Pixbuf;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import GBAUtils.ROMManager;
import GBAUtils.PixbufExtend;
import GBAUtils.PictureFrame;
import IO.MapData;
import IO.MapTileData;
import IO.MapHeader;
import IO.ConnectionData;
import IO.BankLoader;
import IO.TilesetCache;
import IO.MapIO;
import MapElements.HeaderSprites;
import MapElements.SpritesNPCManager;
import MapElements.SpritesSignManager;
import MapElements.SpritesExitManager;
import MapElements.TriggerManager;
import IO.Render.BlockRenderer;
import IO.Render.TilesetRenderer;
import IO.Render.OverworldSprites;
import IO.Render.OverworldSpritesManager;

public class Map : ISaveable
{
    private MapData mapData;
    private MapTileData mapTileData;
    public MapHeader mapHeader; 
    public ConnectionData mapConnections;
    public HeaderSprites mapSprites;
    
    public SpritesNPCManager mapNPCManager;
    public SpritesSignManager mapSignManager;
    public SpritesExitManager mapExitManager;
    public TriggerManager mapTriggerManager;
    public OverworldSpritesManager overworldSpritesManager;
    public uint dataOffset = 0;
    public OverworldSprites[] eventSprites;
    public bool isEdited;
    
    public this(GBARom rom, uint bank, uint map)
    {
        this(rom,BankLoader.maps[bank][map]);
    }
    
    public this(GBARom rom, uint dataOffset)
    {
        this.dataOffset = dataOffset;
        mapHeader = new MapHeader(rom, dataOffset);
        mapConnections = new ConnectionData(rom, mapHeader);
        mapSprites = new HeaderSprites(rom, mapHeader.pSprites);
        
        mapNPCManager=new SpritesNPCManager(rom, this, mapSprites.pNPC, mapSprites.bNumNPC);
        mapSignManager = new SpritesSignManager(rom, this, mapSprites.pSigns, mapSprites.bNumSigns);
        mapTriggerManager = new TriggerManager(rom, this, mapSprites.pTraps, mapSprites.bNumTraps);
        mapExitManager = new SpritesExitManager(rom, this, mapSprites.pExits, mapSprites.bNumExits);
        overworldSpritesManager= new OverworldSpritesManager(rom);

        mapData = new MapData(rom, mapHeader);
        mapTileData = new MapTileData(rom ,mapData);
        isEdited = true;
    }
    
    public MapData getMapData()
    {
        return mapData;
    }
    
    public MapTileData getMapTileData()
    {
        return mapTileData;
    }
    
    
    public void save()
    {
        //Save in reverse order in case we have repointing to do first.
        mapTileData.save();
        mapData.save();

        mapNPCManager.save();
        mapSignManager.save();
        mapTriggerManager.save();
        mapExitManager.save();
        mapSprites.save();
        
        mapConnections.save();
        mapHeader.save();
    }

    public static Pixbuf renderMap(int bank, int map)
    {
        return renderMap(new Map(ROMManager.currentROM,bank,map), true);
    }
    
    public static Pixbuf renderMap(Map map, bool full)
    {
        TilesetCache.switchTileset(map);
        
        if(MapIO.blockRenderer is null)
            MapIO.blockRenderer = new BlockRenderer();
        
        MapIO.blockRenderer.setGlobalTileset(TilesetCache.get(map.getMapData().globalTileSetPtr));
        MapIO.blockRenderer.setLocalTileset(TilesetCache.get(map.getMapData().localTileSetPtr));
        
        
        Pixbuf imgBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, 8, 8);
        Pixbuf tiles;
        if(!full)
            tiles = TilesetRenderer.RerenderSecondary(TilesetRenderer.imgBuffer);
        else
            tiles = TilesetRenderer.RerenderTiles(TilesetRenderer.imgBuffer, 0);
        new PictureFrame(tiles);

        try
        {		
            imgBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, map.getMapData().mapWidth * 16, map.getMapData().mapHeight * 16);

            for (int y = 0; y < map.getMapData().mapHeight; y++)
            {
                for (int x = 0; x < map.getMapData().mapWidth; x++)
                {
                    int TileID=(map.getMapTileData().getTile(x, y).getID());
                    int srcX=(TileID % TilesetRenderer.renderWidth) * 16;
                    int srcY = (TileID / TilesetRenderer.renderWidth) * 16;
                    imgBuffer.drawImage(tiles.newSubpixbuf(srcX, srcY, 16, 16), x * 16, y * 16); 
                }
            }
        }
        catch (Exception e)
        {
            writefln("Error rendering map.");
            //e.printStackTrace();
            imgBuffer.fillRect(0, 0, 8, 8, 255, 0, 0);
        }

        return imgBuffer;
    }
}
