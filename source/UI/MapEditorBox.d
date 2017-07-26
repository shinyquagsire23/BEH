/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapEditorBox.d                                                             *
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
module UI.MapEditorBox;

import GBAUtils.DataStore;
import GBAUtils.Rectangle;
import GBAUtils.PixbufExtend;

import IO.Map;
import IO.MapIO;
import IO.Tileset;
import IO.Render.TilesetRenderer;
import Structures.EditMode;
import Structures.MapTile;
import Structures.SelectRect;
import UI.BlockPickerBox;

import std.stdio;
import std.functional;
import std.math;
import gtk.Image;
import gtk.Widget;
import gdk.DragContext;
import gdk.RGBA;
import gtkc.gdktypes;
import gdkpixbuf.Pixbuf;

public class MapEditorBox : Image
{
	private static MapEditorBox instance = null;

	public static MapEditorBox getInstance() 
	{
		if (instance is null) 
		{
			instance = new MapEditorBox();
		}
		return instance;
	}

	private Tileset globalTiles;
	private Tileset localTiles;
	public BlockPickerBox blockPickerBox;
	public Map map;
	static Rectangle mouseTracker;
	public static MapTile[][] selectBuffer;
	public static SelectRect selectBox;

	public static Pixbuf gcBuff;
	static  Pixbuf imgBuffer = null;
	static Pixbuf permImgBuffer = null;
	static Pixbuf dispImgBuffer = null;
	
	public static bool needsRedraw = true;
	public static bool renderPalette = false;
	public static bool renderTileset = false;
	public static int bufferWidth = 1;
	public static int bufferHeight = 1;
	public static uint lastState = 0;

	

	//	public RGBA selectRectColor = new RGBA(0,0,0,0);//MainGUI.uiSettings.cursorColor; //TODO
	private static EditMode currentMode = EditMode.TILES;
	
	public this() 
	{
		mouseTracker = new Rectangle(0,0,16,16);
		selectBox = new SelectRect(0,0,16,16);
		selectBuffer = new MapTile[][](1,1);
		selectBuffer[0][0] = new MapTile(0,0xC);
		//this.addMouseMotionListener(this);
	}
	
	/*public void mousePressed(MouseEvent e) //TODO
	{
		if (map == null || !isInBounds(x,y))
			return;
		
		if(MapIO.DEBUG)
			writefln(e.getButton());
		
		int x = selectBox.x / 16;
		int y = selectBox.y / 16;
		
		if(e.getButton() == 1) {
			selectRectColor = MainGUI.uiSettings.markerColor;
			drawTiles(x, y);
			map.isEdited = true;
			//DrawMap();
		}
		else if(e.getButton() == 3) {
			selectBox = new SelectRect(x * 16,y * 16,16,16);
			selectRectColor = MainGUI.uiSettings.cursorSelectColor;
			
			if(currentMode == EditMode.TILES) {
				MainGUI.tileEditorPanel.baseSelectedTile = map.getMapTileData().getTile(x, y).getID();
				MainGUI.lblTileVal.setText("Current Tile: 0x" + BitConverter.toHexString(MainGUI.tileEditorPanel.baseSelectedTile));
			}
			else if(currentMode == EditMode.MOVEMENT) {
				PermissionTilePanel.baseSelectedTile = map.getMapTileData().getTile(x, y).getMeta();
				MainGUI.lblTileVal.setText("Current Perm: 0x" + BitConverter.toHexString(MainGUI.tileEditorPanel.baseSelectedTile));
			}
			
			//MapIO.repaintBlockPickerBox();
		}
		
		/*
		 if(e.getButton() == 3) {
		 selectBox = new SelectRect((x / 16) * 16,(y / 16) * 16,16,16);
		 bufferWidth = 1;
		 bufferHeight = 1;
		 mouseTracker.x = x - (bufferWidth * 8);
		 mouseTracker.y = y - (bufferHeight * 8);
		 selectRectColor = MainGUI.uiSettings.cursorSelectColor;
		 }* /
		
		MainGUI.setMouseCoordinates(mouseTracker.x / 16, mouseTracker.y / 16);
		repaint();
	}*/
	
	/*public void mouseReleased(MouseEvent e) //TODO
	{
		if (map == null)
			return;
		
		selectRectColor = MainGUI.uiSettings.cursorColor;
		
		if(e.getButton() == 3) 
		{
			if(isInBounds(x,y)) 
			{
				calculateSelectBox(e,selectBox);
				//Fill the tile buffer
				selectBuffer = new MapTile[selectBox.width / 16][selectBox.height / 16];
				bufferWidth = selectBox.width / 16;
				bufferHeight = selectBox.height / 16;
				for(int x = 0; x < bufferWidth; x++)
					for(int y = 0; y < bufferHeight; y++)
						selectBuffer[x][y] = map.getMapTileData().getTile(selectBox.x / 16 + x, selectBox.y / 16 + y).dup();
			}
		}
		repaint();
	}*/
	
	/*public void mouseEntered(MouseEvent e) //TODO
	{
		if (map == null)
			return;
		
		//if(isInBounds(mouseTracker.x,mouseTracker.y)) //TODO, mouse pos tracking from MainGUI
			//MainGUI.setMouseCoordinates(mouseTracker.x / 16, mouseTracker.y / 16);
		repaint();
	}*/
	
	/*public void mouseExited(MouseEvent e) { //TODO
		/*		if (map == null)
		 return;
		 
		 if(isInBounds(mouseTracker.x,mouseTracker.y))
		 MainGUI.setMouseCoordinates(mouseTracker.x / 16, mouseTracker.y / 16);
		 repaint();* /
	}*/
	
	public bool mouseDragged(int mx, int my, uint state) 
	{
		mouseTracker.x = mx;
		mouseTracker.y = my;
		
		if(map is null || !isInBounds(mouseTracker.x,mouseTracker.y))
			return false;
		
		int x = (mouseTracker.x / 16);
		int y = (mouseTracker.y / 16);
		
		if (state & GdkModifierType.BUTTON1_MASK)  
		{
			if(MapIO.DEBUG)
				writefln("left click");
			moveSelectRect(mx,my);
			drawTiles(x, y);
			map.isEdited = true;
			//MapIO.repaintBlockPickerBox();
		}
		else if (state & GdkModifierType.BUTTON3_MASK)
		{
			if(isInBounds(mx,my))
				calculateSelectBox(mx,my,selectBox);
		}
		else
			moveSelectRect(mx,my);
		
		//MainGUI.setMouseCoordinates(x, y); //TODO

		if(selectBox.moved)
			renderDisplay();
		lastState = state;
		return true;
	}

	public bool mousePressed(int mx, int my, uint button)
	{
		mouseTracker.x = mx;
		mouseTracker.y = my;
		
		if(map is null || !isInBounds(mouseTracker.x,mouseTracker.y))
			return false;
		
		int x = (mouseTracker.x / 16);
		int y = (mouseTracker.y / 16);
		
		if (button == 1)  
		{
			if(MapIO.DEBUG)
				writefln("left click");
			moveSelectRect(mx,my);
			drawTiles(x, y);
			map.isEdited = true;
			//MapIO.repaintBlockPickerBox();
		}
		else if (button == 3)  
		{
			if(MapIO.DEBUG)
				writefln("right click");

			selectBox = new SelectRect(x * 16,y * 16,16,16);
			//selectRectColor = MainGUI.uiSettings.cursorSelectColor;
			
			if(currentMode == EditMode.TILES) {
				//MainGUI.tileEditorPanel.baseSelectedTile = map.getMapTileData().getTile(x, y).getID();
				//MainGUI.lblTileVal.setText("Current Tile: 0x" + BitConverter.toHexString(MainGUI.tileEditorPanel.baseSelectedTile));
			}
			else if(currentMode == EditMode.MOVEMENT) {
				//PermissionTilePanel.baseSelectedTile = map.getMapTileData().getTile(x, y).getMeta();
				//MainGUI.lblTileVal.setText("Current Perm: 0x" + BitConverter.toHexString(MainGUI.tileEditorPanel.baseSelectedTile));
			}
			//MapIO.repaintBlockPickerBox();
		}
		
		//MainGUI.setMouseCoordinates(x, y); //TODO
		renderDisplay();
		return true;
	}

	public bool mouseRelease(int mx, int my, uint button)
	{
		mouseTracker.x = mx;
		mouseTracker.y = my;
		
		if(map is null || !isInBounds(mouseTracker.x,mouseTracker.y))
			return false;
		
		//int x = (mouseTracker.x / 16);
		//int y = (mouseTracker.y / 16);
		
		//selectRectColor = MainGUI.uiSettings.cursorColor;
		
		if(button == 3) 
		{
			if(isInBounds(mx,my)) 
			{
				calculateSelectBox(mx,my,selectBox);
				//Fill the tile buffer
				selectBuffer = new MapTile[][](cast(ushort)(selectBox.width / 16), cast(ushort)(selectBox.height / 16));
				bufferWidth = selectBox.width / 16;
				bufferHeight = selectBox.height / 16;
				for(int x = 0; x < bufferWidth; x++)
					for(int y = 0; y < bufferHeight; y++)
						selectBuffer[x][y] = map.getMapTileData().getTile(selectBox.x / 16 + x, selectBox.y / 16 + y).clone();

				blockPickerBox.selectBlock(map.getMapTileData().getTile(selectBox.x / 16, selectBox.y / 16 ).getID());
			}
		}
		
		//MainGUI.setMouseCoordinates(x, y); //TODO
		renderDisplay();
		return true;
	}
	
	/*public void mouseMoved(MouseEvent e) { //TODO
		if(map == null || !isInBounds(x,y))
			return;
		
		moveSelectRect(e);
		repaint();
	}*/
	
	public bool isInBounds(int x, int y)
	{
		if (x < 0 || x >= (map.getMapData().mapWidth * 16) || y < 0 || y >= (map.getMapData().mapHeight * 16))
			return false;
		return true;
	}
	
	public void moveSelectRect(uint x, uint y)
	{
		if(isInBounds(x, y))
		{
			mouseTracker.x = x;
			mouseTracker.y = y;
			//MainGUI.setMouseCoordinates(mouseTracker.x / 16, mouseTracker.y / 16); //TODO
		}

		uint movx, movy;
		movx = ((mouseTracker.x / 16) * 16);
		movy = ((mouseTracker.y / 16) * 16);

		selectBox.moved = (selectBox.x != movx || selectBox.y != movy);

		selectBox.x = movx;
		selectBox.y = movy;
		selectBox.startX = movx;
		selectBox.startY = movx;
		
		/*		if(selectBox.width > 16)
		 selectBox.x -= selectBox.width / 2;
		 if(selectBox.height > 16)
		 selectBox.y -= selectBox.height / 2;*/
		
		if(selectBox.realWidth + selectBox.x > (map.getMapData().mapWidth * 16 - 1))
			selectBox.width = cast(int) ((map.getMapData().mapWidth * 16) - selectBox.x);
		else
			selectBox.width = selectBox.realWidth;
		if(selectBox.realHeight + selectBox.y > (map.getMapData().mapHeight * 16 - 1))
			selectBox.height = cast(int) ((map.getMapData().mapHeight * 16) - selectBox.y);
		else
			selectBox.height = selectBox.realHeight;
	}
	
	public void drawTiles(int x, int y)
	{
		for(int DrawX=0; DrawX < bufferWidth; DrawX++) 
		{
			for(int DrawY = 0; DrawY < bufferHeight; DrawY++) 
			{
				if (selectBox.x + DrawX * 16 < (map.getMapData().mapWidth * 16 - 1) && selectBox.y + DrawY * 16 < (map.getMapData().mapHeight * 16 - 1)) {
					//Tiles multi-select will grab both the tiles and the meta, 
					//while movement editing will only select metas.
					if(currentMode == EditMode.TILES) 
					{
						map.getMapTileData().getTile(selectBox.x/16 + DrawX, selectBox.y/16 + DrawY).SetID(selectBuffer[DrawX][DrawY].getID());
						if(selectBuffer[DrawX][DrawY].getMeta() >= 0)
							map.getMapTileData().getTile(selectBox.x/16 + DrawX, selectBox.y/16 + DrawY).SetMeta(selectBuffer[DrawX][DrawY].getMeta()); //TODO Allow for tile-only selection. Hotkeys?
						drawTile(selectBox.x/16 + DrawX,selectBox.y/16 + DrawY);
					}
					else if(currentMode == EditMode.MOVEMENT) 
					{
						map.getMapTileData().getTile(selectBox.x/16+DrawX, selectBox.y/16+DrawY).SetMeta(selectBuffer[DrawX][DrawY].getMeta());
						drawTile(selectBox.x/16+DrawX,selectBox.y/16+DrawY);
					}
				}
			}
		}
	}
	
	public static void calculateSelectBox(uint mx, uint my, SelectRect givenBox) {
		//Round the values to multiples of 16
		int x = (mx / 16) * 16;
		int y = (my / 16) * 16;

		uint movx, movy;
		movx = ((mouseTracker.x / 16) * 16);
		movy = ((mouseTracker.y / 16) * 16);
		
		givenBox.moved = (selectBox.x != movx || selectBox.y != movy);

		givenBox.x = movx;
		givenBox.y = movy;
		givenBox.startX = ((givenBox.startX / 16) * 16);
		givenBox.startY = ((givenBox.startY / 16) * 16);
		givenBox.width = ((givenBox.width / 16) * 16);
		givenBox.height = ((givenBox.height / 16) * 16);
		givenBox.realWidth = ((givenBox.realWidth / 16) * 16);
		givenBox.realHeight = ((givenBox.realHeight / 16) * 16);
		
		//Get width/height
		givenBox.width = givenBox.realWidth = (x - givenBox.startX);
		givenBox.height = givenBox.realHeight = (y - givenBox.startY);
		
		//If our selection is negative, adjust it to be positive 
		//starting from the position the mouse was released
		if (givenBox.realWidth < 0)
			givenBox.x = x;
		else
			givenBox.x = givenBox.startX;

		if (givenBox.realHeight < 0)
			givenBox.y = y;
		else
			givenBox.y = givenBox.startY;
		
		givenBox.width = givenBox.realWidth = abs(givenBox.realWidth) + 16;
		givenBox.height = givenBox.realHeight = abs(givenBox.realHeight) + 16;
		
		//Minimum sizes
		if(givenBox.realWidth == 0)
			givenBox.width = givenBox.realWidth = 16;
		if(givenBox.realHeight == 0)
			givenBox.height = givenBox.realHeight = 16;
	}
	
	public void setGlobalTileset(Tileset global) 
    {
		globalTiles = global;
		MapIO.blockRenderer.setGlobalTileset(global);
		blockPickerBox.setGlobalTileset(global);
	}
	
	public void setLocalTileset(Tileset local) 
    {
		localTiles = local;
		MapIO.blockRenderer.setLocalTileset(local);
		blockPickerBox.setLocalTileset(local);
	}
	
	public void setMap(Map m) 
    {
		map = m;
		this.needsRedraw = true;
	}
	
	public void DrawMap() 
	{
		imgBuffer = Map.renderMap(map, true);
	}
	
	public void DrawMovementPerms() 
    {
		/*try {
			permImgBuffer = createImage(cast(int) map.getMapData().mapWidth * 16,
				cast(int) map.getMapData().mapHeight * 16);
			for (int y = 0; y < map.getMapData().mapHeight; y++) {
				for (int x = 0; x < map.getMapData().mapWidth; x++) {
					drawTile(x,y,EditMode.MOVEMENT);
				}
			}
		}
		catch (Exception e) {
			if(MapIO.DEBUG)
				e.printStackTrace();
		}*/ //TODO
	}
	
	void drawTile(int x, int y) {
		drawTile(x,y,currentMode);
	}
	
	void drawTile(int x, int y, EditMode m) 
	{
		if(m == EditMode.TILES) 
		{
			//gcBuff = imgBuffer.getGraphics();
			int TileID=(map.getMapTileData().getTile(x, y).getID());
			int srcX=(TileID % TilesetRenderer.renderWidth) * 16;
			int srcY = (TileID / TilesetRenderer.renderWidth) * 16; //TODO
			imgBuffer.drawImage(TilesetRenderer.imgBuffer.newSubpixbuf(srcX, srcY, 16, 16), x * 16, y * 16);
		}
		else if(m == EditMode.MOVEMENT) 
		{
			int TileMeta=(map.getMapTileData().getTile(x, y).getMeta());
			
			//Clear the rectangle since transparency can draw ontop of itself
			permImgBuffer.fillRect(x * 16, y * 16, 16, 16, 0, 0, 0, 0);
			//permImgBuffer.drawImage(PermissionTilePanel.imgPermissions.newSubpixbuf(TileMeta*16, 0, 16, 16), x * 16, y * 16); //TODO
		}
		//repaint();* //TODO
        setFromPixbuf(imgBuffer);
	}
	
	public static Pixbuf getMapImage() 
	{
		return imgBuffer;
	}

	//TODO: This is horribly slow, use OpenGL or similar.
	public void renderDisplay() 
	{ 
		if (globalTiles !is null) 
		{
			if(MapEditorBox.needsRedraw) 
			{
				DrawMap();
				DrawMovementPerms();
				MapEditorBox.needsRedraw = false;
			}

			if(currentMode != EditMode.TILES) 
			{
				dispImgBuffer = imgBuffer.copy();
				//dispImgBuffer.drawImage(imgBuffer, 0, 0);

				//TODO
				/*AlphaComposite ac = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, DataStore.mehPermissionTranslucency);
				g2.setComposite(ac);
				g2.drawImage(permImgBuffer, 0, 0, this);*/
			}
			else
				dispImgBuffer = imgBuffer.copy();
			
			if(renderPalette) 
			{
				int x = 0;
				for(int i = 0; i < 16; i++) 
				{
					while(x < 16) 
					{
						RGBA color = globalTiles.getPalette(MapIO.blockRenderer.currentTime)[i].getIndex(x);
						dispImgBuffer.fillRect(x*8, i*8, 8, 8, cast(ubyte)(color.red() * 255), cast(ubyte)(color.green() * 255), cast(ubyte)(color.blue() * 255));
						x++;
					}
					x = 0;
				}
				
				x = 0;
				for(int i = 0; i < 16; i++) 
				{
					while(x < 16) 
					{
						RGBA color = localTiles.getPalette(MapIO.blockRenderer.currentTime)[i].getIndex(x);
						dispImgBuffer.fillRect(128+(x*8), i*8, 8, 8, cast(ubyte)(color.red() * 255), cast(ubyte)(color.green() * 255), cast(ubyte)(color.blue() * 255));
						x++;
					}
					x = 0;
				}
			}

			//TODO
			if(renderTileset)
			{
				//g.drawImage(MainGUI.tileEditorPanel.RerenderTiles(BlockPickerBox.imgBuffer, 255),0,0,this);
				for(int i = 0; i < 13; i++)
				{
					//g.drawImage(globalTiles.getTileSet(i),i*128,0,this);
					//g.drawImage(localTiles.getTileSet(i),i*128,DataStore.MainTSHeight + 8,this);
				}
			}
			
			
			//g.setColor(selectRectColor); //TODO
			if (mouseTracker.width < 0)
				mouseTracker.x -= abs(mouseTracker.width);
			if (mouseTracker.height < 0)
				mouseTracker.y -= abs(mouseTracker.height);

			dispImgBuffer.drawRect(selectBox.x,selectBox.y,selectBox.width-1,selectBox.height-1, 255, 0, 0);
			this.setFromPixbuf(dispImgBuffer);
		}
	}
	
	public void reset() {
		globalTiles = null;
		localTiles = null;
		map = null;
		mouseTracker.x = 0;
		mouseTracker.y = 0;
		//MainGUI.setMouseCoordinates(0, 0); //TODO
		
		selectBox.x = 0;
		selectBox.y = 0;
		selectBox.startX = 0;
		selectBox.startY = 0;
		selectBox.width = 16;
		selectBox.height = 16;
		selectBox.realWidth = 16;
		selectBox.realHeight = 16;
		//repaint(); //TODO
	}
	
	public static void setMode(EditMode tiles) {
		currentMode = tiles;
	}
	
	public static EditMode getMode() {
		return currentMode;
	}
}
