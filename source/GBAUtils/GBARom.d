module GBAUtils.GBARom;

import std.stdio : writeln;
import std.stdio : writefln;
import std.bitmanip;
import std.uni;
import std.string;
import std.conv;
import std.file;
import std.array;
import std.algorithm;

import GBAUtils.ROMManager;

class GBARom
{
	private string headerCode = "";
	private string headerName = "";
	private string headerMaker = "";

	static ubyte[] rom_bytes;
	public string input_filepath;
	static ubyte[] current_rom_header;

	string[string] rom_header_names;
	string[string] hex_tbl;
	
	public bool isPrimalDNAdded = false;
	public bool isRTCAdded = false;
	public bool isDNPkmnPatchAdded = false;
	
	/**
	 *  Wraps that ROM up like a nice warm burrito
	 * @param rom_path Path to the ROM file
	 */
	this(string rom_path)
	{
		input_filepath = rom_path;

		loadRomToBytes();
		
		headerCode = readASCII(0xAC,4);
		headerName = stripRight(readASCII(0xA0, 12));
		headerMaker = readASCII(0xB0, 2);

		updateROMHeaderNames();
		updateFlags();
	}
	
	public void updateFlags()
	{
		if(toUpper(headerCode) == "BPRE")
		{
			if(readByte(0x082903) == 0x8) //Is there a function pointer here?
				isDNPkmnPatchAdded = true;
			if(readByte(0x427) == 0x8) //Is interdpth's RTC in there?
				isRTCAdded = true;
		}
		else if(toUpper(headerCode) == "BPEE")
		{
			isRTCAdded = true;
			if(readByte(0x0B4C7F) == 0x8)
				isDNPkmnPatchAdded = true;
		}
	}

	/**
	 *  Loads the files from the ROM into the byte array
	 * @throws IOException
	 */
	public void loadRomToBytes()
	{
		rom_bytes = cast(ubyte[]) read(input_filepath, 0x2000000); //32MB
	}

	/**
	 *  Read bytes from the ROM from given offset into an array of a given size
	 * @param offset Offset in ROM as hex string
	 * @param size Amount of bytes to grab
	 * @return
	 */
	public ubyte[] readBytes(string offset, int size)
	{
		int offs = convertOffsetToInt(offset);
		return readBytes(offs, size);
	}

	/**
	 *  Read bytes from the ROM from given offset into an array of a given size
	 * @param offset Offset in ROM
	 * @param size Amount of bytes to grab
	 * @return
	 */
	public ubyte[] readBytes(uint offset, int size)
	{
		return rom_bytes[(offset & 0x1FFFFFF)..min(rom_bytes.length, (offset & 0x1FFFFFF)+size)];
	}
	public ubyte[] readBytes(int size)
	{
		ubyte[] t = rom_bytes[internalOffset..min(rom_bytes.length, internalOffset+size)];
		internalOffset += size;	
		return t;
	}
	/**
	 * Reads a byte from an offset
	 * @param offset Offset to read from
	 * @return
	 */
	public ubyte readByte(uint offset)
	{
		return readBytes(offset,1)[0];
	}
	
	public ubyte readByte()
	{
		return rom_bytes[internalOffset++];
	}

	public uint readLong()
	{
		ubyte[4] t=readBytes(4);
		return littleEndianToNative!uint(t);
		
	}
	public uint readLong(uint offset)
	{
		ubyte[4] t=readBytes(offset, 4);
		return littleEndianToNative!uint(t);
		
	}
	/**
	 * Reads a 16 bit word from an offset
	 * @param offset Offset to read from
	 * @return
	 */
	public ushort readWord(uint offset)
	{
		return littleEndianToNative!ushort(readBytes(offset,2)[0..2]);
	}
	
	public void writeWord(uint offset, ushort toWrite)
	{
		ubyte[2] nBytes = nativeToLittleEndian(toWrite);
		writeBytes(offset,nBytes);
	}
	
	public void writeWord(ushort toWrite)
	{
		writeWord(internalOffset,toWrite);
		internalOffset += 2;
	}
	
	/**
	 * Reads a 16 bit word from an InternalOffset
	 * @param offset Offset to read from
	 * @return
	 */
	public ushort readWord()
	{
		ushort word = littleEndianToNative!ushort(readBytes(internalOffset,2)[0..2]);
		internalOffset+=2;
		return word;
	}
	/**
	 *  Write an array of bytes to the ROM at a given offset
	 * @param offset Offset to write the bytes at
	 * @param bytes_to_write Bytes to write to the ROM
	 */
	public void writeBytes(uint offset, ubyte[] bytes_to_write)
	{
		for (int count = 0; count < bytes_to_write.length; count++)
		{
			try {
				rom_bytes[offset & 0x1FFFFFF] = bytes_to_write[count];
				offset++;
			}
			catch (Exception e) {
				writeln("Tried to write outside of bounds! (%x)", offset & 0x1FFFFFF);
			}
		}
	}
	
	public void writeByte(byte b, uint offset)
	{
		rom_bytes[offset] = b;
	}
	
	public void writeByte(byte b)
	{
		rom_bytes[internalOffset] = b;
		internalOffset++;
	}
	
    public int internalOffset;
    /**
	 *  Write an array of bytes to the ROM at a given offset
	 * @param offset Offset to write the bytes at
	 * @param bytes_to_write Bytes to write to the ROM
	 */
    public void writeBytes(ubyte[] bytes_to_write)
	{
		for (int count = 0; count < bytes_to_write.length; count++)
		{
			rom_bytes[internalOffset] = bytes_to_write[count];
			internalOffset++;
		}
	}
	/**
	 *  Write any changes made back to the ROM file on disk
	 * @return
	 */
	public int commitChangesToROMFile()
	{
		write(input_filepath, rom_bytes);
		return 1;
	}

	/**
	 *  Convert a string offset i.e 0x943BBD into a decimal
	 *  Used for directly accessing the ROM byte array
	 * @param offset Offset to convert to an integer
	 * @return The offset as an int
	 */
	public uint convertOffsetToInt(string offset)
	{
		return parse!uint(offset, 16);
	}

	/**
	 *  Retrieve the header of the ROM, based on offset and size
	 *  Identical to readBytesFromROM just with a different name
	 * @param header_offset
	 * @param header_size
	 * @return
	 */
	public ubyte[] getROMHeader(string header_offset, int header_size)
	{
		current_rom_header = readBytes(header_offset, header_size);
		return current_rom_header;
	}

	/**
	 *  Validate the file loaded based on a given byte and offset
	 * @param validation_offset Offset to check in the ROM
	 * @param validation_byte Byte to check it with
	 * @return
	 */
	public bool validateROM(int validation_offset, byte validation_byte)
	{
		if (rom_bytes[validation_offset] == validation_byte)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	/**
	 *  Load a HEX table file for character mapping i.e. Pokétext
	 * @param tbl_path File path to the character table
	 * @throws IOException
	 */
	public void loadHexTBLFromFile(string tbl_path)
	{
		string text = cast(string)read(tbl_path);
		string[] lines = text.splitLines();

		foreach(int i, string line; lines)
		{
			string[] seperated = line.split("=");
			string key;
			string value;

			if (seperated.length > 1)
			{
				key = seperated[0];
				value = seperated[1];
			}
			else
			{
				key = seperated[0];
				value = " ";
			}

			hex_tbl[key] = value;
		}
	}
	
	/**
	 *  Load a HEX table file for character mapping i.e. Pokétext
	 * @param tbl_path File path to the character table
	 * @throws IOException
	 */
	public bool loadHexTBL(string tbl_path)
	{
		string text = cast(string)read(tbl_path);
		string[] lines = text.splitLines();

		foreach(int i, string line; lines)
		{
			string[] seperated = line.split("=");
			string key;
			string value;

			if (seperated.length > 1)
			{
				key = seperated[0];
				value = seperated[1];
			}
			else
			{
				key = seperated[0];
				value = " ";
			}

			hex_tbl[key] = value;
		}
		return true;
	}

	/**
	 *  Convert Poketext to ascii, takes an array of bytes of poketext
	 *  Basically returns the results from the given HEX Table <- must loadHexTBL first
	 * @param poketext Poketext as a byte array
	 * @return
	 */
	public string convertPoketextToAscii(ubyte[] poketext)
	{
		string converted = "";

		for (int i = 0; i < poketext.length; i++)
		{
			string temp;
			temp = hex_tbl.get(format("%02X", poketext[i]), " ");
    
            if(poketext[i] != 0xFF)
			    converted = converted ~ temp;
		}

		return converted;
	}

	/**
	 *  Return a string of the friendly ROM header based on the current ROM
	 * @return
	 */
	public string getFriendlyROMHeader()
	{
		return rom_header_names[cast(string)current_rom_header];
	}

	// Update the list of friendly ROM headers
	// TODO: Load header list from file or .ini and include inside the tool
	private void updateROMHeaderNames()
	{
		rom_header_names["POKEMON FIREBPRE01"] = "Pokémon: FireRed";
		rom_header_names["POKEMON LEAFBPGE01"] = "Pokémon: LeafGreen";
		rom_header_names["POKEMON EMERBPEE01"] = "Pokémon: Emerald";
	}

	/**
	 *  Read a structure of data from the ROM at a given offset, a set numner of times, with a set structure size
	 *  For example returning the names of Pokemon into an ArrayList of bytes
	 * @param offset Offset to read the structure from
	 * @param amount Amount to read
	 * @param max_struct_size Maximum structure size
	 * @return
	 */
	public ubyte[][] loadArrayOfStructuredData(uint offset,
			int amount, int max_struct_size)
	{
		ubyte[][] data = new ubyte[][](max_struct_size, amount+1);
		int offs = offset & 0x1FFFFFF;
      
		for (int count = 0; count < amount; count++)
		{
			for (int c2 = 0; c2 < max_struct_size; c2++)
			{
				data[c2][count] = rom_bytes[offs];
				offs++;
			}
		}

		return data;
	}

	/**
	 * Reads ASCII text from the ROM
	 * @param offset The offset to read from
	 * @param length The amount of text to read
	 * @return Returns the text as a string object
	 */
	public string readASCII(uint offset, int length)
	{
		return cast(string)(rom_bytes[offset..offset+length]);
	}
	
	public string readPokeText(uint offset)
	{
		return readPokeText(offset, -1);
	}
	
	public string readPokeText(uint offset, int length)
	{
		if(length > -1)
			return convertPoketextToAscii(getData()[offset..offset+length]);
		
		ubyte b = 0x0;
		int i = 0;
		while(b != 0xFF)
		{
			b = getData()[offset+i];
			i++;
		}
		Seek(offset+i);
		return convertPoketextToAscii(getData()[offset..offset+i]);
	}
	
	public string readPokeText()
	{
		ubyte b = 0x0;
		int i = 0;
		while(b != 0xFF)
		{
			b = getData()[internalOffset+i];
			i++;
		}
		
		string s = convertPoketextToAscii(getData()[internalOffset..internalOffset+i]);
		internalOffset += i;
		return s;
	}
	
	public ubyte[] getData()
	{
		return rom_bytes;
	}
	
	/**
	 * Gets a pointer at an offset
	 * @param offset Offset to get the pointer from
	 * @param fullPointer Whether we should fetch the full 32 bit pointer or the 24 bit ubyte[] friendly version.
	 * @return Pointer as a Long
	 */
	public uint getPointer(uint offset, bool fullPointer)
	{
	    writefln("%X", offset);
	    if(offset+4 > getData().length)
	    {
	        writefln("Error! Tried to access pointer at %x", offset);
	        return 0;
	    }
	    
		ubyte[4] data = getData()[offset..offset+4];
		if(!fullPointer)
			data[3]=0;
		return littleEndianToNative!uint(data);
	}
	
	/**
	 * Gets a 24 bit pointer in the ROM as an integer. 
	 * @param offset Offset to get the pointer from
	 * @return Pointer as a Long
	 */
	public uint getPointer(uint offset)
	{
		return getPointer(offset,false)& 0x1FFFFFF;
	}
	
	public uint getSignedLong(bool fullPointer)
	{
		ubyte[4] data = getData()[internalOffset..internalOffset+4];
		if(!fullPointer)
			data[3] = 0;
		internalOffset+=4;
		uint ptr = littleEndianToNative!uint(data);
		return (data[3] > 0x7F ? ~ptr : ptr);
	}
	
	/**
	 * Reverses and writes a pointer to the ROM
	 * @param pointer Pointer to write
	 * @param offset Offset to write it at
	 */
	public void writePointer(uint pointer, uint offset)
	{
		ubyte[] bytes = nativeToLittleEndian(pointer);
		writeBytes(offset,bytes);
	}
	
	/**
	 * Reverses and writes a pointer to the ROM. Assumes pointer is ROM memory and appends 08 to it.
	 * @param pointer Pointer to write (appends 08 automatically)
	 * @param offset Offset to write it at
	 */
	public void writePointer(int pointer, uint offset)
	{
		ubyte[] bytes = nativeToLittleEndian(pointer);
		bytes[3] = 0x08;
		writeBytes(offset,bytes);
	}
	
	/**
	 * Gets the game code from the ROM, ie BPRE for US Pkmn Fire Red
	 * @return
	 */
	public string getGameCode()
	{
		return headerCode;
	}
	
	/**
	 * Gets the game text from the ROM, ie POKEMON FIRE for US Pkmn Fire Red
	 * @return
	 */
	public string getGameText()
	{
		return headerName;
	}
	
	/**
	 * Gets the game creator ID as a string, ie '01' is GameFreak's Company ID
	 * @return
	 */
	public string getGameCreatorID()
	{
		return headerMaker;
	}

	/**
	 * Gets a pointer at an offset
	 * @param offset Offset to get the pointer from
	 * @param fullPointer Whether we should fetch the full 32 bit pointer or the 24 bit ubyte[] friendly version.
	 * @return Pointer as a Long
	 */
	public uint getPointer(bool fullPointer)
	{
		ubyte[4] data = getData()[internalOffset..internalOffset+4];
		if(!fullPointer)
			data[3] -= 0x8;
		internalOffset+=4;
		return littleEndianToNative!uint(data);
	}
	
	/**
	 * Gets a 24 bit pointer in the ROM as an integer. 
	 * @param offset Offset to get the pointer from
	 * @return Pointer as a Long
	 */
	public uint getPointer()
	{
		return getPointer(false);
	}
	
	/**
	 * Gets a pointer in the ROM as an integer. 
	 * Does not support 32 bit pointers due to Java's integer size not being uint enough.
	 * @param offset Offset to get the pointer from
	 * @return Pointer as an Integer
	 */
	public int getPointerAsInt()
	{
		return cast(int)getPointer(internalOffset,false);
	}
	
	/**
	 * Reverses and writes a pointer to the ROM
	 * @param pointer Pointer to write
	 * @param offset Offset to write it at
	 */
	public void writePointer(uint pointer)
	{
		ubyte[4] bytes = nativeToLittleEndian(pointer);

		writeBytes(internalOffset,bytes);
		internalOffset+=4;
	}
	
	public void writeSignedPointer(uint pointer)
	{
		ubyte[4] bytes = nativeToLittleEndian(pointer);

		writeBytes(internalOffset,bytes);
		internalOffset+=4;
	}
	
	/**
	 * Reverses and writes a pointer to the ROM. Assumes pointer is ROM memory and appends 08 to it.
	 * @param pointer Pointer to write (appends 08 automatically)
	 * @param offset Offset to write it at
	 */
	public void writePointer(int pointer)
	{
		ubyte[] bytes = nativeToLittleEndian(pointer);
		bytes[3] += 0x8;

		writeBytes(internalOffset,bytes);
		internalOffset+=4;
	}
	
	/**
	 * Gets the game code from the ROM, ie BPRE for US Pkmn Fire Red
	 * @return
	 */
	public void Seek(uint offset)
	{
		if(offset > 0x08000000)
			offset &= 0x1FFFFFF;
		
		internalOffset=offset;
	}

	public byte freeSpaceByte = cast(byte)0xFF;
	public int findFreespace(int length)
	{
		return findFreespace(length, 0, false);
	}
	
	public int findFreespace(int length, bool asmSafe)
	{
		return findFreespace(length, 0, asmSafe);
	}
	
	public int findFreespace(uint freespaceStart, int startingLocation)
	{
		return findFreespace(freespaceStart, startingLocation, false);
	}
	
	public int findFreespace(uint freespaceSize, uint startingLocation, bool asmSafe)
	{
		byte free = freeSpaceByte;
		 ubyte[] searching = new ubyte[freespaceSize];
		 for(int i = 0; i < freespaceSize; i++)
			 searching[i] = free;
		 uint numMatches = 0;
		 uint freespace = -1;
		 for(int i = startingLocation; i < rom_bytes.length; i++)
		 {
			 ubyte b = rom_bytes[i];
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
				 numMatches = 0;
		 }
		 return freespace;
	}
	
	public void floodBytes(uint offset, byte b, int length)
	{
		if(offset > 0x1FFFFFF)
			return;
		
		for(int i = offset; i < offset+length; i++)
			rom_bytes[i] = b;
	}
	
	public void repoint(int pOriginal, int pNew)
	{
		repoint(pOriginal, pNew, -1);
	}
	
	public void repoint(int pOriginal, int pNew, int numbertolookfor)
	{
		pOriginal |= 0x08000000;
		 ubyte[] searching = nativeToLittleEndian(pOriginal);
		 int numMatches = 0;
		 int totalMatches = 0;
		 uint offset = -1;
		 for(int i = 0; i < rom_bytes.length; i++)
		 {
			 byte b = rom_bytes[i];
			 byte c = searching[numMatches];
			 if(b == c)
			 {
				 numMatches++;
				 if(numMatches == searching.length - 1)
				 {
					 offset = i - cast(uint)searching.length + 2;
					 this.Seek(offset);
					 this.writePointer(pNew);
					 writeln("%x", offset);
					 totalMatches++;
					 if(totalMatches == numbertolookfor)
						 break;
					 numMatches = 0;
				 }
			 }
			 else
				 numMatches = 0;
		 }
		 writeln("Found %i occurences of the pointer specified.", totalMatches);
	}
}
