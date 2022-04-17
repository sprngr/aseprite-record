--[[
    Record v3.0 - Take Snapshot
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

if checkVersion() then
    local sprite = app.activeSprite
    if sprite and app.fs.isFile(sprite.filename) then
        local autoSnapshot = AutoSnapshot_sharedInstance()
        AutoSnapshot_setSprite(autoSnapshot, sprite)
        AutoSnapshot_saveSnapshot(autoSnapshot)
    else
        return showError("File must be saved before able to run script.")
    end
end
