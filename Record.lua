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

if sprite.filename then
    -- Get file path separator, \ for Windows and / for everything else
    local pathSeparator = sprite.filename:sub(1,1) == "/" and "/" or "\\"

    -- Set up path 
    local pathTable = split(sprite.filename, pathSeparator)
    local baseFilename = pathTable[#pathTable]

    table.remove(pathTable, #pathTable)

    local workingDirectory = table.concat(pathTable,pathSeparator)
end
 
