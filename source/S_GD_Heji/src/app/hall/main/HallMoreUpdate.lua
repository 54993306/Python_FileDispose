-- 更新界面

local Delay = class("Delay")

HallMoreUpdate = class("HallMoreUpdate", UIWndBase);

function HallMoreUpdate:ctor(info)
    self.super.ctor(self, "hall/hallUpdate.csb", info);
    self.percent = 0
    --需要更新包的个数
    self.updateNumber = 0
    --已经更新的百分比
    self.updatetPercent = 0

    self.updatePath = WRITEABLEPATH.."update/"
    Log.i("self.updatePath........",self.updatePath)

end

local checkNewVersion = function(oldVersion, newVersion)
    if not oldVersion then return true end
    local oldVerTab = string.split(oldVersion, ".")
    local newVerTab = string.split(newVersion, ".")
    for i, v in ipairs(oldVerTab) do
        if not newVerTab[i] then
            return false
        elseif tonumber(v) > tonumber(newVerTab[i]) then
            return false
        elseif tonumber(v) < tonumber(newVerTab[i]) then
            return true
        end
    end
    return false
end

function HallMoreUpdate:onShow()
--
    local function tmpUpdatetData(tData)
        -- self:tmpUpdateFile(tData)
        self:iniDirectory()
    end
    self:updateFile(tmpUpdatetData)
end

function HallMoreUpdate:analyzeVersion()
    Log.i("HallMoreUpdate:analyzeVersion........")
     --下载的包个个数
     self.m_updteIndex = 1
     --所有的版本
     self.m_updateVersion = {}
     self.m_netWorkError = 0
     self.m_errorIndex = 0

     self:tmpUpdateFile()
end
function HallMoreUpdate:analyzeString(strText)
    local retV = {};
    if (strText == nil or strText == "" ) then return retV end
    local retTable = Util.split(strText,"%.")

    return retTable
end
function HallMoreUpdate:tmpUpdateFile(tData)
    if not tData then
        tData = self.m_tData
    end
    self.m_updateVersion = tData.version
    if not self.m_updateVersion or #self.m_updateVersion <= 0 then
        -- Toast.getInstance():show("没有m_updateVersion")
        self:onUpdateLogin()
        return
    end
        local selfVersion = cc.UserDefault:getInstance():getStringForKey("moreupdate-version", VERSION)
        if self:checkVersion(1,self:analyzeString(VERSION),self:analyzeString(selfVersion)) then
            selfVersion = VERSION
        end
        -- Toast.getInstance():show( string.format("selfVersion....%s",selfVersion))
        local  version = cc.UserDefault:getInstance():getStringForKey("current-version-codezd", VERSION)
        cc.UserDefault:getInstance():setStringForKey("current-version-codezd", nil)
        cc.UserDefault:getInstance():setStringForKey("downloaded-version-codezd",nil)
        Log.i("selfVersion........",selfVersion,self.m_updateVersion)
        local tmpIndex = false
        for i, v in pairs(self.m_updateVersion) do
            local verTable = self:analyzeString(v)
            local selfVerTable = self:analyzeString(selfVersion)
            local index = i
            tmpIndex = false
            for j = 1,#verTable do
                if not selfVerTable[j] then
                    selfVerTable[j] = 0
                end
                if tonumber(verTable[j]) > tonumber(selfVerTable[j]) then
                    self.updateNumber = #self.m_updateVersion - self.m_updteIndex + 1
                    self.m_updteIndex = index
                --  Toast.getInstance():show("开始更新")
                    Log.i("开始更新.....",verTable,selfVerTable,verTable[j],selfVerTable[j])
                    tmpIndex = true
                    -- self.m_pWidget:setOpacity(255)
                    self:updateZip()
                    return
                elseif tonumber(verTable[j]) < tonumber(selfVerTable[j]) then
                    Log.i("没有小版本....")
                    break
                end
            end
            -- end
            -- forIndex(1)
            if tmpIndex then
                Log.i("已经开始更新了2222222")
                break
            else
            if i == table.nums(self.m_updateVersion) then
                Log.i("没有更新")
                -- Toast.getInstance():show("没有更新")
                self:onUpdateLogin()
                break
            end
        end

    end
end

function HallMoreUpdate:checkVersion(type,verTable,selfVerTable)
    local tmpIndex = false
    for j = type,#verTable do
        if not selfVerTable[j] then
            break
        end
        if tonumber(verTable[j]) > tonumber(selfVerTable[j]) then
            Log.i("开始更新.....",verTable,selfVerTable,verTable[j],selfVerTable[j])
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
function HallMoreUpdate:onComplete()
    if self.scheduler then
        scheduler.unscheduleGlobal(self.scheduler)
        self.scheduler = nil
    end
    self.m_pWidget:performWithDelay(function()
        UIManager.getInstance():popWnd(CommonDialog);
        self.m_pWidget:getParent():setVisible(true)
        UIManager.getInstance():popWnd(HallMoreUpdate)
    end,1)
end

function HallMoreUpdate:onUpdateLogin()
    -- self.m_pWidget:performWithDelay(function()
        if not tolua.isnull(self.m_pWidget) then
            self.m_pWidget:getParent():setVisible(true)
        end
        UIManager.getInstance():popWnd(CommonDialog);
        UIManager.getInstance():popWnd(HallMoreUpdate)
        self.m_data:onComplete()
    -- end,0.2)
end

function HallMoreUpdate:updateZip()
    if self.m_updteIndex > #self.m_updateVersion  then
        -- Toast.getInstance():show( string.format("self.m_updteIndex%s...%s",self.m_updteIndex,#self.m_updateVersion))
        self:onUpdateLogin()
        return
    end
    self.m_pWidget:getParent():setVisible(true)
    -- 下载错误回调
    local function onError(errorCode)
        self:onError(errorCode)
    end
     -- 进度更新回调
     local function onProgress( percent )
        self:onProgress(percent)
     end
      -- 下载成功方法回调
    local function onSuccess()
        self:onSuccess()
    end

    local url = string.format( "%s/%s/%s/game.zip",_HotMoreLinkURL,APP_NAME_PATCH,self.m_updateVersion[self.m_updteIndex])
    local versionFile = string.format( "%s/%s/%s/version.ini?timestampvalue=%s",_HotMoreLinkURL,APP_NAME_PATCH,self.m_updateVersion[self.m_updteIndex],os.time())
    local assetsManager  = cc.AssetsManager:new(url,versionFile,self.updatePath)

    assetsManager:retain()
    -- 设置一系列委托
    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )

    assetsManager:setConnectionTimeout(3)-- 设置连接超时
    assetsManager:update()
end

function HallMoreUpdate:onProgress(percent)
    if not self.updatetPercent or not percent or not self.updateNumber then
        return
    end

    -- 显示下载进度
    local data = {}
    data.type = 1
    local pro = (self.updatetPercent + percent/(self.updateNumber)/2)
    if tolua.isnull(self.pb) then
        self.pb = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb");
    end
    if not tolua.isnull(self.pb) and pro < self.pb:getPercent() then
        pro = self.pb:getPercent()
    end
    if pro > 100 and self.m_updteIndex < #self.m_updateVersion then
        pro = pro%100
    end
    data.pro = pro--string.format("downloading %d%%",percent)
    data.banben = self.m_updateVersion[self.m_updteIndex]
    self:upCallBack(data)

    local percent = tonumber(string.format("%.2f",self.pb:getPercent()))
    local updatePer = tonumber(string.format("%.2f",(((self.m_updteIndex)/self.updateNumber) * 100)/2))
    Log.i("self.pb:getPercent()........",percent, updatePer,self.m_updteIndex)
    if not tolua.isnull(self.pb) and (percent >= updatePer or updatePer >= 100) then
        Log.i("解压更新....")
        self:decompressed("progress")
    end
end
function HallMoreUpdate:onSuccess()
    -- Toast.getInstance():show(string.format("更新成功%s",self.m_updateVersion[self.m_updteIndex]))
    Log.i("更新完成....",self.m_updateVersion[self.m_updteIndex])
    cc.UserDefault:getInstance():setStringForKey("moreupdate-version", self.m_updateVersion[self.m_updteIndex])
    if self.scheduler then
        scheduler.unscheduleGlobal(self.scheduler)
        self.scheduler = nil
    end
    self.updatetPercent = ((self.m_updteIndex)/self.updateNumber) * 100
    self.m_updteIndex = self.m_updteIndex + 1
    if self.m_updteIndex <= #self.m_updateVersion then
        self:updateZip(self.m_updateVersion,self.m_updteIndex)
    else
        if not tolua.isnull(self.pb) and self.pb:getPercent() < 100 then
            self:decompressed(2)
        else
            self:onLogin()
        end

    end
end

function HallMoreUpdate:onLogin()
    local data = {}
    data.type = 3
    self:upCallBack(data)
    self:setSearchPath()
    self:onComplete()
    cc.UserDefault:getInstance():setStringForKey("current-version-codezd", self.m_updateVersion[#self.m_updateVersion])
end

function HallMoreUpdate:onError(errorCode)
    Log.i("下载错误",errorCode)
    -- 没有新版本
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        -- progressLable:setString("no new version")
        -- Toast.getInstance():show("下载错误   没有新版本")
        self.updatetPercent = ((self.m_updteIndex)/self.updateNumber) * 100
        self.m_updteIndex = self.m_updteIndex + 1
        cc.UserDefault:getInstance():setStringForKey("downloaded-version-codezd",nil)
        self:updateZip()
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        -- 网络错误
        -- Toast.getInstance():show("网络错误")
        if self.scheduler then
            scheduler.unscheduleGlobal(self.scheduler)
            self.scheduler = nil
        end
        if self.m_errorIndex > 0 then
            self:netWorkLink()
        else
            self:conglian()
        end
    elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
        Toast.getInstance():show("下载错误")
        self:onComplete()
    elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
        if self.scheduler then
            scheduler.unscheduleGlobal(self.scheduler)
            self.scheduler = nil
        end
        if self.m_errorIndex > 0 then
            local data = {}
            data.content = "下载错误，请重试"
            data.closeStr = "重试"
            self:netWorkLink(data)
        else
            self:conglian()
        end
    end
end

function HallMoreUpdate:netWorkLink(mData)
    if self.m_updteIndex > #self.m_updateVersion then
        return
    end
    self.m_errorIndex = 0
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.content = mData.content or "网络异常请检测网络";
    if self.m_netWorkError < 2 then
        data.closeStr = mData.closeStr or "重连"
    else
        data.closeStr = "退出"
        self.m_netWorkError = 3
        -- self.m_errorIndex = 3
    end
    data.yesCallback = function()
        self:conglian()
    end
    data.closeCallback = function ()
        self:conglian()
        self.m_netWorkError = self.m_netWorkError +1
    end
    data.canKeyBack = false
    UIManager.getInstance():pushWnd(CommonDialog, data);
    LoadingView.getInstance():hide()
end

function HallMoreUpdate:conglian()
    -- if self.m_errorIndex < 3 then
        self.m_errorIndex = self.m_errorIndex + 1
    -- else
    --     self.m_errorIndex = 0
    -- end
    if self.m_netWorkError <= 2 then
        self.m_pWidget:performWithDelay(function()
            cc.UserDefault:getInstance():setStringForKey("downloaded-version-codezd",nil)
            self:updateZip()
        end,0.5)
    else
        -- MyAppInstance:exit()
        self:onComplete()
    end
end

function HallMoreUpdate:decompressed(type)
    Log.i("开始解压进度")
    if self.scheduler then
        scheduler.unscheduleGlobal(self.scheduler)
        self.scheduler = nil
    end
    local updatePro = ((self.m_updteIndex)/self.updateNumber) * 100
    Log.i("updatePro......",updatePro,self.pb:getPercent())

    local pro = updatePro - self.pb:getPercent()
    math.randomseed(os.time())
    self.scheduler = scheduler.scheduleGlobal(function()
        if self.pb then
            Log.i("开始解压进度",self.pb:getPercent())
        end
        if self.pb and self.pb:getPercent() < updatePro and self.pb:getPercent() < 100 then
            Log.i("解压 更新",(updatePro/100))
            -- self.pb:setPercent(self.pb:getPercent() + 0.1)
            local random = math.random(5);
            if random == 1 then
                return
            end
            -- 显示下载进度
            local data = {}
            data.type = 1
            data.pro = self.pb:getPercent() + (updatePro/1000)--string.format("downloading %d%%",percent)
            data.banben = self.m_updateVersion[self.m_updteIndex]
            self:upCallBack(data)
        else
            scheduler.unscheduleGlobal(self.scheduler)
            self.scheduler = nil
            if self.pb and self.pb:getPercent() >= 100 then
                if type == "progress" then
                    self.pb:setPercent(100)
                else
                    self:onLogin()
                end
            end
        end
    end, (1-updatePro/100)*0.005)
end

function HallMoreUpdate:iniDirectory()
    Log.i("HallMoreUpdate:iniDirectory")
    -- 删除文件夹操作失败后尝试次数
	--local removeTry = Delay.new(3)
	-- 删除文件夹有延迟，设置等待尝试次数
	-- local removeListenTry = Delay.new(5)
	-- -- 创建文件夹操作失败后尝试次数
	-- local createTry = Delay.new(3)
    local fileUtils = cc.FileUtils:getInstance()
    if device.platform ~= "ios" then
        local path = string.format("%s%s/%s",fileUtils:getWritablePath(),APP_NAME_PATCH,"update/")
        self.updatePath = cc.UserDefault:getInstance():getStringForKey("update_path", path)
    end
    Log.i("self.updatePath.........",self.updatePath)
    -- WRITEABLEPATH = self.updatePath
    self.mIsPrepare = false
    -- 创建文件夹
    local function createDir()
        -- 已存在此文件夹
        local isDirectory = fileUtils:isDirectoryExist(self.updatePath)
        Log.i("isDirectory22.....",isDirectory)
        if not isDirectory then
            local careteDirectory = fileUtils:createDirectory(self.updatePath)
            Log.i("careteDirectory33....",careteDirectory)
            if  careteDirectory then
                self.mIsPrepare = true
                self:analyzeVersion()
                cc.UserDefault:getInstance():setStringForKey("update_path", self.updatePath)
            else
                -- createTry:wheel(createDir)
                self.m_pWidget:performWithDelay(function ()
                    createDir()
                end,3)
            end
        else
            self:analyzeVersion()
            cc.UserDefault:getInstance():setStringForKey("update_path", self.updatePath)
        end
    end
    -- 如果存在此文件夹，删除掉
    local isDirectory = fileUtils:isDirectoryExist(self.updatePath)
    Log.i("isDirectory11.....",isDirectory)
    if isDirectorye then
        --如果存在文件夹则直接更新
        self:analyzeVersion()
    else
        createDir()
    end
end

function HallMoreUpdate:updateFile(onFinish)
    local url = string.format("%s/%s/version.ini?timestampvalue=%s",_HotMoreLinkURL,APP_NAME_PATCH, os.time())
    Log.i("url..........",url)
    local function onReponse(event)
        -- Log.i("onReponse event:",event)
        if not event or event.name ~= "completed" then
            if event.name == "failed" then
                -- onFinish(-1)
                self:onUpdateLogin()
            end

            return;
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            Log.i("onReponse code:",code)
            -- onFinish(-1)
            self:onUpdateLogin()
            return;
        end
        -- request:saveResponseData(self.updatePath);
        -- local path = string.format("%sversion.txt",self.updatePath)
        -- Log.i("保存地址...",path)
        -- request:saveResponseData(path );

        local responseString = request:getResponseString();
        Log.i("responseString........",responseString)
        local tData = json.decode(responseString);
        if not tData then
            Log.i("onReponse tData error appid:",tData)
            self:onUpdateLogin()
            return
        end
        Log.i("onReponse tData:",tData)
        self.m_data.version = self.m_data.version or "0.1"
        --先检测后台版本的位置
        local versionIndex = 0
        for i,v in pairs(tData.version) do
            v = v or "0.1"
            local tmpIndex = self:checkVersion(1,self:analyzeString(v),self:analyzeString(self.m_data.version))
            if tmpIndex then
                versionIndex = i
                break
            end
        end

        if self.m_data.whiteUpdate == 1 and versionIndex ~= 0 then
            --这个是屏蔽热更的逻辑（如果不在白名单内只能更新到线上填的版本）
            for i=#tData.version,versionIndex,-1 do
                table.remove( tData.version,i)
            end
        end
        self.m_tData = tData
        onFinish(tData)
    end
    local request = network.createHTTPRequest(onReponse, url, "GET");

    request:start();

end

function HallMoreUpdate:xmlRequest(url)
--[[ #param luaTable ]]--
    -- Log.s(str)
    -- do return end
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET", url)

    local function onReadyStateChange()
        local statusString = "Http Status Code:"..xhr.statusText
        print(statusString)
        print(xhr.readyState)
        Log.i(xhr.status)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send() -- 发送请求
    -- local sendStr = "username=".._logConfigParam.username .. "&info="..str
    -- local sendStr = "username=".. "xzj" .. "&info="..str
    -- xhr:send(sendStr)
end


function HallMoreUpdate:setSearchPath()
    Log.i("切换查找目录。。。。。。")
    local upPath = self.updatePath
    -- WRITEABLEPATH = upPath
    package.path = upPath .. "src/;" .. package.path;
    Log.i("重设路径....",upPath)
    local paths = cc.FileUtils:getInstance():getSearchPaths()
    table.insert(paths, 1, upPath .. "res/")
    table.insert(paths, 1, upPath .. "src/")
    cc.FileUtils:getInstance():setSearchPaths(paths);
    package.loaded["app.config"] = nil;
    package.loaded["app.common.NativeCall"] = nil;
    require("app.config");
    require("app.common.NativeCall");
end

function HallMoreUpdate:updatePro(info)
    Log.i("info.pro........",info.pro)
    if tolua.isnull(self.pb) then
        return
    end
    self.pb:setPercent(info.pro)
    self.lb_status:setString( string.format("下载%s中，请耐心等待...",""));
    if info.pro == 100 or self.pb:getPercent() == 100 then
        self.lb_status:setString("内容解压中，不消耗流量，请耐心等待，不要关闭游戏...");
    end
    self.lb_percent:setString(string.format("%s%%",string.format( "%0.1f",self.pb:getPercent())));

end

function HallMoreUpdate:updateUncompress(pro)
    -- self.pb:setPercent(pro)
    -- self.lb_status:setString("内容解压中，不消耗流量，请耐心等待，不要关闭游戏...");
    -- self.lb_percent:setString(string.format("%d%%",self.pb:getPercent()));

end

function HallMoreUpdate:upCallBack(info)
    if info.type == 1 then
        self:updatePro(info)
    elseif info.type == 3 then
        LoadingView.getInstance():hide();

        package.loaded["app.hall.HallConfig"] = nil;
        require("app.hall.HallConfig");
        package.loaded["app.config"] = nil;
        require("app.config");

        UIManager.getInstance():pushWnd(HallLogin);
    end
end

-- 响应窗口回到最上层
function HallMoreUpdate:onResume()
end

function HallMoreUpdate:onClose()

end

function HallMoreUpdate:onInit()
    -- self.m_pWidget:setCascadeOpacityEnabled ( true )
    -- self.m_pWidget:setOpacity(0)
    if IsPortrait then -- TODO
        self.m_pWidget:getParent():setVisible(false)
        local logoPath=GC_GameHallLogoPath or string.format("games/%s/hall/login/logo.png", GC_GameTypes[CONFIG_GAEMID])
        local img_logo = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_logo")
        img_logo:loadTexture(logoPath)
    else
        local bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"bg")
        local logo = display.newSprite(GC_GameHallLogoPath)
        local logoSize = logo:getContentSize()
        if logoSize.width > 300 then
            logo:setScale(0.5)
        else
            logo:setAnchorPoint(cc.p(1, 1))
        end
        logo:setAnchorPoint(0, 1)
        logo:setPosition(cc.p(42 ,display.height - 12))
        logo:addTo(bg)
    end

    self.lb_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_status");
    self.lb_percent = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_percent");
    self.pb = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb");
    self.pb:setVisible(true)               --用九宫格做进度条，当进度较小时，九宫格往回拉会有表现问题
    self.lb_status:setString("检测更新中...");
    self.pb:setPercent(0)
    self.lb_percent:setString("0%")
    self.lab_copyright = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_copyright");
    self.lab_publishcompany = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_publishcompany");
    self.lab_AuditingFileNo = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_AuditingFileNo");
    self.lab_ISBN = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_ISBN");

    self.lab_copyright:setString(_copyright and _copyright or "")
    self.lab_publishcompany:setString(_publishcompany and _publishcompany or "")
    self.lab_AuditingFileNo:setString(_AuditingFileNo and _AuditingFileNo or "")
    self.lab_ISBN:setString(_ISBN and _ISBN or "")

    if not IsPortrait then -- TODO
        -- 改变登录/ 更新/ 大厅 界面的logo
        local logo = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_22")
        if logo then
            Util.changeHallLogo(logo, 0, 3)
        end
    end

    ---- 测试方法
    -- local pro = 0
    -- self.m_pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
    --     local data = {}
    --     pro = pro + 1
    --     if pro > 100 then
    --         self.m_pWidget:stopAllActions()
    --         return
    --     end
    --     data.pro = pro
    --     self:updatePro(data)
    -- end))))
    self:haveNewBgimage()
end

-- 是否有新的背景图需要更新
function HallMoreUpdate:haveNewBgimage()
    if HANENEWBGIMAGE and PRODUCT_ID == 5542 then
        self.bg_image = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
        self.bg_image:loadTexture ( "hall/huanpi2/main_portrait/5542newbg.png" )
    end
end

--返回
function HallMoreUpdate:keyBack()

end
