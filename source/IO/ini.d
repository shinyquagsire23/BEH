/*
	Copyright (C) 2004-2006 Christopher E. Miller
	http://www.dprogramming.com/ini.php

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.
*/

/*
 
	Modified by Jesse Phillips
	Made to work with D 2.0. 
	Changed all string to string. 
	Added some @safe and nothrow
	Other changes marked

Update:
The Ini object no longer saves in the destructor because if it is the
garbage collector deleting it, some value or section object could have
been destructed first, resulting in undefined behavior, such as an
access violation. Solution: save() before you exit the program.


Portable module for reading and writing INI files of the format:

[section]
key=value
...

Leading spaces and tabs are ignored.
Comments start with ; and should be on their own line.

If there are comments, spaces or keys above the first section, a nameless section is created for them.
This means there need not be any sections in the file to have keys.

Differences with Windows' profile (INI) functions:
* Windows 9x does not allow tabs in the value.
* Some versions do not allow the file to exceed 64 KB.
* If not a full file path, it's relative to the Windows directory.
* Windows 9x strips trailing spaces from the value.
* There might be a restriction on how long sections/keys/values may be.
* If there are double quotes around a value, Windows removes them.
* All key/value pairs must be in a named section.

*/



/// Portable module for reading and writing _INI files. _ini.d version 0.6
module IO.ini;

private import std.file, std.string, std.stream, std.range;;


//debug = INI; //show file being parsed


debug(INI)
	private import std.cstream;


private class IniLine
{
	~this()
	{
		debug(PRINT_DTORS)
			printf("~IniLine\n");
	}
	
	
private:
	string data;
}


/// Key in an INI file.
class IniKey: IniLine
{
protected:
	//these are slices in data if unmodified
	//if modified, data is set to null
	string _name;
	string _value;


	this(string name)
	{
		_name = name;
	}
	
	
	~this()
	{
		debug(PRINT_DTORS)
			printf("~IniKey '%.*s'\n", _name);
	}


public:
	/// Property: get key _name.
	@property string name()
	{
		return _name;
	}


	/// Property: get key _value.
	@property string value()
	{
		return _value;
	}
}


/// Section of keys in an INI file.
class IniSection
{
protected:
	Ini _ini;
	string _name;
	IniLine[] lines;
	bool _detatched;

	this(Ini ini, string name, bool detatched = false)
	{
		_ini = ini;
		_name = name;
		_detatched = detatched;
	}
	
	
	~this()
	{
		debug(PRINT_DTORS)
			printf("~IniSection '%.*s'\n", _name);
	}

	@safe nothrow
	private void attach() {
		if(_detatched)
			_ini.addSection(this);
		_detatched = false;
	}

	unittest {
		string inifile = "unittest.ini";
		Ini ini;

		ini = new Ini(inifile);
		auto sec = ini["NewSection"];
		sec.setValue("NewKey", "NewValue");
		assert(ini["NewSection"]["NewKey"] == "NewValue");
		import std.range;
		assert(ini["Invalid"]["Invalid"].empty);
		ini["missing"]["new"] = "Value";
		assert(ini["missing"]["new"] == "Value");
	}

public:
	/// Property: get section _name.
	@property @safe nothrow
	string name()
	{
		return _name;
	}


	/// Property: set section _name.
	@property @safe nothrow
	void name(string newName)
	{
		_ini._modified = true;
		_name = newName;
	}


	/// foreach key.
	int opApply(int delegate(ref IniKey) dg)
	{
		int result = 0;
		uint i;
		IniKey ikey;
		for(i = 0; i != lines.length; i++)
		{
			ikey = cast(IniKey)lines[i];
			if(ikey)
			{
				result = dg(ikey);
				if(result)
					break;
			}
		}
		return result;
	}


	/// Property: get all _keys.
	//better to use foreach unless this array is needed
	@property IniKey[] keys()
	{
		IniKey[] ikeys = new IniKey[lines.length];
		uint i = 0;
		foreach(IniKey ikey; this)
		{
			ikeys[i++] = ikey;
		}
		return ikeys[0 .. i];
	}


	/// Returns: _key matching keyName, or a new key if not present.
	IniKey key(string keyName)
	{
		foreach(IniKey ikey; this)
		{
			if(_ini.match(ikey._name, keyName))
				return ikey;
		}
		return new IniKey(keyName); //didn't find it
	}


	/// Set an existing key's value.
	@safe nothrow
	void setValue(IniKey ikey, string newValue)
	{
		ikey._value = newValue;
		_ini._modified = true;
		ikey.data = null;
		if(_detatched)
			attach();
	}

	/// Find or create key keyName and set its _value to newValue.
	void setValue(string keyName, string newValue)
	{
		IniKey ikey = key(keyName);
		if(!ikey.data)
		{
			ikey = new IniKey(keyName);
			lines ~= ikey;
			//_ini._modified = true; //next call does this
		}
		value(ikey, newValue);
	}
	
	
	/+
	///
	alias setValue value;
	+/
	
	
	/// Same as setValue(ikey, newValue).
	@safe nothrow
	void value(IniKey ikey, string newValue)
	{
		return setValue(ikey, newValue);
	}
	
	
	/// Same as setValue(keyName, newValue).
	void value(string keyName, string newValue)
	{
		return setValue(keyName, newValue);
	}


	/// Returns: value of the existing key keyName, or defaultValue if not present.
	string getValue(string keyName, string defaultValue = null)
	{
		foreach(IniKey ikey; this)
		{
			if(_ini.match(ikey._name, keyName))
				return ikey.value;
		}
		return defaultValue; //didn't find it
	}
	
	
	// /// Returns: _value of the existing key keyName, or null if not present.
	/// Same as getValue(keyName, null).
	string value(string keyName)
	{
		return getValue(keyName, null);
	}


	/// Shortcut for getValue(keyName).
	string opIndex(string keyName)
	{
		return value(keyName);
	}


	/// Shortcut for setValue(keyName, newValue).
	void opIndexAssign(string newValue, string keyName)
	{
		value(keyName, newValue);
	}
	
	
	/// _Remove key keyName.
	void remove(string keyName)
	{
		uint i;
		IniKey ikey;
		for(i = 0; i != lines.length; i++)
		{
			ikey = cast(IniKey)lines[i];
			if(ikey && _ini.match(ikey._name, keyName))
			{
				if(i == lines.length - 1)
					lines = lines[0 .. i];
				else if(i == 0)
					lines = lines[1 .. lines.length];
				else
					lines = lines[0 .. i] ~ lines[i + 1 .. lines.length];
				_ini._modified = true;
				return;
			}
		}
	}
}


/// An INI file.
class Ini
{
protected:
	string _file;
	bool _modified = false;
	IniSection[] isecs;
	char secStart = '[', secEnd = ']';


	void parse(string data = null)
	{
		debug(INI)
			printf("INI parsing file '%.*s'\n", _file);

		int i = -1;
		IniSection isec;
		uint lineStartIndex = 0; 

		try
		{
			if(data.empty)
				data = cast(string)std.file.read(_file);
			/+
			File f = new File(_file, FileMode.In);
			data = f.readString(f.size());
			delete f;
			+/
		}
		catch(Throwable o)
		{
			debug(INI)
				std.cstream.dout.writeString("INI no file to parse\n");
			return;
		}
		if(!data.length)
		{
			debug(INI)
				std.cstream.dout.writeString("INI nothing to parse\n");
			return;
		}


		char getc()
		{
			//also increment -i- past end so ungetc works properly
			if(++i >= data.length)
				return 0;
			return data[i];
		}


		void ungetc()
		{
			assert(i > 0);
			i--;
		}
		
		
		void reset()
		{
			lineStartIndex = i + 1;
		}


		void eol()
		{
			IniLine iline = new IniLine;
			iline.data = data[lineStartIndex .. i];
			debug(INI)
				printf("INI line: '%.*s'\n", std.string.replace(std.string.replace(std.string.replace(iline.data, "\\", "\\\\"), "\r", "\\r"), "\n", "\\n"));
			isec.lines ~= iline;
		}


		char ch, ch2;
		int i2;
		isec = new IniSection(this, "");
		for(;;)
		{
			ch = getc();
			switch(ch)
			{
				case '\r':
					eol();
					ch2 = getc();
					if(ch2 != '\n')
						ungetc();
					reset();
					break;

				case '\n':
					eol();
					reset();
					break;

				case 0: //eof
					ini_eof:
					if(lineStartIndex < i)
					{
						eol();
						//reset();
					}
					isecs ~= isec;
					if(!isecs[0].lines)
						isecs = isecs[1 .. isecs.length];
					debug(INI)
						std.cstream.dout.writeString("INI done parsing\n\n");
					return;

				case ' ':
				case '\t':
				case '\v':
				case '\f':
					break;
				
				case ';': //comments
				case '#':
					done_comment:
					for(;;)
					{
						ch2 = getc();
						switch(ch2)
						{
							case '\r':
								eol();
								ch2 = getc();
								if(ch2 != '\n')
									ungetc();
								reset();
								break done_comment;
							
							case '\n':
								eol();
								reset();
								break done_comment;
							
							case 0: //eof
								goto ini_eof;
							
							default:
								break;
						}
					}
					break;
				
				default:
					if(ch == secStart) // '['
					{
						i2 = i + 1;
						done_sec:
						for(;;)
						{
							ch2 = getc();
							switch(ch2)
							{
								case '\r':
									eol();
									ch2 = getc();
									if(ch2 != '\n')
										ungetc();
									reset();
									break done_sec;

								case '\n':
									eol();
									reset();
									break done_sec;

								case 0: //eof
									goto ini_eof;

								default:
									if(ch2 == secEnd) // ']'
									{
										isecs ~= isec;
										isec = new IniSection(this, data[i2 .. i]);
										debug(INI)
											printf("INI section: '%.*s'\n", isec._name);
										for(;;)
										{
											ch2 = getc();
											switch(ch2)
											{
												case ' ':
												case '\t':
												case '\v':
												case '\f':
													//ignore whitespace
													break;
		
												case '\r':
													ch2 = getc();
													if(ch2 != '\n')
														ungetc();
													break done_sec;
		
												case '\n':
													break done_sec;
		
												default:
													//just treat junk after the ] as the next line
													ungetc();
													break done_sec;
											}
										}
										break done_sec;
									}
							}
						}
						reset();
						break;
					}
					else //must be beginning of key name
					{
						i2 = i;
						done_default:
						for(;;)
						{
							ch2 = getc();
							switch(ch2)
							{
								case '\r':
									eol();
									ch2 = getc();
									if(ch2 != '\n')
										ungetc();
									reset();
									break done_default;
								
								case '\n':
									eol();
									reset();
									break done_default;
								
								case 0: //eof
									goto ini_eof;
								
								case ' ':
								case '\t':
								case '\v':
								case '\f':
									break;
								
								case '=':
									IniKey ikey;
	
	
									void addKey()
									{
										ikey.data = data[lineStartIndex .. i];
										ikey._value = data[i2 .. i].strip();
										isec.lines ~= ikey;
										debug(INI)
											printf("INI key: '%.*s' = '%.*s'\n", ikey._name, ikey._value);
									}
									
									
									ikey = new IniKey(data[i2 .. i].strip());
									i2 = i + 1; //after =
									for(;;) //get key value
									{
										ch2 = getc();
										switch(ch2)
										{
											case '\r':
												addKey();
												ch2 = getc();
												if(ch2 != '\n')
													ungetc();
												reset();
												break done_default;
											
											case '\n':
												addKey();
												reset();
												break done_default;
											
											case 0: //eof
												addKey();
												reset();
												goto ini_eof;
											
											default:
												break;
										}
									}
									break done_default;
								
								default:
									break;
							}
						}
					}
			}
		}
	}
	
	
	void firstOpen(string file, string data = null)
	{
		//null terminated just to make it easier for the implementation
		//_file = toStringz(file)[0 .. file.length];
		// JP Modified
		_file = file;
		parse(data);
	}


public:
	// Added by Jesse Phillips
	/// Upon the next save use this file.
	string saveTo;
	// Use different section name delimiters; not recommended.
	this(string file, char secStart, char secEnd)
	{
		this.secStart = secStart;
		this.secEnd = secEnd;
		
		firstOpen(file);
	}


	/// Construct a new INI _file.
	this(string file, string data = null)
	{
		firstOpen(file, data);
	}


	~this()
	{
		debug(PRINT_DTORS)
			printf("~Ini '%.*s'\n", _file);
		
		// The reason this is commented is explained above.
		/+
		if(_modified)
			save();
		+/
	}


	/// Comparison function for section and key names. Override to change behavior.
	bool match(string s1, string s2)
	{
		return !std.string.icmp(s1, s2);
	}


	//reuse same object for another file
	/// Open an INI _file.
	void open(string file)
	{
		if(_modified)
			save();
		_modified = false;
		isecs = null;
		
		firstOpen(file);
	}


	/// Reload INI file; any unsaved changes are lost.
	void rehash()
	{
		_modified = false;
		isecs = null;
		parse();
	}


	/// Release memory without saving changes; contents become empty.
	@safe nothrow
	void dump()
	{
		_modified = false;
		isecs = null;
	}


	/// Property: get whether or not the INI file was _modified since it was loaded or saved.
	@property @safe nothrow
	bool modified()
	{
		return _modified;
	}
	
	
	/// Params:
	/// f = an opened-for-write stream; save() uses BufferedFile by default. Override save() to change stream.
	protected final void saveToStream(Stream f)
	{
		_modified = false;

		if(!isecs.length)
			return;

		IniKey ikey;
		IniSection isec;
		uint i = 0, j;
		//auto File f = new File;

		//f.create(_file, FileMode.Out);
		assert(f.writeable);

		if(isecs[0]._name.length)
			goto write_name;
		else //first section doesn't have a name; just keys at start of file
			goto after_name;

		for(; i != isecs.length; i++)
		{
			write_name:
			// JP Modified added dup
			f.printf("%c%.*s%c\r\n".dup, secStart, isecs[i]._name.dup, secEnd);
			after_name:
			isec = isecs[i];
			for(j = 0; j != isec.lines.length; j++)
			{
				if(isec.lines[j].data is null)
				{
					ikey = cast(IniKey)isec.lines[j];
					if(ikey)
						ikey.data = ikey._name ~ "=" ~ ikey._value;
				}
				f.writeString(isec.lines[j].data);
				f.writeString("\r\n");
			}
		}
	}

	/// Write contents to disk, even if no changes were made. It is common to do if(modified)save();
	void save()
	{
		if(saveTo) {
			_file = saveTo;
			saveTo = null;
		}
		BufferedFile f = new BufferedFile;
		f.create(_file);
		try
		{
			saveToStream(f);
			f.flush();
		}
		finally
		{
			f.close();
		}
	}

	/// Write contents to disk with filename
	// Added by Jesse Phillips
	void save(string filename) {
		_file = filename;
		save();
	}


	/// Finds a _section; returns a new section if one named name does not exist.
	IniSection section(string name)
	{
		foreach(IniSection isec; isecs)
		{
			if(match(isec._name, name))
				return isec;
		}
		return new IniSection(this, name, true); //didn't find it
	}

	bool hasSection(string name)
	{
		foreach(IniSection isec; isecs)
			if(match(isec._name, name))
				return true;
		return false;
	}

	unittest {
		string inifile = "unittest.ini";
		Ini ini;

		ini = new Ini(inifile);
		auto sec = ini["NewSection"];
		sec.setValue("NewKey", "NewValue");
		assert(ini.hasSection("NewSection"));
		assert(!ini.hasSection("Missing"));
	}

	/// Shortcut for section(sectionName).
	IniSection opIndex(string sectionName)
	{
		return section(sectionName);
	}


	/// The section is created if one named name does not exist.
	/// Returns: Section named name.
	IniSection addSection(string name)
	{
		IniSection isec = section(name);
		if(isec._detatched)
			isec.attach();
		return isec;
	}

	@safe nothrow
	void addSection(IniSection isec)
	{
		isecs ~= isec;
		_modified = true;
	}

	/// foreach section.
	int opApply(int delegate(ref IniSection) dg)
	{
		int result = 0;
		foreach(IniSection isec; isecs)
		{
			result = dg(isec);
			if(result)
				break;
		}
		return result;
	}


	/// Property: get all _sections.
	@property @safe nothrow
	IniSection[] sections()
	{
		return isecs;
	}
	
	
	/// _Remove section named sectionName.
	void remove(string sectionName)
	{
		uint i;
		for(i = 0; i != isecs.length; i++)
		{
			if(match(sectionName, isecs[i]._name))
			{
				if(i == isecs.length - 1)
					isecs = isecs[0 .. i];
				else if(i == 0)
					isecs = isecs[1 .. isecs.length];
				else
					isecs = isecs[0 .. i] ~ isecs[i + 1 .. isecs.length];
				_modified = true;
				return;
			}
		}
	}
}


unittest
{
	string inifile = "unittest.ini";
	// Jesse Phillips
	// Remove file when done.
	scope(exit)
		std.file.remove(inifile);
	Ini ini;

	ini = new Ini(inifile);
	with(ini.addSection("foo"))
	{
		value("asdf", "jkl");
		value("bar", "wee!");
		value("hi", "hello");
	}
	ini.addSection("BAR");
	assert(!ini["bar"]._detatched);
	with(ini.addSection("fOO"))
	{
		value("yes", "no");
	}
	with(ini.addSection("Hello"))
	{
		value("world", "true");
	}
	with(ini.addSection("test"))
	{
		value("1", "2");
		value("3", "4");
	}
	ini["test"]["value"] = "true";
	assert(ini["Foo"]["yes"] == "no");
	ini.save();

	ini = new Ini(inifile);
	assert(ini["FOO"]["Bar"] == "wee!");
	assert(ini["Foo"]["yes"] == "no");
	assert(ini["hello"]["world"] == "true");
	assert(ini["FOO"]["Bar"] == "wee!");
	assert(ini["55"]._detatched);
	assert(!ini["hello"]._detatched);
	assert(ini["hello"]["Yes"] is null);
	
	ini.open(inifile);
	assert(!ini["BAR"]._detatched);
	ini["bar"].remove("notta");
	ini["foo"].remove("bar");
	ini.remove("bar");
	assert(ini["bar"]._detatched);
	assert(!ini["foo"]._detatched);
	assert(ini["foo"]["bar"] is null);
	ini.remove("foo");
	assert(ini["foo"]._detatched);
	ini.save();
}

