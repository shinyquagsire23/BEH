/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * ConnectionData.d                                                           *
 * "Stores multiple Connections for reading and writing to ROM."              *
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
        //Maps without connection data will have this by default
        if(mapHeader.pConnect == 0xf8000000)
        {
            originalSize = 0;
            return;
        }

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
        //Maps without connection data will have this by default
        if(mapHeader.pConnect == 0xf8000000)
        {
            return;
        }

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
        //Maps without connection data will have this by default
        if(mapHeader.pConnect == 0xf8000000)
        {
            mapHeader.pConnect = rom.findFreespace(8);
        }

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
