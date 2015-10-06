/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapTreeView.d                                                              *
 * "A TreeView for Maps"                                                      *
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
module MapTreeView;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.TreeStore;
private import gtk.CellRendererText;
private import gtk.ListStore;

class MapTreeView : TreeView
{
    private TreeViewColumn mapColumn;
    private TreeViewColumn bankNumColumn;
    private TreeViewColumn mapNumColumn;
    
    this(TreeStore store)
    {        
        mapColumn = new TreeViewColumn("Map", new CellRendererText(), "text", 0);
        bankNumColumn = new TreeViewColumn("", new CellRendererText(), "text", 1);
        mapNumColumn = new TreeViewColumn("", new CellRendererText(), "text", 2);

        bankNumColumn.setVisible(false);
        mapNumColumn.setVisible(false);

        appendColumn(mapColumn);
        appendColumn(bankNumColumn);
        appendColumn(mapNumColumn);
        
        setModel(store);
    }
}

