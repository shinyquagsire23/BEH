module IO.Render.OverworldSpritesManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import IO.Render.OverworldSprites;
import gdkpixbuf.Pixbuf;

public class OverworldSpritesManager //TODO Thread this
{
	public static OverworldSprites[] Sprites = new OverworldSprites[256];
	private static GBARom rom;
	
	public this(GBARom rom)
	{
		OverworldSpritesManager.rom = rom;
	}

	public static Pixbuf GetImage(uint index)
	{
		if(Sprites[index] !is null)
			return Sprites[index].imgBuffer;
		else
			return loadSprite(index).imgBuffer;
	}

	public static OverworldSprites GetSprite(uint index)
	{
		if(Sprites[index] !is null)
			return Sprites[index];
		else
			return loadSprite(index);
	}
	
	public static OverworldSprites loadSprite(uint num)
	{
		uint ptr = rom.getPointer(DataStore.SpriteBase + (num * 4));
		Sprites[num] = new OverworldSprites(rom, ptr);
		return Sprites[num];
	}
	
	public void run()
	{
		if (DataStore.mehSettingShowSprites == 0)
			return;// Don't load if not enabled.
		for (int i = 0; i < DataStore.NumSprites; i++)
		{
				loadSprite(i);
		}
	}
}
