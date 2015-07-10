module IO.Render.BlockRenderer;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.PixbufExtend;

import gdkpixbuf.Pixbuf;
import IO.Block;
import IO.MapIO;
import IO.Tile;
import IO.Tileset;

public class BlockRenderer
{
    public enum TripleType
    {
        NONE,
        LEGACY,
        LEGACY2,
        REFERENCE
    }
    
    private Tileset global;
    private Tileset local;
    public static int currentTime = 0;
    public this(Tileset global, Tileset local)
    {
        this.global = global;
        this.local = local;
    }
    
    public this()
    {
        this(null,null);
    }
    
    public void setGlobalTileset(Tileset global)
    {
        this.global = global;
    }
    
    public void setLocalTileset(Tileset local)
    {
        this.local = local;
    }
    
    
    public Tileset getGlobalTileset()
    {
        return global;
    }
    
    public Tileset getLocalTileset()
    {
        return local;
    }
    
    public Pixbuf renderBlock(int blockNum)
    {
        return renderBlock(blockNum, true);
    }
    
    public Pixbuf renderBlock(int blockNum, bool transparency)
    {
        int origBlockNum = blockNum;
        bool isSecondaryBlock = false;
        if (blockNum >= DataStore.MainTSBlocks)
        {
            isSecondaryBlock = true;
            blockNum -= DataStore.MainTSBlocks;
        }
        
        uint blockPointer = ((isSecondaryBlock ? local.getTilesetHeader().pBlocks : global.getTilesetHeader().pBlocks) + (blockNum * 16));
        Pixbuf block = new Pixbuf(GdkColorspace.RGB, true, 8, 16, 16);
        int x = 0;
        int y = 0;
        int layerNumber = 0;
        
        TripleType type = TripleType.NONE;
        if((getBehaviorByte(origBlockNum) >> (DataStore.EngineVersion == 1 ? 24 : 8) & 0x30) == 0x30)
            type = TripleType.LEGACY;
        
        if((getBehaviorByte(origBlockNum) >> (DataStore.EngineVersion == 1 ? 24 : 8) & 0x40) == 0x40) {
            blockPointer +=8;
            type = TripleType.LEGACY2;
        }
        
        else if((getBehaviorByte(origBlockNum) >> (DataStore.EngineVersion == 1 ? 24 : 8) & 0x60) == 0x60 && DataStore.EngineVersion == 1)
            type = TripleType.REFERENCE;
        
        if(type != TripleType.NONE && MapIO.DEBUG == true)
            writefln("Rendering triple tile! %x", type);
        
        for (int i = 0; i < (type != TripleType.NONE ? 24 : 16); i++)
        {
            if(type == TripleType.REFERENCE && i == 16)
            {
                bool second = false;
                uint tripNum = ((getBehaviorByte(origBlockNum) >> 14) & 0x3FF);
                if (tripNum >= DataStore.MainTSBlocks)
                {
                    second = true;
                    tripNum -= DataStore.MainTSBlocks;
                }
                
                blockPointer = ((second ? local.getTilesetHeader().pBlocks : global.getTilesetHeader().pBlocks) + (tripNum * 16)) + 8;
                blockPointer -= i;
            }
            int orig = global.getROM().readWord(blockPointer + i);
            int tileNum = orig & 0x3FF;
            int palette = (orig & 0xF000) >> 12;
            bool xFlip = (orig & 0x400) > 0;
            bool yFlip = (orig & 0x800) > 0;
            if (transparency && layerNumber == 0)
            {
                block.fillRect(x * 8, y * 8, 8, 8, global.getPalette(currentTime)[palette].getRedValue(0), global.getPalette(currentTime)[palette].getGreenValue(0), global.getPalette(currentTime)[palette].getBlueValue(0));
            }
            
            if (tileNum < DataStore.MainTSSize)
            {
                block.drawImage(global.getTile(tileNum, palette, xFlip, yFlip, currentTime), x * 8, y * 8);
            }
            else
            {
                block.drawImage(local.getTile(tileNum - DataStore.MainTSSize, palette, xFlip, yFlip, currentTime), x * 8, y * 8);
            }
            x++;
            if (x > 1)
            {
                x = 0;
                y++;
            }
            if (y > 1)
            {
                x = 0;
                y = 0;
                layerNumber++;
            }
            i++;
        }
        return block;
    }
    
    public Block getBlock(int blockNum)
    {
        bool isSecondaryBlock = false;
        int realBlockNum = blockNum;
        if (blockNum >= DataStore.MainTSBlocks)
        {
            isSecondaryBlock = true;
            blockNum -= DataStore.MainTSBlocks;
        }
        
        int blockPointer = ((isSecondaryBlock ? local.getTilesetHeader().pBlocks : global.getTilesetHeader().pBlocks) + (blockNum * 16));
        int x = 0;
        int y = 0;
        int layerNumber = 0;
        Block b = new Block(realBlockNum, global.getROM());
        
        bool tripleTile = false;
        
        if((b.backgroundMetaData >> (DataStore.EngineVersion == 1 ? 24 : 8) & 0x30) == 0x30)
        {
            tripleTile = true;
            if(MapIO.DEBUG == true)
                writefln("Rendering triple tile block!");
        }
        else if((b.backgroundMetaData >> (DataStore.EngineVersion == 1 ? 24 : 8) & 0x40) == 0x40)
        {
            tripleTile = true;
            blockPointer +=8;
            if(MapIO.DEBUG == true)
                writefln("Rendering space-saver triple tile block!");
        }
        
        for (int i = 0; i < (tripleTile ? 24 : 16); i++)
        {
            int orig = global.getROM().readWord(blockPointer + i);
            int tileNum = orig & 0x3FF;
            int palette = (orig & 0xF000) >> 12;
            bool xFlip = (orig & 0x400) > 0;
            bool yFlip = (orig & 0x800) > 0;
            
            //			if(i < 16)
            b.setTile(x+(layerNumber*2), y, new Tile(tileNum, palette, xFlip, yFlip));
            x++;
            if (x > 1)
            {
                x = 0;
                y++;
            }
            if (y > 1)
            {
                x = 0;
                y = 0;
                layerNumber++;
            }
            i++;
        }
        return b;
    }
    
    public uint getBehaviorByte(int blockID)
    {
        uint pBehavior = MapIO.blockRenderer.getGlobalTileset().tilesetHeader.pBehavior;
        uint blockNum = blockID;
        
        if (blockNum >= DataStore.MainTSBlocks)
        {
            blockNum -= DataStore.MainTSBlocks;
            pBehavior = MapIO.blockRenderer.getLocalTileset().tilesetHeader.pBehavior;
        }
        global.getROM().Seek(pBehavior + (blockNum * (DataStore.EngineVersion == 1 ? 4 : 2)));
        uint bytes = DataStore.EngineVersion == 1 ? global.getROM().getPointer(true) : global.getROM().getPointer(true) & 0xFFFF;
        return bytes;
    }
}
