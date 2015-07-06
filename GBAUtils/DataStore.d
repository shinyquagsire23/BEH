module GBAUtils.DataStore;

import IO.ini;
import std.string;
import std.conv;
import std.algorithm;
import std.file;
import GBAUtils.ROMManager;
import GBAUtils.GBARom;

public class DataStore
{

	// Everything we parse from the Ini
	public static Ini iP;
	private static bool passedTraits;

	// private Parser p;//For when we have YAML reading as well
	public static float Str2Float(string nkey)
	{
		int CommentIndex = -1;
		float ReturnValue = 0;
		string FinalString = "";
		try
		{
			FinalString = nkey;

			ReturnValue = parse!float(FinalString);
		}
		catch (Exception e)
		{
			// There's a chance the key may not exist, let's come up with a way
			// to handle this case
			//
			ReturnValue = 0;

		}
		return ReturnValue;
	}

	public static uint Str2Num(string nkey)
	{
		int CommentIndex = -1;
		uint ReturnValue = 0;
		string FinalString = "";
		try
		{
			FinalString = nkey;
			if (nkey.startsWith("0x"))
			{
				FinalString = nkey[2..nkey.length];
				ReturnValue = parse!uint(FinalString, 16);
			}
			else
				ReturnValue = parse!uint(FinalString);
		}
		catch (Exception e)
		{
			// There's a chance the key may not exist, let's come up with a way
			// to handle this case
			//
			ReturnValue = 0;

		}
		return ReturnValue;
	}

	public static float ReadFloatEntry(string Section, string key)
	{
		return Str2Float(iP.section(Section).value(key));
	}

	public static uint ReadNumberEntry(string Section, string key)
	{
		return Str2Num(iP.section(Section).value(key));
	}

	public static void WriteString(string section, string key, string value)
	{
		iP.section(section).setValue(key, value);
	}

	public static string ReadString(string Section, string key)
	{
		string nkey = iP.section(Section).value(key);

		int CommentIndex = -1;
		string ReturnValue = "";
		string FinalString = "";
	    FinalString = nkey;
		ReturnValue = FinalString;
		return ReturnValue;
	}

	public static bool ReadBoolean(string Section, string key)
	{
		return (ReadString(Section, key).toLower() == "true" || ReadString(Section, key).toLower() == "yes" || ReadString(Section, key).toLower() == "1");
	}
	
	public static void WriteBoolean(string Section, string key, bool boolean)
	{
		WriteString(Section, key, boolean ? "true" : "false");
	}
	
	void ReadData(string ROMHeader)
	{
		// Read all the entries.
		Inherit = iP.section(ROMHeader).value("Inherit");
		if (passedTraits == false && Inherit != "")
		{
			// Genes passed, let's snip the traits.
			passedTraits = true;
			ReadData(Inherit);// Grab inherited values
		}
		EngineVersion = ReadNumberEntry(ROMHeader, "Engine");
		Name = iP.section(ROMHeader).value("Name");
		Language = ReadNumberEntry(ROMHeader, "Language");
		Cries = ReadNumberEntry(ROMHeader, "Cries");
		MapHeaders = ReadNumberEntry(ROMHeader, "MapHeaders");
		Maps = ReadNumberEntry(ROMHeader, "Maps");
		MapLabels = ReadNumberEntry(ROMHeader, "MapLabels");
		MapLabels = ROMManager.getActiveROM().getPointer(MapLabels);
		MonsterNames = ReadNumberEntry(ROMHeader, "MonsterNames");
		MonsterBaseStats = ReadNumberEntry(ROMHeader, "MonsterBaseStats");
		MonsterDexData = ReadNumberEntry(ROMHeader, "MonsterDexData");
		TrainerClasses = ReadNumberEntry(ROMHeader, "TrainerClasses");
		TrainerData = ReadNumberEntry(ROMHeader, "TrainerData");
		TrainerPics = ReadNumberEntry(ROMHeader, "TrainerPics");
		TrainerPals = ReadNumberEntry(ROMHeader, "TrainerPals");
		TrainerPicCount = ReadNumberEntry(ROMHeader, "TrainerPicCount");
		TrainerBackPics = ReadNumberEntry(ROMHeader, "TrainerBackPics");
		TrainerBackPals = ReadNumberEntry(ROMHeader, "TrainerBackPals");
		TrainerBackPicCount = ReadNumberEntry(ROMHeader, "TrainerBackPicCount");
		ItemNames = ReadNumberEntry(ROMHeader, "ItemNames");
		MonsterPics = ReadNumberEntry(ROMHeader, "MonsterPics");
		MonsterPals = ReadNumberEntry(ROMHeader, "MonsterPals");
		MonsterShinyPals = ReadNumberEntry(ROMHeader, "MonsterShinyPals");
		MonsterPicCount = ReadNumberEntry(ROMHeader, "MonsterPicCount");
		MonsterBackPics = ReadNumberEntry(ROMHeader, "MonsterBackPics");
		HomeLevel = ReadNumberEntry(ROMHeader, "HomeLevel");
		SpriteBase = ReadNumberEntry(ROMHeader, "SpriteBase");
		SpriteColors = ReadNumberEntry(ROMHeader, "SpriteColors");
		SpriteNormalSet = ReadNumberEntry(ROMHeader, "SpriteNormalSet");
		SpriteSmallSet = ReadNumberEntry(ROMHeader, "SpriteSmallSet");
		SpriteLargeSet = ReadNumberEntry(ROMHeader, "SpriteLargeSet");
		NumSprites = ReadNumberEntry(ROMHeader, "NumSprites");
		WildPokemon = ROMManager.currentROM.getPointer(ReadNumberEntry(ROMHeader, "WildPokemon"));
		FontGFX = ReadNumberEntry(ROMHeader, "FontGFX");
		FontWidths = ReadNumberEntry(ROMHeader, "FontWidths");
		AttackNameList = ReadNumberEntry(ROMHeader, "AttackNameList");
		AttackTable = ReadNumberEntry(ROMHeader, "AttackTable");
		StartPosBoy = ReadNumberEntry(ROMHeader, "StartPosBoy");
		StartPosGirl = ReadNumberEntry(ROMHeader, "StartPosGirl");
		MainTSPalCount = ReadNumberEntry(ROMHeader, "MainTSPalCount");
		MainTSSize = ReadNumberEntry(ROMHeader, "MainTSSize");
		LocalTSSize = ReadNumberEntry(ROMHeader, "LocalTSSize");
		MainTSBlocks = ReadNumberEntry(ROMHeader, "MainTSBlocks");
		LocalTSBlocks = ReadNumberEntry(ROMHeader, "LocalTSBlocks");
		MainTSHeight = ReadNumberEntry(ROMHeader, "MainTSHeight");
		LocalTSHeight = ReadNumberEntry(ROMHeader, "LocalTSHeight");
		NumBanks = ReadNumberEntry(ROMHeader, "NumBanks");
		FreespaceStart = ReadNumberEntry(ROMHeader, "FreespaceStart");
		FreespaceByte = cast(ubyte) ReadNumberEntry(ROMHeader, "FreespaceByte");
		SpeciesNames = ReadNumberEntry(ROMHeader, "SpeciesNames");
		string[] mBS = ReadString(ROMHeader, "MapBankSize").split(",");
		MapBankSize = new uint[NumBanks];

		int i = 0;
		for (i = 0; i < mBS.length; i++)
		{
			MapBankSize[i] = parse!uint(mBS[i]);
		}
		// Name=ip.getString(ROMHeader, "Name");
		// Read the data for MEH
		string[] awmgfx = (ReadString(ROMHeader, "WorldMapGFX")).split(",");
		string[] wmdp = ReadString(ROMHeader, "WorldMapPal").split(",");
		string[] wmptm = ReadString(ROMHeader, "WorldMapTileMap").split(",");
		string[] wmpds = ReadString(ROMHeader, "WorldMapSlot").split(",");
		string[] ps = ReadString(ROMHeader, "WorldMapPalSize").split(",");
		WorldMapCount = ReadNumberEntry(ROMHeader, "WorldMapCount");
		// Grab them all

		WorldMapGFX = new uint[WorldMapCount];
		WorldMapPal = new uint[WorldMapCount];
		WorldMapTileMap = new uint[WorldMapCount];
		WorldMapSlot = new uint[WorldMapCount];
		WorldMapPalSize = new uint[WorldMapCount];
		for (i = 0; i < WorldMapCount; i++)
		{
			// Sometimes weird things happen

			WorldMapGFX[i] = Str2Num(awmgfx[i]);
			WorldMapPal[i] = Str2Num(wmdp[i]);
			WorldMapTileMap[i] = Str2Num(wmptm[i]);
			WorldMapSlot[i] = Str2Num(wmpds[i]);
			WorldMapPalSize[i] = Str2Num(ps[i]);
		}
		mehSettingShowSprites = ReadNumberEntry("MEH", "mehSettingShowSprites");
		mehUsePlugins = ReadNumberEntry("MEH", "mehUsePlugins");
		mehSettingCallScriptEditor = ReadString("MEH", "mehSettingCallScriptEditor");
		NumPokemon = ReadNumberEntry("MEH", "NumPokemon");
		mehPermissionTranslucency = ReadFloatEntry("MEH", "mehPermissionTranslucency");
		mehMetTripleTiles = ReadBoolean("MEH", "mehMetTripleTiles");
		mehTripleEditByte = ReadNumberEntry("MEH", "mehTripleEditByte");
		
		//if(mehTripleEditByte == 0)
			//mehTripleEditByte = 0x60;
	}
	
	public static string getBehaviorString(int num)
	{
		return ReadString(format("Behaviors%i", EngineVersion), format("b%i", num));
	}

	public static void WriteNumberEntry(string Section, string key, uint val)// Writes
	// can
	// happen
	// at
	// any
	// time...currently....
	// move
	// to
	// mapsave
	// function
	// for
	// later
	{

		string nkey = iP.section(Section).value(key);

		int CommentIndex = -1;
		uint ReturnValue = 0;
		string FinalString = "";
		try
		{
			FinalString = format("%i", val);
			iP.section(Section).setValue(key, FinalString);
		}
		catch (Exception e)
		{
			// There's a chance the key may not exist, let's come up with a way
			// to handle this case
			//
			ReturnValue = 0;

		}

	}

	this(string FilePath, string ROMHeader)
	{
	    iP = new Ini(FilePath);
		bDataStoreInited = true;
		passedTraits = false;
		Inherit = "";
		ReadData(ROMHeader);
	}

	public static uint EngineVersion;
	public static string Inherit;
	public static string Name;
	public static uint Language;
	public static uint Cries;
	public static uint MapHeaders;
	public static uint Maps;
	public static uint MapLabels;
	public static uint MonsterNames;
	public static uint MonsterBaseStats;
	public static uint MonsterDexData;
	public static uint TrainerClasses;
	public static uint TrainerData;
	public static uint TrainerPics;
	public static uint TrainerPals;
	public static uint TrainerPicCount;
	public static uint TrainerBackPics;
	public static uint TrainerBackPals;
	public static uint TrainerBackPicCount;
	public static uint ItemNames;
	public static uint MonsterPics;
	public static uint MonsterPals;
	public static uint MonsterShinyPals;
	public static uint MonsterPicCount;
	public static uint MonsterBackPics;
	public static uint HomeLevel;
	public static uint SpriteBase;
	public static uint SpriteColors;
	public static uint SpriteNormalSet;
	public static uint SpriteSmallSet;
	public static uint SpriteLargeSet;
	public static uint NumSprites;
	public static uint WildPokemon;
	public static uint FontGFX;
	public static uint FontWidths;
	public static uint AttackNameList;
	public static uint AttackTable;
	public static uint StartPosBoy;
	public static uint StartPosGirl;
	public static uint MainTSPalCount;
	public static uint MainTSSize;
	public static uint LocalTSSize;
	public static uint MainTSBlocks;
	public static uint LocalTSBlocks;
	public static uint MainTSHeight;
	public static uint LocalTSHeight;
	public static uint NumBanks;
	public static uint[] MapBankSize;
	public static uint[] WorldMapGFX;
	public static uint[] WorldMapPal;
	public static uint[] WorldMapSlot;
	public static uint[] WorldMapTileMap;
	public static uint WorldMapCount;
	public static uint[] WorldMapPalSize;
	public static float mehPermissionTranslucency;
	public static uint mehUsePlugins;
	public static uint mehSettingShowSprites;
	public static string mehSettingCallScriptEditor;
	public static uint mehTripleEditByte;
	public static uint FreespaceStart;
	public static ubyte FreespaceByte;
	public static uint NumPokemon = 412;
	public static uint SpeciesNames;
	public static bool mehMetTripleTiles = false;

	public static bool bDataStoreInited;// Not stored in INI :p

	public static void meetTripleTiles()
	{
		WriteBoolean("MEH", "mehMetTripleTiles", true);
	}

}
