-------------------------------------------------------------------------
-- Desc:   发牌UI
-- Last:
-- Author:   faker
-- 2017-11-07  展示发牌动画
-------------------------------------------------------------------------
--
local PorkerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local PokerUtils =require("package_src.games.pokercommon.commontool.PokerUtils")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPAllCards = class("DDZTWOPOtherHandCardView", function ()
    return display.newNode()
end)

---------------------------------------
-- 函数功能：   构造
-- 返回值：     无
---------------------------------------
function  DDZTWOPAllCards:ctor(delegate)
	self:setTouchEnabled(false)
    self.m_delegate = delegate
    --发牌动画ui宽度
    self.width = display.width
    --发牌动画ui高度
    self.height = DDZTWOPCard.HEIGHT
    self:setContentSize(cc.size(self.width, self.height))
    --存储牌
    self.m_cards = {}
end

---------------------------------------
-- 函数功能：    发牌动画
-- 返回值：      无
---------------------------------------
function DDZTWOPAllCards:dealCard(isReconnect)
    self:removeAllChildren()
    self:stopAllActions()
    local cards = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_ALLHANDCARDS)
    self:setMingCard(cards)
    if not DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_DEBUGSTATE) then
        for i=1,#cards do
            local lordCard = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAICARD)
            if cards[i] ~= lordCard then
                cards[i] = DDZTWOPCard.DEBUGCARD
            else
                cards[i] = DDZTWOPCard.ConvertToLocal(lordCard)
            end
        end
    else
        for i=1,#cards do
            cards[i] = DDZTWOPCard.ConvertToLocal(cards[i])
        end
    end
    self:addCards(cards)
	isReconnect = false
    if not cards or #cards == 0 then
        return
    end
    for k, v in pairs(cards) do
        self:performWithDelay(function()
           self:removeCards({v})
        end, k * DDZTWOPConst.DISPENSE_DELAY * 0.5)
    end
end
---------------------------------------
-- 函数功能：    设置发牌时的明牌
-- 返回值：      无
-- cards：      需要显示的牌的集合
---------------------------------------
function DDZTWOPAllCards:setMingCard(cards)
    local mingCardIdx = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAIIDX)
    local mingCard = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MINGPAICARD)
    for i,v in ipairs(cards) do
        if v == mingCard then
            table.remove(cards,i)
            table.insert(cards,(17 - mingCardIdx)*2 or 1,mingCard)
            break
        end
    end
end

---------------------------------------
-- 函数功能：    将牌加入到牌堆中
-- 返回值：      无
-- cards：      需要加入的牌的集合
---------------------------------------
function DDZTWOPAllCards:addCards(cards)
    if cards == nil or #cards == 0 then
        return
    end
    for i, card in pairs(cards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setTouchEnabled(false)
        cardView:setScale(DDZTWOPCard.SElFSCALE)
        self:addChild(cardView)
        table.insert(self.m_cards, cardView)
    end

    self:resetPosition()
end
---------------------------------------
-- 函数功能：    显示废弃的牌
-- 返回值：      无
-- cards：      需要显示的废弃的牌的集合
---------------------------------------
function DDZTWOPAllCards:addDespatchCards(cards)
    if cards == nil or #cards == 0 then
        return
    end

    for i, card in pairs(cards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setTouchEnabled(false)
        cardView:addDespatchTag()
        cardView:setScale(DDZTWOPCard.SElFSCALE)
        self:addChild(cardView)
        table.insert(self.m_cards, cardView)
    end

    self:resetPosition()
end

---------------------------------------
-- 函数功能：    将牌从牌堆中移除
-- 返回值：      无
-- cards：      需要移除的牌的集合
---------------------------------------
function DDZTWOPAllCards:removeCards(cards) 
    for _, card in pairs(cards) do
        for i = #self.m_cards, 1, -1  do 
                self:removeChild(self.m_cards[i])
                table.remove(self.m_cards, i)
                self.m_cards[i] = nil
                break
        end
    end
end

---------------------------------------
-- 函数功能：    设置牌堆中所有牌的位置
-- 返回值：      无
---------------------------------------
function DDZTWOPAllCards:resetPosition()
    local cardNum = #self.m_cards
    if cardNum > 0 then
        local space = self:getSpace(cardNum)

        local x = self.width/2  - cardNum/2*space - (DDZTWOPCard.WIDTH * DDZTWOPCard.SElFSCALE * 0.5- space)/2 + DDZTWOPCard.WIDTH * DDZTWOPCard.SElFSCALE * 0.5 /2;
        for k, v in ipairs(self.m_cards) do 
            if v:getStatus() == DDZTWOPCard.STATUS_NORMAL or v:getStatus() == DDZTWOPCard.STATUS_NORMAL_SELECT then
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2))
            else
                v:setPosition(cc.p(x, DDZTWOPCard.HEIGHT/2 + DDZTWOPCard.POPHEIGHT))   
            end
            
            x = x + space
        end
    end
end

---------------------------------------
-- 函数功能：    返回牌距
-- 返回值：      无
---------------------------------------
function DDZTWOPAllCards:getSpace(cardNum)
    local space = DDZTWOPCard.NORMALSPACE
    if cardNum > 1 then
        space = (self.width - DDZTWOPCard.WIDTH * DDZTWOPCard.SElFSCALE )/(cardNum - 1)
    else
        return 0
    end
    space = space > DDZTWOPCard.MAXSPACE and DDZTWOPCard.MAXSPACE or space

    return space
end


return DDZTWOPAllCards