--[[---------------------------------------- 
-- 作者: 汪智
-- 日期: 2018年7月26日15:44:29
-- 摘要: 右家手牌
]]-------------------------------------------

local PokerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local DDZConst = require("package_src.games.ddz.data.DDZConst")
local DDZCard = require("package_src.games.ddz.utils.card.DDZCard")

local DDZRightHandCardView = class("DDZRightHandCardView", function ()
    return display.newLayer();
end);


local HAND_LAYER_POSITIONX = -260
local HAND_LAYER_POSITIONY = 130

local CARD_SCALE = 0.4

local CARD_SPACE = 20

--函数功能：    构造函数
--返回值：      无
--widget：      ui
function DDZRightHandCardView:ctor( widget)
    Log.i("--wangzhi--创建右家手牌区--")
    self:setTouchEnabled(false);
    self.m_pWidget = widget
    self:setPosition(HAND_LAYER_POSITIONX,HAND_LAYER_POSITIONY)
    self.m_cards = {}
    self.listeners = {}
    --添加监听事件
    self.nHandler = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)

    self.addCardHandler = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_ADD, handler(self, self.addLordIdCards))
    table.insert(self.listeners, self.addCardHandler)
end

--函数功能：    析构函数
--返回值：      无
function DDZRightHandCardView:dtor()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    ui关闭函数
--返回值：      无
function DDZRightHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
    self.listeners = nil
end

-- 增加地主手牌
function DDZRightHandCardView:addLordIdCards(cards, seat)

    if seat ~= DDZConst.SEAT_RIGHT  then
        return
    end
    Log.i("--wangzhi--DDZRightHandCardView--增加地主手牌--",cards)
        Log.i("--wangzhi--DDZRightHandCardView--",cards)
    for i,v in ipairs(cards) do
        local cardType, cardValue = DDZCard.cardConvert(v);
        local cardView = PokerCardView.new(cardType, cardValue,v);
        cardView:setScale(CARD_SCALE)
        self:addChild(cardView);
        table.insert(self.m_cards,cardView)
    end
    self:sortByValue()
end

function DDZRightHandCardView:dealCard(cards, isReconnect)
    -- 这里只是为了处理战绩回放,重连不处理,避免对局中有重连，导致牌局异常
    if isReconnect then
        return
    end

    local seat = DDZConst.SEAT_RIGHT
    local delCard = {}
    for i,v in ipairs(self.m_cards) do
        table.insert(delCard,self.m_cards[i]:getCard())
    end
    self:onDelCard(delCard,seat)

    Log.i("--wangzhi--DDZRightHandCardView--",cards)
    for i,v in ipairs(cards) do
        local cardType, cardValue = DDZCard.cardConvert(v);
        local cardView = PokerCardView.new(cardType, cardValue,v);
        cardView:setScale(CARD_SCALE)
        self:addChild(cardView);
        table.insert(self.m_cards,cardView)
    end
    self:sortByValue()
end

--函数功能：    根据牌值手牌排序
--返回值：      无
function DDZRightHandCardView:sortByValue()
    
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
function DDZRightHandCardView:updatePoker()
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
function DDZRightHandCardView:resetPosition()

    local CardPositionX = CARD_SPACE*(16-(#self.m_cards-1))/2
    for i,v in ipairs(self.m_cards) do
        CardPositionX = CardPositionX +CARD_SPACE
        self.m_cards[i]:setPositionX(CardPositionX)
        self.m_cards[i]:setLocalZOrder(i);
    end
end


--函数功能：    删除牌
--返回值：      无
--cards：       要删除手牌
--seat：        删除牌的座位
function DDZRightHandCardView:onDelCard(cards, seat)
    if seat ~= DDZConst.SEAT_RIGHT  then
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

return DDZRightHandCardView