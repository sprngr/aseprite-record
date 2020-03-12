# Record for Aseprite

An Aseprite utility script for recording snapshots in app to build time lapses.

## How to Install

It is recommended to go to the itch page for the tool to get the latest stable release: https://sprngr.itch.io/aseprite-record

If you would like to live on the edge and pull down the source code, you can clone this repo and copy that directory into your Aseprite scripts directory.

## Scripts

(I don't like that the script files have a space in their names, but it makes it look so much better in the Aseprite menus.)

### Command Palette

This option will open up a dialog box to leave up in your editor, giving you access to the functionality to take a snapshot & open the time lapse for the current sprite if any snapshots are saved for it.

The functions of each button are described in detail below and are available as single actions that can be mapped to a keyboard shortcut.

### Take Snapshot

This option saves a flattened png copy of the visible layers of the current sprite. It is saved to a sibling folder named <name of sprite>_record. Each file will be saved with an incrementing count appended to the end of it. No modifications to your work are performed by this script, it only creates new files.

### Open Time Lapse

This will open the Aseprite dialog asking if you wish to load all sequenced files related as a gif. If you accept, it will load it as a cool time lapse of all your snapshots saved for the current sprite.
