module MapElements.WildPokemon;

import GBAUtils.GBARom;
import GBAUtils.ISaveable;

public class WildPokemon : ISaveable
{
	private GBARom rom;
	public ubyte bMinLV, bMaxLV;
	public ushort wNum;
	
	public this(GBARom rom)
	{
		this.rom = rom;
		bMinLV = rom.readByte();
		bMaxLV = rom.readByte();
		wNum = rom.readWord();
	}
	
	public this(GBARom rom, ubyte minLV, ubyte maxLV, ushort pokemon)
	{
		this.rom = rom;
		bMinLV = minLV;
		bMaxLV = maxLV;
		wNum   = pokemon;
	}
	
	public static uint getSize()
	{
		return 4;
	}
	
	public void save()
	{
		rom.writeByte(bMinLV);
		rom.writeByte(bMaxLV);
		rom.writeWord(wNum);
	}
}
