/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * Lz77.d                                                                     *
 * "A wrapper for various LZ77 functions for the GBARom class"                *
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
module GBAUtils.Lz77;

import GBAUtils.GBARom;
import GBAUtils.NewLz77;
import std.stdio;
import std.algorithm;

/**
 * Wrapper of debloat's Lz77 algorithm adapted for purposes within GBA ROM Hacking
 * @author maxamillion
 *
 */
public class Lz77
{
    public static int getUncompressedSize(GBARom ROM, int offset)
    {
        return NewLz77.getLz77DataLength(ROM, offset);
    }
    
    public static ubyte[] decompressLZ77(GBARom ROM, int offset)
    {
        uint outputlen = 0;
        ubyte[] decompressed = new ubyte[](NewLz77.getLz77DataLength(ROM, offset));
        NewLz77.decompressLZ77content(ROM.readBytes(offset, NewLz77.getLz77DataLength(ROM, offset)), NewLz77.getLz77DataLength(ROM, offset), decompressed, outputlen);
        return decompressed;
    }
    
    public static ubyte[] decompressLZ77(ubyte[] ROM, int offset)
    {
        uint outputlen = 0;
        ubyte[] decompressed = new ubyte[](NewLz77.getLz77DataLength(ROM, offset));
        NewLz77.decompressLZ77content(ROM[offset..offset+min(ROM.length, NewLz77.getLz77DataLength(ROM, offset))], NewLz77.getLz77DataLength(ROM, offset), decompressed, outputlen);
        return decompressed;
    }
    
    public static ubyte[] compressLZ77(ubyte[] data)
    {
        byte[] bytes = null;
        return NewLz77.compressLZ10(data);
    }
}
