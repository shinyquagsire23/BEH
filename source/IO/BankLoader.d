/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * BankLoader.d                                                               *
 * "brief description of file"                                                *
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
module IO.BankLoader;

import std.stdio;
import std.bitmanip;
import std.array;
import std.format;
import std.exception;
import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ROMManager;
import gtk.TreeIter;
import MapStore;

public class BankLoader
{
    private static GBARom rom;
    int tblOffs;
    MapStore tree;
    TreeIter root;
    TreeIter[] bankTrees;
    private static uint mapNamesPtr;
    public static uint[][] maps;
    public static uint[] bankPointers;
    public static bool banksLoaded = false;
    public static string[uint] mapNames;
    
    public static void reset()
    {
        try
        {
            mapNamesPtr = rom.getPointer(DataStore.MapLabels);
            maps = uninitializedArray!(uint[][])();
            bankPointers = uninitializedArray!(uint[])();
            banksLoaded = false;
        }
        catch(Exception e)
        {
            
        }
    }

    this(int tableOffset, GBARom rom, MapStore tree, TreeIter root)
    {
        BankLoader.rom = rom;
        tblOffs = ROMManager.currentROM.getPointer(tableOffset);
        
        this.tree = tree;
        this.root = root;
        reset();
    }

    public void run()
    {
        rom.Seek(tblOffs);
        bankPointers = new uint[](DataStore.NumBanks);
        bankTrees = new TreeIter[](DataStore.NumBanks);
        for(int bankNum = 0; bankNum < DataStore.NumBanks; bankNum++)
        {
            writefln("Loading banks into tree... %u", bankNum);
            bankPointers[bankNum] = rom.readLong() & 0x1FFFFFF;
            bankTrees[bankNum] = tree.addChild(root, format("%u", bankNum));
        }

        maps = new uint[][](0xFF, 0xFF); //TODO: This is really hacky...
        foreach(int mapNum, uint l; bankPointers)
        {
            uint[] mapList = new uint[](DataStore.MapBankSize[mapNum]);
            for(int miniMapNum = 0; miniMapNum < DataStore.MapBankSize[mapNum]; miniMapNum++)
            {
                writefln("Loading maps into tree...\tBank %u, map %u", mapNum, miniMapNum);
                try
                {
                    uint dataPtr = rom.readLong(l + (miniMapNum * 4)) & 0x1FFFFFF;
                    mapList[miniMapNum] = dataPtr;
                    uint mapName = cast(uint)rom.readByte(dataPtr + 0x14);
                    //mapName -= 0x58; //TODO: Add Jambo51's map header hack
                    uint mapNamePokePtr = 0;
                    string convMapName = "";
                    if(DataStore.EngineVersion==1)
                    {
                        if(mapName !in mapNames)
                        {
                            mapNamePokePtr = rom.getPointer(DataStore.MapLabels + ((mapName - 0x58) * 4)); //TODO use the actual structure
                            convMapName = rom.readPokeText(mapNamePokePtr);
                            mapNames[mapName] = convMapName;
                        }
                        else
                        {
                            convMapName = mapNames[mapName];
                        }
                    }
                    else if(DataStore.EngineVersion==0)//RSE
                    {
                        if(mapName in mapNames)
                        {
                            mapNamePokePtr = rom.getPointer(DataStore.MapLabels + ((mapName * 8) + 4));
                            convMapName = rom.readPokeText(mapNamePokePtr);
                            mapNames[mapName] = convMapName;
                        }
                        else
                        {
                            convMapName = mapNames[mapName];
                        }
                    }
                    tree.addChild(bankTrees[mapNum], format("%s (%u.%u)", convMapName, mapNum, miniMapNum));
                }
                catch(Exception e)
                {
                    writeln(collectExceptionMsg(e));
                }
            }
            maps[mapNum] = mapList;
        }

        writeln("Refreshing tree...");
        banksLoaded = true;
        //TODO: Load time, maybe.
    }
}
