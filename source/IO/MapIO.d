/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapIO.d                                                                    *
 * "Contains various methods and data structures for loading and              *
 *  managing maps."                                                           *
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
module IO.MapIO;

import std.stdio;

import GBAUtils.DataStore;
import GBAUtils.ROMManager;

import IO.Render.BlockRenderer;
import IO.Map;
import IO.BorderMap;
import IO.BankLoader;
import IO.TilesetCache;
import IO.Render.TilesetRenderer;
import MapElements.WildData;
import MapElements.WildDataCache;
//import Plugins.PluginManager;
//import UI.DNPokePatcher;
//import UI.MainGUI;

public class MapIO //This whole file is just one big TODO
{
    public static Map loadedMap;
    
    public static BorderMap borderMap;
    public static int selectedBank = 0;
    public static int selectedMap = 0;
    public static int currentBank = 0;
    public static int currentMap = 0;
    public static bool doneLoading = false;
    public static WildData wildData;
    public static bool DEBUG = false;
    public static BlockRenderer blockRenderer;
    
    public static void loadMap(int bank, int map)
    {
        selectedMap = map;
        selectedBank = bank;
        loadMap();
    }
    
    public static void loadMap()
    {
        if(blockRenderer is null)
            blockRenderer = new BlockRenderer();
        
        uint offset = BankLoader.maps[selectedBank][selectedMap];
        loadMapFromPointer(offset, false);
        //MainGUI.updateTree();
    }
    
    public static void loadMapFromPointer(uint offset, bool justPointer)
    {
        if(blockRenderer is null)
            blockRenderer = new BlockRenderer();

        writefln("Loading map...");
        
        //MainGUI.setStatus("Loading Map..."); //TODO
        
        if (!justPointer) {
            currentBank = -1;
            currentMap = -1;
        }
        
        /*new Thread()
         {
         
         public void run()
         {*/ //TODO, actually thread this
        //Date d = new Date();
        doneLoading = false;
        if (loadedMap !is null)
            TilesetCache.get(loadedMap.getMapData().globalTileSetPtr).resetCustomTiles();

        writefln("Tileset loaded");
        
        loadedMap = new Map(ROMManager.getActiveROM(), offset);
        currentBank = selectedBank;
        currentMap = selectedMap;
        writefln("Map data loaded, switching tileset...");
        TilesetCache.switchTileset(loadedMap);
        writefln("Tileset cache swapped over, loading border map...");
        
        borderMap = new BorderMap(ROMManager.getActiveROM(), loadedMap);
        writefln("Border map loaded, loading global tileset...");
        /*MainGUI.reloadMimeLabels(); //TODO UI stuff
         MainGUI.mapEditorPanel.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
         MainGUI.mapEditorPanel.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));
         MainGUI.eventEditorPanel.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
         MainGUI.eventEditorPanel.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));*/
        
        TilesetRenderer.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
        writefln("Global tileset loaded to tileset renderer");
        TilesetRenderer.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));
        writefln("Local tileset loaded to tileset renderer");
        TilesetRenderer.DrawTileset();
        writefln("Tilesets rendered");
        /*MainGUI.tileEditorPanel.repaint();
         
         MainGUI.mapEditorPanel.setMap(loadedMap);//TODO UI stuff
         MainGUI.mapEditorPanel.DrawMap();
         MainGUI.mapEditorPanel.DrawMovementPerms();
         MainGUI.mapEditorPanel.repaint();
         
         MainGUI.eventEditorPanel.setMap(loadedMap);
         MainGUI.eventEditorPanel.Redraw = true;
         MainGUI.eventEditorPanel.DrawMap();
         MainGUI.eventEditorPanel.repaint();
         MainGUI.borderTileEditor.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
         MainGUI.borderTileEditor.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));
         MainGUI.borderTileEditor.setMap(borderMap);
         MainGUI.borderTileEditor.repaint();
         MainGUI.connectionsEditorPanel.loadConnections(loadedMap);
         MainGUI.connectionsEditorPanel.repaint();
         try {
         wildData = (WildData) WildDataCache.getWildData(currentBank, currentMap).clone();
         }
         catch (Exception e) {
         
         }
         
         MainGUI.loadWildPokemon();
         
         MainGUI.mapEditorPanel.repaint();*/
        //Date eD = new Date();
        //uint time = eD.getTime() - d.getTime();
        //MainGUI.setStatus("Done! Finished in " + (double) (time / 1000) + " seconds!"); //TODO, time loaded?
        doneLoading = true;
        
        //PluginManager.fireMapLoad(selectedBank, selectedMap);
        
        /*}
         }.start();*/
        //MainGUI.setStatus(MainGUI.mapBanks.getLastSelectedPathComponent().toString() + " loaded.");
    }
    
    public static string[] pokemonNames;
    
    public static void loadPokemonNames()
    {
        pokemonNames = new string[DataStore.NumPokemon];
        ROMManager.currentROM.Seek(ROMManager.currentROM.getPointer(DataStore.SpeciesNames));
        for (int i = 0; i < DataStore.NumPokemon; i++)
        {
            pokemonNames[i] = ROMManager.currentROM.readPokeText();
            writefln(pokemonNames[i]);
        }
        /*addStringArray(MainGUI.pkName1, pokemonNames); //TODO UI stuff
         addStringArray(MainGUI.pkName2, pokemonNames);
         addStringArray(MainGUI.pkName3, pokemonNames);
         addStringArray(MainGUI.pkName4, pokemonNames);
         addStringArray(MainGUI.pkName5, pokemonNames);
         addStringArray(MainGUI.pkName6, pokemonNames);
         addStringArray(MainGUI.pkName7, pokemonNames);
         addStringArray(MainGUI.pkName8, pokemonNames);
         addStringArray(MainGUI.pkName9, pokemonNames);
         addStringArray(MainGUI.pkName10, pokemonNames);
         addStringArray(MainGUI.pkName11, pokemonNames);
         addStringArray(MainGUI.pkName12, pokemonNames);*/
    }
    
    
    public static void openScript(int scriptOffset)
    {
        /*if (DataStore.mehSettingCallScriptEditor == null || DataStore.mehSettingCallScriptEditor.isEmpty())
         {
         int reply = JOptionPane.showConfirmDialog(null, "It appears that you have no script editor registered with MEH. Would you like to search for one?", "You need teh Script Editorz!!!", JOptionPane.YES_NO_OPTION);
         if (reply == JOptionPane.YES_OPTION)
         {
         FileDialog fd = new FileDialog(new Frame(), "Choose your script editor...", FileDialog.LOAD);
         fd.setFilenameFilter(new FilenameFilter()
         {
         public boolean accept(File dir, String name)
         {
         return ((System.getProperty("os.name").toLowerCase().contains("win") ? name.toLowerCase().endsWith(".exe") : name.toLowerCase().endsWith(".*")) || name.toLowerCase().endsWith(".jar"));
         }
         });
         
         fd.setVisible(true);
         String location = fd.getDirectory() + fd.getFile();
         if (location.isEmpty())
         return;
         
         if (!location.isEmpty())
         DataStore.mehSettingCallScriptEditor = location;
         }
         }
         
         try {
         Runtime r = Runtime.getRuntime();
         String s = (DataStore.mehSettingCallScriptEditor.toLowerCase().endsWith(".jar") ? "java -jar " : "") + DataStore.mehSettingCallScriptEditor + " \"" + ROMManager.currentROM.input_filepath.replace("\"", "") + "\" 0x" + String.format("%x", scriptOffset);
         r.exec(s);
         }
         catch (IOException e) {
         JOptionPane.showMessageDialog(null, "It seems that your script editor has gone missing. Look around for it and try it again. I'm sure it'll work eventually.");
         e.printStackTrace();
         }*/
    }
    
    /*public static void addStringArray(JComboBox b, string[] strs) {
     b.removeAllItems();
     for (String s : strs)
     b.addItem(s);
     b.repaint();
     }*/
    
    public static void repaintTileEditorPanel() {
        //MainGUI.tileEditorPanel.repaint();
    }
    
    public static void patchDNPokemon() {
        //DNPokePatcher n = new DNPokePatcher();
        //n.setVisible(true);
    }
    
    public static void saveMap() {
        /*MapIO.loadedMap.save();
         MapIO.borderMap.save();
         TilesetCache.get(MapIO.loadedMap.getMapData().globalTileSetPtr).save();
         TilesetCache.get(MapIO.loadedMap.getMapData().localTileSetPtr).save();
         MainGUI.connectionsEditorPanel.save(); // Save surrounding maps
         WildDataCache.setWildData(currentBank, currentMap, wildData);
         PluginManager.fireMapSave(MapIO.currentBank, MapIO.currentMap);*/
    }
    
    public static void saveROM() {
        /*PluginManager.fireROMSave();
         
         WildDataCache.save();
         ROMManager.getActiveROM().commitChangesToROMFile();*/
    }
    
    public static void saveAll() {
        saveMap();
        saveROM();
    }
}
