# Dynamic Note Items
### General
This is a mod that makes it possible for modded items to have death/pause sceen icons in the corresponding lists.
Currently all of this is just a **Proof of Concept**!

### Usage
To make use of this new functionality in your mod you'll have do the following:

1. Make sure all your item ids are saved in the `CollectibleType` enum. This is needed because the mod can't find out your item ids any other way. (yet.) You can do this in two ways:
``` Lua
[...]
CollectibleType.MYMOD_C_MY_COOL_ITEM = Isaac.GetItemIdByName("My Cool Item")
CollectibleType["MYMOD_C_MY_OTHER_COOL_ITEM"] = Isaac.GetItemIdByName("My Other Cool Item")
[...]
``` 
It doesn't matter how you do it, or how you name your constant.

2. Add a note sprite (16x16) to `/resources/gfx/ui/deathnotes/` for each item. Make sure the filename of this sprite is EXACLTY the same as the filename of the collectible sprite!

### Technical Details
#### Pause Screen
This works by replacing the `gfx/ui/pausescreen.anm2` with one where the background and "My List" layer are invisible and by replacing `gfx/ui/death items.png` with an empty png.   
An new animation file that contains the layers that were made invisible is then loaded. This step is needed to be able to render on top of the "My List" paper.    
Now the game checks which items the player currently by cycling through the `CollectibleType` enum and checking if the player has the item. Currently this is the only way to get the current items. (This is why the first thing mentioned in the _Usage_ section is important.)   
For each item a new sprite will be rendered. This sprite points to `gfx/ui/deathnotes/collectiblespritename.png`. (This is why the second part of _Usage_ is important.)
#### Death Screen
Not implemented.
