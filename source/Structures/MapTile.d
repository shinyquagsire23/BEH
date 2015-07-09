module Structures.MapTile;

public class MapTile
{
	private ushort ID; 
	private ushort Meta;
	
	public void SetID(ushort i)
	{
		ID=i;
	}
	
	public this(ushort id, ushort meta)
	{
		ID = id;
		Meta = meta;
	}
	
	public void SetMeta(ushort meta)
	{
		Meta=meta;
	}
	
	public ushort getID()
	{
		return ID;
	}
	
	public ushort getMeta()
	{
		return Meta;
	}

	public MapTile clone()
	{
		return new MapTile(ID,Meta);
	}
}
