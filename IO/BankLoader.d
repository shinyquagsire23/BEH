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
	    writefln("%x", DataStore.NumBanks);
		//ubyte[][] bankPointersPre = rom.loadArrayOfStructuredData(tblOffs, DataStore.NumBanks, 4);

        rom.Seek(tblOffs);
		bankPointers = new uint[](DataStore.NumBanks);
		bankTrees = new TreeIter[](DataStore.NumBanks);
		for(int bankNum = 0; bankNum < DataStore.NumBanks; bankNum++)
		{
			writefln("Loading banks into tree... %u", bankNum);
			bankPointers[bankNum] = rom.readLong() & 0x1FFFFFF;
			bankTrees[bankNum] = tree.addChild(root, format("%u", bankNum));
			//DefaultMutableTreeNode node = new DefaultMutableTreeNode(String.valueOf(bankNum));
			//model.insertNodeInto(node, root, root.getChildCount());
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
					
					//MapTreeNode node = new MapTreeNode(convMapName + " (" + mapNum + "." + miniMapNum + ")",mapNum,miniMapNum); //TODO: Pull PokeText from header
					//findNode(root,String.valueOf(mapNum)).add(node);
				}
				catch(Exception e)
				{
				    writeln(collectExceptionMsg(e));
				}
			}
			maps[mapNum] = mapList;
		}

		writeln("Refreshing tree...");
		/*model.reload(root);
		for (int i = 0; i < tree.getRowCount(); i++)
		{
			TreePath path = tree.getPathForRow(i);
			if (path != null)
			{
				//javax.swing.tree.TreeNode node = (javax.swing.tree.TreeNode) path.getLastPathComponent();
				//string str = node.toString();
				//DefaultTreeModel models = (DefaultTreeModel) tree.getModel();
				//models.valueForPathChanged(path, str);
			}
		}*/
		banksLoaded = true;
		//TODO: Load time, maybe.
	}

	/*private TreePath findPath(DefaultMutableTreeNode root, String s)
	{
		@SuppressWarnings("unchecked")
		Enumeration<DefaultMutableTreeNode> e = root.depthFirstEnumeration();
		while (e.hasMoreElements())
		{
			DefaultMutableTreeNode node = e.nextElement();
			if (node.toString().equalsIgnoreCase(s))
			{
				return new TreePath(node.getPath());
			}
		}
		return null;
	}
	
	private DefaultMutableTreeNode findNode(DefaultMutableTreeNode root, String s)
	{
		@SuppressWarnings("unchecked")
		Enumeration<DefaultMutableTreeNode> e = root.depthFirstEnumeration();
		while (e.hasMoreElements())
		{
			DefaultMutableTreeNode node = e.nextElement();
			if (node.toString().equalsIgnoreCase(s))
			{
				return node;
			}
		}
		return null;
	}
	
	public class MapTreeNode extends DefaultMutableTreeNode
	{
		public int bank;
		public int map;
		
		public MapTreeNode (String name, int bank2, int map2)
		{
			super(name);
			bank = bank2;
			map = map2;
		}
	}*/
}
