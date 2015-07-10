module Structures.MapTile;

public class MapTile
{
    private ushort id; 
    private ushort metaData;
    
    public void SetID(ushort i)
    {
        id = i;
    }
    
    public this(ushort id, ushort meta)
    {
        this.id = id;
        metaData = meta;
    }
    
    public void SetMeta(ushort meta)
    {
        metaData = meta;
    }

    public ushort getID()
    {
        return id;
    }
    
    public ushort getMeta()
    {
        return metaData;
    }

    public MapTile clone()
    {
        return new MapTile(ID,Meta);
    }
}
