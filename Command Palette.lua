--[[
    Record v3.0 - Command Palette
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local autoSnapshot = AutoSnapshot_sharedInstance()

local function takeSnapshot()
    AutoSnapshot_updateSprite(autoSnapshot)
    if not AutoSnapshot_isValid(autoSnapshot) then
        return
    end

    AutoSnapshot_saveSnapshot(autoSnapshot)
end

local function openTimeLapse()
    AutoSnapshot_updateSprite(autoSnapshot)
    if not AutoSnapshot_isValid(autoSnapshot) then
        return
    end

    local path = AutoSnapshot_imagePathAt(autoSnapshot, 0)
    if app.fs.isFile(path) then
        app.command.OpenFile { filename = path }
    else
        showError("You need to make at least one snapshot to load a time lapse.")
    end
end

if checkVersion() then
    local mainDlg = Dialog {
        title = "Record - Command Palette"
    }

    -- Creates the main dialog box
    mainDlg:button {
        text = "Take Snapshot",
        onclick = function()
            takeSnapshot()
        end
    }
    mainDlg:button {
        text = "Open Time Lapse",
        onclick = function()
            openTimeLapse()
        end
    }
    mainDlg:show { wait = false }
end
