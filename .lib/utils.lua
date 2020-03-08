local pathSep = "/"
local filePath = ""
local fileName = ""

-- Set up utility methods
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function setPathSep(path)
    pathSep = path:sub(1,1) == "/" and "/" or "\\"
end

function getPathSep()
    return pathSep
end

function setFileName(name)
    fileName = name
end

function getFileName()
    return fileName
end

function setFilePath(path)
    filePath = path
end

function getFilePath()
    return filePath
end

function setupFileStrings(filename)
    -- setup path separator
    setPathSep(filename)
    
    local pathTable = split(filename, getPathSep())
    setFileName(pathTable[#pathTable])

    table.remove(pathTable, #pathTable)

    setFilePath(table.concat(pathTable,getPathSep()))
end

function showError(errorMsg)
    local errorDlg = Dialog("Error")
    errorDlg
        :label{id = 0, text = errorMsg}
        :newrow()
        :button{id = 1, text = "Close", onclick = function() errorDlg:close() end }
    errorDlg:show()
    return
end
