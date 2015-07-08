module MapElements.SpritesNPCManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.SpriteNPC;
import IO.Map;

public class SpritesNPCManager : ISaveable
{
	public SpriteNPC[] mapNPCs;
	private int internalOffset;
	private GBARom rom;
	private int originalSize;
	private Map loadedMap;
	
	public this(GBARom rom, Map m, int offset, int count)
	{
		this.rom = rom;
		internalOffset = offset;
		loadedMap = m;
		
		rom.Seek(offset);
		int i = 0;
		mapNPCs.length = 0;
		for (i = 0; i < count; i++)
		{
			mapNPCs[i] = new SpriteNPC(rom);
			mapNPCs.length++;
		}
		originalSize = getSize();
	}

	public int[] GetSpriteIndices()
	{
		int i = 0;
		int[] indices = new int[](mapNPCs.length);
		for (i = 0; i < mapNPCs.length; i++)
		{
			indices[i] = mapNPCs[i].bSpriteSet;
		}
		return indices;
	}

	public int getSpriteIndexAt(int x, int y)
	{
		int i = 0;
		for (i = 0; i < mapNPCs.length; i++)
		{
			if (mapNPCs[i].bX == x && mapNPCs[i].bY == y)
			{
				return i;
			}
		}

		return -1;

	}

	public int getSize()
	{
		return cast(uint)mapNPCs.length * SpriteNPC.getSize();
	}
	
	public void add(ubyte x, ubyte y)
	{
		mapNPCs ~= new SpriteNPC(rom, x, y);
	}

	public void remove(int x, int y)
	{
		std.algorithm.remove(mapNPCs, getSpriteIndexAt(x,y));
	}

	public void save()
	{
		rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);

		// TODO make this a setting, ie always repoint vs keep pointers
		int i = getSize();
		if (originalSize < getSize())
		{
			internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());

			if (internalOffset < 0x08000000)
				internalOffset += 0x08000000;
		}

		loadedMap.mapSprites.pNPC = internalOffset;
		loadedMap.mapSprites.bNumNPC = cast(ubyte)mapNPCs.length;

		rom.Seek(internalOffset);
		foreach(SpriteNPC n; mapNPCs)
			n.save();
	}
}
