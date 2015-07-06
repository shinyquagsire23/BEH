module MainGUI;

import std.functional;
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
import gdk.Event;
import gtk.FileChooserDialog;

import MapStore;
import MapTreeView;

import GBAUtils.ROMManager;
import GBAUtils.GBARom;

static MainWindow win;

void main(string[] args)
{
    Main.init(args);
    win = new MainWindow("Hello World");
    win.setDefaultSize(516, 338);
    
    Box barPanel = new Box(Orientation.VERTICAL, 0);
    Paned mainSplit = new Paned(Orientation.HORIZONTAL);
    Box mapSelector = new Box(Orientation.VERTICAL, 1);
    
    MenuBar bar = new MenuBar();
    auto fileMenuItem = new MenuItem("File");
    auto fileSubMenu = new Menu();
    auto fileOpenMenu = new MenuItem("Open ROM...");
    fileOpenMenu.addOnActivate(toDelegate(&chooseRom));
    fileSubMenu.append(fileOpenMenu);
    fileMenuItem.setSubmenu(fileSubMenu);
    bar.append(fileMenuItem);
    barPanel.add(bar);
    
    auto store = new MapStore();
    
    auto rootMap = store.addCategory("Maps by Bank");
    auto bank0 = store.addChild(rootMap, "0");
    store.addChild(bank0, "Some Map (0.0)");
    
    auto locationTreeView = new LocationTreeView(store);
    mapSelector.packStart(locationTreeView, true, true, 0);
    
    mainSplit.setPosition(150);
    mainSplit.add1(mapSelector);
    mainSplit.add2(new Label("<Insert Map Editor Here>"));
    
    barPanel.add(mainSplit);
    win.add(barPanel);
    win.showAll();
    Main.run();
}

void chooseRom(MenuItem item)
{
    writeln(ROMManager.loadRom());
    writeln(ROMManager.getActiveROM().getGameCode());
    writeln(ROMManager.getActiveROM().getGameText());
    writeln(ROMManager.getActiveROM().getGameCreatorID());
}
