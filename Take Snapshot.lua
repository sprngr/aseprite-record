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
        local autoSnapshot = get_snapshot()
        set_snapshot_sprite(autoSnapshot, sprite)
        save_snapshot(autoSnapshot)
    else
        return show_error("File must be saved before you are able to run this script.")
    end
end
