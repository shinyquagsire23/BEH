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
 * <project name> is free software: you can redistribute it and/or modify it  *
 * under the terms of the GNU General Public License as published by the Free *
 *  Software Foundation, either version 3 of the License, or (at your option) *
 *                             any later version.                             *
 *                                                                            *
 *    <project name> is distributed in the hope that it will be useful, but   *
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
import gtk.Paned;
import gtk.TreeStore;
import gtk.MenuBar;
import gtk.MenuItem;
import gtk.Menu;
import gtk.Widget;
import gtk.Image;
import gdk.Event;
import gdkpixbuf.Pixbuf;
import gtk.FileChooserDialog;

import MapStore;
import MapTreeView;

import GBAUtils.ROMManager;
import GBAUtils.GBARom;
import GBAUtils.DataStore;
import GBAUtils.PixbufExtend;
import IO.BankLoader;
import IO.Map;
import IO.MapIO;

static MainWindow win;
static MapStore store;
static Image image;

void main(string[] args)
{
    Main.init(args);
    win = new MainWindow("Hello World");
    win.setDefaultSize(516, 338);

    Box barPanel = new Box(Orientation.VERTICAL, 0);
    Paned mainSplit = new Paned(Orientation.HORIZONTAL);
    Box mapSelector = new Box(Orientation.VERTICAL, 1);
    Box mapEditor = new Box(Orientation.VERTICAL, 1);
    
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
    mapSelector.packStart(mapTreeView, true, true, 0);
    
    image = new Image();
    Pixbuf buf = new Pixbuf("resources/mime.jpg");
    Pixbuf buf2 = new Pixbuf("resources/smeargle.png").addAlpha(false, 0, 0, 0);
    
    buf.drawImage(buf2, 5, 5);
    buf.fillRect(40,50,8,8,0,0,0);

    image.setFromPixbuf(buf);
    mapEditor.add(image);
    mapEditor.add(new Label("<Insert Map Editor Here>"));
    
    mainSplit.setPosition(220);
    mainSplit.add1(mapSelector);
    mainSplit.add2(mapEditor);
    
    
    barPanel.add(mainSplit);
    win.add(barPanel);
    win.showAll();
    Main.run();
}

void chooseRom(MenuItem item)
{
    if(ROMManager.loadRom() >= 0)
    {
        writeln(ROMManager.getActiveROM().getGameCode());
        writeln(ROMManager.getActiveROM().getGameText());
        writeln(ROMManager.getActiveROM().getGameCreatorID());
        DataStore dataStore = new DataStore("BEH.ini", ROMManager.currentROM.getGameCode());
        BankLoader b = new BankLoader(DataStore.MapHeaders, ROMManager.getActiveROM(), store, store.addCategory("Maps by Bank"));
        b.run();
        MapIO.loadMap(3,4);
        writefln("%u, %u", MapIO.loadedMap.getMapData().mapWidth, MapIO.loadedMap.getMapData().mapHeight);
        image.setFromPixbuf(Map.renderMap(MapIO.loadedMap, true));
    }
}
