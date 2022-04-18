--[[
    Record v3.x - Record Core Library
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

function check_api_version()
    if app.apiVersion < 15 then
        show_error("This script requires Aseprite v1.2.30 or newer. Please update Aseprite to continue.")
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

function get_active_frame_number()
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
    self.index_file_name = "_index.txt"

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
    self.index_file_path = app.fs.joinPath(self.record_directory_path, self.index_file_name)

    -- 2.x Add Missing Index File for Forward Compatibility
    if is_legacy_recording and not app.fs.isFile(self.index_file_path) then
        local is_index_set = false
        local current_index = 0
        while not is_index_set do
            if not app.fs.isFile(get_contextual_recording_image_path(self, current_index)) then
                is_index_set = true
                local path = self.index_file_path
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

function is_snapshot_valid(self)
    if self.sprite then
        return true
    end
    return false
end

function is_snapshot_active(self)
    if not is_snapshot_valid(self) then
        return false
    end
    return self.enabled
end

local function get_snapshot_recording_index(self)
    local path = self.context.index_file_path
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
    local path = self.context.index_file_path
    local file = io.open(path, "w")
    file:write("" .. index)
    io.close(file)
end

function get_snapshot_current_image_path(self)
    return get_recording_image_path_at_index(self, get_snapshot_recording_index(self))
end

function save_snapshot(self)
    local path = get_snapshot_current_image_path(self)
    local image = Image(self.sprite)
    image:drawSprite(self.sprite, get_active_frame_number())
    image:saveAs(path)
    increment_snapshot_recording_index(self)
end

local function initialize_snapshot(self, sprite)
    self.enabled = false
    self.snapDelay = 1
    self.snapIncrement = 0
    self.context = nil
    self.sprite = nil
    if sprite then
        self.sprite = sprite
        self.context = get_recording_context(sprite)
    end
end

local function get_new_snapshot()
    local self = {}
    initialize_snapshot(self, nil)
    return self
end

function reset_snapshot(self)
    initialize_snapshot(self, nil)
end

function set_snapshot_sprite(self, sprite)
    if not app.fs.isFile(sprite.filename) then
        return show_error("File must be saved before able to run script.")
    end

    if (not self.sprite or self.sprite ~= sprite) then
        initialize_snapshot(self, sprite)
    end
end

function update_snapshot_sprite(self)
    local sprite = app.activeSprite
    if not sprite then
        return show_error("No active sprite available.")
    end
    set_snapshot_sprite(self, sprite)
end

function auto_save_snapshot(self)
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
    save_snapshot(self)
end

local snapshot_instance = get_new_snapshot()

function get_snapshot()
    return get_new_snapshot()
end
