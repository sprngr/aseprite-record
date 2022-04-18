--[[
    Record v3.x - Automatic Snapshot Controls
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local autoSnapshot = get_snapshot()

local function take_auto_snapshot()
    auto_save_snapshot(autoSnapshot)
end

local function enable_auto_snapshot(dialog)
    update_snapshot_sprite(autoSnapshot)

    autoSnapshot.enabled = is_snapshot_valid(autoSnapshot)
    if not autoSnapshot.enabled then
        return
    end

    autoSnapshot.snapIncrement = 0
    autoSnapshot.sprite.events:on("change", take_auto_snapshot)

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
        text = autoSnapshot.context.sprite_file_name
    }
end

local function disable_auto_snapshot(dialog)
    autoSnapshot.enabled = false
    if not is_snapshot_valid(autoSnapshot) then
        return
    end

    autoSnapshot.sprite.events:off(take_auto_snapshot)

    dialog:modify {
        id = "status",
        text = "OFF"
    }
    dialog:modify {
        id = "toggle",
        text = "Start"
    }
end

if check_api_version() then
    local main_dialog = Dialog {
        title = "Record - Auto Snapshot",
        onclose = function()
            reset_snapshot(autoSnapshot)
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
        text = tostring(autoSnapshot.snapDelay),
        onchange = function()
            autoSnapshot.snapDelay = main_dialog.data.delay
            autoSnapshot.snapIncrement = 0
        end
    }
    main_dialog:separator {}
    main_dialog:button {
        id = "toggle",
        text = "Start",
        onclick = function()
            if is_snapshot_active(autoSnapshot) then
                disable_auto_snapshot(main_dialog)
            else
                enable_auto_snapshot(main_dialog)
            end
        end
    }
    main_dialog:show { wait = false }
end
