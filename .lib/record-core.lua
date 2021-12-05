--[[
    Record v2.0 - Record Core Library
    Author: Michael Springer (@sprngr_)
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

function checkVersion()
    if app.apiVersion < 15 then
        showError("This script requires Aseprite v1.2.30 or newer. Please update Aseprite to continue.")
        return false
    else
        return true
    end
end

function setFileName(filename)
    fileName = app.fs.fileTitle(filename)
end

function getFileName()
    return fileName
end

function setFilePath(filename)
    filePath = app.fs.filePath(filename)
end

function getFilePath()
    return filePath
end

function setupFileStrings(filename)
    setFileName(filename)
    setFilePath(filename)
end

function showError(errorMsg)
    local errorDlg = Dialog("Error")
    errorDlg
        :label{ text = errorMsg }
        :newrow()
        :button{ text = "Close", onclick = function() errorDlg:close() end }
    errorDlg:show()
    return
end

function getDirectoryName()
    return getFileName().."_record"
end

function getSavePath()
    return app.fs.joinPath(getFilePath(), getDirectoryName())
end

function recordSnapshot(sprite, increment)
    sprite:saveCopyAs(app.fs.joinPath(getSavePath(), getSaveFileName(increment)))
end

function getSaveFileName(increment)
    return getFileName().."_"..increment..".png"
end