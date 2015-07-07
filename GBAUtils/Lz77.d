module GBAUtils.Lz77;

import GBAUtils.GBARom;
import GBAUtils.NewLz77;
import std.stdio;
import std.algorithm;

/**
 * Wrapper of debloat's Lz77 algorithm adapted for purposes within GBA ROM Hacking
 * @author maxamillion
 *
 */
public class Lz77
{
	public static int getUncompressedSize(GBARom ROM, int offset)
	{
		return NewLz77.getLz77DataLength(ROM, offset);
	}
	
	public static ubyte[] decompressLZ77(GBARom ROM, int offset)
	{
	    uint outputlen = 0;
	    ubyte[] decompressed = new ubyte[](NewLz77.getLz77DataLength(ROM, offset));
		NewLz77.decompressLZ77content(ROM.readBytes(offset, NewLz77.getLz77DataLength(ROM, offset)), NewLz77.getLz77DataLength(ROM, offset), decompressed, outputlen);
		return decompressed;
	}
	
	public static ubyte[] decompressLZ77(ubyte[] ROM, int offset)
	{
		uint outputlen = 0;
	    ubyte[] decompressed = new ubyte[](NewLz77.getLz77DataLength(ROM, offset));
	    writefln("%x", NewLz77.getLz77DataLength(ROM, offset));
		NewLz77.decompressLZ77content(ROM[offset..offset+min(ROM.length, NewLz77.getLz77DataLength(ROM, offset))], NewLz77.getLz77DataLength(ROM, offset), decompressed, outputlen);
		return decompressed;
	}
	
	public static ubyte[] compressLZ77(ubyte[] data)
	{
		byte[] bytes = null;
		return NewLz77.compressLZ10(data);
	}
}
