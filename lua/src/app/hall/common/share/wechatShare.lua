--Aven
--微信分享
-- 分享鏈接到朋友圈
-- WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult))
-- 分享鏈接到好友
-- WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult))
-- 分享图片到朋友圈
-- WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.PICTURE, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult))
-- 分享图片到好友
-- WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.PICTURE, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult))

WeChatShared = {}

-- local aesUtil = require("app.hall.common.share.aes.aeslib.util")

-- 配置部分
--防屏蔽预发布服
-- if _isPreReleaseEnv then
--     WeChatShared.baseUrl = "http://pre-app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
--     WeChatShared.baseFeedbackUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
-- else
-- -- 防屏蔽和外网服
--     WeChatShared.baseUrl = "http://app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
--     WeChatShared.baseFeedbackUrl = "http://client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
-- end

WeChatShared.baseUrl =  WeChatShared.baseUrl or _WeChatSharedBaseUrl
WeChatShared.baseFeedbackUrl = WeChatShared.baseFeedbackUrl or _WeCharSHaredBaseFeedBackUrl

WeChatShared.shareClickNumberUrl = WeChatShared.shareClickNumberUrl or _WechatSharedClicksNumberUrl


WeChatShared.aesPassword = "96Ebbeir96Ebbeir"  -- aes 秘钥

---------------不需要配置begin-----------------------------
WeChatShared.package_name = ''      --包名
WeChatShared.dataSavedPath = ''     -- 本机数据存储路径
--临时缓存部分
WeChatShared._sharedResCB = nil
WeChatShared._shareType  = 0       -- 分享类型：0 朋友圈；1 好友（群）分享
WeChatShared._source = 0        -- 分享的来源,例如大厅分享,游戏内房间分享   
WeChatShared._conf_id = 0       -- Int 是   配置id，后台通过该id匹配分享的AppID及包名
WeChatShared._link_id = 0        -- Int 是   链接id
WeChatShared._resShareType = 0      -- 服务器返回的分享类型
WeChatShared._resShareImgUrl = ''   -- 系统分享的图片url(包括分享缩略图片url)
WeChatShared._headUrl = ""          -- 头像Url
WeChatShared._shareContentType = 0  -- 分享內容类型, default is 0 indicate link
WeChatShared._sharePath = "&source=0"   ---分享的路径tag
WeChatShared._shareMold = 0            --1涉及图片和缩略图分享，2内容链接分享，3文字内容分享，4链接分享
---------------不需要配置end-----------------------------
-- 分享类型 (注意, 在sdk端, 朋友圈是1, 好友是2)
WeChatShared.ShareType = {
    TIMELINE = 0,       --朋友圈
    FRIENDS = 1,        --好友
}
-- 分享內容类型
WeChatShared.ShareContentType = {
    LINK = 0,       -- 链接类型
    PICTURE = 1,    -- 图片类型
}

-- 分享功能
WeChatShared.SourceType = {
    HALL_NO_REWARD          = 1, -- 大厅分享（无奖励）竖版
    HALL_REWARD             = 2, -- 大厅分享（有奖励）
    GET_DIAMOND             = 3, -- 领取钻石
    CLUB                    = 4, -- 亲友圈分享
    FRIEND_ROOM_FRIEND      = 5, -- 房间等待界面邀请好友
    HALL_NO_REWARD_FRIEND   = 6, -- 大厅分享给好友（无奖励）竖版
    GET_DIAMOND_FRIEND      = 7, -- 领取钻石分享给好友
    CLUB_FRIEND             = 8, -- 亲友圈分享给好友
    CLUB_QR_FRIEND          = 9, -- 分享俱乐部二维码给好友
}

-- 采用的分享方式
WeChatShared.UseShareType = {
    DYNAMICAPPID = 1,   --动态appid 
    SYSTEMSHARE = 2,    --系统分享
    DYNAMICAPPIDPIC = 3, -- 动态appid图片分享
    SYSTEM_SHARE_TXT = 4, -- 系统纯文字分享
}

WeChatShared.clear = function( ... )        
    WeChatShared._resShareImgUrl = ''            -- 分享图片url

    WeChatShared._sharedResCB = nil
    WeChatShared._shareType = nil 
    WeChatShared._source = nil 

    WeChatShared._conf_id = 0       -- Int 是   配置id，后台通过该id匹配分享的AppID及包名
    WeChatShared._link_id = 0 
    WeChatShared._serverSharedData = nil
    WeChatShared._resShareType = nil
    WeChatShared._headUrl = ""          -- 头像Url
    WeChatShared._shareContentType = 0 
    WeChatShared._sharePath = "&source=0"
end

--获取手机信息返回
WeChatShared.getPhoneInfoCallBack = function(phoneInfo)
    Log.i("WeChatShared getPhoneInfoCallBack phoneInfo", phoneInfo);
    if phoneInfo then
        -- IMEI = phoneInfo.imei or IMEI;
        -- MODEL = phoneInfo.model or MODEL;
        -- REGION = phoneInfo.pu or REGION;
        -- SPID = phoneInfo.spid or SPID;
        -- VERSION = phoneInfo.version or VERSION;
        -- NETMODE = phoneInfo.netmode or NETMODE;
        -- JINDU = phoneInfo.longitude
        -- WEIDU = phoneInfo.latitude
        -- ENTERROOMCODE = phoneInfo.enterCode;
        -- if kLoginInfo:checkNetWork(NETMODE) then
        --     SocketManager.getInstance():openSocket();
        -- end
		-- if ( (not phoneInfo.packageName or string.len(phoneInfo.packageName)<=0) and (not phoneInfo["package Name"] or string.len(phoneInfo["package Name"])<=0)) then
  --           if _GameIdentification == 20006 then
  --               phoneInfo.packageName = "com.dashengzhangyou.pykf.bengbu"
  --           elseif _GameIdentification == 20005 then
  --               phoneInfo.packageName = "com.dashengzhangyou.pykf.huainan"
  --           end
  --       end
        if (phoneInfo.packageName and string.len(phoneInfo.packageName)>0) or (phoneInfo["package Name"] and string.len(phoneInfo["package Name"])>0) then
            if phoneInfo["package Name"] then
                WeChatShared.package_name = phoneInfo["package Name"]
            else
                WeChatShared.package_name = phoneInfo.packageName
            end
            -- 开始请求分享数据
            WeChatShared.beginWechatSharedInvoke()
        else
            WeChatShared.share()
            -- Toast.getInstance():showReminder("如分享异常，请前往苹果商城下载并安装最新版\n“河南麻将全集”")
            -- local serverDayShareInfo = kServerInfo:getDayShareInfo()
            -- local data = {};
            -- --分享标题 shT2="";
            -- --分享描述shD="";
            -- --分享链接shL="";
            -- data.cmd = NativeCall.CMD_WECHAT_SHARE;
            -- -- if(self.m_giftBaseInfo.shT==1) then 
            -- data.title = serverDayShareInfo.shareTitle or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
            -- data.desc = serverDayShareInfo.shareDesc or kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
            -- data.url = serverDayShareInfo.shareLink or kFriendRoomInfo:getRoomBaseInfo().downloadLink;
            -- data.url = data.url..WeChatShared._sharePath
            -- -- data.type = 1;
            -- data.type = WeChatShared._shareType + 1
            -- --LoadingView.getInstance():show("正在分享,请稍后...", 2);
            -- TouchCaptureView.getInstance():showWithTime()
            -- if WeChatShared._sharedResCB then
            --     NativeCall.getInstance():callNative(data, WeChatShared._sharedResCB);
            -- else
            --     NativeCall.getInstance():callNative(data, WeChatShared.shareResult);
            -- end
        end
    end
end

function WeChatShared.share()

    local serverData = WeChatShared._serverSharedData
    Log.i("serverData", serverData)
    local data = {};
    if not serverData  then
        WeChatShared._resShareType = nil
    end
    local res_type = WeChatShared._resShareType
    if res_type==WeChatShared.UseShareType.DYNAMICAPPID or res_type==WeChatShared.UseShareType.DYNAMICAPPIDPIC then
        --分享标题 shT2="";
        --分享描述shD="";
        --分享链接shL="";
        data.cmd = NativeCall.CMD_WECHAT_SHARE
        -- if(self.m_giftBaseInfo.shT==1) then
        data.title = serverData.title or serverData.shareTitle or ' '--serverDayShareInfo.shareTitle or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
        data.desc = serverData.desc or serverData.shareDesc or ' ' --serverDayShareInfo.shareDesc or kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
        data.url = serverData.link or serverData.shareLink or ' '--serverDayShareInfo.shareLink or kFriendRoomInfo:getRoomBaseInfo().downloadLink;
        data.url = data.url..WeChatShared._sharePath

        data.imgPath = serverData.headUrl or ""
        data.appid = serverData.appid
        -- args{"desc":"henan desc","title":"henan title","appid":"wx951f07ccd3f34856",
        -- "url":"http:\/\/s1.daqp9999.cn\/wechat\/shareNew.html?gameId=4156&from=timeline&isappinstalled=0","cmd":1007,
        -- "imgPath":"\/data\/user\/0\/com.pwgcrf.vpcn.henan\/files\/dsdfqp\/1260c2a87d29db738fb4a6eec32e2fca.jpg","type":1}
        data.friendOrCircle = WeChatShared._shareType
        data.linkOrPhoto = WeChatShared._shareContentType        
    elseif res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
        local invokeFlag = true
        if device.platform == "ios" then
            local  newDesc = serverData.desc
            local matchUrl = string.match(newDesc, '%[(http.-)]')
            if matchUrl then
                -- print(matchUrl)
                newDesc = string.gsub(newDesc, "%[http.-]", '')
                -- print("tttt",type(newDesc), newDesc)
            else
                invokeFlag = false
                -- error process
                Toast.getInstance():show("分享失败");
            end
        
        
            if invokeFlag then
              data.cmd = NativeCall.CMD_WECHAT_SHARE
              data.desc = newDesc
              data.imgPath = serverData.headUrl
              data.url = matchUrl
            end
        else
            data.cmd = NativeCall.CMD_WECHAT_SHARE
            data.desc = serverData.desc
            data.imgPath = serverData.headUrl
        end
    else
        local serverDayShareInfo = kServerInfo:getDayShareInfo()
        --分享标题 shT2="";
        --分享描述shD="";
        --分享链接shL="";
        data.cmd = NativeCall.CMD_WECHAT_SHARE;
        -- if(self.m_giftBaseInfo.shT==1) then 
        data.title = serverDayShareInfo.shareTitle or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
        data.desc = serverDayShareInfo.shareDesc or kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
        data.url = serverDayShareInfo.shareLink or kFriendRoomInfo:getRoomBaseInfo().downloadLink;
        data.url = data.url..WeChatShared._sharePath
    end
    if WeChatShared._source == WeChatShared.SourceType.FRIEND_ROOM_FRIEND then
        local roomInfo = {shareTitle = serverData.title, shareDesc = serverData.desc}
        local playerInfo = kFriendRoomInfo:getRoomInfo();
        local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
        -- data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
        if res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
            data.desc = data.title .. " " .. data.desc
        end
    elseif WeChatShared._source == WeChatShared.SourceType.GET_DIAMOND_FRIEND then
        if serverData then
            if data.title then
                data.title = string.format(data.title, kUserInfo:getUserId())
            end
            data.desc = string.format(data.desc, kUserInfo:getUserId())
        else
            
        end
    elseif WeChatShared._source == WeChatShared.SourceType.CLUB or WeChatShared._source == WeChatShared.SourceType.CLUB_FRIEND then
        local clubInfo = kSystemConfig:getOwnerClubInfo()
        data.desc = string.format(data.desc, kUserInfo:getUserName(), clubInfo.clN or "亲友圈")
        local clubUrl = clubInfo.clURL
        if clubUrl then 
            if not string.find(clubUrl,"?") then
                clubUrl = clubUrl.."?"
            end    
            data.url = clubUrl .. WeChatShared._sharePath
        end
    end
    local place_id = SettingInfo.getInstance():getSelectAreaPlaceID()
    if place_id and data.url and string.len(data.url) > 10 then
        data.url = data.url .. "&placeid=" .. place_id
    end
    if WeChatShared._shareMold == 0 then
        data.type = WeChatShared._shareType + 1
    else
        data.type = WeChatShared._shareMold
    end
    Log.i("--wangzhi--WeChatShared--data--",data)
    --LoadingView.getInstance():show("正在分享,请稍后...", 2);
    TouchCaptureView.getInstance():showWithTime()
    if WeChatShared._sharedResCB then
        NativeCall.getInstance():callNative(data, WeChatShared._sharedResCB);
    else
        NativeCall.getInstance():callNative(data, WeChatShared.shareResult);
    end
end

function WeChatShared.shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
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

--获取手机信息
WeChatShared.getPhoneInfoAndLink = function()
    local data = {}
    data.cmd = NativeCall.CMD_GET_PHONEINFO
    NativeCall.getInstance():callNative(data, WeChatShared.getPhoneInfoCallBack)
end

-- 开始请求分享数据
WeChatShared.beginWechatSharedInvoke = function ( ... )
    -- 1. 组装分享请求url
    local curUserid = kUserInfo:getUserId()
    local package_name = WeChatShared.package_name
    local share_type = WeChatShared._shareType
    local source = WeChatShared._source
    local ts = os.time()
    local place_id = SettingInfo.getInstance():getSelectAreaPlaceID()
    Log.i("WeChatShared.baseUrl", WeChatShared.baseUrl)
    Log.i("curUserid", curUserid)
    Log.i("package_name", package_name)
    Log.i("share_type", share_type)
    Log.i("source", source)
    Log.i("ts", ts)
    Log.i("place_id", place_id)
    local reqShareUrl = string.format("%s?userid=%d&package_name=%s&share_type=%d&source=%d&ts=%d&place_id=%d", 
                                        WeChatShared.baseUrl, curUserid, package_name, share_type, source, ts, place_id)
    if source == WeChatShared.SourceType.FRIEND_ROOM_FRIEND then
        reqShareUrl = reqShareUrl .. string.format("&play_id=%d", kFriendRoomInfo:getGameID())
    end

    if WeChatShared._serverSharedData and WeChatShared._serverSharedData.linkType then
        reqShareUrl = reqShareUrl .. string.format("&link_type=%d", WeChatShared._serverSharedData.linkType)
    end

    Log.i("getWechatShareInfo url", reqShareUrl)

    --2. 请求服务器
    -- 从服务器获取分享数据
    HttpManager.getURL(reqShareUrl, WeChatShared.handleShareData)
end

-- 获取微信分享信息
-- local url = baseUrl .. "?share_type=" .. shareType .. "&source=" .. source
-- Log.i("getWechatShareInfo url", url)
-- url = "http://192.168.9.101/container_info_list?project=中心组项目&branch=all_branch"
-- userid
-- package_name
-- share_type  分享类型：1 朋友圈；2 好友（群）分享
-- source   分享功能：1 每日分享；2 大赢家分享
-- shareContentType 分享內容類型
WeChatShared.getWechatShareInfo = function(shareType, shareContentType, source, callBack, sharePath, data)
    --首先清除上次缓存数据
    WeChatShared.clear()
    Log.i("data.......",data)
    Log.i(debug.traceback())
    WeChatShared._sharePath = sharePath or "&source=0"
    WeChatShared._sharedResCB = callBack
    WeChatShared._shareType = shareType or WeChatShared.ShareType.TIMELINE
    WeChatShared._source = source
    WeChatShared._shareContentType = shareContentType or WeChatShared.ShareContentType.LINK
    if data then
        WeChatShared._headUrl = data.headUrl or ""
        WeChatShared._shareMold = data.shardMold
        WeChatShared._serverSharedData = data
        WeChatShared._resShareType = data.resShareType or WeChatShared.UseShareType.DYNAMICAPPID
    end
    -- 0. check package name
    if string.len(WeChatShared.package_name)==0 then
        WeChatShared.getPhoneInfoAndLink()
        return
    end

    -- 开始请求分享数据
    WeChatShared.beginWechatSharedInvoke()
end

-- 获取数据存储路径
WeChatShared.getDataSavedPath = function()  
    local data = {}
    data.cmd = NativeCall.CMD_GETCACHE
    NativeCall.getInstance():callNative(data, WeChatShared.getDataSavedPathRet)
end

-- 获取数据存储路径返回
WeChatShared.getDataSavedPathRet = function(info)
    if info and info.path then
        release_print("------WeChatShared:getCachePath", info.path);
        -- WRITEABLEPATH = info.path;
        WeChatShared.dataSavedPath = info.path

        WeChatShared.checkDownloadImgData()
    end
end

-- 生成微下载地址
local function getWeLink(welinkURL, mode, param)
    if type(welinkURL) ~= "string" then
        return ""
    end
    if device.platform == "ios" then
        if mode and param then
            local encodePara = string.format(
                "steve://%s:8080/openwith?model=%s&param=%d",
                SCHEME_HOST_NAME,  --和Android包mfest配置的schema host保持一致
                mode, -- 'room' --自定义mode
                param) --自定义参数

            return welinkURL .. "&android_schema=" .. string.urlencode(encodePara)
        else
            return welinkURL
        end
    else
        if mode and param then
            local encodePara = string.format(
                "steve://%s:8080/openwith?model=%s&param=%d",
                SCHEME_HOST_NAME,  --和Android包mfest配置的schema host保持一致
                mode, -- 'room' --自定义mode
                param) --自定义参数

            return welinkURL .. "&android_schema=" .. string.urlencode(encodePara)
        else
            local encodePara = string.format(
            "steve://%s:8080/openwith?",
            SCHEME_HOST_NAME  --和Android包mfest配置的schema host保持一致
             ) --自定义参数

            return welinkURL .. "&android_schema=" .. string.urlencode(encodePara)
        end
    end
end

-- 调用微信分享接口
WeChatShared.callWechatShareInterface = function(imgFileFullPath)
    -- WeChatShared._shareType 
    -- WeChatShared._source 
    
    local serverData = WeChatShared._serverSharedData
    Log.i("serverData", serverData)
    
    local data = {};

    local res_type = WeChatShared._resShareType
    if res_type==WeChatShared.UseShareType.DYNAMICAPPID or res_type==WeChatShared.UseShareType.DYNAMICAPPIDPIC then
        --分享标题 shT2="";
        --分享描述shD="";
        --分享链接shL="";
        data.cmd = NativeCall.CMD_WECHAT_SHARE
        -- if(self.m_giftBaseInfo.shT==1) then
        data.title = serverData.title or ' '--serverDayShareInfo.shareTitle or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
        data.desc = serverData.desc or ' ' --serverDayShareInfo.shareDesc or kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
        data.url = serverData.link or ' '--serverDayShareInfo.shareLink or kFriendRoomInfo:getRoomBaseInfo().downloadLink;
        data.applink = serverData.applink or ''    --微下载的链接
        data.applink_id = serverData.applink_id or 0    --微下载的id
        if data.applink_id and string.len(tostring(data.applink)) > 4 then
            data.url = data.applink
            Log.i("--wangzhi--change--data.url--",data.url)
        end
        data.url = data.url..WeChatShared._sharePath

        data.imgPath = imgFileFullPath
        data.appid = serverData.appid
        -- args{"desc":"henan desc","title":"henan title","appid":"wx951f07ccd3f34856",
        -- "url":"http:\/\/s1.daqp9999.cn\/wechat\/shareNew.html?gameId=4156&from=timeline&isappinstalled=0","cmd":1007,
        -- "imgPath":"\/data\/user\/0\/com.pwgcrf.vpcn.henan\/files\/dsdfqp\/1260c2a87d29db738fb4a6eec32e2fca.jpg","type":1}
        data.friendOrCircle = WeChatShared._shareType
        data.linkOrPhoto = WeChatShared._shareContentType        
    elseif res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
        local invokeFlag = true
        if device.platform == "ios" then
            local  newDesc = serverData.desc
            local matchUrl = string.match(newDesc, '%[(http.-)]')
            if matchUrl then
                -- print(matchUrl)
                newDesc = string.gsub(newDesc, "%[http.-]", '')
                -- print("tttt",type(newDesc), newDesc)
            else
                invokeFlag = false
                -- error process
                Toast.getInstance():show("分享失败");
                Log.e("res_type error", "invokeFlag false", serverData)
                return
            end
        
        
            if invokeFlag then
              data.cmd = NativeCall.CMD_WECHAT_SHARE_SYSTEM
              data.desc = newDesc
              data.imgPath = imgFileFullPath
              data.url = matchUrl
              data.path = imgFileFullPath
            end
        else
            data.cmd = NativeCall.CMD_WECHAT_SHARE_SYSTEM
            data.desc = serverData.desc
            data.imgPath = imgFileFullPath
            data.path = imgFileFullPath
        end
    else
        -- 容错处理, 记录报错
        Log.e("res_type error", WeChatShared)
        return
    end
    if WeChatShared._source == WeChatShared.SourceType.FRIEND_ROOM_FRIEND then
        local roomInfo = {shareTitle = serverData.title, shareDesc = serverData.desc}
        local playerInfo = kFriendRoomInfo:getRoomInfo();
        local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
        data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
        if res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
            data.desc = data.title .. " " .. data.desc
        end
        data.url = getWeLink(data.url, 'room', playerInfo.pa)
    elseif WeChatShared._source == WeChatShared.SourceType.GET_DIAMOND_FRIEND then
        if data.title then
            data.title = string.format(data.title, kUserInfo:getUserId())
        end
        data.desc = string.format(data.desc, kUserInfo:getUserId())
        data.url = getWeLink(data.url)
    elseif WeChatShared._source == WeChatShared.SourceType.CLUB or WeChatShared._source == WeChatShared.SourceType.CLUB_FRIEND then
        local clubInfo = kSystemConfig:getOwnerClubInfo()
        data.desc = string.format(data.desc, kUserInfo:getUserName(), clubInfo.clN or "亲友圈")
        local clubUrl = clubInfo.clURL
        if clubUrl then 
            if not string.find(clubUrl,"?") then
                clubUrl = clubUrl.."?"
            end    
            data.url = clubUrl .. WeChatShared._sharePath
            data.url = getWeLink(data.url)
        end
    else
        data.url = getWeLink(data.url)
    end

    if WeChatShared._shareMold == 0 or res_type==WeChatShared.UseShareType.DYNAMICAPPID or res_type==WeChatShared.UseShareType.DYNAMICAPPIDPIC  then
        data.type = WeChatShared._shareType + 1
    elseif res_type == WeChatShared.UseShareType.SYSTEMSHARE then
        data.type = 1
    end
    data.res_type = res_type
    data.headUrl = WeChatShared._headUrl

    local place_id = SettingInfo.getInstance():getSelectAreaPlaceID()
    if place_id and data.url and string.len(data.url) > 10 then
        data.url = data.url .. "&placeid=" .. place_id
    end

    Log.i("shareToWechat", data)
    NativeCall.getInstance():callNative(data, WeChatShared.nativeSharedFinishRet)
end

--监察并下载数据返回
WeChatShared.checkDownloadImgDataRet = function(info)
    release_print("------WeChatShared:checkDownloadImgDataRet")
    Log.i("WeChatShared.checkDownloadImgDataRet", info)
    local ret = info.ret
    local fileFullPath = info.fileFullPath
    if ret and ret>0 then
        WeChatShared.callWechatShareInterface(fileFullPath)
    else 
        -- 下载img
        HttpManager.getNetworkImageWithUrl(WeChatShared._resShareImgUrl, fileFullPath, WeChatShared.callWechatShareInterface)
    end
end

--监察并下载数据
WeChatShared.checkDownloadImgData = function()   
    local imgUrlMd5Val = crypto.md5(WeChatShared._resShareImgUrl)
    local localImgFilename = imgUrlMd5Val..'.jpg'

    -- 本地缓存有没有
    if device.platform == "ios" then
        WeChatShared.dataSavedPath = WeChatShared.dataSavedPath .. '/'
    end
    local chkImgFileFullPath = WeChatShared.dataSavedPath..localImgFilename
    local data = {}
    data.cmd = NativeCall.CMD_CHECKFILEEXIST    --检查是否存在
    -- data.cmd = NativeCall.CMD_GETCACHE
    data.filePath = chkImgFileFullPath
    release_print("------WeChatShared.checkDownloadImgData---------");
    NativeCall.getInstance():callNative(data, WeChatShared.checkDownloadImgDataRet)    
end


-- 4. 分析获取的img data
WeChatShared.getSharedImgData = function(imageUrl) 
    Log.i("WeChatShared.getSharedImgData", imageUrl, WeChatShared.dataSavedPath)     

    if not (WeChatShared.dataSavedPath and string.len(WeChatShared.dataSavedPath)>0) then       
        WeChatShared.getDataSavedPath()
    else
        WeChatShared.checkDownloadImgData()
    end   
end

-- 3. 分析分享服务器返回数据
-- 从服务器获取分享数据回调    
-- code    Int 返回码：0 成功
-- msg String  返回消息
-- data    Object  返回数据
-- data.res_type   Int 类型：1 链接
-- 当data.res_type = 1，出现以下字段：
-- data.title  String  标题
-- data.thumbimg   String  缩略图200x200的jpg，完整Http URL
-- data.desc   String  描述
-- data.link_id    Int 链接id
-- data.link   String  链接
-- data.conf_id    Int 配置id，该id关联后台的AppID及包名
-- data.appid  String  微信开发id
-- ***微信分享到朋友圈用的是title，不显示desc，用户可以自输入内容,分享到微信好友用的是title和description，用户不可以输内容***
WeChatShared.handleShareData = function(retData)         
    Log.i("handleData 1 ", retData)    
    local serverData = json.decode(retData)       

    -- -- 需要进行aes 128 cbc 解密    
    -- local encServerData = retData.data
    -- print("Cipher: ", aesUtil.toHexString(encServerData))
    -- local serverData = aeslua.decrypt(WeChatShared.aesPassword, encServerData, aeslua.AES128, aeslua.CBCMODE)
    -- print(" Plain: ", serverData)

    -- local encServerData = 'Hello world!'
    -- local serverData = aeslua.encrypt(WeChatShared.aesPassword, encServerData, aeslua.AES128, aeslua.CBCMODE)   
    -- local b64data = crypto.encodeBase64(serverData)
    -- print(" Plain: ", b64data, #serverData)
    -- print(tolua.type(serverData))

    -- local dedata = 'FnMto6s7Idt3yhv2MvZB/5aUwclbE40z5AUu24ZiCNg='
    -- local debase64data = crypto.decodeBase64(dedata)    
    -- local serverDataRaw = aeslua.decrypt(WeChatShared.aesPassword, debase64data, aeslua.AES128, aeslua.CBCMODE)    
    -- print("raw data: ", serverDataRaw)

    
    
    -- if true then
    --     return
    -- end

    -- local file = io.open(WRITEABLEPATH .. "test","w")
    -- file:write(serverData)
    -- file:close()


    -- -- 模拟数据
    -- local serverData = {
    --     code = 0,
    --     msg = '',
    --     data = {
    --         res_type = 1,
    --         title = 'xxx',
    --         thumbimg = '/xxx/xxx.jpg',
    --         desc = 'xxxx',
    --         link = 'http://192.168.1.1/xxx',
    --         appid = 'xxx'
    --     }
    -- }

    -- local serverData = {
    --     code = 0,
    --     res_type = 1,
    --     title = "Aven new share test is here now!",
    --     thumbimg = "http://i3.17173cdn.com/2fhnvk/YWxqaGBf/cms3/sUELrWbliqjeobF.jpg",
    --     desc = "Aven new share test is here now!",
    --     link_id = 12,
    --     link = "www.qq.com",
    --     conf_id = 3,
    --     appid = "wx951f07ccd3f34856",
    -- }
    -- Log.i("aven get code:", serverData.code, type(serverData))
    -- serverData.thumbimg = "http://112.74.174.12:36999/tubiao/icon_68.jpg"
    if serverData.code~=0 then
        Log.i("get shared data error", serverData.msg)
        Toast.getInstance():show("无法获取到分享数据......")
        return
    end

    local serverData = WeChatShared.decodeSharedData(serverData.data)
    Log.i("handleData decode ", serverData)    

    local res_type = serverData.res_type

    WeChatShared._resShareType = res_type
    if res_type==WeChatShared.UseShareType.DYNAMICAPPID or res_type==WeChatShared.UseShareType.DYNAMICAPPIDPIC then
        WeChatShared.DynamicAppidShare(serverData)
        -- WeChatShared._resShareType = WeChatShared.UseShareType.SYSTEMSHARE
        -- WeChatShared.SystemShare(serverData)
    elseif res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
        WeChatShared.SystemShare(serverData)
    end   
end

-- 微信系统分享
WeChatShared.SystemShare = function(shareData)
    local serverData = shareData
    WeChatShared._serverSharedData = serverData    
    WeChatShared._resShareImgUrl = serverData.bgimg or serverData.thumbimg
    -- WeChatShared._resShareImgUrl = serverData.thumbimg

    Log.i("serverdata: come 1", WeChatShared._resShareImgUrl, type(WeChatShared._resShareImgUrl))
    if WeChatShared._resShareImgUrl and string.len(WeChatShared._resShareImgUrl) > 4 then
        Log.i("serverdata: come 2")
        WeChatShared.getSharedImgData(WeChatShared._resShareImgUrl)
    else
        WeChatShared.callWechatShareInterface("")
    end
end

-- 微信动态appid分享
WeChatShared.DynamicAppidShare = function(shareData)
    --暂存服务器返回的分享数据
    local serverData = shareData
    WeChatShared._serverSharedData = serverData
    WeChatShared._link_id = serverData.link_id or 0
    WeChatShared.applink_id = serverData.applink_id or 0
    WeChatShared.applink = serverData.applink or ''
    if applink_id ~= 0 and string.len(WeChatShared.applink) > 4 then
        WeChatShared._link_id = serverData.applink_id
        Log.i("--wangzhi--change--WeChatShared._link_id--",WeChatShared._link_id)
    end
    WeChatShared._conf_id = serverData.conf_id or 0
    WeChatShared._resShareImgUrl = serverData.thumbimg

    Log.i("serverdata: come 1", WeChatShared._resShareImgUrl, type(WeChatShared._resShareImgUrl))
    if WeChatShared._resShareImgUrl and string.len(WeChatShared._resShareImgUrl) > 4 then
        Log.i("serverdata: come 2")
        WeChatShared.getSharedImgData(WeChatShared._resShareImgUrl)
    else
        Log.i("serverdata: come 3")
        WeChatShared.callWechatShareInterface("")
    end
end

-- 微信分享完成后回调
WeChatShared.nativeSharedFinishRet = function(retInfo)
    -- 分享反馈
    -- userid  String  是   用户id
    -- share_type  Int 是   分享类型：1 朋友圈；2 好友（群）分享
    -- conf_id Int 是   配置id，后台通过该id匹配分享的AppID及包名
    -- link_id Int 是   链接id
    -- share_result    Int 是   分享结果：1 成功；9 失败
    Log.i("WeChatShared.nativeSharedFinishRet retInfo:", retInfo)
    if retInfo.sharedResCB then
        retInfo.sharedResCB(retInfo)
    elseif WeChatShared._sharedResCB then
        WeChatShared._sharedResCB(retInfo)
    end

    local res_type = retInfo.resType or WeChatShared._resShareType -- 兼容处理
    local sharePath = retInfo.sharePath or WeChatShared._sharePath or ""
    local source = retInfo.source or WeChatShared._source or 0

    if res_type==WeChatShared.UseShareType.DYNAMICAPPID or res_type==WeChatShared.UseShareType.DYNAMICAPPIDPIC then
        local share_result = 9
        if retInfo.errCode==0 then share_result=1 end--成功
        Log.i("--wangzhi--back--WeChatShared._link_id--",WeChatShared._link_id)
        local reqUrl = string.format("%s?userid=%d&share_type=%d&conf_id=%d&link_id=%d&share_result=%d&gameid=%d&source=%d",
                                    WeChatShared.baseFeedbackUrl, kUserInfo:getUserId(), WeChatShared._shareType, 
                                    WeChatShared._conf_id, WeChatShared._link_id, share_result, PRODUCT_ID, source)

        Log.i("WeChatShared.nativeSharedFinishRet:", reqUrl)
        
        HttpManager.getURL(reqUrl, WeChatShared.feedbackSharedCB)
 

        ---统计分享次数
        if (share_result == 1) and sharePath ~= "" then
            local reqClickUrl = string.format("%s?gameid=%d%s",
                                        WeChatShared.shareClickNumberUrl, PRODUCT_ID, sharePath)
            Log.i("WeChatShared.nativeSharedFinishRet111111111111111:", reqClickUrl)
            HttpManager.getURL(reqClickUrl, WeChatShared.feedbackSharedCB)            
        end

    elseif res_type==WeChatShared.UseShareType.SYSTEMSHARE or res_type == WeChatShared.UseShareType.SYSTEM_SHARE_TXT then
        -- nothing
    end
end

-- 服务器返回分享反馈结果
-- code    Int 返回码：0 成功
-- msg String  返回消息
-- data    Object  返回数据
WeChatShared.feedbackSharedCB = function(retInfo)
    Log.i("WeChatShared.feedbackSharedCB  finish", retInfo)
end

-- 解密方案
WeChatShared.decodeSharedData = function(encryptData)
    Log.i("WeChatShared.decodeSharedData:", encryptData)
    local newEncryptData = WeChatShared.decodeSharedDataMethod(encryptData)

    newEncryptData = WeChatShared.decodeSharedDataMethod(newEncryptData)

    newEncryptData = json.decode(newEncryptData)   

    return newEncryptData
end

WeChatShared.decodeSharedDataMethod = function(encryptData)
    Log.i("WeChatShared.decodeSharedData encrypdata:", encryptData)
    local newEncryptData = encryptData
    local dataLen = #encryptData
    local newEncryptDataFirst = string.sub(encryptData, 1,1)
    local newEncryptDataBack = string.sub(encryptData, dataLen,dataLen)

    local newEncryptDataInner = string.sub(encryptData, 2,dataLen-1)

    newEncryptData = newEncryptDataBack .. newEncryptDataInner .. newEncryptDataFirst    

    Log.i("WeChatShared.decodeSharedData encrypdata 2:", newEncryptData)

    newEncryptData = crypto.decodeBase64(newEncryptData)

    Log.i("WeChatShared.decodeSharedData decodedata:", newEncryptData)
    return newEncryptData
end


