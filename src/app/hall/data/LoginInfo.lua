--登录信息

LoginInfo = class("LoginInfo");

local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local ComFun = require("app.hall.wnds.account.AccountComFun")

LoginInfo.getInstance = function()
    if not LoginInfo.s_instance then
        LoginInfo.s_instance = LoginInfo.new();
    end

    return LoginInfo.s_instance;
end

LoginInfo.releaseInstance = function()
    if LoginInfo.s_instance then
        LoginInfo.s_instance:dtor();
    end
    LoginInfo.s_instance = nil;
end

LoginInfo.cleanup = function()
    LoginInfo.releaseInstance();
end

LoginInfo.ctor = function(self)
    self.m_LoginInfo = {};
    self.player_info = {}
    self._gameType = 0
    self._isLogin = false
    self._isServerMaintain = -1
    self.NewAccredit = false
end

LoginInfo.dtor = function(self)
    self.m_LoginInfo = {};
end

LoginInfo.setNewAccredit = function(self,accredit)
    self.NewAccredit = accredit
end

LoginInfo.isNewAccredit = function(self)
    return self.NewAccredit
end

--获取手机信息后连接服务器
LoginInfo.getPhoneInfoAndLink = function(self)
    local data = {};
    data.cmd = NativeCall.CMD_GET_PHONEINFO;
    NativeCall.getInstance():callNative(data, LoginInfo.getPhoneInfoCallBack, self);
end

function LoginInfo:getPhoneInfoCallBack(phoneInfo)
    Log.i("getPhoneInfoCallBack phoneInfo", phoneInfo);
    if phoneInfo then
        IMEI = phoneInfo.imei or IMEI;
        MODEL = phoneInfo.model or MODEL;
        REGION = phoneInfo.pu or REGION;
        SPID = phoneInfo.spid or SPID;
        local verTable = cc.UserDefault:getInstance():getStringForKey("moreupdate-version", VERSION)
        local selfVerTable = VERSION
        if self:checkVersion(1,self:analyzeString(verTable),self:analyzeString(selfVerTable)) then
            selfVerTable = verTable
        end
        VERSION = selfVerTable
        NETMODE = phoneInfo.netmode or NETMODE; -- 得到手机的联网状态
        JINDU = phoneInfo.longitude
        WEIDU = phoneInfo.latitude
        ENTERROOMCODE = phoneInfo.enterCode;
        PAGENAME = phoneInfo.packageName;
        if kLoginInfo.checkNetWork(NETMODE) and SocketManager.getInstance():getNetWorkStatus() ~= NETWORK_NORMAL then
            SocketManager.getInstance():openSocket();
        end
    end
end

function LoginInfo:analyzeString(strText)
    local retV = {};
    if (strText == nil or strText == "" ) then return retV end
    local retTable = Util.split(strText,"%.")
    
    return retTable
end

function LoginInfo:checkVersion(type,verTable,selfVerTable)
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

function LoginInfo:weChatLoginCallBack(info)
    Log.i("weChatLoginCallBack info", info);
    if info.errCode == 0 then
        HttpManager.getWeChatAccess_token(info);
        LoadingView.getInstance():show("正在登录，请稍后...");
    elseif info.errCode == -8 then
        LoadingView.getInstance():hide();
        Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
    else
        LoadingView.getInstance():hide();
    end
end

local function sendMyIP()
    local ip = kUserInfo:getUserNewIp()
    if type(ip) == "string" and string.len(ip) >= 7 then
        local data = {}
        data.ip = ip
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_IP, data)
    end
end

-- 手机号自动登陆
LoginInfo.autoLoginByPhone = function()
    Log.i("autoLoginByPhone")
    if ComFun.getPhone() == "0" or ComFun.getPassword() == "0" then
        Log.i("Phone : " .. ComFun.getPhone() .. "Password : " .. ComFun.getPassword())
        LoadingView.getInstance():hide();
        return false
    end
    local data = LoginInfo.initLoginData()
    data.phN = ComFun.getPhone()
    data.pa = crypto.md5(ComFun.getPassword())
    data.LoT = AccountStatus.PhoneLogin
    local ret = SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOGIN, data);
    if ret then
        sendMyIP()
    end
    return ret
end

-- 向服务器发送登陆请求
-- 返回值: bool 是否成功登录
LoginInfo.requestLogin = function(self, loginFromHallLogin, data)
    if not data then  data = LoginInfo.initLoginData(loginFromHallLogin) end

    Log.i("LoginInfo.requestLogin : " , data)
    data.LoT = AccountStatus.WechatLogin
    local loginType = cc.UserDefault:getInstance():getStringForKey("logintype", "0");
    if loginType == "phone" then  -- 手机登陆过则默认使用手机登陆，否则判断是否可以微信登陆
        return LoginInfo.autoLoginByPhone()
    end
    local ret = SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOGIN, data);
    if ret then
        sendMyIP()
    end
    return ret
end

-- 初始化其他数据
LoginInfo.initOtherData = function()
    if device.platform == "windows" then
        OS = 1;
    elseif device.platform == "mac" then
        OS = 2;
    elseif device.platform == "android" then
        OS = 1;
    elseif device.platform == "ios" then
        OS = 2;
        SPID = 10002;
    end
    if JINDU == nil or JINDU == "" then  -- 经度
        JINDU = 0
    end
    if WEIDU == nil or WEIDU == "" then  -- 纬度
        WEIDU = 0
    end
end

-- 初始化登陆的数据
LoginInfo.initLoginData = function(loginFromHallLogin)
    LoginInfo.initOtherData()
    local data = {}
    data.os = tostring(OS);             --     ##  os  int  设备os
    data.sp = tostring(SPID);           --     ##  sp  int  渠道号
    data.ve = tostring(VERSION);        --     ##  ve  String  版本号
    data.neF = tostring(NETMODE);       --     ##  neF  int  网络标识（1 wifi 2 mobile）
    data.ac = tostring(WX_OPENID);      --     ##  ac  String  账号名,即微信的openid
    data.niN = tostring(WX_NAME);       --     ##  niN  String  昵称
    data.se = tostring(WX_SEX) ~= "" and tostring(WX_SEX) or "1" ;         --     ##  se  int  性别
    data.he = tostring(WX_HEAD);        --     ##  he  String  头像
    data.wxP = tostring(WX_PR);
    data.wxC = tostring(WX_CITY);
    data.wxC0 = tostring(WX_CO);
    data.gaI = tostring(PRODUCT_ID);
    data.apI = tostring(WX_APP_ID);
    data.jiD = tonumber(JINDU)
    data.weD = tonumber(WEIDU)
    data.md = tostring(WX_HEADMD5)
    data.idC = tostring(_GameIdentification)
    data.unI = tostring(WX_UID)
    data.miID = tostring(MI_PUSH_ID)

    -- 对昵称进行容错处理, 避免昵称中带有双引号字符, 会导致邀请好友的数据出错, 以及登录丫丫语音崩溃
    data.niN = string.gsub(data.niN, "\"", "")

    if loginFromHallLogin then
        kLoginInfo:clearUserData()
    end
    return data
end

--登陆时清空保存的玩家数据
LoginInfo.clearUserData = function()
    kUserData_userInfo:release();
    kUserData_userExtInfo:release();
    kUserData_userPointInfo:release();
    kGiftData_logicInfo:release();
    kSystemConfig:release()
    kServerInfo:setAdTxt(nil)
    kServerInfo:dtor()
end


--网络检测
LoginInfo.checkNetWork = function(netMode)
    Log.i("------checkNetWork netMode", netMode);
    if netMode > 0 then
        return true;
    end
    scheduler.performWithDelayGlobal(function()
        local data = {};
        data.type = 2;
        data.title = "提示";
        data.yesTitle = "退出游戏";
        data.cancelTitle = "关闭";
        data.content = "网络未连接，请检查您的网络是否正常再进入游戏";
        data.yesCallback = function ()
            MyAppInstance:exit();
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
        LoadingView.getInstance():hide();
    end, 0.01);
end

--记录账号密码
LoginInfo.recordAccountInfo = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        for k, v in pairs(accountInfo) do
            if v.act == account.act and v.pwd == account.pwd then
                return;
            end
        end
    end
    table.insert(accountInfo, 1, account);
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    cc.UserDefault:getInstance():flush()
end

--保存账号信息(登录成功之后保存一下当前的账户信息.recordAccountInfo方法中有存储,但是在点击切换账户的时候会清空配置文件.这样就无法实现白名单的功能)
LoginInfo.saveAccountInfo = function(self, account)
    local accountInfo = {};
    table.insert(accountInfo, 1, account);
    local accountInfoStr = json.encode(accountInfo);
    Log.i("LoginInfo:saveAccountInfo accountInfoStr:",accountInfoStr)
    cc.UserDefault:getInstance():setStringForKey("account_temporary", accountInfoStr);
    cc.UserDefault:getInstance():flush()
end

--获取上一次登录的账户.只要登录成功过,那么一定有值
LoginInfo.getLastLoginAccount = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account_temporary");
    Log.i("LoginInfo:getLastLoginAccount accountInfoStr:",accountInfoStr)
    local accountInfo = {};
    if accountInfoStr then
        accountInfo = json.decode(accountInfoStr);
        if accountInfo and accountInfo[1] then
            return accountInfo[1];
        end
    end
    return nil
end

--记录游客账号密码
LoginInfo.recordVisitorAccountInfo = function(self, account)
    cc.UserDefault:getInstance():setStringForKey("visitor_account", account);
    cc.UserDefault:getInstance():flush()
end

LoginInfo.getVisitorAccount = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("visitor_account");
    return accountInfoStr;
end

--是否过审
LoginInfo.getIsReview = function(self, account)
    local isReview = cc.UserDefault:getInstance():getBoolForKey("reveiw_version", false);
    return isReview;
end

LoginInfo.setIsReview = function (self)
    cc.UserDefault:getInstance():setBoolForKey("reveiw_version", true);
    cc.UserDefault:getInstance():flush()
end

--是否新手
LoginInfo.getIsNewer = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("cf_isNewer", true);
end

LoginInfo.setIsNewer = function (self, isNewer)
    cc.UserDefault:getInstance():setBoolForKey("cf_isNewer", isNewer);
    cc.UserDefault:getInstance():flush()
end

--得到对局数
LoginInfo.getUserId = function(self,id)
    return cc.UserDefault:getInstance():getStringForKey(tostring(id),"-1");
end

LoginInfo.setUserId = function (self, id)
    cc.UserDefault:getInstance():setStringForKey(tostring(id), 1);
    cc.UserDefault:getInstance():flush()
end

--得到对局数
LoginInfo.getRoundNum = function(self)
    return cc.UserDefault:getInstance():getStringForKey("RoundNum","0");
end

LoginInfo.setRoundNum = function (self, num)
    cc.UserDefault:getInstance():setStringForKey("RoundNum", num);
    cc.UserDefault:getInstance():flush()
end

---玩家信息
LoginInfo.getPlayerInfo = function(self)
    return self.player_info or {}
end

LoginInfo.setPlayerInfo = function (self, info)
    self.player_info = info
end

LoginInfo.isFreeGetDiamound = function (self)
    local game_num_tag = 0
    local game_round_num = tonumber(kLoginInfo:getRoundNum())

    if game_round_num >= game_num_tag then
        return true
    else
        return false
    end
end

--记录账号密码并清除老账号
LoginInfo.recordAccountInfoAndClearOld = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        table.remove(accountInfo, 1);
        for k, v in pairs(accountInfo) do
            if v.act == account.act and v.pwd == account.pwd then
                return;
            end
        end
    end
    table.insert(accountInfo, 1, account);
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    cc.UserDefault:getInstance():flush()
end

--修改账号密码
LoginInfo.changeAccountPwd = function(self, account)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        for k, v in pairs(accountInfo) do
            if v.act == account.act then
                v.pwd = account.pwd;
                break;
            end
        end
    end
    local accountInfoStr = json.encode(accountInfo);

    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    cc.UserDefault:getInstance():flush()
end

LoginInfo.delAccountInfo = function(self, index)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        local data = table.remove(accountInfo, index);
        if data and data.status and data.status == 0 then
            local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime") or 0;
            vTime = vTime - 1;
            cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", vTime);
            cc.UserDefault:getInstance():flush()
        end
        local accountInfoStr = json.encode(accountInfo);
        cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
        cc.UserDefault:getInstance():flush()
    end
end

LoginInfo.changeAccountInfo = function(self, index)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= "" then
        accountInfo = json.decode(accountInfoStr);
        local firstInfo = accountInfo[1];
        accountInfo[1] = accountInfo[index];
        accountInfo[index] = firstInfo;
        local accountInfoStr = json.encode(accountInfo);
        cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
        cc.UserDefault:getInstance():flush()
    end
end

LoginInfo.getLastAccount = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    local accountInfo = {};
    if accountInfoStr then
        accountInfo = json.decode(accountInfoStr);
        if accountInfo and accountInfo[1] then
            return accountInfo[1];
        end
    end
end

LoginInfo.getAccountRecord = function (self)
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account");
    if accountInfoStr and accountInfoStr ~= ""then
        local accountInfo = json.decode(accountInfoStr);
        return accountInfo;
    end
end

LoginInfo.clearAccountInfo = function(self)
    local accountInfo = {};
    local accountInfoStr = json.encode(accountInfo);
    cc.UserDefault:getInstance():setStringForKey("account", accountInfoStr);
    cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", 0);
    cc.UserDefault:getInstance():setIntegerForKey("VisitorActiveTime", 0);
    cc.UserDefault:getInstance():flush()
end

LoginInfo.recordVisitorRegister = function (self)
    local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime", 0);
    vTime = vTime + 1;
    cc.UserDefault:getInstance():setIntegerForKey("VisitorRegisterTime", vTime);
    cc.UserDefault:getInstance():flush()
end

LoginInfo.getVisitorRegisterTime = function (self)
    return cc.UserDefault:getInstance():getIntegerForKey("VisitorRegisterTime") or 0;
end

LoginInfo.recordVisitorActive = function (self)
    local vTime = cc.UserDefault:getInstance():getIntegerForKey("VisitorActiveTime") or 0;
    vTime = vTime + 1;
    cc.UserDefault:getInstance():setIntegerForKey("VisitorActiveTime", vTime);
    cc.UserDefault:getInstance():flush()
end

LoginInfo.getVisitorActiveTime = function (self)
    return cc.UserDefault:getInstance():getIntegerForKey("VisitorActiveTime", 0);
end

function LoginInfo:setIsLogin(login)
    self._isLogin = login
end

function LoginInfo:getIsLogin()
    return self._isLogin
end

LoginInfo.setHasResumeRoom = function(self, ty)
    self._gameType = ty or 0
end

function LoginInfo:checkHasResumeRoom()
    return self._gameType
end

function LoginInfo:setServerMaintainStatus(type_status)
    self._isServerMaintain = type_status
end

function LoginInfo:isServerMaintain()
    if self._isServerMaintain == 0 then
        return true
    end
    return false
end
kLoginInfo = LoginInfo.getInstance();
