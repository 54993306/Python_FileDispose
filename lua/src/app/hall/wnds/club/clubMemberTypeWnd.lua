-----------------------------------------------------------
--  @file   clubMemberTypeWnd.lua
--  @brief  亲友圈
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ClubTips = require("app.hall.wnds.club.clubtips")
local CommonTips = require "app.hall.common.CommonTips"
local choiceShare = require("app.hall.common.share.choiceShare")
local ClubMemberTypeWndProcesser = class("ClubMemberTypeWndProcesser",SocketProcesser)

ClubMemberTypeWndProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_QUITCLUB]     = ClubMemberTypeWndProcesser.directForward;
}

local BtnSureText = "邀请好友"

local ClubMemberTypeWnd = class("ClubMemberTypeWnd", UIWndBase)

function ClubMemberTypeWnd:ctor(clubData, mode)
    self.super.ctor(self,"hall/clubMemberTypeWnd.csb", clubData)
    self.mode = mode
    self.clubInfo = clubData or {}

    self.m_SocketProcesser = ClubMemberTypeWndProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubMemberTypeWnd:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

local function btnCallBack(self, widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        elseif widget:getName() == "btn_sure" then
            local str = string.format("进入游戏→打开亲友圈→输入亲友圈ID：%s，即可加入亲友圈，快速组局，秒开！", tostring(self.clubInfo.clubID))
            local shareToWechat = function()
                local data = {}
                data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
                data.content = str
                Log.i("-----copy code----->" .. data.content)
                NativeCall.getInstance():callNative(data);
                -- local CommonTips = require "app.hall.common.CommonTips"
                -- local data = {}
                -- data.content = "亲友圈ID已复制，请前往微信分享"
                -- UIManager.getInstance():pushWnd(CommonTips, data)
                local data2 = {}
                data2.cmd = NativeCall.CMD_OPEN_WEIXIN
                NativeCall.getInstance():callNative(data2, function(info)
                    if info.errCode and info.errCode == -1 then
                        Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
                    end
                end);
            end
            local data1 = {}
            data1.shareToWechat = shareToWechat
            data1.type = "text"
            data1.str = str
            UIManager.getInstance():pushWnd(choiceShare, data1)
        elseif widget:getName() == "btn_applyExit" then
            local info = clone(self.m_data)
            info.type = 1
            self.ClubTips = UIManager.getInstance():pushWnd(ClubTips, info)
        end
    end
end

function ClubMemberTypeWnd:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self,btnCallBack))

    local btn_applyExit = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_applyExit")
    btn_applyExit:addTouchEventListener(handler(self,btnCallBack))

    local btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
    btn_sure:addTouchEventListener(handler(self,btnCallBack))
    if not IsPortrait then -- TODO
        btn_sure:setTitleText(BtnSureText)
    end

    if self.mode then
        btn_applyExit:setVisible(false)
        -- btn_sure:setVisible(true)
    else
        btn_applyExit:setVisible(true)
        -- btn_sure:setVisible(false)
    end
    local clubName = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubName")
    local clubFounder = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubFounder")
    local clubId = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubId")
    local clubMemNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubMemNum")

    Util.updateNickName(clubName, ToolKit.subUtfStrByCn(self.m_data.clubName, 0, 7, "..."))
    Util.updateNickName(clubFounder, ToolKit.subUtfStrByCn(self.m_data.clubOwnerName, 0, 7, "..."))
    clubId:setString(tostring(self.m_data.clubID or ""))
    clubMemNum:setString(tostring(self.m_data.clubMemNum or ""))

end

function ClubMemberTypeWnd:commonTips(str)
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.content = str;
    UIManager.getInstance():pushWnd(CommonTips, data);
end

-- 退出亲友圈结果返回
function ClubMemberTypeWnd:onQuitClubReceive(info)
    LoadingView.getInstance():hide()

    if self.ClubTips then
       UIManager.getInstance():popWnd(self.ClubTips);
       self.ClubTips = nil
    end

    if info.re == 2 then
        self:commonTips("您是管理员，不能退出自己的亲友圈")
    elseif info.re == 1 then
        self:commonTips("亲友圈不存在")
    elseif info.re == 3 then
        self:commonTips("您已经不是该亲友圈亲友")
    elseif info.re == 4 or info.re == 0 then
        self:commonTips("您的申请已提交\n请等待管理员审批")
        self:keyBack()
    else
        self:commonTips("数据错误请联系客服处理")
    end
end

ClubMemberTypeWnd.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_QUITCLUB] = ClubMemberTypeWnd.onQuitClubReceive,
}


return ClubMemberTypeWnd
