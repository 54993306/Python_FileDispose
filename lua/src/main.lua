local isSuccess, errMsg = pcall(require, "LuaDebugjit");
local breakSocketHandle = function() end
local debugXpCall = function() end
if isSuccess then
    breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003)
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
    breakSocketHandle();
    end,0.5,false)
end

function __G__TRACKBACK__(errorMessage)
    if device.platform == "android" then
        local message = tostring(errorMessage)
        if GC_GameName then
            message = GC_GameName .. message
        end
        buglySetTag(67252) -- __G__TRACKBACK__
	    buglyReportLuaException(message, debug.traceback())
	end
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    if device.platform == "windows" or device.platform == "mac" then
    --if true then
        device.showAlert("LUA ERROR", tostring(errorMessage)..debug.traceback("", 2), "OK")
    end
    return errorMessage
end

PLUGIN_LOG=function(sGameLog)
    local tInfo=debug.getinfo(4,"Sln");
    release_print(string.format("%s,%d",tInfo.short_src,tInfo.currentline),sGameLog)
end

release_print(string.format("%s", package.path));
package.path = "src/";
cc.FileUtils:getInstance():setPopupNotify(false);
MyAppInstance = require("app.MyApp").new();
MyAppInstance:run();
