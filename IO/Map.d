module IO.Map;

import std.stdio;
import gdkpixbuf.Pixbuf;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import GBAUtils.ROMManager;
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
		MapIO.blockRenderer.setGlobalTileset(TilesetCache.get(map.getMapData().globalTileSetPtr));
		MapIO.blockRenderer.setLocalTileset(TilesetCache.get(map.getMapData().localTileSetPtr));
		
		
		Pixbuf imgBuffer;/* = new Pixbuf(8,8, Pixbuf.TYPE_INT_ARGB); //TODO
		Image tiles;
		if(!full)
			tiles = MainGUI.tileEditorPanel.RerenderSecondary(TileEditorPanel.imgBuffer);
		else
			tiles = MainGUI.tileEditorPanel.RerenderTiles(TileEditorPanel.imgBuffer, 0);
		try
		{		
			imgBuffer = new Pixbuf( map.getMapData().mapWidth * 16,
					 map.getMapData().mapHeight * 16, Pixbuf.TYPE_INT_ARGB);
			Graphics gcBuff = imgBuffer.getGraphics();

			for (int y = 0; y < map.getMapData().mapHeight; y++)
			{
				for (int x = 0; x < map.getMapData().mapWidth; x++)
				{
					//gcBuff = imgBuffer.getGraphics();
					int TileID=(map.getMapTileData().getTile(x, y).getID());
					int srcX=(TileID % TileEditorPanel.editorWidth) * 16;
					int srcY = (TileID / TileEditorPanel.editorWidth) * 16;
					//gcBuff.drawImage(((Pixbuf)(tiles)).getSubimage(srcX, srcY, 16, 16), x * 16, y * 16, null); //TODO Adjust rendering for Pixbufs
					//new org.zzl.minegaming.GBAUtils.PictureFrame(((Pixbuf)(tiles)).getSubimage(srcX, srcY, 16, 16)).show();
				}
			}
		}
		catch (Exception e)
		{
			writefln("Error rendering map.");
			e.printStackTrace();
			imgBuffer.getGraphics().setColor(Color.RED);
			imgBuffer.getGraphics().fillRect(0, 0, 8, 8);
		}*/

		return imgBuffer;
	}
}
