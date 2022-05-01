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
        local context = RecordingContext.new(sprite)
        local path = context:get_recording_image_path(0)
        if app.fs.isFile(path) then
            app.command.OpenFile { filename = path }
        else
            return show_error(error_messages.snapshot_required)
        end
    else
        return show_error(error_messages.save_required)
    end
end
