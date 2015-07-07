module Structures.MapTile;

public class MapTile
{
	private ubyte ID; 
	private ubyte Meta;
	public void SetID(ubyte i){
		ID=i;
		
	}
	public this(ubyte id, ubyte meta)
	{
		ID = id;
		Meta = meta;
	}
	public void SetMeta(ubyte meta){
		Meta=meta;
	}
	public ubyte getID()
	{
		return ID;
	}
	
	public ubyte getMeta()
	{
		return Meta;
	}

	public MapTile clone()
	{
		return new MapTile(ID,Meta);
	}
}
