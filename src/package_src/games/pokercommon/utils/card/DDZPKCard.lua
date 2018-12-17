 local DDZPKCard = {}

DDZPKCard.STATUS_NORMAL = 1
DDZPKCard.STATUS_NORMAL_SELECT = 2
DDZPKCard.STATUS_POP    = 3
DDZPKCard.STATUS_POP_SELECT = 4
DDZPKCard.STATUS_DRAWING = 5

DDZPKCard.CT_ERROR                            = 0   --0.错误
DDZPKCard.CT_SINGLE                           = 1   --1.单牌，如：3，4，5
DDZPKCard.CT_DOUBLE                           = 2   --2.对牌，如：33，44，55
DDZPKCard.CT_THREE                            = 3   --3.三条，如：333，444，555
DDZPKCard.CT_ONE_LINE                         = 4   --4.顺子，如：34567，5678910，78910JQKA   (连牌五张以上)
DDZPKCard.CT_DOUBLE_LINE                      = 5   --5.连对，如：33＋44＋55，33＋44＋55＋66...(三对以上)
DDZPKCard.CT_THREE_LINE                       = 6   --6.三连，如：333＋444，333＋444＋555...
DDZPKCard.CT_THREE_LINE_TAKE_ONE              = 7   --7.三带一单，如：333＋4，33344456 
DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE           = 8   --8.三带一双，如：333＋44，777888+5566
DDZPKCard.CT_FOUR_LINE_TAKE_ONE               = 9   --9.四带两单，如：3333＋45，7777＋89
DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE            = 10  --10.四带两双，如：3333＋4455，7777＋8899
DDZPKCard.CT_BOMB                             = 11  --11.炸弹，如3333，4444，5555
DDZPKCard.CT_MISSILE                          = 12  --12.火箭，大小王


--牌型与牌值转换
function DDZPKCard.cardConvert(card) 
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

function DDZPKCard.ConvertToLocal(card) 
    if card == 81 then
        return 92
    elseif card == 82 then
        return 93
    else
        return card - 14
    end

end

function DDZPKCard.ConvertToserver(card) 
     if card == 92 then
        return 81
    elseif card == 93 then
        return 82
    else
        return card + 14
    end
end

return DDZPKCard