function getDirectoryName()
    return getFileName():gsub('(%.%w+)$', '_record')
end

function getSavePath()
    return getFilePath()..getPathSep()..getDirectoryName()..getPathSep()
end

function recordSnapshot(sprite, increment)
    sprite:saveCopyAs(getSavePath()..getSaveFileName(increment))
end

function getSaveFileName(increment)
    return getFileName():gsub('(%.%w+)$', '_'..increment..'.png')
end