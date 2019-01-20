-----------------------------------------------------------
--  @file   ClubMatchRecord.lua
--  @brief  亲友圈
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local ClubMatchRecordProcesser = class("ClubMatchRecordProcesser",SocketProcesser)
local SearchRange = 6
if IsPortrait then -- TODO
    SearchRange = 3
end

ClubMatchRecordProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_RECORD_INFO]     = ClubMatchRecordProcesser.directForward;
}

local ClubMatchRecord = class("ClubMatchRecord", UIWndBase)
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")

local enShowType = {
    All = 1,
    Owner = 2,
    Winer = 3,
}

function ClubMatchRecord:ctor(clubInfo)
    self.super.ctor(self,"hall/clubMatchRecord.csb")
    self.clubInfo = clubInfo

    self.m_SocketProcesser = ClubMatchRecordProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubMatchRecord:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

function ClubMatchRecord:sendSearchRecord()
    LoadingView.getInstance():show()
    local sendData = {}
    sendData.clI = self.clubInfo.clubID
    sendData.stT = self.mStartTime
    sendData.enT = self.mEndTime
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_RECORD_INFO, sendData)
end

function ClubMatchRecord:btnCallBack(widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        elseif IsPortrait and widget:getName() == "btn_sure" then -- TODO
            self:keyBack()
        elseif widget:getName() == "btn_search" then
            self:sendSearchRecord()
        end
    end
end


--做成单选 所以不判断eventType
function ClubMatchRecord:checkBoxCallFunc(checkBox)
    self.checkBoxAll:setSelected(false)
    self.checkBoxAsWiner:setSelected(false)
    self.checkboxAsOwner:setSelected(false)
    if IsPortrait then -- TODO
        self.checkBoxAll.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
        self.checkBoxAsWiner.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
        self.checkboxAsOwner.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
        checkBox:setSelected(true)
        checkBox.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
    else
        self.checkBoxAll.labTxt:setColor(cc.c3b(255, 255, 255))
        self.checkBoxAsWiner.labTxt:setColor(cc.c3b(255, 255, 255))
        self.checkboxAsOwner.labTxt:setColor(cc.c3b(255, 255, 255))
        checkBox:setSelected(true)
        checkBox.labTxt:setColor(cc.c3b(38, 204, 38))
    end

    local needRefresh =  false
    if checkBox == self.checkBoxAsWiner then
        needRefresh = self.showType ~= enShowType.Winer
        self.showType = enShowType.Winer
    elseif checkBox == self.checkboxAsOwner then
        needRefresh = self.showType ~= enShowType.Owner
        self.showType = enShowType.Owner
    else
        needRefresh = self.showType ~= enShowType.All
        self.showType = enShowType.All
    end

    if needRefresh then
        self:refreshRecord(self.mRecordData.li, self.showType)
    end
end

function ClubMatchRecord:onInit()
    if IsPortrait then -- TODO
        local btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
        btn_sure:addTouchEventListener(handler(self, self.btnCallBack))
        local labKeepDataTip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_keepDataTip")
        labKeepDataTip:setString("注:每条记录保留".. tostring(SearchRange) .."天")
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self, self.btnCallBack))
    local btn_search = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_search")
    btn_search:addTouchEventListener(handler(self, self.btnCallBack))


    self.lab_recordDesc = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_recordDesc")

    local panelStartTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_startTime")
    local panelEndTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_endTime")

    self.labStartTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_startTime")
    self.labEndTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_endTime")

    self.listStartTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"list_startTime")
    self.listEndTime = ccui.Helper:seekWidgetByName(self.m_pWidget,"list_endTime")

    self.markStartDropSt = ccui.Helper:seekWidgetByName(self.m_pWidget,"mark_startDropSt")
    self.markEndDropSt = ccui.Helper:seekWidgetByName(self.m_pWidget,"mark_endDropSt")

    self.checkBoxAll = ccui.Helper:seekWidgetByName(self.m_pWidget,"checkbox_all")
    self.checkBoxAsWiner = ccui.Helper:seekWidgetByName(self.m_pWidget,"checkbox_asWiner")
    self.checkboxAsOwner = ccui.Helper:seekWidgetByName(self.m_pWidget,"checkbox_asOwner")

    self.checkBoxAll.labTxt = ccui.Helper:seekWidgetByName(self.checkBoxAll,"lab_txt")
    self.checkBoxAsWiner.labTxt = ccui.Helper:seekWidgetByName(self.checkBoxAsWiner,"lab_txt")
    self.checkboxAsOwner.labTxt = ccui.Helper:seekWidgetByName(self.checkboxAsOwner,"lab_txt")

    local btn_all = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_all")
    local btn_asWiner = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_asWiner")
    local btn_asOwner = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_asOwner")
    self:addWidgetClickFunc(btn_all, function() self:checkBoxCallFunc(self.checkBoxAll) end)
    self:addWidgetClickFunc(btn_asWiner, function() self:checkBoxCallFunc(self.checkBoxAsWiner) end)
    self:addWidgetClickFunc(btn_asOwner, function() self:checkBoxCallFunc(self.checkboxAsOwner) end)


    local recordModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "recordItemModel")
    self.matchList = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_matchRecords")
    self.matchList:setItemModel(recordModel:clone())
    recordModel:setVisible(false)


    local touchNode = cc.Node:create()
    self.m_pWidget:addChild(touchNode, 999999)
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        if (self.listStartTime:isVisible() and self.listStartTime:hitTest(location))
            or (self.listEndTime:isVisible() and self.listEndTime:hitTest(location)) then
            return false
        end
        return self.listStartTime:isVisible() or self.listEndTime:isVisible()
    end

    local function onTouchEnded(touch, event)
        self.listStartTime:setVisible(false)
        self.markStartDropSt:setBrightStyle(ccui.BrightStyle.normal)
        self.listEndTime:setVisible(false)
        self.markEndDropSt:setBrightStyle(ccui.BrightStyle.normal)
    end
    local touchListener = cc.EventListenerTouchOneByOne:create()
    touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    touchListener:setSwallowTouches(true)
    local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchListener, touchNode)

    self.lab_recordDesc:setString("点击搜索查询战绩")

    self:addWidgetClickFunc(panelStartTime, function() self:ShowStartTimeList() end)
    self:addWidgetClickFunc(panelEndTime, function() self:ShowEndTimeList() end)

    self.showType = enShowType.All
    self.checkBoxAll:setSelected(true)

    local curTime = os.time() + kSystemConfig:getTimeOffset()
    self.mStartTime = 0
    self.mEndTime = 0
    
    self:setEndTime(curTime)
    self:setStartTime(curTime)
    self.mRecordData = {}

    self:sendSearchRecord()
end

function ClubMatchRecord:setStartTime(time)
    local y = tonumber(os.date("%Y", time))
    local m = tonumber(os.date("%m", time))
    local d = tonumber(os.date("%d", time))
    
    self.mStartTime = os.time({year=y, month=m, day=d,hour=0, min=0,sec= 0});
    self.labStartTime:setString(string.format("%d-%d-%d", y, m, d))

    if self.mEndTime < self.mStartTime then
        self:setEndTime(time)
    end
end

function ClubMatchRecord:setEndTime(time)
    local y = tonumber(os.date("%Y", time))
    local m = tonumber(os.date("%m", time))
    local d = tonumber(os.date("%d", time))

    self.mEndTime = os.time({year=y, month=m, day=d,hour=23, min=59,sec= 59});
    self.labEndTime:setString(string.format("%d-%d-%d", y, m, d))

    if self.mEndTime < self.mStartTime then
        self:setStartTime(time)
    end
end

function ClubMatchRecord:ShowStartTimeList()
    local curTime = os.time() + kSystemConfig:getTimeOffset()
    self.listStartTime:removeAllChildren()
    self.listStartTime:setVisible(true)
    self.markStartDropSt:setBrightStyle(ccui.BrightStyle.highlight)
    local width = self.listStartTime:getContentSize().width
    for i=0, SearchRange do
        local text = ccui.Text:create()
        local time = curTime - 60*60*24*i
        text:setString(os.date("%Y-%m-%d", time))
        text:setFontSize(28)
        text:setFontName("res_TTF/1016001.TTF")
        text:setPosition(width/2, text:getContentSize().height/2)

        local lay = ccui.Layout:create()
        lay:setContentSize(cc.size(width, text:getContentSize().height))
        lay:addChild(text)
        lay:setTouchEnabled(true)
        self:addWidgetClickFunc(lay,
            function()
                self.listStartTime:setVisible(false)
                self.markStartDropSt:setBrightStyle(ccui.BrightStyle.normal)
                self:setStartTime(time)
            end)

        self.listStartTime:pushBackCustomItem(lay)
    end
    self.listStartTime:doLayout()
    local width = self.listStartTime:getContentSize().width
    local height = self.listStartTime:getInnerContainerSize().height
    self.listStartTime:setContentSize(cc.size(width, height))
    self.listStartTime:setPosition(self.listStartTime:getPositionX(), -1*height - 4)
end

function ClubMatchRecord:ShowEndTimeList()
    local curTime = os.time() + kSystemConfig:getTimeOffset()
    self.listEndTime:removeAllChildren()
    self.listEndTime:setVisible(true)
    self.markEndDropSt:setBrightStyle(ccui.BrightStyle.highlight)
    local width = self.listEndTime:getContentSize().width
    for i=0, SearchRange do
        local text = ccui.Text:create()
        local time = curTime - 60*60*24*i
        text:setString(os.date("%Y-%m-%d", time))
        text:setFontSize(28)
        text:setFontName("res_TTF/1016001.TTF")
        text:setPosition(width/2, text:getContentSize().height/2)

        local lay = ccui.Layout:create()
        lay:setContentSize(cc.size(width, text:getContentSize().height))
        lay:addChild(text)
        lay:setTouchEnabled(true)
        self:addWidgetClickFunc(lay,
            function()
                self.listEndTime:setVisible(false)
                self.markEndDropSt:setBrightStyle(ccui.BrightStyle.normal)
                self:setEndTime(time)
            end)

        self.listEndTime:pushBackCustomItem(lay)
    end
    self.listEndTime:doLayout()
    local width = self.listEndTime:getContentSize().width
    local height = self.listEndTime:getInnerContainerSize().height
    self.listEndTime:setContentSize(cc.size(width, height))
    self.listEndTime:setPosition(self.listEndTime:getPositionX(), -1*height - 4)
end

function ClubMatchRecord:refreshRecord(matchsData, showType)
    self.matchList:removeAllChildren()
    local myId = kUserInfo:getUserId()

    if showType == nil then showType = 1 end

    if type(matchsData) ~= "table" then
        self.lab_recordDesc:setString("当前日期无战绩记录")
        return
    end
    local mjDescMap = kFriendRoomInfo:getMjDescInfoMap()


    local winCount = 0
    local ownCount = 0
    for i,data in ipairs(matchsData) do
        if data.owI == myId then ownCount = ownCount + 1 end
        local isMyWin = table.indexof(data.wiI, myId) and true
        if isMyWin then
            winCount = winCount + 1
        end

        if showType == enShowType.All
            or (showType == enShowType.Owner and data.owI == myId) 
            or (showType == enShowType.Winer and isMyWin) then

            self.matchList:pushBackDefaultItem()
            local lay = self.matchList:getItem(#self.matchList:getItems() - 1)
            for j=1, 4 do
                local playerPanel = ccui.Helper:seekWidgetByName(lay, string.format("player_panel_%d", j))
                if #data.usL >= j then
                    local gameId = data.gaI or (data.usL[j].exM and ata.usL[j].exM["gameId"])
                    local userInfo = Util.formatMatchRecordUserInfo(data.usL[j], gameId)

                    local head = ccui.Helper:seekWidgetByName(playerPanel, "img_head")


                    if userInfo.headImgUrl and string.len(userInfo.headImgUrl) > 4 then
                        local imgName = userInfo.playerID .. ".jpg"
                        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
                        if io.exists(headFile) then
                            if IsPortrait then -- TODO
                                head:loadTexture(headFile)
                            else
                                head:removeAllChildren()
                                local cirHead = CircleClippingNode.new(headFile, true, head:getContentSize().width)
                                cirHead:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
                                head:addChild(cirHead)
                            end
                        else
                            self.netImgsTable[imgName] = head
                            HttpManager.getNetworkImage(userInfo.headImgUrl, imgName)
                        end
                    end

                    --房主名字和成绩
                    local labPlayerName = ccui.Helper:seekWidgetByName(playerPanel, "player_name")
                    local nickName = ""
                    nickName = ToolKit.subUtfStrByCn(userInfo.playerName, 0,5,"")
                    Util.updateNickName(labPlayerName, nickName)
                    local opacity = myId == userInfo.playerID and 255 or 220
                    labPlayerName:setOpacity(opacity)

                    local playerScore = ccui.Helper:seekWidgetByName(playerPanel, "lab_score")
                    playerScore:setString(userInfo.scoreStr)
                    playerScore:setColor(userInfo.scoreClr)

                    if data.gaI == 20011 and userInfo.shengji == 1 then
                        if tonumber(userInfo.scoreStr) > 0 then
                            playerScore:setString("过"..(userInfo.scoreStr+1))
                            if data.gaI == 20011 then
                                if data.roC == 40 then 
                                    if userInfo.scoreStr+1 > 6 then
                                        playerScore:setString("过6")
                                    end
                                elseif data.roC == 80 then 
                                    if userInfo.scoreStr+1 > 10 then
                                        playerScore:setString("过10")
                                    end
                                elseif data.roC == 120 then 
                                    if userInfo.scoreStr+1 > 14 then
                                        playerScore:setString("过A")
                                    end
                                end                    
                            end
                            playerScore:setColor(userInfo.scoreClr)
                        elseif tonumber(userInfo.scoreStr) <= 0 then
                            playerScore:setVisible(false)
                        end
                    end
                    
                    --房主标记和大赢家标记
                    local ownerMark = ccui.Helper:seekWidgetByName(playerPanel, "img_room_owner")
                    local winnerMark = ccui.Helper:seekWidgetByName(playerPanel, "img_winer")
                    ownerMark:setVisible(data.owI == userInfo.playerID)
                    winnerMark:setVisible(table.indexof(data.wiI, userInfo.playerID) and true)
                else
                    playerPanel:setVisible(false)
                end
            end

            --设置麻将信息
            local lab_mjName = ccui.Helper:seekWidgetByName(lay, "lab_mjName")
            local lab_roundNum = ccui.Helper:seekWidgetByName(lay, "lab_roundNum")
            local lab_roomId = ccui.Helper:seekWidgetByName(lay, "lab_roomId")
            local lab_time = ccui.Helper:seekWidgetByName(lay, "lab_time")

            lab_mjName:setString((data.gaI and mjDescMap[data.gaI]) and mjDescMap[data.gaI].gameName or "麻将")
            lab_roundNum:setString(tostring(data.roC).."局")
            if tonumber(data.gaI) == 20011 then
                if tonumber(data.roC) == 40 then 
                    lab_roundNum:setString("过6")
                elseif tonumber(data.roC) == 80 then 
                    lab_roundNum:setString("过10")
                elseif tonumber(data.roC) == 120 then 
                    lab_roundNum:setString("过A")
                end                    
            end
            lab_roomId:setString(tostring(data.roID))
            lab_time:setString(tostring(data.da).." "..tostring(data.ti))
            lab_time:setFontSize(22)
        end
    end

    if #matchsData > 0 then
        self.lab_recordDesc:setString(string.format("大赢家次数：%d次  担任房主次数：%d次", winCount, ownCount))
    else
        self.lab_recordDesc:setString("当前日期无战绩记录")
    end
end

function ClubMatchRecord:onResponseNetImg(imgName)
    local headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if not tolua.isnull(headImg) and io.exists(imageName) then
        if IsPortrait then -- TODO
            headImg:loadTexture(imageName);
        else
            headImg:removeAllChildren()
            local cirHead = CircleClippingNode.new(imageName, true, 80)
            cirHead:setPosition(headImg:getContentSize().width/2, headImg:getContentSize().height/2)
            headImg:addChild(cirHead)
        end
    end
end

function ClubMatchRecord:showRecordList(packInfo)
    LoadingView.getInstance():hide()
    self.mRecordData = checktable(packInfo)
    self:refreshRecord(self.mRecordData.li, self.showType)
end
-- 返回战绩
ClubMatchRecord.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_RECORD_INFO] = ClubMatchRecord.showRecordList
}

return ClubMatchRecord