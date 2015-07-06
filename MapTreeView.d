module LocationTreeView;

private import gtk.TreeView;
private import gtk.TreeViewColumn;
private import gtk.TreeStore;
private import gtk.CellRendererText;
private import gtk.ListStore;

class LocationTreeView : TreeView
{
    private TreeViewColumn countryColumn;
    private TreeViewColumn capitalColumn;
    
    this(TreeStore store)
    {        
        // Add Country Column
        countryColumn = new TreeViewColumn(
            "Map", new CellRendererText(), "text", 0);
        appendColumn(countryColumn);
        
        setModel(store);
    }
}

