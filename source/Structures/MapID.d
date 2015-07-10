module Structures.MapID;

public class MapID
{
    private ubyte bank, map;
    
    public this(ubyte bank, ubyte map)
    {
        this.bank = bank;
        this.map = map;
    }
    
    public ubyte getBank()
    {
        return bank;
    }
    
    public ubyte getMap()
    {
        return map;
    }
}
