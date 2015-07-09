module IO.Tile;

public class Tile
{
	private uint tileNum;
	private uint pal;
	public bool xFlip;
	public bool yFlip;
	public this(int tileNum, int palette, bool xFlip, bool yFlip)
	{
		if(tileNum > 0x3FF)
			tileNum = 0x3FF;
		
		if(palette > 12)
			palette = 12;
		
		this.tileNum = tileNum;
		this.pal = palette;
		this.xFlip = xFlip;
		this.yFlip = yFlip;
	}
	
	public int getTileNumber()
	{
		return tileNum;
	}
	
	public int getPaletteNum()
	{
		return pal;
	}
	
	public void setTileNumber(int number)
	{
		if(number > 0x3FF)
			number = 0x3FF;
		
		tileNum = number;
	}
	
	public void setPaletteNum(int palette)
	{
		if(palette > 12)
			palette = 12;
		
		pal = palette;
	}

	public Tile getNewInstance()
	{
		return new Tile(tileNum, pal, xFlip, yFlip);
	}
}
