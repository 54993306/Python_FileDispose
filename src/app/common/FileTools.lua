local FileTools = {}

FileTools.isFileExist = function(requirePath,isIOS)
    -- requirePath暂定为app起始, filePath需要为src起始的路径
    
    local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    print("FileTools.isFileExist: filePath: " .. filePath)
    -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
    local re, err = cc.FileUtils:getInstance():isFileExist(filePath)
    if not re then
        local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".luac"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
        print("FileTools.isFileExist: filePath: " .. filePath)
        -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
        re, err = cc.FileUtils:getInstance():isFileExist(filePath)
    end
    if re then
        return true
    else
        if isIOS then
            -- ios修改自动打包结构后，会导致热更搜索不到加载的文件目录
            local filePath = WRITEABLEPATH .. "update/".."src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
            filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
            print("FileTools.isFileExist: filePath: " .. filePath)
            -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
            local re, err = cc.FileUtils:getInstance():isFileExist(filePath)
            if not re then
                local filePath = WRITEABLEPATH .. "update/".."src/" .. string.gsub(requirePath, "%.", "/") .. ".luac"
                filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
                print("FileTools.isFileExist: filePath: " .. filePath)
                -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
                re, err = cc.FileUtils:getInstance():isFileExist(filePath)
            end
            if re then
                return true
            else
                return false
            end
        else
            return false
        end
    end
end

FileTools.reloadFile = function(requirePath,isIOS)
    local exist = FileTools.isFileExist(requirePath,isIOS)
    -- print(requirePath)
    if not exist then return nil end

    package.loaded[requirePath] = nil
    local isSuccess, errMsg = pcall(require, requirePath)
    -- print(isSuccess)
    -- print(errMsg)
    return isSuccess, errMsg
end

return FileTools