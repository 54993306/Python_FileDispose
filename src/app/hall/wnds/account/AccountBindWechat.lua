-----------------------------------------------------------
--  @file   AccountBindWechat.lua
--  @brief  绑定微信处理
--  @author At.Lin
--  @DateTime:2018-07-05 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local BindWechat = {}
local LocalEvent = require "app.hall.common.LocalEvent"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

-- 返回数据判断
BindWechat.repSucceed = function(event)
    if not event or event.name ~= "completed" then
        return
    end
    
    local code = event.request:getResponseStatusCode();
    if code ~= 200 then -- 请求结束，但没有返回 200 响应代码
        Log.e("BindWechat.repSucceed Failed code :", code);
        return;
    end

    local data = json.decode(event.request:getResponseString());
    if IsPortrait then -- TODO
        if data.errcode and data.errcode ~= 0 then
            LoadingView.getInstance():hide();
            -- Toast.getInstance():show("微信登录失败，请重试");
            Log.e("BindWechat.repSucceed Failed errcode :" , data.errcode);
            return data;
        end
    else
        if data.errcode and data.errcode == 40029 then
            LoadingView.getInstance():hide();
            Toast.getInstance():show("微信登录失败，请重试");
            Log.e("BindWechat.repSucceed Failed errcode :" , data.errcode);
            return;
        end
    end
    return data
end

-- https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APPID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
-- 刷新微信access_token
BindWechat.refreshToken = function ()
    if AccountStatus.TEST then
        BindWechat.notifyStatus(LocalEvent.RefreshToken)
        return
    end
    local onReponse = function (event)
        local RspData = BindWechat.repSucceed(event)
        if not RspData then return end
        if IsPortrait then -- TODO
            if RspData.errcode and RspData.errcode ~= 0 then
                LoadingView.getInstance():hide();   
                BindWechat.Bind()                       -- 刷新token失败,调用玩家新授权
                return
            end
        end
        BindWechat.saveTokenInfo(RspData)
        BindWechat.notifyStatus(LocalEvent.RefreshToken,RspData);
        LoadingView.getInstance():hide();    -- 到此微信的消息获取完成，绑定成功
    end
    local refresh_token = cc.UserDefault:getInstance():getStringForKey("refresh_token")
    if IsPortrait then -- TODO
        refresh_token = cc.UserDefault:getInstance():getStringForKey("refresh_token","")
        if refresh_token == "" then
            LoadingView.getInstance():hide();   
            BindWechat.Bind()                       -- 刷新token失败,调用玩家新授权
            return 
        end
    end
    local htp = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid="
    local url = htp.. WX_APP_ID .. "&grant_type=refresh_token&refresh_token=" .. refresh_token;
    Log.i("refreshToken url : ",url)
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end
-- 根据appid 获取微信 access_token
BindWechat.getWeChatToken = function (info)
    Log.i("BindWechat.getWeChatToken");
    local onReponse = function (event)
        local RspData = BindWechat.repSucceed(event)
        if not RspData then return end
        if IsPortrait then -- TODO
            if RspData.errcode and RspData.errcode ~= 0 then
                Log.e("getWeChatToken failed : " , RspData )
                return
            end
        end
        BindWechat.saveTokenInfo(RspData)
        BindWechat.getUserWechatInfo(RspData);
    end
    local htp = "https://api.weixin.qq.com/sns/oauth2/access_token?appid="
    local url =  htp .. info.appid .. "&secret=" .. info.secret .. "&code=" .. info.code .. "&grant_type=authorization_code";
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

-- 存储token数据
BindWechat.saveTokenInfo = function(data)
    Log.i("saveTokenInfo : " , data)
    if data.access_token then
        cc.UserDefault:getInstance():setStringForKey("access_token", data.access_token);
    end
    if data.openid then
        cc.UserDefault:getInstance():setStringForKey("openid", data.openid);
    end
    if data.refresh_token then
        cc.UserDefault:getInstance():setStringForKey("refresh_token", data.refresh_token);
    end
    cc.UserDefault:getInstance():flush()
end

-- 根据token获取玩家微信信息
BindWechat.getUserWechatInfo = function (info)
    local onReponse = function (event)
        local RspData = BindWechat.repSucceed(event)
        if not RspData then return end
        if IsPortrait then -- TODO
            if RspData.errcode and RspData.errcode ~= 0 then
                Log.e("getUserWechatInfo failed : " , RspData )
                return
            end
        end
        BindWechat.saveUserInfo( RspData )
        LoadingView.getInstance():hide();    -- 到此微信的消息获取完成，绑定成功
        BindWechat.notifyStatus(LocalEvent.BindWechatSucceed,RspData);
    end

    if info.access_token and info.openid then
        local htp = "https://api.weixin.qq.com/sns/userinfo?access_token="
        local url = htp .. info.access_token .. "&openid=" .. info.openid;
        Log.i("Wechat ：" , url)
        local request = network.createHTTPRequest(onReponse, url, "GET");
        request:start();
    else
        Log.e();
    end
end

-- 存储用户微信数据
BindWechat.saveUserInfo = function(data)
    Log.i("getUserWechatInfo------saveUserInfo------------",data)
    WX_OPENID   = data.openid;
    WX_NAME     = data.nickname;
    WX_SEX      = data.sex;
    WX_PR       = data.province;
    WX_CITY     = data.city;
    WX_CO       = data.country;
    WX_HEAD     = data.headimgurl or "";
    WX_UID      = data.unionid or WX_UID
    cc.UserDefault:getInstance():setStringForKey("union_id", WX_UID)
    cc.UserDefault:getInstance():flush()
end

-- 绑定微信
BindWechat.Bind = function()
    -- pc绑定测试
    if AccountStatus.TEST then
        local data = {}
        data.nickname = "testbind"
        BindWechat.notifyStatus(LocalEvent.BindWechatSucceed,data)
        return
    end

    local data = {}
    data.cmd = NativeCall.CMD_WECHAT_LOGIN
    NativeCall.getInstance():callNative(data, function(info)  -- info 为微信登陆返回
        if info.errCode == 0 then
            BindWechat.getWeChatToken(info);
            LoadingView.getInstance():show("正在绑定微信，请稍候...");
        elseif info.errCode == -8 then
            LoadingView.getInstance():hide();
            Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
        else
            LoadingView.getInstance():hide();
        end 
    end)
end

-- 检验授权凭证（access_token）是否有效
-- http：GET（需用https协议） https://api.weixin.qq.com/sns/auth?access_token=ACCESS_TOKEN&openid=OPENID

-- 状态通知
BindWechat.notifyStatus = function(eventCode ,data)
    local event = cc.EventCustom:new(eventCode)
    event._userdata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

BindWechat.getNetworkImage = function (url, fileName)
    Log.i("BindWechat.getNetworkImage url : ",url);
    if not url or string.len(url) < 4 then
        return false
    end
    local onReponseNetworkImage = function (event)
        if event == nil or event.name ~= "completed" then
            return;
        end
        local code = event.request:getResponseStatusCode()
        if code ~= 200 then  -- 请求结束，但没有返回 200 响应代码
            Log.i("BindWechat.getNetworkImage code : ", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("BindWechat.getNetworkImage", "-------savePath = " .. savePath);
        event.request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetImg(fileName);
    end
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

return BindWechat