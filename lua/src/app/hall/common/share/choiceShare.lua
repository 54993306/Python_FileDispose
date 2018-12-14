-----------------------------------------------------------
--  @file   choiceShare.lua
--  @brief  选择分享界面
--  @author At.Lin
--  @DateTime:2018-10-29 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local choiceShare = class("choiceShare" , UIWndBase)
local ShareToWX = require "app.hall.common.ShareToWX"
local UmengClickEvent = require("app.common.UmengClickEvent")
local _Widget = {
    btn_xianliao        = "btn_xianliao",       -- 闲聊按钮
    btn_wechat          = "btn_wechat",         -- 微信按钮
    btn_close           = "btn_close",          -- 关闭界面
    pan_circle          = "pan_circle",         -- 选择前往闲聊或微信提示面板
    btn_wechat2         = "btn_wechat2",        -- 前往微信
    btn_xianliao2       = "btn_xianliao2",      -- 前往闲聊
    lab_str             = "lab_str",            -- 提示内容
    pan_choice2         = "pan_choice2",        -- 横版分享界面
    pan_choice          = "pan_choice",        -- 横版分享界面
}

-- 构造函数
function choiceShare:ctor(data)
    if IsPortrait and data.type == "roompicture" then
        self.super.ctor(self,"hall/choiceShare_horizontal.csb",data)
    else
        self.super.ctor(self,"hall/choiceShare.csb",data)
    end
    -- self.super.ctor(self,"hall/choiceShare.csb",data)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
end

function choiceShare:onInit()
    self.pan_choice = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.pan_choice) -- 横版分享界面
    self.pan_circle = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.pan_circle)   -- 提示亲友圈已复制界面
    self.lab_str = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_str)   -- 提示亲友圈已复制界面

    self.btn_xianliao = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_xianliao)
    self.btn_xianliao:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_wechat = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_wechat)
    self.btn_wechat:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_close)
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_wechat2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_wechat2)
    self.btn_wechat2:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_xianliao2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_xianliao2)
    self.btn_xianliao2:addTouchEventListener(handler(self, self.onClickButton))

    self.pan_circle:setVisible(self.m_data.type == "text")   -- 亲友圈的分享要屏蔽掉按钮显示新的按钮
    self.btn_xianliao:setVisible(self.m_data.type ~= "text")
    self.btn_wechat:setVisible(self.m_data.type ~= "text")
end

-- 做兼容模式判断
function choiceShare:notCompatible()
    if device.platform == "ios" then
        if not COMPATIBLE_VERSION or tonumber(COMPATIBLE_VERSION) < 1 then
            self:keyBack()
            local data = {}
            data.type = 2
            data.content = "您需要安装新版本才能使用此功能！请联系客服获取最新下载地址！"
            data.yesCallback = function()
                local data1 = {};
                data1.cmd = NativeCall.CMD_KE_FU;
                data1.uid, data.uname = kUserInfo:getKfUserInfo()
                NativeCall.getInstance():callNative(data1, function()end);
                NativeCallUmengEvent(UmengClickEvent.MoreKeFuOnline)
            end

            data.cancalCallback = function()
            end

            data.closeCallback = function()
            end

            data.yesStr = "联系客服"                               --确定按钮文本
            data.cancalStr = "取消"                            --取消按钮文本
            UIManager:getInstance():pushWnd(CommonDialog, data)

            return true
        end
    end
    return false
end

-- 按钮点击回调
function choiceShare:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then return end
    if pWidget:getName() == _Widget.btn_close then  -- 获取验证码
        self:keyBack()
    elseif pWidget:getName() == _Widget.btn_wechat or
           pWidget:getName() == _Widget.btn_wechat2  then
        if self.m_data.type == "roompicture" then  -- 分享图片
            Log.i("roompicture")
            UIManager.getInstance():popWnd(self, true);
        else
            self:keyBack()
        end
        self.m_data.shareToWechat()
    elseif pWidget:getName() == _Widget.btn_xianliao or
           pWidget:getName() == _Widget.btn_xianliao2 then
        if self:notCompatible() then              -- 不是兼容的包不启用新功能
            return
        end
        if self.m_data.type == "room" then        -- 分享房间信息
            self:shareXianLiao()
        elseif self.m_data.type == "text" then    -- 分享文本内容
            self:shareText()
        elseif self.m_data.type == "circle" then  -- 分享文本和链接
            self:shareText()
        elseif self.m_data.type == "roompicture" then  -- 分享图片
            -- self:keyBack()
            Log.i("roompicture")
            UIManager.getInstance():popWnd(self, true);
            self:shareTexture()
        elseif self.m_data.type == "club" then
            self:shareClub()
        else
            Log.e(" choiceShare:onClickButton ")
        end
        self:keyBack()
    else
        Log.i(" [ Tips ] choiceShare:onClickButton name not define ")
    end
    self:keyBack()
end

-- 获取分享防屏蔽的链接
function choiceShare:shareXianLiao()
    -- WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.FRIEND_ROOM_FRIEND, callBack, ShareToWX.PaijuShareFriend, data)
    local data = {}
    data.cmd = NativeCall.CMD_GET_PHONEINFO
    NativeCall.getInstance():callNative(data,function(phoneInfo)
        Log.i("choiceShare shareXianLiao", phoneInfo);
        if not phoneInfo then
            Log.e("choiceShare:shareXianLiao 1")
            self:shareRoom()
            return
        end
        local package_name = ""
        if (phoneInfo.packageName and string.len(phoneInfo.packageName)>0) or  -- ios 返回的格式
           (phoneInfo["package Name"] and string.len(phoneInfo["package Name"])>0) then  -- android 返回的格式
            if phoneInfo["package Name"] then
                package_name = phoneInfo["package Name"]
            else
                package_name = phoneInfo.packageName
            end
        else
            Log.e("choiceShare:shareXianLiao 2")
            self:shareRoom()
            return
        end
        -- 获取包名后组装请求Url获取分享链接和AppID
        -- 组装分享请求url
        local reqShareUrl = string.format("%s?userid=%d&package_name=%s&share_type=%d&source=%d&ts=%d&place_id=%d&play_id=%d",
                                            _WeChatSharedBaseUrl,
                                            kUserInfo:getUserId(),
                                            package_name,
                                            WeChatShared.ShareType.FRIENDS,
                                            WeChatShared.SourceType.FRIEND_ROOM_FRIEND,
                                            os.time(),
                                            SettingInfo.getInstance():getSelectAreaPlaceID(),
                                            kFriendRoomInfo:getGameID())

        Log.i("choiceShare:shareXianLiao url ", reqShareUrl)
        -- http://app75.stevengame.com/Api/getConfig?userid=3310753979&package_name=com.dashengzhangyou.pykf.lailaiguangdong&share_type=1&source=5&ts=1542960386&place_id=55370101&play_id=20010
        -- 从PHP服务器获取分享数据
        HttpManager.getURL(reqShareUrl, function(recData)
            local phpData = json.decode(recData)
            local function decode_str(str)
                local DataFirst = string.sub(str, 1,1)
                local DataBack = string.sub(str, #str,#str)
                local DataInner = string.sub(str, 2,#str-1)
                return crypto.decodeBase64(DataBack .. DataInner .. DataFirst)
            end
            local shareData = decode_str(phpData.data)
            shareData = decode_str(shareData)
            shareData = json.decode(shareData)
            -- {
            --     ["appid"] = wx0de318c6a747b122;
            --     ["link_id"] = 236;
            --     ["desc"] = 跑得快,dd局,快来玩！;
            --     ["link"] = http://s1.eidneit.top/index.html?gameId=4444;
            --     ["source"] = 5;
            --     ["thumbimg"] = ;
            --     ["res_type"] = 1;    -- 用来控制是动态 分享还是系统分享
            --     ["title"] = 【跑得快】房间号:d;
            --     ["conf_id"] = 5;
            -- };
            self:shareRoom(shareData.link)
            Log.i("=============== >>> shareData : " , shareData)
        end)
    end)
end
-- 闲聊分享房间
function choiceShare:shareRoom(url)
    local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
    local playerInfo = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
    selectSetInfo.RoJST = playerInfo.RoJST
    selectSetInfo.plS = playerInfo.plS
    selectSetInfo.clI = playerInfo.clI  --俱樂部id
    local data = {};
    data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    if roomInfo.gameId == 20009 then
        data.desc = "斗地主" .. data.desc
    elseif roomInfo.gameId == 20010 then
        data.desc = "跑得快" .. data.desc
    end
    local oldurl = roomInfo.shareLink .. "&code=" .. playerInfo.pa..ShareToWX.PaijuShareFriend
    url = url or oldurl
    data.url = url                      -- 已经废弃的url地址
    data.imgPath = "1111"               -- 分享所使用的图标，默认使用游戏图标
    data.roomId = playerInfo.pa
    data.roomToken = "2222"
    data.cmd = NativeCall.CMD_XIANLIAO_SHARE_ROOM
    NativeCall.getInstance():callNative(data, function(data)
        Toast.getInstance():show(" 提示：闲聊分享失败，未检测到闲聊App ")
    end)
    Log.i("============choiceShare:shareRoom" , data)
end

-- 闲聊分享文本内容,分享落地页为相同的分享方式
function choiceShare:shareText()
    local data = {}
    -- data.url = "http://download.stevengame.com/client-data/project_1/android/guangdongmj/app_guangdongmj-V1.2.13-201808041931-release.apk"
    -- data.str = "进来一起游戏吧 : " .. data.url
    data.str = self.m_data.str or ""
    data.cmd = NativeCall.CMD_XIANLIAO_SHARE_TEXT
    NativeCall.getInstance():callNative(data, function(data)
        Toast.getInstance():show(" 提示：闲聊分享失败，未检测到闲聊App ")
    end)
    Log.i("============choiceShare:shareText")
end

-- 闲聊分享文本内容,分享落地页为相同的分享方式
function choiceShare:shareClub()
    local serverDayShareInfo = kServerInfo:getDayShareInfo()
    local data = {}
    data.roomId = "0"
    data.imgPath = "1111"
    data.roomToken = "2222"
    data.cmd = NativeCall.CMD_XIANLIAO_SHARE_ROOM;
    data.title = serverDayShareInfo.shareTitle or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle;
    data.desc = serverDayShareInfo.shareDesc or kFriendRoomInfo:getRoomBaseInfo().dwShareDesc;
    data.url = serverDayShareInfo.shareLink or kFriendRoomInfo:getRoomBaseInfo().downloadLink;
    data.url = data.url..WeChatShared._sharePath
    NativeCall.getInstance():callNative(data, function(data)
        Toast.getInstance():show(" 闲聊房间分享错误，请联系客服 ")
    end)
    Log.i("============shareClub " , data)
end

-- 闲聊分享图片
function choiceShare:shareTexture()
    display.captureScreen(function()
        local data = {};
        data.cmd = NativeCall.CMD_XIANLIAO_SHARE_PICTURE;
        NativeCall.getInstance():callNative(data, function(data)
        Toast.getInstance():show(" 提示：闲聊分享失败，未检测到闲聊App ")
    end);
    end , CACHEDIR .. "screen.jpg");
end

return choiceShare
