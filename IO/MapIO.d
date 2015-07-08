module IO.MapIO;

import GBAUtils.DataStore;
import GBAUtils.ROMManager;

import IO.Render.BlockRenderer;
import IO.Map;
import IO.BorderMap;
import IO.BankLoader;
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
	public static BlockRenderer blockRenderer; //TODO = new

	public static void loadMap(int bank, int map)
	{
		selectedMap = map;
		selectedBank = bank;
		loadMap();
	}

	public static void loadMap()
	{
		uint offset = BankLoader.maps[selectedBank][selectedMap];
		loadMapFromPointer(offset, false);
        //MainGUI.updateTree();
	}

	public static void loadMapFromPointer(uint offs, bool justPointer)
	{
		/*MainGUI.setStatus("Loading Map...");
		final uint offset = offs;

		if (!justPointer) {
			currentBank = -1;
			currentMap = -1;
		}

		new Thread()
		{

			public void run()
			{
				Date d = new Date();
				doneLoading = false;
				if (loadedMap != null)
					TilesetCache.get(loadedMap.getMapData().globalTileSetPtr).resetCustomTiles();

				loadedMap = new Map(ROMManager.getActiveROM(), (int) (offset));
				currentBank = selectedBank;
				currentMap = selectedMap;
				TilesetCache.switchTileset(loadedMap);

				borderMap = new BorderMap(ROMManager.getActiveROM(), loadedMap);
				MainGUI.reloadMimeLabels();
				MainGUI.mapEditorPanel.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
				MainGUI.mapEditorPanel.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));
				MainGUI.eventEditorPanel.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
				MainGUI.eventEditorPanel.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));

				MainGUI.tileEditorPanel.setGlobalTileset(TilesetCache.get(loadedMap.getMapData().globalTileSetPtr));
				MainGUI.tileEditorPanel.setLocalTileset(TilesetCache.get(loadedMap.getMapData().localTileSetPtr));
				MainGUI.tileEditorPanel.DrawTileset();
				MainGUI.tileEditorPanel.repaint();

				MainGUI.mapEditorPanel.setMap(loadedMap);
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

				MainGUI.mapEditorPanel.repaint();
				Date eD = new Date();
				uint time = eD.getTime() - d.getTime();
				//MainGUI.setStatus("Done! Finished in " + (double) (time / 1000) + " seconds!");
				doneLoading = true;

				PluginManager.fireMapLoad(selectedBank, selectedMap);

			}
		}.start();
        MainGUI.setStatus(MainGUI.mapBanks.getLastSelectedPathComponent().toString() + " loaded.");*/
	}

	public static string[] pokemonNames;

	public static void loadPokemonNames()
	{
		/*pokemonNames = new String[DataStore.NumPokemon];
		ROMManager.currentROM.Seek(ROMManager.currentROM.getPointerAsInt(DataStore.SpeciesNames));
		for (int i = 0; i < DataStore.NumPokemon; i++)
		{
			pokemonNames[i] = ROMManager.currentROM.readPokeText();
			System.out.println(pokemonNames[i]);
		}
		addStringArray(MainGUI.pkName1, pokemonNames);
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
