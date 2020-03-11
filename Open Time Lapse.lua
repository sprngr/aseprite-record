--[[
    Record v1.0 - Open Time Lapse
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile('.lib/utils.lua')
dofile('.lib/version-check.lua')
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

local sprite = app.activeSprite

if checkVersion()
then
    if sprite and fileExists(sprite.filename)
    then
        setupFileStrings(sprite.filename)
        
        if fileExists(getSavePath()..getSaveFileName(0))
        then
            app.command.OpenFile{filename=getSavePath()..getSaveFileName(0)}
        else
            return showError("Need to record at least one snapshot to load time lapse.")
        end
    else
        return showError("File must be saved before able to run script.")
    end
end