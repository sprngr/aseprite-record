--[[
    Record v1.0 - Record Now
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]


dofile('.lib/utils.lua')
dofile('.lib/record-core.lua')

local fileIncrement = 0

function setCurrentIncrement()
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

if app.activeSprite
then
    sprite = app.activeSprite
    setupFileStrings(sprite.filename)
    setCurrentIncrement()
    recordSnapshot(sprite, fileIncrement)
end