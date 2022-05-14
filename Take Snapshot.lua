--[[
    Record v3.x - Take Snapshot
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

if check_api_version() then
    local sprite = app.activeSprite
    if sprite and app.fs.isFile(sprite.filename) then
        local snapshot = Snapshot.new()
        snapshot:set_sprite(sprite)
        snapshot:save()
    else
        return show_error(error_messages.save_required)
    end
end
