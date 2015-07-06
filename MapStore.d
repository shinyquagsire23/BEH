module MapStore;

private import gtk.TreeStore;
private import gtk.TreeIter;
private import gtkc.gobjecttypes;

class MapStore : TreeStore
{
    this()
    {
        super([GType.STRING]);
    }
    
    // Adds a location and returns the TreeIter of the item added.
    public TreeIter addCategory(in string name)
    {
        
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        return iter;
    }
    
    // Adds a child location to the specified parent TreeIter.
    public TreeIter addChild(TreeIter parent,
            in string name)
    {
        TreeIter child = TreeStore.createIter(parent);
        setValue(child, 0, name);
        return child;
    }
}
