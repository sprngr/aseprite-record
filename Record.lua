--[[
    Aseprite Recorder v0.1
    Author: Michael Springer (@sprngr_)

    Records a time lapse by writing snapshots to a directory.
    Can be imported as a sequence to aseprite as a gif.
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

local fileIncrement = 0

-- Get file path separator, \ for Windows and / for everything else
local pathSeparator = sprite.filename:sub(1,1) == "/" and "/" or "\\"

-- Set up path
local pathTable = split(sprite.filename, pathSeparator)
local baseFilename = pathTable[#pathTable]

table.remove(pathTable, #pathTable)
local workingDirectory = table.concat(pathTable,pathSeparator)

-- Create new Time Lapse directory
function generateDirectoryName()
    return baseFilename:gsub('(%.%w+)$', '_time-lapse')
end

local basePath = workingDirectory..pathSeparator..generateDirectoryName()..pathSeparator

-- Create new Time Lapse filename
function generateFilename()
    return baseFilename:gsub('(%.%w+)$', '_'..fileIncrement..'.png')
end

function writeSnapshot()
    sprite:saveCopyAs(basePath..generateFilename())
    fileIncrement = fileIncrement + 1
end

function fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

-- Creates the base dialog box
local mainDlg = Dialog("Aseprite Recorder v0.1")
local recordDlg = Dialog("Aseprite Recorder v0.1")

local bounds = mainDlg.bounds
mainDlg.bounds = Rectangle(bounds.x, bounds.y, 128, 128)
mainDlg:button{
    text = "Take Snapshot",
    onclick = function() writeSnapshot() end
}
mainDlg:separator{}
mainDlg:label{
    text="Timer Delay (seconds):"
}
mainDlg:number{ 
    id="timeLapseInterval",
    text="60",
    focus=true
}
mainDlg:button{
    text = "Start Recording",
    onclick = function() recordSprite(mainDlg.data.timeLapseInterval) end
}

recordDlg.bounds = mainDlg.bounds
recordDlg:label{
    text="Recording..."
}
recordDlg:button{
    text = "Stop",
    onclick = function() stopRecording() end
}

local isRecording = false

function stopRecording()
    isRecording = false
    recordDlg:close()
    mainDlg:show{ wait=false }
end

function recordSprite(interval)
    mainDlg:close()
    recordDlg:show{ wait=false }

    local endTime = os.time() + interval

    while isRecording do
        if os.time() >= endTime then
            writeSnapshot()
            endTime = os.time() + interval
        end
    end
end

-- Determines the current interval value, then opens the dialog box
function initialize()
    local incrementSet = false
    while not incrementSet do
        if (not fileExists(basePath..generateFilename()))
        then
            incrementSet = true
        else
            fileIncrement = fileIncrement + 1
        end
    end
    mainDlg:show{ wait=false }
end

initialize()
