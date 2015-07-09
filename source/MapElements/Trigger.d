module MapElements.Trigger;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class Trigger : ISaveable
{
	public ubyte bX;
	public ubyte b2;
	public ubyte bY;
	public ubyte b4;
	public ushort h3;
	public ushort hFlagCheck;
	public ushort hFlagValue;
	public ushort h6;
	public uint pScript;

	private GBARom rom;

	void LoadTriggers(GBARom rom)
	{
		this.rom = rom;

		bX = rom.readByte();
		b2 = rom.readByte();
		bY = rom.readByte();
		b4 = rom.readByte();
		h3 = rom.readWord();
		hFlagCheck = rom.readWord();
		hFlagValue = rom.readWord();
		h6 = rom.readWord();
		pScript = rom.getPointer();
	}

	public this(GBARom rom, uint offset)
	{
		rom.Seek(offset);
		LoadTriggers(rom);
	}

	public this(GBARom rom)
	{
		LoadTriggers(rom);
	}

	public this(GBARom rom, ubyte x, ubyte y)
	{
		this.rom = rom;

		bX = 0;
		b2 = 0;
		bY = 0;
		b4 = 0;
		h3 = 0;
		hFlagCheck = 0;
		hFlagValue = 0;
		h6 = 0;
		pScript = 0;
	}

	public static uint getSize()
	{
		return 16;
	}

	public void save()
	{
		rom.writeByte(bX);
		rom.writeByte(b2);
		rom.writeByte(bY);
		rom.writeByte(b4);
		rom.writeWord(h3);
		rom.writeWord(hFlagCheck);
		rom.writeWord(hFlagValue);
		rom.writeWord(h6);
		rom.writePointer(pScript + (pScript == 0 ? 0 : 0x08000000));
	}
}
