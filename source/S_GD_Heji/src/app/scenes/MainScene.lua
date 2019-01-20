local LoggerWindow = require("app.hall.common.UILoggerWindow")

--主场景
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    
    require("app.hall.HallConfig");
    if device.platform ~= "ios" then
    	self:checkUpdateVersion()
    end
    
    SocketManager.getInstance():setUserDataProcesser(UserDataProcesser.new());
    cc.Director:getInstance():setAnimationInterval(1/60);
    cc(self):addComponent("app.games.common.components.SingleTouchSwallow"):exportMethods()
    -- --解决真机上闪屏的问题
    -- self.tmpImg = ccui.ImageView:create("real_res/1004471.png");
    -- self.tmpImg:ignoreContentAdaptWithSize(false);
    -- self.tmpImg:setLocalZOrder(0)
    -- self:addChild(self.tmpImg)

    if DEBUG_MODE then
        Log.i("MainScene:ctor")
        LoggerWindow:getInstance():removeFromParent()
        self:addChild(LoggerWindow:getInstance(), UIManager.ZOrderOnScene.LoggerWindow)
    end
    self:setName("MainScene")

end

function MainScene:checkUpdateVersion()
    local verTable = cc.UserDefault:getInstance():getStringForKey("moreupdate-version", VERSION)
    local selfVerTable = VERSION
    -- Toast.getInstance():show("版本号.",verTable,selfVerTable)
    print("版本号."..verTable..selfVerTable)
    if self:checkVersion(1,self:analyzeString(verTable),self:analyzeString(selfVerTable)) then
        selfVerTable = verTable
        -- Toast.getInstance():show("读取更新的....")
        print("读取更新的....")
        if device.platform ~= "ios" then
            self:setSearchPath()
        end
    end
end


function MainScene:analyzeString(strText)
    local retV = {};
    if (strText == nil or strText == "" ) then return retV end
    local retTable = self:split(strText,"%.")

    return retTable
end

function MainScene:split( str, splitchar )
    local arr = {}
    local head = 1
    local tail = nil
    while true do
        tail, _ = str:find(splitchar,head )
        if tail == nil then
            arr[ 1 + #arr ] = str:sub( head, -1 )
            break
        end
        arr[ 1 + #arr ] = str:sub( head, tail - 1 )
        head = tail + 1
    end
    return arr
end

function MainScene:checkVersion(type,verTable,selfVerTable)
    local tmpIndex = false
    for j = type,#verTable do
        if not selfVerTable[j] then
            selfVerTable[j] = 0
        end
        if tonumber(verTable[j]) > tonumber(selfVerTable[j]) then
            print("检测版本....."..verTable[j]..":"..selfVerTable[j])
            tmpIndex = true
            break
        elseif tonumber(verTable[j]) == tonumber(selfVerTable[j]) then
            tmpIndex = self:checkVersion(type+1,verTable,selfVerTable)
            break
        else
            break
        end
    end
    return tmpIndex
end


function MainScene:setSearchPath()

    local fileUtils = cc.FileUtils:getInstance()
    local path = cc.UserDefault:getInstance():getStringForKey("update_path", string.format("%s%s/%s/", fileUtils:getWritablePath(),APP_NAME_PATCH or "dszy","update"))
    -- fileUtils:removeAllPaths()
    local upPath = path
    print("搜索路径....",upPath)
    -- WRITEABLEPATH = upPath
    package.path = upPath .. "src/;" .. package.path;
    print("package.path....",package.path)
    local paths = fileUtils:getSearchPaths()
    table.insert(paths, 1, upPath .. "res/")
    table.insert(paths, 1, upPath .. "src/package_src/games/")
    table.insert(paths, 1, upPath .. "src/package_src/")
    table.insert(paths, 1, upPath .. "src/")

    cc.FileUtils:getInstance():setSearchPaths(paths);
    for i,v in pairs(paths) do
        print(v)
    end
    release_print("device.platform....",device.platform)
    release_print("VERSION111111...",VERSION)
    package.loaded["app.config"] = nil;
    package.loaded["app.common.NativeCall"] = nil;
    package.loaded["app.hall.HallConfig"] = nil;
    require("app.hall.HallConfig");
    for i ,v in pairs(package.loaded) do
        v = nil
    end
    require("app.config");
    require("app.common.NativeCall");

end
--返回键
function MainScene:onKeyboard(code, event)
    Log.i("MainScene:onKeyboard code", code);
    if code == cc.KeyCode.KEY_BACK then
        UIManager.getInstance():disPatchKeyBackEvent();
    end
end

function MainScene:onEnter()
    Log.i("MainScene:onEnter...")
    self:regSwallowTouchEvent()
    local glview = cc.Director:getInstance():getOpenGLView()
    if glview then
        --在游戏中被360清除，重启要旋转屏幕
        UIManager.getInstance():recoverToDesignOrient()

        if self.tmpImg then
            self.tmpImg:setPosition(display.cx, display.cy)
            if display.width > display.height then
                self.tmpImg:setContentSize(display.size)
            else
                self.tmpImg:setContentSize(cc.size(display.height, display.width))
                self.tmpImg:setRotation(90)
            end
            self.tmpImg:setVisible(true)
        end
    end

    if not self.m_add then
        --刚启动游戏
        self.m_add = true;
        UIManager.getInstance():recoverToDesignOrient()
        --返回键监听
        local keyListener = cc.EventListenerKeyboard:create();
        keyListener:registerScriptHandler(handler(self, self.onKeyboard), cc.Handler.EVENT_KEYBOARD_RELEASED);
        local eventDispatch = self:getEventDispatcher();
        eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self);
        --加载UI
        UIManager.getInstance():setCurScene(self);
        UIManager.getInstance():pushWnd(HallLogin);
        -- 初始化配置
        self:initConfig()
    else
        UIManager.getInstance():recoverToDesignOrient()
        SocketManager.getInstance().pauseDispatchMsg = false
        if SocketManager.getInstance():getNetWorkStatus() == NETWORK_NORMAL then
            UIManager.getInstance():replaceWnd(HallMain);
        else
            --网络异常退出到登录界面
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end

        --释放ccs动画
        if _gameArmatureFileInfoCfg then
            for k, v in pairs(_gameArmatureFileInfoCfg) do
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v);
            end
        end
        --释放无用资源
        if device.platform == "windows" or device.platform == "mac" then
        else
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res_plist/1008024.plist")
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res_plist/1008025.plist")
            cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames();
            cc.Director:getInstance():getTextureCache():removeUnusedTextures();
        end
    end
end

--[[
-- @brief  初始化配置函数
-- @param  void
-- @return void
--]]
function MainScene:initConfig()
    -- 初始化音效音量
    local soundValue = SettingInfo.getInstance():getGameSoundValue()
    audio.setSoundsVolume(soundValue / 100)
    -- 初始化音乐音量
    local musicValue = SettingInfo.getInstance():getGameMusicValue()
    audio.setMusicVolume(musicValue / 100)
end

function MainScene:onEnterBackGround()
    Log.i("------MainScene:onEnterBackGround");
end

function MainScene:onEnterForeground()
--    if not UIManager.getInstance():getWnd(FriendRoomScene) then
        -- local hallMain = UIManager.getInstance():getWnd(HallMain);
        -- if hallMain then
        --     scheduler.performWithDelayGlobal(function ()
        --         hallMain:getEnterCode();
        --     end, 0.5);
        -- end
        Log.i("------MainScene:onEnterForeground");
        local hallMain = UIManager.getInstance():getWnd(HallMain);
        if hallMain then
            hallMain:joinRoomByScheme()
            hallMain:JoinRoomByXianLaiScheme()
        end
--    end
end

function MainScene:onExit()
    self:releaseSwallowTouchEvent()
    if self.tmpImg then self.tmpImg:setVisible(false) end
end

return MainScene
