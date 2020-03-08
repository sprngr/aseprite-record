--[[
    Record v1.0 - Command Palette
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]


dofile('.lib/utils.lua')
dofile('.lib/record-core.lua')

local sprite = nil
local fileIncrement = 0
local mainDlg = Dialog("Record - v1.0")

function setSprite()
    sprite = app.activeSprite
    setupFileStrings(sprite.filename)
    setCurrentIncrement()
end

function setCurrentIncrement()
    fileIncrement = 0
    local incrementSet = false
    while not incrementSet do
        if (not fileExists(getSavePath()..getSaveFileName(fileIncrement)))
        then
            incrementSet = true
        else
            fileIncrement = fileIncrement + 1
        end
    end
end

function checkSprite()
    if not app.activeSprite
    then
        return showError("No active sprite available.")
    elseif (sprite == nil or not sprite == app.activeSprite)
    then
        return setSprite()
    end
end

function paletteRecord()
    checkSprite()

    if sprite
    then
        recordSnapshot(sprite, fileIncrement)
        fileIncrement = fileIncrement + 1
    end
end

function openFolder()
    checkSprite()

    if sprite
    then
        app.command.openInFolder()
    end
end

-- Creates the main dialog box
mainDlg:button{
    text = "Record Snapshot",
    onclick = 
        function()
            paletteRecord()
        end
}
mainDlg:button{
    text = "Open Folder",
    onclick = 
        function() 
            openFolder()
        end
}

mainDlg:show{ wait=false } 