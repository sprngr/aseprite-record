--[[
    Record v1.0
    Author: Michael Springer (@sprngr_)

    Records by writing snapshots to a directory.

    Can be imported as a sequence into Aseprite to make a gif.
    
    Requires an active sprite.
]]


dofile('.lib/utils.lua')
dofile('.lib/record-core.lua')

local sprite = nil
local fileIncrement = 0
local mainDlg = Dialog("Record")

function init()
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
        return init()
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

mainDlg:show()