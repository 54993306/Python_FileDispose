--
-- 操作结果界面(叫\抢\加倍\出牌\游戏结束后显示牌)
--
local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDOprationResultView = class("GDOprationResultView", GDRoomView)

function GDOprationResultView:initView()
    if self.m_data.seat == GDConst.SEAT_MINE then
        local originMargin_start = self.m_pWidget:getLayoutParameter():getMargin()
        originMargin_start.top = originMargin_start.top + 5 
        self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
    end
    self.img_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_status")
    self.img_status:ignoreContentAdaptWithSize(true)
    self.m_cards = {}
    self.m_scale = GDCard.OPRASCALE
    self.m_outCard_y = 42 * self.m_scale
    local size = self.m_pWidget:getContentSize()
    self.width  = size.width
    self.height = size.height
    --手牌回弹距离
    self.spring_back_dis = 15
    --手牌回弹时间
    self.spring_back_time = 0.2
    --手牌动画时间
    self.outcardDelayTime = 0.05

    if self.m_data.gameType == GDConst.GAME_UP_TYPE.NO_UP_GRADE then
        local originMargin_start = self.m_pWidget:getLayoutParameter():getMargin()
        if self.m_data.seat == GDConst.SEAT_RIGHT
           or self.m_data.seat == GDConst.SEAT_LEFT then
            originMargin_start.top = originMargin_start.top + 60
            self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
            self.m_pWidget:getParent():requestDoLayout()
        elseif self.m_data.seat == GDConst.SEAT_TOP then
            originMargin_start.top = originMargin_start.top + 60
            self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
            self.m_pWidget:getParent():requestDoLayout()
            self.img_status:setPositionX(350)
        end
    end
end

-----------------------------------------------------
-- @desc 玩家打牌
-- @pram info 打牌的信息
-----------------------------------------------------
function GDOprationResultView:onPlayCard(info, isReconnect)
    Log.i("GDOprationResultView:onPlayCard info", info)
    self.m_pWidget:setVisible(true)

    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(GDDefine.SEX)
    local userId = PlayerModel:getProp(GDDefine.USERID)

    if not info.cards then return end
    --fl 0 不出   1 出
    if info.fl == 0 then
        self.img_status:setVisible(true)
        self.img_status:loadTexture("common/status_6.png",ccui.TextureResType.plistType)
        if not isReconnect then
            local random = math.random(1, 3)
            kPokerSoundPlayer:playEffect("op_buchu" .. random .. sex)
        end
    else
        self.img_status:setVisible(false)
        self:showOutCards(info.cards, info.cardType, info.keyCardValue, userId)
        self:playEffect(info.cardType, info.keyCardValue, #info.cards, sex, info.cards)
        
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTSEAT, self.m_data.seat)
    end
end

-----------------------------------------------------
-- @desc 游戏结束其他玩家亮牌
-- @pram info.ca :其他玩家的手牌
--       userId:玩家id
--       sex:玩家性别
-----------------------------------------------------
function GDOprationResultView:onGameOver(info, userId, sex)
    self.m_pWidget:setVisible(true)
    self.img_status:setVisible(false)
    if not info.cards then return end
    self:playEffect(info.cardType, info.keyCardValue, #info.cards, sex, info.cards)
    self:showOutCards(info.cards, info.cardType,nil, info.usI)
end

-----------------------------------------------------
-- @desc 播放玩家牌型的音效
-- @pram cardType :牌的类型
--       keyCardValue:牌的关键值
--       cardLenght:牌的类型
--       sex:出牌的人的性别
-----------------------------------------------------
function GDOprationResultView:playEffect(cardType, keyCardValue, cardLenght, sex, cards)
    -- Log.i("playEffect cardType = ", cardType)
    -- Log.i("playEffect keyCardValue = ", keyCardValue)
    if cardType == enmCardType.EBCT_TYPE_NONE or keyCardValue == 0 then
        return
    end
    if cardType == enmCardType.EBCT_BASETYPE_SINGLE then
        --单张
        kPokerSoundPlayer:playEffect("danzhang_" .. keyCardValue .. sex)
    elseif cardType == enmCardType.EBCT_BASETYPE_PAIR then
        --对子
        for k,v in pairs(cards) do
            local _,value = GDCard.cardConvert(v)
            if value ~= RULESETTING.nLevelCard then
                keyCardValue = value
                break
            end
        end
        kPokerSoundPlayer:playEffect("dui_" .. keyCardValue .. sex)
    elseif cardType == enmCardType.EBCT_BASETYPE_3KIND then
        --三张
        for k,v in pairs(cards) do
            local _,value = GDCard.cardConvert(v)
            if value ~= RULESETTING.nLevelCard then
                keyCardValue = value
                break
            end
        end
        kPokerSoundPlayer:playEffect("sanzhang_" .. keyCardValue .. sex)
    elseif cardType == enmCardType.EBCT_BASETYPE_3AND2 then
        --三带二
        kPokerSoundPlayer:playEffect("ct_sandaier2" .. sex)
    elseif cardType == enmCardType.EBCT_BASETYPE_SISTER then
        --顺子
        kPokerSoundPlayer:playEffect("ct_shunzi" .. sex)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
        --木板
        kPokerSoundPlayer:playEffect("mu_ban")
        kPokerSoundPlayer:playEffect("mu_ban_"..sex)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
        --钢板
        kPokerSoundPlayer:playEffect("gang_ban_"..sex)
        kPokerSoundPlayer:playEffect("gang_ban")
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
        --同花顺
        kPokerSoundPlayer:playEffect("sister_bomb_"..sex)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
        --炸弹
        local random = math.random(1, 2)
        kPokerSoundPlayer:playEffect("ct_zhadan" .. random .. sex)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
        --天王炸
        kPokerSoundPlayer:playEffect("king_" .. sex)
        kPokerSoundPlayer:playEffect("huojian")
    end
end

-----------------------------------------------------
-- @desc 隐藏玩家操作
-- @pram 无 
-----------------------------------------------------
function GDOprationResultView:hideOprationResult()
    self.img_status:setVisible(false)
    for i = 1, #self.m_cards do
        self.m_pWidget:removeChild(self.m_cards[i])
        self.m_cards[i] = nil
    end
end

function GDOprationResultView:hideOprationStatus()
    self.img_status:setVisible(false)
end

---------------------------------------
-- 函数功能：    显示出去的牌
-- 返回值：      无
---------------------------------------
function GDOprationResultView:showOutCards(cards, cardType, keyCardValue,userId)
    -- Log.i("GDOprationResultView:showOutCards ", cards, userId)
    local cardNum = #cards
    local space = self:getSpace(cardNum)
    local x = self.width/2  - (cardNum - 1)/2*space
    if self.m_data.seat == GDConst.SEAT_MINE then
    elseif self.m_data.seat == GDConst.SEAT_RIGHT then
        x = self.width  - (cardNum - 1)*space - GDCard.WIDTH/2 * self.m_scale
    elseif self.m_data.seat == GDConst.SEAT_LEFT then
        x = GDCard.WIDTH/2 * self.m_scale
    elseif self.m_data.seat == GDConst.SEAT_TOP then
        x = self.width  - (cardNum - 1)*space - GDCard.WIDTH/2 * self.m_scale
    end
    local cardViews = {}
    for i, card in pairs(cards) do
        local type, value = GDCard.cardConvert(card)
        local cardView = PokerCardView.new(type, value, card, GDCard.TYPE_OUT)
        cardView:setScale(self.m_scale)
        table.insert(cardViews, cardView)
    end
    cardViews = self:sortCards(cardViews, cardType, keyCardValue)
    if not cardViews then return end
    for k, cardView in pairs(cardViews) do
        self.m_pWidget:addChild(cardView)
        if VideotapeManager.getInstance():isPlayingVideo() and self.m_data.seat == GDConst.SEAT_TOP then
            cardView:setPosition(cc.p(x,self.m_outCard_y-110))
        else
            cardView:setPosition(cc.p(x,self.m_outCard_y))
        end
        table.insert(self.m_cards,cardView)

        if k > 1 then
            cardView:performWithDelay(function()
                if VideotapeManager.getInstance():isPlayingVideo() and self.m_data.seat == GDConst.SEAT_TOP then
                    transition.execute(cardView,cc.MoveTo:create(k*self.outcardDelayTime,cc.p(x + (k-1)*space + self.spring_back_dis,self.m_outCard_y-110)),
                        {onComplete = function() transition.execute(cardView,cc.MoveBy:create(self.spring_back_time,cc.p(-(self.spring_back_dis),0)))end})
                else
                    transition.execute(cardView,cc.MoveTo:create(k*self.outcardDelayTime,cc.p(x + (k-1)*space + self.spring_back_dis,self.m_outCard_y)),
                        {onComplete = function() transition.execute(cardView,cc.MoveBy:create(self.spring_back_time,cc.p(-(self.spring_back_dis),0)))end})
                end
            end, 0.2)
        end
    end
end

--获取 相同牌值的个数
function GDOprationResultView:getCountByValue(cardViews, nCount)
    local tmp_cards = {}
    local index = 1
    for k,v in pairs(cardViews) do
        local value = v:getValue()
        local has = false
        for kk,vv in pairs(tmp_cards) do
            if vv[1]:getValue() == value then
                table.insert(vv, v)
                has = true
                break
            end
        end
        if not has then
            tmp_cards[index] = {}
            table.insert(tmp_cards[index], v)
            index = index + 1
        end
    end
    local back_cards = {}
    local other_cards = {}
    for k,v in pairs(tmp_cards) do
        if #v == nCount then
            table.insert(back_cards, v)
        else
            table.insert(other_cards, v)
        end
    end
    return back_cards, other_cards
end
--去除 万能牌
function GDOprationResultView:removeWan(cardViews)
    local tmp = clone(cardViews)
    local wanTab = {}
    for i=#tmp,1,-1 do
        local value = tmp[i]:getValue()
        local cardType = tmp[i]:getType()
        if value == RULESETTING.nLevelCard and cardType == 2 then
            table.insert(wanTab, tmp[i])
            table.remove(tmp, i)
        end
    end
    return tmp, wanTab
end
---------------------------------------
-- @desc    对手牌进行排序
-- @pram    cardViews 手牌ui
--          cardType 牌型
--          keyCardValue 牌的关键值
-- @return  无
function GDOprationResultView:sortCards(cardViews, cardType, keyCardValue)
    if cardType == enmCardType.EBCT_BASETYPE_SINGLE
        or cardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then---单张/天王炸
        return cardViews
    elseif cardType == enmCardType.EBCT_BASETYPE_PAIR then--对子
        local newCardViews = {}
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        for k,v in pairs(wanTab) do
            table.insert(newCardViews, v)
        end
        for k,v in pairs(removeWanTab) do
            table.insert(newCardViews, v)
        end
        return newCardViews
    elseif cardType == enmCardType.EBCT_BASETYPE_3KIND--三张
            or cardType == enmCardType.EBCT_CUSTOMERTYPE_BOMB--炸弹
            then
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        local oldValue = removeWanTab[1]:getValue()
        for k,v in pairs(wanTab) do
            table.insert(removeWanTab, 1, v)
        end
        return removeWanTab
    elseif cardType == enmCardType.EBCT_BASETYPE_3AND2 then--3带2
        local newCardViews = {}
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        local temp, other_cards = self:getCountByValue(removeWanTab, 3)
        if #temp == 1 then--AAA
            newCardViews = temp[1]
            for k,v in pairs(wanTab) do
                table.insert(newCardViews, v)
            end
            for k,v in pairs(other_cards[1]) do
                table.insert(newCardViews, v)
            end
        else
            local temp2, other_cards2 = self:getCountByValue(removeWanTab, 2)
            if #temp2 == 2 then--AABBX
                table.insert(newCardViews, wanTab[1])
                if temp2[1][1]:getValue() == RULESETTING.nLevelCard then
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                elseif temp2[2][1]:getValue() == RULESETTING.nLevelCard then
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() == 15 and temp2[2][1]:getValue() == 14 then--22aax
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() == 15 and temp2[2][1]:getValue() == 3 then--2233x
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() < temp2[2][1]:getValue() then
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                else
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                    table.insert(newCardViews, temp2[2][1])
                    table.insert(newCardViews, temp2[2][2])
                end
            else--AABXX
                if temp2[1][1]:getValue() == RULESETTING.nLevelCard then--AAXXB
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards2[1][1])
                elseif other_cards2[1][1]:getValue() == RULESETTING.nLevelCard then
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards2[1][1])

                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() == 15 and other_cards2[1][1]:getValue() == 14 then--22axx
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, wanTab[2])

                    table.insert(newCardViews, other_cards2[1][1])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() == 14 and other_cards2[1][1]:getValue() == 15 then--aa2xx
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards2[1][1])
                elseif temp2[1][1]:getValue() == 15 and other_cards2[1][1]:getValue() == 3 then--223xx
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, wanTab[2])

                    table.insert(newCardViews, other_cards2[1][1])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])
                elseif temp2[1][1]:getValue() == 3 and other_cards2[1][1]:getValue() == 15 then--2x33x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, temp2[1][1])
                    table.insert(newCardViews, temp2[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards2[1][1])
                else
                    if temp2[1][1]:getValue() > other_cards2[1][1]:getValue() then
                        table.insert(newCardViews, wanTab[1])
                        for k,v in pairs(temp2[1]) do
                            table.insert(newCardViews, v)
                        end
                        table.insert(newCardViews, wanTab[2])
                        for k,v in pairs(other_cards2[1]) do
                            table.insert(newCardViews, v)
                        end
                    else
                        table.insert(newCardViews, wanTab[1])
                        table.insert(newCardViews, wanTab[2])
                        for k,v in pairs(other_cards2[1]) do
                            table.insert(newCardViews, v)
                        end
                        table.insert(newCardViews, temp2[1][1])
                        table.insert(newCardViews, temp2[1][2])
                    end
                end
            end
        end
        return newCardViews
    elseif cardType == enmCardType.EBCT_BASETYPE_SISTER--顺子
            or cardType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then--同花顺
        local newCardViews = {}
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        local aAndTwoTab = {}
        local otherTab = {}
        for k,v in pairs(removeWanTab) do
            if v:getValue() == 14 or v:getValue() == 15 then
                table.insert(aAndTwoTab, v)
            else
                table.insert(otherTab, v)
            end
        end
        newCardViews[1] = otherTab[1]
        for i=2,#otherTab do
            if otherTab[i-1]:getValue() - otherTab[i]:getValue() == 2 then
                if #wanTab < 1 then break end
                table.insert(newCardViews, wanTab[1])
                table.remove(wanTab, 1)
            elseif otherTab[i-1]:getValue() - otherTab[i]:getValue() == 3 then
                if #wanTab < 2 then break end
                table.insert(newCardViews, wanTab[1])
                table.insert(newCardViews, wanTab[2])
                table.remove(wanTab, 1)
                table.remove(wanTab, 1)
            end
            table.insert(newCardViews, otherTab[i])
        end

        --aAndTwoTab 肯定是a(14)在前, 2(15)在后
        --otherTab 345 34
        --12345 23456
        if otherTab[1]:getValue() <= 6 then
            if #wanTab <= 0 then
                for k,v in pairs(aAndTwoTab) do
                    table.insert(newCardViews, v)
                end
            elseif #wanTab == 1 then
                if #aAndTwoTab == 1 then--aX345 2345X 2X456
                    if aAndTwoTab[1]:getValue() == 14 then--aX345
                        table.insert(newCardViews, wanTab[1])
                        table.insert(newCardViews, aAndTwoTab[1])
                    elseif aAndTwoTab[1]:getValue() == 15 then--2345X 2X456
                        if otherTab[1]:getValue() == 5 then--2345X
                            table.insert(newCardViews, 1, wanTab[1])
                        elseif otherTab[1]:getValue() == 6 then--2X456
                            table.insert(newCardViews, wanTab[1])
                        end
                        table.insert(newCardViews, aAndTwoTab[1])
                    end
                elseif #aAndTwoTab == 2 then--a2 345
                    if otherTab[1]:getValue() == 5 then--a2X45
                        table.insert(newCardViews, wanTab[1])
                        table.insert(newCardViews, aAndTwoTab[2])
                        table.insert(newCardViews, aAndTwoTab[1])
                    elseif otherTab[1]:getValue() == 4 then--a234X
                        table.insert(newCardViews, 1, wanTab[1])
                        table.insert(newCardViews, aAndTwoTab[2])
                        table.insert(newCardViews, aAndTwoTab[1])
                    end
                elseif #aAndTwoTab == 0 then--3456X
                    table.insert(newCardViews, 1, wanTab[1])
                end
            elseif #wanTab == 2 then
                if #aAndTwoTab == 1 then--XX 234XX 2XX56 2X45X
                                        --   AX34X AXX45
                    if aAndTwoTab[1]:getValue() == 14 then--a 2 345 
                        if otherTab[1]:getValue() == 4 then--234XX
                            table.insert(newCardViews, 1, wanTab[1])
                            table.insert(newCardViews, 1, wanTab[2])
                            table.insert(newCardViews, aAndTwoTab[1])
                        elseif otherTab[1]:getValue() == 5 then--2X45X
                            table.insert(newCardViews, 1, wanTab[2])
                            table.insert(newCardViews, wanTab[1])
                            table.insert(newCardViews, aAndTwoTab[1])
                        elseif otherTab[1]:getValue() == 6 then--2XX56
                            table.insert(newCardViews, wanTab[2])
                            table.insert(newCardViews, wanTab[1])
                            table.insert(newCardViews, aAndTwoTab[1])
                        end
                    elseif aAndTwoTab[1]:getValue() == 15 then--AX34X AXX45
                        if otherTab[1]:getValue() == 4 then--AX34X
                            table.insert(newCardViews, 1, wanTab[2])
                            table.insert(newCardViews, wanTab[1])
                            table.insert(newCardViews, aAndTwoTab[1])
                        elseif otherTab[1]:getValue() == 5 then--AXX45
                            table.insert(newCardViews, wanTab[2])
                            table.insert(newCardViews, wanTab[1])
                            table.insert(newCardViews, aAndTwoTab[1])
                        end
                    end
                elseif #aAndTwoTab == 2 then--a2XX5  a23XX a2X4X
                    if otherTab[1]:getValue() == 5 then--a2XX5
                        table.insert(newCardViews, wanTab[2])
                        table.insert(newCardViews, wanTab[1])
                        table.insert(newCardViews, aAndTwoTab[2])
                        table.insert(newCardViews, aAndTwoTab[1])
                    elseif otherTab[1]:getValue() == 4 then--a2X4X
                        table.insert(newCardViews, 1, wanTab[2])
                        table.insert(newCardViews, wanTab[1])
                        table.insert(newCardViews, aAndTwoTab[2])
                        table.insert(newCardViews, aAndTwoTab[1])
                    elseif otherTab[1]:getValue() == 3 then--a23XX
                        table.insert(newCardViews, 1, wanTab[1])
                        table.insert(newCardViews, 1, wanTab[2])
                        table.insert(newCardViews, aAndTwoTab[2])
                        table.insert(newCardViews, aAndTwoTab[1])
                    end
                elseif #aAndTwoTab == 0 then--345XX
                    local oldValue = newCardViews[1]:getValue()
                    table.insert(newCardViews, 1, wanTab[1])
                    table.insert(newCardViews, 1, wanTab[2])
                end
            end
        else
            if newCardViews[1]:getValue() == 13 then--KQJXX
                if next(aAndTwoTab) and aAndTwoTab[1]:getValue() == 14 then--AK
                    table.insert(newCardViews, 1, aAndTwoTab[1])
                    local oldValue = newCardViews[#newCardViews]:getValue()
                    for k,v in pairs(wanTab) do
                        oldValue = oldValue - 1
                        table.insert(newCardViews, v)
                    end
                else--KQJXX
                    local oldValue = newCardViews[#newCardViews]:getValue()
                    if #wanTab > 0 then
                        table.insert(newCardViews, 1, wanTab[1])
                        table.remove(wanTab, 1)
                    end
                    for k,v in pairs(wanTab) do
                        table.insert(newCardViews, v)
                        oldValue = oldValue - 1
                    end
                end
            else
                local oldValue = newCardViews[1]:getValue()
                for k,v in pairs(wanTab) do
                    oldValue = oldValue + 1
                    table.insert(newCardViews, 1, v)
                end
                for k,v in pairs(aAndTwoTab) do
                    table.insert(newCardViews, 1, v)
                end
            end
        end
        return newCardViews
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then--钢板 AAABBB
        local newCardViews = {}
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        local aAndTwoTab = {}
        local otherTab = {}
        for k,v in pairs(removeWanTab) do
            if v:getValue() == 14 or v:getValue() == 15 then
                table.insert(aAndTwoTab, v)--aAndTwoTab 肯定是a(14)在前, 2(15)在后
            else
                table.insert(otherTab, v)
            end
        end
        local temp, other_cards = self:getCountByValue(removeWanTab, 3)
        if #temp == 2 then
            if temp[1][1]:getValue() == 15 and temp[2][1]:getValue() == 3 then--222333
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                table.insert(newCardViews, temp[2][3])
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[1][3])
            else
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[1][3])
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                table.insert(newCardViews, temp[2][3])
            end
        elseif #temp == 1 then--222333
            if temp[1][1]:getValue() == 15 and other_cards[1][1]:getValue() == 3 then--222333
                for k,v in pairs(wanTab) do
                    table.insert(newCardViews, v)
                end
                for k,v in pairs(other_cards) do
                    for kk,vv in pairs(v) do
                        table.insert(newCardViews, vv)
                    end
                end
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[1][3])
            else
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[1][3])
                local insertFront = false
                if other_cards[1][1]:getValue() > temp[1][1]:getValue() then
                    insertFront = true
                end
                if insertFront then
                    for k,v in pairs(other_cards) do
                        for kk,vv in pairs(v) do
                            table.insert(newCardViews, 1, vv)
                        end
                    end
                    for k,v in pairs(wanTab) do
                        table.insert(newCardViews, 1, v)
                    end
                else
                    for k,v in pairs(wanTab) do
                        table.insert(newCardViews, v)
                    end
                    for k,v in pairs(other_cards) do
                        for kk,vv in pairs(v) do
                            table.insert(newCardViews, vv)
                        end
                    end
                end
            end
        elseif #temp == 0 then--22X33X
            if other_cards[1][1]:getValue() == 15 and other_cards[2][1]:getValue() == 3 then
                table.insert(newCardViews, wanTab[1])
                table.insert(newCardViews, other_cards[2][1])
                table.insert(newCardViews, other_cards[2][2])
                table.insert(newCardViews, wanTab[2])
                table.insert(newCardViews, other_cards[1][1])
                table.insert(newCardViews, other_cards[1][2])
            else
                table.insert(newCardViews, wanTab[1])
                table.insert(newCardViews, other_cards[1][1])
                table.insert(newCardViews, other_cards[1][2])
                table.insert(newCardViews, wanTab[2])
                table.insert(newCardViews, other_cards[2][1])
                table.insert(newCardViews, other_cards[2][2])
            end
        end
        return newCardViews
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then--木板 AABBCC
        local newCardViews = {}
        local removeWanTab, wanTab = self:removeWan(cardViews)
        table.sort(removeWanTab, function(a, b)
            return a:getValue()*4+a:getType() > b:getValue()*4+b:getType()
        end)
        local aAndTwoTab = {}
        local otherTab = {}
        for k,v in pairs(removeWanTab) do
            if v:getValue() == 14 or v:getValue() == 15 then
                table.insert(aAndTwoTab, v)
            else
                table.insert(otherTab, v)
            end
        end

        local temp, other_cards = self:getCountByValue(removeWanTab, 2)
        if #temp == 3 then
            if temp[1][1]:getValue() == 14 then-- qqkkaa
                return removeWanTab
            elseif temp[1][1]:getValue() == 15 and temp[2][1]:getValue() == 14 then--aa2233
                table.insert(newCardViews, temp[3][1])
                table.insert(newCardViews, temp[3][2])
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
            elseif temp[1][1]:getValue() == 15 then--223344
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                table.insert(newCardViews, temp[3][1])
                table.insert(newCardViews, temp[3][2])
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
            else
                return removeWanTab
            end
        elseif #temp == 2 then--aa22XX AAXX33 XX2233
            if temp[1][1]:getValue() == 15 and temp[2][1]:getValue() == 14 then--aa22XX
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                for k,v in pairs(other_cards) do
                    for kk, vv in pairs(v) do
                        table.insert(newCardViews, 1, vv)
                    end
                end
                for k,v in pairs(wanTab) do
                    table.insert(newCardViews, 1, v)
                end
            elseif temp[1][1]:getValue() == 14 and temp[2][1]:getValue() == 3 then--AAXX33
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                for k,v in pairs(wanTab) do
                    table.insert(newCardViews, v)
                end
                for k,v in pairs(other_cards) do
                    for kk, vv in pairs(v) do
                        table.insert(newCardViews, vv)
                    end
                end
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
            elseif temp[1][1]:getValue() == 15 and temp[2][1]:getValue() == 3 then--2233XX aX2233
                table.insert(newCardViews, temp[2][1])
                table.insert(newCardViews, temp[2][2])
                table.insert(newCardViews, temp[1][1])
                table.insert(newCardViews, temp[1][2])
                if other_cards and other_cards[1] and other_cards[1][1] and other_cards[1][1]:getValue() == 14 then--aX2233
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])
                else--2233XX 22334x
                    for k,v in pairs(other_cards) do
                        for kk,vv in pairs(v) do
                            table.insert(newCardViews, 1, vv)
                        end
                    end
                    for k,v in pairs(wanTab) do
                        table.insert(newCardViews, 1, v)
                    end
                end
            else
                if temp[1][1]:getValue() - temp[2][1]:getValue() == 1 then
                    if #wanTab == 2 then
                        for k,v in pairs(wanTab) do
                            table.insert(newCardViews, v)
                        end
                        table.insert(newCardViews, temp[1][1])
                        table.insert(newCardViews, temp[1][2])
                        table.insert(newCardViews, temp[2][1])
                        table.insert(newCardViews, temp[2][2])
                    elseif #wanTab == 1 then
                        if other_cards[1][1]:getValue() == 15 and temp[2][1]:getValue() == 3 and temp[1][1]:getValue() == 4 then--33442X
                            table.insert(newCardViews, temp[1][1])
                            table.insert(newCardViews, temp[1][2])
                            table.insert(newCardViews, temp[2][1])
                            table.insert(newCardViews, temp[2][2])
                            for k,v in pairs(wanTab) do
                                table.insert(newCardViews, v)
                            end
                            table.insert(newCardViews, other_cards[1][1])
                        elseif other_cards[1][1]:getValue() > temp[1][1]:getValue() then
                            for k,v in pairs(wanTab) do
                                table.insert(newCardViews, v)
                            end
                            table.insert(newCardViews, other_cards[1][1])
                            table.insert(newCardViews, temp[1][1])
                            table.insert(newCardViews, temp[1][2])
                            table.insert(newCardViews, temp[2][1])
                            table.insert(newCardViews, temp[2][2])
                        else
                            table.insert(newCardViews, temp[1][1])
                            table.insert(newCardViews, temp[1][2])
                            table.insert(newCardViews, temp[2][1])
                            table.insert(newCardViews, temp[2][2])
                            for k,v in pairs(wanTab) do
                                table.insert(newCardViews, v)
                            end
                            table.insert(newCardViews, other_cards[1][1])
                        end
                    end
                elseif temp[1][1]:getValue() - temp[2][1]:getValue() == 2 then--33xx55
                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])
                    for k,v in pairs(wanTab) do
                        table.insert(newCardViews, v)
                    end
                    if #wanTab == 1 then
                        table.insert(newCardViews, other_cards[1][1])
                    end
                    table.insert(newCardViews, temp[2][1])
                    table.insert(newCardViews, temp[2][2])
                end
            end
        elseif #temp == 1 then--aa2x3x ax223x ax2x33
                              --223x4x 2x334x 2x3x44 
                              --334455
            if temp[1][1]:getValue() == 14 then--aa2x3x QXKXAA
                if other_cards[1][1]:getValue() == 15 and other_cards[2][1]:getValue() == 3 then--aa2x3x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[2][1])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[1][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])
                else--QXKXAA
                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])

                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])
                end
            elseif temp[1][1]:getValue() == 15 then--ax223x 223x4x
                if other_cards[1][1]:getValue() == 14 and other_cards[2][1]:getValue() == 3 then--ax223x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[2][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[1][1])
                else--223x4x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])
                    
                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])
                end
            elseif temp[1][1]:getValue() == 3 then--ax2x33 2x334x 334x5x
                if other_cards[1][1]:getValue() == 15 and other_cards[2][1]:getValue() == 14 then--ax2x33
                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])

                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])
                    
                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])
                elseif other_cards[1][1]:getValue() == 15 and other_cards[2][1]:getValue() == 4 then--2x334x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[2][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])
                else--334x5x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])
                    
                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])
                end
            else
                if other_cards[1][1]:getValue() - other_cards[2][1]:getValue() == 1 then
                    for k,v in pairs(other_cards) do
                        for kk,vv in pairs(v) do
                            table.insert(newCardViews, wanTab[1])
                            table.remove(wanTab, 1)
                            table.insert(newCardViews, temp[1][1])
                        end
                    end
                    if other_cards[1][1]:getValue() < temp[1][1]:getValue() then--6x7x88
                        table.insert(newCardViews, 1, temp[1][2])
                        table.insert(newCardViews, 1, temp[1][1])
                    else--667x8x
                        table.insert(newCardViews, temp[1][1])
                        table.insert(newCardViews, temp[1][2])
                    end
                else--6x778x
                    table.insert(newCardViews, wanTab[1])
                    table.insert(newCardViews, other_cards[1][1])

                    table.insert(newCardViews, temp[1][1])
                    table.insert(newCardViews, temp[1][2])

                    table.insert(newCardViews, wanTab[2])
                    table.insert(newCardViews, other_cards[2][1])
                end
            end
        end
        return newCardViews
    end
end
------------------------------------------------------------------
-- @desc 返回牌距
-- @pram cardNum 拍的数量
------------------------------------------------------------------
function GDOprationResultView:getSpace(cardNum)
    return 25
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function GDOprationResultView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    -- Log.i("GDDefine.SITE ",GDDefine.SITE)
    -- Log.i("self.m_data ", self.m_data)
    for k,v in pairs(PlayerModelList) do
        -- Log.i("v:getProp(GDDefine.SITE) ", v:getProp(GDDefine.SITE))
        if v:getProp(GDDefine.SITE) == self.m_data.seat then
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

return GDOprationResultView