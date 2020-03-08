--[[
    Record v1.0
    Author: Michael Springer (@sprngr_)

    Records by writing snapshots to a directory.

    Can be imported as a sequence into Aseprite to make a gif.
    
    Requires an active sprite.
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