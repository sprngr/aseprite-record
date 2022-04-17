--[[
    Record v3.0 - Open Time Lapse
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

if checkVersion() then
    local sprite = app.activeSprite
    if sprite and app.fs.isFile(sprite.filename) then
        local context = ProjectContext_new(sprite)
        local path = ProjectContext_recordImagePath(context, 0)
        if app.fs.isFile(path) then
            app.command.OpenFile { filename = path }
        else
            return showError("Need to record at least one snapshot to load time lapse.")
        end
    else
        return showError("File must be saved before able to run script.")
    end
end
