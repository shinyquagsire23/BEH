module Structures.MapID;

public class MapID
{
    private int bank, map;
    
    public this(int bank, int map)
    {
        this.bank = bank;
        this.map = map;
    }
    
    public int getBank()
    {
        return bank;
    }
    
    public int getMap()
    {
        return map;
    }
}
