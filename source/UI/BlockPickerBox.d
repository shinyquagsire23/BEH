/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * BlockPickerBox.d                                                           *
 * "The main GUI of BEH, actually does all the interfacing between data."     *
 *                                                                            *
 *                         This file is part of BEH.                          *
 *                                                                            *
 *       BEH is free software: you can redistribute it and/or modify it       *
 * under the terms of the GNU General Public License as published by the Free *
 *  Software Foundation, either version 3 of the License, or (at your option) *
 *                             any later version.                             *
 *                                                                            *
 *         BEH is distributed in the hope that it will be useful, but         *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *
 *   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licens  *
 *                             for more details.                              *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License along   *
 *      with BEH.  If not, see <http://www.gnu.org/licenses/>.                *
 *****************************************************************************/
module UI.BlockPickerBox;

import GBAUtils.DataStore;
import GBAUtils.Rectangle;
import GBAUtils.PixbufExtend;

import IO.MapIO;
import IO.Tileset;
import IO.Render.TilesetRenderer;
import Structures.EditMode;
import Structures.MapTile;
import Structures.SelectRect;
import UI.MapEditorBox;

import std.stdio;
import std.functional;
import std.algorithm;
import std.format;
import std.math;
import gtk.Image;
import gtk.Widget;
import gdk.DragContext;
import gdk.RGBA;
import gtkc.gdktypes;
import gdkpixbuf.Pixbuf;

//TODO Make this a base class for *any* tileset, ie movement perms
public class BlockPickerBox : Image
{
	public int baseSelectedTile;
	public int editorWidth = 8; //Editor width in 16x16 tiles
	public bool tripleSelectMode = false; //We really need events...
    public bool needsRedraw = false;
    private bool tiedToEditor = false;
	public Rectangle mouseTracker;
	public SelectRect selectBox;
	public MapEditorBox mapEditorBox;
	private Tileset globalTiles;
	private Tileset localTiles;

	static  Pixbuf imgBuffer = null;
	static Pixbuf dispImgBuffer = null;
	//public Color selectRectColor = MainGUI.uiSettings.cursorColor;

	public this(bool tied) 
	{
		tiedToEditor = tied;
		mouseTracker = new Rectangle(0,0,16,16);
		selectBox = new SelectRect(0,0,16,16);
	}

	public void SetRect(int width, int height) 
	{
		if (height > 16)
			height = 16;
		if (width > 16)
			width = 16;
		mouseTracker.height = height;
		mouseTracker.width = width;
	}

	public void SetRect() 
	{
		mouseTracker.height = 16;
		mouseTracker.width = 16;
	}

	int srcX;
	int srcY;

	public bool mouseDragged(int mx, int my, uint state) 
	{
		if(imgBuffer is null)
			return true;

		mouseTracker.x = mx;
		mouseTracker.y = my;

		int x = min(editorWidth-1, max(0, (mouseTracker.x / 16)));
		int y = min(imgBuffer.getHeight(), max(0, (mouseTracker.y / 16)));

				
		if(MapIO.DEBUG)
			writefln("%u %u %x", x, y, state);

		if(state)
			MapEditorBox.calculateSelectBox(x*16, y*16, selectBox);
				
		//MainGUI.setMouseCoordinates(mouseTracker.x / 16, mouseTracker.y / 16);
		renderDisplay();

		return true;
	}

	public bool mousePressed(int mx, int my, uint button) 
	{
		if(mouseTracker.x > (16 * editorWidth) - 1 || mouseTracker.y > ((DataStore.MainTSSize / editorWidth) * (DataStore.LocalTSSize / editorWidth) * 16) - 1)
			return false;

		int x = mx / 16;
		int y = my / 16;
				
		if(MapIO.DEBUG)
			writefln("%u %u %x", x, y, button);

				
		if(button) //Any button down
		{
			selectBox = new SelectRect(x * 16,y * 16,16,16);
			baseSelectedTile = x + (y * editorWidth);
		} 
				
        applySelectedTile();
		renderDisplay();

		return true;
	}

	public bool mouseRelease(int mx, int my, uint button) 
	{	
		if (button) //Any button down
		{
			mapEditorBox.calculateSelectBox(mx, my, selectBox);

			//Fill the tile buffer
			mapEditorBox.selectBuffer = new MapTile[][](selectBox.width / 16, selectBox.height / 16);
			mapEditorBox.bufferWidth = selectBox.width / 16;
			mapEditorBox.bufferHeight = selectBox.height / 16;
			mapEditorBox.selectBox = selectBox;
			for(int x = 0; x < mapEditorBox.bufferWidth; x++)
				for(int y = 0; y < mapEditorBox.bufferHeight; y++)
					mapEditorBox.selectBuffer[x][y] = new MapTile(cast(ushort)(baseSelectedTile + (x + (y * editorWidth))), cast(ushort)0xC); //TODO implement movement perms
		}
		renderDisplay();
		mapEditorBox.renderDisplay();

		return true;
	}

	public void selectBlock(ushort index)
	{
		baseSelectedTile = index;
		selectBox = new SelectRect((baseSelectedTile % editorWidth) * 16, (baseSelectedTile / editorWidth) * 16, 16-1, 16-1);
		renderDisplay();
	}

	public void setGlobalTileset(Tileset global) 
	{
		globalTiles = global;
	}
	
	public void setLocalTileset(Tileset local) 
	{
		localTiles = local;
	}
	
	public void tieToEditor()
	{
		tiedToEditor = true;
	}
	
	void renderDisplay() 
	{
		if (globalTiles !is null) 
		{
			if(needsRedraw) 
			{
				imgBuffer = TilesetRenderer.DrawTileset();
				needsRedraw = false;
			}

			dispImgBuffer = imgBuffer.copy();
			//dispImgBuffer.drawImage(imgBuffer.newSubpixbuf(0, 0, 128, 2048), 0, 0);
			
			//g.setColor(MainGUI.uiSettings.markerColor); //TODO
			dispImgBuffer.drawRect(selectBox.x, selectBox.y, (selectBox.realWidth)-1, (selectBox.realHeight)-1, 0, 255, 0);
			
			//g.setColor(selectRectColor); //TODO
			if(mouseTracker.width <0)
				mouseTracker.x -= abs(mouseTracker.width);
			if(mouseTracker.height <0)
				mouseTracker.y -= abs(mouseTracker.height);
			
			if(mouseTracker.x > editorWidth * 16)
				mouseTracker.x = editorWidth * 16;
			
			dispImgBuffer.drawRect(((mouseTracker.x / 16) % editorWidth) * 16,(mouseTracker.y / 16) * 16,16-1,16-1, 255, 0, 0); //TODO
		}

		//I'll always remember you Smeargle <3
		this.setFromPixbuf(dispImgBuffer);
	}

	//TODO: Use delegates here
    public void applySelectedTile() 
    {
    	//TODO: Events
    	if(tiedToEditor)
    	{
    		mapEditorBox.selectBuffer = new MapTile[][](1, 1);
    		mapEditorBox.selectBuffer[0][0] = new MapTile(cast(ushort)baseSelectedTile,cast(ushort)-1); //TODO Default movement perms
    		mapEditorBox.bufferWidth = 1;
    		mapEditorBox.bufferHeight = 1;
    		mapEditorBox.selectBox.width = 16;
    		mapEditorBox.selectBox.height = 16;
    		string k = format("Current Tile: 0x%08x", baseSelectedTile);
    		//MainGUI.lblTileVal.setText("Current Tile: 0x" + BitConverter.toHexString(baseSelectedTile)); //TODO
    	}
    	/*else
    	{
    		if(!tripleSelectMode)
    		{
    			BlockEditor.blockEditorPanel.setBlock(MapIO.blockRenderer.getBlock(baseSelectedTile));
    			long behavior = MapIO.blockRenderer.getBehaviorByte(baseSelectedTile);
    			BlockEditor.txtBehavior.setText(String.format("%08X", behavior));
    		}
    		else
    		{
    			BlockEditor.blockEditorPanel.setTriple(MapIO.blockRenderer.getBlock(baseSelectedTile));
    			baseSelectedTile = BlockEditor.blockEditorPanel.getBlock().blockID;
    			tripleSelectMode = false;
    			this.repaint();
    		}
    		BlockEditor.blockEditorPanel.repaint();
    		//BlockEditor.lblMeep.setText(String.format("0x%3s", Integer.toHexString(baseSelectedTile)).replace(' ', '0'));
    	}*/
    }
}
