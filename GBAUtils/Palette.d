module GBAUtils.Palette;

import std.algorithm;
import std.stdio;
import std.conv;
import gdk.RGBA;
import GBAUtils.GBAImageType;
import GBAUtils.GBARom;

public class Palette
{
	private RGBA[] colors;
	private ubyte[] reds;
	private ubyte[] greens;
	private ubyte[] blues;
	
 	public this(GBAImageType type, ubyte[] data)
	{
		if(type == GBAImageType.c16)
		{
			colors = new RGBA[16];
			reds = new ubyte[16];
			greens = new ubyte[16];
			blues = new ubyte[16];
		}
		else
		{
			colors = new RGBA[256];
			reds = new ubyte[256];
			greens = new ubyte[256];
			blues = new ubyte[256];
		}
		
		for(int i = 0; i < data.length; i++)
		{
			int color = data[i] + (data[i + 1] << 8);
			ubyte r = (color & 0x1F) << 3;
			ubyte g = (color & 0x3E0) >> 2;
			ubyte b = (color & 0x7C00) >> 7;
			reds[i / 2] = r;
			greens[i / 2] = g;
			blues[i / 2] = b;
			colors[i / 2] = new RGBA(255/r,255/g,255/b);
			i++;
		}
	}
 	
 	public this(GBAImageType type, GBARom rom, int offset)
	{
		this(type,rom.getData()[offset..offset+(type == GBAImageType.c16 ? 32 : 512)]);
	}
	
	public RGBA getIndex(int i)
	{
		if(i > colors.length)
		{
			writefln("WARNING: Program attempted to grab color outside of palette range! Returning RGBA.BLACK...");
			return new RGBA(0,0,0);
		}
		
		return colors[i];
	}
	
	public uint getIndexAsInt(int i)
	{
		if(i > colors.length)
		{
			writefln("WARNING: Program attempted to grab color outside of palette range! Returning RGBA.BLACK...");
			return 0;
		}
		
		return to!uint(colors[i].red() * 255) + (to!uint(colors[i].green() * 255) << 8) + (to!uint(colors[i].blue() * 255) << 16);
	}
	
	public ubyte getRedValue(int i)
	{
		return reds[i];
	}
	
	public ubyte getGreenValue(int i)
	{
		return greens[i];
	}
	
	public ubyte getBlueValue(int i)
	{
		return blues[i];
	}
	
	public ubyte[] getReds()
	{
		return reds;
	}
	
	public ubyte[] getGreens()
	{
		return greens;
	}
	
	public ubyte[] getBlues()
	{
		return blues;
	}

	public void setReds(ubyte[] reds)
	{
		this.reds = reds;
		refreshColors();
	}
	
	public void setGreens(ubyte[] greens)
	{
		this.greens = greens;
		refreshColors();
	}
	
	public void setBlues(ubyte[] blues)
	{
		this.blues = blues;
		refreshColors();
	}
	
	public void setColors(ubyte[] reds, ubyte[] greens, ubyte[] blues)
	{
		this.reds = reds;
		this.blues = blues;
		this.greens = greens;
		refreshColors();
	}
	
	public void refreshColors()
	{
		for(int i = 0; i < 16; i++)
			colors[i] = new RGBA(255 / (reds[i] & 0xFF), 255 / (greens[i] & 0xFF), 255 / (blues[i] & 0xFF));
	}
	
	public uint getSize()
	{
		return cast(uint)colors.length;
	}

	public Palette xorRGBA(RGBA c)
	{
		for (int i = 0; i < 16; i++)
		{
			RGBA end = blend(c, colors[i]);

			ubyte red = to!ubyte(255 * end.red());
			ubyte blue = to!ubyte(255 * end.blue());
			ubyte green = to!ubyte(255 * end.green());

			reds[i] = red;
			greens[i] = green;
			blues[i] = blue;
		}
		
		refreshColors();
		return this;
	}
	
	private RGBA blend(RGBA c0, RGBA c1) 
	{
	    double totalAlpha = c0.alpha() + c1.alpha();
	    double weight0 = c0.alpha() / totalAlpha;
	    double weight1 = c1.alpha() / totalAlpha;

	    double r = weight0 * to!uint(255 * c0.red()) + weight1 * to!uint(255 * c1.red());
	    double g = weight0 * to!uint(255 * c0.green()) + weight1 * to!uint(255 * c1.green());
	    double b = weight0 * to!uint(255 * c0.blue()) + weight1 * to!uint(255 * c1.blue());
	    double a = max(c0.alpha(), c1.alpha());

	    return new RGBA(r, g, b); //TODO Alpha
	}
	
	public static RGBA[] gradient(RGBA c0, RGBA c1, int steps)
	{
		RGBA[] colors = new RGBA[steps];
		for(int i = 0; i < steps; i++ )
		{
			float n = cast(float) i / cast(float) (steps - 1);
			ubyte r =  to!ubyte((c0.red() * 255) * (1.0f - n) + (c1.red() * 255) * n);
			ubyte g =  to!ubyte((c0.green() * 255) * (1.0f - n) + (c1.green() * 255) * n);
			ubyte b =  to!ubyte((c0.blue() * 255) * (1.0f - n) + (c1.blue() * 255) * n);
			int a =  to!ubyte((c0.alpha() * 255) * (1.0f - n) + (c1.alpha() * 255) * n);
			colors[i] = new RGBA(255/r,255/g,255/b);
		}
		return colors;
	}
	
 	public void save(GBARom rom)
	{
		ubyte[] data = new ubyte[0x20];
		for(int i = 0; i < 16; i++)
		{
			int color = 0;
			color |= ((reds[i] >> 3) & 0x1F);
			color |= (((greens[i] >> 3) & 0x1F) << 5);
			color |= (((blues[i] >> 3) & 0x3F) << 10);
			color &= 0x7FFF;
			
			data[(i*2)+1] = ((color & 0xFF00) >> 8);
			data[(i*2)] = (color & 0xFF);
		}
		rom.writeBytes(data);
	}
}
