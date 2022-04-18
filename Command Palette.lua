--[[
    Record v3.x - Command Palette
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local autoSnapshot = get_snapshot()

local function take_snapshot()
    update_snapshot_sprite(autoSnapshot)
    if not is_snapshot_valid(autoSnapshot) then
        return
    end

    save_snapshot(autoSnapshot)
end

local function open_time_lapse()
    update_snapshot_sprite(autoSnapshot)
    if not is_snapshot_valid(autoSnapshot) then
        return
    end

    local path = get_snapshot_image_path_at_index(autoSnapshot, 0)
    if app.fs.isFile(path) then
        app.command.OpenFile { filename = path }
    else
        show_error("You need to make at least one snapshot to load a time lapse.")
    end
end

if check_api_version() then
    local mainDlg = Dialog {
        title = "Record - Command Palette"
    }

    -- Creates the main dialog box
    mainDlg:button {
        text = "Take Snapshot",
        onclick = function()
            take_snapshot()
        end
    }
    mainDlg:button {
        text = "Open Time Lapse",
        onclick = function()
            open_time_lapse()
        end
    }
    mainDlg:show { wait = false }
end
