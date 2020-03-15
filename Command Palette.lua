--[[
    Record v1.2 - Command Palette
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local fileIncrement = 0
local mainDlg = Dialog("Record")
local sprite = nil

function setCurrentIncrement()
    fileIncrement = 0
    local incrementSet = false
    while not incrementSet do
        if (not app.fs.isFile(app.fs.joinPath(getSavePath(), getSaveFileName(fileIncrement))))
        then
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

function checkSprite()
    -- If no sprite is active, throw error
    if not app.activeSprite
    then
        return showError("No active sprite available.")
    else
        -- stash currently active sprite for comparison
        local currentSprite = app.activeSprite
        
        -- Check if file exists, reset sprite and throw error if not.
        if not app.fs.isFile(currentSprite.filename)
        then
            sprite = nil
            return showError("File must be saved before able to run script.")
        end

        -- If sprite is nil, or current sprite doesnt match; reinitialize it.
        if (sprite == nil or sprite.filename ~= currentSprite.filename)
        then
            return setSprite()
        end
    end
end

function takeSnapshot()
    checkSprite()

    if sprite
    then
        recordSnapshot(sprite, fileIncrement)
        fileIncrement = fileIncrement + 1
    end
end

function openTimeLapse()
    checkSprite()
    
    if sprite
    then
        if app.fs.isFile(app.fs.joinPath(getSavePath(), getSaveFileName(0)))
        then
            app.command.OpenFile{filename=app.fs.joinPath(getSavePath(), getSaveFileName(0))}
        else
            showError("You need to make at least one snapshot to load a time lapse.")
        end
    end
end

if checkVersion()
then
    -- Creates the main dialog box
    mainDlg:button{
        text = "Take Snapshot",
        onclick = 
            function()
                takeSnapshot()
            end
    }
    mainDlg:button{
        text = "Open Time Lapse",
        onclick = 
            function() 
                openTimeLapse()
            end
    }

    mainDlg:show{ wait=false }
end