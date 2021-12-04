--[[
    Record v2.0 - Command Palette
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

dofile(".lib/record-core.lua")

local fileIncrement = 0

local sprite = nil
local autoSnapshot = false
local autoSnapshotDelay = 3
local autoSnapshotIncrement = 0

local mainDlg = Dialog{
    title = "Record",
    onclose = 
        function() 
            autoSnapshot = false
        end
}

function setCurrentIncrement()
    fileIncrement = 0
    local incrementSet = false
    while not incrementSet do
        if (not app.fs.isFile(app.fs.joinPath(getSavePath(), getSaveFileName(fileIncrement)))) then
            incrementSet = true
        else
            fileIncrement = fileIncrement + 1
        end
    end
end

local function setSprite()
    sprite = app.activeSprite
    setupFileStrings(sprite.filename)
    setCurrentIncrement()
end

function checkSprite()
    -- If no sprite is active, throw error
    if not app.activeSprite then
        sprite = nil
        return showError("No active sprite available.")
    else
        -- stash currently active sprite for comparison
        local currentSprite = app.activeSprite
        
        -- Check if file exists, reset sprite and throw error if not.
        if not app.fs.isFile(currentSprite.filename) then
            sprite = nil
            return showError("File must be saved before able to run script.")
        end

        -- If sprite is nil, or current sprite doesnt match; reinitialize it.
        if (not sprite or sprite.filename ~= currentSprite.filename) then
            return setSprite()
        end
    end
end

function takeSnapshot()
    checkSprite()

    if sprite then
        recordSnapshot(sprite, fileIncrement)
        fileIncrement = fileIncrement + 1
    end
end

function openTimeLapse()
    checkSprite()
    
    if sprite then
        if app.fs.isFile(app.fs.joinPath(getSavePath(), getSaveFileName(0))) then
            app.command.OpenFile{filename=app.fs.joinPath(getSavePath(), getSaveFileName(0))}
        else
            showError("You need to make at least one snapshot to load a time lapse.")
        end
    end
end

function takeAutoSnapshot()
    if autoSnapshot then
        if autoSnapshotIncrement < autoSnapshotDelay then
            autoSnapshotIncrement = autoSnapshotIncrement + 1
        else 
            autoSnapshotIncrement = 0
            takeSnapshot()
        end
    end
end

-- Initialize dialog if app meets version requirements
if checkVersion() then
    app.events:on('sitechange',
        function()
            if (sprite and autoSnapshot) then
                autoSnapshot = false
                sprite.events:off(takeAutoSnapshot)
                mainDlg:modify{
                    id = "status",
                    text = "OFF"
                }
            end
        end
    )

    -- Creates the main dialog box
    mainDlg:separator{
        text="Manual Controls"
    }
    mainDlg:button{
        text = "Take Snapshot",
        onclick = 
            function()
                takeSnapshot()
            end
    }
    mainDlg:button{
        text = "Open Time Lapse",
        onclick = 
            function() 
                openTimeLapse()
            end
    }
    mainDlg:separator{
        text="Automatic Snapshot"
    }
    mainDlg:label{
        id = "status",
        label = "Automatic Snapshot is:",
        text = "OFF"
    }
    mainDlg:number{
        id = "delay",
        label = "Action Delay Count:",
        focus = true,
        text = tostring(autoSnapshotDelay),
        onchange = 
            function()
                autoSnapshotDelay = mainDlg.data.delay
                autoSnapshotIncrement = 0
            end
    }
    mainDlg:button{
        text = "Enable",
        id = "start",
        onclick = 
            function()
                checkSprite()

                if sprite then
                    autoSnapshot = true
                    autoSnapshotIncrement = 0
                    sprite.events:on('change', takeAutoSnapshot)
                    mainDlg:modify{
                        id = "status",
                        text = "RUNNING"
                    }
                end
            end
    }
    mainDlg:button{
        text = "Disable",
        id = "stop",
        onclick = 
            function()
                if autoSnapshot then 
                    autoSnapshot = false
                    sprite.events:off(takeAutoSnapshot)
                    mainDlg:modify{
                        id = "status",
                        text = "OFF"
                    }
                end
            end
    }
    mainDlg:show{ wait=false }    
end