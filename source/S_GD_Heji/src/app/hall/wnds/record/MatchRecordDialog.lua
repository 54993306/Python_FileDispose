-------------------------------------------------------------
--  @file   main.lua
--  @brief  lua 类定义
--  @author ZCQ
--  @DateTime:2016-10-19 10:08:25
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
MatchRecordDialog = class("MatchRecordDialog", UIWndBase)
local kWidgets = {
    tagCloseBtn     = "close_btn",
    tagTableView    = "scrollView",
    tabItem         = "scrollViewItem",
    tagRecordBtn    = "record_btn",
}
-- 麻将名称配置
local kMjNameConfig = {
    offX = -26, -- 水平距离移动
    fontSize = 26,
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]


local MatchRecordProcesser = class("MatchRecordProcesser", SocketProcesser)

function MatchRecordProcesser:RecordCall(cmd,packetInfo)
    Log.i("MatchRecordProcesser:RecordCall..", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

MatchRecordProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO]    = MatchRecordProcesser.RecordCall;        --邮件列表返回
}


function MatchRecordDialog:ctor(info)
	MatchRecordDialog.super.ctor(self, "hall/record_match_dialog.csb", info)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = MatchRecordProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
    -- 请求战绩 --
    self.roomid = info.roI
    local tData = {}
    tData.roI = info.roI
    tData.gaI = info.gaI
    self.owI = info.owI
    self.gameId = info.gaI
    self.mjName = "麻将"
    local areatable = kFriendRoomInfo:getAreaBaseInfo()
    for k,areaData in pairs(areatable) do
        if info.gaI == areaData.gameId then
            self.mjName = areaData.gameName
        end
    end
    self.gameId = info.gaI
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_MATCH_RECORD_INFO, tData)
end

--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.tableView  = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTableView)
    self.itemUI     = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tabItem)
    self.itemUI:setVisible(false)
    self.title     = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")
    self.title:setString("战绩回放")
    if IsPortrait then -- TODO
        self.title_0     = ccui.Helper:seekWidgetByName(self.m_pWidget, "title_0")
        self.title_0:setString("战绩回放")
    end

    for i = 1, 4 do
        local p = ccui.Helper:seekWidgetByName(self.itemUI, string.format("player_panel_%d", i))
        p:setVisible(false)
    end

    self.button_close = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton));
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onShow()
    print("onShow")
end
--[[
-- @brief  点击按钮函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end

function MatchRecordDialog:parseRecordData(datas)
end

--[[
-- @brief  显示战绩函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:showRecordList(info)
    local function scrollFunc(data, mWight, nIndex)
        local time          = ccui.Helper:seekWidgetByName(mWight, "time_text")
        time:setString(data.gaST)
        local date          = ccui.Helper:seekWidgetByName(mWight, "date_text")
        date:setString(data.gaSD)

        local roomNub   = ccui.Helper:seekWidgetByName(mWight, "room_num")
        roomNub:setString(self.roomid)

        local mjName   = ccui.Helper:seekWidgetByName(mWight, "mj_type")
        if IsPortrait then -- TODO
            mjName:setString(self.mjName)
        else
            local areatable = kFriendRoomInfo:getAreaBaseInfo()
            if #areatable > 1 then -- 当多于一个地区选项时，增加前缀
                -- mjName:setString(GC_GameName .. "\n" .. self.mjName)  -- 不需要显示省包的名称
                mjName:setString(self.mjName)
            else
                mjName:setString(self.mjName)
            end
            mjName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            mjName:setFontSize(kMjNameConfig.fontSize)
            -- mjName:setPositionX(mjName:getPositionX() + kMjNameConfig.offX)  -- 不需要进行偏移
        end
        mjName:setFontSize(mjName:getFontSize()-4)

        local matchNum      = ccui.Helper:seekWidgetByName(mWight, "match_num")
        local strMatch      = string.format("第%d局", nIndex)
        matchNum:setString(strMatch)

        for i=1, #data.usL do
            local p = ccui.Helper:seekWidgetByName(mWight, string.format("player_panel_%d", i))
            p:setVisible(true)
            local nameStr       = string.format("player_name_%d", i)
            local playerName    = ccui.Helper:seekWidgetByName(mWight, nameStr)
            local strNickName = data.usL[i].niN
            local strNickNameLen = string.len(strNickName)
            local nickName = ""
            nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
            -- playerName:setString(nickName)
            Util.updateNickName(playerName, nickName, 24)
            local scoreStr      = string.format("player_score_%d", i)
            local playerScore   = ccui.Helper:seekWidgetByName(mWight, scoreStr)
            playerScore:setString(tostring(data.usL[i].ca))

            local playerId = string.format("player_id_%d", i)
            local playerIdTip = ccui.Helper:seekWidgetByName(mWight, playerId)
            playerIdTip:setString(string.format("ID:%d", data.usL[i].usID))
            
            local roomOwner = string.format("img_room_owner_%d", i)
            local roomOwnerMark = ccui.Helper:seekWidgetByName(mWight, roomOwner)
            if roomOwnerMark then
                if self.owI and self.owI ~= 0 then 
                    roomOwnerMark:setVisible(self.owI == data.usL[i].usID)
                else
                    roomOwnerMark:setVisible(false)
                end
            end
            
            --local color = kUserInfo:getUserId() == data.usL[i].usID and cc.c3b(255, 85, 0) or cc.c3b(43, 76, 1)
            -- playerName:setColor(color)
            -- playerIdTip:setColor(color)

            local opacity = kUserInfo:getUserId() == data.usL[i].usID and 255 or 178
            playerName:setOpacity(opacity)
            playerIdTip:setOpacity(opacity)
            

            local head = ccui.Helper:seekWidgetByName(mWight, string.format("img_head_%d", i))

            if data.usL[i].im and string.len(data.usL[i].im) > 4 then
                local imgName = data.usL[i].usID .. ".jpg"
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
                    HttpManager.getNetworkImage(data.usL[i].im, imgName)
                end
            end

            -- local scoreSource = data.usL[i].ca > 0 and "hall/font/yellow_num_big.fnt" or "hall/font/green_num_big.fnt"
            -- local scoreTip = cc.Label:createWithBMFont(scoreSource, data.usL[i].ca > 0 and "+" .. data.usL[i].ca or data.usL[i].ca)
            -- scoreTip:setPosition(playerScore:getPosition())
            -- scoreTip:setAnchorPoint(playerScore:getAnchorPoint())
            -- playerScore:getParent():addChild(scoreTip)
            -- playerScore:setVisible(false)
			
            playerScore:setString(data.usL[i].ca > 0 and "+" .. data.usL[i].ca or data.usL[i].ca)
            if IsPortrait then -- TODO
                playerScore:setColor(data.usL[i].ca > 0 and cc.c3b(255, 0, 0) or cc.c3b(38, 204, 38))
            else
                playerScore:setColor(data.usL[i].ca > 0 and cc.c3b(255, 191, 0) or cc.c3b(38, 204, 38))
            end
            
			local playerData = data.usL[i]
            local gameId = data.gaI or playerData.exM and playerData.exM["gameId"]
            if gameId == 10031 then      
                --1园内2园外
                local s = playerData.exM["nw"]
                if(s~=nil) then
                    local t = ""--普通模式
                    if(s==1)then 
                       t="园内:"
                    elseif(s==2) then
                       t="园外:"
                    end

                    local color;
                    if(playerData.ca > 0) then
                        color = cc.c3b(0xff,0xb8,0x49) 
                    else
                        color =  cc.c3b(0x19,0xc9,0x0b)
                    end

                    playerScore:setVisible(true);
                    --playerScore:setPosition(cc.p(220,65));
                    playerScore:setString(t..playerData.ca);
                    playerScore:setColor(color);
                    playerScore:setFontSize(20);
                    if scoreTip then
                        scoreTip:removeFromParent(true)
                    end
                end
            elseif self.gameId == 20011 and playerData.exM.shengji == 1 then
                if playerData.exM.shengji == 1 then
                    if playerData.ca > 0 then
                        playerScore:setString("升"..(playerData.ca).."级")
                    elseif playerData.ca <= 0 then
                        playerScore:setVisible(false)
                    end
                end                
            elseif gameId == 10029 then
                if playerData.exM and playerData.exM["putong-" .. playerData.usID] then
                    local scoreNum = tonumber(playerData.exM["putong-" .. playerData.usID])
                    local color = scoreNum > 0 and cc.c3b(0xff,0xb8,0x49) or cc.c3b(0x19,0xc9,0x0b)
                    local numStr = scoreNum > 0 and "+" .. tostring(scoreNum) or tostring(scoreNum)
                    playerScore:setVisible(true)
                    playerScore:setColor(color)
                    playerScore:setString(numStr)
                else
                    local color = playerData.ca > 0 and cc.c3b(0xff,0xb8,0x49) or cc.c3b(0x19,0xc9,0x0b)

                    playerScore:setVisible(true);
                    playerScore:setAnchorPoint(cc.p(0, 0.5))
                    playerScore:setPosition(cc.p(105,130));
                    playerScore:setString("底数: "..playerData.ca);
                    playerScore:setColor(color);
                    playerScore:setFontSize(20);
                 
                    local waiscore = "tiwai1-" .. playerData.usID
                    local s = playerData.exM[waiscore]
                    if(s~=nil ) then
                        local cloneUI = playerScore:clone();
                        playerScore:getParent():addChild(cloneUI);
                        print(s);
                        cloneUI:setPosition(cc.p(105,90));
                        cloneUI:setString("体外: "..s); 
                    end
                end
                if scoreTip then
                    scoreTip:removeFromParent(true)
                end
            end
            
            -- 回放按钮
            local recordBtn = ccui.Helper:seekWidgetByName(mWight, "record_btn")
            local recordBtnImg = ccui.Helper:seekWidgetByName(mWight, "record_btn_img")

            local closeReplay = false
            if CLOSE_REPLAY_ID_LIST then
                for k,v in pairs(CLOSE_REPLAY_ID_LIST) do
                    if v == self.gameId then
                        closeReplay = true
                    end
                end                
            end
            -- recordBtn:setVisible(not closeReplay)

            recordBtnImg._GetTouched = false
            recordBtn:addTouchEventListener(function (pWidget, EventType)
                if EventType == ccui.TouchEventType.began then
                    recordBtnImg._GetTouched = true
                    recordBtnImg:setScale(1.1)
                elseif EventType == ccui.TouchEventType.moved then
                    if recordBtnImg._GetTouched then
                        local bPos = cc.p(recordBtn:getTouchBeganPosition())
                        local mPos = cc.p(recordBtn:getTouchMovePosition())
                        local _offset = cc.pGetLength(cc.pSub(bPos, mPos))
                        recordBtnImg._GetTouched = _offset < 30
                        recordBtnImg:setScale(recordBtnImg._GetTouched and 1.1 or 1)
                    end
                elseif EventType == ccui.TouchEventType.ended then
                    SoundManager.playEffect("btn");
                    -- 获取战绩数据表
                    self:getNetRecordFromJson(data.plBF, data.gaSD)
                    kPlaybackInfo:setCurrentGamesNum(nIndex)
                    recordBtnImg:setScale(1)
                elseif EventType  == ccui.TouchEventType.canceled then
                    -- 获取战绩数据表
                    if recordBtnImg._GetTouched then
                        self:getNetRecordFromJson(data.plBF, data.gaSD)
                        kPlaybackInfo:setCurrentGamesNum(nIndex)
                        recordBtnImg:setScale(1)
                    end
                end
            end)
        end
    end

    for i, v in ipairs(info.li) do
        local data = v
        local mWight = self.itemUI:clone()
        mWight:setVisible(true)
        scrollFunc(data, mWight, i)
        self.tableView:pushBackCustomItem(mWight)
    end
end

function MatchRecordDialog:onResponseNetImg(imgName)
    if not imgName then return end

    local headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if headImg and io.exists(imageName) then
        headImg:loadTexture(imageName);
        headImg:removeAllChildren()
        local cirHead = CircleClippingNode.new(imageName, true, 80)
        cirHead:setPosition(headImg:getContentSize().width/2, headImg:getContentSize().height/2)
        --headImg:addChild(cirHead)
    end
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end


--[[
-- @brief  获取网络对战信息
-- @param  void
-- @return void
--]]
function MatchRecordDialog:getNetRecordFromJson(jsonFileName, gameSaveDate)
	Log.i("MatchRecordDialog:getNetRecordFromJson...",jsonFileName)
	-- 文件名字
    if nil == jsonFileName then
        printError("MatchRecordDialog:getNetRecordFromJson 找不到回放的数据")
        return
    end
    local recUrl = kServerInfo:getRecordUrl()
    if string.find(jsonFileName, "zip") then
        recUrl = recUrl .. tostring(gameSaveDate) .. "/" .. jsonFileName
    else
        recUrl = recUrl..jsonFileName
    end
    Log.i("------imgUrl", recUrl);
    if string.len(recUrl) > 4 then
        LoadingView.getInstance():show("获取对局数据中...")
        HttpManager.getNetworkJson(recUrl, jsonFileName);
    else
        printError("MatchRecordDialog:getNetRecordFromJson 获取对战信息失败")
    end
end

--[[
-- @brief  返回网络战绩json文件
-- @param  void
-- @return void
--]]
function MatchRecordDialog:onResponseNetJson(fileName)
    Log.i("------MatchRecordDialog:onResponseNetJson fileName", fileName);
    LoadingView.getInstance():hide()
    VideotapeManager.getInstance():reSponseInfo(fileName)
end
-- -- 改变变量名字
-- --[[
-- -- @brief  拼装消息函数
-- -- @param  void
-- -- @return void
-- --]]
-- function MatchRecordDialog:contentNameChange(messages)
--     local message = {}
--     message.subcode = messages.code
--     message.content = messages.jsonContent
--     message.code    = messages.type
--     return message
-- end

-- function MatchRecordDialog:getUrlFileName( strurl, strchar, bafter)
--     local ts = string.reverse(strurl)
--     local param1, param2 = string.find(ts, strchar)  -- 这里以"/"为例
--     local m = string.len(strurl) - param2 + 1
--     local result
--     if (bafter == true) then
--         result = string.sub(strurl, m+1, string.len(strurl))
--     else
--         result = string.sub(strurl, 1, m-1)
--     end
--     return result
-- end

function MatchRecordDialog:keyBack()
    UIManager:getInstance():popWnd(MatchRecordDialog)
end

-- 返回战绩
MatchRecordDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO] = MatchRecordDialog.showRecordList
}

return MatchRecordDialog