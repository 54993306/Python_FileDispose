--本地调用

NativeCall = class("NativeCall");

--获取手机信息
NativeCall.CMD_GET_PHONEINFO = 1001;
--切换屏幕
NativeCall.CMD_CHANGE_ORIENTAION = 1002;
--上传头像
NativeCall.CMD_CHANGE_HEADIMG = 1003;
--创建缓存路径
NativeCall.CMD_GETCACHE = 1004;
--获取电量信息
NativeCall.CMD_GETBATTERY = 1005;
--震动
NativeCall.CMD_SHAKE = 1006;
--微信分享
NativeCall.CMD_WECHAT_SHARE = 1007;
--用户协议
NativeCall.CMD_USER_AGREEMENT = 1008;
--复制到剪切板
NativeCall.CMD_CLIPBOARD_COPY = 1009;
--充值
NativeCall.CMD_CHARGE = 1010;
--获取当前屏幕是否为竖屏
NativeCall.CMD_IS_PORTRAIT =1011;
--微信登录
NativeCall.CMD_WECHAT_LOGIN = 1012;
--微信分享截屏
NativeCall.CMD_WECHAT_SHARE_SCREEN = 1013;
--信号强度
NativeCall.CMD_WECHAT_SIGNAL = 1014;
--呀呀登录
NativeCall.CMD_YY_LOGIN = 1015;
--开始录音
NativeCall.CMD_YY_START = 1016;
--停止录音
NativeCall.CMD_YY_STOP = 1017;
--播放录音
NativeCall.CMD_YY_PLAY = 1018;
--上传录音
NativeCall.CMD_YY_UPLOAD_SUCCESS = 1019;
--获取经纬度
NativeCall.CMD_LOCATION = 1020;
--关闭EditBox
NativeCall.CMD_CLOSEEDITBOX = 1021;
--获取链接传递的房间号
NativeCall.CMD_GET_ENTERCODE = 1022;
--播放录音结束
NativeCall.CMD_YY_PLAY_FINISH = 1023;
--版本更新
NativeCall.CMD_UPDATE_VERSION = 1024;
--umeng统计(type：1登录，2退出，3事件统计)
NativeCall.CMD_UMENG_LOGIN_OFF = 1025;
--打开一个url
NativeCall.CMD_OPEN_URL = 1026;
--打开客服
NativeCall.CMD_KE_FU = 1027;
--注册客服消息数量提示
NativeCall.CMD_KE_FU_REFRESH = 1028;
--打开微信
NativeCall.CMD_OPEN_WEIXIN = 1029;

--获取定位
NativeCall.CMD_GET_LOCATION = 1030;

--分享图片
NativeCall.CMD_SHARE_PICTURE = 1031;

-- 拉取微下载链接
NativeCall.CMD_PULL_SCHEMEDATA = 1032;
-- 闲聊分享分享图片
NativeCall.CMD_XIANLIAO_SHARE_PICTURE = 1033;
-- 闲聊分享分享房间
NativeCall.CMD_XIANLIAO_SHARE_ROOM = 1034;
-- 闲聊分享分享文字
NativeCall.CMD_XIANLIAO_SHARE_TEXT = 1035;
-- 拉取闲聊房间数据
NativeCall.CMD_PULL_XIANLIAO_DATA = 1036;
-- 获取兼容版本号
NativeCall.CMD_GET_COMPATIBLE = 1037;
--检查文件是否存在
NativeCall.CMD_CHECKFILEEXIST = 1050   
-- 微信系统分享
NativeCall.CMD_WECHAT_SHARE_SYSTEM = 1051
-- 获取MiPush ID 
NativeCall.CMD_GET_XIAOMI_ID = 1052

NativeCall.CDM_JS_WEB_INTERFACE = 1053
--停止播放录音
NativeCall.CMD_YY_STOP_PLAY = 1060

NativeCall.Events = {
    NetStateChange = "onNetStateChange", -- 网络改变
    YYCallFuncChange = "isYYCallFuncChange",    --丫丫语音监听
    YYCallFuncFinish = "isYYCallFuncFinish",    --丫丫结束监听
}

NativeCall.getInstance = function()
    if not NativeCall.s_instance then
        NativeCall.s_instance = NativeCall.new();
    end

    return NativeCall.s_instance;
end

function NativeCall:ctor()
    self.m_callbacks = {};
end

function NativeCall:callNative(data, callback, obj)
    data = checktable(data);
    if callback then
        local func_obj = {};
        func_obj.func = callback;
        func_obj.obj = obj;
        self.m_callbacks[data.cmd] = func_obj;
    end

    if device.platform == "android" then
        -- Java 类的名称
        local className = "org/cocos2dx/lua/AppActivity";
        -- 调用 Java 方法需要的参数
        local dataString = json.encode(data);
        local args = {dataString};

        if data.cmd == NativeCall.CMD_YY_LOGIN then
            table.insert(args, NativeCallyyLogin);
            -- 调用 Java 方法
            luaj.callStaticMethod(className, "luaCall", args);
            return;
        end

        if callback then
            table.insert(args, PlatformCallLua);
            -- 调用 Java 方法
            luaj.callStaticMethod(className, "luaCall", args);
        else
            luaj.callStaticMethod(className, "luaCall1", args);
        end

    elseif device.platform == "windows" or device.platform == "mac" then
        if callback then
            self:windowsCallLua(data, callback, obj);                    -- 在windows上模拟调用实现
        end
    elseif device.platform == "ios" then
        if data.cmd == NativeCall.CMD_GET_PHONEINFO then
            if callback then
                scheduler.performWithDelayGlobal(function()
                    data.callback = PlatformCallLua
                    luaoc.callStaticMethod("RootViewController", "getLocation", data);
                end, 0.5);
            end
        elseif data.cmd == NativeCall.CMD_CHANGE_ORIENTAION then
            if data.orient == 1 then
                local data1 = {};
                data1.orient = 1;
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerV", data1);
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerH", data);

            elseif data.orient == 2 then
                local data1 = {};
                data1.orient = 2;
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerH", data1);
                luaoc.callStaticMethod("RootViewController", "changeRootViewControllerV", data);
            end
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShard", data);
        elseif data.cmd == NativeCall.CMD_CHANGE_HEADIMG then
            Log.i("开始选择图片......")
            luaoc.callStaticMethod("SendMsgWXRequest", "sendPictureView", data);
        elseif data.cmd == NativeCall.CMD_CHARGE then
            data.callback = PlatformCallLua
            Log.i("--wangzhi--调用支付--")
            luaoc.callStaticMethod("MXWechatPayHandler", "jumpToWxPay", data);
        elseif data.cmd == NativeCall.CMD_USER_AGREEMENT then
            luaoc.callStaticMethod("AppController", "showUserAgreement", data);
        elseif data.cmd == NativeCall.CMD_GETBATTERY then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "deviceLevel", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SIGNAL then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "getNetWorkState", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_LOGIN then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXLogin", data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE_SCREEN then
            data.callback = PlatformCallLua
            data.path = CACHEDIR .. "screen.jpg";
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShareScreen", data);
        elseif data.cmd == NativeCall.CMD_LOCATION then
            scheduler.performWithDelayGlobal(function()
                data.callback = PlatformCallLua
                luaoc.callStaticMethod("RootViewController", "getLocation", data);
            end, 0.5);
        elseif data.cmd == NativeCall.CMD_GET_ENTERCODE then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "getEnterCode", data);
        elseif data.cmd == NativeCall.CMD_YY_LOGIN then
            local func_obj = {};
            func_obj.func = NativeCallyyLogin;
            self.m_callbacks[NativeCall.CMD_YY_LOGIN] = func_obj;

            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "yayaLogin", data);
        elseif data.cmd == NativeCall.CMD_YY_START then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "yayaStart", data);
        elseif data.cmd == NativeCall.CMD_YY_STOP then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "yayaStop", data);
        elseif data.cmd == NativeCall.CMD_YY_PLAY then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "yayaPlay", data);
        elseif data.cmd == NativeCall.CMD_YY_STOP_PLAY then
            data.callback = NativeCallLua
            luaoc.callStaticMethod("AppController", "yayaStopPlay", data);
        elseif data.cmd == NativeCall.CMD_UPDATE_VERSION then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "download", data);
        elseif data.cmd == NativeCall.CMD_YY_UPLOAD_SUCCESS then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "getYYUploadStatus", data);
        elseif data.cmd == NativeCall.CMD_YY_PLAY_FINISH then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController", "getYYPlayStatus", data);
        elseif data.cmd == NativeCall.CMD_UMENG_LOGIN_OFF then
            data.callback = PlatformCallLua;
            luaoc.callStaticMethod("AppController", "getUMData", data);
        elseif data.cmd == NativeCall.CMD_SHAKE then
            data.callback = NativeCall;
            luaoc.callStaticMethod("AppController","getShock",data);
        elseif data.cmd == NativeCall.CMD_KE_FU then
            data.callback = NativeCall;
            luaoc.callStaticMethod("SendMsgWXRequest","getQYSDK",data);
        elseif data.cmd == NativeCall.CMD_CLIPBOARD_COPY then
            data.callback = NativeCall;
            luaoc.callStaticMethod("RootViewController","getCopy",data);
        elseif data.cmd == NativeCall.CMD_KE_FU_REFRESH then
            data.callback = NativeCall;
            luaoc.callStaticMethod("RootViewController","getRedPoint",data);
        elseif data.cmd == NativeCall.CMD_OPEN_WEIXIN then
            data.callback = NativeCall;
            local res = luaoc.callStaticMethod("RootViewController","openWX",data);
            if res == false then -- 兼容老麻将
                device.openURL("weixin://")
            end
        elseif data.cmd == NativeCall.CMD_GET_LOCATION then
            data.callback = NativeCall;
            luaoc.callStaticMethod("SendMsgWXRequest","getLocation",data);
        elseif data.cmd == NativeCall.CMD_SHARE_PICTURE then
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("SendMsgWXRequest", "sendWXShareScreen", data);   
        elseif data.cmd == NativeCall.CMD_CHECKFILEEXIST then  --检查文件是否存在
            data.callback = PlatformCallLua 
            luaoc.callStaticMethod("RootViewController","imageIsExists",data);
        elseif data.cmd == NativeCall.CMD_GETCACHE then  --返回路径
            data.callback = PlatformCallLua 
            luaoc.callStaticMethod("RootViewController","getFilePath",data);
        elseif data.cmd == NativeCall.CMD_WECHAT_SHARE_SYSTEM then
            data.callback = NativeCall;
            luaoc.callStaticMethod("SendMsgWXRequest","iosShareWX",data);
        elseif data.cmd == NativeCall.CMD_OPEN_URL then
            if data.url then
                data.callback = NativeCall;
                device.openURL(data.url)
            end
        elseif data.cmd == NativeCall.CMD_XIANLIAO_SHARE_PICTURE then  -- 闲聊分享分享截图
            -- shareUrlImage 分享网络图片
            data.callback = {}
            data.path = CACHEDIR .. "screen.jpg";
            luaoc.callStaticMethod("XianLiaoController","shareDataImage",data);
        elseif data.cmd == NativeCall.CMD_XIANLIAO_SHARE_ROOM then  -- 闲聊分享分享房间
            data.callback = {}
            luaoc.callStaticMethod("XianLiaoController","shareGame",data);
        elseif data.cmd == NativeCall.CMD_XIANLIAO_SHARE_TEXT then  -- 闲聊分享分享文字
            data.callback = {}
            luaoc.callStaticMethod("XianLiaoController","shareText",data);
        elseif data.cmd == NativeCall.CMD_PULL_XIANLIAO_DATA then  -- 拉取闲聊房间数据
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController","getXianLiaoScheme",data);
        elseif data.cmd == NativeCall.CMD_GET_COMPATIBLE then       -- 获取兼容版本号
            data.callback = PlatformCallLua
            luaoc.callStaticMethod("AppController","getCompatibleVersion",data);
        end

    end
end


function NativeCall:addWebInterface(data, callback, obj)

    if device.platform == "android" then
        -- Java 类的名称
        local className = "org/cocos2dx/lua/AppActivity";
        local webCB = function (arg)
            -- print("web ret",arg)
            UIManager:getInstance():popWnd(ActivityDialog)
		end
	    local args = {		    
		   webCB 
		}  --传参
		if callback and type(callback)=="function" then
			args[#args] = callback
        end
        print("传入js回调方法")
        -- Toast.getInstance():show("传入回调")
        -- 调用 Java 方法
        luaj.callStaticMethod(className, "addWebInterface", args);
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("EasyJSWebView", "addWebInterface", data);
    else
        callback("{\"activityType\":\"1","pram1\":{}}")
    end
end

function NativeCall:callLua(args)
    local data = {}
    if type(args) == "table" then
        data = args
    else
        data = json.decode(args);
    end
    local func_obj =  self.m_callbacks[data.cmd];
    if func_obj then
        --ios平台下的充值返回立刻调用，不走gl线程切换
        if args.cmd == NativeCall.CMD_CHARGE and device.platform == "ios" then
            if func_obj.obj then
                func_obj.func(func_obj.obj, data);
            else
                func_obj.func(data);
            end
        elseif data and data.cmd == NativeCall.CMD_GETCACHE then
            if func_obj.obj then
                func_obj.func(func_obj.obj, data);
            else
                func_obj.func(data);
            end
        else
            scheduler.performWithDelayGlobal(function()
                if func_obj.obj then
                    func_obj.func(func_obj.obj, data);
                else
                    func_obj.func(data);
                end

                --self.m_callbacks[data.cmd] = nil;
                --func_obj = nil;

            end, 0.1);
        end
    end
end

function NativeCall:windowsCallLua(data, callback, obj)
    local args = {};
    if data.cmd == NativeCall.CMD_GET_PHONEINFO then

        args.cmd = NativeCall.CMD_GET_PHONEINFO;
        args.imei = IMEI;
        args.model = MODEL;
        args.pu = REGION;
        args.spid = SPID;
        args.version = VERSION;
        args.netmode = NETMODE;
        args.latitude = WEIDU
        args.longitude = JINDU
        args.packageName = "com.FtOuYuSQ.tNXoWbdrDV.vANhqmm"
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_GETBATTERY then
        args.cmd = NativeCall.CMD_GETBATTERY;
        args.baPro = 80;
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_WECHAT_SHARE then
        args.cmd = NativeCall.CMD_WECHAT_SHARE;
        args.errCode = 0;
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_GETCACHE then
        args.cmd = NativeCall.CMD_GETCACHE
        args.path = WRITEABLEPATH .. "cache/"
        local argStr = json.encode(args);
        PlatformCallLua(argStr)
    elseif data.cmd == NativeCall.CMD_CHECKFILEEXIST then
        args.cmd = NativeCall.CMD_CHECKFILEEXIST
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(data.filePath);
        -- print(headFile)
        args.ret = io.exists(headFile) and 1 or 0
        args.fileFullPath = headFile
        local argStr = json.encode(args);
        PlatformCallLua(argStr)
    elseif data.cmd == NativeCall.CMD_IS_PORTRAIT then
    elseif data.cmd == NativeCall.CMD_WECHAT_SIGNAL then
        args.cmd = NativeCall.CMD_WECHAT_SIGNAL;
        args.rssi = 4
        args.type = "Wi-Fi"
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_YY_UPLOAD_SUCCESS then
        args.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        args.fileUrl = "fileUrl"
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
    elseif data.cmd == NativeCall.CMD_YY_PLAY_FINISH then
        args.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        args.usI = kUserInfo:getUserId();
        local argStr = json.encode(args);

        PlatformCallLua(argStr);
	elseif data.cmd == NativeCall.CMD_OPEN_URL then
        Log.i("url:".. data.url);
		device.openURL(data.url);
        PlatformCallLua(data);

    elseif data.cmd == NativeCall.CMD_KE_FU_REFRESH then
        args.cmd = NativeCall.CMD_KE_FU_REFRESH

        args.count = math.random(0, 1)
        local argStr = json.encode(args);
        PlatformCallLua(argStr);

    elseif data.cmd == NativeCall.CMD_LOCATION then
        args.cmd = NativeCall.CMD_LOCATION

        args.longitude = math.random(115, 120)
        args.latitude  = math.random(20, 25)
        local argStr = json.encode(args);
        PlatformCallLua(argStr);
    end
end

-- 从平台回调至Lua入口函数
PlatformCallLua = function(args)
    -- Log.i("------PlatformCallLua", args);
    NativeCall.getInstance():callLua(args);
end

--lua 被调用
NativeCallyyLogin = function(args)
    Log.i("------PlatformCallLuaPlayerFinish ");
    YY_IS_LOGIN = true;
end

-- 调用友盟统计事件
function NativeCall:NativeCallUmengEvent(eventId)
    Log.i("------NativeCallUmengEvent ", eventId);
    local data = {};
    data.cmd = NativeCall.CMD_UMENG_LOGIN_OFF;
    data.type = 3
    data.eventId = eventId
    NativeCall.getInstance():callNative(data);
end

function NativeCallUmengEvent(eventId)
    NativeCall.getInstance():NativeCallUmengEvent(eventId)
end

function NativeDNSPaserCallBack(domain, ip)
    Log.d("NativeDNSPaserCallBack", domain, ip)
    SocketManager.getInstance():getIPCallback(domain, ip)
end

-- 暴露给底层的全局函数
function NativeCallToLua(value)
    local data = json.decode(value)
    Log.i("NativeCallToLua", data)
    if data.cmd == NativeCall.CMD_WECHAT_SIGNAL then
        local event = cc.EventCustom:new(NativeCall.Events.NetStateChange) -- "onNetStateChange"
        event.data = data
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    elseif data.cmd == NativeCall.CMD_YY_UPLOAD_SUCCESS then
        local event = cc.EventCustom:new(NativeCall.Events.YYCallFuncChange)
        event.data = data
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    elseif data.cmd == NativeCall.CMD_YY_PLAY_FINISH then
        local event = cc.EventCustom:new(NativeCall.Events.YYCallFuncFinish)
        event.data = data
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    end
end

