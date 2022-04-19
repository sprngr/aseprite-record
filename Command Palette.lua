--[[
    Record v3.x - Command Palette
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local snapshot = get_snapshot()

local function take_snapshot()
    update_snapshot_sprite(snapshot)
    if not is_snapshot_valid(snapshot) then
        return
    end

    save_snapshot(snapshot)
end

local function open_time_lapse()
    update_snapshot_sprite(snapshot)
    if not is_snapshot_valid(snapshot) then
        return
    end

    local path = get_recording_image_path_at_index(snapshot, 0)
    if app.fs.isFile(path) then
        app.command.OpenFile { filename = path }
    else
        show_error(error_messages.snapshot_required)
    end
end

if check_api_version() then
    local main_dialog = Dialog {
        title = "Record - Command Palette"
    }

    -- Creates the main dialog box
    main_dialog:button {
        text = "Take Snapshot",
        onclick = function()
            take_snapshot()
        end
    }
    main_dialog:button {
        text = "Open Time Lapse",
        onclick = function()
            open_time_lapse()
        end
    }
    main_dialog:show { wait = false }
end
