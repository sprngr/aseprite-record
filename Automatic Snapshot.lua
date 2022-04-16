--[[
    Record v2.4 - Automatic Snapshot Controls
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local autoSnapshot = AutoSnapshot_sharedInstance()

local function takeAutoSnapshot()
    AutoSnapshot_tick(autoSnapshot)
end

local function enableAutoSnapshot(dialog)
    AutoSnapshot_updateSprite(autoSnapshot)

    autoSnapshot.enabled = AutoSnapshot_isValid(autoSnapshot)
    if not autoSnapshot.enabled then
        return
    end

    autoSnapshot.snapIncrement = 0
    autoSnapshot.sprite.events:on("change", takeAutoSnapshot)

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
        text = autoSnapshot.projectContext.fileName
    }
end

local function disableAutoSnapshot(dialog)
    autoSnapshot.enabled = false
    if not AutoSnapshot_isValid(autoSnapshot) then
        return
    end

    autoSnapshot.sprite.events:off(takeAutoSnapshot)

    dialog:modify {
        id = "status",
        text = "OFF"
    }
    dialog:modify {
        id = "toggle",
        text = "Start"
    }
end

if checkVersion() then
    local mainDlg = Dialog {
        title = "Record - Auto Snapshot",
        onclose = function()
            AutoSnapshot_reset(autoSnapshot)
        end
    }

    mainDlg:label {
        id = "target",
        label = "Target:",
        text = "<NONE>"
    }
    mainDlg:label {
        id = "status",
        label = "Status:",
        text = "OFF"
    }
    mainDlg:number {
        id = "delay",
        label = "Action Delay:",
        focus = true,
        text = tostring(autoSnapshot.snapDelay),
        onchange = function()
            autoSnapshot.snapDelay = mainDlg.data.delay
            autoSnapshot.snapIncrement = 0
        end
    }
    mainDlg:separator {}
    mainDlg:button {
        id = "toggle",
        text = "Start",
        onclick = function()
            if AutoSnapshot_isActive(autoSnapshot) then
                disableAutoSnapshot(mainDlg)
            else
                enableAutoSnapshot(mainDlg)
            end
        end
    }
    mainDlg:show { wait = false }
end
