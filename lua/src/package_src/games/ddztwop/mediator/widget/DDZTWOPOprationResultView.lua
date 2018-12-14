-------------------------------------------------------------------------
-- Desc:   二人斗地主操作结果显示层UI 继承DDZTWOPRoomView
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPRoomView")
local PorkerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPOprationResultView = class("DDZTWOPOprationResultView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationResultView:initView()
    self.img_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_status")
    self.m_cards = {}
    if self.m_data == DDZTWOPConst.SEAT_MINE then
        self.m_scale = DDZTWOPConst.OUTCARDSACLE
    else
        self.m_scale = DDZTWOPConst.OUTCARDSACLE
    end
    self.m_outCard_y = DDZTWOPCard.HEIGHT/2 * self.m_scale
    local size = self.m_pWidget:getContentSize()
    self.width  = size.width
    self.height = size.height
    --手牌回弹距离
    self.spring_back_dis = 15
    --手牌回弹时间
    self.spring_back_time = 0.2
    --手牌动画时间
    self.outcardDelayTime = 0.05

    --添加监听事件
    self.nHandle=HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_PROP_CHANGE, handler(self, self.onRecvEvent))
    table.insert(self.listeners, self.nHandle)
end

function DDZTWOPOprationResultView:onRecvEvent(prop_id, value, oldvalue, extinfo)
    local PlayerModel = self:getPlayerModel()
    if prop_id == DDZTWOPDefine.DOUBLE and extinfo == self.m_data then
        self:onDouble(value)
    end
end

---------------------------------------
-- 函数功能：   展示叫地主结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:onCallLord(isCall)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)

    self.m_pWidget:setVisible(true)
    self.img_status:setVisible(true)
    if isCall == 1 then  --叫地主
        self.img_status:loadTexture("common/status_1.png", ccui.TextureResType.plistType)
        kPokerSoundPlayer:playEffect("op_jiaodizhu1" .. sex)
    else
        self.img_status:loadTexture("common/status_0.png",ccui.TextureResType.plistType)
        kPokerSoundPlayer:playEffect("op_jiaodizhu0" .. sex)
    end
end

---------------------------------------
-- 函数功能：   展示抢地主结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:onRobLord(isRob)

    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)

    self.m_pWidget:setVisible(true)
    self.img_status:setVisible(true)
    if isRob == 1 then --抢地主
        self.img_status:loadTexture("common/status_3.png",ccui.TextureResType.plistType)
        local random = math.random(1, 2)
        kPokerSoundPlayer:playEffect("op_qiangdizhu" .. random .. sex)
    else
        self.img_status:loadTexture("common/status_2.png",ccui.TextureResType.plistType)
        kPokerSoundPlayer:playEffect("op_qiangdizhu0" .. sex)
    end
end

---------------------------------------
-- 函数功能：   展示打牌结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:onPlayCard(info)
    self.m_pWidget:setVisible(true)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)
    local userId = PlayerModel:getProp(DDZTWOPDefine.USERID)

    if not info.cards then return end
    if info.fl == 0 then
        self.img_status:setVisible(true)
        self.img_status:loadTexture("common/status_6.png",ccui.TextureResType.plistType)
        local random = math.random(1, 3)
        kPokerSoundPlayer:playEffect("op_buchu" .. random .. sex)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    else
        self.img_status:setVisible(false)
        self:showOutCards(info.cards, info.cardType, info.keyCardValue)
        local lastSeat = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LASTOUTSEAT)
        print(debug.traceback("%%%%%%onPlayCard"))
        Log.i("****************onPlayCad info:",info)
        if lastSeat == 0 or lastSeat == self.m_data or info.cardType <= 3 or info.cardType >= 11 then
            self:playEffect(info.cardType, info.keyCardValue, #info.cards, sex)
        else
            local random = math.random(1, 3)
            kPokerSoundPlayer:playEffect("op_chu" .. random .. sex)
        end
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTOUTSEAT, self.m_data)
    end
end

---------------------------------------
-- 函数功能：   游戏结束结果处理函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:onGameOver(info, userId, sex)
    self.m_pWidget:setVisible(true)
    self.img_status:setVisible(false)
    --if self.m_data ~= DDZTWOPConst.SEAT_MINE then
        if info.ca and #info.ca > 0 then
            self:showOutCards(info.ca, -1,nil,userId)
        end
    --end
end

---------------------------------------
-- 函数功能：  根据牌型播放音效函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationResultView:playEffect(cardType, keyCardValue, cardLenght, sex)
    if cardType == DDZTWOPCard.CT_SINGLE then
        kPokerSoundPlayer:playEffect("danzhang_" .. keyCardValue .. sex)
    elseif cardType == DDZTWOPCard.CT_DOUBLE then
        kPokerSoundPlayer:playEffect("dui_" .. keyCardValue .. sex)
    elseif cardType == DDZTWOPCard.CT_THREE then
        kPokerSoundPlayer:playEffect("sanzhang_" .. keyCardValue .. sex)
    elseif cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_ONE then
        if cardLenght == 4 then
            kPokerSoundPlayer:playEffect("ct_sandaiyi" .. sex)
        else
            kPokerSoundPlayer:playEffect("ct_feiji1" .. sex)
        end
    elseif cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE then
        if cardLenght == 5 then
            kPokerSoundPlayer:playEffect("ct_sandaiyi" .. sex)
        else
            kPokerSoundPlayer:playEffect("ct_feiji1" .. sex)
        end  
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE then
        kPokerSoundPlayer:playEffect("ct_sidaier" .. sex)
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE then
        kPokerSoundPlayer:playEffect("ct_sidaier" .. sex)
    elseif cardType == DDZTWOPCard.CT_ONE_LINE then
        kPokerSoundPlayer:playEffect("ct_shunzi" .. sex)
    elseif cardType == DDZTWOPCard.CT_DOUBLE_LINE then
        kPokerSoundPlayer:playEffect("ct_liandui" .. sex)
    elseif cardType == DDZTWOPCard.CT_THREE_LINE then
       kPokerSoundPlayer:playEffect("ct_feiji" .. sex)
    elseif cardType == DDZTWOPCard.CT_BOMB then
        local random = math.random(1, 2)
        kPokerSoundPlayer:playEffect("ct_zhadan" .. random .. sex)
    elseif cardType == DDZTWOPCard.CT_MISSILE then
        local random = math.random(1, 3)
        kPokerSoundPlayer:playEffect("ct_huojian" .. random .. sex)      
    end
end

---------------------------------------
-- 函数功能：   隐藏操作结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:hideOprationResult()
    self.img_status:setVisible(false)
    for i = 1, #self.m_cards do
        self.m_pWidget:removeChild(self.m_cards[i])
        self.m_cards[i] = nil
    end
end

---------------------------------------
-- 函数功能：   展示打出手牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:showOutCards(cards, cardType, keyCardValue)
    if self.m_data == DDZTWOPConst.SEAT_MINE then
        self:showSelfOutCard(cards, cardType, keyCardValue)
    elseif self.m_data == DDZTWOPConst.SEAT_RIGHT then
        self:showRightOutCard(cards, cardType, keyCardValue)
    end
    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
end

---------------------------------------
-- 函数功能：    对手牌进行排序
-- 返回值：      无
---------------------------------------
function DDZTWOPOprationResultView:sortCards(cardViews, cardType, keyCardValue)
    local cardLenght = #cardViews
    
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType()
    end

    for i = 2, cardLenght do 
        local card = cardViews[i]

        local index = 1
        for j = i - 1, 1, -1 do
            if getCardValue(card) > getCardValue(cardViews[j]) then
                cardViews[j + 1] = cardViews[j]
            else
                index = j + 1
                break
            end
        end

        cardViews[index] = card
    end


    --DDZTWOPCard.CT_THREE_LINE_TAKE_ONE              = 7   --7.三带一单，如：333＋4，33344456 
    --DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE           = 8   --8.三带一双，如：333＋44，777888+5566
    --DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE               = 9   --9.四带两单，如：3333＋45，7777＋89
    --DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE            = 10  --10.四带两双，如：3333＋4455，7777＋8899
    if cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_ONE then
        local newCardViews = {}
        local num = cardLenght/4
        local index = cardLenght
        for i = cardLenght, 1, -1 do
            if cardViews[i]:getValue() == keyCardValue then
                index = i
                break
            end 
        end
        if index > cardLenght - num then
            for i = index, index - num * 3 + 1, -1 do
                table.insert(newCardViews, cardViews[i])
            end
            for i = 1, index - num * 3 do
                table.insert(newCardViews, cardViews[i])
            end
            for i = index + 1, cardLenght do
                table.insert(newCardViews, cardViews[i])
            end
            cardViews = newCardViews
        end
    elseif cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE then
        local newCardViews = {}
        local num = cardLenght/5
        local index = cardLenght
        for i = cardLenght, 1, -1 do
            if cardViews[i]:getValue() == keyCardValue then
                index = i
                break
            end 
        end
        if index > cardLenght - num * 2 then
            for i = index, index - num*3 + 1, -1 do
                table.insert(newCardViews, cardViews[i])
            end
            for i = 1, index - num*3 do
                table.insert(newCardViews, cardViews[i])
            end
            for i = index + 1, cardLenght do
                table.insert(newCardViews, cardViews[i])
            end
            cardViews = newCardViews
        end
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE then
        if cardViews[1]:getValue() ~= keyCardValue then
            cardViews[1], cardViews[5] = cardViews[5], cardViews[1]
            if cardViews[2]:getValue() ~= keyCardValue then
                cardViews[2], cardViews[6] = cardViews[6], cardViews[2]
            end
        end
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE then
        if cardViews[1]:getValue() ~= keyCardValue then
            cardViews[1], cardViews[5] = cardViews[5], cardViews[1]
            cardViews[2], cardViews[6] = cardViews[6], cardViews[2]
            if cardViews[3]:getValue() ~= keyCardValue then
                cardViews[3], cardViews[7] = cardViews[7], cardViews[3]
                cardViews[4], cardViews[8] = cardViews[8], cardViews[4]
            end
        end
    end

    return cardViews
end

---------------------------------------
-- 函数功能：   展示自己打出的手牌函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationResultView:showSelfOutCard(cards, cardType, keyCardValue)
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    local cardNum = #cards
    local space = self:getSpace(cardNum)
    local x = self.width/2  - (cardNum - 1)/2*space
    local cardViews = {}
    for i, card in pairs(cards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setScale(self.m_scale)
        if i == #cards and isMeLord then
            cardView:addLordTag()
        else
            cardView:hideLordTag()
        end
        table.insert(cardViews, cardView)
    end
    cardViews = self:sortCards(cardViews, cardType, keyCardValue)
    for k, cardView in pairs(cardViews) do
        self.m_pWidget:addChild(cardView)
        cardView:setPosition(cc.p(x,self.m_outCard_y))
        table.insert(self.m_cards,cardView)
        if k == #cardViews then
            cardView:showFlowerImg()
        else
            cardView:hideFlowerImg()
        end

        if k > 1 then
            cardView:performWithDelay(function()
                transition.execute(cardView,cc.MoveTo:create(k*self.outcardDelayTime,cc.p(x + (k-1)*space + self.spring_back_dis,self.m_outCard_y)),{onComplete = function()
                    transition.execute(cardView,cc.MoveBy:create(self.spring_back_time,cc.p(-(self.spring_back_dis),0)))
                end})
            end, 0.2)
        end
    end
end

---------------------------------------
-- 函数功能：   展示对手打出的手牌函数
-- 返回值：     无
---------------------------------------
function DDZTWOPOprationResultView:showRightOutCard(cards, cardType, keyCardValue)
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    local cardNum = #cards
    local space = self:getSpace(cardNum)
    local x = self.width/2  - (cardNum - 1)/2*space--self.width  - (cardNum - 1)*space - DDZTWOPCard.WIDTH/2 * self.m_scale
    local cardViews = {}
    for i, card in pairs(cards) do
        local type, value = DDZTWOPCard.cardConvert(card)
        local cardView = PorkerCardView.new(type, value, card)
        cardView:setScale(self.m_scale)
        if i == #cards and not isMeLord then
            cardView:addLordTag()
        else
            cardView:hideLordTag()
        end
        table.insert(cardViews, cardView)
    end
    cardViews = self:sortCards(cardViews, cardType, keyCardValue)
    for k, cardView in pairs(cardViews) do
        self.m_pWidget:addChild(cardView)
        cardView:setPosition(cc.p(x,self.m_outCard_y))
        table.insert(self.m_cards,cardView)

        if k == #cardViews then
            cardView:showFlowerImg()
        else
            cardView:hideFlowerImg()
        end

        if k > 1 then
            cardView:performWithDelay(function()
                transition.execute(cardView,cc.MoveTo:create(k*self.outcardDelayTime,cc.p(x + (k-1)*space + self.spring_back_dis,self.m_outCard_y)),{onComplete = function()
                    transition.execute(cardView,cc.MoveBy:create(self.spring_back_time,cc.p(-(self.spring_back_dis),0)))
                end})
            end, 0.2)
        end
    end
end

---------------------------------------
-- 函数功能：   返回牌距
-- 返回值：     牌距
---------------------------------------
function DDZTWOPOprationResultView:getSpace(cardNum)
    local space = DDZTWOPCard.NORMALSPACE * self.m_scale
    if cardNum > 1 then
        space = (self.width - DDZTWOPCard.WIDTH * self.m_scale)/(cardNum - 1)
    else
        return 0
    end
    space = space > DDZTWOPCard.MAXSPACE * self.m_scale and DDZTWOPCard.MAXSPACE * self.m_scale or space

    return space
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZTWOPOprationResultView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZTWOPDefine.SITE) == self.m_data then
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

return DDZTWOPOprationResultView