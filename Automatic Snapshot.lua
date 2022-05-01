--[[
    Record v3.x - Automatic Snapshot Controls
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local snapshot = Snapshot.new()

local function take_auto_snapshot()
    snapshot:auto_save()
end

local function disable_auto_snapshot(dialog)
    snapshot.auto_snap_enabled = false
    if not snapshot:is_valid() then
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
    snapshot:update_sprite()

    snapshot.auto_snap_enabled = snapshot:is_valid()
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
            snapshot:reset()
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
            if snapshot:is_active() then
                disable_auto_snapshot(main_dialog)
            else
                enable_auto_snapshot(main_dialog)
            end
        end
    }
    main_dialog:show { wait = false }
end
