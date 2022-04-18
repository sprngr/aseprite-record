--[[
    Record v3.x - Open Time Lapse
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

if check_api_version() then
    local sprite = app.activeSprite
    if sprite and app.fs.isFile(sprite.filename) then
        local context = get_recording_context(sprite)
        local path = get_contextual_recording_image_path(context, 0)
        if app.fs.isFile(path) then
            app.command.OpenFile { filename = path }
        else
            return show_error("You need to record at least one snapshot to load time lapse.")
        end
    else
        return show_error("File must be saved before you are able to run this script.")
    end
end
