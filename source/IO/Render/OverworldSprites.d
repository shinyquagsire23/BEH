/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * OverworldSprites.d                                                         *
 * "Renders overworld sprites, given a ROM and an offset to the overworld  *
 *  sprite data."                                                             *
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
module IO.Render.OverworldSprites;

import pokegba.rom;
import GBAUtils.GBAImage;
import GBAUtils.Palette;
import GBAUtils.DataStore;
import GBAUtils.GBAImageType;
import GBAUtils.PixbufExtend;
import gdkpixbuf.Pixbuf;
import std.stdio;

public class OverworldSprites 
{
    //Rom structure 
    /*
     public uint lIndex; //Primary Key in sprite database?
     public  uint lSlot;
     public  uint iOffTop; //Hotspot//s top area. Normally 16.
     public  int iOffBot; //Hotspot//s bottom area. Normally 32.
     public  int iPal; //Palette to use. Probably contains more than that, only last digit actually matters.
     public  int filler;
     public  uint u1; //An unknown pointer.*/
    public  uint StarterWord;
    public  ubyte iPal;
    public  ubyte sprVald1;
    public  ubyte sprVald2;
    public  ubyte sprVald3;
    public  uint FrameSize;
    public uint width;
    public uint height;
    public uint oam1;
    public uint oam2;
    public  uint ptr2anim;
    public  uint ptrSize; //Pointer to unknown data. Determines sprite size.
    public  uint ptrAnim; //Pointer to unknown data. Determines sprite mobility: just one sprite, can only turn (gym leaders) or fully mobile.
    public  uint ptrGraphic; //Pointer to pointer to graphics <- not a typo ;)
    public  uint LoadCode; //Another unknown pointer.
    //Class vars
    public  uint trueGraphicsPointer;
    public  Pixbuf imgBuffer;
    public  GBAImage rawImage;
    public static Palette[] myPal;
    private Pixbuf[] bi;
    public uint mSpriteSize;
    
    /*			if(renderTileset)
     {
     for(int i = 0; i < 13; i++)
     {
     g.drawImage(globalTiles.getTileSet(i),i*128,0,this);
     
     }
     }
     */
    
    public this(ROM rom)
    {
        Load(rom);	
    }
    
    public this(ROM rom, int offset)
    {
        rom.Seek(offset);
        Load(rom);
    }
    
    void GrabPal(ROM rom)
    {
        OverworldSprites.myPal = new Palette[16];
        
        
        for(int i = 0; i < 16; i++)
        {
            uint ptr = rom.getPointer(DataStore.SpriteColors + (i * 8));
            uint palNum = rom.readByte(DataStore.SpriteColors + (i * 8) + 4) & 0xF;
            OverworldSprites.myPal[palNum] = new Palette(GBAImageType.c16, rom.readBytes(ptr, 32));
        }
        
        
    }
    void DrawSmall()
    {
        imgBuffer.drawImage(getTile(0,iPal&0xf),0,0);
        imgBuffer.drawImage(getTile(1,iPal&0xf),8,0);
        imgBuffer.drawImage(getTile(2,iPal&0xf),0,8);
        imgBuffer.drawImage(getTile(3,iPal&0xf),8,8);
    }
    
    void DrawMedium()
    {
        imgBuffer.drawImage(getTile(0,iPal&0xf),0,0);
        imgBuffer.drawImage(getTile(1,iPal&0xf),8,0);
        imgBuffer.drawImage(getTile(2,iPal&0xf),0,8);
        imgBuffer.drawImage(getTile(3,iPal&0xf),8,8);
        imgBuffer.drawImage(getTile(4,iPal&0xf),0,16);
        imgBuffer.drawImage(getTile(5,iPal&0xf),8,16);
        imgBuffer.drawImage(getTile(6,iPal&0xf),0,24);
        imgBuffer.drawImage(getTile(7,iPal&0xf),8,24);
    }
    //AutoX and AutoY are only for drawlarge 
    
    void DrawLarge()
    {
        try
        {
            imgBuffer.drawImage(getTile(0,iPal&0xf), 0, 0);
            imgBuffer.drawImage(getTile(1,iPal&0xf), 8, 0);
            imgBuffer.drawImage(getTile(2,iPal&0xf), 16, 0);
            imgBuffer.drawImage(getTile(3,iPal&0xf), 24, 0);
            imgBuffer.drawImage(getTile(4,iPal&0xf), 0, 8);
            imgBuffer.drawImage(getTile(5,iPal&0xf), 8, 8);
            imgBuffer.drawImage(getTile(6,iPal&0xf), 16, 8);
            imgBuffer.drawImage(getTile(7,iPal&0xf), 24, 8);
            imgBuffer.drawImage(getTile(8,iPal&0xf), 0, 16);
            imgBuffer.drawImage(getTile(9,iPal&0xf), 8, 16);
            imgBuffer.drawImage(getTile(10,iPal&0xf), 16, 16);
            imgBuffer.drawImage(getTile(11,iPal&0xf), 24, 16);
            imgBuffer.drawImage(getTile(12,iPal&0xf), 0, 24);
            imgBuffer.drawImage(getTile(13,iPal&0xf), 8, 24);
            imgBuffer.drawImage(getTile(14,iPal&0xf), 16, 24);
            imgBuffer.drawImage(getTile(15,iPal&0xf), 24, 24);
        }
        catch(Exception e)
        {
            writefln("Error occured while rendering large sprite!");
            //e.printStackTrace();
            imgBuffer.fillRect(0, 0, 24, 24, 0, 0, 0);   
        }
        
    }
    void PaintMeLikeYourWomenInMagazines()
    {
        imgBuffer = new Pixbuf(GdkColorspace.RGB, true, 8, 128, 128);
        
        switch(mSpriteSize)
        {
            case 0:
                DrawSmall();
                break;
            case 1:
                DrawMedium();
                break;
            case 2:
                DrawLarge();
                break;
            default:
                break;
        }				
    }
    
    void MakeMeReal(ROM rom)
    {
        int sz=0;
        if(ptrSize==DataStore.SpriteSmallSet)
        {
            sz=(4*32)/2;
            mSpriteSize=0;
        }
        else if(ptrSize==DataStore.SpriteNormalSet)
        {
            sz=(8*32)/2;
            mSpriteSize=1;
            
            
        }
        else if(ptrSize==DataStore.SpriteLargeSet)
        {
            sz=(16*32)/2;
            mSpriteSize=2;
            
        }
        else
        {
            sz=(32*32)/2;
            mSpriteSize=1;	
        }
        
        int i=0;
        rom.Seek( trueGraphicsPointer);
        ubyte[] dBuff = rom.readBytes(sz*2);
        rawImage = new GBAImage(dBuff,myPal[iPal&0xF],128, 128);//pntSz);	
        
        bi = new Pixbuf[16];
        for(i=0;i<16;i++)
        {
            this.bi[i] = rawImage.getPixbufFromPal(OverworldSprites.myPal[i]);
        }
        PaintMeLikeYourWomenInMagazines();//Honestly not sure what I'm totally doing here. 
    }
    
    void Load(ROM rom)
    {
        StarterWord = rom.readWord();
        iPal=rom.readByte();
        sprVald1=rom.readByte();
        sprVald2=rom.readByte();
        sprVald3=rom.readByte();
        FrameSize= rom.readWord();
        width= rom.readWord();
        height= rom.readWord();
        oam1= rom.readWord();
        oam2= rom.readWord();
        ptr2anim= rom.getPointer();
        ptrSize= rom.getPointer(); //Pointer to unknown data. Determines sprite size.
        ptrAnim= rom.getPointer(); //Pointer to unknown data. Determines sprite mobility: just one sprite, can only turn (gym leaders) or fully mobile.
        ptrGraphic= rom.getPointer(); //Pointer to pointer to graphics <- not a typo ;)
        LoadCode= rom.getPointer();
        trueGraphicsPointer=rom.getPointer( ptrGraphic);//Grab the real one
        if(OverworldSprites.myPal==null)
        {
            GrabPal(rom);
        }
        MakeMeReal(rom);
        //if pal size is 0 then we need to grab it
    }
    public Pixbuf getTile(int tileNum, int palette)
    {
        
        
        int x = tileNum * 8;
        int y = 0;
        Pixbuf toSend = bi[palette].newSubpixbuf(x, y, 8, 8);
        
        return toSend;
    }
}
