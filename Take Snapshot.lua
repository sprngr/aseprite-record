--[[
    Record v1.2 - Take Snapshot
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local fileIncrement = 0
local sprite = app.activeSprite

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

if checkVersion()
then
    if sprite and app.fs.isFile(sprite.filename)
    then
        setupFileStrings(sprite.filename)
        setCurrentIncrement()
        recordSnapshot(sprite, fileIncrement)
    else
        return showError("File must be saved before able to run script.")
    end
end