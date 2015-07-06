module GBAUtils.ROMManager;

import std.algorithm;
import std.stdio;
import gtk.FileChooserDialog;
import gtk.Window;

import GBAUtils.GBARom;

public class ROMManager
{
    private this(){}
    static:

	 GBARom[int] screenStore;
	 GBARom currentROM = null;
	
	GBARom getActiveROM()
	{
		return currentROM;
	}

	void AddROM(int stateId, GBARom rom)
	{
		screenStore[stateId] = rom;
	}

	void ChangeROM(int stateId)
	{
		currentROM = screenStore[stateId];
	}
	
	int getID()
	{
		return cast(int)screenStore.length;
	}
	
    /**
	 * Loads a ROM using a file dialog. Sets the loaded ROM as default.
	 * @return The ROMManager ROM Id.
	 */
	int loadRom()
	{
	    string location = "";
        auto dlg = new FileChooserDialog(
	       "Open File",
	       null,
	       FileChooserAction.OPEN,
	       ["Open", "Cancel"],
	        [ResponseType.ACCEPT, ResponseType.CANCEL]
        );
        if(GtkResponseType.ACCEPT == dlg.run() ){
	        location = dlg.getFilename();
	        writeln(location);
        }
        else
        {
            writeln(dlg.run());
        }
        dlg.destroy();
        
		if(location.length == 0)
			return -1;

		int romID = ROMManager.getID();
		AddROM(romID, new GBARom(location));
		ChangeROM(romID);
		
		if(getActiveROM().hex_tbl.length == 0)
		{
				//string path = LZ77Test.class.getProtectionDomain().getCodeSource().getLocation().getPath();
				//string decodedPath = URLDecoder.decode(path, "UTF-8");
			if(!getActiveROM().loadHexTBL("/resources/poketable.tbl"))
				return -3;
		}
		writeln(romID);
		return romID;
	}
}
