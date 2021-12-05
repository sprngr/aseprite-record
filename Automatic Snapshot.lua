--[[
    Record v2.0 - Automatic Snapshot Controls
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

-- Auto Snapshot functions
local autoSnapshot = false
local autoSnapshotDelay = 3
local autoSnapshotIncrement = 0

local fileIncrement = 0
local fileName = ""
local filePath = ""
local sprite = nil
local spriteSelection = nil

-- Local overrides of core code to cache the target sprite
local function setFileName(filename)
    fileName = app.fs.fileTitle(filename)
end

local function setFilePath(filename)
    filePath = app.fs.filePath(filename)
end

local function setupFileStrings(filename)
    setFileName(filename)
    setFilePath(filename)
end

local function getSavePath()
    return app.fs.joinPath(filePath, fileName.."_record")
end

local function recordSnapshot(sprite, increment)
    sprite:saveCopyAs(app.fs.joinPath(getSavePath(), fileName.."_"..increment..".png"))
end
-- Local override region end

local function setCurrentIncrement()
    fileIncrement = 0
    local incrementSet = false
    while not incrementSet do
        if (not app.fs.isFile(app.fs.joinPath(getSavePath(),  fileName.."_"..fileIncrement..".png"))) then
            incrementSet = true
        else
            fileIncrement = fileIncrement + 1
        end
    end
end

local function setSprite()
    sprite = app.activeSprite
    setupFileStrings(sprite.filename)
    setCurrentIncrement()
end

local function checkSprite()
    -- If no sprite is active, throw error
    if not app.activeSprite then
        return showError("No active sprite available.")
    else
        -- stash currently active sprite for comparison
        local currentSprite = app.activeSprite
        
        -- Check if file exists, reset sprite and throw error if not.
        if not app.fs.isFile(currentSprite.filename) then
            return showError("File must be saved before able to run script.")
        end

        -- If sprite is nil, or current sprite doesnt match; reinitialize it.
        if (not sprite or sprite.filename ~= currentSprite.filename) then
            return setSprite()
        end
    end
end

local function cacheSelection()
    local selection = sprite.selection

    -- Returns false if sprite selection is empty
    if selection.isEmpty then
        spriteSelection = nil
    end

    -- Compare against cached selection
    if spriteSelection ~= selection then
        spriteSelection = selection
    end
end

local function selectionChanged()
    local selection = sprite.selection

    -- Returns false if sprite selection is empty
    if not spriteSelection then
        return false
    end

    -- Compare against cached selection
    return spriteSelection ~= selection
end

local function takeAutoSnapshot()
    if autoSnapshot then
        autoSnapshotIncrement = autoSnapshotIncrement + 1

            if autoSnapshotIncrement >= autoSnapshotDelay then
                autoSnapshotIncrement = 0
                
                -- Check if a selection is different or empty, and skip it so it doesn't crash
                if not selectionChanged() or sprite.selection.isEmpty then
                    -- Paranoia, check increment in case manual operation was used
                    setCurrentIncrement()
        
                    recordSnapshot(sprite, fileIncrement)
                end
            end

        cacheSelection()
    end
end

-- Main Dialog
-- Initialize dialog if app meets version requirements
if checkVersion() then
    local mainDlg = Dialog{
        title = "Record - Auto Snapshot",
        onclose = 
            function() 
                autoSnapshot = false
                sprite = nil
            end
    }

    -- Creates the main dialog box
    mainDlg:label{
        id = "target",
        label = "Target:",
        text = "<NONE>"
    }
    mainDlg:label{
        id = "status",
        label = "Status:",
        text = "OFF"
    }
    mainDlg:number{
        id = "delay",
        label = "Action Delay:",
        focus = true,
        text = tostring(autoSnapshotDelay),
        onchange = 
            function()
                autoSnapshotDelay = mainDlg.data.delay
                autoSnapshotIncrement = 0
            end
    }
    mainDlg:separator{}
    mainDlg:button{
        id = "toggle",
        text = "Start",
        onclick = 
            function()
                if not autoSnapshot then
                    checkSprite()

                    if sprite then
                        autoSnapshot = true
                        autoSnapshotIncrement = 0
                        sprite.events:on('change', takeAutoSnapshot)
                        mainDlg:modify{
                            id = "status",
                            text = "RUNNING"
                        }
                        mainDlg:modify{
                            id = "toggle",
                            text = "Stop"
                        }
                        mainDlg:modify{
                            id = "target",
                            text = fileName
                        }
                    end
                else
                    autoSnapshot = false
                    sprite.events:off(takeAutoSnapshot)
                    mainDlg:modify{
                        id = "status",
                        text = "OFF"
                    }
                    mainDlg:modify{
                        id = "toggle",
                        text = "Start"
                    }
                end
            end
    }
    mainDlg:show{ wait=false }    
end