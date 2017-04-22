# Dynamic Note Items
### General
This is a mod that makes it possible for modded items to have death/pause sceen icons in the corresponding lists.
Currently all of this is just a **Proof of Concept**!

### Usage
To make use of this new functionality in your mod you'll have do the following:

1. Add a note sprite (16x16) to `/resources/gfx/ui/deathnotes/` for each item. Make sure the filename of this sprite is EXACLTY the same as the filename of the collectible sprite!

### Technical Details
#### Pause Screen
This works by replacing the `gfx/ui/pausescreen.anm2` with one where the background and "My List" layer are invisible and by replacing `gfx/ui/death items.png` with an empty png.   
An new animation file that contains the layers that were made invisible is then loaded. This step is needed to be able to render on top of the "My List" paper.    
Now the game checks which items the player currently by cycling through all item ids and checking if the player has the item.  
For each item a new sprite will be rendered. This sprite points to `gfx/ui/deathnotes/collectiblespritename.png`. (This is why the first point in _Usage_ is important.)
#### Death Screen
Not implemented.
