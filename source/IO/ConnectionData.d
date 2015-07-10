module IO.ConnectionData;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import IO.MapHeader;
import IO.Connection;
import Structures.ConnectionType;
import MainGUI;

public class ConnectionData
{
    private uint originalSize;
    private GBARom rom;
    private MapHeader mapHeader;
    public uint pNumConnections;
    public uint pData;
    public Connection[] aConnections;
    
    public this(GBARom rom, MapHeader mHeader)
    {
        this.rom = rom;
        mapHeader = mHeader;
        load();
    }
    
    public void load()
    {
        rom.Seek(mapHeader.pConnect);
        pNumConnections = rom.getPointer(true);
        pData = rom.getPointer(true);
        
        rom.Seek(pData);
        for(int i = 0; i < pNumConnections; i++)
        {
            aConnections.length++;
            aConnections[i] = new Connection(rom);
        }
        
        originalSize = getConnectionDataSize();
    }
    
    public void save()
    {
        if(pData < 0x08000000)
            pData += 0x08000000;
        
        rom.Seek(mapHeader.pConnect);
        rom.writePointer(pNumConnections);
        rom.writePointer(pData);
        
        rom.Seek(pData);
        for(int i = 0; i < pNumConnections; i++)
        {
            aConnections[i].save();
        }
    }
    
    public uint getConnectionDataSize()
    {
        return cast(uint)aConnections.length * 12;
    }

    public void addConnection()
    {
        
    }
    
    public void addConnection(ConnectionType c, byte bank, byte map)
    {
        pNumConnections++;
        aConnections.length++;
        aConnections[pNumConnections] = new Connection(rom, c,bank,map); //Check
        rom.floodBytes(pData, rom.freeSpaceByte, originalSize);
        
        //TODO make this a setting, ie always repoint vs keep pointers
        if(originalSize < getConnectionDataSize())
        {
            pData = rom.findFreespace(DataStore.FreespaceStart, getConnectionDataSize());
        }
        
        //MainGUI.connectionsEditorPanel.loadConnections(MapIO.loadedMap); //TODO
    }
}
