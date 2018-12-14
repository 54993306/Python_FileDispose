
require("app.config");
require("cocos.init");
require("app.framework.init");
require("app.common.NativeCall");

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    return self;
end

function MyApp:run()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    --随机数
    math.newrandomseed();
    --
    release_print("------device.writablePath", device.writablePath);
    if device.platform == "android" then
        WRITEABLEPATH = "/storage/emulated/0/dsdfqp/";
        -- self:setSearchPath();

        --创建缓存目录
        local data = {};
        data.cmd = NativeCall.CMD_GETCACHE;
        NativeCall.getInstance():callNative(data, self.getCachePath, self);
    elseif device.platform == "windows" then
        WRITEABLEPATH = device.writablePath;
        self:setSearchPath();
        self:enterScene("MainScene");
    else
        MODEL = device.model;
        OS = 2;-- 操作系统：2:ios, 1:android, 3:mac, 4:windows
        WRITEABLEPATH = device.writablePath;
        self:setSearchPath();
        self:enterScene("MainScene");
    end

    self:createLuaConfig();

end

function MyApp:onEnterBackground()
    Log.i("------MyApp:onEnterBackground");
     if display.getRunningScene() and display.getRunningScene().onEnterBackGround then
        display.getRunningScene():onEnterBackGround()
    end
end

function MyApp:onEnterForeground()
    Log.i("------MyApp:onEnterForeground");
    if UIManager.getInstance():getWnd(HallMain) then
        SoundManager.pauseMoment(0.01);
    elseif UIManager.getInstance():getWnd(HallLogin) then
        LoadingView.getInstance():hide();
    else
        SoundManager.pauseMoment(1);
        CommonAnimManager.getInstance():pauseMoment();
    end

    if display.getRunningScene() and  display.getRunningScene().onEnterForeground then
        display.getRunningScene():onEnterForeground()
    end
end

--获取游戏是否为竖屏如果是竖屏的话切换为横屏
function MyApp:getScreenOriatationPortrait()
    local data = {};
    data.cmd = NativeCall.CMD_IS_PORTRAIT;
    NativeCall.getInstance():callNative(data, self.screenIsPortrait, self);
end

function MyApp:screenIsPortrait(info)
     Log.i("获取游戏是否为竖屏如果是竖屏的话切换为横屏...",info)
    if info.portrait == true and UIManager:getInstance():getScreenOrient() == 1 then
        local data = {};
        data.cmd = NativeCall.CMD_CHANGE_ORIENTAION;
        data.orient = 1;
        NativeCall.getInstance():callNative(data);
    elseif info.portrait == false and UIManager:getInstance():getScreenOrient() == 2 then
        local data = {};
        data.cmd = NativeCall.CMD_CHANGE_ORIENTAION;
        data.orient = 2;
        NativeCall.getInstance():callNative(data);
    end
end

function MyApp:getCachePath(info)

    if info and info.path then
        -- if info.path ~= WRITEABLEPATH then
            release_print("------MyApp:getCachePath", info.path);
            WRITEABLEPATH = info.path;
            self:setSearchPath();
            self:enterScene("MainScene");
        -- end
    end
end

function MyApp:setSearchPath()
    package.path = WRITEABLEPATH .. "update/src/;" .. package.path;
    release_print("------package.path = ", package.path);
    if device.platform == "ios" then
        CACHEDIR = WRITEABLEPATH;
    else
        CACHEDIR = WRITEABLEPATH .. "cache/";
    end

    cc.FileUtils:getInstance():addSearchPath(WRITEABLEPATH .. "update/" .. "src/");
    cc.FileUtils:getInstance():addSearchPath(CACHEDIR);
    cc.FileUtils:getInstance():addSearchPath(WRITEABLEPATH .. "update/" .. "res/");
    cc.FileUtils:getInstance():addSearchPath("res/");
    cc.FileUtils:getInstance():addSearchPath("res/games/common/");
    if device.platform == "ios" then
        release_print("device.platform....",device.platform)
        release_print("VERSION111111...",VERSION)
        package.loaded["app.config"] = nil;
        package.loaded["app.common.NativeCall"] = nil;
        require("app.config");
        --require("cocos.init");
        --require("app.framework.init");
        require("app.common.NativeCall");
        release_print("VERSION...",VERSION)
        -- VERSION = "1.0.10";
    end
end

--通过读取CSV配置表生成LUA文件
function MyApp:createLuaConfig()
     --创建LUA配置表
    if device.platform == "windows" then
        --Util.CSV2Table("bagIconConfig.csv")
    end

    local CacheCollect = require("app.CacheCollect")
    -- CacheCollect.new()
end

return MyApp
