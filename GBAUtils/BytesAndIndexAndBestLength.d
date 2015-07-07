module GBAUtils.BytesAndIndexAndBestLength;

public class BytesAndIndexAndBestLength
{
	private ubyte[] bytes;
	private uint index;
	private uint bestlength;

	public this(ubyte[] bytes, uint index, uint bestlength)
	{
		this.bytes = bytes;
		this.index = index;
	}

	public ubyte[] getBytes()
	{
		return bytes;
	}

	public uint getIndex()
	{
		return index;
	}

	public uint getBestLength()
	{
		return bestlength;
	}

	public void setBytes(ubyte[] bytes)
	{
		this.bytes = bytes;
	}

	public void setIndex(uint index)
	{
		this.index = index;
	}

	public void setBestLength(uint bestlength)
	{
		this.bestlength = bestlength;
	}
}
