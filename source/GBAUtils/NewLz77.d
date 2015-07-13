/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * NewLz77.d                                                                  *
 * "Provides GBA-compatible LZ77 compression and decompression methods"       *
 *                                                                            *
 *     Portions of File Copyright 2009 The Lemon Man <giuseppe@FullMetal>     *
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
module GBAUtils.NewLz77;

import std.bitmanip;
import std.algorithm;
import pokegba.rom;
import std.stdio;

public class NewLz77
{
    //Pulled from taiko and ported/adjusted to D
    static uint packBytes(int a, int b, int c, int d)
    {
        return (d << 24) | (c << 16) | (b << 8) | (a);
    }

    static void decompressLZ7711(ubyte[] input, uint inputLen, out ubyte[] output, out uint outputLen)
    {
        int x, y;

        uint compressedPos 	= 0x4;
        uint decompressedPos	= 0x0;
        uint decompressedSize = 0;
        
        decompressedSize = packBytes(input[0], input[1], input[2], input[3]) >> 8;
        ubyte[] out_ = new ubyte[](decompressedSize);

        if (!decompressedSize)
        {
            decompressedSize = packBytes(input[4], input[5], input[6], input[7]);
            compressedPos += 0x4;
        }
        
        writefln("\t[*] Decompressed size : %x", decompressedSize);
        
        while (compressedPos < inputLen && decompressedPos < decompressedSize)
        {
            ubyte byteFlag = input[compressedPos];
            compressedPos++;
            
            for (x = 7; x >= 0; x--)
            {
                if ((byteFlag & (1 << x)) > 0)
                {
                    ubyte first = input[compressedPos];
                    ubyte second = input[compressedPos + 1];
                    
                    uint pos, copyLen;
                    
                    if (first < 0x20)
                    {
                        ubyte third = input[compressedPos + 2];
                        
                        if (first >= 0x10)
                        {
                            uint fourth = input[compressedPos + 3];
                            
                            pos			= cast(uint)(((third & 0xF) << 8) | fourth) + 1;
                            copyLen		= cast(uint)((second << 4) | ((first & 0xF) << 12) | (third >> 4)) + 273;
                            
                            compressedPos += 4;
                        } else {
                            pos          = cast(uint)(((second & 0xF) << 8) | third) + 1;
                            copyLen		 = cast(uint)(((first & 0xF) << 4) | (second >> 4)) + 17;
                            
                            compressedPos += 3;
                        }
                    } else {
                        pos 		= cast(uint)(((first & 0xF) << 8) | second) + 1;
                        copyLen		= cast(uint)(first >> 4) + 1;

                        compressedPos += 2;
                    }				

                    for (y = 0; y < copyLen; y++)
                    {
                        out_[decompressedPos + y] = out_[decompressedPos - pos + y];
                    }
                    
                    decompressedPos += copyLen;
                } else {
                    out_[decompressedPos] = input[compressedPos];
                    
                    decompressedPos++;
                    compressedPos++;
                }
                
                if (compressedPos >= inputLen || decompressedPos >= decompressedSize)
                    break;

            }
        }
        
        output = out_;
        outputLen = decompressedSize;
    }

    static void decompressLZ7710(ubyte[] input, uint inputLen, out ubyte[] output, out uint outputLen)
    {	
        int x, y;
        
        uint compressedPos = 0;
        uint decompressedSize = 0x4;
        uint decompressedPos = 0;
        
        decompressedSize = packBytes(input[0], input[1], input[2], input[3]) >> 8;
        ubyte[] out_ = new ubyte[](decompressedSize*8);

        int compressionType = (packBytes(input[0], input[1], input[2], input[3]) >> 4) & 0xF;
        
        /*if (compressionType != 1)
         {
         __errorCheck(-1337, 1);
         }*/
        
        writefln("\t[*] Decompressed size : %x", decompressedSize);

        compressedPos += 0x4;
        
        while (decompressedPos < decompressedSize)
        {
            ubyte flag = input[compressedPos];
            compressedPos += 1;
            
            for (x = 0; x < 8; x++)
            {
                if (flag & 0x80)
                {
                    ubyte first = input[compressedPos];
                    ubyte second = input[compressedPos + 1];
                    
                    ushort pos = cast(ushort)((((first << 8) + second) & 0xFFF) + 1);
                    ubyte copyLen = cast(ubyte)(3 + ((first >> 4) & 0xF));

                    for (y = 0; y < copyLen; y++)
                    {
                        out_[decompressedPos + y] = out_[decompressedPos - pos + (y % pos)];
                    }
                    
                    compressedPos += 2;
                    decompressedPos += copyLen;				
                }
                else
                {
                    out_[decompressedPos] = input[compressedPos];
                    compressedPos += 1;
                    decompressedPos += 1;
                }
                
                flag <<= 1;
                
                if (decompressedPos >= decompressedSize)
                    break;
            }
        }

        output = out_;
        outputLen = decompressedSize;
    }

    static int isLZ77compressed(ubyte *buffer)
    {
        if ((buffer[0] == 0x10) || (buffer[0] == 0x11))
        {
            return 1;
        }
        
        return 0;
    }

    static bool decompressLZ77content(ubyte[] buffer, uint lenght, out ubyte[] output, out uint outputLen)
    {
		bool ret = false;
        switch (buffer[0])
        {
            case 0x10:
                writefln("\t[*] LZ77 variant 0x10 compressed content...unpacking may take a while...");
                decompressLZ7710(buffer, lenght, output, outputLen); 
				ret = true;
				break;
            case 0x11:
                writefln("\t[*] LZ77 variant 0x11 compressed content...unpacking may take a while...");
                decompressLZ7711(buffer, lenght, output, outputLen); 
				ret = true;
				break;
            default:
                break;
        }
		return ret;
    }

    public enum CheckLz77Type
    {
        Sprite, Palette
    }

    // For picking what type of Compression Look-up we want
    public enum CompressionMode
    {
        Old, // Good
        New // Perfect!
    }

    public static uint getLz77DataLength(ROM rom, int offset)
    {
        ubyte[] data = rom.readBytes(offset, 0x10);
        return littleEndianToNative!uint(data[1..5]) << 8;
    }

    public static uint getLz77DataLength(ubyte[] rom, int offset)
    {
        ubyte[] data = rom[offset..offset+0x10];
        return littleEndianToNative!uint(data[1..5]) << 8;
    }

    public static ubyte[] compressLZ10(ubyte[] indata)
    {
        ubyte[] outstream;
        uint position = 0;
        int inLength = cast(uint)indata.length;
        if (inLength > 0xFFFFFF)
            return null;

        // write the compression header first
        outstream.length++; outstream[position++] = 0x10;
        outstream.length++; outstream[position++] = cast(ubyte) (inLength & 0xFF);
        outstream.length++; outstream[position++] = cast(ubyte) ((inLength >> 8) & 0xFF);
        outstream.length++; outstream[position++] = cast(ubyte) ((inLength >> 16) & 0xFF);

        int compressedLength = 4;

        // we do need to buffer the output, as the first byte indicates which
        // blocks are compressed.
        // this version does not use a look-ahead, so we do not need to buffer
        // more than 8 blocks at a time.
        ubyte[] outbuffer = new ubyte[8 * 2 + 1];
        outbuffer[0] = 0;
        int bufferlength = 1, bufferedBlocks = 0;
        int readBytes = 0;
        while (readBytes < inLength)
        {
            // we can only buffer 8 blocks at a time.
            if (bufferedBlocks == 8)
            {
                for(int i = 0; i < bufferlength; i++)
                {
                    outstream.length++; outstream[position++] = outbuffer[i];
                }
                compressedLength += bufferlength;
                // reset the buffer
                outbuffer[0] = 0;
                bufferlength = 1;
                bufferedBlocks = 0;
            }

            // determine if we're dealing with a compressed or raw block.
            // it is a compressed block when the next 3 or more bytes can be
            // copied from
            // somewhere in the set of already compressed bytes.
            int[] dispArr = new int[1];
            int oldLength = min(readBytes, 0x1000);
            int length = GetOccurrenceLength(indata, readBytes, min(inLength - readBytes, 0x12), readBytes - oldLength, oldLength, dispArr);
            int disp = dispArr[0];

            // length not 3 or more? next byte is raw data
            if (length < 3)
            {
                outbuffer[bufferlength++] = indata[readBytes++];
            }
            else
            {
                // 3 or more bytes can be copied? next (length) bytes will be
                // compressed into 2 bytes
                readBytes += length;

                // mark the next block as compressed
                outbuffer[0] |= cast(byte) (1 << (7 - bufferedBlocks));

                outbuffer[bufferlength] = cast(byte) (((length - 3) << 4) & 0xF0);
                outbuffer[bufferlength] |= cast(byte) (((disp - 1) >> 8) & 0x0F);
                bufferlength++;
                outbuffer[bufferlength] = cast(byte) ((disp - 1) & 0xFF);
                bufferlength++;
            }
            bufferedBlocks++;
        }

        // copy the remaining blocks to the output
        if (bufferedBlocks > 0)
        {
            for(int i = 0; i < bufferlength; i++)
            {
                outstream.length++; outstream[position++] = outbuffer[i];
            }
            compressedLength += bufferlength;
            // make the compressed file 4-byte aligned.
            while ((compressedLength % 4) != 0)
            {
                outstream.length++; outstream[position++] = 0;
                compressedLength++;
            }
        }

        return outstream;
    }

    public static int GetOccurrenceLength(ubyte[] indata, int newPtr, int newLength, int oldPtr, int oldLength, int[] disp)
    {
        int minDisp = 1;
        disp[0] = 0;
        if (newLength == 0)
            return 0;
        int maxLength = 0;
        // try every possible 'disp' value (disp = oldLength - i)
        for (int i = 0; i < oldLength - minDisp; i++)
        {
            // work from the start of the old data to the end, to mimic the
            // original implementation's behaviour
            // (and going from start to end or from end to start does not
            // influence the compression ratio anyway)
            int currentOldStart = oldPtr + i;
            int currentLength = 0;
            // determine the length we can copy if we go back (oldLength - i)
            // bytes
            // always check the next 'newLength' bytes, and not just the
            // available 'old' bytes,
            // as the copied data can also originate from what we're currently
            // trying to compress.
            for (int j = 0; j < newLength; j++)
            {
                // stop when the bytes are no longer the same
                if (indata[currentOldStart + j] != indata[newPtr + j])
                    break;
                currentLength++;
            }

            // update the optimal value
            if (currentLength > maxLength)
            {
                maxLength = currentLength;
                disp[0] = oldLength - i;

                // if we cannot do better anyway, stop trying.
                if (maxLength == newLength)
                    break;
            }
        }
        return maxLength;
    }
}
