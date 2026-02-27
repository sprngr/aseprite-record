--[[
    Record v3.x - Open Time Lapse
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

--[[
    Record Core Library
]]

error_messages = {
    invalid_api_version = "This script requires Aseprite v1.2.30 or newer. Please update Aseprite to continue.",
    no_active_sprite = "No active sprite is available.",
    save_required = "A sprite must be saved before you are able to run this script.",
    snapshot_required = "You need to take at least one snapshot to load a time lapse.",
}

-- Utility functions
function check_api_version()
    if app.apiVersion < 15 then
        show_error(error_messages.invalid_api_version)
        return false
    else
        return true
    end
end

function show_error(error_msg)
    local error_dialog = Dialog("Error")
    error_dialog
        :label { text = error_msg }
        :newrow()
        :button { text = "Close", onclick = function() error_dialog:close() end }
    error_dialog:show()
end

local function get_active_frame_number()
    local frame = app.frame.frameNumber
    if frame == nil then
        return 1
    else
        return frame
    end
end

RecordingContext = {}

function RecordingContext:get_recording_index()
    local path = self.index_file
    if not app.fs.isFile(path) then
        return 0
    end
    local file = io.open(path, "r")
    assert(file)
    local contents = file:read()
    io.close(file)
    return tonumber(contents)
end

function RecordingContext:set_recording_index(index)
    local path = self.index_file
    local file = io.open(path, "w")
    assert(file)
    file:write("" .. index)
    io.close(file)
end

function RecordingContext.new(sprite)
    local self = {}
    setmetatable(self, { __index = RecordingContext })
    self.sprite_file_name = app.fs.fileTitle(sprite.filename)
    self.sprite_file_path = app.fs.filePath(sprite.filename)
    self:_init_directory()
    self.index_file = app.fs.joinPath(self.record_directory_path, "_index.txt")
    self:_promote_v2_to_v3()
    return self
end

function RecordingContext:_init_directory()
    local dir_name_legacy = self.sprite_file_name .. "_record"
    local dir_path_legacy = app.fs.joinPath(self.sprite_file_path, dir_name_legacy)
    if app.fs.isDirectory(dir_path_legacy) then
        -- For 2.x Target Directory Backwards Compatibility
        self._is_legacy_recording = true
        self.record_directory_name = dir_name_legacy
    else
        self._is_legacy_recording = false
        self.record_directory_name = self.sprite_file_name .. "__record"
    end

    self.record_directory_path = app.fs.joinPath(self.sprite_file_path, self.record_directory_name)
end

function RecordingContext:_promote_v2_to_v3()
    if not self._is_legacy_recording then
        return -- Is not v2.x
    end
    if app.fs.isFile(self.index_file) then
        return -- Is v2.x, but already has promoted structure
    end
    -- 2.x Add Missing Index File for Forward Compatibility
    local is_index_set = false
    local current_index = 0
    while not is_index_set do
        if not app.fs.isFile(self:get_recording_image_path(current_index)) then
            is_index_set = true
            self.context:set_recording_index(current_index)
        else
            current_index = current_index + 1
        end
    end
end

function RecordingContext:get_recording_image_path(index)
    if not app.fs.isDirectory(self.record_directory_path) then
        app.fs.makeDirectory(self.record_directory_path)
    end

    return app.fs.joinPath(self.record_directory_path, self.sprite_file_name .. "_" .. index .. ".png")
end

--[[
    End Record Core Library
]]

if check_api_version() then
    local sprite = app.sprite
    if sprite and app.fs.isFile(sprite.filename) then
        local context = RecordingContext.new(sprite)
        local path = context:get_recording_image_path(0)
        if app.fs.isFile(path) then
            app.command.OpenFile { filename = path }
        else
            return show_error(error_messages.snapshot_required)
        end
    else
        return show_error(error_messages.save_required)
    end
end
