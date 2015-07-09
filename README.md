# BEH
BEH is a Generation III Map Editor for Pokemon Fire Red, Leaf Green, Ruby, Sapphire, and Emerald games for the GameBoy Advance, based on MEH and ported to the D language. Currently only Fire Red, Ruby, and Emerald are supported by the INI file, however more can be added if support is desired. In it's current state, BEH is lacking many of the features which MEH originally had, however about 90% of the actual map reading, rendering, and data structure code is present.

**Dependencies**

- dmd
- gtkd 3.0 or higher
- dub (for building)
 
**Building**

Tihs project uses dub for building. To build, run ```dub build``` in the root directory and then the executable will be placed as ```./beh```. The ```resources``` directory and ```BEH.ini``` are required for BEH to function properly.

**TODOs**

- Port UI code over to D and gtk
- Validate saving code, make sure it writes correctly after porting
- Code cleanup
- Anything other TODOs in the code
 
**Contributing**

When contributing, new code should adhere to to the [Dlang and Phobos Guidelines](http://dlang.org/dstyle.html). Tabs should be 4 spaces wide, with no \t characters being used. TODOs are welcome in moderation, however issue reports and PRs are preferred.
