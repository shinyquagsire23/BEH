module GBAUtils.GBAImage;

import gtkc.gdkpixbuf;
import gtkc.gdkpixbuftypes;
import gdkpixbuf.Pixbuf;
import gdk.RGBA;
import GBAUtils.Palette;
import std.stdio;

public class GBAImage
{
	private Palette p;
	private ubyte[] data;
	private uint size_x;
	private uint size_y;
	
	public this(ubyte[] imageBytes, Palette palette, uint size_x, uint size_y)
	{
		p = palette;
		data = imageBytes;
		this.size_x = size_x;
		this.size_y = size_y;
		//make sure verything is dandy..
	
	}
	
	public static GBAImage fromImage(Pixbuf im, Palette p)
	{
		int x = -1;
		int y = 0;
		int blockx = 0;
		int blocky = 0;
		ubyte[] data = new ubyte[(im.getWidth() * im.getHeight()) / 2];
		for(int i = 0; i < im.getWidth() * im.getHeight(); i++)
		{
			x++;
			if(x >= 8)
			{
				x = 0;
				y++;
			}
			if(y >= 8)
			{
				y = 0;
				blockx++;
			}
			if(blockx > (im.getWidth() / 8) - 1)
			{
				blockx = 0;
				blocky++;
			}
			RGBA c = new RGBA(0,0,0);//TODO//im.getRGB(x + (blockx * 8), y + (blocky * 8)), true);
			int pal = 0;
			for(int j = 0; j < 16; j++) 
			{
				RGBA col = p.getIndex(j);
				if(col == c)
				{
					pal = j;
				}
			}
			
			ubyte toWrite = data[i/2];
			if((i & 1) == 0)
				toWrite |= (pal & 0xF);
			else
				toWrite |= ((pal << 4) & 0xF0);
			
			data[i/2] = toWrite;
		}
		return new GBAImage(data, p, im.getWidth(), im.getHeight());
	}
	
	public Pixbuf getPixbuf()
	{
		return getPixbuf(true);
	}
	
	public Pixbuf getPixbuf(bool transparency)
	{
		if(p.getSize() == 16)
			return get16Image(p, transparency);
		else
			return get256Image(transparency);
	}
	
	public Pixbuf getPixbufFromPal(Palette pl)
	{
		return get16Image(pl, true);
	}
	
	public Pixbuf getPixbufFromPal(Palette pl, bool trans)
	{
		return get16Image(pl, trans);
	}
	
	private Pixbuf get16Image(Palette pl, bool transparency)
	{
		Pixbuf im = new Pixbuf(GdkColorspace.RGB, true, 8, size_x, size_y);
		int x = -1;
		int y = 0;
		int blockx = 0;
		int blocky = 0;
		for(int i = 0; i < data.length * 2; i++)
		{
			x++;
			if(x >= 8)
			{
				x = 0;
				y++;
			}
			if(y >= 8)
			{
				y = 0;
				blockx++;
			}
			if(blockx > (im.getWidth() / 8) - 1)
			{
				blockx = 0;
				blocky++;
			}
			
			int pal = data[i/2];
			if((i & 1) == 0)
				pal &= 0xF;
			else
				pal = (pal & 0xF0) >> 4;

			try
			{
				setPixel(im, x + (blockx * 8), y + (blocky * 8), pl.getRedValue(pal),pl.getGreenValue(pal), pl.getBlueValue(pal), (transparency && pal == 0 ? 0 : 255));
			}
			catch(Exception e){}
		}
		return im;
	}
	
	private Pixbuf get256Image(bool transparency)
	{
		Pixbuf im = new Pixbuf(GdkColorspace.RGB, true, 8, size_x, size_y);
		//Graphics g = im.getGraphics();
		int x = -1;
		int y = 0;
		int blockx = 0;
		int blocky = 0;
		for(int i = 0; i < data.length; i++)
		{
			x++;
			if(x >= 8)
			{
				x = 0;
				y++;
			}
			if(y >= 8)
			{
				y = 0;
				blockx++;
			}
			if(blockx > (im.getWidth() / 8) - 1)
			{
				blockx = 0;
				blocky++;
			}
			
			int pal = data[i];
			try
			{
				setPixel(im, x + (blockx * 8), y + (blocky * 8), p.getRedValue(pal),p.getGreenValue(pal), p.getBlueValue(pal), (transparency && pal == 0 ? 0 : 255));
			}
			catch(Exception e){}
		}
		return im;
	}
	
	private void setPixel(Pixbuf buf, uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte a)
	{
	    uint pixelPos = ((y * buf.getWidth) + x) * 4;
	    buf.getPixelsWithLength()[pixelPos+0] = r;
	    buf.getPixelsWithLength()[pixelPos+1] = g;
	    buf.getPixelsWithLength()[pixelPos+2] = b;
	    buf.getPixelsWithLength()[pixelPos+3] = a;
	}
	
	/*public Pixbuf getIndexedImage()
	{
		return getIndexedImage(p, true);
	}
	
	public Pixbuf getIndexedImage(Palette pl, bool transparency)
	{		
		IndexColorModel icm = new IndexColorModel(8,16,pl.getReds(),pl.getGreens(),pl.getBlues(), 0);
		Pixbuf indexedImage = new Pixbuf(size_x, size_y, Pixbuf.TYPE_BYTE_INDEXED, icm);
		int x = -1;
		int y = 0;
		int blockx = 0;
		int blocky = 0;
		for(int i = 0; i < data.length * 2; i++)
		{
			x++;
			if(x >= 8)
			{
				x = 0;
				y++;
			}
			if(y >= 8)
			{
				y = 0;
				blockx++;
			}
			if(blockx > (indexedImage.getWidth() / 8) - 1)
			{
				blockx = 0;
				blocky++;
			}
			
			int pal = data[i/2];
			if((i & 1) == 0)
				pal &= 0xF;
			else
				pal = (pal & 0xF0) >> 4;
				
			try
			{
				indexedImage.getRaster().getDataBuffer().setElem((x + (blockx * 8))+((y + (blocky * 8)) * indexedImage.getWidth()), pal);
			}
			catch(Exception e){}
		}
		return indexedImage;
		
	}*/ //TODO
	
 	public ubyte[] getRaw()
	{
		return data;
	}
}
