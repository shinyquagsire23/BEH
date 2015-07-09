module MapElements.SpriteSign;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class SpriteSign : ISaveable
{
	//TODO I'm pretty sure some of these are word values...
	public ubyte bX;
	public ubyte b2;
	public ubyte bY;
	public ubyte b4;
	public ubyte b5;
	public ubyte b6;
	public ubyte b7;
	public ubyte b8;
	public uint pScript;
	private GBARom rom;

	public this(GBARom rom)
	{
		this(rom, rom.internalOffset);
	}

	public this(GBARom rom, int offset)
	{
		this.rom = rom;
		
		rom.Seek(offset);
		bX = rom.readByte();
		b2 = rom.readByte();
		bY = rom.readByte();
		b4 = rom.readByte();
		b5 = rom.readByte();
		b6 = rom.readByte();
		b7 = rom.readByte();
		b8 = rom.readByte();
		pScript = rom.getPointer();
	}

	public this(GBARom rom, byte x, byte y)
	{
		this.rom = rom;
		
		bX = x;
		b2 = 0;
		bY = y;
		b4 = 0;
		b5 = 0;
		b6 = 0;
		b7 = 0;
		b8 = 0;
		pScript = 0;
	}
	
	public static int getSize()
	{
		return 12;
	}

	public void save()
	{
		rom.writeByte(bX);
		rom.writeByte(b2);
		rom.writeByte(bY);
		rom.writeByte(b4);
		rom.writeByte(b5);
		rom.writeByte(b6);
		rom.writeByte(b7);
		rom.writeByte(b8);
		rom.writePointer(pScript + (pScript == 0 ? 0 : 0x08000000));
	}
}
