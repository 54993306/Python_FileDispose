--------------
-- 登录界面

HallLogin = class("HallLogin", UIWndBase)

local fun = {}
local LocalEvent = require("app.hall.common.LocalEvent")
local Duty = require "app.hall.wnds.duty.Duty"
local crypto = require "app.framework.crypto"
local UmengClickEvent = require("app.common.UmengClickEvent")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local FileLog = require("app.common.FileLog")

local advertView_expPath = "10007_34030101_exp_"
local advertView_smallPath = "10007_34030101_small_"
local pngPath=".png"
local jpgPath=".jpg"

function HallLogin:ctor(info)
    FileLog.init(CACHEDIR)

    if IsPortrait then -- TODO
        if device.platform == "ios" then
        --第一次热更广告图点不开
            cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("__cc_touch_one_by_one")
        else

        end
        --切换账号时,清理掉内存中的图片缓存,否则,广告图有缓存,不会更新。
        self:removerSpriteFrameAndFile()
    end
    self.super.ctor(self, "hall/hallLogin.csb", info);
    SocketManager.getInstance():setUserDataProcesser(UserDataProcesser.new());
    self.m_socketProcesser = HallSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    cc.FileUtils:getInstance():addSearchPath(WRITEABLEPATH .. "update/");
    cc.FileUtils:getInstance():addSearchPath("res/hall"); --用来搜索字体的路径。减少包体大小。
    cc.FileUtils:getInstance():addSearchPath(WRITEABLEPATH .. "update/".."res/hall/");--用来搜索字体的路径。减少包体大小。
    self.Events = {}
    self.loadNum = 1
    self.m_connectedNet = false -- socket是否联通
    HttpManager.getLocalNetworkIP()
    self:initCompatible()
end

-- 获取兼容版本号
function HallLogin:initCompatible()
    COMPATIBLE_VERSION = 0 -- 兼容版本号
    if device.platform == "android" or device.platform == "windows" then
        COMPATIBLE_VERSION = 1
    else
        local data = {}
        data.cmd = NativeCall.CMD_GET_COMPATIBLE
        NativeCall.getInstance():callNative(data,function(info)
            COMPATIBLE_VERSION = tonumber(info.version) or 0
        end)
    end
end

--清理内存中的图片缓存,并且清除相应目录下的图片资源,使得切换账号时会重新回去网络最新图片。
function HallLogin:removerSpriteFrameAndFile()
    --登出时切换
    --删除内存中空闲的缓存帧,但是小图清理不掉,点击放大的大图倒是可以清理掉
    display.removeUnusedSpriteFrames()

    for i=0,4 do
        --删除缓存的小图
        local advertView_deletePath = CACHEDIR..advertView_expPath..i..pngPath
        cc.FileUtils:getInstance():removeFile(advertView_deletePath)

        advertView_deletePath = CACHEDIR..advertView_expPath..i..jpgPath
        cc.FileUtils:getInstance():removeFile(advertView_deletePath)

        --删除缓存的大图
        advertView_deletePath = CACHEDIR..advertView_smallPath..i..pngPath
        cc.FileUtils:getInstance():removeFile(advertView_deletePath)

        advertView_deletePath = CACHEDIR..advertView_smallPath..i..jpgPath
        cc.FileUtils:getInstance():removeFile(advertView_deletePath)

        --由于不能清理内存中小图的缓存,根据名字手动清理
        local advertView_exp_removePath = advertView_expPath..i..pngPath
        display.removeSpriteFrameByImageName(advertView_exp_removePath)

        advertView_exp_removePath = advertView_expPath..i..jpgPath
        display.removeSpriteFrameByImageName(advertView_exp_removePath)
    end

end

fun.testFun = function(self)
    local SelectServerWnd = require "app.hall.wnds.selectServer.SelectServerWnd"
    local wnd = UIManager:getInstance():pushWnd(SelectServerWnd)
    if wnd then
        wnd:setLogin(self)
    else
        Log.e("init SelectServerWnd error")
        return
    end

    local query = string.urlencode(DOCKER_NAME or "中心组项目")
    local hookFun = function(body)
        local urls = json.decode(body)
        wnd:refreshDockServerList(urls["urls"])
    end
    HttpManager.getURL(
        "http://192.168.9.101:80/container_info_list?project=" .. query .. "&branch=all_branch",
        hookFun
    )
end

function HallLogin:onShow()
    -- 清理全局变量
    _gameChatTxtCfg = nil

    self:onEnterGetWhiteLists()

    if device.platform == "android" or device.platform == "ios" then
        --选择服务器测试时不自动登录
        if _isChooseServerForTest then
            fun.testFun(self)
        else
            self:autoLogin()
        end
    else
        if _isChooseServerForTest then
            fun.testFun(self)
        else
            self:autoLogin()
        end
    end

    if IsPortrait then -- TODO
        if IS_YINGYONGBAO or (IS_IOS and not kLoginInfo:getIsReview()) then
            self.btn_login_visitor:setVisible(true)
            self.btn_login:setVisible(false)
            self.btn_phone:setVisible(false)
            self.isVisitor = true
        else
            self.btn_login_visitor:setVisible(false)
            self.btn_login:setVisible(true)
            self.btn_phone:setVisible(false)
            self.isVisitor = false

            --定位
            local data = {}
            data.cmd = NativeCall.CMD_GET_LOCATION
            NativeCall.getInstance():callNative(data)
        end
    else
        self.btn_phone:setVisible(false)
        if IS_YINGYONGBAO or (IS_IOS and not kLoginInfo:getIsReview()) then
            self.btn_login_img_txt:loadTexture("#1004740.png")
            self.isVisitor = true
        else
            self.btn_login_img_txt:loadTexture("hall/loginUI/img_txt_weichat.png")
            self.isVisitor = false

            --定位
            local data = {}
            data.cmd = NativeCall.CMD_GET_LOCATION
            NativeCall.getInstance():callNative(data)
        end
    end

    -- mipush
    local dataMiReq = {}
    dataMiReq.cmd = NativeCall.CMD_GET_XIAOMI_ID
    NativeCall.getInstance():callNative(dataMiReq, self.onMipushID, self)

    if IsPortrait then -- TODO
        local logoPath=GC_GameHallLogoPath or string.format("games/%s/hall/login/logo.png", GC_GameTypes[CONFIG_GAEMID])
        local img_logo = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_logo")
        img_logo:loadTexture(logoPath)
        img_logo:getLayoutParameter():setMargin({ left = 0, right = 0, top = 200, bottom = 0})
    else
        local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg")
        local logo = display.newSprite(GC_GameHallLogoPath)
        local logoSize = logo:getContentSize()
        if logoSize.width > 300 then
            logo:setScale(0.5)
        end
        logo:setAnchorPoint(0, 1)
        logo:setPosition(cc.p(42, display.height - 12))
        logo:addTo(bg)
    end

    kLoginInfo:setIsLogin(true)

    self:updateHelp()
end

-- 自动登录处理
function HallLogin:autoLogin()
    if self.m_data.isExit then
        return
    end
    local loginType = cc.UserDefault:getInstance():getStringForKey("logintype", "0");
    if loginType == "phone" then  -- 手机登陆过则默认使用手机登陆，否则判断是否可以微信登陆
        if ComFun.getPhone() == "0" or ComFun.getPassword() == "0" then
            Log.i("手机号自动登陆账号或密码为空 phone :" .. ComFun.getPhone() .. " pwd : " .. ComFun.getPassword())
            return
        end
        Toast.getInstance():show("手机号自动登陆...");
        self:wechatLogin("phone")
    else
        local lastAccount = kLoginInfo:getLastAccount()  -- 正常的自动登录流程
        if lastAccount then
            self.account = lastAccount.act
            self.pwd = lastAccount.pwd
            LoadingView.getInstance():show("正在连接服务器，请稍候...", 1000)
            self:wechatLogin()
        end
    end
end

-- 自动登录处理
function HallLogin:onMipushID(info)
    MI_PUSH_ID = info.id
    Log.i("com.xiao id 1----------", info)
    Log.i("com.xiao #id ----------", #MI_PUSH_ID)

    -- if #id > 0 then
        local data = {}
        data.miID = MI_PUSH_ID
        Log.i("com.xiao id 1----------", data)
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_IP, data)
    -- end
end

--不断刷新客服红点显示内容
function HallLogin:updateHelp()
    local hongdian = display.newSprite("real_res/1004749.png")
    local hdCs = hongdian:getContentSize()
    local kfCs = self.btn_kefu:getContentSize()
    self.btn_kefu:addChild(hongdian)
    hongdian:setPosition(cc.p(kfCs.width - 10, kfCs.height - hdCs.height / 2))
    hongdian:setName("hongdian")
    hongdian:setVisible(false)

    local update = cc.CallFunc:create(
        function()
            local data = {}
            data.cmd = NativeCall.CMD_KE_FU_REFRESH
            NativeCall.getInstance():callNative(data, self.kefuCallBack, self)
        end
    )
    self.btn_kefu:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2), update)))
    local listener = cc.EventListenerCustom:create(LocalEvent.HallCustomerService, handler(self, self.getKeFuHongDian))
    table.insert(self.Events, listener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function HallLogin:kefuCallBack(result)
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = result
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

-- @Table result {cmd = NativeCall.CMD_KE_FU_REFRESH, count = @int}
function HallLogin:getKeFuHongDian(event)
    local hongdianNum = math.floor(tonumber(event._userdata.count))
    local hongdian = self.btn_kefu:getChildByName("hongdian")
    if hongdian then
        if hongdianNum > 0 then
            hongdian:setVisible(true)
        else
            hongdian:setVisible(false)
        end
    else
        print("[ ERROR ] HallLogin:getKeFuHongDian by linxiancheng ")
    end
end

-- 响应窗口回到最上层
function HallLogin:onResume()
end

function HallLogin:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
    self.m_connectedNet = false

    table.walk(
        self.Events,
        function(event)
            cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
        end
    )
    self.Events = {}

    if self.m_updateWhiteListHandle then
        scheduler.unscheduleGlobal(self.m_updateWhiteListHandle)
    end
end

local function drawUnderline(node)
    local drawNode = cc.DrawNode:create()
    local color = node:getTextColor()
    local size = node:getContentSize()
    -- debugDraw(node)
    -- 2b4c01
    drawNode:drawLine(cc.p(0, 0), cc.p(size.width, 0), cc.c4f(1, 1, 1, 150 / 255))
    drawNode:setPosition(cc.p(0, 0))
    drawNode:setAnchorPoint(cc.p(0, 0))
    node:addChild(drawNode)
end

function HallLogin:onInit()
    self.btn_login = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_login")
    self.btn_login:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_phone = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_phone")
    self.btn_phone:addTouchEventListener(handler(self, self.onClickButton))
    --
    if IsPortrait then -- TODO
        self.btn_login_visitor = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_login_visitor")
        self.btn_login_visitor:addTouchEventListener(handler(self, self.onClickButton))
    else
        self.btn_login_img_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_txt")
    end
    --
    self.cb_agreement = ccui.Helper:seekWidgetByName(self.m_pWidget, "cb_agreement")
    self.cb_agreement:setSelected(true)

    self.btn_user = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_user")
    self.btn_user:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_applyAgent = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_applyAgent")
    self.btn_applyAgent:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_kefu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_kefu")
    self.btn_kefu:addTouchEventListener(handler(self, self.onClickButton))
    --版权信息
    local soft_Label = ccui.Helper:seekWidgetByName(self.m_pWidget, "soft_Label")
    soft_Label:setString(_gameSoftTitle)

    self.lab_version0 = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_version_0")
    self.lab_version1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_version_1")

    self:haveNewBgimage()

    if self.lab_version0 then
        self.lab_version0:setString("")
    end

    if self.lab_version1 then
        if IsPortrait then -- TODO
            self.lab_version1:setString(string.format("游戏版本号:%s",VERSION))
        else
            self.lab_version1:setString("游戏版本号:" .. "1.1.0" .. (GC_HALL_VERSION and ("_" .. GC_HALL_VERSION) or ""))
        end
    end

    local lab_proto = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_sure")
    drawUnderline(lab_proto)

    if IsPortrait then -- TODO
        self.lab_copyright = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_copyright");
        self.lab_publishcompany = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_publishcompany");
        self.lab_AuditingFileNo = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_AuditingFileNo");
        self.lab_ISBN = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_ISBN");

        self.lab_copyright:setString(_copyright and _copyright or "")
        self.lab_publishcompany:setString(_publishcompany and _publishcompany or "")
        self.lab_AuditingFileNo:setString(_AuditingFileNo and _AuditingFileNo or "")
        self.lab_ISBN:setString(_ISBN and _ISBN or "")
    else
        -- 改变登录/ 更新/ 大厅 界面的logo
        local logo = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_18")
        if logo then
            Util.changeHallLogo(logo, 0, 6)
        end
    end
end

-- 是否有新的背景图需要更新
function HallLogin:haveNewBgimage()
    if HANENEWBGIMAGE and PRODUCT_ID == 5542 then
        self.bg_image = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
        self.bg_image:loadTexture ( "real_res/1004665.png" )
    end

end

function HallLogin:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        if pWidget == self.btn_login or (IsPortrait and pWidget == btn_login_visitor) then -- TODO
            if not self.cb_agreement:isSelected() then
                Toast.getInstance():show("请勾选用户协议")
                return
            end
            LoadingView.getInstance():show("正在连接服务器，请稍候...", 1000)
            Util.disableNodeTouchWithinTime(pWidget)
            -- 网络超时自动连接
            scheduler.performWithDelayGlobal(function()
                self:onResponseNetImgFail()
                end, 3)
            if self.isVisitor then
                self:setVistorAccount()
                kLoginInfo:getPhoneInfoAndLink()
            else

                if device.platform == "ios" then
                local serverDayShareInfo = kServerInfo:getDayShareInfo()
                local data = {};
                data.cmd = NativeCall.CMD_WECHAT_SHARE;
                data.type = -1;
                NativeCall.getInstance():callNative(data, HallLogin.shareResult);
                end

                self:wechatLogin()
            end
        elseif pWidget == self.btn_login_visitor then
            self.isVisitor = true
            if not self.cb_agreement:isSelected() then
                Toast.getInstance():show("请勾选用户协议")
                return
            end
            LoadingView.getInstance():show("正在连接服务器，请稍候...", 1000)
            self:setVistorAccount()
            kLoginInfo:getPhoneInfoAndLink()
        elseif pWidget == self.btn_user then
            local data = {}
            data.title = "用户协议"
            data.type = Duty.DIALOG_TYPE.AGREEMENT
            UIManager.getInstance():pushWnd(Duty, data)
        elseif pWidget == self.btn_applyAgent then
            local wnd = UIManager.getInstance():pushWnd(Contact_us, {type = 1, title = "申请代理"})
            if self.btn_kefu and self.btn_kefu:getChildByName("hongdian") then
                wnd:setKfRed(self.btn_kefu:getChildByName("hongdian"):isVisible())
            end
        elseif pWidget == self.btn_kefu then
            local wnd = UIManager.getInstance():pushWnd(Contact_us)
            if self.btn_kefu and self.btn_kefu:getChildByName("hongdian") then
                wnd:setKfRed(self.btn_kefu:getChildByName("hongdian"):isVisible())
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.LoginKeFu)
        elseif pWidget == self.btn_phone then
            local function startLogin()
                local PhoneLogin = require "app.hall.wnds.account.PhoneLogin"
                UIManager:getInstance():pushWnd(PhoneLogin)
            end
            self:onLoginGetWhiteLists(startLogin)
        else
        end
    end
end

function HallLogin.shareResult(info)
    Log.i("shard button:", info);
    if(info.errCode ==0) then --成功
        Toast.getInstance():show("分享成功");
        local data = {}
        data.wa = 1
        SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end

-- 生成游客账号
function HallLogin:setVistorAccount()
    if not kLoginInfo:getVisitorAccount() or kLoginInfo:getVisitorAccount() == "" then
        WX_OPENID =
            "visitor" .. os.time() .. math.random(1000, 10000) .. math.random(1000, 10000) .. math.random(1000, 10000)
    else
        WX_OPENID = kLoginInfo:getVisitorAccount()
    end

    WX_NAME = device.model
end

--微信登录
function HallLogin:wechatLogin(loginType)
    local function startLogin()
        kLoginInfo:setHasResumeRoom(0)
        if device.platform == "ios" or device.platform == "android" then
            --if device.platform == "ios" then
            WX_OPENID = cc.UserDefault:getInstance():getStringForKey("openid")
            local refresh_token = cc.UserDefault:getInstance():getStringForKey("refresh_token")

            WX_NAME = cc.UserDefault:getInstance():getStringForKey("wx_name")
            WX_HEAD = cc.UserDefault:getInstance():getStringForKey("wx_head")
            WX_SEX = cc.UserDefault:getInstance():getStringForKey("wx_sex")
            WX_CO = cc.UserDefault:getInstance():getStringForKey("wx_co")
            WX_PR = cc.UserDefault:getInstance():getStringForKey("wx_pr")
            WX_CITY = cc.UserDefault:getInstance():getStringForKey("wx_city")
            WX_HEADMD5 = cc.UserDefault:getInstance():getStringForKey("wx_headmd5","")
            WX_UID = cc.UserDefault:getInstance():getStringForKey("union_id", "")
            -- 新增用于判断是否为热更后的包的标记，以后可以以WX_NAME 为判断基础
            local newPacket = cc.UserDefault:getInstance():getStringForKey("newPacket", "0");
            cc.UserDefault:getInstance():setStringForKey("logintype",loginType or "wechat")
            cc.UserDefault:getInstance():flush()
            kLoginInfo:setNewAccredit(false)
            if loginType == "phone" then
                kLoginInfo:getPhoneInfoAndLink()
                return
            end
            if not WX_NAME or WX_NAME == "" or newPacket == "0" then
                --cc.UserDefault:getInstance():setStringForKey("newPacket", "1");--防止用户跳转微信后不授权就返回游戏
                scheduler.performWithDelayGlobal(
                    function()
                        local data = {}
                        data.cmd = NativeCall.CMD_WECHAT_LOGIN
                        NativeCall.getInstance():callNative(data, LoginInfo.weChatLoginCallBack, kLoginInfo)
                    end,
                    0.1
                )
            else
                kLoginInfo:getPhoneInfoAndLink()
                if refresh_token and refresh_token ~= "" then
                    local info = {}
                    info.refresh_token = refresh_token
                    if IsPortrait then -- TODO
                        info.openid = openid
                    end
                    HttpManager.toRefreshWeChat_token(info)
                end
            end
        else
            cc.UserDefault:getInstance():setStringForKey("logintype",loginType or "wechat")
            cc.UserDefault:getInstance():flush()
            LoadingView.getInstance():show("正在连接服务器，请稍候...", 1000)
            kLoginInfo:getPhoneInfoAndLink()
        end
    end

    self:onLoginGetWhiteLists(startLogin)
end

function HallLogin:showServerTip(serverData, closeCallback)
    -- if self.showedServerTip then
    --     if closeCallback then closeCallback(serverData) end
    --     return
    -- end
    -- 显示维护
    local data = {}
    data.title = serverData.gameNotify.notifyTitle
    data.serverTips = serverData.gameNotify.notifyContent
    data.type = Duty.DIALOG_TYPE.SERVER_NOTICE
    data.closeCallback = closeCallback
    UIManager.getInstance():pushWnd(Duty, data)
    self.m_showedServerTip = true

    LoadingView.getInstance():hide()
    -- if self.m_showedServerTipHandle then scheduler.unscheduleGlobal(self.m_showedServerTipHandle) end
    -- self.m_showedServerTipHandle = scheduler.performWithDelayGlobal(function()
    --     Log.i("self.showedServerTip = false")
    --     self.showedServerTip = false
    --     end, 120)
end

function HallLogin:needShowServerTip(data, showStatus)
    -- dump(data)
    if not data then return end
    for i, v in pairs(showStatus) do
        if data.gameStatus == v then
            local gameNotify = data.gameNotify
            if not gameNotify then return false end
            local notifyStartTime = tonumber(gameNotify.notifyStartTime)
            return (notifyStartTime and notifyStartTime <= kServerInfo:getServerTime() / 1000) and data.gameNotify.notifyStatus == "open"
        end
    end
    return false
end

function HallLogin:needShowServerTip_Login(data, showStatus)
    -- dump(data)
    if not data then return end
    for i, v in pairs(showStatus) do
        -- if data.gameStatus == "update" then
        --     local gameNotify = data.gameNotify
        --     if not gameNotify then return false end
        --     return data.gameNotify.notifyStatus == "open"
        -- elseif data.gameStatus == "reading" then
        if data.gameStatus == "update" or data.gameStatus == "reading" then
            local gameNotify = data.gameNotify
            if not gameNotify then return false end
            local gameUpgradeTime = tonumber(data.gameUpgradeTime)
            return (gameUpgradeTime and gameUpgradeTime <= kServerInfo:getServerTime() / 1000) and data.gameNotify.notifyStatus == "open"
        end
    end
    return false
end

function HallLogin:isMaintain(data)
    -- if data.gameStatus == "update" then
    --     return true
    -- elseif data.gameStatus == "reading" then
    if data.gameStatus == "update" or data.gameStatus == "reading" then
        local gameUpgradeTime = tonumber(data.gameUpgradeTime)
        if self:inWhiteLists(data.gameWhiteList) then
            return false
        else
            return (gameUpgradeTime and gameUpgradeTime <= kServerInfo:getServerTime() / 1000)
        end
    end
    return false
end

-- 获取白名单
function HallLogin:onEnterGetWhiteLists()
    local onComplete = function(result, data)
        if result == 0 then
            if Util.table_eq(data, self.m_whiteListsData) then return end -- 拉取到相同的文件
            Log.i("update whiteListsData",data)
            self.m_whiteListsData = data
            self:setPhoneBtn()
            -- 判断是否需要提示维护
            if self:needShowServerTip(data, {"reading", "update"}) then
                self:showServerTip(data)
            end
            -- 启动维护倒计时提示
            kServerInfo:setServerNotifyData(data, true)
        end
    end
    self:getWhiteListsConfig(onComplete)
    self.m_updateWhiteListHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        Log.i("self.m_updateWhiteListHandle")
        self:getWhiteListsConfig(onComplete)
    end, 120, false)
end

-- 收到后台数据后重置按钮显示
function HallLogin:setPhoneBtn()
    if self.m_whiteListsData and self.m_whiteListsData.gameConfSwitch then
        if self.m_whiteListsData.gameConfSwitch.showPhoneLogin == "open" then  -- 从需求上看，按钮默认是被隐藏的
            self.btn_phone:setVisible(true)
            if not IsPortrait then
                self.btn_login:setPosition(cc.p(self.btn_login:getPositionX()- 200,self.btn_login:getPositionY()))
            end
        end

        if self.m_whiteListsData.gameConfSwitch.popupPhoneBind == "open" then
            if tostring(self.m_whiteListsData.gameConfSwitch.popupPhoneBindType) == "0" then
                kUserData_userExtInfo:setPhoneRegist(true)
            elseif tostring(self.m_whiteListsData.gameConfSwitch.popupPhoneBindType) == "1" then
                if kSettingInfo:getpopDay() ~= tostring(os.date("%d",os.time())) then
                    kUserData_userExtInfo:setPhoneRegist(true)
                    kSettingInfo:setpopDay(tostring(os.date("%d",os.time())))
                    cc.UserDefault:getInstance():flush()
                    -- print(kSettingInfo:getpopDay() )
                    -- kSettingInfo:getpopDay() .. " : " .. tostring(os.date("%d",os.time()))
                    -- Log.i("======>>>> setPhoneBtn :" , kSettingInfo:getpopDay() , tostring(os.date("%d",os.time())))
                end
            end
        end
    end
end

local function showDialog(sMsg, title)
    -- print(debug.traceback())
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.content = sMsg;
    data.yesCallback = function()
        MyAppInstance:exit()
    end
    data.closeCallback = function ()
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
    LoadingView.getInstance():hide()
end

-- 函数功能:检测白名单信息
-- onComplete: 检测完成回调
-- 返回值:  无
function HallLogin:checkWhiteLists(tData, onComplete)
    -- self.bCheckingWhiteList = true

    --如果游戏状态为在线.则检测白名单结束,返回ok.
    --这边修改为只要能登录则直接检测更新
    if not self:isMaintain(tData) then
        LoadingView.getInstance():hide()
        -- onComplete()
        -- Toast.getInstance():show("开始热更。。。")
        -- Log.i("开始进入热更")
        -- --调用热更新
        local data = {}
        data.neVDRL = tData.gameWhiteList
        data.newVersion = tData.gameWhiteList
        data.onComplete = onComplete
        if tData.updateWhiteList then
            data.version = tostring(tData.updateWhiteList.curVersion or 0.1)
            if tData.updateWhiteList.subVersion and table.nums(tData.updateWhiteList.subVersion) > 0 then
                local gamePach = Util.analyzeString_3(APP_NAME_PATCH)
                if table.nums(gamePach) > 0 then
                    for i,v in pairs(tData.updateWhiteList.subVersion) do
                        local gameName = GC_GameTypes[tonumber(v.playId)]
                        if gameName == gamePach[1] then
                            data.version = tostring(v.version or 0.1)
                        end
                    end
                end
            end
        else
            if not self:isMaintain(tData) then
                onComplete()
            elseif not self.m_showedServerTip then
                local sErrorMsg = "服务器正在维护！代码-003"
                showDialog(sErrorMsg)
            end
            return
        end
        data.whiteUpdate = self:isWhiteUpdateList(tData)
        UIManager.getInstance():pushWnd(HallMoreUpdate, data)
    elseif not self.m_showedServerTip then
        local sErrorMsg = "服务器正在维护！代码-003"
        showDialog(sErrorMsg)
    end
end

--检测当前账户是否在白名单
function HallLogin:inWhiteLists(gameWhiteList)
    gameWhiteList = gameWhiteList or {}

    -- 检测IP
    local ipList = gameWhiteList.ip or {}
    Log.i("ipList", ipList)
    Log.i("kUserInfo:getUserNewIp()", kUserInfo:getUserNewIp())
    for _, ip in ipairs(ipList) do
        if kUserInfo:getUserNewIp() == ip then
            return true
        end
    end
    return false
end

--检测当前账户是否在黑名单
function HallLogin:inBlackLists(userId)
    Log.i("HallLogin:inBlackLists", "userId: " .. tostring(userId) .. ", type: " .. type(userId))
    local bExist = false
    if not userId then
        Log.i("no userId!!!!!!!!!!!!!!!!")
        return bExist
    elseif type(self.m_whiteListsData) ~= "table" then
        Log.i("no whiteListsData!!!!!!!!!!!!!!!!")
        return bExist
    elseif type(self.m_whiteListsData.gameBlackList) ~= "table" then
        Log.i("no whiteListsData.gameBlackList!!!!!!!!!!!!!!!!")
        return bExist
    end
    local blackList = self.m_whiteListsData.gameBlackList.uid or {}
    Log.i("HallLogin:inBlackLists", "userId: " .. tostring(blackList) .. ", type: " .. type(blackList))
    -- blackList = {"3723376745", "3748606385"}
    for _, nUserId in ipairs(blackList) do
        if tostring(nUserId) == tostring(userId) then
            bExist = true
            break
        end
    end

    if bExist then
        -- 禁用登录按钮, 以等待socket接收服务器下发的数据, 否则下次连接服务器时, 会下发未接收完的数据
        Util.disableNodeTouchWithinTime(self.btn_login, 1)
        scheduler.performWithDelayGlobal(function()
                SocketManager.getInstance():closeSocket()
            end, 1)
        -- local sErrorMsg = string.format("您的账号（ID：%d）已被封停，时间 20XX 年 x 月 x 日 xx:xx-20XX 年 x 月 x 日 xx:xx。如有疑问，请联系客服。 ", userId)
        local sErrorMsg = "账号已被封停，如有疑问请联系客服。 "
        showDialog(sErrorMsg)
    end
    return bExist
end

function HallLogin:isWhiteUpdateList(data)
    --白名单控制（0未开启白名单，1开启白名单单未在白名单内，2开启白名单并在白名单内）
    local white = 0
    --白名单跟新
    if data.updateWhiteList then
    -- if data.updateWhiteList.status == "On" then
        white = 1
        -- 检测IP
        local ipList = data.updateWhiteList.ip or {}
        Log.i("ipList", ipList)
        Log.i("kUserInfo:getUserNewIp()", kUserInfo:getUserNewIp())
        for _, ip in ipairs(ipList) do
            if kUserInfo:getUserNewIp() == ip then
                white = 2
            end
        end

        local userId = data.updateWhiteList.uid or {}
        Log.i("userId......",userId,kUserInfo:getUserId())
        for i,id in pairs(userId) do
            if tostring(id) == tostring(kUserInfo:getUserId()) then
                white = 2
            end
        end
    -- end
    end

    --增加游戏登录ip白名单更新检测
    if white == 0 or white == 1 then
        if data.gameWhiteList then
            local ipList = data.gameWhiteList.ip or {}
            Log.i("ipList", ipList)
            Log.i("kUserInfo:getUserNewIp()", kUserInfo:getUserNewIp())
            for _, ip in ipairs(ipList) do
                if kUserInfo:getUserNewIp() == ip then
                    white = 2
                end
            end
        end
    end
    return white
end

function HallLogin:onLoginGetWhiteLists(onLogin)
    Log.i("HallLogin:onLoginGetWhiteLists")
    local onComplete = function(result, data)
        -- Log.i("onComplete " .. result, data)
        if data then
            self.m_whiteListsData = data
            self.m_showedServerTip = false
            -- 判断是否需要提示维护
            -- 若需要提示, 先弹框, 关闭后再进行白名单逻辑
            if self:needShowServerTip_Login(data, {"reading", "update"}) then
                self:showServerTip(data, function()
                        self:checkWhiteLists(data, onLogin)
                    end)
            else
                self:checkWhiteLists(data, onLogin)
            end
        else
            -- 提示
            local errMesg = "网络连接失败，请重试！代码-001";
            showDialog(errMesg)
        end
    end

    -- local onCheckNetWork = function(code)
        -- Log.i("onCheckNetWork", code)
        -- if code == 200 then
            if self.m_whiteListsData then
                onComplete(0, self.m_whiteListsData)
            else
                self:getWhiteListsConfig(onComplete)
            end
        -- else
            -- local errMesg = "网络异常，请检查您的网络状态"
            -- showDialog(errMesg)
        -- end
    -- end
    HttpManager.getLocalNetworkIP()
    -- Util.checkNetWork(onCheckNetWork)
end

-- 函数功能:请求cdn的白名单配置文件
-- onComplete: 请求完成回调
-- 返回值:  无
function HallLogin:getWhiteListsConfig(onComplete)
    local sRoot = _WhiteListConfigUrlRoot
    local url = string.format("%s/gameconf_%d.json",sRoot,PRODUCT_ID)
    -- local url = "http://192.168.7.105:8089/gameconf_4156.json"
    Log.i("HallLogin:getWhiteListsConfig url",url)
    local repeatTime = 3
    local function onFinish(nErrorCode,tData)
        if nErrorCode == -1 and repeatTime >= 1 then
            repeatTime = repeatTime - 1
            self:requestWhiteList(url, onFinish)
            return
        end
        if onComplete then
            onComplete(nErrorCode,tData)
        end
    end
    self:requestWhiteList(url, onFinish)
end

function HallLogin:requestWhiteList(url, onFinish)
    local function onReponse(event)
        -- Log.i("onReponse event:",event)
        if not event or event.name ~= "completed" then
            if event.name == "failed" then
                onFinish(-1)
            end
            return;
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            Log.i("onReponse code:",code)
            onFinish(-1)
            return;
        end
        local responseString = request:getResponseString();
        local tData = json.decode(responseString);
        if not tData or not tData.gameAppId then
            Log.i("onReponse tData error appid:",tData)
            onFinish(-1)
            return
        end
        if tData.gameAppId ~= ""..PRODUCT_ID then
            Log.i("onReponse gameAppId:",tData.gameAppId)
            onFinish(-1)
            return
        end
        -- Log.i("onReponse tData:",tData)
        onFinish(0,tData)
    end
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

--返回
function HallLogin:keyBack()
    local data = {}
    data.type = 2
    data.title = "提示"
    data.yesTitle = "退出"
    data.cancelTitle = "取消"
    data.content = "确定要退出游戏吗？"
    data.yesCallback = function()
        MyAppInstance:exit()
    end
    UIManager.getInstance():pushWnd(CommonDialog, data)
end

-- 网络连通
function HallLogin:onNetWorkConnected()
    Log.i("HallLogin:onNetWorkConnected", kLoginInfo:isNewAccredit(), self.m_connectedNet)
    self.m_connectedNet = true -- socket联通
    -- cc.UserDefault:getInstance():setStringForKey("wx_headmd5","")
    -- HttpManager.testmd5(WX_HEAD)
    -- cc.UserDefault:getInstance():setStringForKey("wx_head", WX_HEAD);
    if not kLoginInfo:isNewAccredit() then
        if IsPortrait then -- TODO
            self:onLoginGetWhiteLists(function ()
                if kLoginInfo:requestLogin(true) then
                    Log.i("HallLogin:onNetWorkConnected", "kLoginInfo:requestLogin")
                    LoadingView.getInstance():show("正在登录，请稍候...", 1000)
                end
            end)
        else
            if kLoginInfo:requestLogin(true) then
                Log.i("HallLogin:onNetWorkConnected", "kLoginInfo:requestLogin")
                LoadingView.getInstance():show("正在登录，请稍候...", 1000)
            end
        end
    end
end

-- 网络图片获取超时的处理
function HallLogin:onResponseNetImgFail()
    if not kLoginInfo:isNewAccredit() then return end -- 如果已经请求过登陆, 则返回

    Log.w(string.format("HallLogin:onResponseNetImgFail() IP: %s, HEAD: %s", kUserInfo:getUserNewIp(), WX_HEAD))

    WX_HEADMD5 = ""--"1" -- 图片下载默认错误形式
    cc.UserDefault:getInstance():setStringForKey("wx_headmd5",WX_HEADMD5)
    kLoginInfo:setNewAccredit(false)
    if IsPortrait then -- TODO
        if self.m_connectedNet  then
            self:onLoginGetWhiteLists(function ()
                if kLoginInfo:requestLogin(true) then
                    Log.i("HallLogin:onResponseNetImgFail", "kLoginInfo:requestLogin")
                    LoadingView.getInstance():show("正在登录，请稍候...", 1000)
                end
            end)
        end
    else
        if self.m_connectedNet and kLoginInfo:requestLogin(true) then
            Log.i("HallLogin:onResponseNetImgFail", "kLoginInfo:requestLogin")
            LoadingView.getInstance():show("正在登录，请稍候...", 1000)
        end
    end
end

function HallLogin:onResponseNetImg(fileName)
    Log.i("HallLogin:onResponseNetImg", fileName, self.m_connectedNet)
    if not kLoginInfo:isNewAccredit() then return end -- 如果已经请求过登陆, 则返回
    if fileName == kUserInfo:getUserId() .. ".jpg" or fileName == "md5.jpg" then
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        local isSuccess, errMsg = pcall(display.newSprite, headFile);
        if isSuccess then
            WX_HEADMD5 = crypto.md5file(headFile)
            cc.UserDefault:getInstance():setStringForKey("wx_headmd5",WX_HEADMD5)
            cc.UserDefault:getInstance():setStringForKey("newPacket", "1")
        else
            WX_HEADMD5 = ""--"1" -- 图片下载默认错误形式
            self.loadNum = self.loadNum + 1
            if self.loadNum < 4 then  -- 拉取三次失败的情况
                if WX_HEAD~= "" then
                    HttpManager.getNetworkImage(WX_HEAD, "md5.jpg");
                    return
                else
                    WX_HEADMD5 = ""--"2" -- 图片url为空
                end
            else
                WX_HEADMD5 = ""--"3"
            end
            cc.UserDefault:getInstance():setStringForKey("wx_headmd5",WX_HEADMD5)
        end

        kLoginInfo:setNewAccredit(false)
        if IsPortrait then -- TODO
            if self.m_connectedNet then
                self:onLoginGetWhiteLists(function ()
                    if kLoginInfo:requestLogin(true) then
                        Log.i("HallLogin:onResponseNetImg", "kLoginInfo:requestLogin")
                        LoadingView.getInstance():show("正在登录，请稍候...", 1000)
                    end
                end)
            end
        else
            if self.m_connectedNet and kLoginInfo:requestLogin(true) then
                Log.i("HallLogin:onResponseNetImg", "kLoginInfo:requestLogin")
                LoadingView.getInstance():show("正在登录，请稍候...", 1000)
            end
        end
    end
end

--登录返回
function HallLogin:onRepLogin(info)
    --##验证结果(0 - 验证失败  1 - 成功  2 服务器异常 4 版本已过期) su
    --## 结果描述 de
    --##当前版本号 ve
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog)
    if
        commonDialog and
            (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK or
                commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED)
     then
        LoadingView.getInstance():hide()
        return
    end
    LoadingView.getInstance():hide()
    Log.i("---------------onRepLogin" , info)
    if info.su == 1 or info.su == 5 then -- 登录成功
        if self:inBlackLists(info.usI) then
            return
        end -- 黑名单检测

        FileLog.onLogin(info.usI)

        if device.platform == "android" or device.platform == "ios" then
            --呀呀登录
            local data = {}
            data.cmd = NativeCall.CMD_YY_LOGIN
            local str = WX_OPENID or info.phN
            data.usI = info.usI .. "" .. str
            data.niN = info.niN
            NativeCall.getInstance():callNative(data)
        end
        ComFun.setPhone(info.phN)
        if self.isVisitor then
            if info.pa then
                kLoginInfo:recordVisitorAccountInfo(info.ac)
            end
            --跳转大厅
            UIManager.getInstance():replaceWnd(HallLoading)
        else
            if info.pa then
                local account = {}
                account.act = info.ac
                account.pwd = info.pa
                account.usi = info.usI
                kLoginInfo:recordAccountInfo(account)
                kLoginInfo:saveAccountInfo(account)
            end

            if _isForceUpdate then --强更
                self:startForceUpdate(_forceUpdateUrl,info.usI) --在GameConfig.lua 里定义
            else
                --跳转大厅
                UIManager.getInstance():replaceWnd(HallLoading)
                HttpManager.getLocalNetworkIP()
            end

        end
    elseif info.su == 4 then
        SocketManager.getInstance():closeSocket();
        self.m_connectedNet = false
        kLoginInfo:clearAccountInfo();
        cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
        cc.UserDefault:getInstance():setStringForKey("wx_name", "");
        cc.UserDefault:getInstance():setStringForKey("newPacket", "0");
        cc.UserDefault:getInstance():flush()
        --调用热更新
        local data = {}
        data.neVDRL = info.neVDRL
        data.newVersion = info.ve
        UIManager.getInstance():pushWnd(HallUpdate, data)
    elseif info.su == 9 then -- 弹出新app落地页的地址
        -- info.de   落地页的内容 以服务器发送的数据为准，点击跳转落地页。
        if _forceUpdateUrl then
            self:startForceUpdate(_forceUpdateUrl,info.usI)
        else
            self:startForceUpdate(info.neVDRL,info.usI)
        end
    else
        Toast.getInstance():show(info.de or "登录失败")
        local loginType = cc.UserDefault:getInstance():getStringForKey("logintype", "0");
        if loginType ~= "phone" then -- 手机登陆时，不关闭socket，关闭手机登陆页面时关闭socket
            SocketManager.getInstance():closeSocket()
            self.m_connectedNet = false
        end
    end
end
function HallLogin:startForceUpdate(updateUrl,usI)
    if updateUrl == nil or updateUrl == "" then
        updateUrl = _forceUpdateUrl --在config_package.lua里面定义
        if updateUrl == nil then
            Log.i("强更地址为空，请配置FORCE_UPDATE_URL字段！")
            return
        end
    end
    LoadingView.getInstance():hide()
    local data = {}
    data.type = 2
    data.title = "更新提示"
    data.yesStr = "点击前往"
    data.cancalStr = "退出游戏"
    data.content = _SpeedLabel or "亲爱的玩家，您需要更新我们最新版的应用才能创建新账号。"
    --data.backupLabel = usI --使用备用标签
    data.yesCallback = function()
        device.openURL(updateUrl)
        SocketManager.getInstance():closeSocket();
        self.m_connectedNet = false
        kLoginInfo:clearAccountInfo();
        cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
        cc.UserDefault:getInstance():setStringForKey("wx_name", "");
    end
    data.cancalCallback = function()
        if device.platform == "ios" then
            --UIManager.getInstance():popWnd(CommonDialog);
            SocketManager.getInstance():closeSocket();
            self.m_connectedNet = false
        else
            local data2 = {}
            data2.type = 1
            data2.content = "您将退出游戏"
            data2.keyBackCallback = function()
                MyAppInstance:exit()
            end
            UIManager.getInstance():pushWnd(CommonDialog, data2)
        end
    end
    UIManager.getInstance():pushWnd(CommonDialog, data)
end


HallLogin.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_LOGIN] = HallLogin.onRepLogin
}
