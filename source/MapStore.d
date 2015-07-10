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

    public TreeIter addCategory(in string name)
    {
        
        TreeIter iter = createIter();
        setValue(iter, 0, name);
        return iter;
    }

    public TreeIter addChild(TreeIter parent,
        in string name)
    {
        TreeIter child = TreeStore.createIter(parent);
        setValue(child, 0, name);
        return child;
    }
}
