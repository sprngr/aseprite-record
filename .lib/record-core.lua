--[[
    Record v2.4 - Record Core Library
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

function showError(errorMsg)
    local errorDlg = Dialog("Error")
    errorDlg
        :label { text = errorMsg }
        :newrow()
        :button { text = "Close", onclick = function() errorDlg:close() end }
    errorDlg:show()
end

function activeFrameNumber()
    local f = app.activeFrame
    if f == nil then
        return 1
    else
        return f
    end
end

function ProjectContext_new(sprite)
    local self = {}
    self.fileName = app.fs.fileTitle(sprite.filename)
    self.filePath = app.fs.filePath(sprite.filename)
    self.recordDirName = self.fileName .. "__record"
    self.recordDirPath = app.fs.joinPath(self.filePath, self.recordDirName)
    self.recordIndexName = "_index.txt"
    self.recordIndexFile = app.fs.joinPath(self.recordDirPath, self.recordIndexName)
    return self
end

function ProjectContext_recordImagePath(self, index)
    return app.fs.joinPath(self.recordDirPath, "" .. index .. ".png")
end

function AutoSnapshot_imagePathAt(self, index)
    return ProjectContext_recordImagePath(self.projectContext, index)
end

function AutoSnapshot_isValid(self)
    if self.sprite then
        return true
    end
    return false
end

function AutoSnapshot_isActive(self)
    if not AutoSnapshot_isValid(self) then
        return false
    end
    return self.enabled
end

local function _AutoSnapshot_getRecordIndex(self)
    local path = self.projectContext.recordIndexFile
    if not app.fs.isFile(path) then
        return 0
    end
    local file = io.open(path, "r")
    local contents = file:read()
    io.close(file)
    return tonumber(contents)
end

local function _AutoSnapshot_incRecordIndex(self)
    local index = _AutoSnapshot_getRecordIndex(self) + 1
    local path = self.projectContext.recordIndexFile
    local file = io.open(path, "w")
    file:write("" .. index)
    io.close(file)
end

function AutoSnapshot_currentImagePath(self)
    return AutoSnapshot_imagePathAt(self, _AutoSnapshot_getRecordIndex(self))
end

function AutoSnapshot_saveSnapshot(self)
    local path = AutoSnapshot_currentImagePath(self)
    local image = Image(self.sprite)
    image:drawSprite(self.sprite, activeFrameNumber())
    image:saveAs(path)
    _AutoSnapshot_incRecordIndex(self)
end

local function _AutoSnapshot_init(self, sprite)
    self.enabled        = false
    self.snapDelay      = 1
    self.snapIncrement  = 0
    self.projectContext = nil
    self.sprite         = nil
    if sprite then
        self.sprite         = sprite
        self.projectContext = ProjectContext_new(sprite)
    end
end

local function _AutoSnapshot_new()
    self = {}
    _AutoSnapshot_init(self, nil)
    return self
end

function AutoSnapshot_reset(self)
    _AutoSnapshot_init(self, nil)
end

function AutoSnapshot_setSprite(self, sprite)
    if not app.fs.isFile(sprite.filename) then
        return showError("File must be saved before able to run script.")
    end

    if (not self.sprite or self.sprite ~= sprite) then
        _AutoSnapshot_init(self, sprite)
    end
end

function AutoSnapshot_updateSprite(self)
    local sprite = app.activeSprite
    if not sprite then
        return showError("No active sprite available.")
    end
    AutoSnapshot_setSprite(self, sprite)
end

function AutoSnapshot_tick(self)
    if not self.enabled then
        return
    end
    if not self.sprite then
        return
    end

    self.snapIncrement = self.snapIncrement + 1
    if self.snapIncrement < self.snapDelay then
        return
    end
    self.snapIncrement = 0
    AutoSnapshot_saveSnapshot(self)
end

local _AutoSnapshot_instance = _AutoSnapshot_new()

function AutoSnapshot_sharedInstance()
    return _AutoSnapshot_instance
end
