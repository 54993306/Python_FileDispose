--[[--

提供调试接口

]]
local LoggerWindow = require("app.hall.common.UILoggerWindow")
local FileLog = require("app.common.FileLog")

Log = {};

Log.s_tab = "";

-- 存储的日志级别
local LogLevel = FileLog.LogLevel
---------------------------------------------------------------------

local function printLongLog(strInfo)
    local bufCount=8*1024

    if #strInfo>bufCount then
        local count = math.ceil(#strInfo / bufCount)
        for i=1,count do
            local str=string.sub(strInfo, 1+(i-1)*bufCount, i*bufCount)
            release_print(str)
            -- LoggerWindow.print(str)
        end
    else
        release_print(strInfo)
        -- LoggerWindow.print(strInfo)
    end
end

local function output(str, logLevel)
    if DEBUG_MODE then
        printLongLog(str)
    end
    if logLevel >= kServerInfo:getFileLogLvl() then
        FileLog.saveLog(str)
    end
end

function Log.s(...)
-- Log.s = function(...)
    if LogLevel.DEBUG >= kServerInfo:getFileLogLvl() then
        local str =  Log.getStrInfo("[DEBUG] ", "", ...)
        FileLog.saveLog(str)
    end
end

--函数功能: 输出到wnt控制台 debug
function Log.d(...)
-- Log.d = function(...)
    local str =  Log.getStrInfo("[DEBUG] ", "", ...)
    output(str, LogLevel.DEBUG)
end

function Log.w(...)
-- Log.w = function(...)
    local str =  Log.getStrInfo("[WARN] ", "", ...)
    output(str, LogLevel.WARN)
end

function Log.e(...)
-- Log.e = function(...)
    local str =  Log.getStrInfo("[ERROR] ", "", ...)
    output(str, LogLevel.ERROR)
    output(debug.traceback(), LogLevel.ERROR)
end

function Log.t(...)
-- Log.t = function(...)
    --output(serializeTable(_table))
    if DEBUG_MODE then
        local str = ""
        local temp = {...}
        for _,v in pairs(temp) do
            if type(v) == "table" or type(v) == "userdata" then
                str = str .. Log.decomposeTable(v)
            else
                str = str .. tostring(v)
            end
            str = str .. " "
        end
       -- local str = Log.decomposeTable(_table)
        -- Log.i(str)
        output("[INFO] ".. str, LogLevel.INFO)
    end
end

function Log.format(...)

    local args = {...}
    local str = ""
    for k, v in pairs(args) do
        str = str .. " " .. tostring(v)
    end
    return str
end

function Log.decomposeTable(_table)

    if not _table then
        return "nil"
    end
    local str = "{ "
    if type(_table) == "userdata" then
        str = str .. tostring(_table) .. "}"
        return str
    end

    for k,v in pairs(_table) do
        str = str .. tostring(k) .. " = "
        if k == "class" then
            str = str .. tostring(v)
        else
        if type(v) == "table" then
            str = str .. Log.decomposeTable(v)
        else
            str = str .. tostring(v) .. " "

        end
    end
        str = str .. ", "

    end
    str = str .. "}"
   -- num = 1
    tableList = {}
    return str
end
---------------------------------------------------------------------

function Log.i(tag, ...)
-- Log.i = function(tag, ...)
    Log.base("[INFO] ", tag, ...);
end

if PLUGIN_LOG == nil then
    PLUGIN_LOG = release_print
end

function Log.base(tagPrefix, tag, ...)
-- Log.base = function(tagPrefix, tag, ...)
    if DEBUG < 1 then
        return;
    end

    local strInfo = Log.getStrInfo(tagPrefix, tag, ...);

    local bufCount=8*1024
    if #strInfo>bufCount then
        local count = math.ceil(#strInfo / bufCount)
        for i=1,count do
            local str=string.sub(strInfo, 1+(i-1)*bufCount, i*bufCount)
            PLUGIN_LOG(str)
        end
    else
        PLUGIN_LOG(strInfo);
    end
end

function Log.getStrInfo(tagPrefix, tag, ...)
-- Log.getStrInfo = function(tagPrefix, tag, ...)
    local strInfo = Log.getData(tagPrefix, tag, ...);
    return strInfo;
end

function Log.getData(tagPrefix, tag, ...)
-- Log.getData = function(tagPrefix, tag, ...)
    tag = tag or "";
    tagPrefix = tagPrefix or "[INFO] ";
    tagPrefix = os.date() .. " ".. tagPrefix;
    local strArr = {};
    table.insert(strArr, "");
    for _, v in pairs({...}) do
        local tempType = type(v);
        if tempType == "table" then
            table.insert(strArr, Log.loadTable(v));
        else
            table.insert(strArr, tostring(v));
        end
        table.insert(strArr, " ");
    end
    -- table.concat(strArr)
    return string.format("%s%s: %s", tagPrefix, tag, table.concat(strArr));

end

function Log.loadTable(t)
-- Log.loadTable = function(t)
    if type(t) ~= "table" then
        return t;
    end

    local tab = Log.s_tab;
    Log.s_tab = Log.s_tab .. "    ";
    local strArr = {};
    table.insert(strArr, "");
    for k, v in pairs(t) do
        if v ~= nil then
            local key = Log.s_tab;
            if type(k) == "string" then
                -- key = key .. "[\""..tostring(k).."\"] = ";
                key =  string.format("%s[\"%s\"] = ", key, tostring(k) );
            else
                -- key = key.."["..tostring(k).."] = ";
                key =  string.format("%s[%s] = ", key, tostring(k) );
            end

            table.insert(strArr, key);
            if type(v) == "table" then
                -- temp = temp..key..Log.loadTable(v);
                table.insert(strArr, Log.loadTable(v) );
            else
                -- temp = temp..key..tostring(v)..";\n";
                table.insert(strArr, tostring(v) .. ";\n" );
            end
        end
    end
    Log.s_tab = tab;
    local str = string.format("\n%s{\n%s%s};\n", Log.s_tab, table.concat(strArr), Log.s_tab);
    -- temp = "\n"..Log.s_tab.."{\n"..temp..Log.s_tab.."};\n";

    return str;
end

--[[ #param luaTable ]]--
function Log.postLog( str )
-- Log.postLog = function( str )
    Log.s(str)
    do return end
    if type(DEBUG) ~= "number" or DEBUG <= 0 then return end
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", "http://192.168.8.129:8080/xGame/LogUpload.action")

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    -- local sendStr = "username=".._logConfigParam.username .. "&info="..str
    local sendStr
    if kUserInfo and kUserInfo.getUserId then
        sendStr = "username=".. "zsy" .. "&info=".."userID: " .. kUserInfo:getUserId() .. ", str: " .. str
    else
        sendStr = "username=".. "zsy" .. "&info=" .. str
    end
    xhr:send(sendStr)
end
