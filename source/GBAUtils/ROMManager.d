/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * ROMManager.d                                                               *
 * "Manages and holds multiple GBARoms for programs which may have multiple   *
 *  ROMs open."                                                               *
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
            if(!getActiveROM().loadHexTBL("./resources/poketable.tbl"))
                return -3;
        }
        writeln(romID);
        return romID;
    }
}
