/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapStore.d                                                                 *
 * "A TreeStore for Maps"                                                     *
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
module MapStore;

private import gtk.TreeStore;
private import gtk.TreeIter;
private import gtkc.gobjecttypes;

class MapStore : TreeStore
{
    this()
    {
        super([GType.STRING, GType.INT, GType.INT]);
    }

    public TreeIter addCategory(in string name)
    {
        
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        setValue(iter, 1, -1);
        setValue(iter, 2, -1);
        return iter;
    }

    public TreeIter addChild(TreeIter parent,
        in string name, in uint bank, in uint map)
    {
        TreeIter child = TreeStore.createIter(parent);
        setValue(child, 0, name);
        setValue(child, 1, bank);
        setValue(child, 2, map);
        return child;
    }
}
