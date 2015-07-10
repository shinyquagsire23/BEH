/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * OverworldSpritesManager.d                                                  *
 * "Loads and stores multiple OverworldSprites for use."                      *
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
module IO.Render.OverworldSpritesManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import IO.Render.OverworldSprites;
import gdkpixbuf.Pixbuf;

public class OverworldSpritesManager //TODO Thread this
{
    public static OverworldSprites[] Sprites = new OverworldSprites[256];
    private static GBARom rom;
    
    public this(GBARom rom)
    {
        OverworldSpritesManager.rom = rom;
    }

    public static Pixbuf GetImage(uint index)
    {
        if(Sprites[index] !is null)
            return Sprites[index].imgBuffer;
        else
            return loadSprite(index).imgBuffer;
    }

    public static OverworldSprites GetSprite(uint index)
    {
        if(Sprites[index] !is null)
            return Sprites[index];
        else
            return loadSprite(index);
    }
    
    public static OverworldSprites loadSprite(uint num)
    {
        uint ptr = rom.getPointer(DataStore.SpriteBase + (num * 4));
        Sprites[num] = new OverworldSprites(rom, ptr);
        return Sprites[num];
    }
    
    public void run()
    {
        if (DataStore.mehSettingShowSprites == 0)
            return;// Don't load if not enabled.
        for (int i = 0; i < DataStore.NumSprites; i++)
        {
            loadSprite(i);
        }
    }
}
