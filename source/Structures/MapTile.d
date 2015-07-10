/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * MapTile.d                                                                  *
 * "brief description of file"                                                *
 *                                                                            *
 *                         This file is part of BEH.                          *
 *                                                                            *
 *       BEH is free software: you can redistribute it and/or modify it       *
 * under the terms of the GNU General Public License as published by the Free *
 *  Software Foundation, either version 3 of the License, or (at your option) *
 *                             any later version.                             *
 *                                                                            *
 *          BEH is distributed in the hope that it will be useful, but        *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *
 *   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licens  *
 *                             for more details.                              *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License along   *
 *      with BEH.  If not, see <http://www.gnu.org/licenses/>.                *
 *****************************************************************************/
module Structures.MapTile;

public class MapTile
{
    private ushort id; 
    private ushort metaData;
    
    public void SetID(ushort i)
    {
        id = i;
    }
    
    public this(ushort id, ushort meta)
    {
        this.id = id;
        metaData = meta;
    }
    
    public void SetMeta(ushort meta)
    {
        metaData = meta;
    }

    public ushort getID()
    {
        return id;
    }
    
    public ushort getMeta()
    {
        return metaData;
    }

    public MapTile clone()
    {
        return new MapTile(id,metaData);
    }
}
