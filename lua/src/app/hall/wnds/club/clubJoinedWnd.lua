-----------------------------------------------------------
--  @file   ClubJoinedWnd.lua
--  @brief  亲友圈
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local CLUB_HELP_CONTENT = {
    "亲友圈功能:",
    " ",
    "    玩家加入亲友圈之后，可以使用亲友圈钻石创建房间。只有属于相同亲友圈的玩家才能加入该房间。",
    " ",
    "    玩家可在亲友圈查询自己的亲友圈牌局信息，包括大赢家的获得者和每个人的最终成绩。",
    " ",
    "    如果想了解更多亲友圈信息，请联系管理员或在线客服。",
    " ",
}


local ClubJoinedProcesser = class("ClubJoinedProcesser",SocketProcesser)
local LocalEvent = require("app.hall.common.LocalEvent")

ClubJoinedProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_CLUBAPPLYLIST]     = ClubJoinedProcesser.directForward;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]    = ClubJoinedProcesser.directForward;
}


local ClubJoinedWnd = class("ClubJoinedWnd", UIWndBase)

local ClubApplyRecordWnd = require("app.hall.wnds.club.clubApplyRecordWnd")
local Club = require("app.hall.wnds.club.club")
local HelpWnd = require("app.hall.wnds.helpWnd")

function ClubJoinedWnd:ctor()
    self.super.ctor(self,"hall/clubJoinedWnd.csb")
    self.m_SocketProcesser = ClubJoinedProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubJoinedWnd:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

function ClubJoinedWnd:btnCallBack(widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        elseif widget:getName() == "btn_reqRecord" then
            UIManager.getInstance():pushWnd(ClubApplyRecordWnd)
        elseif widget:getName() == "btn_applyJoin" then
            UIManager.getInstance():pushWnd(Club, {type = 2})
        elseif widget:getName() == "btn_help" then
            UIManager.getInstance():pushWnd(HelpWnd, {content = CLUB_HELP_CONTENT})
        end
    end
end

function ClubJoinedWnd:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self, self.btnCallBack))

    local btn_reqRecord = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_reqRecord")
    btn_reqRecord:addTouchEventListener(handler(self, self.btnCallBack))
    local applyRedRefresh = function()
        local visible = kSystemConfig:isClubApplyChanged()
        local clubBtnSize = btn_reqRecord:getContentSize()
        Util.createRedPointTip(btn_reqRecord, visible, cc.p(clubBtnSize.width-8, clubBtnSize.height-8))
    end
    local updateClubRedPoint = cc.EventListenerCustom:create(LocalEvent.ClubApplyRedChange, applyRedRefresh)
    btn_reqRecord:getEventDispatcher():addEventListenerWithSceneGraphPriority(updateClubRedPoint, btn_reqRecord)
    applyRedRefresh()

    local btn_applyJoin = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_applyJoin")
    btn_applyJoin:addTouchEventListener(handler(self, self.btnCallBack))

    local btn_help = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_help")
    btn_help:addTouchEventListener(handler(self, self.btnCallBack))

    local clubListPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/clubListView.csb")
    local itemModel = ccui.Helper:seekWidgetByName(clubListPanel, "itemModel_club")
    if IsPortrait then -- TODO
        local lab_clubIdTitle = ccui.Helper:seekWidgetByName(itemModel,"lab_clubIdTitle")
        lab_clubIdTitle:setString("亲友圈ID:")
    end
    self.clubListView = ccui.Helper:seekWidgetByName(clubListPanel, "list_clubs")
    self.clubListView:setItemModel(itemModel:clone())
    itemModel:setVisible(false)

    local contentPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_clubs")
    clubListPanel:setContentSize(cc.size(clubListPanel:getContentSize().width, contentPanel:getContentSize().height))
    if IsPortrait then -- TODO
        clubListPanel:setPosition((contentPanel:getContentSize().width - clubListPanel:getContentSize().width)*0.5, 0)
        ccui.Helper:doLayout(clubListPanel)
    end
    contentPanel:addChild(clubListPanel)

    self:refreshList(kSystemConfig:getMyClubsInfo())
end

function ClubJoinedWnd:refreshList(data)
    self.clubListView:removeAllChildren()

    if type(data) ~= "table" then return end

    local clubClickCall = function(clubInfo)
        -- body
        local ClubRoomListWnd = require("app.hall.wnds.club.clubRoomListWnd")
        UIManager.getInstance():pushWnd(ClubRoomListWnd, clubInfo)
    end

    -- local btnClickCall = function(clubInfo)
    --     local data = {};
    --     data.clubInfo = clubInfo;
    --     UIManager:getInstance():pushWnd(FriendRoomCreate, data);
    --     -- body
    -- end

    for i,v in ipairs(data) do
        self.clubListView:pushBackDefaultItem()
        local lay = self.clubListView:getItem(i - 1)

        local lab_clubName = ccui.Helper:seekWidgetByName(lay, "lab_clubName")
        local lab_clubId = ccui.Helper:seekWidgetByName(lay, "lab_clubId")
        local lab_clubMemNum = ccui.Helper:seekWidgetByName(lay, "lab_clubMemNum")
        local lab_diamondState = ccui.Helper:seekWidgetByName(lay, "lab_diamondState")

        local btn_club = ccui.Helper:seekWidgetByName(lay, "btn_club")
        local mark_selected = ccui.Helper:seekWidgetByName(lay, "mark_selected")
        mark_selected:setVisible(false)

        if IsPortrait then -- TODO
            Util.updateNickName(lab_clubName, v.clubName)
        else
            local club_name = string.gsub(v.clubName,"亲友圈","")
            Util.updateNickName(lab_clubName, ToolKit.subUtfStrByCn(club_name, 0, 8, "...亲友圈"))
        end
        lab_clubId:setString(tostring(v.clubID))
        lab_clubMemNum:setString(tostring(v.clubMemNum))

        local diaStr, diaClr = Util.formatClubDiamondSt(v.diamondSt)
        lab_diamondState:setString(diaStr)
        lab_diamondState:setColor(diaClr)

        self:addWidgetClickFunc(btn_club, function() clubClickCall(v) end)
        -- self:addWidgetClickFunc(btn_createRoom, function() btnClickCall(v) end)
        if not IsPortrait then -- TODO
            local btn_createRoom = ccui.Helper:seekWidgetByName(lay, "btn_createRoom")
            self:addWidgetClickFunc(btn_createRoom, function() clubClickCall(v) end)
        end
    end
end

function ClubJoinedWnd:recJoinedClubList()
    self:refreshList(kSystemConfig:getMyClubsInfo())
end

--网络接收接口定义
ClubJoinedWnd.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]   = ClubJoinedWnd.recJoinedClubList;
}

return ClubJoinedWnd