module IO.BorderMap;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

import IO.BorderTileData;
import IO.Map;
import IO.MapData;

public class BorderMap : ISaveable
{
	private Map map;
	private MapData mapData;
	private BorderTileData mapTileData;
	public bool isEdited = false;
	
	public this(GBARom rom, Map m)
	{
		map = m;
		mapData = map.getMapData();
		mapTileData = new BorderTileData(rom, mapData.borderTilePtr, mapData);
	}
	
	public MapData getMapData()
	{
		return mapData;
	}
	
	public BorderTileData getMapTileData()
	{
		return mapTileData;
	}
	
	public void save()
	{
		mapTileData.save();
	}
}
