--[[----------------------------------------
    作者:          faker
    日期：         2017.12.6
    摘要:      对家手牌UI层，包括对手牌的处理
-------------------------------------------]]

local PorkerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local DDZTWOPGameEvent = require("package_src.games.ddztwop.data.DDZTWOPGameEvent")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local PokerUtils =require("package_src.games.pokercommon.commontool.PokerUtils")
local BasePlayerDefine = require("package_src.games.pokercommon.data.BasePlayerDefine")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")

local DDZTWOPOtherHandCardView = class("DDZTWOPOtherHandCardView", function ()
    return display.newLayer()
end)

---------------------------------------
-- 函数功能：构造函数 初始化数据
--------------------------------------
function DDZTWOPOtherHandCardView:ctor(delegate)
    self:setTouchEnabled(false)
    self.m_delegate = delegate
    --手牌UI宽度
    self.width = DDZTWOPCard.OTHERHANDWIDTH
    --手牌UI高度
    self.height = DDZTWOPCard.OTHERHANDHEIGHT
    --存储所有手牌
    self.m_cards = {}

    --是否根据牌值进行排序
    self.sortByNum = false
    self:setContentSize(cc.size(self.width,self.height))

    --存储所有的监听   便于在析构函数中移除
    self.listeners= {}
    --添加监听事件
    self.nHandler=HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)
end

---------------------------------------
-- 函数功能：   关闭函数  用于清除注册的消息
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPOtherHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

---------------------------------------
-- 函数功能：   重置手牌UI
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPOtherHandCardView:reset()
    for k, v in pairs(self.m_cards) do
        self:removeChild(v)
        v = nil
    end
    self.m_cards = {}
end 

---------------------------------------
-- 函数功能：   根据牌值对手牌进行排序
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPOtherHandCardView:sortByValue()
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType()
    end

    for i = 2, #self.m_cards do 
        local card = self.m_cards[i]
        if card then
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
    end
      
    for i, v in ipairs(self.m_cards) do
        v:setLocalZOrder(i)
    end
    local state = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    local debug = DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_DEBUGSTATE)
    if not debug then 
        if state < DDZTWOPConst.STATUS_PLAY then
            self:setMingCard()
        else
            self:hideMingCard()
        end
    end
    self:updatePoker(true)
end

----------------------------------------------
-- 函数功能： 设置明牌的位置
-- 返回值：   无
----------------------------------------------
function DDZTWOPOtherHandCardView:setMingCard()
    local mingCard = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAICARD)
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType()
    end
    for i,v in ipairs(self.m_cards) do
        if v:getCard() == DDZTWOPCard.ConvertToLocal(mingCard) then
            v:showAsCard()
        else
            v:showAsBackBg()
        end
    end
end

----------------------------------------------
-- 函数功能： 隐藏明牌的位置
-- 返回值：   无
----------------------------------------------
function DDZTWOPOtherHandCardView:hideMingCard()
    local mingCard = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAICARD)
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType()
    end
    for i,v in ipairs(self.m_cards) do
        v:showAsBackBg()
    end
end

---------------------------------------
-- 函数功能：     发牌函数
-- 返回值：        无
--[[
    参数：
    cards:         对家手牌数据
    isReconnect:   是否是重新连接
]]
---------------------------------------
function DDZTWOPOtherHandCardView:dealCard(cards, isReconnect)
    --连续两次发牌（出现手牌超过17张的情况） 在这里重置手牌数据  停止所有定时器
    ------------------------
    self:reset()
    self:stopAllActions()
    ------------------------
    local mingCard = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAICARD)
    if not cards or #cards == 0 then
        return
    end

    if not isReconnect then
        self:setTouchEnabled(false)
        for k, v in pairs(cards) do
            self:performWithDelay(function()
                self:addCards({v})
            end, k * DDZTWOPConst.DISPENSE_DELAY)
        end
    else
        self:addCards(cards)
    end
    self:setTouchEnabled(true)
end

---------------------------------------
-- 函数功能：   加入底牌函数
-- 返回值：     无
--[[
    参数：
    cards:      地主底牌数据
]]
---------------------------------------
function DDZTWOPOtherHandCardView:addBottomCard(cards)
    self:addCards(cards)
end

---------------------------------------
-- Author:      faker
-- 函数功能：   将牌加入到手牌中
-- 返回值：     无
--[[
    参数：
    cards:   需要加入手牌的牌数据
]]
---------------------------------------
function DDZTWOPOtherHandCardView:addCards(cards)
    if cards == nil or #cards == 0 then
        return
    end

    local mineCardCount = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_OTHERCARDCOUNT) or 0
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_OTHERCARDCOUNT,mineCardCount + #cards)

    for i, card in pairs(cards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setTouchEnabled(false)
        cardView:setScale(cardView:getScale() * DDZTWOPCard.OTHERSCALE)
        self:addChild(cardView)
        table.insert(self.m_cards, cardView)
    end
    
    for i, v in ipairs(self.m_cards) do
        v:setLocalZOrder(i)
    end
    self:sortByValue()
end

---------------------------------------
-- Author:     faker
-- 函数功能：   将牌从手牌中移除
-- 返回值：     无
--[[
    参数：
    cards:     需要从手牌中移除的牌数据
]]
---------------------------------------
function DDZTWOPOtherHandCardView:removeCards(cards) 
    local mineCardCount = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_OTHERCARDCOUNT) or 0
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_OTHERCARDCOUNT,mineCardCount + #cards)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.SHOWTIPCOUNT)
    --if not DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_DEBUGSTATE) then
        for _, card in pairs(cards) do
            for k, v in pairs(self.m_cards) do 
                if card == v:getCard() then
                    self:removeChild(v)
                    table.remove(self.m_cards, k)
                    break
                end
            end
        end
    --end
    self:updatePoker(true)
end

---------------------------------------
-- Author:      faker
-- 函数功能：   清除触摸状态函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:cleanTouchState()
    self.m_beginTouchIndex = -1
    self.m_lastTouchIndex = -1
    self.m_lastTouchX = nil
    self.m_lastTouchY = nil
    self.m_stopMoving = false
end

---------------------------------------
-- 函数功能：   根据触摸点返回手牌
-- 返回值：     无
--[[
    参数:
    触摸点x值
    触摸点y值
]]
---------------------------------------
function DDZTWOPOtherHandCardView:getCardAndIndex(x, y)
    for i = #self.m_cards, 1, -1 do
        local card = self.m_cards[i]
        if self.m_cards[i]:isClick(cc.p(x, y)) then
            return card, i
        end
    end
    return nil
end

---------------------------------------
-- 函数功能：   获取所有手牌的牌值
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:getHandCardValues()
    local cardValues = {}
    for k, v in pairs(self.m_cards) do
        table.insert(cardValues, v:getValue())
    end
    return cardValues
end

---------------------------------------
-- 函数功能：   更新牌的状态
-- 返回值：     无
--[[
    参数
    srcStatus    卡牌当前状态
    destStatus   需要设置的状态
    begIndex     开始索引
    endIndex     结束索引
]]
---------------------------------------
function DDZTWOPOtherHandCardView:changeStatus(srcStatus, destStatus, begIndex, endIndex)
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
-- 函数功能：   更新牌的展示状态
-- 返回值：     无
-- isUpateAll   是否全部更新
---------------------------------------
function DDZTWOPOtherHandCardView:updatePoker(isUpateAll)
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
    local rangCount = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_RANGPAICOUNT)
    local debug = DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_DEBUGSTATE)
    local isMeLord = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    if self.m_cards and #self.m_cards > 0 and debug then
        for i,v in ipairs(self.m_cards) do
            if i == #self.m_cards then
                self.m_cards[#self.m_cards]:showFlowerImg()
            else
                self.m_cards[i]:hideFlowerImg()
            end
        end
    end

    if isChange then
        self:resetPosition()
    end
end

---------------------------------------
-- 函数功能：   重设牌的位置
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:resetPosition()
    local cardNum = #self.m_cards
    if cardNum > 0 then
        local space = self:getSpace(cardNum)

        local x = self.width/2  - cardNum/2*space - (DDZTWOPCard.WIDTH - space)/2 * DDZTWOPCard.OTHERSCALE+ DDZTWOPCard.WIDTH/2 *DDZTWOPCard.OTHERSCALE
        for k, v in ipairs(self.m_cards) do 
            if v:getStatus() == DDZTWOPCard.STATUS_NORMAL or v:getStatus() == DDZTWOPCard.STATUS_NORMAL_SELECT or v:getStatus() == DDZTWOPCard.STATUS_SHOWRANG then
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2 * DDZTWOPCard.OTHERSCALE))
            else
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2 * DDZTWOPCard.OTHERSCALE + DDZTWOPCard.POPHEIGHT * DDZTWOPCard.OTHERSCALE))   
            end
            
            x = x + space
        end
    end
end

---------------------------------------
-- 函数功能：   返回某种状态的牌
-- 返回值：     同一种状态的牌
-- status：     需要返回的牌的状态
---------------------------------------
function DDZTWOPOtherHandCardView:getCardsByStatus(status)
    local ret = {}
    for k, v in ipairs(self.m_cards) do
        if v:getStatus() == status then
            ret[#ret + 1] = v
        end
    end
    return ret
end

---------------------------------------
-- 函数功能：   返回牌之间的距离
-- 返回值：     牌距
-- cardNum:    牌的数量
---------------------------------------
function DDZTWOPOtherHandCardView:getSpace(cardNum)
    local space = DDZTWOPCard.NORMALSPACE
    if cardNum > 1 then
        space = (self.width - DDZTWOPCard.WIDTH * DDZTWOPCard.OTHERSCALE)/(cardNum - 1)
    else
        return 0
    end
    space = space > DDZTWOPCard.MAXSPACE * DDZTWOPCard.OTHERSCALE and DDZTWOPCard.MAXSPACE * DDZTWOPCard.OTHERSCALE or space

    return space
end

---------------------------------------
-- 函数功能：   返回手牌
-- 返回值：     手牌集合
-- cardViews：  手牌UI集合
---------------------------------------
function DDZTWOPOtherHandCardView:getCardsByView(cardViews)
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
-- 函数功能：   获取牌值
-- 返回值：     牌值集合
-- cards：     手牌集合
---------------------------------------
function DDZTWOPOtherHandCardView:getCardValues(cards)
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
-- 函数功能：   将牌从手牌中移除
-- 返回值：     无
--[[
    参数：
    cards      需要移除的牌集合
    seat       玩家位置
]]
---------------------------------------
function DDZTWOPOtherHandCardView:onDelCard(cards,seat)
    if seat ~= DDZTWOPConst.SEAT_RIGHT then return end
    self:onOutCard(cards)
end

---------------------------------------
-- 函数功能：   出牌函数
-- 返回值：     无
-- cards：      需要打出的牌集合
---------------------------------------
function DDZTWOPOtherHandCardView:onOutCard(cards)
    local cardValues = self:getCardValues(cards)
    if not cardValues or #cardValues == 0 then 
    else
        self:removeCards(cards)
    end
end

---------------------------------------
-- 函数功能：   游戏结束手牌处理函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:onGameOver(info)
    self:setTouchEnabled(false)
    self.sortByNum = false

    --清空别人的手牌
    for k, v in pairs(self.m_cards) do
        self:removeChild(v)
        v = nil
    end  

    -- 
end

---------------------------------------
-- 函数功能：   让牌后设置状态
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:setRangCardsStatus()
    local rangCount = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_RANGPAICOUNT)
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    local debug = DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_DEBUGSTATE)
    local isCertainLord = DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_ISCERTAINLORD)
    if rangCount and isMeLord and not debug and isCertainLord then
        self:hideMingCard()
        for i=1,rangCount do
            if self.m_cards[i] and  self.m_cards[i].showAsRangBg then
                self.m_cards[i]:showAsRangBg()
            end
        end
    end
end

---------------------------------------
-- 函数功能：   奖牌设置为背景牌
-- 返回值：     无
---------------------------------------
function DDZTWOPOtherHandCardView:resetCardsStatus()
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    for k, v in pairs(self.m_cards) do
        if v:getStatus() ~= DDZTWOPCard.STATUS_SHOWRANG or not isMeLord then
            v:showAsBackBg()
        end  
    end
end

---------------------------------------
-- 函数功能：   获取对手玩家player
-- 返回值：     player
---------------------------------------
function DDZTWOPOtherHandCardView:getOtherPlayerModel()
    local playerList = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(playerList) do
        if v:getProp(BasePlayerDefine.SITE) == DDZTWOPConst.SEAT_RIGHT then
            return v
        end
    end
end

return DDZTWOPOtherHandCardView