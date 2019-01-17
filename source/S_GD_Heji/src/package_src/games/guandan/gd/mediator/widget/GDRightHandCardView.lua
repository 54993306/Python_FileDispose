--[[---------------------------------------- 
-- 作者: 汪智
-- 日期: 2018年7月26日15:44:29
-- 摘要: 右家手牌
]]-------------------------------------------

local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")

local GDRightHandCardView = class("GDRightHandCardView", function ()
    return display.newLayer();
end);


local HAND_LAYER_POSITIONX = -100
local HAND_LAYER_POSITIONY = -50

local CARD_SCALE = 0.8

local CARD_SPACE = 20

--函数功能：    构造函数
--返回值：      无
--widget：      ui
function GDRightHandCardView:ctor( widget)
    Log.i("--wangzhi--创建右家手牌区--")
    self:setTouchEnabled(false);
    self.m_pWidget = widget
    self:setPosition(HAND_LAYER_POSITIONX,HAND_LAYER_POSITIONY)
    self.m_cards = {}
    self.listeners = {}
    --添加监听事件
    self.nHandler = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)

    self.nHandler2 = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_ADD, handler(self, self.dealCard))
    table.insert(self.listeners, self.nHandler2)
end

--函数功能：    析构函数
--返回值：      无
function GDRightHandCardView:dtor()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    ui关闭函数
--返回值：      无
function GDRightHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
    self.listeners = nil
end

function GDRightHandCardView:dealCard(cards, isReconnect,seat)
    -- 这里只是为了处理战绩回放,重连不处理,避免对局中有重连，导致牌局异常
    if isReconnect then
        return
    end

    if seat and seat ~= GDConst.SEAT_RIGHT then
        return
    end

    Log.i("--wangzhi--GDRightHandCardView--",cards)
    for i,v in ipairs(cards) do
        local cardType, cardValue = GDCard.cardConvert(v);
        local cardView = PokerCardView.new(cardType, cardValue,v,GDCard.TYPE_OUT);
        cardView:setScale(CARD_SCALE)
        self:addChild(cardView);
        table.insert(self.m_cards,cardView)
    end
    self:sortByValue()
end

--函数功能：    根据牌值手牌排序
--返回值：      无
function GDRightHandCardView:sortByValue()
    
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType();
    end
    for i = 2, #self.m_cards do 
        local card = self.m_cards[i];

        local index = 1;
        for j = i - 1, 1, -1 do
            if getCardValue(card) > getCardValue(self.m_cards[j]) then
                self.m_cards[j + 1] = self.m_cards[j];
            else
                index = j + 1;
                break;
            end
        end

        self.m_cards[index] = card;
    end
    self:updatePoker();
end

--函数功能：      更新牌的状态
--返回值:         无
--isUpateAll ：   是否更新所有牌
function GDRightHandCardView:updatePoker()
    if self.m_cards and #self.m_cards > 0 then
        for i,v in ipairs(self.m_cards) do
            Log.i("--wangzhi--self.m_cards:getValue()--",self.m_cards[i]:getValue())
            if i == #self.m_cards then
                self.m_cards[#self.m_cards]:showFlowerImg()
            else
                self.m_cards[i]:hideFlowerImg()
            end
        end
    end
    self:resetPosition();
end

--函数功能：      重设牌位置
--返回值:         无
function GDRightHandCardView:resetPosition()
    Log.i("--wangzhi--#self.m_cards--",#self.m_cards)
    local CardPositionX = -100
    if #self.m_cards<14 then
        CardPositionX = -100 + CARD_SPACE*(14-(#self.m_cards-1))/2
    end
    for i,v in ipairs(self.m_cards) do
        CardPositionX = CardPositionX +CARD_SPACE
        self.m_cards[i]:setPositionX(CardPositionX)
        if i == 14 then
            CardPositionX = -100
        end
        if i>14 then
            self.m_cards[i]:setPositionY(HAND_LAYER_POSITIONY)
        else
            self.m_cards[i]:setPositionY(HAND_LAYER_POSITIONY+50)
        end
        self.m_cards[i]:setLocalZOrder(i);
        Log.i("--wangzhi--牌的位置--i--",i,self.m_cards[i]:getPosition())
    end
end


--函数功能：    删除牌
--返回值：      无
--cards：       要删除手牌
--seat：        删除牌的座位
function GDRightHandCardView:onDelCard(cards, seat)
    if seat ~= GDConst.SEAT_RIGHT  then
        return
    end
    Log.i("--wangzhi--需要删除的牌--",cards,seat)
    local delCards = {}
    for i,v in ipairs(cards) do
        for i2,v2 in ipairs(self.m_cards) do
            if cards[i] == self.m_cards[i2]:getCard() then
                -- table.insert(delCards,self.m_cards[i2])
                self:removeChild(v2)
                table.remove(self.m_cards, i2)
                Log.i("--wangzhi--删除牌后还剩--self.m_cards--",#self.m_cards)
            end
        end
    end
    self:updatePoker();
end

return GDRightHandCardView