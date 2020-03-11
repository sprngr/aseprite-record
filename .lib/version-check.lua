function checkVersion()
    if app.apiVersion < 9
    then
        showError("This script requires Aseprite v1.2.17 or newer. Please update Aseprite to continue.")
        return false
    else
        return true
    end
end
