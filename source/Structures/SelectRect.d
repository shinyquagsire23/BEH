module Structures.SelectRect;

import GBAUtils.Rectangle;

public static class SelectRect : Rectangle
{
	int startX;
	int startY;
	int realWidth;
	int realHeight;
	bool moved = false;
	
	public this(int i, int j, int k, int l) {
		super(i,j,k,l);
		startX = i;
		startY = j;
		realWidth = k;
		realHeight = l;
	}
}

