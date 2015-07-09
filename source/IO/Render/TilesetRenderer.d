module IO.Render.TilesetRenderer;

import gdkpixbuf.Pixbuf;
import GBAUtils.DataStore;
import GBAUtils.PixbufExtend;
import IO.Tileset;
import IO.MapIO;
import std.algorithm;

public class TilesetRenderer
{
    static:
    public Tileset globalTiles;
	public Tileset localTiles;
	public Pixbuf imgBuffer = null;
	public uint renderWidth = 8; //Width in 16x16 tiles
	
    public void setGlobalTileset(Tileset global) 
    {
		globalTiles = global;
		MapIO.blockRenderer.setGlobalTileset(global);
	}

	public void setLocalTileset(Tileset local) 
	{
		localTiles = local;
		MapIO.blockRenderer.setLocalTileset(local);
	}

	public void DrawTileset() 
	{
		imgBuffer = RerenderTiles(imgBuffer, 0, DataStore.MainTSBlocks+0x200,true);//(DataStore.EngineVersion == 1 ? 0x11D : 0x200), true);
		//new org.zzl.minegaming.GBAUtils.PictureFrame(imgBuffer).show();
		//Dimension d = new Dimension(16*renderWidth,(DataStore.MainTSSize / renderWidth)*(DataStore.LocalTSSize / renderWidth) *16);
		//imgBuffer = new BufferedImage(d.width,d.height,BufferedImage.TYPE_INT_ARGB);
	}
	
	public Pixbuf RerenderSecondary(Pixbuf i) 
	{
		return RerenderTiles(i, DataStore.MainTSBlocks);
	}
	
	public Pixbuf RerenderTiles(Pixbuf i, int startBlock) 
	{
		return RerenderTiles(i, startBlock, DataStore.MainTSBlocks+(DataStore.EngineVersion == 1 ? 0x11D : 1024), false);
	}
	
	public Pixbuf RerenderTiles(Pixbuf b, int startBlock, int endBlock, bool completeRender) 
	{
		//startBlock = DataStore.MainTSBlocks;
		uint width = 16*renderWidth;
		uint height = max((endBlock / renderWidth) * 16, ((DataStore.MainTSSize / renderWidth)+(DataStore.LocalTSSize / renderWidth))*16);
		if(completeRender || b is null) 
		{
			if(DataStore.EngineVersion == 0)
				height = 3048;
			b = new Pixbuf(GdkColorspace.RGB, true, 8, width, height);
		}
		
		for(int i = startBlock; i < endBlock; i++) 
		{
			int x = (i % renderWidth) * 16;
			int y = (i / renderWidth) * 16;

			b.drawImage(MapIO.blockRenderer.renderBlock(i,true), x, y);
		}
		return b;
	}
}
