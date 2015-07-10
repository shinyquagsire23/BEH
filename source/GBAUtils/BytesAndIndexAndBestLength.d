/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * BytesAndIndexAndBestLength.d                                               *
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
module GBAUtils.BytesAndIndexAndBestLength;

public class BytesAndIndexAndBestLength
{
    private ubyte[] bytes;
    private uint index;
    private uint bestlength;

    public this(ubyte[] bytes, uint index, uint bestlength)
    {
        this.bytes = bytes;
        this.index = index;
    }

    public ubyte[] getBytes()
    {
        return bytes;
    }

    public uint getIndex()
    {
        return index;
    }

    public uint getBestLength()
    {
        return bestlength;
    }

    public void setBytes(ubyte[] bytes)
    {
        this.bytes = bytes;
    }

    public void setIndex(uint index)
    {
        this.index = index;
    }

    public void setBestLength(uint bestlength)
    {
        this.bestlength = bestlength;
    }
}
