--[[
    Aseprite Time Lapse v0.1
    Author: Michael Springer (@sprngr_)

    Records a time lapse by writing snapshots to a new file as frames.
    Requires an active sprite to be opened to launch.
]]

-- Attempt to fetch an active sprite to setup for recording
local sprite = app.activeSprite

-- If no sprite, notify and exit
if not sprite then
  app.alert("Please open a sprite to begin a time lapse.")
  return
end

-- Set up utility methods
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- Check if a filename is set, otherwise skip these steps
if not sprite.filename then
    app.alert("Please save the file to disk before starting Time Lapse.")
    return
end

-- Get file path separator, \ for Windows and / for everything else
local pathSeparator = sprite.filename:sub(1,1) == "/" and "/" or "\\"

-- Set up path
local pathTable = split(sprite.filename, pathSeparator)
local baseFilename = pathTable[#pathTable]

table.remove(pathTable, #pathTable)
local workingDirectory = table.concat(pathTable,pathSeparator)

-- Create new Time Lapse filename
function generateFilename()
    return baseFilename:gsub('(%.%w+)$', '-time-lapse.aseprite')
end

function open(filename)
    local saveFile = app.open(workingDirectory..pathSeparator..filename)

    if not saveFile then
        -- TODO Make new file
    end
end

function write()
    sprite.selection:selectAll()
    app.command.CopyMerged()
end

-- Create dialog box
local dlg = Dialog("Time Lapse v0.1")
local bounds = dlg.bounds
dlg.bounds = Rectangle(bounds.x, bounds.y, 256, 128)
dlg:label{ id="originalFile",
           label="Target File:",
           text="./"..baseFilename }
dlg:label{ id="timeLapseFile",
           label="Save File:",
           text="./"..generateFilename() }
dlg:number{ id="timeLapseInterval",
           text="60",
           focus=true }
dlg:separator{}
dlg:button{
    text = "Open Save File",
		onclick = function() open(generateFilename()) end
}


dlg:show{ wait=false }
