--[[
    Record v3.x - Record Core Library
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

error_messages = {}
error_messages["invalid_api_version"] = "This script requires Aseprite v1.2.30 or newer. Please update Aseprite to continue."
error_messages["no_active_sprite"] = "No active sprite is available."
error_messages["snapshot_required"] = "You need to take at least one snapshot to load a time lapse."
error_messages["save_required"] = "A sprite must be saved before you are able to run this script."

-- Utility functions
function check_api_version()
    if app.apiVersion < 15 then
        show_error(error_messages["invalid_api_version"])
        return false
    else
        return true
    end
end

function show_error(errorMsg)
    local error_dialog = Dialog("Error")
    error_dialog
        :label { text = errorMsg }
        :newrow()
        :button { text = "Close", onclick = function() error_dialog:close() end }
    error_dialog:show()
end

-- Core functions
local function initialize_snapshot(self, sprite)
    self.auto_snap_enabled = false
    self.auto_snap_delay = 1
    self.auto_snap_increment = 0
    self.context = nil

    -- Instance of Aseprite Sprite object
    -- https://github.com/aseprite/api/blob/master/api/sprite.md#sprite
    self.sprite = nil
    if sprite then
        self.sprite = sprite
        self.context = get_recording_context(sprite)
    end
end

local function get_snapshot_recording_index(self)
    local path = self.context.index_file
    if not app.fs.isFile(path) then
        return 0
    end
    local file = io.open(path, "r")
    local contents = file:read()
    io.close(file)
    return tonumber(contents)
end

local function increment_snapshot_recording_index(self)
    local index = get_snapshot_recording_index(self) + 1
    local path = self.context.index_file
    local file = io.open(path, "w")
    file:write("" .. index)
    io.close(file)
end

local function get_active_frame_number()
    local frame = app.activeFrame
    if frame == nil then
        return 1
    else
        return frame
    end
end

function get_recording_context(sprite)
    local self = {}
    self.sprite_file_name = app.fs.fileTitle(sprite.filename)
    self.sprite_file_path = app.fs.filePath(sprite.filename)

    -- 2.x Target Directory Backwards Compatibility
    self.record_directory_name_legacy = self.sprite_file_name .. "_record"
    local is_legacy_recording = false
    if app.fs.isDirectory(app.fs.joinPath(self.sprite_file_path, self.record_directory_name_legacy)) then
        is_legacy_recording = true
        self.record_directory_name = self.record_directory_name_legacy
    else
        self.record_directory_name = self.sprite_file_name .. "__record"
    end

    self.record_directory_path = app.fs.joinPath(self.sprite_file_path, self.record_directory_name)
    self.index_file = app.fs.joinPath(self.record_directory_path, "_index.txt")

    -- 2.x Add Missing Index File for Forward Compatibility
    if is_legacy_recording and not app.fs.isFile(self.index_file) then
        local is_index_set = false
        local current_index = 0
        while not is_index_set do
            if not app.fs.isFile(get_contextual_recording_image_path(self, current_index)) then
                is_index_set = true
                local path = self.index_file
                local file = io.open(path, "w")
                file:write("" .. current_index)
                io.close(file)
            else
                current_index = current_index + 1
            end
        end
    end

    return self
end

function get_contextual_recording_image_path(self, index)
    return app.fs.joinPath(self.record_directory_path, self.sprite_file_name .. "_" .. index .. ".png")
end

function get_recording_image_path_at_index(self, index)
    return get_contextual_recording_image_path(self.context, index)
end

function get_snapshot()
    local self = {}
    initialize_snapshot(self, nil)
    return self
end

function is_snapshot_active(self)
    if not is_snapshot_valid(self) then
        return false
    end
    return self.auto_snap_enabled
end

function is_snapshot_valid(self)
    if self.sprite then
        return true
    end
    return false
end

function reset_snapshot(self)
    initialize_snapshot(self, nil)
end

function auto_save_snapshot(self)
    if not self.auto_snap_enabled then
        return
    end
    if not self.sprite then
        return
    end

    self.auto_snap_increment = self.auto_snap_increment + 1
    if self.auto_snap_increment < self.auto_snap_delay then
        return
    end
    self.auto_snap_increment = 0
    save_snapshot(self)
end

function save_snapshot(self)
    local path = get_recording_image_path_at_index(self, get_snapshot_recording_index(self))
    local image = Image(self.sprite)
    image:drawSprite(self.sprite, get_active_frame_number())
    image:saveAs(path)
    increment_snapshot_recording_index(self)
end

function set_snapshot_sprite(self, sprite)
    if not app.fs.isFile(sprite.filename) then
        return show_error(error_messages["save_required"])
    end

    if (not self.sprite or self.sprite ~= sprite) then
        initialize_snapshot(self, sprite)
    end
end

function update_snapshot_sprite(self)
    local sprite = app.activeSprite
    if not sprite then
        return show_error(error_messages["no_active_sprite"])
    end
    set_snapshot_sprite(self, sprite)
end