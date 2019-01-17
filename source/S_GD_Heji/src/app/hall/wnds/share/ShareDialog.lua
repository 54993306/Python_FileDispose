-------------------------------------------------------------
--  @file   ShareDialog.lua
--  @brief  分享对话框
--  @author Zhu Can Qin
--  @DateTime:2016-09-25 15:45:33
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local ShareToWX = require "app.hall.common.ShareToWX"
local BackEndStatistics = require("app.common.BackEndStatistics")
local UmengClickEvent = require("app.common.UmengClickEvent")

ShareDialog = class("ShareDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn         = "close_btn",
    tagTableView        = "listView",
    tagWeixinBtn        = "weixin_btn",
    tagFriendGroupBtn   = "friend_group_btn",
}

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ShareDialog:ctor(...)
    self.super.ctor(self, "hall/shareDialog.csb")
    self.m_data = ... or {}
    if self.m_data.resCsb then--csb路径
        self.super.ctor(self, self.m_data.resCsb)
    else
        self.super.ctor(self, "hall/shareDialog.csb")
    end
    self.m_giftBaseInfo = self.m_data.baseGiftData;
    self.m_logicData    = self.m_data.logicData
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function ShareDialog:onShow()
    print("onShow")

end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function ShareDialog:onClose()
    print("onClose")
    
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function ShareDialog:onInit()
    self.buttonClose = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.buttonClose:addTouchEventListener(handler(self, self.onClickButton))

    self.weiXinFriend = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagWeixinBtn)
    self.weiXinFriend:addTouchEventListener(handler(self, self.onClickButton))

    self.friendCircle = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagFriendGroupBtn)
    self.friendCircle:addTouchEventListener(handler(self, self.onClickButton))
    
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function ShareDialog:onClickButton(pWidget, EventType)
    print(EventType)
    if EventType == ccui.TouchEventType.ended then
    SoundManager.playEffect("btn");
        if pWidget == self.buttonClose then
            self:keyBack()
        elseif pWidget == self.weiXinFriend then
            Util.disableNodeTouchWithinTime(pWidget)
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
            -- data.type = 2;
            -- --修改 20171114 start 点击分享 diyal.yin
            -- data.headUrl = "";
            -- --修改 20171114 end 点击分享 diyal.yin
            -- --LoadingView.getInstance():show("正在分享,请稍后...", 2);
            -- TouchCaptureView.getInstance():showWithTime()
            -- NativeCall.getInstance():callNative(data, self.shareResult, self);
            -- ShareToWX.getInstance():shareToHaoYouQun(self.shareResult, self, ShareToWX.ShareFriendQun)
            LoadingView.getInstance():show("正在分享,请稍后...", 1);
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_NO_REWARD_FRIEND, handler(self, self.shareResult), ShareToWX.ShareFriendQun)
            if IsPortrait then -- TODO
                local data = {}
                data.wa = BackEndStatistics.HallShareGroup
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallShareGroupButton)
            end
        elseif pWidget == self.friendCircle then
            Util.disableNodeTouchWithinTime(pWidget)
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
            -- data.type = 1;
            -- --LoadingView.getInstance():show("正在分享,请稍后...", 2);
            -- TouchCaptureView.getInstance():showWithTime()
            -- NativeCall.getInstance():callNative(data, self.shareResult, self);
            LoadingView.getInstance():show("正在分享,请稍后...", 2);
            local data = {}
            data.shardMold = 5
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_NO_REWARD, handler(self, self.shareResult), ShareToWX.ShareFriendQuan,data)
            if IsPortrait then -- TODO
                local data = {}
                data.wa = BackEndStatistics.HallShareMoments
                
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallShareCircleButton)
            end
        end
    end
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ShareDialog:shareResult(info)
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

function ShareDialog:keyBack()
    UIManager:getInstance():popWnd(ShareDialog)
end

