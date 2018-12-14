--http连接管理器

HttpManager = {}

local fun = {}
--获取网络图片
HttpManager.getNetworkImage = function (url, fileName)
    Log.i("HttpManager.getNetworkImage", "-------url = " .. url);
    if not url or string.len(url) < 4 then
        if kLoginInfo:isNewAccredit() then
            kLoginInfo:setNewAccredit(false)
            if IsPortrait then -- TODO
                WX_HEADMD5 = "2"
            else
                WX_HEADMD5 = ""--"4"
            end
            cc.UserDefault:getInstance():setStringForKey("wx_headmd5",WX_HEADMD5)
        end
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkImage", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetImg(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

--获取网络json文件
HttpManager.getNetworkJson = function (url, fileName)
    Log.i("HttpManager.getNetworkJson", "-------url = " .. url);
    if not url or string.len(url) < 4 then
        return
    end
    local onReponseNetworkJson = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkJson code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkJson", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        UIManager.getInstance():onResponseNetJson(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkJson, url, "GET");
    request:start();
end

--获取微信access_token
HttpManager.getWeChatAccess_token = function (info)
    Log.i("HttpManager.getWeChatAccess_token");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatAccess_token code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatAccess_token", responseString);
        local info = json.decode(responseString);
        if info.errcode and info.errcode == 40029 then
            LoadingView.getInstance():hide();
            Toast.getInstance():show("微信登录失败，请重试");
            return;
        end
        if info.access_token then
            cc.UserDefault:getInstance():setStringForKey("access_token", info.access_token);
        end
        if info.openid then
            cc.UserDefault:getInstance():setStringForKey("openid", info.openid);
        end
        if info.refresh_token then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", info.refresh_token);
        end
        cc.UserDefault:getInstance():flush()
        --
        HttpManager.getWeChatUserInfo(info);
    end
    local url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" .. info.appid .. "&secret=" .. info.secret .. "&code=" .. info.code .. "&grant_type=authorization_code";
    Log.i("getWeChatAccess_token url", url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

HttpManager.getWeChatUserInfo = function (info)
    Log.i("------HttpManager.getWeChatUserInfo");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatUserInfo code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatUserInfo", responseString);
        local info = json.decode(responseString);
        WX_OPENID = info.openid;
        WX_NAME = info.nickname;
        WX_PR = info.province;
        WX_CITY = info.city;
        WX_CO = info.country;
        WX_HEAD = info.headimgurl or "";
        WX_SEX = info.sex;
        WX_UID = info.unionid or WX_UID
        --
        fun.downloadWechatHeadImage(WX_HEAD)
        cc.UserDefault:getInstance():setStringForKey("wx_name", WX_NAME);
        cc.UserDefault:getInstance():setStringForKey("wx_head", WX_HEAD);
        cc.UserDefault:getInstance():setStringForKey("wx_sex", WX_SEX);
        cc.UserDefault:getInstance():setStringForKey("wx_co", WX_CO);
        cc.UserDefault:getInstance():setStringForKey("wx_pr", WX_PR);
        cc.UserDefault:getInstance():setStringForKey("wx_city", WX_CITY);
        cc.UserDefault:getInstance():setStringForKey("union_id", WX_UID)
        cc.UserDefault:getInstance():flush()
        kLoginInfo:getPhoneInfoAndLink();    --获取手机信息登录
    end

    if info.access_token and info.openid then
        local url = "https://api.weixin.qq.com/sns/userinfo?access_token=" .. info.access_token .. "&openid=" .. info.openid;
        Log.i("------getWeChatUserInfo url", url);
        local request = network.createHTTPRequest(onReponse, url, "GET");
        request:start();
    else
        Log.i("------getWeChatUserInfo nil data");
    end
end

fun.downloadWechatHeadImage = function(headUrl)
    local cacheUrl = cc.UserDefault:getInstance():getStringForKey("wx_head","")
    local cacheMd5 = cc.UserDefault:getInstance():getStringForKey("wx_headmd5","")
    if cacheMd5 ~= "" and cacheUrl == WX_HEAD then
        return   -- 已经生成过一次类似的md5了不需要再生成
    end
    if IsPortrait then -- TODO
        local str = kUserInfo:getUserId()
        if str == 0 then
            str = "md5"
        end
        kLoginInfo:setNewAccredit(true)
        HttpManager.getNetworkImage(headUrl, str .. ".jpg");
    else
        kLoginInfo:setNewAccredit(true)
        HttpManager.getNetworkImage(headUrl,"md5.jpg");
    end
end

HttpManager.testmd5 = fun.downloadWechatHeadImage

--刷新微信access_token
HttpManager.toRefreshWeChat_token = function (info)
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------toRefreshWeChat_token code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.toRefreshWeChat_token", responseString);
        local info = json.decode(responseString);
        if info.errcode and info.errcode == 40030 then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
            --LoadingView.getInstance():hide();
            --Toast.getInstance():show("您的微信授权已过期，请重新登录");
            return;
        end
        if info.access_token then
            cc.UserDefault:getInstance():setStringForKey("access_token", info.access_token);
        end
        if info.openid then
            cc.UserDefault:getInstance():setStringForKey("openid", info.openid);
        end
        if info.refresh_token then
            cc.UserDefault:getInstance():setStringForKey("refresh_token", info.refresh_token);
        end
        cc.UserDefault:getInstance():flush()
        --
        HttpManager.getWeChatUserInfo1(info);
    end
    local url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=".. WX_APP_ID .. "&grant_type=refresh_token&refresh_token=" .. info.refresh_token;
    Log.i("------HttpManager.toRefreshWeChat_token url : " , url);
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

HttpManager.getWeChatUserInfo1 = function (info)
    Log.i("------HttpManager.getWeChatUserInfo1");
    local onReponse = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWeChatUserInfo1 code", code);
            return;
        end
        local responseString = request:getResponseString();
        Log.i("-----HttpManager.getWeChatUserInfo1", responseString);
        local info = json.decode(responseString);
        WX_OPENID = info.openid;
        WX_NAME = info.nickname;
        WX_PR = info.province;
        WX_CITY = info.city;
        WX_CO = info.country;
        WX_HEAD = info.headimgurl or "";
        WX_SEX = info.sex;
        WX_UID = info.unionid or WX_UID
        --
        fun.downloadWechatHeadImage(WX_HEAD)
        cc.UserDefault:getInstance():setStringForKey("wx_name", WX_NAME);
        cc.UserDefault:getInstance():setStringForKey("wx_head", WX_HEAD);
        cc.UserDefault:getInstance():setStringForKey("wx_sex", WX_SEX);
        cc.UserDefault:getInstance():setStringForKey("wx_co", WX_CO);
        cc.UserDefault:getInstance():setStringForKey("wx_pr", WX_PR);
        cc.UserDefault:getInstance():setStringForKey("wx_city", WX_CITY);
        cc.UserDefault:getInstance():setStringForKey("union_id", WX_UID)

        cc.UserDefault:getInstance():flush()
        local data = {}
        data.niN = WX_NAME
        data.he = WX_HEAD
        if not IsPortrait then -- TODO
            SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_IP, data)
        end
    end
    if info.access_token and info.openid then
        --todo
        local url = "https://api.weixin.qq.com/sns/userinfo?access_token=" .. info.access_token .. "&openid=" .. info.openid;
        Log.i("------getWeChatUserInfo1 url", url);
        local request = network.createHTTPRequest(onReponse, url, "GET");
        request:start();
    else
        Log.i("------getWeChatUserInfo1 nil data");
    end
end

local function decodeIp(request)
    local code = request:getResponseStatusCode()
    if code ~= 200 then return end
    -- 请求成功，显示本地外网ip信息
    local responseString = request:getResponseString()
    --解析
    local p1 = string.find(responseString, "{")
    if p1 == 0 or p1 == nil then return end
    local p2 = string.len(responseString)
        local e = string.byte("}")
        while p2 > 0 do
            local b = string.byte(responseString, p2)
            if b == e then -- 46 = char "."
                break
            end
        p2 = p2 - 1
    end
    if p2 == 0 then return end

    local str = string.sub(responseString, p1, p2)
    local tab = json.decode(str)
    if tab and tab["cip"] and tab["cip"] ~= "" then
        local ip = tab["cip"]
        Util.reportBuglyLog(
            69696, -- 切换wifi登陆
            {
                IP = ip,
            })
        Log.d("HttpManager.getLocalNetworkIP decodeIp", ip)
        kUserInfo:setUserNewIp(ip)
        return ip
    end
end

HttpManager.getLocalNetworkIP = function(onFinish)
    local onNetworkIPData = function (event)
        if event == nil then
            return
        end
        if event.name == "failed" then
            if onFinish then onFinish(-1) end
            return
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request
        local code = request:getResponseStatusCode()
        if onFinish then
            decodeIp(request)
            onFinish(code, request:getResponseString())
            return
        end
        if code ~= 200 then
            Log.i("------getIP code", code)
            return
        end

        local data = {}
        data.ip = decodeIp(request)
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_IP, data)
        if IsPortrait then -- TODO
            local LocalEvent = require("app.hall.common.LocalEvent")
            local event = cc.EventCustom:new(LocalEvent.PlayerIp)
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
        end
    end

    local url = "http://pv.sohu.com/cityjson"
    local request = network.createHTTPRequest(onNetworkIPData, url, "GET")
    request:start();
end


---- 获取微信号轮换数据
HttpManager.getWechatIdData = function (url, callBack)
    Log.i("HttpManager.getWechatIdData", "-------url = " .. url);
    local onReponseWechatIdData = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------getWechatIdData code", code);
            return;
        end

        -- 请求成功，显示服务端返回的内容
        local responseString = request:getResponseString();
        --Log.i("-----HttpManager.getWechatIdData", responseString);
        --解析
        if not responseString or responseString == "" then return end 
        local tab = Util.stringSplit(responseString, "|");
        if not tab or #tab < 2 then return end 
        local arr = {};
        for i=2, #tab do
            table.insert(arr, tab[i]);
        end

        if #arr == 1 then arr[2] = arr[1] end
        local update_time = tab[1] or 600
        kUserData_userExtInfo:setAddWeChatID(arr, update_time, callBack) 
    end

    local request = network.createHTTPRequest(onReponseWechatIdData, url, "GET");
    request:start();
end

--测试界面获取网络消息
HttpManager.getTestUrl = function (url, onFinish)
    Log.i("HttpManager.getTestUrl", "-------url = " .. url);
    local onReponseGetURL = function (event)
        if event == nil then
            return;
        end
        if event.name == "failed" then
            if onFinish then onFinish(-1) end
            return
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseUrl code", code);
            onFinish(code)
            return;
        end
        Log.i("HttpManager.getTestUrl");

        local body=request:getResponseString()

        onFinish(code, body)
    end
    local request = network.createHTTPRequest(onReponseGetURL, url, "GET");
    request:start();
end

--获取网络内容
HttpManager.getURL = function (url, hookFun)
    Log.i("HttpManager.getURL", "-------url = " .. url);
    local onReponseGetURL = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseUrl code", code);
            return;
        end
        Log.i("HttpManager.getURL");

        local body=request:getResponseString()

        hookFun(body)

    end
    --
    local request = network.createHTTPRequest(onReponseGetURL, url, "GET");
    request:start();
end


--获取网络图片并回调
HttpManager.getNetworkImageWithUrl = function (url, fileNameFullPath, downFinishCB)
    Log.i("HttpManager.getNetworkImageWithUrl", "-------url = " .. url)
    if not url or string.len(url) < 4 then
        return
    end

    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = fileNameFullPath
        Log.i("HttpManager.getNetworkImageWithUrl", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        downFinishCB(savePath)
    end
    
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

-- 获取微信分享信息
HttpManager.getWechatShareInfo = function(shareType, source, callBack)
    local baseUrl = "http://192.168.9.101/container_info_list"
    local url = baseUrl .. "?share_type=" .. shareType .. "&source=" .. source
    Log.i("getWechatShareInfo url", url)
    url = "http://192.168.9.101/container_info_list?project=中心组项目&branch=all_branch"

    local function handleData(serverData)
        Log.i("handleData", serverData)
        serverData = 
        {
            code = 0,
            msg = '',
            data = {
                res_type = 1,
                title = 'xxx',
                thumbimg = '/xxx/xxx.jpg',
                desc = 'xxxx',
                link = 'http://192.168.1.1/xxx',
                appid = 'xxx'
            }
        }
        callBack(serverData)
    end
    HttpManager.getURL(url, handleData)
end

-- 测试url的访问情况
HttpManager.testUrlConnect = function (url, callback, responseTime)
    Log.i("HttpManager.getNetworkImage", "-------url = " .. url);
    if not callback then return end
    local responseTimeOut = false -- 响应超时

    local onReponseNetwork = function (event)
        if responseTimeOut then return end
        if event == nil then
            return;
        end
        -- print(event.name)
        if event.name == "failed" then
            responseTimeOut = true
            callback(event, code)
        elseif event.name == "completed" then
            responseTimeOut = true
            local request = event.request
            local code = request:getResponseStatusCode()
            callback(event, code)
        end
    end
    --
    local request = network.createHTTPRequest(onReponseNetwork, url, "GET");
    request:start();

    scheduler.performWithDelayGlobal(function()
        if responseTimeOut then return end
        responseTimeOut = true
        callback({name = "timeout"})
        end, responseTime or 10)
end
