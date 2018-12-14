-----------------------------------------------------------
--  @file   ClubSwitchCreateRoomWnd.lua
--  @brief  亲友圈
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ClubSwitchCreateRoomProcesser = class("ClubSwitchCreateRoomProcesser",SocketProcesser)

ClubSwitchCreateRoomProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_CLUBAPPLYLIST]     = ClubSwitchCreateRoomProcesser.directForward;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]    = ClubSwitchCreateRoomProcesser.directForward;
}

local ClubSwitchCreateRoomWnd = class("ClubSwitchCreateRoomWnd", UIWndBase)

function ClubSwitchCreateRoomWnd:ctor(clubsData, curClubID)
    self.super.ctor(self,"hall/clubSwitchCreateRoomWnd.csb", clubsData)

    self.m_curClubID = curClubID == nil and 0 or curClubID
    self.m_SocketProcesser = ClubSwitchCreateRoomProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubSwitchCreateRoomWnd:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

function ClubSwitchCreateRoomWnd:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self, self.btnCallBack))
    local clubListPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/clubListView.csb")
    if IsPortrait then -- TODO
        clubListPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/clubSwitchListView.csb")
        
        local itemModel = ccui.Helper:seekWidgetByName(clubListPanel, "itemModel_club")
        local lab_clubIdTitle = ccui.Helper:seekWidgetByName(itemModel,"lab_clubIdTitle")
        lab_clubIdTitle:setString("亲友圈ID:")
    end
    local itemModel = ccui.Helper:seekWidgetByName(clubListPanel, "itemModel_club")
    self.clubListView = ccui.Helper:seekWidgetByName(clubListPanel, "list_clubs")
    self.clubListView:setItemModel(itemModel:clone())
    itemModel:setVisible(false)

    local contentPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_clubs")
    clubListPanel:setContentSize(cc.size(clubListPanel:getContentSize().width, contentPanel:getContentSize().height))
    contentPanel:addChild(clubListPanel)

    self:refreshList(self.m_data)
end

function ClubSwitchCreateRoomWnd:refreshList(data)
    self.clubListView:removeAllChildren()

    if type(data) ~= "table" then return end

    local clubClickCall = function(clubInfo)
        local friendRoomCreateWnd = UIManager.getInstance():getWnd(FriendRoomCreate);
        if friendRoomCreateWnd then
            friendRoomCreateWnd:switchClubMode(clubInfo)
        else
            if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
                Toast.getInstance():show("服务器即将进行维护! ")
                return
            end
            local data = {};
            data.clubInfo = clubInfo;
            UIManager:getInstance():pushWnd(FriendRoomCreate, data);
        end
        UIManager:getInstance():popWnd(ClubSwitchCreateRoomWnd);
        if IsPortrait then -- TODO
            local UmengClickEvent = require("app.common.UmengClickEvent")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.CreateRoomButton)
        end
    end


    for i,v in ipairs(data) do
        local lay = nil
        if self.m_curClubID ~= v.clubID then
            self.clubListView:pushBackDefaultItem()
            lay = self.clubListView:getItem(#self.clubListView:getItems() - 1)
        else
            self.clubListView:insertDefaultItem(0)
            lay = self.clubListView:getItem(0)
        end

        local lab_clubName = ccui.Helper:seekWidgetByName(lay, "lab_clubName")
        local lab_clubId = ccui.Helper:seekWidgetByName(lay, "lab_clubId")
        local lab_clubMemNum = ccui.Helper:seekWidgetByName(lay, "lab_clubMemNum")
        local lab_diamondState = ccui.Helper:seekWidgetByName(lay, "lab_diamondState")

        local btn_club = ccui.Helper:seekWidgetByName(lay, "btn_club")
        local btn_createRoom = ccui.Helper:seekWidgetByName(lay, "btn_createRoom")
        local mark_selected = ccui.Helper:seekWidgetByName(lay, "mark_selected")

        btn_createRoom:setVisible(self.m_curClubID ~= v.clubID)
        mark_selected:setVisible(self.m_curClubID == v.clubID)

        Util.updateNickName(lab_clubName, v.clubName)
        lab_clubId:setString(tostring(v.clubID))
        lab_clubMemNum:setString(tostring(v.clubMemNum))

        local diaStr, diaClr = Util.formatClubDiamondSt(v.diamondSt)
        lab_diamondState:setString(diaStr)
        lab_diamondState:setColor(diaClr)

        self:addWidgetClickFunc(btn_club, function() clubClickCall(v) end)
        self:addWidgetClickFunc(btn_createRoom, function() clubClickCall(v) end)

        if not IsPortrait then -- TODO
            local textCreateRoom = ccui.Helper:seekWidgetByName(lay, "Label_71")
            textCreateRoom:setString("创建房间")
        end
    end
end

function ClubSwitchCreateRoomWnd:formatData(data)
    local format = clone(data)
    return format
end

function ClubSwitchCreateRoomWnd:btnCallBack(widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        end
    end
end

function ClubSwitchCreateRoomWnd:recJoinedClubList()
    self:refreshList(kSystemConfig:getMyClubsInfo())
end

--网络接收接口定义
ClubSwitchCreateRoomWnd.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]   = ClubSwitchCreateRoomWnd.recJoinedClubList;
}

return ClubSwitchCreateRoomWnd