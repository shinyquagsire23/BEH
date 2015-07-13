#!/usr/bin/dmd
/******************************************************************************
 * PokéGBA Library                                                            *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * `rom.d`                                                                    *
 * "classes for managing Pokémon GBA ROMs"                                    *
 *                                                                            *
 *                         This file is part of BEH.                          *
 *                                                                            *
 *  BEH is free software: you can redistribute it and/or modify it under the  *
 *  terms of the GNU General Public License as published by the Free Software *
 * Foundation, either version 3 of the License, or (at your option) any later *
 *                                  version.                                  *
 *                                                                            *
 *   BEH is distributed in the hope that it will be useful, but WITHOUT ANY   *
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS *
 *   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more   *
 *                                  details.                                  *
 *                                                                            *
 *  You should have received a copy of the GNU General Public License along   *
 *           with BEH.  If not, see <http://www.gnu.org/licenses/>.           *
 *                                                                            *
 *****************************************************************************/

module pokegba.rom;

// TO-DO: Rework the remainder of GBAUtils in this fashion, and rename it
// pokegba.

static import io    = std.stdio;
static import bit   = std.bitmanip;
static import str   = std.string;
static import conv  = std.conv;
static import file  = std.file;
static import array = std.array;
static import algor = std.algorithm;

class ROM
{
    private string headerCode;
    private string headerName;
    private string headerMaker;

    static ubyte[] romData;
    public string inputPath;
    static ubyte[] romHeader;

    string[string] romHeaderNames;
    string[string] hexTable;
    
    public bool isPrimalDNAdded = false;
    public bool isRTCAdded = false;
    public bool isDNPkmnPatchAdded = false;
    
    public ubyte freespaceByte = 0xFF;
    public uint  internalOffset;
    
    
    
    
    
    /// ROM Object Constructor
    ///
    /// Initializes the ROM's bytecode buffer, and parses the header info.
    ///
    /// Params:
    ///     romPath = Path to the ROM file we're constructing for
    
    this(string romPath)
    {
        inputPath = romPath;

        loadROMBytes();
        
        headerCode = readASCII(0xAC,4);
        headerName = str.stripRight(readASCII(0xA0, 12));
        headerMaker = readASCII(0xB0, 2);

        updateROMHeaderNames();
        updateFlags();
    }
    
    
    
    /// ROM Flag Updater
    ///
    /// Checks for certain conditionals within the ROM, and updates properties
    /// of the ROM object as necessary. Checks for the Day/Night Pokémon Patch
    /// and the Real Time Clock so far.
    
    public void updateFlags()
    {
        if(str.toUpper(headerCode) == "BPRE")
        {
            if(readByte(0x082903) == 0x8) //Is there a function pointer here?
            {
                isDNPkmnPatchAdded = true;
            }
            
            if(readByte(0x427) == 0x8) //Is interdpth's RTC in there?
            {
                isRTCAdded = true;
            }
        }
        else if(str.toUpper(headerCode) == "BPEE")
        {
            isRTCAdded = true;
            
            if(readByte(0x0B4C7F) == 0x8)
            {
                isDNPkmnPatchAdded = true;
            }
        }
    }
    
    
    /// Read Game Code
    ///
	/// Gets the game code from the ROM, ie BPRE for US Pkmn Fire Red
	public string getGameCode()
	{
		return headerCode;
	}
	
	/// Read Game Text
	///
	/// Gets the game text from the ROM, ie POKEMON FIRE for US Pkmn Fire Red
	public string getGameText()
	{
		return headerName;
	}
	
	/// Read Creator ID
	///
	/// Gets the game creator ID as a string, ie '01' is GameFreak's Company ID
	public string getGameCreatorID()
	{
		return headerMaker;
	}
    
    
    /// Load ROM Data
    ///
    /// (Re)loads the entire ROM bytecode into a 32MiB `ubyte[]` buffer.
    
    public void loadROMBytes()
    {
        romData = cast(ubyte[]) file.read(inputPath, 0x2000000); //32MiB
    }
    
    
    
    /// Read Bytes From ROM
    ///
    /// Reads and returns a given number of bytes from the ROM buffer,
    /// optionally taking an offset in the form of either a `string` or an
    /// `int`.
    ///
    /// Params:
    ///     offset = Offset in ROM as hex string
    ///     size   = Amount of bytes to grab
    ///
    /// Returns: the bytes read, in a `ubyte[]`.
    
    public ubyte[] readBytes(string offset, int size)
    {
        int offs = convertOffsetToInt(offset);
        return readBytes(offs, size);
    }
    
    public ubyte[] readBytes(uint offset, int size)
    {
        return romData[(offset & 0x1FFFFFF)..algor.min(romData.length, (offset
        & 0x1FFFFFF)+size)];
    }
    
    public ubyte[] readBytes(int size)
    {
        ubyte[] t = romData[internalOffset..algor.min(romData.length,
        internalOffset+size)];
        internalOffset += size; 
        return t;
    }
    
    
    
    /// Read Byte From ROM
    ///
    /// Singular alias for function `readBytes()`; reads a single byte from the
    /// ROM buffer and returns it.
    ///
    /// Params:
    ///     offset = Offset to read byte from; optional. If not provided, it
    ///              will use the internal offset and will auto-increment it.
    ///
    /// Returns: The byte read, as a `ubyte`.
    
    public ubyte readByte(uint offset)
    {
        return readBytes(offset,1)[0];
    }
    
    public ubyte readByte()
    {
        return romData[internalOffset++];
    }
    
    
    
    /// Read Word From ROM
    ///
    /// Reads a 32-bit unsigned word from an offset in the ROM buffer,
    /// optionally taking an offset to read from.
    ///
    /// Params:
    ///     offset = Offset to read word from; optional. If not provided, it
    ///              will use the internal offset and will auto-increment it.
    ///
    /// Returns: a `uint` of the word read.
    
    public uint readWord()
    {
        ubyte[4] t = readBytes(4);
        
        return bit.littleEndianToNative!uint(t);
    }
    
    public uint readWord(uint offset)
    {
        ubyte[4] t=readBytes(offset, 4);
        return bit.littleEndianToNative!uint(t);
        
    }
    
    
    
    /// Read Halfword from ROM
    ///
    /// Reads a 16-bit halfword from the ROM buffer, optionally taking an
    /// offset to read from.
    ///
    /// Params:
    ///     offset = Offset to read from; optional. If not provided, it will
    ///              use the internal offset and will auto-increment it.
    ///
    /// Returns: a `ushort` of the halfword read.
    
    public ushort readHalfword(uint offset)
    {
        return bit.littleEndianToNative!ushort(readBytes(offset, 2)[0..2]);
    }
    
    public ushort readHalfword()
    {
        ushort word = bit.littleEndianToNative!ushort(readBytes(internalOffset, 
        2)[0..2]);
        internalOffset += 2;
        return word;
    }
    
    
    
    /// Write Halfword to ROM
    ///
    /// Writes a 16-bit halfword to the ROM buffer, optionally taking an offset
    /// to write to.
    ///
    /// Params:
    ///     offset  = offset to write to; optional. If not provided, it will
    ///               use the internal offset and will auto-increment it.
    ///     toWrite = Data to write.
    
    public void writeHalfword(uint offset, ushort toWrite)
    {
        ubyte[2] nBytes = bit.nativeToLittleEndian(toWrite);
        writeBytes(offset,nBytes);
    }
    
    public void writeHalfword(ushort toWrite)
    {
        writeHalfword(internalOffset,toWrite);
        internalOffset += 2;
    }
    
    
    
    /// Write Bytes to ROM
    ///
    /// Writes an array of bytes to the ROM buffer, optionally taking an offset
    /// to write to.
    ///
    /// Params:
    ///     offset       = Offset to write the bytes at; optional. If not
    ///                    provided, it will use the internal offset and will
    ///                    auto-increment it.
    ///     bytesToWrite = Bytes to write to the ROM.
    
    public void writeBytes(uint offset, ubyte[] bytesToWrite)
    {
        for (int count = 0; count < bytesToWrite.length; count++)
        {
            try
            {
                romData[offset & 0x1FFFFFF] = bytesToWrite[count];
                
                offset++;
            }
            catch (Exception e)
            {
                io.writeln("Tried to write outside of bounds! (%x)", offset &
                0x1FFFFFF);
            }
        }
    }
    
    public void writeBytes(ubyte[] bytesToWrite)
    {
        for (int count = 0; count < bytesToWrite.length; count++)
        {
            romData[internalOffset++] = bytesToWrite[count];
        }
    }
    
    
    
    /// Write Byte to ROM
    ///
    /// Singular wrapper for `writeBytes` - writes a byte to the ROM buffer.
    /// Optionally takes an offset to read from.
    ///
    /// Params:
    ///     b      = Byte to write to the ROM buffer.
    ///     offset = The offset to read from; optional. If not provided, it
    ///              will use the internal offset and will auto-increment it.
    
    public void writeByte(byte b, uint offset)
    {
        romData[offset] = b;
    }
    
    
    
    public void writeByte(byte b)
    {
        romData[internalOffset] = b;
        internalOffset++;
    }
    
    
    
    /// Commit ROM Changes
    ///
    /// Commit all changes to the ROM buffer to file.
    ///
    /// Returns: 1, always.
    
    public int commitROM()
    {
        file.write(inputPath, romData);
        return 1;
    }
    
    
    
    /// Convert Offset to Integer
    ///
    /// Converts a hexadecimal offset into a native integer. Used for directly
    /// accessing the ROM byte array
    ///
    /// Params:
    ///     offset = Offset to convert to an integer.
    ///
    /// Returns The offset provided, as a `uint`.
    
    public uint convertOffsetToInt(string offset)
    {
        return conv.parse!uint(offset, 16);
    }
    
    
    
    /// Get ROM Header
    ///
    /// Retrieves the header of the ROM, based on offset and size. Identical to
    /// `readBytes` just with a different name.
    ///
    /// Params:
    ///     headerOffset = Offset of the ROM header.
    ///     headerSize   = Size of the ROM header.
    ///
    /// Returns: a `ubyte[]` of the ROM header.
    
    public ubyte[] getROMHeader(string headerOffset, uint headerSize)
    {
        romHeader = readBytes(headerOffset, headerSize);
        return romHeader;
    }
    
    
    
    /// Validate Byte in ROM
    ///
    /// Validates the file loaded based on a given byte and offset.
    ///
    /// Params:
    ///     validationOffset = Offset to check in the ROM
    ///     validationByte   = Byte to check it with
    ///
    /// Returns: true if validation passed, false if not.
    
    public bool validateByte(uint validationOffset, ubyte validationByte)
    {
        return romData[validationOffset] == validationByte ? true : false;
    }
    
    
    
    /// Load Hex Table File
    ///
    /// Load a HEX table file for character mapping, such as for Pokétext
    ///
    /// Params:
    ///     tablePath = File path to the character table
    ///
    /// Throws: IOException
    
    public bool loadHexTableFromFile(string tablePath)
    {
        string text = cast(string) file.read(tablePath);
        string[] lines = str.splitLines(text);

        foreach(int i, string line; lines)
        {
            string[] separated = array.split(line, "=");
            string key;
            string value;
            
            if (separated.length > 1)
            {
                key = separated[0];
                value = separated[1];
            }
            else
            {
                key = separated[0];
                value = " ";
            }
            
            hexTable[key] = value;
        }
        
        return true;
    }
    
    
    
    /// Convert Pokétext to ASCII
    ///
    /// Converts Pokétext to ASCII and returns it as a string.
    ///
    /// Params:
    ///     poketext = Pokétext as a byte array
    ///
    /// Returns: ASCII string of Pokétext
    
    public string convertPoketextToASCII(ubyte[] poketext)
    {
        string converted;

        for (int i = 0; i < poketext.length; i++)
        {
            string temp;
            temp = hexTable.get(str.format("%02X", poketext[i]), " ");
    
            if(poketext[i] != 0xFF)
                converted = converted ~ temp;
        }

        return converted;
    }
    
    
    
    /// Get Friendly ROM Header
    ///
    /// Gets a string of the friendly ROM header based on the current ROM, and
    /// returns it.
    ///
    /// Returns: A `string` of the ROM header.
    
    public string getFriendlyROMHeader()
    {
        return romHeaderNames[cast(string)romHeader];
    }
    
    
    
    /// Updated ROM Header Names
    ///
    /// Updates the human-readable names of the ROM headers for the ROM object.
    // Update the list of friendly ROM headers
    // TODO: Load header list from file or .ini and include inside the tool
    
    private void updateROMHeaderNames()
    {
        romHeaderNames["POKEMON FIREBPRE01"] = "Pokémon: FireRed";
        romHeaderNames["POKEMON LEAFBPGE01"] = "Pokémon: LeafGreen";
        romHeaderNames["POKEMON EMERBPEE01"] = "Pokémon: Emerald";
    }
    
    
    
    /// Load Array of Structured Data
    ///
    /// Read a structure of data from the ROM at a given offset a set number
    /// of times, with a set structure size. For example returning the names of
    /// Pokemon into a jagged array of bytes.
    ///
    /// Params:
    ///     offset        = Offset to read the structure from
    ///     amount        = Amount to read
    ///     maxStructSize = Maximum structure size
    ///
    /// Returns: Jagged `ubyte[][]` array of the read pseudostructure
    
    public ubyte[][] loadArrayOfStructuredData(uint offset,
    int amount, int maxStructSize)
    {
        ubyte[][] data = new ubyte[][](maxStructSize, amount + 1);
        int offs = offset & 0x1FFFFFF;
      
        for (int count = 0; count < amount; count++)
        {
            for (int c2 = 0; c2 < maxStructSize; c2++)
            {
                data[c2][count] = romData[offs];
                offs++;
            }
        }

        return data;
    }
    
    
    
    /// Read ASCII from ROM
    ///
    /// Reads an ASCII string from the ROM buffer and spits it out casted into
    /// a string.
    ///
    /// Params:
    ///     offset = The offset to read from
    ///     length = The amount of text to read
    ///
    /// Returns: Returns the text as a string object
    
    public string readASCII(uint offset, int length)
    {
        return cast(string)(romData[offset..offset+length]);
    }
    
    
    
    /// Read Pokétext
    ///
    /// Reads Pokétext from an (optionally) given offset, for an optionally
    /// given length.
    
    public string readPoketext(uint offset)
    {
        return readPoketext(offset, -1);
    }
    
    public string readPoketext(uint offset, int length)
    {
        if(length > -1)
        {
            return convertPoketextToASCII(getData()[offset..offset + length]);
        }
        
        ubyte b = 0x0;
        int i = 0;
        while(b != 0xFF)
        {
            b = getData()[offset+i];
            i++;
        }
        Seek(offset+i);
        return convertPoketextToASCII(getData()[offset..offset + i]);
    }
    
    public string readPoketext()
    {
        ubyte b = 0x0;
        int i = 0;
        while(b != 0xFF)
        {
            b = getData()[internalOffset + i];
            i++;
        }
        
        string s = convertPoketextToASCII(getData()
        [internalOffset..internalOffset + i]);
        internalOffset += i;
        return s;
    }
    
    
    
    public ubyte[] getData()
    {
        return romData;
    }
    
    
    
    /// Get Pointer from ROM
    ///
    /// Retrieves a pointer from an offset in the ROM buffer, either as a full
    /// 32-bit pointer or as a 24-bit `ubyte[]`-friendly pointer, and returns
    /// it as a `uint`.
    ///
    /// Params:
    ///     offset      = Offset to get the pointer from
    ///     fullPointer = Whether we should fetch the full 32-bit pointer or
    ///                   the 24-bit ubyte[] friendly version.
    ///
    /// Returns: the fetched pointer as a uint
    
    public uint getPointer(uint offset, bool fullPointer)
    {
        ubyte[4] data = getData()[offset..offset + 4];
        
        if(!fullPointer)
        {
            data[3] = 0;
        }
        
        return bit.littleEndianToNative!uint(data);
    }
    
    public uint getPointer(uint offset)
    {
        return getPointer(offset,false) & 0x1FFFFFF;
    }
    
    
    
    /// Get Signed Word from ROM
    ///
    /// Fetches a signed word from the ROM buffer, using the internal offset.
    ///
    /// Params:
    ///     fullPointer = whether to use a full 32-bit pointer or to use a
    ///                   `ubyte[]`-friendly 24-bit pointer.
    ///
    /// Returns: an `int` of the offset fetched.
    
    public int getSignedWord(bool fullPointer)
    {
        ubyte[4] data = getData()[internalOffset..internalOffset+4];
        if(!fullPointer)
            data[3] = 0;
        internalOffset += 4;
        int ptr = bit.littleEndianToNative!int(data);
        return (data[3] > 0x7F ? ~ptr : ptr);
    }
    
    
    
    /// Write Word to ROM
    ///
    /// Takes a uint and writes it as a little endian word into the ROM
    /// buffer.
    /// @param pointer Pointer to write
    /// @param offset Offset to write it at\
    
    public void writeWord(uint pointer, uint offset)
    {
        ubyte[] bytes = bit.nativeToLittleEndian(pointer);
        writeBytes(offset,bytes);
    }
    
    public void writeWord(uint pointer)
    {
        ubyte[] bytes = bit.nativeToLittleEndian(pointer);
        
        writeBytes(internalOffset,bytes);
        internalOffset += 4;
    }
    
    
    
    /// Write Pointer to ROM
    ///
    /// Reverses and writes a pointer to the ROM. Assumes pointer is ROM memory
    /// and ORs 08 to it.
    ///
    /// Params:
    ///     pointer = Pointer to write (appends 08 automatically)
    ///     offset  = Offset to write it at
    
    public void writePointer(uint pointer, uint offset)
    {
        ubyte[] bytes = bit.nativeToLittleEndian(pointer);
        bytes[3] |= 8;
        writeBytes(offset, bytes);
    }
    
    public void writePointer(uint pointer)
    {
        ubyte[4] bytes = bit.nativeToLittleEndian(pointer);

        writeBytes(internalOffset,bytes);
        internalOffset += 4;
    }
    
    
    
    /// Get Pointer from ROM
    ///
    /// Gets a pointer at an offset
    ///
    /// Params:
    ///     offset      = Offset to get the pointer from
    ///     fullPointer = Whether we should fetch the full 32 bit pointer or
    ///                   the 24 bit `ubyte[]` friendly version.
    ///
    /// Returns: the fetched pointer, as a uint
    
    public uint getPointer(bool fullPointer)
    {
        ubyte[4] data = getData()[internalOffset..internalOffset+4];
        if(!fullPointer)
            data[3] -= 0x8;
        internalOffset += 4;
        return bit.littleEndianToNative!uint(data);
    }
    
    public uint getPointer()
    {
        return getPointer(false);
    }
    
    
    
    /// Seek Offset in ROM
    ///
    /// Sets the internal offset for the ROM object.
    
    public void Seek(uint offset)
    {
        internalOffset = offset & 0x1FFFFFF;
    }
    
    
    
    /// Find Free Space in ROM
    ///
    /// Searches the ROM for free space, using the ROM object's `freespaceByte`.
    ///
    /// Params:
    ///     length = the amount of free space desired.
    ///     
    
    public int findFreespace(int length)
    {
        return findFreespace(length, 0, false);
    }
    
    public int findFreespace(int length, bool asmSafe)
    {
        return findFreespace(length, 0, asmSafe);
    }
    
    public int findFreespace(uint length, int start)
    {
        return findFreespace(length, start, false);
    }
    
    public int findFreespace(uint length, uint start, bool
    asmSafe)
    {
        byte free = freespaceByte;
        ubyte[] searching = new ubyte[length];
        
        for(int i = 0; i < length; i++)
        {
            searching[i] = free;
        }
        
        uint numMatches = 0;
        uint freespace = -1;
        
        for(int i = start; i < romData.length; i++)
        {
            ubyte b = romData[i];
            ubyte c = searching[numMatches];
            if(b == c)
            {
                numMatches++;
                if(numMatches == searching.length - 1)
                {
                    freespace = i - cast(uint)searching.length + 2;
                    break;
                }
            }
            else
            {
                numMatches = 0;
            }
        }
        
        return freespace;
    }
    
    
    
    /// Flood Bytes Into ROM
    ///
    /// Carelessly overwrites the data at a certain offset with a ubyte, for a
    /// specified length.
    ///
    /// Params:
    ///     offset = Offset to start flooding from
    ///     b      = byte to overwrite with
    ///     length = the amount of bytes to overwrite
    
    public void floodBytes(uint offset, ubyte b, uint length)
    {
        if(offset > 0x1FFFFFF)
        {
            return;
        }
        
        for(int i = offset; i < offset+length; i++)
        {
            romData[i] = b;
        }
    }
    
    
    
    /// Repoint Offset
    ///
    /// Repoint pointer(s) to a specified offset in the ROM buffer.
    ///
    /// Params:
    ///     
    
    public void repoint(uint pOriginal, uint pNew)
    {
        repoint(pOriginal, pNew, -1);
    }
    
    public void repoint(int pOriginal, int pNew, int numbertolookfor)
    {
         pOriginal |= 0x08000000;
         
         ubyte[] searching = bit.nativeToLittleEndian(pOriginal);
         int numMatches = 0;
         int totalMatches = 0;
         uint offset = -1;
         
         for(int i = 0; i < romData.length; i++)
         {
             ubyte b = romData[i];
             ubyte c = searching[numMatches];
             if(b == c)
             {
                 numMatches++;
                 if(numMatches == searching.length - 1)
                 {
                     offset = i - cast(uint)searching.length + 2;
                     this.Seek(offset);
                     this.writePointer(pNew);
                     io.writeln("%x", offset);
                     totalMatches++;
                     
                     if(totalMatches == numbertolookfor)
                     {
                         break;
                     }
                     
                     numMatches = 0;
                 }
             }
             else
             {
                 numMatches = 0;
             }
         }
         io.writeln("Found %i occurences of the pointer specified.",
         totalMatches);
    }
}





static class ROMManager
{
    static:
    
    ROM[ulong] screenStore;
    ROM currentROM = null;
    
    ROM getActiveROM()
    {
        return currentROM;
    }

    void addROM(ulong stateID, ROM rom)
    {
        screenStore[stateID] = rom;
    }

    void changeROM(ulong stateID)
    {
        currentROM = screenStore[stateID];
    }
    
    ulong getID()
    {
        return screenStore.length;
    }
    
    /// Load ROM into ROM Manager
    ///
    /// Loads a ROM using stdin if no location is provided. Sets the loaded ROM as default.
    ///
    /// Returns: The ROMManager ROM ID.
    
    ulong loadROM()
    {
        string location;
        
        io.writef("Please select a ROM: ");
        location = io.readln();
        
        return loadROM(location);
    }
    
    ulong loadROM(string location)
    {        
        if(location.length == 0)
        {
            return -1;
        }

        ulong romID = ROMManager.getID();
        addROM(romID, new ROM(location));
        changeROM(romID);
        
        if(getActiveROM().hexTable.length == 0)
        {
            if(!getActiveROM().loadHexTableFromFile("./resources/poketable.tbl"))
            {
                return -3;
            }
        }
        
        io.writefln(conv.to!string(romID));
        return romID;
    }
}
