 local GDPKCard = {}

GDPKCard.STATUS_NORMAL = 1
GDPKCard.STATUS_SELECT = 2
GDPKCard.STATUS_NORMAL_GRAY = 3            --灰色牌
-- GDPKCard.STATUS_NORMAL_SELECT = 2
-- GDPKCard.STATUS_POP    = 3
-- GDPKCard.STATUS_POP_SELECT = 4
-- GDPKCard.STATUS_DRAWING = 5
-- GDPKCard.STATUS_NORMAL_GRAY = 6            --灰色牌

GDPKCard.TYPE_HAND = 0            --手上的牌
GDPKCard.TYPE_OUT = 1            --打出的牌

--牌型与牌值转换
function GDPKCard.cardConvert(card) 
    local cardType = nil --牌型
    local cardValue = nil--牌值
    if card == 92 then
        cardType = 5
        cardValue = 29
    elseif card == 93 then
        cardType = 5
        cardValue = 30
    else
        cardType = bit.brshift(card, 4) --牌型
        cardValue = bit.band(card, 0x0F)--牌值
    end

    if card == -1 then
        return 0,0
    end
    return cardType, cardValue
end

function GDPKCard.ConvertToLocal(card) 
    if card == 81 then
        return 92
    elseif card == 82 then
        return 93
    else
        return card - 14
    end

end

function GDPKCard.ConvertToserver(card) 
     if card == 92 then
        return 81
    elseif card == 93 then
        return 82
    else
        return card + 14
    end
end

return GDPKCard