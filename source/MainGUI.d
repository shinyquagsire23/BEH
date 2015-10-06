/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MainGUI.d                                                                  *
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
module MainGUI;

import std.functional;
import std.algorithm;
import std.stdio;
import gtk.Window;
import gtk.MainWindow;
import gtk.Label;
import gtk.Main;
import gtk.Box;
import gtk.VBox;
import gtk.ScrolledWindow;
import gtk.Paned;
import gtk.TreeStore;
import gtk.TreePath;
import gtk.TreeViewColumn;
import gtk.TreeView;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Menu;
import gtk.Widget;
import gtk.Image;
import gdk.Event;
import gtkc.gdktypes;
import gdkpixbuf.Pixbuf;
import gtk.FileChooserDialog;
import gtk.Container;

import MapStore;
import MapTreeView;

import pokegba.rom;
import GBAUtils.DataStore;
import GBAUtils.PixbufExtend;
import IO.BankLoader;
import IO.Map;
import IO.MapIO;
import UI.MapEditorBox;
import UI.BlockPickerBox;

static MainWindow win;
static MapStore store;
static MapEditorBox mapEditorBox;
static BlockPickerBox blockPickerBox;
static ScrolledWindow blockPickerWindow;

void main(string[] args)
{
    Main.init(args);
    win = new MainWindow("Hello World");
    win.setDefaultSize(516, 338);

    Box barPanel = new Box(Orientation.VERTICAL, 0);
    Paned mainSplit = new Paned(Orientation.HORIZONTAL);
    ScrolledWindow mapSelectWindow = new ScrolledWindow();

    Box mapEditor = new Box(Orientation.HORIZONTAL, 0);
    ScrolledWindow mapEditorWindow = new ScrolledWindow();
	blockPickerWindow = new ScrolledWindow();
    
    MenuBar bar = new MenuBar();
    auto fileMenuItem = new MenuItem("File");
    auto fileSubMenu = new Menu();
    auto fileOpenMenu = new MenuItem("Open ROM...");
    fileOpenMenu.addOnActivate(toDelegate(&chooseRom));
    fileSubMenu.append(fileOpenMenu);
    fileMenuItem.setSubmenu(fileSubMenu);
    bar.append(fileMenuItem);
    barPanel.add(bar);
    
    store = new MapStore();
    
    auto mapTreeView = new MapTreeView(store);
    mapTreeView.setHeadersVisible(false);
    mapTreeView.addOnRowActivated(toDelegate(&openMap));
    mapSelectWindow.add(mapTreeView);
    
    mapEditorBox = MapEditorBox.getInstance();
	blockPickerBox = new BlockPickerBox(true);
    Pixbuf buf = new Pixbuf("resources/mime.jpg");
    Pixbuf buf2 = new Pixbuf("resources/smeargle.png").addAlpha(false, 0, 0, 0);
    
    buf.drawImage(buf2, 5, 5);
    buf.drawRect(40,50,8,8,0,0,0);

	blockPickerBox.mapEditorBox = mapEditorBox;
	blockPickerBox.setFromPixbuf(buf2);
	blockPickerBox.setHalign(GtkAlign.START);
	blockPickerBox.setValign(GtkAlign.START);
	blockPickerBox.setSizeRequest(blockPickerBox.editorWidth * 16, -1);
	blockPickerWindow.setSizeRequest(blockPickerBox.editorWidth * 16, -1);
	blockPickerWindow.add(blockPickerBox);
	blockPickerWindow.addOnMotionNotify(toDelegate(&mouseDraggedBlockPicker));
	blockPickerWindow.addOnButtonPress(toDelegate(&buttonPressBlockPicker));
	blockPickerWindow.addOnButtonRelease(toDelegate(&buttonReleaseBlockPicker));

	mapEditorBox.blockPickerBox = blockPickerBox;
	mapEditorBox.setFromPixbuf(buf);
	mapEditorBox.setHalign(GtkAlign.START);
	mapEditorBox.setValign(GtkAlign.START);
    mapEditorWindow.add(mapEditorBox);
	mapEditorWindow.addEvents(GdkEventMask.POINTER_MOTION_MASK | GdkEventMask.POINTER_MOTION_HINT_MASK | GdkEventMask.BUTTON_PRESS_MASK);
	mapEditorWindow.addOnMotionNotify(toDelegate(&mouseDraggedMapEditor));
	mapEditorWindow.addOnButtonPress(toDelegate(&buttonPressMapEditor));
	mapEditorWindow.addOnButtonRelease(toDelegate(&buttonReleaseMapEditor));

	mapEditor.packStart(mapEditorWindow, true, true, 0);
	mapEditor.packStart(blockPickerWindow, false, false, 0);
    
    mainSplit.setPosition(220);
    mainSplit.pack1(mapSelectWindow, false, false);
    mainSplit.add2(mapEditor);
    
    
    barPanel.packStart(mainSplit, true, true, 0);
	win.add(barPanel);
    win.showAll();
    Main.run();
}

void openMap(TreePath path, TreeViewColumn column, TreeView view)
{
    int bank = view.getSelectedIter().getValueInt(1);
    int map = view.getSelectedIter().getValueInt(2);
    if(bank != -1 && map != -1)
    {
        MapIO.loadMap(bank,map);
        writefln("Map loaded");
    }
}

void chooseRom(MenuItem item)
{
    string location = "";
    auto dlg = new FileChooserDialog("Open File", null, FileChooserAction.OPEN, ["Open", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
    if(GtkResponseType.ACCEPT == dlg.run() )
    {
        location = dlg.getFilename();
        if(ROMManager.loadROM(location) >= 0)
        {
            writeln(ROMManager.getActiveROM().getGameCode());
            writeln(ROMManager.getActiveROM().getGameText());
            writeln(ROMManager.getActiveROM().getGameCreatorID());
            DataStore dataStore = new DataStore("BEH.ini", ROMManager.currentROM.getGameCode());
            BankLoader b = new BankLoader(DataStore.MapHeaders, ROMManager.getActiveROM(), store, store.addCategory("Maps by Bank"));
            b.run();
        }
    }
    dlg.destroy();
}

public bool mouseDraggedMapEditor(GdkEventMotion* eventMotion, Widget w) 
{
	int mx = cast(int)eventMotion.x;
	int my = cast(int)eventMotion.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();

	return mapEditorBox.mouseDragged(mx,my, eventMotion.state);
}

public bool buttonPressMapEditor(GdkEventButton* event, Widget w)
{
	int mx = cast(int)event.x;
	int my = cast(int)event.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();

	return mapEditorBox.mousePressed(mx,my, event.button);
}

public bool buttonReleaseMapEditor(GdkEventButton* event, Widget w)
{
	int mx = cast(int)event.x;
	int my = cast(int)event.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();
	
	return mapEditorBox.mouseRelease(mx,my, event.button);
}

public bool mouseDraggedBlockPicker(GdkEventMotion* eventMotion, Widget w) 
{
	int mx = cast(int)eventMotion.x;
	int my = cast(int)eventMotion.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();
	
	return blockPickerBox.mouseDragged(mx,my, eventMotion.state);
}

public bool buttonPressBlockPicker(GdkEventButton* event, Widget w)
{
	int mx = cast(int)event.x;
	int my = cast(int)event.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();
	
	return blockPickerBox.mousePressed(mx,my, event.button);
}

public bool buttonReleaseBlockPicker(GdkEventButton* event, Widget w)
{
	int mx = cast(int)event.x;
	int my = cast(int)event.y;
	mx += cast(int)(cast(ScrolledWindow)w).getHadjustment.getValue();
	my += cast(int)(cast(ScrolledWindow)w).getVadjustment.getValue();
	
	return blockPickerBox.mouseRelease(mx,my, event.button);
}
