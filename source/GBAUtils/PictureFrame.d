/******************************************************************************
 * BEH                                                                        *
 * Source Code                                                                *
 *                                                                            *
 * D 2.067.0-0                                                                *
 * PictureFrame.d                                                             *
 * "A small class which can be fed a Pixbuf to display. Useful for testing."  *
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
module GBAUtils.PictureFrame;

import gdkpixbuf.Pixbuf;
import gtk.MainWindow;
import gtk.Image;

public class PictureFrame
{
    public this(Pixbuf img)
    {
        MainWindow win = new MainWindow("Picture Frame");
        Image image = new Image();
        image.setFromPixbuf(img);
        win.add(image);
        win.showAll();
    }
}
