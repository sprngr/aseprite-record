--[[
    Record v3.x - Automatic Snapshot Controls
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local snapshot = get_snapshot()

local function take_auto_snapshot()
    auto_save_snapshot(snapshot)
end

local function disable_auto_snapshot(dialog)
    snapshot.auto_snap_enabled = false
    if not is_snapshot_valid(snapshot) then
        return
    end

    snapshot.sprite.events:off(take_auto_snapshot)

    dialog:modify {
        id = "status",
        text = "OFF"
    }
    dialog:modify {
        id = "toggle",
        text = "Start"
    }
end

local function enable_auto_snapshot(dialog)
    update_snapshot_sprite(snapshot)

    snapshot.auto_snap_enabled = is_snapshot_valid(snapshot)
    if not snapshot.auto_snap_enabled then
        return
    end

    snapshot.auto_snap_increment = 0
    snapshot.sprite.events:on("change", take_auto_snapshot)

    dialog:modify {
        id = "status",
        text = "RUNNING"
    }
    dialog:modify {
        id = "toggle",
        text = "Stop"
    }
    dialog:modify {
        id = "target",
        text = snapshot.context.sprite_file_name
    }
end

if check_api_version() then
    local main_dialog = Dialog {
        title = "Record - Auto Snapshot",
        onclose = function()
            reset_snapshot(snapshot)
        end
    }

    main_dialog:label {
        id = "target",
        label = "Target:",
        text = "<NONE>"
    }
    main_dialog:label {
        id = "status",
        label = "Status:",
        text = "OFF"
    }
    main_dialog:number {
        id = "delay",
        label = "Action Delay:",
        focus = true,
        text = tostring(snapshot.auto_snap_delay),
        onchange = function()
            snapshot.auto_snap_delay = main_dialog.data.delay
            snapshot.auto_snap_increment = 0
        end
    }
    main_dialog:separator {}
    main_dialog:button {
        id = "toggle",
        text = "Start",
        onclick = function()
            if is_snapshot_active(snapshot) then
                disable_auto_snapshot(main_dialog)
            else
                enable_auto_snapshot(main_dialog)
            end
        end
    }
    main_dialog:show { wait = false }
end
