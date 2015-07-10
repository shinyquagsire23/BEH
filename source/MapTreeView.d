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
module MapTreeView;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.TreeStore;
private import gtk.CellRendererText;
private import gtk.ListStore;

class MapTreeView : TreeView
{
    private TreeViewColumn countryColumn;
    private TreeViewColumn capitalColumn;
    
    this(TreeStore store)
    {        
        countryColumn = new TreeViewColumn("Map", new CellRendererText(), "text", 0);
        appendColumn(countryColumn);
        
        setModel(store);
    }
}

