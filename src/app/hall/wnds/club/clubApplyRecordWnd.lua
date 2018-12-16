-----------------------------------------------------------
--  @file   ClubApplyRecordWnd.lua
--  @brief  亲友圈
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local ClubApplyRecordWnd = class("ClubApplyRecordWnd", UIWndBase)

local ClubApplyRecordProcesser = class("ClubApplyRecordProcesser",SocketProcesser)

ClubApplyRecordProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_CLUBAPPLYLIST]     = ClubApplyRecordProcesser.directForward;
}

function ClubApplyRecordWnd:ctor()
    self.super.ctor(self,"hall/clubApplyRecordWnd.csb")
    self.m_SocketProcesser = ClubApplyRecordProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubApplyRecordWnd:onClose()
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
        end
    end
end

function ClubApplyRecordWnd:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self,btnCallBack))

    local recordModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "recordModel")
    self.markNoData = ccui.Helper:seekWidgetByName(self.m_pWidget, "mark_noData")
    self.markNoData:setVisible(false)

    self.recordList = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_records")
    self.recordList:setItemModel(recordModel:clone())
    recordModel:setVisible(false)

    LoadingView.getInstance():show()
    kSystemConfig:setClubApplyChanged(false)
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CLUBAPPLYLIST, {})
end


function ClubApplyRecordWnd:refreshApplyList(applyRecordData)
    self.recordList:removeAllChildren()

    if type(applyRecordData) ~= "table" then
        self.markNoData:setVisible(true)
        return
    end

    self.markNoData:setVisible(#applyRecordData==0)
    for i,v in ipairs(applyRecordData) do
        self.recordList:pushBackDefaultItem()
        local lay = self.recordList:getItem(#self.recordList:getItems() - 1)
        local clubName = ccui.Helper:seekWidgetByName(lay, "lab_clubName")
        local clubMemNum = ccui.Helper:seekWidgetByName(lay, "lab_clubMemNum")
        local clubId = ccui.Helper:seekWidgetByName(lay, "lab_id")
        local applyType = ccui.Helper:seekWidgetByName(lay, "lab_applyType")
        local applyTime = ccui.Helper:seekWidgetByName(lay, "lab_applyTime")

        --clubName:setString(v.clubName)
        Util.updateNickName(clubName, v.clubName)
        clubId:setString(v.clubID)
        applyType:setString(v.applyType == 1 and "入会申请" or "退会申请")
        applyTime:setString(os.date("%Y-%m-%d %H:%M:%S", v.applyTime))

        local stateMark = ccui.Helper:seekWidgetByName(lay, "mark_state")
        local state_str = ccui.Helper:seekWidgetByName(lay, "state_str")
        state_str:setVisible(false)

        --0 审核中 1 同意加入 2 加入失败 3 加入亲友圈数量超限
        if v.applyState == 1 then
            stateMark:setBright(true)
            stateMark:setBrightStyle(ccui.BrightStyle.highlight)
        elseif v.applyState == 2 then
            stateMark:setBright(false)
        elseif v.applyState == 3 then
            state_str:setVisible(true)
            stateMark:setBright(false)
        else            
            stateMark:setBright(true)
            stateMark:setBrightStyle(ccui.BrightStyle.normal)
        end
    end
    self.recordList:doLayout()
    self.recordList:jumpToTop()
end

function ClubApplyRecordWnd:recClubApplyList(info)
    LoadingView.getInstance():hide()
    checktable(info)
    self:refreshApplyList(info.usAI)
end


--网络接收接口定义
ClubApplyRecordWnd.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_CLUBAPPLYLIST]    = ClubApplyRecordWnd.recClubApplyList;
}

return ClubApplyRecordWnd