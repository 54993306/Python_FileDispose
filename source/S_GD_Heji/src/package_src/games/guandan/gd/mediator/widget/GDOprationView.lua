--
-- 玩家操作界面 (叫地主/抢地主/加倍/出牌/提示等)
--
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDOprationView = class("GDOprationView", GDRoomView)
local GDGameEvent = require("package_src.games.guandan.gd.data.GDGameEvent")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local friendDefTimwe = 15

function GDOprationView:initView()
    self.clockContainer = ccui.Helper:seekWidgetByName(self.m_pWidget, "clockContainer")
    self.lb_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "clock")
    if self.m_data.seat == GDConst.SEAT_MINE then
        self.btn_bchu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bchu")
        self.btn_chu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chu")
        self.btnGiveBack = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_give_back")

        self.btn_bchu:addTouchEventListener(handler(self, self.onClickButton))
        self.btn_chu:addTouchEventListener(handler(self, self.onClickButton))
        self.btnGiveBack:addTouchEventListener(handler(self, self.onClickButton))
    end

    if self.m_data.gameType == GDConst.GAME_UP_TYPE.NO_UP_GRADE then
        if self.m_data.seat == GDConst.SEAT_RIGHT
            or self.m_data.seat == GDConst.SEAT_LEFT
            or self.m_data.seat == GDConst.SEAT_TOP 
            then
            local originMargin_start = self.m_pWidget:getLayoutParameter():getMargin()
            originMargin_start.top = originMargin_start.top + 60
            self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
            self.m_pWidget:getParent():requestDoLayout()
        end
    end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function GDOprationView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        local isNotColse = false
        local userID = HallAPI.DataAPI:getUserId()
        if pWidget == self.btn_bchu then
            local info = {}
            info.action = "buchu"
            HallAPI.EventAPI:dispatchEvent(GDGameEvent.UPDATEOPERATION, userID, info)
        elseif pWidget == self.btn_chu then
            local isLegal = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_SELECARDLEGAL)
            if not isLegal then
                PokerToast.getInstance():show("您选择的牌不符合规则")
                isNotColse = true
            else
                local info = {}
                info.action = "chupai"
                HallAPI.EventAPI:dispatchEvent(GDGameEvent.UPDATEOPERATION, userID, info)
            end
        elseif pWidget == self.btnGiveBack then
            local info = {}
            local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
            if gameStatus == GDConst.STATUS_ON_JINGONG then--进贡阶段
                info.action = "jingong"
            elseif gameStatus == GDConst.STATUS_ON_HUANGONG then----还贡阶段
                info.action = "huangong"
            else
                Log.i("err gameStatus :"..gameStatus)
                return
            end

            local isLegal = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_SELECARDLEGAL)
            if not isLegal then
                PokerToast.getInstance():show("您选择的牌不符合规则")
                isNotColse = true
            else
                HallAPI.EventAPI:dispatchEvent(GDGameEvent.UPDATEOPERATION, userID, info)
            end
        end
        if not isNotColse then
            self:hideOpration()
        end
    end
end

----------------------------------------------
-- @desc 显示玩家操作 
-- @pram info:显示玩家操作需要的相关信息
--       notUpdateTime:是否更新操作倒计时
----------------------------------------------
function GDOprationView:showOpration(info, notUpdateTime)
    Log.i("OprationView:showOpration",info, notUpdateTime)
    local player = self:getPlayerModel()
    local tuoguanState = player:getProp(GDDefine.HASTUOGUAN)
    if tuoguanState == GDConst.TUOGUAN_STATE_1 and self.m_data.seat == GDConst.SEAT_MINE then
        return 
    end

    self.isBigger = info and info.isBigger
    self.playCard = info and info.playCard
    info = checktable(info)
    self.m_pWidget:setVisible(true)
    if not notUpdateTime then
        local reconnectTime = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_LEFTTIME)
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LEFTTIME, nil)
        if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
            self.m_Time = reconnectTime or (not self.isBigger and self.m_data.seat == GDConst.SEAT_MINE and self.playCard) and 5 or DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_LIMITTIME)
        else
            self.m_Time = friendDefTimwe
        end
        local strTime = self.m_Time
        if self.m_Time < 10 then
            strTime = "0" .. self.m_Time
        end
        self.lb_time:setString(strTime)
        self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateTime), 1)
    end

    if self.m_data.seat == GDConst.SEAT_MINE then
        self:showOprationBtns(info)
    end
end

----------------------------------------------
-- @desc 更新玩家操作 
-- @pram info:显示玩家操作需要的相关信息
--       handview:玩家的手牌的ui
----------------------------------------------
function GDOprationView:updateOpration(info, handview)
    info = checktable(info)
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if gameStatus == GDConst.STATUS_ON_OUT_CARD then
        if info.action == "tishibuchu" then
            self:hideOpration()
        elseif info.action == "handCardSelect" then
            local cards = handview.m_handCardView:getCardsByStatus(GDCard.STATUS_SELECT)
            --增加了判断，不仅要选中牌，还要能够出出去的牌
            if #cards > 0 and info.selCardLegal then
                self:setBtnGray(self.btn_chu, false)
            else
                self:setBtnGray(self.btn_chu, true)
            end
        elseif info.action == "chongxuan" then
            self:setBtnGray(self.btn_chu, true)
        end
    end
end

----------------------------------------------
-- @desc 显示玩家操作按钮
-- @pram info:显示玩家操作需要的相关信息
----------------------------------------------
function GDOprationView:showOprationBtns(info)
    self.m_info = info
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    self.btn_bchu:setVisible(false)
    self.btn_chu:setVisible(false)
    self.btnGiveBack:setVisible(false)
    self.clockContainer:setVisible(true)
    
    local tuoguanState = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
    if tuoguanState == GDConst.TUOGUAN_STATE_0 then
        if gameStatus == GDConst.STATUS_ON_OUT_CARD then
            self.btn_bchu:setVisible(true)
            self.btn_bchu:setBright(true)
            self.btn_bchu:setTouchEnabled(true)
            self.btn_chu:setVisible(true)
            --必须出
            if info.isMustOut then
                self.btn_bchu:setTouchEnabled(false)
                self.btn_bchu:setBright(false)
                local image = ccui.Helper:seekWidgetByName(self.btn_bchu,"image")
                image:loadTexture("guandan_text_pass_gray.png",ccui.TextureResType.plistType)
            else
                local image = ccui.Helper:seekWidgetByName(self.btn_bchu,"image")
                image:loadTexture("btn/btn_pass.png",ccui.TextureResType.plistType)
            end
            if not info.isBigger and not info.isMustOut then
                self.btn_bchu:setPositionX(309)
                self.clockContainer:setPositionY(100)
                self.btn_chu:setVisible(false)
            else
                self.btn_bchu:setPositionX(170)
                self.clockContainer:setPosition(264, 2)
            end
        elseif gameStatus == GDConst.STATUS_ON_JINGONG then--进贡阶段
            self.clockContainer:setVisible(false)
            local jinTab = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_JINGGONGMAP)
            for k,v in pairs(jinTab) do
                if tonumber(k) == kUserInfo:getUserId() then
                    if not next(v) then
                        self.btnGiveBack:getChildByName("img_text"):loadTexture("guandan_text_give.png", ccui.TextureResType.plistType)
                        self.btnGiveBack:setVisible(true)
                    end
                    break
                end
            end
        elseif gameStatus == GDConst.STATUS_ON_HUANGONG then----还贡阶段
            self.clockContainer:setVisible(false)
            local huanTab = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_HUANGONGMAP)
            for k,v in pairs(huanTab) do
                if tonumber(k) == kUserInfo:getUserId() then
                    if not next(v) then
                        self.btnGiveBack:getChildByName("img_text"):loadTexture("guandan_text_back.png", ccui.TextureResType.plistType)
                        self.btnGiveBack:setVisible(true)
                    end
                    break
                end
            end
        end
    end

    if GDConst.STATUS_ON_GAMEOVER == gameStatus then
        self.lb_time:setVisible(false)
    else
        self.lb_time:setVisible(true)
    end
    
    self:setBtnGray(self.btn_chu, true)
end

----------------------------------------------
-- @desc 显示玩家托管状态改变后
-- @pram 无
----------------------------------------------
function GDOprationView:onTuoGuanChange()
    if self.m_data.seat == GDConst.SEAT_MINE then
        local tuoguanState = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
        if tuoguanState == GDConst.TUOGUAN_STATE_1 then
            self.btn_bchu:setVisible(false)
            self.btn_chu:setVisible(false)
        else
            local opeSeat = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_OPERATESEATID)
            local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
            if opeSeat == GDConst.SEAT_MINE then
                self:showOpration(self.m_info, true)
            end
        end
    end  
end

----------------------------------------------
-- @desc 更新操作时间
-- @pram 无
----------------------------------------------
function GDOprationView:updateTime()
    self.m_Time = self.m_Time - 1
    if self.m_Time < 0 then
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

----------------------------------------------
-- @desc 隐藏操作
-- @pram 无
----------------------------------------------
function GDOprationView:hideOpration()
    self.m_pWidget:setVisible(false)
    if self.m_time_update then
        transition.removeAction(self.m_time_update)
        self.m_time_update = nil
    end
end

----------------------------------------------
-- @desc 让按钮置灰
-- @pram btn:改变的按钮
--       isGary:是否要置灰
----------------------------------------------
function GDOprationView:setBtnGray(btn, isGray)
    if isGray then
        btn:setTouchEnabled(false)
        btn:setBright(false)
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        btn_text:loadTexture("btn/btn_gray_chu.png", ccui.TextureResType.plistType)
    else
        btn:setBright(true)
        btn:setTouchEnabled(true)
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        btn_text:loadTexture("btn/btn_yellow_chu.png", ccui.TextureResType.plistType)
    end
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function GDOprationView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil

    for k,v in pairs(PlayerModelList) do
        if v:getProp(GDDefine.SITE) == self.m_data.seat then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end

return GDOprationView