module MapElements.WildDataHeader;

import GBAUtils.GBARom;

public class WildDataHeader
{
	public ubyte bBank, bMap;
	public uint pGrass, pWater, pTrees, pFishing;
	private GBARom rom;
	
	public this(GBARom rom)
	{
		this(rom,rom.internalOffset);
	}
	
	public this(GBARom rom, uint offset)
	{
		loadWildData(rom, offset);
	}
	
	public this(GBARom rom, ubyte bank, ubyte map)
	{
			this.rom = rom;
			
			bBank = bank;
			bMap = map;
			pGrass = 0;
			pWater = 0;
			pTrees = 0;
			pFishing = 0;
	}
	
	public static int getSize()
	{
		return 20;
	}
	
	private void loadWildData(GBARom rom, uint offset)
	{
		this.rom = rom;
		
		rom.Seek(offset);
		bBank = rom.readByte();
		bMap = rom.readByte();
		rom.internalOffset+=2; //Filler bytes
		pGrass = rom.getPointer();
		pWater = rom.getPointer();
		pTrees = rom.getPointer();
		pFishing = rom.getPointer();
	}
	
	public void save(uint headerloc)
	{
		rom.Seek(headerloc);
		rom.writeByte(bBank);
		rom.writeByte(bMap);
		rom.internalOffset+=2; //Filler bytes
		
		if(pGrass != 0)
			rom.writePointer(pGrass);
		else
			rom.writePointer(0);
		
		if(pWater != 0)
			rom.writePointer(pWater);
		else
			rom.writePointer(0);
		
		if(pTrees != 0)
			rom.writePointer(pTrees);
		else
			rom.writePointer(0);
		
		if(pFishing != 0)
			rom.writePointer(pFishing);
		else
			rom.writePointer(0);
	}
}
