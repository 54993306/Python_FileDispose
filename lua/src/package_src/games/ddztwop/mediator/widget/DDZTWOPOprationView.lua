-------------------------------------------------------------------------
-- Desc:   二人斗地主操作层UI
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPRoomView")
local DDZTWOPGameEvent = require("package_src.games.ddztwop.data.DDZTWOPGameEvent")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPCardTypeAnalyzer = require("package_src.games.pokercommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZTWOPOprationView = class("DDZTWOPOprationView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationView:initView()
    self.Image_clock =  ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_clock")
    self.lb_time = self:getWidget(self.m_pWidget, "clock")
    self.curTouch = nil
    self.touchNum = 0
    if self.m_data == DDZTWOPConst.SEAT_MINE then
        self.btn_bjiao = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bjiao")
        self.btn_jiao = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_jiao")
        self.btn_bqiang = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bqiang")
        self.btn_qiang = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_qiang")
        self.btn_bjia = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bjia")
        self.btn_jia = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_jia")
        self.btn_bchu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bchu")
        self.btn_chu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chu")
        self.btn_tshi = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_tshi")
        self.btn_chubuqi =  ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chubuqi")
        self.btn_tishi_center = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_tshi_center")
        self.btn_chu_center = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_chu_center")

        self.btn_bjiao:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_jiao:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_bqiang:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_qiang:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_bjia:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_jia:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_bchu:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_chu:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_tshi:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_chubuqi:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_tishi_center:addTouchEventListener(handler(self,self.onClickButton))
        self.btn_chu_center:addTouchEventListener(handler(self,self.onClickButton))
    end
end

---------------------------------------
-- 函数功能：   点击事件处理函数
-- 返回值：     无
--[[
    参数：
    pWidget     点击ui节点
    EventType   点击事件
]]
---------------------------------------
function DDZTWOPOprationView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.began then
        self.touchNum = self.touchNum + 1
        if not self.curTouch then
            self.curTouch = pWidget
        else
        end
    end
    if EventType == ccui.TouchEventType.ended then
        if self.curTouch then 
            self.curTouch = nil
        else
            return
        end
        kPokerSoundPlayer:playEffect("btn")
        local isNotColse = false
        local gamePlayeId = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
        if pWidget == self.btn_bjiao then
            local data = {}
            data.gaPI = gamePlayeId
            data.fl = DDZTWOPConst.CALLLORDSTATUS0
            data.usI = HallAPI.DataAPI:getUserId()
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_CALLLORD, data)
        elseif pWidget == self.btn_jiao then
            local data = {}
            data.gaPI = gamePlayeId
            data.fl = DDZTWOPConst.CALLLORDSTATUS1
            data.usI = HallAPI.DataAPI:getUserId()
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_CALLLORD, data)
        elseif pWidget == self.btn_bqiang then
            local data = {}
            data.gaPI = gamePlayeId
            data.fl = DDZTWOPConst.ROBLORDSTATUS0
            data.usI = HallAPI.DataAPI:getUserId()
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_ROBLORD, data)
        elseif pWidget == self.btn_qiang then
            local data = {}
            data.gaPI = gamePlayeId
            data.fl = DDZTWOPConst.ROBLORDSTATUS1
            data.usI = HallAPI.DataAPI:getUserId()
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_ROBLORD, data)
        elseif pWidget == self.btn_bchu or pWidget == self.btn_chubuqi then
            local info = {}
            info.action = "buchu"
            if self.isMustOut then
                isNotColse = true
            end
            HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
        elseif pWidget == self.btn_tshi or pWidget == self.btn_tishi_center then
            local info = {}
            info.action = "tishi"
            isNotColse = true
            HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
        elseif pWidget == self.btn_chu or pWidget == self.btn_chu_center then
            local canOutcard = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_SELECARDLEGAL)
            local info = {}
            info.action = "chupai"
            if not canOutcard then
                Log.i("Cur Select card is can output:",tostring(canOutcard))
                isNotColse = true
                Log.i("DDZTWOPConst.CARDTYPETIPS***********:",DDZTWOPConst.CARDTYPETIPS)
                PokerToast.getInstance():show("您选择的牌不符合规则")
            else
                HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
            end
        end
        if not isNotColse then
            self:hideOpration()
        end
    end
end

---------------------------------------
-- 函数功能：   显示操作UI函数
-- 返回值：     无
--[[
    参数：
    info 操作信息
    notUpdateTime   是否需要更新倒计时信息
    isReconnect     是否是重新连接
    handCardView    玩家手牌UI面板
]]
---------------------------------------
function DDZTWOPOprationView:showOpration(info, notUpdateTime,isReconnect,handCardView)
    self.isBigger = info and info.isBigger
    self.playCard = info and info.playCard
    info = checktable(info)
    Log.i("------showOpration gameStatus = ", DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS))
    self.m_pWidget:setVisible(true)
    if not notUpdateTime then
        if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
            self.m_Time = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LIMITTIME)
        else
            if isReconnect then
                self.m_Time = (not self.isBigger and self.m_data == DDZTWOPConst.SEAT_MINE and self.playCard) and 5 or DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_RECONNECTTIME)
            else
                self.m_Time = (not self.isBigger and self.m_data == DDZTWOPConst.SEAT_MINE and self.playCard) and 5 or DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LIMITTIME)
            end
        end
        local strTime = ""
        if self.m_Time < 10 then
            strTime = "0"..tostring(self.m_Time)
        else
            strTime = tostring(self.m_Time)
        end
        self.lb_time:setString(strTime)
        self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateTime), 1)
    end

    if self.m_data == DDZTWOPConst.SEAT_MINE then
        self:showOprationBtns(info,handCardView)
    end
end

----------------------------------------
-- 函数功能：   选牌后更新按钮状态函数
-- 返回值：     无
--[[
    参数：
    info        操作更新数据封装
    {
        action    操作名称
    }
    handview     玩家手牌UI面板
]]
---------------------------------------
function DDZTWOPOprationView:updateOpration(info,handview)
    info = checktable(info)
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    if gameStatus == DDZTWOPConst.STATUS_PLAY then
        if info.action == "sort" then

        elseif info.action == "tishibuchu" then
            self:hideOpration()
        elseif info.action == "handCardSelect" then
            local cards = handview.m_handCardView:getCardsByStatus(DDZTWOPCard.STATUS_POP)
            if #cards > 0 then
                self:setBtnGray(self.btn_chu_center,false)
                self:setBtnGray(self.btn_chu, false)
            else
                self:setBtnGray(self.btn_chu, true)
                self:setBtnGray(self.btn_chu_center,true)
            end
        end
    end
end

---------------------------------------
-- 函数功能：   显示按钮函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationView:showOprationBtns(info,handCardView)
    self.m_info = info
    local gameStatus = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    self.btn_bjiao:setVisible(false)
    self.btn_jiao:setVisible(false)
    self.btn_bqiang:setVisible(false)
    self.btn_qiang:setVisible(false)
    self.btn_bjia:setVisible(false)
    self.btn_jia:setVisible(false)
    self.btn_bchu:setVisible(false)
    self.btn_tshi:setVisible(false)
    self.btn_chu:setVisible(false)
    self.btn_chubuqi:setVisible(false)
    self.btn_chu_center:setVisible(false)
    self.btn_tishi_center:setVisible(false)
    local tuoguanStates =  DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    if not tuoguanStates[HallAPI.DataAPI:getUserId()] or (tuoguanStates[HallAPI.DataAPI:getUserId()] and tuoguanStates[HallAPI.DataAPI:getUserId()] == DDZTWOPConst.TUOGUAN_STATE_0) then
        self.Image_clock:setVisible(true)
        if gameStatus == DDZTWOPConst.STATUS_CALL then
            self.btn_bjiao:setVisible(true)
            self.btn_jiao:setVisible(true)
        elseif gameStatus == DDZTWOPConst.STATUS_ROB then
            self.btn_bqiang:setVisible(true)
            self.btn_qiang:setVisible(true)
        elseif gameStatus == DDZTWOPConst.STATUS_DOUBLE then
            self.btn_bjia:setVisible(true)
            self.btn_jia:setVisible(true)
        elseif gameStatus == DDZTWOPConst.STATUS_PLAY then
            if info.isMustOut then
                self.btn_bchu:setVisible(false)
                self.btn_tishi_center:setVisible(true)
                self.btn_chu_center:setVisible(true)
            else
                if info.isBigger then
                    self.btn_bchu:setVisible(true)
                    self.btn_tshi:setVisible(true)
                    self.btn_chu:setVisible(true)
                    self.isMustOut =info.isMustOut
                else
                    self.btn_chubuqi:setVisible(true)
                end
            end
        end
    else
        self.Image_clock:setVisible(false)
    end

    if DDZTWOPConst.STATUS_GAMEOVER == gameStatus then
        self.lb_time:setVisible(false)
    else
        self.lb_time:setVisible(true)
    end

    local info = {}
    info.selCardLegal = false
    local lastOutCards = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_LASTOUTCARDS)
    local lastOutCardType = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LASTCARDTYPE)
    local lastOutCardValues = self:getCardValues(lastOutCards)
    local lastKeyCard =DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LASTCARDTYPE)
    local cards = handCardView.m_handCardView:getSelectedCardValues()

    --检查当前选择的牌是否符合牌型
    local isLegal = DDZTWOPCardTypeAnalyzer.isLegal(cards, lastOutCardValues, lastOutCardType, lastKeyCard)
    info.action = "handCardSelect"
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_SELECARDLEGAL, isLegal)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
    --上手牌王炸自动不出
    if info.autoNotOut then
        self:onClickButton(self.btn_bchu, ccui.TouchEventType.ended)
    end
end

---------------------------------------
-- 函数功能：   托管状态改变更新操作UI函数
-- 返回值：     无
--[[
    参数：
    playerId    玩家id
    handCardView   操作玩家手牌UI面板
]]
---------------------------------------
function DDZTWOPOprationView:onTuoGuanChange(playerId,handCardView)
    if self.m_data == DDZTWOPConst.SEAT_MINE then
        local tuoguanStates =  DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
        if not tuoguanStates[HallAPI.DataAPI:getUserId()] or (tuoguanStates[HallAPI.DataAPI:getUserId()] and tuoguanStates[HallAPI.DataAPI:getUserId()] == DDZTWOPConst.TUOGUAN_STATE_1 and playerId == HallAPI.DataAPI:getUserId()) then
            self.btn_bjiao:setVisible(false)
            self.btn_jiao:setVisible(false)
            self.btn_bqiang:setVisible(false)
            self.btn_qiang:setVisible(false)
            self.btn_bjia:setVisible(false)
            self.btn_jia:setVisible(false)
            self.btn_bchu:setVisible(false)
            self.btn_tshi:setVisible(false)
            self.btn_chu:setVisible(false)
            self.btn_chubuqi:setVisible(false)
            self.Image_clock:setVisible(false)
            self.btn_chu_center:setVisible(false)
            self.btn_tishi_center:setVisible(false)
        else
            local opeSeat = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_OPERATESEATID)
            local gameStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
            local myDbStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_DUUBLESTATUS)
            if opeSeat == DDZTWOPConst.SEAT_MINE or (gameStatus == DDZTWOPConst.STATUS_DOUBLE and myDbStatus == -1) then
                self:showOpration(self.m_info, true, nil, handCardView)
            end
        end
    end  
end

---------------------------------------
-- 函数功能：    根据手牌返回牌值
-- 返回值：      牌值集合
---------------------------------------
function DDZTWOPOprationView:getCardValues(cards)
    local cardValues = {}
    if cards and #cards > 0 then
        for k, v in pairs(cards) do
            local type, val = DDZTWOPCard.cardConvert(v)
            table.insert(cardValues, val)
        end
    end
    return cardValues
end

---------------------------------------
-- 函数功能：   更新时间回调
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationView:updateTime()
    self.m_Time = self.m_Time - 1
    if self.m_Time < 0 then
        if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
            if not self.isBigger and self.playCard then
                self.curTouch = self.btn_bchu
                self:onClickButton(self.btn_bchu,ccui.TouchEventType.ended)
                return
            end
        end
        self.m_Time = 0
    end
    local timeStr = nil
    if self.m_Time < 10 then
        timeStr = 0 .. self.m_Time
    else
        timeStr = self.m_Time
    end
    self.lb_time:setString(timeStr)
    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateTime), 1)
end

---------------------------------------
-- 函数功能：   隐藏操作UI
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationView:hideOpration()
    self.m_pWidget:setVisible(false)
    if self.m_time_update then
        transition.removeAction(self.m_time_update)
        self.m_time_update = nil
    end
end

---------------------------------------
-- 函数功能：   设置按钮是否可点击
-- 返回值：     无
--[[
    参数：
    btn    需要置灰的按钮
    isGray   是否需要置灰
]]
---------------------------------------
function DDZTWOPOprationView:setBtnGray(btn, isGray)
    if isGray then
        btn:setTouchEnabled(false)
        --btn:setBright(false)
        
        btn_text = ccui.Helper:seekWidgetByName(btn,"Image")
        if btn == self.btn_chu or btn == self.btn_chu_center then
            btn:loadTextureNormal("btn/btn_gray_bg.png", ccui.TextureResType.plistType)
            btn_text:loadTexture("btn/btn_gray_chu.png", ccui.TextureResType.plistType)
        end
    else
        --btn:setBright(true)
        btn:setTouchEnabled(true)
        btn_text = ccui.Helper:seekWidgetByName(btn,"Image")
        if btn == self.btn_chu or btn == self.btn_chu_center then
            btn:loadTextureNormal("btn/btn_yellow_bg.png", ccui.TextureResType.plistType)
            btn_text:loadTexture("btn/btn_yellow_chu.png", ccui.TextureResType.plistType)
        end
    end
end

return DDZTWOPOprationView