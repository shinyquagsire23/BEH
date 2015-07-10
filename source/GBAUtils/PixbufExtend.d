/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * PixbufExtend.d                                                             *
 * "A set of functions to extend and further improve the Pixbuf class.        *
 *  Primarily allows writing and drawing to Pixbuf images."                   *
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
module GBAUtils.PixbufExtend;

import gdkpixbuf.Pixbuf;
import std.conv;
import std.algorithm;

//TODO: This assumes RGBA
Pixbuf drawImageFast(Pixbuf mn, Pixbuf sb, uint xPos, uint yPos)
{
    Pixbuf main = mn;
    Pixbuf sub = sb;
    if(!mn.getHasAlpha())
        main = mn.addAlpha(false, 0, 0, 0);
    if(!sb.getHasAlpha())
        sub = sb.addAlpha(false, 0, 0, 0);
    
    for(int y = 0; y < sub.getHeight(); y++)
    {
        uint subPos = (y * sub.getWidth()) * 4;
        uint mainPos = (((y + yPos) * main.getWidth()) + xPos) * 4;
        char[] row = sub.getPixelsWithLength[subPos..subPos+(sub.getWidth() * 4)];
        main.getPixelsWithLength[mainPos..mainPos+(sub.getWidth() * 4)] = row;
    }
    return main;
}

Pixbuf drawImage(Pixbuf main, Pixbuf sub, uint xPos, uint yPos)
{       
    void blend(out ubyte r, out ubyte g, out ubyte b, out ubyte a, ubyte r1, ubyte g1, ubyte b1, ubyte a1, ubyte r2, ubyte g2, ubyte b2, ubyte a2)
    {
        uint alpha = a1 + 1;
        uint inv_alpha = 256 - a1;
        r = to!ubyte((alpha * r1 + inv_alpha * r2) >> 8);
        g = to!ubyte((alpha * g1 + inv_alpha * g2) >> 8);
        b = to!ubyte((alpha * b1 + inv_alpha * b2) >> 8);
        a = max(a2, a1);
    }

    for(int y = yPos; y < yPos+sub.getHeight(); y++)
    {
        for(int x = xPos; x < xPos+sub.getWidth(); x++)
        {
            ubyte r_1;
            ubyte g_1;
            ubyte b_1;
            ubyte a_1;
            main.getPixel(x, y, r_1, g_1, b_1, a_1);
            
            ubyte r_2;
            ubyte g_2;
            ubyte b_2;
            ubyte a_2;
            sub.getPixel(x-xPos, y-yPos, r_2, g_2, b_2, a_2);
            
            ubyte r;
            ubyte g;
            ubyte b;
            ubyte a;
            blend(r,g,b,a, r_2,g_2,b_2,a_2, r_1,g_1,b_1,a_1);

            main.setPixel(x, y, r, g, b, a);
        }
    }
    return main;
}

Pixbuf fillRect(Pixbuf main, uint xPos, uint yPos, uint width, uint height, ubyte r, ubyte g, ubyte b, ubyte a = 0xFF)
{
    for(int y = yPos; y < yPos+height; y++)
    {
        for(int x = xPos; x < xPos+width; x++)
        {
            main.setPixel(x, y, r, g, b, a);
        }
    }
    return main;
}

Pixbuf setPixel(Pixbuf main, uint x, uint y, ubyte r, ubyte g, ubyte b, ubyte a = 0xFF)
{
    if(x >= main.getWidth() || y >= main.getHeight())
        return main;
    
    main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 0] = r;
    main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 1] = g;
    main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 2] = b;
    
    if(main.getHasAlpha())
        main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 3] = a;
    
    return main;
}

void getPixel(Pixbuf main, uint x, uint y, out ubyte r, out ubyte g, out ubyte b, out ubyte a)
{
    if(x >= main.getWidth() || y >= main.getHeight())
        return;
    
    r = main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 0];
    g = main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 1];
    b = main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 2];
    
    if(main.getHasAlpha())
        a = main.getPixelsWithLength[(y * main.getRowstride() + x * main.getNChannels()) + 3];
    else
        a = 0xFF;
}
