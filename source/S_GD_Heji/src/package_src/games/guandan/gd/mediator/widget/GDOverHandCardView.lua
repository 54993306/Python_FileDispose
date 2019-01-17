
local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")

local GDOverHandCardView = class("GDOverHandCardView", function ()
    return display.newLayer()
end)

local CARD_SPACE = 38 - 10

function GDOverHandCardView:ctor(widget, posX, posY, seat)
    self:setTouchEnabled(false)
    self.m_pWidget = widget
    self.posY = posY
    self:setPosition(posX, posY)
    self.m_cards = {}
    self.seat = seat
end

function GDOverHandCardView:dealCard(cards)
    for i,v in ipairs(cards) do
        local cardType, cardValue = GDCard.cardConvert(v)
        local cardView = PokerCardView.new(cardType, cardValue, v, GDCard.TYPE_OUT)
        self:addChild(cardView)
        table.insert(self.m_cards,cardView)
    end
    self:sortByValue()
end

--函数功能：    根据牌值手牌排序
--返回值：      无
function GDOverHandCardView:sortByValue()
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
    self:updatePoker()
end

--函数功能：      更新牌的状态
--返回值:         无
--isUpateAll ：   是否更新所有牌
function GDOverHandCardView:updatePoker()
    if self.m_cards and #self.m_cards > 0 then
        for i,v in ipairs(self.m_cards) do
            if i == #self.m_cards then
                self.m_cards[#self.m_cards]:showFlowerImg()
            else
                self.m_cards[i]:hideFlowerImg()
            end
        end
    end
    self:resetPosition()
end

--函数功能：      重设牌位置
--返回值:         无
function GDOverHandCardView:resetPosition()
    local CardPositionX = -100
    for i,v in ipairs(self.m_cards) do
        CardPositionX = CardPositionX +CARD_SPACE
        self.m_cards[i]:setPositionX(CardPositionX)
        if i%9 == 0 then
            CardPositionX = -100
        end
        if self.seat == GDConst.SEAT_TOP then
            self.m_cards[i]:setPositionY(self.posY-math.ceil(i/9)*100)
        else
            self.m_cards[i]:setPositionY(self.posY-math.ceil(i/9)*100)
        end
            self.m_cards[i]:setPositionY(self.posY-math.ceil(i/9)*(80-20))
        self.m_cards[i]:setLocalZOrder(i)
    end
end

return GDOverHandCardView