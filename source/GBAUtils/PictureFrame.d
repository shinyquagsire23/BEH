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
