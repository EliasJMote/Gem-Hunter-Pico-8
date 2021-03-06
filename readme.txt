Gem Hunter
Version 0.7.1

Copyright © 2019-2020 Elias Mote
Copyright © 2019-2020 Roc Studios

I. Disclaimer
II. Version History
III. Requirements
IV. Story
V. Controls
VI. Contact
VII. Credits

I. Disclaimer

This software may be not be reproduced under any circumstances except for personal, private use. It may
not be placed on any web site or otherwise distributed publicly except at the sole discretion of the 
author. Placement of this readme or game on any other web site or as a part of any public display is
strictly prohibited, and a violation of copyright.

II. Version History

------------------------
V0.7.1 - Current version
------------------------
------------------------------------------------- Updates -----------------------------------------------
- Added character selection screen
- Instant drop using the up key
- Added gem rain opening cinematic
- Added Roc Studios opening logo

------------------------
V0.7.0
------------------------
------------------------------------------------- Updates -----------------------------------------------
- Added arrow columns!
-- Up arrow will create three rows of gray blocks for opponent.
-- Middle block destroys all blocks of the block color it lands on
-- Down arrow will remove three rows of gray blocks for the player activating it.
- Both players will now correctly have the same series of columns.

------------------------
V0.6.1.1
------------------------
------------------------------------------------- Hotfixes ----------------------------------------------
- 1 player mode was accidentally enabled. I've disabled it since it's not ready.
- Fixed a bug where 2 player mode wouldn't work (since player 2 wasn't being created)
- Fixed player scores back to 0.

------------------------
V0.6.1
------------------------
------------------------------------------------ Bug fixes ----------------------------------------------
- Fixed a bug where the crush point score was accidentally adding extra points for some block combinations
- Fixed a bug where crush bars weren't always being added correctly (crush level being > 3 and # of new crush
bars was >= 2)

------------------------
V0.6.0
------------------------
-- Changed block removal algorithm (should work correctly, could use further testing)

------------------------
V0.5.2
------------------------
-- Changed sprites from "gummy" blocks to gemstone blocks

------------------------
V0.5.1
------------------------
-- Added a "practice" mode

------------------------
V0.5.0
------------------------
-- Added a "game mode" screen
-- Added the ability to start a new game after a player has won
-- Added sfx for placing columns/dropping blocks and clearing rows

------------------------
V0.4.6
------------------------
-- Added win/loss conditions

------------------------
V0.4.5
------------------------
-- Added score display (max of 30)
-- Added crush bars (only additive, not subtractive)

------------------------
V0.4.4
------------------------
-- Added game display showing future columns

------------------------
V0.4.3
------------------------
-- Two player mode works (on two controllers)
-- Title screen added

------------------------
V0.4.2
------------------------
-- Two player mode works (on one controller)

------------------------
V0.4.1
------------------------
- Added animation to blocks being eliminated
- Combos of any number are now supported

------------------------
V0.4.0
------------------------
- Added additional collision detection to the columns
- Combos up to three can be performed
- Multiple rows that share blocks will be removed simultaneously

------------------------
V0.3.0
------------------------
- Added a readme
- Rows of 3 are removed
- Blocks move themselves downward if they are floating after rows are removed

------------------------
V0.2.0
------------------------
- Added grids to the wells
- Added rotatable columns
- Added collision detection
- Added controls
- Added randomized column patterns

------------------------
V0.0.1
------------------------
- Created outlines for the wells

III. Requirements


IV. Story
This is a demake of Columns 3: Revenge of Columns, so there's no story to it :)
The basic gist of the game is to match rows of 3 or more blocks using columns of
three blocks that can be rotated. You must force your opponent to fill their well
with blocks before your well is filled. Combos grant you points that you can use
to disrupt your opponent and reduce their well size while increasing yours at the
same time.

IV. Controls (Default)
Player 1:
- Use the left and right keys to move the falling columns left and right, respectively
- Use the down key to drop the column faster
- Use the 'Z' key to rotate the column
- Use the 'X' key to "crush" your opponent (uses 10 or more score)
- Use the up and down keys to navigate menus
- Press 'Z' after a player has won to restart the game

Player 2:
- Use the 'S' and 'F' keys to move the falling columns left and right, respectively
- Use the 'D' key to drop the column faster
- Use the 'Left Shift' key to rotate the column
- Use the 'A' key to "crush" your opponent (uses 10 or more score)

V. Contact
Contact me with questions or comments at rulerofchaosstudios@gmail.com
Twitter: twitter.com/Roc_Studios
Twitch:
Facebook page:
Itch.io page: rocstudios.itch.io
Game jolt page: gamejolt.com/@Roc_Studios


VI. Credits
Created by: Elias Mote
Treasure Takers characters owned by: David Harper
Engine: Pico-8
Programming language: Lua