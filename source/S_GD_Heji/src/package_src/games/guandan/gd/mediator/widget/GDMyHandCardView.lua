--[[---------------------------------------- 
-- 作者: 方明扬
-- 日期: 2018-05-07 
-- 摘要: 自己的手牌
]]-------------------------------------------

local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDGameEvent = require("package_src.games.guandan.gd.data.GDGameEvent")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDSocketCmd = require("package_src.games.guandan.gd.proxy.delegate.GDSocketCmd")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDPKCardTypeAnalyzer = require("package_src.games.guandan.gdcommon.utils.card.GDPKCardTypeAnalyzer")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local ddzRule = require("package_src.games.guandan.gdfuckFaster.GDGameRule")
local GDPKCard = require("package_src.games.guandan.gdcommon.utils.card.GDPKCard")

local GDMyHandCardView = class("GDMyHandCardView", function ()
    return display.newLayer()
end)

local SELECT_COLOR = cc.c3b(158, 198, 228)
local NOAMEL_COLOR = cc.c3b(255, 255, 255)
local GRAY_COLOR = cc.c3b(210,210,210)
local WIDTH_SCALE  = 0.75
local BIG_JOKER_VAULE   = 30
local SAMLL_JOKER_VAULE = 29
local LEVEL_CARD_VALUE = 28 --级牌
local JOKER_NUMBER = 2


function GDMyHandCardView:ctor(parent)
    self.posOffsetX = parent:getPositionX()
    self:setPositionX(-self.posOffsetX)
    self:setTouchEnabled(false)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouchCard(event.name, event.x, event.y)
    end)
    self.tipCardList = {}
    self.width = display.width * WIDTH_SCALE
    self.height = display.height

    self:setContentSize(cc.size(display.width, self.height))
    self.m_cards = {}
    self.m_lastSelectCard = {}

    self.listeners = {}--存储所有的监听   便于在析构函数中移除

    -- 引入牌型判断库
    self.m_ddzRule =  ddzRule:new()

    self:reset()

    --添加监听事件
    self.nHandler = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)
end


--函数功能：    析构函数
--返回值：      无
function GDMyHandCardView:dtor()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    ui关闭函数
--返回值：      无
function GDMyHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    重置
--返回值：      无
function GDMyHandCardView:reset()
    self:setIsBiggerCard(true)
    for k, v in pairs(self.m_cards) do
        self:removeChild(v)
        v = nil
    end
    self.m_cards = {}
end 

--函数功能：    根据view创建时传入的seat来获取到自己的数据模型
--返回值：      返回玩家数据模型
function GDMyHandCardView:getMyPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(GDDefine.SITE) == GDConst.SEAT_MINE then
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

--函数功能：    删除牌
--返回值：      无
--cards：       要删除手牌
--seat：        删除牌的座位
function GDMyHandCardView:onDelCard(cards, seat)
    if seat ~= GDConst.SEAT_MINE  then
        return
    end
    local myPlayerModel = DataMgr:getInstance():getMyPlayerModel()
    local dataCards = myPlayerModel:getProp(GDDefine.HAND_CARDS)

    local tableFind = function(tb, value)
        for k,v in pairs(tb) do
            if value == v then
                return true
            end
        end
        return false
    end

    -- Log.i("dataCards :", dataCards)
    local delcard = {}
    self.m_cards = checktable(self.m_cards)
    for k,v in pairs(cards) do
        for i = 1, #self.m_cards do 
            local uicard = self.m_cards[i]:getCard()
            -- Log.i("uicard : ", uicard)
            if uicard == v then
                table.insert(delcard, uicard)
                break
            end
        end
    end
    -- Log.i("GDMyHandCardView:onDelCard: delcard", delcard)
    self:onOutCard(delcard)

    for i,v in ipairs(self.m_cards) do
        if v:getStatus() == GDCard.STATUS_NORMAL_GRAY then
            v:setStatus(GDCard.STATUS_NORMAL)
            v:setColor(NOAMEL_COLOR)
        end
    end
end


--函数功能：    发牌
--cards：       要添加的手牌
--isReconnect:  是否重连
function GDMyHandCardView:dealCard(cards, isReconnect)
    -- Log.i("GDMyHandCardView:dealCard cards", cards)
    -- Log.i("GDMyHandCardView:dealCard isReconnect", isReconnect)
    ----------------------
    self:reset()
    self:stopAllActions()
    self.m_ddzRule:updateWanFa()
    ----------------------
    
    local interval = 0.05
    if not cards or #cards == 0 then
        return
    end
    self:reset()
    if not isReconnect then
        self.posVerState = false --竖向摆牌
        self:setTouchEnabled(false)
        for k, v in ipairs(cards) do
            self:performWithDelay(function()
                self:addCards({v})
                if k == #cards then
                    self:moveToCenter()
                    -- HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONDEALCARDEND)
                    -- HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                end
            end, k * interval, true)
        end
    else
        -- HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONDEALCARDEND)
        -- HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        self.posVerState = true
        self:addCards(cards)
        self:setTouchEnabled(true)
    end
end

--函数功能：    加入到手牌中
--返回值：      无
--cards：       需要添加的牌
function GDMyHandCardView:addCards(cards)
    if cards == nil or #cards == 0 then
        return
    end
    if VideotapeManager.getInstance():isPlayingVideo() then
        for i, card in pairs(cards) do
            local cardType, cardValue = GDCard.cardConvert(card)
            local cardView = PokerCardView.new(cardType, cardValue,card,GDCard.TYPE_OUT)
            cardView:setScale(1.5)
            cardView:setTouchEnabled(false)
            self:addChild(cardView)
            table.insert(self.m_cards, cardView)
        end
    else
        for i, card in pairs(cards) do
            local cardType, cardValue = GDCard.cardConvert(card)
            local cardView = PokerCardView.new(cardType, cardValue,card)
            cardView:setScale(GDCard.SCALE)
            cardView:setTouchEnabled(false)
            self:addChild(cardView)
            table.insert(self.m_cards, cardView)
        end
    end
    self:sortByValue()
end

--函数功能：    从手牌中移除
--返回值：      无
--cards：       要移除的牌
function GDMyHandCardView:removeCards(cards) 
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

--函数功能：    根据牌值手牌排序
--返回值：      无
function GDMyHandCardView:sortByValue()
    local getCardValue = function(card)
        local cardValue = card:getValue()
        if cardValue == RULESETTING.nLevelCard then
            if card:getType() == 2 then--万能牌显示在最下面
                return LEVEL_CARD_VALUE*4 - 1
            else
                return LEVEL_CARD_VALUE*4 + card:getType()
            end
        else
            if cardValue == 15 then
                cardValue = 2
            end
            return cardValue * 4 + card:getType()
        end
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

--函数功能：    清楚牌的点击状态
--返回值：      无
function GDMyHandCardView:cleanTouchState()
    self.m_beginTouchIndex = -1
    self.m_lastTouchIndex = -1
    self.m_lastTouchData = -1
    self.m_stopMoving = false
end


--函数功能：    清楚牌的点击状态
--返回值card:   点击的牌值
--i:            点击的牌的下标
--x:            触摸的x坐标
--y:            触摸的y坐标
function GDMyHandCardView:getCardAndIndex(x, y)
    for i = #self.m_cards, 1, -1 do
        local card = self.m_cards[i]
        if self.m_cards[i]:isClick(cc.p(x, y)) then
            return card, i
        end
    end
    return nil
end

function GDMyHandCardView:checkRect(beginRanks, endRanks)
    local startR = {}
    local endR = {}
    if endRanks.row > beginRanks.row then--向上
        startR.row = beginRanks.row
        endR.row = endRanks.row
    else
        startR.row = endRanks.row
        endR.row = beginRanks.row
    end

    if endRanks.col > beginRanks.col then--向右
        startR.col = beginRanks.col
        endR.col = endRanks.col
    else
        startR.col = endRanks.col
        endR.col = beginRanks.col
    end

    for k,v in pairs(self.m_cards) do
        local ranks = v:getRanks()
        local row = ranks.row--行
        local col = ranks.col--列
        
        if v:getStatus() ~= GDCard.STATUS_NORMAL_GRAY then
            if startR.row <= row and row <= endR.row and
               startR.col <= col and col <= endR.col then
                --select
                local has = false
                for j,h in pairs(self.m_lastSelectCard) do
                    if v == h then
                        has = true
                        v:setStatus(GDCard.STATUS_NORMAL)
                        break
                    end
                end
                if not has then
                    v:setStatus(GDCard.STATUS_SELECT)
                end
            else
                local has = false
                for j,h in pairs(self.m_lastSelectCard) do
                    if v == h then
                        has = true
                        break
                    end
                end
                if not has then
                    v:setStatus(GDCard.STATUS_NORMAL)
                end
            end
        end
    end
end
--函数功能：    清楚牌的点击状态
--返回值:       无
--EventType:    点击类型
--x:            触摸的x坐标
--y:            触摸的y坐标
function GDMyHandCardView:onTouchCard(EventType, x, y)
    local card, index = self:getCardAndIndex(x, y)

    local function checkLastRoundSelectCard(index)
        if card:getStatus() == GDCard.STATUS_NORMAL_GRAY then
            return
        end
        local has = false
        for k,v in pairs(self.m_lastSelectCard) do
            if v == card then
                has = true
                card:setStatus(GDCard.STATUS_NORMAL)
                break
            end
        end
        if not has then
            card:setStatus(GDCard.STATUS_SELECT)
        end
    end

    if EventType == "began" then 
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
        self:cleanTouchState()
        self:SetIsTouchMove(false)
        if card then 
            self.m_beginTouchIndex = index
            self.m_lastTouchIndex = index
            self.m_lastTouchData = index
            self.beginRanks = card:getRanks()

            checkLastRoundSelectCard(index)
        else
            self:onChongXuanClick()
        end
        self.moveIndex = nil
        return true
    elseif EventType == "moved" then
        if card then
            if not self.m_beginTouchIndex or self.m_beginTouchIndex == -1 then
                self.m_beginTouchIndex = index
                self.m_lastTouchIndex = index
                self.m_lastTouchData = index
                self.beginRanks = card:getRanks()

                checkLastRoundSelectCard(index)
                return
            end
            if not self.moveIndex then
                self.moveIndex = index
                checkLastRoundSelectCard(index)
            elseif self.moveIndex == index then
                local has = false
                for j,h in pairs(self.m_lastSelectCard) do
                    if card == h then
                        has = true
                        break
                    end
                end
                if not has and card:getStatus() ~= GDCard.STATUS_NORMAL_GRAY then
                    card:setStatus(GDCard.STATUS_SELECT)
                end
            else
                local endRanks = card:getRanks()
                self:checkRect(self.beginRanks, endRanks)
                self.moveIndex = index
            end
            
            self.m_lastTouchIndex = index
        end
    else 
        if self.m_beginTouchIndex and self.m_beginTouchIndex ~= -1 then
            kPokerSoundPlayer:playEffect("cardClick")
        end
        if self.m_lastTouchData ~= self.m_lastTouchIndex then
            self:SetIsTouchMove(true)
        else
            self:SetIsTouchMove(false)
        end
        self:onTouchEnd()
    end

    self:updatePoker(true)
end

--函数功能：    设置是否是滑选
--move：        滑选
--返回值：      无
function GDMyHandCardView:SetIsTouchMove(move)
    self.m_isTouchMove = move
end
--函数功能：    获取是否是滑选
--返回值：      滑选
function GDMyHandCardView:GetIsTouchMove()
    return self.m_isTouchMove
end

--函数功能：    强制停止触摸事件
--返回值:       无
function GDMyHandCardView:onStopMoving()
    self.m_stopMoving = true
    -- self:changeStatus(GDCard.STATUS_NORMAL_SELECT, GDCard.STATUS_NORMAL)
    -- self:changeStatus(GDCard.STATUS_POP_SELECT, GDCard.STATUS_POP)
    self:popCards({})
end

--函数功能：    点击结束
--返回值:       无
function GDMyHandCardView:onTouchEnd()
    if self.m_stopMoving then
        return
    end
    
    -- self:changeStatus(GDCard.STATUS_NORMAL_SELECT, GDCard.STATUS_POP)
    -- self:changeStatus(GDCard.STATUS_POP_SELECT, GDCard.STATUS_NORMAL)
    self:onHandCardSelect()
    self:cleanTouchState()

    self.m_lastSelectCard = {}
    for i = 1, #self.m_cards, 1 do
        local state = self.m_cards[i]:getStatus()
        if state ~= GDCard.STATUS_NORMAL and state ~= GDCard.STATUS_NORMAL_GRAY then
            table.insert(self.m_lastSelectCard, self.m_cards[i])
        end
    end
end

--函数功能：    点击手牌后的处理
--返回值:       无
function GDMyHandCardView:onHandCardSelect()
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if gameStatus == GDConst.STATUS_ON_JINGONG then
        local jinTab = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_JINGGONGMAP)
        for k,v in pairs(jinTab) do
            if tonumber(k) == kUserInfo:getUserId() then
                if not next(v) then
                    local selectedCardValues = self:getSelectedCardValues()
                    if selectedCardValues and #selectedCardValues > 0 then
                        local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
                        local cards = self:getCardsByView(cardViews)

                        local cmpValues = {}
                        for i,v in pairs(cards) do
                            cmpValues[i] = GDCard.ConvertToserver(v)
                        end

                        if next(self.m_ddzRule:GetPutOutCard(cmpValues)) and #cards == 1 then
                            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, true)
                        else
                            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
                        end
                    end
                end
                break
            end
        end
        return
    elseif gameStatus == GDConst.STATUS_ON_HUANGONG then
        local huanTab = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_HUANGONGMAP)
        for k,v in pairs(huanTab) do
            if tonumber(k) == kUserInfo:getUserId() then
                if not next(v) then
                    local selectedCardValues = self:getSelectedCardValues()
                    if selectedCardValues and #selectedCardValues > 0 then
                        local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
                        local cards = self:getCardsByView(cardViews)
                        local cmpValues = {}
                        for i,v in pairs(cards) do
                            cmpValues[i] = GDCard.ConvertToserver(v)
                        end

                        if next(self.m_ddzRule:GetPutInCard(cmpValues)) and #cards == 1 then
                            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, true)
                        else
                            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
                        end
                    end
                end
                break
            end
        end
        return
    end

    local seat = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_OPERATESEATID)
    if seat ~= GDConst.SEAT_MINE 
        then
        return
    end

    local info = {}
    info.action = "handCardSelect"
    info.selCardLegal = false
    local selectedCardValues = self:getSelectedCardValues()
    if selectedCardValues and #selectedCardValues > 0 then
        local lastOutCards = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS)
        local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
        local cards = self:getCardsByView(cardViews)

        --Modify 2018-7-26 19:30:14 diyal start 
        --修复单击牌的打牌的Bug（table引用问题）
        Log.i("--GDMyHandCardView:onHandCardSelect===self:GetIsTouchMove()==", self:GetIsTouchMove())
        if self:GetIsTouchMove() then
            info = self:CardsTouchMove(cards,lastOutCards,info)
        else
            info = self:CardsTouchRadio(cards,lastOutCards,info)
        end
    end

    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, info.selCardLegal)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
end

--函数功能：    处理滑动选牌
--cards:       选中的牌
--lastOutCards:其他玩家出的牌
--info：       设置的数据
--返回值：      设置的数据
function GDMyHandCardView:CardsTouchMove(cards,lastOutCards,info)
    local cmpValues = {}
    for i,v in pairs(lastOutCards) do
        cmpValues[i] = GDCard.ConvertToserver(v)
    end
    for i,v in pairs(cards) do
        cards[i] = GDCard.ConvertToserver(v)
    end

    Log.i("--GDMyHandCardView:CardsTouchMove===lastOutCards==", lastOutCards)
    if not lastOutCards or not next(lastOutCards) then
        local tmpTipCards = self.m_ddzRule:GetCardType(cards) 
        Log.i("--GDMyHandCardView:CardsTouchMove===tmpTipCards==", tmpTipCards)
        if tmpTipCards ~= enmCardType.EBCT_TYPE_NONE then
            info.selCardLegal = true
        end
        return info
    else
        local lastCardType = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_LASTCARDTYPE)
        local tmpTipCards = self.m_ddzRule:PressCard(cards, cmpValues,true, lastCardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS,lastCardType) 
        Log.i("--GDMyHandCardView:CardsTouchMove===tmpTipCards==", tmpTipCards)
        if tmpTipCards and next(tmpTipCards) then
            info.selCardLegal = true
        end
        return info
    end
end

--函数功能：    处理单选牌
--cards:       选中的牌
--lastOutCards:其他玩家出的牌
--info：       设置的数据
--返回值：      设置的数据
function GDMyHandCardView:CardsTouchRadio(cards,lastOutCards,info)
    for i,v in pairs(cards) do
        cards[i] = GDCard.ConvertToserver(v)
    end
    local cmpValues = {}
    for i,v in pairs(lastOutCards) do
        cmpValues[i] = GDCard.ConvertToserver(v)
    end

    info.selCardLegal = true
    local tempType = self.m_ddzRule:GetCardType(cards)
    local cardsType = self:getOutCardsType(tempType, #cards)
    Log.i("--GDMyHandCardView:CardsTouchRadio==630===", cardsType)
    if not cardsType then
        info.selCardLegal = false
    end

    if lastOutCards and #lastOutCards > 0 then
        local lastCardType = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_LASTCARDTYPE)
        local temp = self.m_ddzRule:PressCard(cards,cmpValues,true, lastCardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS,lastCardType)
        Log.i("--GDMyHandCardView:CardsTouchRadio===637==", temp)
        if (not temp) or (not next(temp)) then
            info.selCardLegal = false
        end
    end
    return info
end

--函数功能：    获取选中手牌的值
--返回值:       选中手牌的值
function GDMyHandCardView:getSelectedCardValues()
    local selectedCardValues = {}
    for k, v in pairs(self.m_cards) do
        if v:getStatus() == GDCard.STATUS_SELECT then
            table.insert(selectedCardValues, v:getValue())
        end
    end
    return selectedCardValues
end

--函数功能：      更新牌的状态
--返回值:         无
--isUpateAll ：   是否更新所有牌
function GDMyHandCardView:updatePoker(isUpateAll)
    isUpdatePos = isUpdatePos or true
    local isChange = false
    for _, v in pairs(self.m_cards) do 
        if v:isStatusChanged() or isUpateAll then 
            isChange = true
            if v:getStatus() == GDCard.STATUS_NORMAL then
                v:setColor(NOAMEL_COLOR)
            elseif v:getStatus() ~= GDCard.STATUS_NORMAL_GRAY
                then
                v:setColor(SELECT_COLOR)
            end
        end
    end

    if isChange and isUpdatePos then
        self:resetPosition()
    end
end


--函数功能：      重设牌位置
--返回值:         无
function GDMyHandCardView:resetPosition()
    if self.posVerState and not VideotapeManager.getInstance():isPlayingVideo() then
        --相同牌值放 一起
        local sortTab = {}
        local tabIndex = {}
        local count = 0
        for k,v in pairs(self.m_cards) do
            local value = v:getValue()
            if sortTab[value] then
                table.insert(sortTab[value], v)
            else
                sortTab[value] = {}
                count = count + 1
                table.insert(sortTab[value], v)
                table.insert(tabIndex, value)
            end
        end

        if count > 0 then
            local space = self:getSpace(count)
            local x = self.width/2  - count/2*space - (GDCard.WIDTH - space)/2 + GDCard.WIDTH/2 + self.posOffsetX
            for k, v in ipairs(tabIndex) do
                local temp = sortTab[v]
                local total = #temp
                for j=total, 1, -1 do
                    local card = temp[j] 
                    card:setPosition(cc.p(x, GDCard.HEIGHT/2 + (total-j)*GDCard.DISHEIGHT)) 
                    card:setRanks(total-j+1, k)
                end
                x = x + space
            end
        end
    else
        local cardNum = #self.m_cards
        if cardNum > 0 then
            local space = self:getSpace(cardNum)
            local x = self.width/2  - cardNum/2*space - (GDCard.WIDTH - space)/2 + GDCard.WIDTH/2 + self.posOffsetX
            for k, v in ipairs(self.m_cards) do 
                v:setPosition(cc.p(x, GDCard.HEIGHT/2))
                
                x = x + space
            end
        end
    end
end

function GDMyHandCardView:moveToCenter()
    local cardNum = #self.m_cards
    if cardNum > 0 then
        local moveToPosX, moveToPosY = self.m_cards[math.ceil(cardNum/2)]:getPosition()
        for k, v in ipairs(self.m_cards) do
            local vPosX = v:getPositionX()
            local duration = 0.2
            local moveTo = cc.MoveTo:create(duration, cc.p(moveToPosX, moveToPosY))
            if k == cardNum-1 then
                local delay = cc.DelayTime:create(duration)
                local func = cc.CallFunc:create(function()
                    self.posVerState = true
                    self:resetPosition()
                    self:setTouchEnabled(true)
                    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONDEALCARDEND)
                    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                end)
                local seq = cc.Sequence:create(moveTo, delay, func)
                v:runAction(seq)
            else
                v:runAction(moveTo)
            end
        end
    end
end

--函数功能：      提起牌
--返回值:         无
--cardValues:     要弹起的牌的牌值
function GDMyHandCardView:popCards(cardValues)
    if not cardValues then
        return
    end

    table.sort(cardValues, function(a, b)
        return a > b
    end)

    local popCards = self:getCardsByStatus(GDCard.STATUS_SELECT)

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
            v:setStatus(GDCard.STATUS_NORMAL)
        end
    end

    if #cardValues > 0 then
        local cardValuesIndex = 1
        for i, v in pairs(self.m_cards) do 
            if v:getStatus() ~= GDCard.STATUS_SELECT and v:getValue() == cardValues[cardValuesIndex] then 
                v:setStatus(GDCard.STATUS_SELECT)
                cardValuesIndex = cardValuesIndex + 1
            end
        end
    end
    
    self:updatePoker(false)
end 

--函数功能：      返回某种状态的牌函数
--返回值:         同种状态的手牌
--status:         状态
function GDMyHandCardView:getCardsByStatus(status)
    local ret = {}
    for k, v in ipairs(self.m_cards) do
        if v:getStatus() == status then
            ret[#ret + 1] = v
        end
    end
    return ret
end

--函数功能：      返回手牌之间的牌距
--返回值:         牌距
--cardNum:        牌的数量
function GDMyHandCardView:getSpace(cardNum)
    local space = GDCard.NORMALSPACE
    if cardNum > 1 then
        space = (self.width - GDCard.WIDTH)/(cardNum - 1)
    else
        return 0
    end
    space = space > GDCard.MAXSPACE and GDCard.MAXSPACE or space

    return space
end


--函数功能：      检测能不能压过上手牌
--返回值:         无
function GDMyHandCardView:checkIsBiggerCard()
    local isBigger = false
    self:newGetTipCards()
    local lastOutCards = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS)
    if (self.tipCardList and #self.tipCardList > 0) or not next(lastOutCards) then
        isBigger = true
        self:setIsBiggerCard(true)
        self:onHandCardSelect()
    else
        isBigger = false
        self:setIsBiggerCard(false)
        self:onStopMoving()
    end
    return isBigger
end


--函数功能：     设置能否压过上手牌UI状态展示
--返回值:        无
--isBigger：     是否有压过的牌
function GDMyHandCardView:setIsBiggerCard(isBigger)
    if isBigger then 
        HallAPI.EventAPI:dispatchEvent(GDGameEvent.SHOWNOBIGGER, not isBigger)
        self:setTouchEnabled(true)
    else
        local tuoguanState = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
        if tuoguanState == GDConst.TUOGUAN_STATE_0 then
             HallAPI.EventAPI:dispatchEvent(GDGameEvent.SHOWNOBIGGER, not isBigger)
        end
    end
end

--函数功能：     获取提示牌
--返回值:        提示牌    
function GDMyHandCardView:newGetTipCards()
    -- 上一手牌的值
    local lastOutCards = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS)
    -- Log.i("--wangzhi--lastOutCards--",lastOutCards)
    local handcardList = {}
    for i,v in ipairs(self.m_cards) do
        table.insert(handcardList,v:getCard())
    end
    
    local selfCards = {}
    for i,v in pairs(handcardList) do
        local card = GDPKCard.ConvertToserver(v) 
        table.insert(selfCards,card)
    end
    local obCards = {}
    for i,v in pairs(lastOutCards) do
        local card = GDPKCard.ConvertToserver(v)
        table.insert(obCards,card)
    end
    -- Log.i("--wangzhi--上一手牌--004",obCards)
    -- Log.i("--wangzhi--cmpValues--004",selfCards)
    local lastCardType = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_LASTCARDTYPE)
    local tmpTipCards = self.m_ddzRule:PressCard(selfCards,obCards, false, lastCardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS,lastCardType)
    if tmpTipCards and #tmpTipCards > 0 then
        if obCards and #obCards > 0  then
            local cardsType = self.m_ddzRule:GetCardType(obCards)
            if cardsType == enmCardType.EBCT_BASETYPE_SINGLE and #self:getNextPlayerCards() == 1 then
                tmpTipCards = tmpTipCards[#tmpTipCards]
                if tolua.type(tmpTipCards[#tmpTipCards]) ~= "table" then
                    tmpTipCards = {tmpTipCards}
                end
            end
        else
            if #self:getNextPlayerCards() == 1 then
                local isCardEnd = true
                for i,v in pairs(tmpTipCards) do
                    if #v > 1 then
                        isCardEnd = false
                        break
                    end
                end
                if isCardEnd then
                    tmpTipCards = {tmpTipCards[#tmpTipCards]}
                end
            end
        end
    end
    
    local tipCards = {}
    for i,v in ipairs(tmpTipCards) do
        tipCards[i] = {}
        for _i,_v in ipairs(v) do
            local tmpLocalCard = GDPKCard.ConvertToLocal(_v)
            local tmpCardType,tmpCard = GDPKCard.cardConvert(tmpLocalCard)
            table.insert(tipCards[i],tmpCard)
        end
    end
   
    self.tipCardList = tipCards
end

--函数功能：    获取下家的手牌
--返回值：      返回玩手牌数量
function GDMyHandCardView:getNextPlayerCards()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(GDDefine.SITE) == GDConst.SEAT_RIGHT then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    local cards = dstPlayer:getProp(GDDefine.HAND_CARDS)
    return cards
end

--函数功能：     不出按钮回调
--返回值:        无    
--notSendMsg：   不发送信息
function GDMyHandCardView:onBuChuClick(notSendMsg)
    self:popCards({})
    -- GDGameManager.getInstance():setLastTipCardValues({})
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTIPS, {})
    if notSendMsg then
        return
    end
    local data = {}
    data.gaPI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMEPLAYID)
    data.fl = 0
    data.usI = HallAPI.DataAPI:getUserId()
    data.ouCT = GDConst.CARDSTYPE.EBCT_TYPE_NONE
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_SEND_OUTCARD, data)
end

--函数功能：     重选
--返回值:        无    
function GDMyHandCardView:onChongXuanClick()
    self.m_lastSelectCard = {}
    self:popCards({})
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTIPS, {})
    -- GDGameManager.getInstance():setLastTipCardValues({})
end

--函数功能：     出牌
--返回值:        无  
function GDMyHandCardView:onChuClick()
    local lastOutCards = clone(DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS))
    local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
    local cards = self:getCardsByView(cardViews)
    for i,v in pairs(lastOutCards) do
        lastOutCards[i] = GDCard.ConvertToserver(v)
    end
    for i,v in pairs(cards) do
        cards[i] = GDCard.ConvertToserver(v)
    end
    local data = {}
    data.gaPI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMEPLAYID)
    data.fl = 1
    data.usI = HallAPI.DataAPI:getUserId()
    data.plC = cards
    local lastCardType = self.m_ddzRule:GetCardType(lastOutCards)
    if lastCardType ~= enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
        lastCardType = nil
    end 
    local tempType = self.m_ddzRule:GetCardType(data.plC,lastCardType)
    local cardsType = self:getOutCardsType(tempType, #cards)
    data.ty = cardsType
    data.ouCT = cardsType
    -- kPokerSoundPlayer:playEffect("card_out")
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_SEND_OUTCARD, data)
end
--函数功能：     进贡
--返回值:        无  
function GDMyHandCardView:onJingongClick()
    local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
    local cards = self:getCardsByView(cardViews)
    for i,v in pairs(cards) do
        cards[i] = GDCard.ConvertToserver(v)
    end

    local data = {}
    data.jiGC = {cards[1]}
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_SEND_JINGONG, data)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
end
--函数功能：     进贡
--返回值:        无  
function GDMyHandCardView:onHuanGongClick()
    local cardViews = self:getCardsByStatus(GDCard.STATUS_SELECT)
    local cards = self:getCardsByView(cardViews)
    for i,v in pairs(cards) do
        cards[i] = GDCard.ConvertToserver(v)
    end

    local data = {}
    data.huGC = {cards[1]}
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_SEND_HUANGONG, data)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
end

function GDMyHandCardView:getOutCardsType(cardsType, count)
    if cardsType == enmCardType.EBCT_BASETYPE_SINGLE then
        --单张
        return GDConst.CARDSTYPE.EBCT_BASETYPE_SINGLE
    elseif cardsType == enmCardType.EBCT_BASETYPE_PAIR then
        --对子
        return GDConst.CARDSTYPE.EBCT_BASETYPE_PAIR
    elseif cardsType == enmCardType.EBCT_BASETYPE_3KIND then
        --三张
        return GDConst.CARDSTYPE.EBCT_BASETYPE_3KIND
    elseif cardsType == enmCardType.EBCT_BASETYPE_3AND2 then
        --三带二
        return GDConst.CARDSTYPE.EBCT_BASETYPE_3AND2
    elseif cardsType == enmCardType.EBCT_BASETYPE_SISTER then
        --顺子
        return GDConst.CARDSTYPE.EBCT_BASETYPE_SISTER
    elseif cardsType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
        --木板
        return GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_PAIRS
    elseif cardsType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
        --钢板
        return GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_3KINDS
    elseif cardsType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
        --炸弹
        if count == 4 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB
        elseif count == 5 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB5
        elseif count == 6 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB6
        elseif count == 7 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB7
        elseif count == 8 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB8
        elseif count == 9 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB9
        elseif count == 10 then
            return GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB10
        end 
    elseif cardsType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
        --同花顺
        return GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_SISTER_BOMB
    elseif cardsType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
        --天王炸
        return GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_KING_BOMB
    end
end

--函数功能：     获取某个手牌的牌值
--返回值:        手牌的牌值  
--cardViews：    手牌
function GDMyHandCardView:getCardsByView(cardViews)
    local cards = {}
    if cardViews and #cardViews > 0 then
        for k, v in pairs(cardViews) do
            local val = v:getCard()
            table.insert(cards, val)
        end
    end
    return cards
end

--函数功能：     获取牌值
--返回值:        牌值 
--cards：        牌组
function GDMyHandCardView:getCardValues(cards)
    local cardValues = {}
    if cards and #cards > 0 then
        for k, v in pairs(cards) do
            local type, val = GDCard.cardConvert(v)
            table.insert(cardValues, val)
        end
    end
    return cardValues
end

--函数功能：     出牌后
--返回值:        无 
--cards：        牌组
function GDMyHandCardView:onOutCard(cards)
    self:setIsBiggerCard(true)
    local cardValues = self:getCardValues(cards)
    if not cardValues or #cardValues == 0 then
        self:onBuChuClick(true)
    else
        self:removeCards(cards)
        self:onBuChuClick(true)
    end
end

--函数功能：     托管改变
--返回值:        无 
function GDMyHandCardView:onTuoGuanChange()
    local tuoguanState = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
    if tuoguanState == GDConst.TUOGUAN_STATE_1 then
        self:setTouchEnabled(false)
        self:onStopMoving()
    else
        self:setTouchEnabled(true)
    end
end

--函数功能：     游戏结束
--返回值:        无 
function GDMyHandCardView:onGameOver()
    self:onStopMoving()
    self:setIsBiggerCard(true)
    self:setTouchEnabled(false)
end

--函数功能：     把不可进贡/还贡的牌置灰
function GDMyHandCardView:grayGongCards()
    local cards = {}
    for k, v in ipairs(self.m_cards) do
        local val = GDCard.ConvertToserver(v:getCard())
        table.insert(cards, val)
    end

    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    local JinGongMap = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_JINGGONGMAP)
    local HuanGongMap = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_HUANGONGMAP)
    if gameStatus == GDConst.STATUS_ON_JINGONG then
        if JinGongMap and JinGongMap[tostring(kUserInfo:getUserId())] then
            local grayCards = self.m_ddzRule:GetPutOutCard(cards)
            for k, v in ipairs(self.m_cards) do
                local val = GDCard.ConvertToserver(v:getCard())
                local has = false
                for kk,vv in pairs(grayCards) do
                    if val == vv then
                        has = true
                    end
                end
                if not has then
                    v:setStatus(GDCard.STATUS_NORMAL_GRAY)
                    v:setColor(GRAY_COLOR)
                end
            end
        end
    elseif gameStatus == GDConst.STATUS_ON_HUANGONG then
        if HuanGongMap and HuanGongMap[tostring(kUserInfo:getUserId())] then
            local grayCards = self.m_ddzRule:GetPutInCard(cards)
            for k, v in ipairs(self.m_cards) do
                local val = GDCard.ConvertToserver(v:getCard())
                local has = false
                for kk,vv in pairs(grayCards) do
                    if val == vv then
                        has = true
                    end
                end
                if not has then
                    v:setStatus(GDCard.STATUS_NORMAL_GRAY)
                    v:setColor(GRAY_COLOR)
                end
            end
        end
    end
end
--函数功能：     把进贡/还贡的置灰牌恢复正常状态
function GDMyHandCardView:removeGrayGongCards()
    for k, v in ipairs(self.m_cards) do
        if v:getStatus() == GDCard.STATUS_NORMAL_GRAY then
            v:setStatus(GDCard.STATUS_NORMAL)
            v:setColor(NOAMEL_COLOR)
        end
    end
end

return GDMyHandCardView