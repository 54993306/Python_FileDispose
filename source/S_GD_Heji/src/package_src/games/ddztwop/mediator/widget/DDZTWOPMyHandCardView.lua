-------------------------------------------------------------------------
-- Desc:   二人斗地主自己手牌UI 继承Node  展示手牌
-- Author:   
-------------------------------------------------------------------------

local PorkerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local DDZTWOPGameEvent = require("package_src.games.ddztwop.data.DDZTWOPGameEvent")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local PokerConst = require("package_src.games.pokercommon.data.PokerConst")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPCardTypeAnalyzer = require("package_src.games.pokercommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZTWOPCardTips  = require("package_src.games.pokercommon.utils.card.DDZPKCardTips")
local DDZTWOPMyHandCardView = class("DDZTWOPMyHandCardView", function ()
    return display.newNode()
end)

---------------------------------------
-- 函数功能：   构造函数 初始化数据
-- 返回值：     无
---------------------------------------
function DDZTWOPMyHandCardView:ctor(delegate)
    self:setTouchEnabled(false)
    self.m_delegate = delegate
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouchCard(event.name, event.x, event.y)
    end)
    --手牌层宽度
    self.width = display.width * DDZTWOPCard.SElFSCALE
    --手牌层的高度
    self.height = DDZTWOPCard.HEIGHT 
    --手牌触摸停止高度
    self.stopHeight = self.height * DDZTWOPConst.TOUCHSCALE
    self:setContentSize(cc.size(self.width, self.height))
    --存储手牌容器
    self.m_cards = {}
    --手牌提示工具
    self.m_cardTips = DDZTWOPCardTips.new()
    --是否开始发牌
    self.beganDealCard = false

    self.sortByNum = false
    self.bg_trust = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"bg_trust")
    self.bottom_bg = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"bottom_bg")
    self.btn_canceltrust = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"btn_canceltrust")
    self.lab_Tip = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget, "Label_OtherWinTip")
    self.lab_Tip:setFontName(PokerConst.FONT)
    self.btn_canceltrust:addTouchEventListener(handler(self, self.onClickButton))

    --存储所有的监听   便于在析构函数中移除
    self.listeners= {}
    --添加监听事件
    self.nHandler=HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)
end

---------------------------------------
-- 函数功能：    关闭UI处理函数  用于取消注册监听函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

---------------------------------------
-- 函数功能：    重置手牌数据函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:reset()
    self:setIsBiggerCard(true)
    self:onTuoGuanChange()
    self.lab_Tip:setVisible(false)
    self:removeAllChildren()
    self.m_cards = {}
    self.m_cardTips:reset()
end 

---------------------------------------
-- 函数功能：    发牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:dealCard(cards, isReconnect)
    --连续两次发牌（出现手牌超过17张的情况） 在这里重置手牌数据  停止所有定时器
    ----------------------
    self:reset()
    self:stopAllActions()
    ----------------------

    self.beganDealCard = true
    if not cards or #cards == 0 then
        return
    end
    if not isReconnect then
        self:setTouchEnabled(false)
        for k, v in pairs(cards) do
            self:performWithDelay(function()
                self:addCards({v})
                if k == #cards then
                    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.SHOWOPRATION)
                    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                end
            end, k * DDZTWOPConst.DISPENSE_DELAY)
        end
    else
        self:addCards(cards)
    end
    self.m_cardTips:add(self:getCardValues(cards))

    self:setTouchEnabled(true)
end

---------------------------------------
-- 函数功能：    将地主底牌加入到手牌中
-- 返回值：      无
-- cards：      添加的牌集合
---------------------------------------
function DDZTWOPMyHandCardView:addBottomCard(cards)
    self.m_cardTips:add(self:getCardValues(cards))
    self:addCards(cards)
end

---------------------------------------
-- 函数功能：    添加牌到手牌中
-- 返回值：      无
-- cards：      添加的牌集合
---------------------------------------
function DDZTWOPMyHandCardView:addCards(cards)
    local mineCardCount = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_MINECARDCOUNT) or 0
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_MINECARDCOUNT,mineCardCount + #cards)
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    if cards == nil or #cards == 0 then
        return
    end
    
    local insertCards = {}
    for i, card in ipairs(cards) do
        local isExist = false
        for ii, v in pairs(self.m_cards) do
            if v:getCard() == card then
                isExist = true
                break
            end
        end 
        if not isExist then
            table.insert(insertCards, card)
        end
    end

    for i, card in pairs(insertCards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setTouchEnabled(false)
        self:addChild(cardView)
        table.insert(self.m_cards, cardView)
    end
    self:sortByValue()
end

---------------------------------------
-- 函数功能：    将牌从手牌中移除
-- 返回值：      无
-- cards:       移除的牌集合
---------------------------------------
function DDZTWOPMyHandCardView:removeCards(cards) 
    local mineCardCount = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_MINECARDCOUNT) or 0
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_MINECARDCOUNT,mineCardCount - #cards)
    for _, card in pairs(cards) do
        for k, v in pairs(self.m_cards) do 
            if card == v:getCard() then
                self:removeChild(v)
                table.remove(self.m_cards, k)
                v = nil
                break
            end
        end
    end
    self:updatePoker(true)
end

---------------------------------------
-- 函数功能：    根据牌值对手牌进行排序
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:sortByValue()
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType()
    end

    for i = 2, #self.m_cards do 
        local card = self.m_cards[i]

        local index = 1
        for j = i - 1, 1, -1 do
            if getCardValue(card) > getCardValue(self.m_cards[j]) then
                self.m_cards[j + 1] = self.m_cards[j]
            else
                index = j + 1
                break
            end
        end

        self.m_cards[index] = card
    end
      
    for i, v in ipairs(self.m_cards) do
        v:setLocalZOrder(i)
    end
    self:updatePoker(true)
end

---------------------------------------
-- 函数功能：    清除当前触摸的状态
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:cleanTouchState()
    --开始触摸索引
    self.m_beginTouchIndex = -1
    --触摸结束索引
    self.m_lastTouchIndex = -1
    self.m_lastTouchX = nil
    self.m_lastTouchY = nil
    self.m_stopMoving = false
end

---------------------------------------
-- 函数功能：    根据触摸x,y的点返回手牌中牌的索引
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:getCardAndIndex(x, y)
    for i = #self.m_cards, 1, -1 do
        local card = self.m_cards[i]
        if self.m_cards[i]:isClick(cc.p(x, y)) then
            return card, i
        end
    end
    return nil
end

---------------------------------------
-- 函数功能：    监听触摸牌事件
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onTouchCard(EventType, x, y)
    --print("------DDZTWOPMyHandCardView:onTouchCard EventType", EventType)
    --print("------DDZTWOPMyHandCardView:onTouchCard x", x)
    --print("------DDZTWOPMyHandCardView:onTouchCard y", y)
    if y > self.stopHeight then
        self:onTouchEnd()
    end
    
    local card, index = self:getCardAndIndex(x, y)
    if EventType == "began" then 
        self:cleanTouchState()

        if card then 
            self.m_beginTouchIndex = index
            self.m_lastTouchIndex = index
            self:updateCardsStateInMoveRegion(index)
            kPokerSoundPlayer:playEffect("cardClick")
        end
        return true
    elseif EventType == "moved" then
        if card then
            self:updateCardsStateInMoveRegion(index)
            if self.m_lastTouchIndex ~= index then
                self.m_lastTouchX = x
                self.m_lastTouchY = y
                kPokerSoundPlayer:playEffect("cardClick")
            end
            self.m_lastTouchIndex = index
        end
    else 
        self:onTouchEnd()
    end

    self:updatePoker(false)
end

---------------------------------------
-- 函数功能：    强行停止触摸事件
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onStopMoving()
    self.m_stopMoving = true
    self:changeStatus(DDZTWOPCard.STATUS_NORMAL_SELECT, DDZTWOPCard.STATUS_NORMAL)
    self:changeStatus(DDZTWOPCard.STATUS_POP_SELECT, DDZTWOPCard.STATUS_POP)
    self:popCards({})
end

---------------------------------------
-- 函数功能：    监听触摸结束函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onTouchEnd()
    if self.m_stopMoving then
        return
    end
    local moveTip = false
    if math.abs(self.m_beginTouchIndex - self.m_lastTouchIndex) > 0 then
        local popCards = self:getCardsByStatus(DDZTWOPCard.STATUS_POP)
        local popSelectCards = self:getCardsByStatus(DDZTWOPCard.STATUS_POP_SELECT)
        if #popCards == 0 and #popSelectCards == 0 then
            moveTip = true
        end
    end
    self:changeStatus(DDZTWOPCard.STATUS_NORMAL_SELECT, DDZTWOPCard.STATUS_POP)
    self:changeStatus(DDZTWOPCard.STATUS_POP_SELECT, DDZTWOPCard.STATUS_NORMAL)
    self:onHandCardSelect(false, moveTip)
    self:cleanTouchState()
end

---------------------------------------
-- 函数功能：    选择牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onHandCardSelect(isChecked, moveTip)
    --当前操作玩家位置
    local seat = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_OPERATESEATID) 

    if seat == DDZTWOPConst.SEAT_MINE then
        local tipCards = nil
        local info = {}
        info.action = "handCardSelect"
        info.selCardLegal = false
        local selectedCardValues = self:getSelectedCardValues()
        if selectedCardValues and #selectedCardValues > 0 then
            if isChecked then
                info.selCardLegal = true
            else
                local lastOutCards = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LASTOUTCARDS)
                local lastOutCardType = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LASTCARDTYPE)
                local lastOutCardValues = self:getCardValues(lastOutCards)
                local lastKeyCard =DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LASTCARDTYPE)
                if moveTip then
                    if not lastOutCards or #lastOutCards == 0 then
                        if #selectedCardValues > 5 then
                            local cardType, cards = self.m_cardTips:getTipsWithCards(selectedCardValues)
                            tipCards = cards
                        elseif #selectedCardValues <= 5 and #selectedCardValues > 1 then
                            local cards = self.m_cardTips:getTipsByPart(selectedCardValues)
                            if cards and #cards > 0 then
                                tipCards = cards
                            else
                                local cardType = DDZTWOPCardTypeAnalyzer.getCardType(selectedCardValues)
                                if cardType > DDZTWOPCard.CT_ERROR then
                                    tipCards = selectedCardValues
                                end
                            end
                        elseif #selectedCardValues == 1 then
                            tipCards = self.m_cardTips:getTipsBy1card(lastOutCardValues, selectedCardValues[1])
                        end
                    else
                        local cardTip = DDZTWOPCardTips.new(selectedCardValues)
                        tipCards = cardTip:getTipsLoop(lastOutCardValues, nil, lastOutCardType)
                    end
                    if tipCards and #tipCards > 0 then
                        info.selCardLegal = true
                        self:popCards(tipCards)
                    end 
                else
                    local isLegal = DDZTWOPCardTypeAnalyzer.isLegal(selectedCardValues, lastOutCardValues, lastOutCardType, lastKeyCard)
                    if isLegal then
                        info.selCardLegal = true
                    end
                end
            end
        end
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_SELECARDLEGAL, info.selCardLegal)
        HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
    end
end

---------------------------------------
-- 函数功能：    获取当前选中的牌函数
-- 返回值：      选中的牌集合
---------------------------------------
function DDZTWOPMyHandCardView:getSelectedCardValues()
    local selectedCardValues = {}
    for k, v in pairs(self.m_cards) do
        if v:getStatus() == DDZTWOPCard.STATUS_POP then
            table.insert(selectedCardValues, v:getValue())
        end
    end
    return selectedCardValues
end

---------------------------------------
-- 函数功能：    获取说有手牌的牌值函数
-- 返回值：      所有手牌牌值集合
---------------------------------------
function DDZTWOPMyHandCardView:getHandCardValues()
    local cardValues = {}
    for k, v in pairs(self.m_cards) do
        table.insert(cardValues, v:getValue())
    end
    return cardValues
end

---------------------------------------
-- 函数功能：    触摸过程中改变手牌的状态
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:updateCardsStateInMoveRegion(curTouchIndex)
    self:changeStatus(DDZTWOPCard.STATUS_NORMAL, DDZTWOPCard.STATUS_NORMAL_SELECT, self.m_beginTouchIndex, curTouchIndex)
    self:changeStatus(DDZTWOPCard.STATUS_POP, DDZTWOPCard.STATUS_POP_SELECT, self.m_beginTouchIndex, curTouchIndex)

    --move direction has changed
    if (self.m_lastTouchIndex - self.m_beginTouchIndex)*(curTouchIndex - self.m_lastTouchIndex) < 0 then 
        local endIndex = curTouchIndex + (self.m_lastTouchIndex < curTouchIndex and -1 or 1)
        self:changeStatus(DDZTWOPCard.STATUS_NORMAL_SELECT, DDZTWOPCard.STATUS_NORMAL, self.m_lastTouchIndex, endIndex)
        self:changeStatus(DDZTWOPCard.STATUS_POP_SELECT, DDZTWOPCard.STATUS_POP, self.m_lastTouchIndex, endIndex)
    end
end

---------------------------------------
-- 函数功能：    改变手牌的状态
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:changeStatus(srcStatus, destStatus, begIndex, endIndex)
    begIndex = begIndex or 1
    endIndex = endIndex or #self.m_cards

    for i = begIndex, endIndex, (begIndex < endIndex) and 1 or -1 do
        local card = self.m_cards[i]
        if card and card:getStatus() == srcStatus then
            card:setStatus(destStatus)
        end
    end
end

---------------------------------------
-- 函数功能：    更新手牌的展示状态
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:updatePoker(isUpateAll)
    local isChange = false
    for _, v in pairs(self.m_cards) do 
        if v:isStatusChanged() or isUpateAll then 
            isChange = true
            if v:getStatus() == DDZTWOPCard.STATUS_NORMAL or v:getStatus() == DDZTWOPCard.STATUS_POP then
                v:setColor(DDZTWOPCard.NORMALCOLOR)
            elseif v:getStatus() == DDZTWOPCard.STATUS_NORMAL_SELECT or v:getStatus() == DDZTWOPCard.STATUS_POP_SELECT then
                v:setColor(DDZTWOPCard.NORMALSELECTCOLOR)
            end
        end
    end

    if self.m_cards and #self.m_cards > 0 then
        for i,v in ipairs(self.m_cards) do
            if i == #self.m_cards then
                self.m_cards[#self.m_cards]:showFlowerImg()
            else
                self.m_cards[i]:hideFlowerImg()
            end
        end
        
    end

    local lordId = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID)
    if lordId == HallAPI.DataAPI:getUserId() then
        if self.m_cards and #self.m_cards > 0 then
            for i,v in ipairs(self.m_cards) do
                if i == #self.m_cards then
                    self.m_cards[#self.m_cards]:addLordTag()
                else
                    self.m_cards[i]:hideLordTag()
                end
            end
        end
    end

    if isChange then
        self:resetPosition()
    end
end

---------------------------------------
-- 函数功能：    重设手牌的位置
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:resetPosition()
    local cardNum = #self.m_cards
    if cardNum > 0 then
        local space = self:getSpace(cardNum)
        local x = self.width/2  - cardNum/2*space - (DDZTWOPCard.WIDTH - space)/2 * DDZTWOPCard.SElFSCALE+ DDZTWOPCard.WIDTH/2 *DDZTWOPCard.SElFSCALE
        for k, v in ipairs(self.m_cards) do 
            if v:getStatus() == DDZTWOPCard.STATUS_NORMAL or v:getStatus() == DDZTWOPCard.STATUS_NORMAL_SELECT then
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2 * DDZTWOPCard.SElFSCALE))
            else
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2 * DDZTWOPCard.SElFSCALE + DDZTWOPCard.POPHEIGHT * DDZTWOPCard.SElFSCALE))   
            end
            x = x + space
        end
    end
end

---------------------------------------
-- 函数功能：    将选中的牌提起
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:popCards(cardValues)
    if not cardValues then
        return
    end
    table.sort(cardValues, function(a, b)
        return a > b
    end)

    local popCards = self:getCardsByStatus(DDZTWOPCard.STATUS_POP)

    for k, v in ipairs(popCards) do
        local value = v:getValue()
        local ret = false
        for kk, vv in ipairs(cardValues) do 
            if vv == value then
                table.remove(cardValues, kk)
                ret = true
                break
            end
        end

        if not ret then
            v:setStatus(DDZTWOPCard.STATUS_NORMAL)
        end
    end

    if #cardValues > 0 then
        local cardValuesIndex = 1
        local lastQualifiedIndex = -1 
        for i, v in pairs(self.m_cards) do 
            if v:getStatus() ~= DDZTWOPCard.STATUS_POP and v:getValue() == cardValues[cardValuesIndex] then 
                v:setStatus(DDZTWOPCard.STATUS_POP)
                cardValuesIndex = cardValuesIndex + 1
            end
        end
    end
    
    self:updatePoker(false)
end 

---------------------------------------
-- 函数功能：    返回某种状态的牌函数
-- 返回值：      同种状态的手牌
---------------------------------------
function DDZTWOPMyHandCardView:getCardsByStatus(status)
    local ret = {}
    for k, v in ipairs(self.m_cards) do
        if v:getStatus() == status then
            ret[#ret + 1] = v
        end
    end
    return ret
end

---------------------------------------
-- 函数功能：    返回手牌之间的牌距
-- 返回值：      牌距
---------------------------------------
function DDZTWOPMyHandCardView:getSpace(cardNum)
    local space = DDZTWOPCard.NORMALSPACE
    if cardNum > 1 then
        space = (self.width - DDZTWOPCard.WIDTH * DDZTWOPCard.SElFSCALE)/(cardNum - 1)
    else
        return 0
    end
    space = space > DDZTWOPCard.MAXSPACE and DDZTWOPCard.MAXSPACE or space

    return space
end

---------------------------------------
-- 函数功能：    检测能不能压过上手牌
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:checkIsBiggerCard()
    local tipCards = self:getTipCards()
    if tipCards and #tipCards > 0 then
        self:setIsBiggerCard(true)
        --self:onHandCardSelect(false)
        --[[--出牌后就剩一张牌,自动出。
        if #self.m_cards == 1 then
            self.m_cards[1]:setStatus(DDZTWOPCard.STATUS_POP)
            self:updatePoker(true)
            self:onChuClick()
        end--]]
        return true
    else
        self:setIsBiggerCard(false)
        self:onStopMoving()
        --只剩一张自动不出
        -- if #self.m_cards == 1 then
        --     self:onBuChuClick()
        -- end
        return false
    end
end

---------------------------------------
-- 函数功能：    设置能否压过上手牌UI状态展示
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:setIsBiggerCard(isBigger)
    if isBigger then
        self.bottom_bg:setVisible(false)
        self:setTouchEnabled(true)
    else
        local tuoguanStates = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
        if not tuoguanStates[HallAPI.DataAPI:getUserId()] or (tuoguanStates[HallAPI.DataAPI:getUserId()] and tuoguanStates[HallAPI.DataAPI:getUserId()] == DDZTWOPConst.TUOGUAN_STATE_0) then
            self.bottom_bg:setVisible(true)
        end
        self:setTouchEnabled(false)
    end
end

---------------------------------------
-- 函数功能：    获取提示牌
-- 返回值：      提示牌
---------------------------------------
function DDZTWOPMyHandCardView:getTipCards()
    local lastOutCards =  DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_LASTOUTCARDS)
    local lastOutCardType = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LASTCARDTYPE)
    local lastOutCardValues = self:getCardValues(lastOutCards)
    local lastTipCardValues = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_LASTCARDTIPS)
    local tipCards = self.m_cardTips:getTipsLoop(lastOutCardValues, lastTipCardValues, lastOutCardType)
    Log.i("------lastOutCardValues", lastOutCardValues)
    Log.i("------lastTipCardValues", lastTipCardValues)
    Log.i("------lastOutCardType", lastOutCardType)
    Log.i("------tipCards", tipCards)
    return tipCards
end

---------------------------------------
-- 函数功能：    不出按钮回调
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onBuChuClick(notSendMsg)
    self:popCards({})
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTIPS,{})
    if notSendMsg then
        return
    end
    local data = {}
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
    data.fl = 0
    data.usI = HallAPI.DataAPI:getUserId()
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_OUTCARD, data)
end

---------------------------------------
-- 函数功能：    重选
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onChongXuanClick()
    self:popCards({})
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTIPS,{})
end

---------------------------------------
-- 函数功能：    提示
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onTiShiClick()
    --托管状态则提示不出
    -- if self.bg_trust:isVisible() then
    --     self:onBuChuClick()
    --     HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
    --     return
    -- end
    local tipCards = self:getTipCards()
    if tipCards and #tipCards > 0 then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTIPS,clone(tipCards))
        self:popCards(tipCards) --将提示的牌提起
        self:onHandCardSelect(true)
    end
end

---------------------------------------
-- 函数功能：    出牌
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onChuClick()
    local cardViews = self:getCardsByStatus(DDZTWOPCard.STATUS_POP)
    local cards = self:getCardsByView(cardViews)
    local data = {}
    data.gaPI =DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
    data.fl = 1
    data.usI = HallAPI.DataAPI:getUserId()
    data.plC = cards
    for k, v in pairs(data.plC) do
        data.plC[k] = DDZTWOPCard.ConvertToserver(v)
    end
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_SEND_OUTCARD, data)
end

---------------------------------------
-- 函数功能：    根据手牌返回牌
-- 返回值：      牌集合
---------------------------------------
function DDZTWOPMyHandCardView:getCardsByView(cardViews)
    local cards = {}
    if cardViews and #cardViews > 0 then
        for k, v in pairs(cardViews) do
            local val = v:getCard()
            table.insert(cards, val)
        end
    end
    return cards
end

---------------------------------------
-- 函数功能：    根据手牌返回牌值
-- 返回值：      牌值集合
---------------------------------------
function DDZTWOPMyHandCardView:getCardValues(cards)
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
-- 函数功能：    删除手牌事件回调
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onDelCard(cards,seat)
    if seat ~= DDZTWOPConst.SEAT_MINE then return end
    self:onOutCard(cards)
end

---------------------------------------
-- 函数功能：    出牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onOutCard(cards)
    self:setIsBiggerCard(true)
    local cardValues = self:getCardValues(cards)
    if not cardValues or #cardValues == 0 then
        self:onBuChuClick(true)
    else
        self.m_cardTips:remove(self:getCardValues(cards))
        self:removeCards(cards)
        self:onBuChuClick(true)
    end
end

---------------------------------------
-- 函数功能：    按钮点击回调
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_canceltrust then
            kPokerSoundPlayer:playEffect("btn") 
            local data = {}
            data.maPI = HallAPI.DataAPI:getUserId()
            data.isM = 0
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_TUOGUAN, data)
        end
    end
end

---------------------------------------
-- 函数功能：    托管状态改变处理函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onTuoGuanChange()
    local tuoguanStates = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    if tuoguanStates[HallAPI.DataAPI:getUserId()] and tuoguanStates[HallAPI.DataAPI:getUserId()] == DDZTWOPConst.TUOGUAN_STATE_1 then
        self:setTouchEnabled(false)
        self:onStopMoving()
        self.bg_trust:setVisible(true)
    else
        self:setTouchEnabled(true)
        self.bg_trust:setVisible(false)
    end
end

---------------------------------------
-- 函数功能：    游戏结束手牌UI处理函数
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:onGameOver(info)
    self:reset()
    self:onStopMoving()
    self:setIsBiggerCard(true)
    self:setTouchEnabled(false)
    self.sortByNum = false
    self.lab_Tip:setVisible(false)
end

---------------------------------------
-- 函数功能：    提示让牌数量
-- 返回值：      无
---------------------------------------
function DDZTWOPMyHandCardView:showTipCount()
    local leftCount = 0
    local rangCount = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_RANGPAICOUNT)
    local isMeLord = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()

    self.lab_Tip:setVisible(true)
    if isMeLord then
        local player = self:getPlayerByisLord(false)
        local cards = player:getProp(DDZTWOPDefine.HAND_CARDS)
        leftCount = #cards
        local needOut = leftCount - rangCount
        needOut = needOut < 0 and 0 or needOut
        self.lab_Tip:setString("您让对手" .. rangCount .. "张牌，对手再出" .. needOut  .."张即可获胜")
    else
        local player = self:getPlayerByisLord(false)
        local cards = player:getProp(DDZTWOPDefine.HAND_CARDS)
        leftCount = #cards
        local needOut = leftCount - rangCount
        needOut = needOut < 0 and 0 or needOut
        self.lab_Tip:setString("对手让您" .. rangCount.. "张牌，您再出" .. needOut .."张即可获胜")
    end
end 

---------------------------------------
-- 函数功能：    根据是否是地主返回玩家player
-- 返回值：      玩家Player
---------------------------------------
function DDZTWOPMyHandCardView:getPlayerByisLord(isLord)
    local playerlist = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(playerlist) do
        if isLord and v:getProp(DDZTWOPDefine.USERID) == DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) then
            return v
        elseif not isLord and v:getProp(DDZTWOPDefine.USERID) ~= DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) then
            return v
        end
    end
    return
end

return DDZTWOPMyHandCardView