require("lfs")
local zlib = require("zlib")

local FileLog = {}

local fileSuffix = ".log" -- 文件后缀

local initFinish = false -- 是否已经完成初始化

local currentIndex = nil -- 当前文件序号

local currentFilePath = nil -- 当前的日志文件

local logCache = {} -- 登录成功前的日志缓存

local cacheDir = nil -- 缓存目录
local compressedDir = nil -- 压缩文件目录

local MaxFileSize = 1024 * 10000 -- 单个缓存文件的大小

local OutTime = 60 * 60 * 24 * 1 -- 日志清理时间

local firstUpLoad = true -- 打开应用后首次上传

local preUserID = 0

-- 存储的日志级别
FileLog.LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

local function testLog(...)
    if DEBUG_MODE then
        release_print("FileLog", ...)
    else
        Log.i("FileLog", ...)
    end
end

local function logError(str)
    testLog("[ERROR] " .. tostring(str))
    testLog(debug.traceback())
end

function FileLog.init(deviceCacheDir)
    testLog("FileLog.init deviceCacheDir", deviceCacheDir)
    if not Util.debug_shield_value("openFileLog") then return end

    if initFinish then
        testLog("FileLog initFinished cacheDir", cacheDir)
        return
    end

    if type(deviceCacheDir) ~= "string" then
        logError("FileLog.init error deviceCacheDir: " .. tostring(deviceCacheDir))
        return false
    end
    local ret, desc = lfs.mkdir(deviceCacheDir)
    if not ret and desc ~= "File exists" then
        logError("FileLog.init error deviceCacheDir: " .. tostring(deviceCacheDir) .. desc)
        return
    end
    
    local lastStr = string.sub(deviceCacheDir, string.len(deviceCacheDir))
    -- testLog("lastStr " .. lastStr)
    if lastStr ~= "/" and lastStr ~= "\\" then
        cacheDir = deviceCacheDir .. "/log/"
    else
        cacheDir = deviceCacheDir .. "log/"
    end
    local ret, desc = lfs.mkdir(cacheDir)
    if not ret and desc ~= "File exists" then
        logError("FileLog.init error cacheDir: " .. tostring(cacheDir))
        return
    end

    compressedDir = cacheDir .. "compressed/"
    local ret, desc = lfs.mkdir(compressedDir)
    if not ret and desc ~= "File exists" then
        logError("FileLog.init error compressedDir: " .. tostring(compressedDir))
        return
    end

    initFinish = false
    FileLog.compressAllLog()
    currentIndex = 0

    -- Log.i("FileLog.decompress", FileLog.decompress(deviceCacheDir .. "20180905100838_1661180027.log")) -- 打印压缩的日志
end

function FileLog.compressAllLog()
    -- 先上传之前压缩的文件
    for file in lfs.dir(cacheDir) do
        if string.find(file, fileSuffix) then
            FileLog.compressLogFile(file)
            -- delayTime = delayTime + 2
        end
    end
    initFinish = true
end

-- 20180904210121_0-2D_4156-windows-1400100165.log
local function judegOldLog(fileName)
    testLog("string.len(fileName)", string.len(fileName))
    testLog("string.len(fileSuffix)", string.len(fileSuffix))
    if string.len(fileName) < 14 + string.len(fileSuffix) then
        return true
    end
    local data = {}
    data.year = tonumber(string.sub(fileName, 1, 4))
    data.month = tonumber(string.sub(fileName, 5, 6))
    data.day = tonumber(string.sub(fileName, 7, 8))
    data.hour = tonumber(string.sub(fileName, 9, 10))
    data.min = tonumber(string.sub(fileName, 11, 12))
    data.sec = tonumber(string.sub(fileName, 13, 14))
    -- data = {day=17, month=8, year=2018, hour=1, min=2, sec=3}
    -- Log.i("data", data)
    local time = os.time(data)
    testLog("time", time)

    return time + OutTime < os.time()
end

function FileLog.uploadAllLog(isManual)
    if not (firstUpLoad or isManual) or not compressedDir then return end
    firstUpLoad = false

    for file in lfs.dir(compressedDir) do
        testLog(file)
        local fullName = compressedDir .. file
        local fileSuffixFirstIdx = string.find(file, fileSuffix)
        if not fileSuffixFirstIdx then
            os.remove(fullName)
        elseif FileLog.judgeNeedUpload(file, fileSuffixFirstIdx) then
            local svrFilePath = string.sub(file, string.find(file, "-2D") + 1)
            testLog(svrFilePath)

            FileLog.onPostLog(fullName, svrFilePath, function()
                    os.remove(fullName)
                end)
        elseif judegOldLog(file) then
            os.remove(fullName)
        end
    end
end

function FileLog.judgeNeedUpload(fileName, fileSuffixFirstIdx)
    -- do return false end
    local _, platformLastIdx = string.find(fileName, device.platform)
    if not platformLastIdx then return false end
    local userid = string.sub(fileName, platformLastIdx + 2, fileSuffixFirstIdx - 1)
    testLog("userid", userid)
    local fileLogCfg = kServerInfo:getFileLogData()
    if not fileLogCfg or fileLogCfg.white == 0 or fileLogCfg.whiteUids[userid] then return true end
end

function FileLog.compressLogFile(localFileName)
    local localFilePath = cacheDir .. localFileName
    -- testLog("localFilePath: " .. localFilePath)
    local lastFileNameIdx = string.find(localFileName, fileSuffix)
    -- testLog("lastFileNameIdx: " .. lastFileNameIdx)
    local userid = string.sub(localFileName, 5, lastFileNameIdx - 3)
    testLog("userid: " .. userid)

    local fileIdx = string.sub(localFileName, lastFileNameIdx - 1, lastFileNameIdx - 1)
    testLog("fileIdx: " .. fileIdx)
    local lastFileName = string.sub(localFileName, lastFileNameIdx)
    -- testLog("lastFileName: " .. lastFileName)
    -- local svrFilePath = "Res/" .. userid .. "/log_" .. lastFileName
    local svrFilePath = string.format("2D_%s-%s-%s%s", PRODUCT_ID, device.platform, userid, fileSuffix)
    testLog("svrFilePath: " .. svrFilePath)

    local compressedFilePath = string.format("%s%s_%s-%s", compressedDir, os.date("%Y%m%d%H%M%S"), fileIdx, svrFilePath)
    testLog("compressedFilePath: " .. compressedFilePath)

    local eof = FileLog.compress(localFilePath, compressedFilePath)
    testLog("eof " .. tostring(eof))
    if eof then
        os.remove(localFilePath)
    end
end

local function testLogThenRecord(str)
    testLog(str)
    FileLog.saveLog(str)
end

function FileLog.onPostLog(filePath, svrFilePath, callback)
    testLogThenRecord("FileLog.onPostLog filePath: " .. filePath)
    testLogThenRecord("FileLog.onPostLog svrFilePath: " .. svrFilePath)
    network.uploadFile(
        function(evt)
            if evt.name == "completed" then
                testLogThenRecord("onPostLog completed svrFilePath: " .. svrFilePath)
                local request = evt.request
                testLogThenRecord(string.format("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode()))
                testLogThenRecord(string.format("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString()))
                testLogThenRecord(string.format("REQUEST getResponseDataLength() = %d", request:getResponseDataLength()))
                testLogThenRecord(string.format("REQUEST getResponseString() =\n%s", request:getResponseString()))
                if request:getResponseStatusCode() == 200 then
                    callback()
                end
            end
        end,
        kServerInfo:getFileLogData().url,
        {
            fileFieldName="logfile",
            filePath=filePath,
            contentType="application/octet-stream",
            extra={
                -- {"act", "uploadImg"},
                {"product_id", "2d"},
                -- {"path", svrFilePath},
            }
        }
    )
end

function FileLog.saveLog(str)
    if not Util.debug_shield_value("openFileLog") then return end

    if type(str) ~= "string" then
        logError("FileLog.saveLog error str: " .. tostring(str))
        return false
    end
    str = os.time() .. " " .. str
    -- testLog("FileLog.saveLog str: " .. str)
    if FileLog.getAvailableFileName() then
        for i = 1, #logCache do
            FileLog.saveToFile(logCache[i], FileLog.getAvailableFileName())
        end
        logCache = {}
        FileLog.saveToFile(str, FileLog.getAvailableFileName())
    else
        table.insert(logCache, str)
    end
end

function FileLog.saveToFile(str, filePath, mode, repeatTimes)
    if type(str) ~= "string" then
        logError("FileLog.saveToFile error str: " .. tostring(str))
        return false
    end
    if type(filePath) ~= "string" then
        logError("FileLog.saveToFile error filePath: " .. tostring(filePath))
    else
        local writeHandle = assert(io.open(filePath, mode or "a+b"), "not the file");
        if writeHandle then
            writeHandle:write(str)
            if repeatTimes then
                for i = 1, repeatTimes - 1 do
                    writeHandle:write(str)
                    writeHandle:write("\n\n")
                end
            end
            writeHandle:write("\n\n")
            writeHandle:close()
            return true
        end
    end
    table.insert(logCache, str)
    return false
end

function FileLog.readFile(filePath)
    local fileHandle = assert(io.open(filePath, "rb"), "not the file");
    local outData
    if fileHandle then
        outData = fileHandle:read("*all");
        fileHandle:close();
        -- print(outData);
    else
        logError("readFile false");
    end
    return outData
end

function FileLog.getAvailableFileName()
    -- testLog("FileLog.getAvailableFileName")
    if not currentFilePath then
        if not initFinish then return nil end
        if kUserInfo:getUserId() == 0 then return nil end
        currentFilePath = cacheDir .. "uid_" .. kUserInfo:getUserId() .. "_" .. currentIndex .. fileSuffix
        FileLog.initFile(currentFilePath)
        -- testLog("not currentFilePath " .. currentFilePath)
        return currentFilePath
    else
        local filesize = io.filesize(currentFilePath) or 0
        if filesize > MaxFileSize then
            FileLog.compressAllLog() -- 对写满的日志文件进行压缩
            currentIndex = (currentIndex + 1) % 5
            currentFilePath = cacheDir .. "uid_" .. kUserInfo:getUserId() .. "_" .. currentIndex .. fileSuffix
            FileLog.initFile(currentFilePath)
        end
        -- testLog("currentFilePath " .. currentFilePath)
        return currentFilePath
    end
end

function FileLog.compress(filePath, compressedFilePath)
    local fromStr = FileLog.readFile(filePath)
    if not fromStr then return false end

    local stream = zlib.deflate(9) -- 压缩级别1-9, 默认6
    local deflated, eof, bytes_in, bytes_out = stream(fromStr, 'finish')
    os.remove(compressedFilePath)
    FileLog.saveToFile(deflated, compressedFilePath)
    return eof
end

function FileLog.initFile(filePath)
    if type(filePath) ~= "string" then
        logError("FileLog.initFile error filePath: " .. tostring(filePath))
    else
        local fileHeader = string.format("%s_Log_Start_%s_Ver%s\n\n", GC_GameName, os.date("%Y%m%d_%H%M%S"), VERSION)
        FileLog.saveToFile(fileHeader, filePath, "w+b")
    end
end

function FileLog.getDir()
end

function FileLog.search()
end

function FileLog.deleteFile(filePath)
end

function FileLog.decompress(filePath)
    local fromStr = FileLog.readFile(filePath)
    local stream = zlib.inflate()
    local inflated, eof, bytes_in, bytes_out = stream(fromStr)
    return inflated
end

function FileLog.manualUploadLogs()
    if not initFinish then return end
    FileLog.compressAllLog()
    FileLog.uploadAllLog(true)
end

-- 登录后如果ID不相同, 则换一个文件名
function FileLog.onLogin(userID)
    if not initFinish then return end
    if type(userID) == 'number' and userID ~= 0 and userID ~= preUserID then
        preUserID = userID
        currentFilePath = cacheDir .. "uid_" .. preUserID .. "_" .. currentIndex .. fileSuffix
    end
end

return FileLog