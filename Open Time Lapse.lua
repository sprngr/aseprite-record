--[[
    Record v1.2 - Open Time Lapse
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local sprite = app.activeSprite

if checkVersion()
then
    if sprite and app.fs.isFile(sprite.filename)
    then
        setupFileStrings(sprite.filename)
        
        if app.fs.isFile(app.fs.joinPath(getSavePath(),app.fs.pathSeparator, getSaveFileName(0)))
        then
            app.command.OpenFile{filename=app.fs.joinPath(getSavePath(), app.fs.pathSeparator, getSaveFileName(0))}
        else
            return showError("Need to record at least one snapshot to load time lapse.")
        end
    else
        return showError("File must be saved before able to run script.")
    end
end