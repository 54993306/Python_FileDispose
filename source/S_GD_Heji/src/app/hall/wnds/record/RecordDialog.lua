-------------------------------------------------------------
--  @file   RecordDialog.lua
--  @brief  战绩类定义
--  @author Zhu Can Qin
--  @DateTime:2016-09-22 12:05:19
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
RecordDialog = class("RecordDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn     = "close_btn",
    tagTableView    = "scrollView",
    tabItem         = "scrollViewItem",
}

local RecordProcesser = class("RecordProcesser", SocketProcesser)

function RecordProcesser:RecordCall(cmd,packetInfo)
    Log.i("RecordProcesser:RecordCall..", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

RecordProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_RECORD_INFO]    = RecordProcesser.RecordCall;        --邮件列表返回
}


--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RecordDialog:ctor(info)
    self.super.ctor(self, "hall/record_dialog.csb", info)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = RecordProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
    -- 请求战绩 -- 
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_RECORD_INFO)
    LoadingView.getInstance():show()
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RecordDialog:onShow()
    print("onShow")

end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function RecordDialog:onClose()
    print("onClose")
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function RecordDialog:onInit()
    if IsPortrait then -- TODO
        local UITool = require "app.common.UITool"
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.tableView  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTableView)
    self.itemUI     = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tabItem)
    if IsPortrait then -- TODO
        self.Label_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_title")
    else
        self.Label_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_title")
    end
    self.Label_title:setString("战绩记录")

    if Util.isBezelLess() and UIManager.getInstance():getScreenOrient() == 1 then
        if display.height < 720 then
            self.itemUI:retain()

            local scaleRatio = display.height/720 - 0.02
            local itemSize = self.itemUI:getContentSize()
            self.itemUI:setScale(scaleRatio)
            self.itemUI:setPosition(0, 0)
            local lay = ccui.Layout:create()
            lay:setContentSize(cc.size(itemSize.width*scaleRatio, itemSize.height*scaleRatio))

            self.itemUI:getParent():addChild(lay)
            self.itemUI:removeFromParent()
            lay:addChild(self.itemUI)
            self.itemUI = lay

        end
    end
    self.itemUI:setVisible(false)

    for i = 1, 4 do
        local p = ccui.Helper:seekWidgetByName(self.itemUI, string.format("player_panel_%d", i))
        p:setVisible(false)
    end

    self.noRecordTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "no_record_tip")
    self.noRecordTip:setVisible(false)

    self.button_close = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton));
end

function RecordDialog:getMjName(gameId)
    if self.mjNameCache == nil then self.mjNameCache = {} end
    if gameId then
        if self.mjNameCache[gameId] then
            return self.mjNameCache[gameId]
        end

        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        for k,areaData in pairs(areatable) do
            if gameId == areaData.gameId then
                self.mjNameCache[gameId] = areaData.gameName
                return areaData.gameName
            end
        end
    end
    return  "麻将"
end

--[[
-- @brief  显示战绩函数
-- @param  void
-- @return void
--]]
function RecordDialog:showRecordList(info)
    LoadingView.getInstance():hide()
    local function scrollFunc(data, mWight, nIndex)

        local time          = ccui.Helper:seekWidgetByName(mWight, "time_text")
        time:setString(data.ti)
        local date          = ccui.Helper:seekWidgetByName(mWight, "date_text")
        if IsPortrait then -- TODO
            local str_data = data.da
            str_data = string.gsub(str_data,"-",".")

            date:setString(str_data)
        else
            date:setString(data.da)
        end
        local roomNub   = ccui.Helper:seekWidgetByName(mWight, "room_num")
        roomNub:setString(data.roID)

        local mjName   = ccui.Helper:seekWidgetByName(mWight, "mj_type")
        if IsPortrait then -- TODO
            mjName:setString(self:getMjName(data.gaI))
        else
            local areatable = kFriendRoomInfo:getAreaBaseInfo()
            if #areatable > 1 then -- 当多于一个地区选项时，增加前缀
                -- mjName:setString(GC_GameName .. "-" .. self:getMjName(data.gaI))
                mjName:setString(self:getMjName(data.gaI))
            else
                mjName:setString(self:getMjName(data.gaI))
            end
        end

        local mj_ju_num   = ccui.Helper:seekWidgetByName(mWight, "mj_ju_num")
        local mj_ju   = ccui.Helper:seekWidgetByName(mWight, "mj_ju")

        if mj_ju_num and mj_ju then
            mj_ju_num:setVisible(false)
            mj_ju:setVisible(false)

            if data.roC and (data.roC ~= 0) then
                
                mj_ju_num:setVisible(true)
                if IsPortrait then -- TODO
                    mj_ju_num:setString("共"..data.roC.."局")
                else
                    mj_ju_num:setString(data.roC.."局")
                    mj_ju:setVisible(true)
                end
                if data.gaI == 20011 then
                    if data.roC == 40 then 
                        mj_ju_num:setString("过6")
                    elseif data.roC == 80 then 
                        mj_ju_num:setString("过10")

                    elseif data.roC == 120 then 
                        mj_ju_num:setString("过A")
                    end                    
                end
            end
        end
       
        for i=1, #data.usL do
            local gameId = data.gaI or (data.usL[i].exM and data.usL[i].exM["gameId"])
            local userInfo = Util.formatMatchRecordUserInfo(data.usL[i], gameId)
            local p = ccui.Helper:seekWidgetByName(mWight, string.format("player_panel_%d", i))
            p:setVisible(true)
			
            local head = ccui.Helper:seekWidgetByName(mWight, string.format("img_head_%d", i))

            if userInfo.headImgUrl and string.len(userInfo.headImgUrl) > 4 then
                local imgName = userInfo.playerID .. ".jpg"
                local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
                if io.exists(headFile) then
                    --
                    head:removeAllChildren()
                    local cirHead = CircleClippingNode.new(headFile, true, 80)
                    cirHead:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
                    if IsPortrait then -- TODO
                        head:loadTexture(headFile)
                    else
                        head:addChild(cirHead)
                    end
                else
                    self.netImgsTable[imgName] = head
                    HttpManager.getNetworkImage(userInfo.headImgUrl, imgName)
                end
            end
			
            --房主名字ID
            local nameStr       = string.format("player_name_%d", i)
            local playerName    = ccui.Helper:seekWidgetByName(mWight, nameStr) 
            local strNickName = userInfo.playerName
            local strNickNameLen = string.len(strNickName)
            local nickName = ""
            nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
            Util.updateNickName(playerName, nickName)
            local playerId = string.format("player_id_%d", i)
            local playerIdTip = ccui.Helper:seekWidgetByName(mWight, playerId)
            playerIdTip:setString(string.format("ID:%d", userInfo.playerID))


            local opacity = kUserInfo:getUserId() == userInfo.playerID and 255 or 220
            playerName:setOpacity(opacity)
            playerIdTip:setOpacity(opacity)

            --房主成绩
            local scoreStr      = string.format("player_score_%d", i)
            local playerScore   = ccui.Helper:seekWidgetByName(mWight, scoreStr) 
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


            local roomOwner = string.format("img_room_owner_%d", i)
            local roomOwnerMark = ccui.Helper:seekWidgetByName(mWight, roomOwner)
            if roomOwnerMark then
                if data.owI and data.owI ~= 0 then 
                    roomOwnerMark:setVisible(data.owI == userInfo.playerID)
                else
                    roomOwnerMark:setVisible(false)
                end
            end            

            local roomWiner = string.format("img_winer_%d", i)
            local winnerMark = ccui.Helper:seekWidgetByName(mWight, roomWiner)
            winnerMark:setVisible(table.indexof(data.wiI, userInfo.playerID) and true)

            -- 请求详细信息
            local recListBtn_1 = ccui.Helper:seekWidgetByName(mWight, "record_list_btn_1")
            local Label_1 = ccui.Helper:seekWidgetByName(mWight, "Label_86")
            Label_1:setString("战绩回放")
            if IsPortrait then -- TODO
                local Label_2 = ccui.Helper:seekWidgetByName(mWight, "Label_86_0")
                Label_2:setString("战绩回放")
            end
            recListBtn_1:addTouchEventListener(function (pWidget, EventType  )
                if EventType == ccui.TouchEventType.ended then
                    self:btnCallBack(data)
                end                
            end)
            if not IsPortrait then -- TODO
                local recListBtn = ccui.Helper:seekWidgetByName(mWight, "record_list_btn")
                recListBtn:addTouchEventListener(function (pWidget, EventType)
                    if EventType == ccui.TouchEventType.ended then
                        self:btnCallBack(data)
                    end
                end)
            end
        end
    end

    if #info.li > 0 then
        for i, v in ipairs(info.li) do
            local mWight = self.itemUI:clone()
            mWight:setVisible(true)
            scrollFunc(v, mWight)
            self.tableView:pushBackCustomItem(mWight)
        end
    else
        self.noRecordTip:setVisible(true)
    end
end

function RecordDialog:btnCallBack(data)
    SoundManager.playEffect("btn");

    local gameType = GC_GameTypes[data.gaI]
    local filePath = "src/package_src/games/"..gameType.."/hall/MatchRecordDialog.lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
    local file = io.exists(filePath)
    assert(file ~= nil)
    local moduleProxy = nil
    if not file then
        filePath = "src/package_src/games/"..gameType.."/hall/MatchRecordDialog.luac"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
        file = io.exists(filePath)
        assert(file ~= nil)
    end
    if file then
        MatchRecordDialog = require("package_src.games."..gameType..".hall.MatchRecordDialog")
    else
        MatchRecordDialog = require("app.hall.wnds.record.MatchRecordDialog")
    end
    UIManager:getInstance():pushWnd(MatchRecordDialog, {roI = data.roID, gaI = data.gaI, owI = data.owI})   
end

function RecordDialog:onResponseNetImg(imgName)
    if not imgName then return end

    local  headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if headImg and io.exists(imageName) then
        headImg:removeAllChildren()
        local cirHead = CircleClippingNode.new(imageName, true, 80)
        cirHead:setPosition(headImg:getContentSize().width/2, headImg:getContentSize().height/2)
        if IsPortrait then -- TODO
            headImg:loadTexture(imageName);
        else
            headImg:addChild(cirHead)
        end
    end
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function RecordDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

function RecordDialog:keyBack()
    UIManager:getInstance():popWnd(RecordDialog)
end

-- 返回战绩
RecordDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_RECORD_INFO] = RecordDialog.showRecordList
}

--endregion
