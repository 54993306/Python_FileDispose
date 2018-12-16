--[[---------------------------------------- 
-- 作者: 方明扬
-- 日期: 2018-05-07 
-- 摘要: 自己的手牌
]]-------------------------------------------

local PokerCardView = require("package_src.games.pokercommon.widget.PokerCardView")
local DDZDefine = require("package_src.games.ddz.data.DDZDefine")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local DDZGameEvent = require("package_src.games.ddz.data.DDZGameEvent")
local DDZDataConst = require("package_src.games.ddz.data.DDZDataConst")
local DDZSocketCmd = require("package_src.games.ddz.proxy.delegate.DDZSocketCmd")
local DDZConst = require("package_src.games.ddz.data.DDZConst")
local DDZPKCardTypeAnalyzer = require("package_src.games.pokercommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZPKCardTips = require("package_src.games.pokercommon.utils.card.DDZPKCardTips")
local DDZCard = require("package_src.games.ddz.utils.card.DDZCard")

local DDZMyHandCardView = class("DDZMyHandCardView", function ()
    return display.newLayer();
end);

local WIDTH_SCALE  = 0.75
local HEIGHT_SCALE = 1.2

local SELECT_CARD_VAULE_FIVE = 5

local SELECT_COLOR = cc.c3b(158, 198, 228)
local NOAMEL_COLOR = cc.c3b(255, 255, 255)

local BIG_JOKER_VAULE   = 30
local SAMLL_JOKER_VAULE = 29

local JOKER_NUMBER = 2


--函数功能：    构造函数
--返回值：      无
--widget：      ui
function DDZMyHandCardView:ctor( widget)
    self:setTouchEnabled(false);
    self.m_pWidget = widget
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouchCard(event.name, event.x, event.y);
    end);

    self.width = display.width * WIDTH_SCALE
    self.height = DDZCard.HEIGHT;
    self.stopHeight = self.height * HEIGHT_SCALE

    self:setContentSize(cc.size(self.width+100, self.height));
    self.m_cards = {};

    --牌型提示
    self.m_cardTips = DDZPKCardTips.new();
    self.listeners = {}--存储所有的监听   便于在析构函数中移除

    self.sortByNum = false;

    self:reset()

    --添加监听事件
    self.nHandler = HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL, handler(self, self.onDelCard))
    table.insert(self.listeners, self.nHandler)
end


--函数功能：    析构函数
--返回值：      无
function DDZMyHandCardView:dtor()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    ui关闭函数
--返回值：      无
function DDZMyHandCardView:close()
    for _,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

--函数功能：    重置
--返回值：      无
function DDZMyHandCardView:reset()
    self:setIsBiggerCard(true);
    for k, v in pairs(self.m_cards) do
        self:removeChild(v);
        v = nil;
    end
    self.m_cards = {};
    self.m_cardTips:reset();
    -- self.bottom_bg:setVisible(false)
end 

--函数功能：    根据view创建时传入的seat来获取到自己的数据模型
--返回值：      返回玩家数据模型
function DDZMyHandCardView:getMyPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.SITE) == DDZConst.SEAT_MINE then
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
function DDZMyHandCardView:onDelCard(cards, seat)
    if seat ~= DDZConst.SEAT_MINE  then
        return
    end
    local myPlayerModel = DataMgr:getInstance():getMyPlayerModel()
    local dataCards = myPlayerModel:getProp(DDZDefine.HAND_CARDS)

    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType();
    end

    local tableFind = function(tb, value)
        for k,v in pairs(tb) do
            if value == v then
                return true
            end
        end
        return false
    end

    Log.i("dataCards :", dataCards)
    local delcard = {}
    self.m_cards = checktable(self.m_cards)
    for i = 1, #self.m_cards do 
        local uicard = self.m_cards[i]:getCard()
        -- Log.i("uicard : ", uicard)
        if not tableFind( dataCards, uicard ) then
            table.insert(delcard, uicard)
        end
    end
    -- Log.i("DDZMyHandCardView:onDelCard: delcard", delcard)
    self:onOutCard(delcard)
end


--函数功能：    发完牌后显示叫与不叫
--返回值：      无
--cards：       要删除手牌
--isReconnect:  是否重连
function DDZMyHandCardView:dealCard(cards, isReconnect)
    Log.i("DDZMyHandCardView:dealCard cards", cards)
    -- Log.i("DDZMyHandCardView:dealCard isReconnect", isReconnect)
    ----------------------
    self:reset()
    self:stopAllActions()
    ----------------------
    
    local interval = 0.05
    if not cards or #cards == 0 then
        return;
    end
    self:reset();
    if not isReconnect then
        self:setTouchEnabled(false);
        for k, v in ipairs(cards) do
            self:performWithDelay(function()
                self:addCards({v});
                if k == #cards then
                    Log.i("DDZMyHandCardView:dealCard isReconnect deal cards")
                    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONDEALCARDEND)
                    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                end

            end, k * interval, true);
        end
    else
        -- HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONDEALCARDEND)
        -- HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        self:addCards(cards);
    end

    self.m_cardTips:add(self:getCardValues(cards));

    self:setTouchEnabled(true);
end


--函数功能：    加入底牌
--返回值：      无
--cards：       需要添加的牌
function DDZMyHandCardView:addBottomCard(cards)
    self.m_cardTips:add(self:getCardValues(cards));
    self:addCards(cards);
end


--函数功能：    加入到手牌中
--返回值：      无
--cards：       需要添加的牌
function DDZMyHandCardView:addCards(cards)

    if cards == nil or #cards == 0 then
        return;
    end

    local insertCards = {};
    for i, card in ipairs(cards) do
        local isExist = false;
        for ii, v in pairs(self.m_cards) do
            if v:getCard() == card then
                isExist = true;
                break;
            end
        end 
        if not isExist then
            table.insert(insertCards, card);
        end
    end

    for i, card in pairs(insertCards) do
        local cardType, cardValue = DDZCard.cardConvert(card);
        local cardView = PokerCardView.new(cardType, cardValue,card);
        cardView:setScale(DDZCard.SCALE)
        cardView:setTouchEnabled(false);
        local tuoguanState = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
        cardView:setGray(tuoguanState == DDZConst.TUOGUAN_STATE_1)
        self:addChild(cardView);
        table.insert(self.m_cards, cardView);
    end

    self:sortByValue();
end


--函数功能：    从手牌中移除
--返回值：      无
--cards：       要移除的牌
function DDZMyHandCardView:removeCards(cards) 
    for _, card in pairs(cards) do
        for k, v in pairs(self.m_cards) do 
            if card == v:getCard() then
                self:removeChild(v);
                table.remove(self.m_cards, k);
                v = nil;
                break;
            end
        end
    end
    self:updatePoker(true);
end


--函数功能：    根据牌值手牌排序
--返回值：      无
function DDZMyHandCardView:sortByValue()
    
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

        
    for i, v in ipairs(self.m_cards) do
        v:setLocalZOrder(i);
    end
    
    self:updatePoker(true);
end

--函数功能：    根据牌数对手牌排序
--返回值：      无
function DDZMyHandCardView:sortByCount(self)
    local countIndex = {1, 1, 1, 1};
    local count = 0;
    local value = -1;
    local newCardTable = {};
    local nJokers = 0;

    local insertFunc = function(cardTableIndex, count)
        local insertCount = 1;
        local i = 1;
        while insertCount <= count do
            local poker = self.m_cards[cardTableIndex-i];
            table.insert(newCardTable, countIndex[count], poker);
            insertCount = insertCount + 1;

            if insertCount > count then
                break;
            end
            i = i + 1;
        end

        for i = 1,count do
            countIndex[i] = countIndex[i] + count;
        end
    end

    for k, v in ipairs(self.m_cards) do
        
        if v:getValue() ~= BIG_JOKER_VAULE and v:getValue() ~= SAMLL_JOKER_VAULE then
            if v:getValue() == value then
                count = count +1;
            else
                insertFunc(k,count);
                
                value = v:getValue();
                count = 1;
            end
        else
            nJokers = nJokers + 1;
        end
        
    end

    insertFunc(#self.m_cards + 1, count);

    if nJokers == JOKER_NUMBER then
        table.insert(newCardTable, 1, self.m_cards[2]);
        table.insert(newCardTable, 1, self.m_cards[1]);
    elseif nJokers == 1 then
        table.insert(newCardTable, countIndex[2], self.m_cards[1]);
    end

    self.m_cards = newCardTable;
    
    for i, v in ipairs(self.m_cards) do
        v:setLocalZOrder(i);
    end
    
    self:updatePoker(true);
end

--函数功能：    清楚牌的点击状态
--返回值：      无
function DDZMyHandCardView:cleanTouchState()
    self.m_beginTouchIndex = -1;
    self.m_lastTouchIndex = -1;
    self.m_lastTouchX = nil;
    self.m_lastTouchY = nil;
    self.m_stopMoving = false;
end


--函数功能：    清楚牌的点击状态
--返回值card:   点击的牌值
--i:            点击的牌的下标
--x:            触摸的x坐标
--y:            触摸的y坐标
function DDZMyHandCardView:getCardAndIndex(x, y)
    for i = #self.m_cards, 1, -1 do
        local card = self.m_cards[i];
        if self.m_cards[i]:isClick(cc.p(x, y)) then
            return card, i;
        end
    end
    return nil;
end


--函数功能：    清楚牌的点击状态
--返回值:       无
--EventType:    点击类型
--x:            触摸的x坐标
--y:            触摸的y坐标
function DDZMyHandCardView:onTouchCard(EventType, x, y)
    local isSelectCard = false
    -- Log.i("--wangzhi--点击了出牌区域--")
    if y > self.stopHeight then
        self:onTouchEnd();
    end
    
    local card, index = self:getCardAndIndex(x, y);
    -- Log.i("card is ", card)
    -- Log.i("index is ", index)

    -- Log.i("self.m_beginTouchIndex is ", self.m_beginTouchIndex)
    -- Log.i("self.m_lastTouchIndex is ", self.m_lastTouchIndex)
    if EventType == "began" then 
        Log.i("--wangzhi--cleanTouchState--")
        self:cleanTouchState();

        if card then 
            isSelectCard = true
            self.m_beginTouchIndex = index;
            self.m_lastTouchIndex = index;
            self:updateCardsStateInMoveRegion(index);
            self:onTouchChangeStatus()
            kPokerSoundPlayer:playEffect("cardClick");
        else
            self:onChongXuanClick()
        end
        return true;
    elseif EventType == "moved" then
        if card then
            self:updateCardsStateInMoveRegion(index);
            if self.m_lastTouchIndex ~= index then
                self.m_lastTouchX = x;
                self.m_lastTouchY = y;
                kPokerSoundPlayer:playEffect("cardClick");
            end
            self.m_lastTouchIndex = index;
        end
    else 
        Log.i("--wangzhi--点击了出牌区域002--",isSelectCard)
        self:onTouchEnd();
    end

    self:updatePoker(false);
end


--函数功能：    强制停止触摸事件
--返回值:       无
function DDZMyHandCardView:onStopMoving()
    self.m_stopMoving = true;
    self:changeStatus(DDZCard.STATUS_NORMAL_SELECT, DDZCard.STATUS_NORMAL);
    self:changeStatus(DDZCard.STATUS_POP_SELECT, DDZCard.STATUS_POP);
    self:popCards({});
end

--函数功能：    点击结束
--返回值:       无
function DDZMyHandCardView:onTouchChangeStatus()
    Log.i("--wangzhi--进入点击开始改变状态--")
    if self.m_stopMoving then
        return;
    end
    -- local moveTip = false;
    -- if math.abs(self.m_beginTouchIndex - self.m_lastTouchIndex) > 0 then
    --     local popCards = self:getCardsByStatus(DDZCard.STATUS_POP);
    --     local popSelectCards = self:getCardsByStatus(DDZCard.STATUS_POP_SELECT);
    --     Log.i("DDZMyHandCardView:onTouchEnd popCards", popCards)
    --     Log.i("DDZMyHandCardView:onTouchEnd popSelectCards", popSelectCards)
    --     if #popCards == 0 and #popSelectCards == 0 then
    --         moveTip = true;
    --     end
    -- end
    -- self:changeStatus(DDZCard.STATUS_NORMAL_SELECT, DDZCard.STATUS_POP);
    -- self:changeStatus(DDZCard.STATUS_POP_SELECT, DDZCard.STATUS_NORMAL);
    -- self:onHandCardSelect(false, not moveTip);
    self:onHandCardSelect(false);
    -- self:cleanTouchState();

end

--函数功能：    点击结束
--返回值:       无
function DDZMyHandCardView:onTouchEnd()
    Log.i("--wangzhi--进入点击结束--")
    if self.m_stopMoving then
        return;
    end
    local moveTip = false;
    if math.abs(self.m_beginTouchIndex - self.m_lastTouchIndex) > 0 then
        local popCards = self:getCardsByStatus(DDZCard.STATUS_POP);
        local popSelectCards = self:getCardsByStatus(DDZCard.STATUS_POP_SELECT);
        Log.i("DDZMyHandCardView:onTouchEnd popCards", popCards)
        Log.i("DDZMyHandCardView:onTouchEnd popSelectCards", popSelectCards)
        if #popCards == 0 and #popSelectCards == 0 then
            moveTip = true;
        end
    end
    self:changeStatus(DDZCard.STATUS_NORMAL_SELECT, DDZCard.STATUS_POP);
    self:changeStatus(DDZCard.STATUS_POP_SELECT, DDZCard.STATUS_NORMAL);
    self:onHandCardSelect(false, moveTip);
    self:cleanTouchState();

end

--函数功能：    点击手牌后的处理
--返回值:       无
--isChecked:    是否检查牌有效
--moveTip:      是否要提示?
function DDZMyHandCardView:onHandCardSelect(isChecked, moveTip)
    Log.i("DDZMyHandCardView:onHandCardSelect",isChecked, moveTip)
    local seat = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_OPERATESEATID)
    if seat ~= DDZConst.SEAT_MINE then
        return
    end

    local tipCards = nil;
    local info = {};
    info.action = "handCardSelect";
    info.selCardLegal = false;
    local selectedCardValues = self:getSelectedCardValues();
    Log.i("selectedCardValues", selectedCardValues)
    if selectedCardValues and #selectedCardValues > 0 then
        if isChecked then
            info.selCardLegal = true;
        else
            local lastOutCards = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_LASTOUTCARDS)
            local lastOutCardType = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LASTCARDTYPE)
            local lastOutCardValues = self:getCardValues(lastOutCards);
            local lastKeyCard = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LASTKEYCARDS)
            -- Log.i("lastOutCards ", lastOutCards)
            -- Log.i("lastOutCardType ", lastOutCardType)
            -- Log.i("lastOutCardValues ", lastOutCardValues)
            -- Log.i("lastKeyCard", lastKeyCard)
            if moveTip then
                print("******************************************************************************************moveTip")
                if not lastOutCards or #lastOutCards == 0 then --自己出牌
                    if #selectedCardValues > SELECT_CARD_VAULE_FIVE then
                        local cardType, cards = self.m_cardTips:getTipsWithCards(selectedCardValues);
                        Log.i("getTipsWithCards(selectedCardValues)", cardType, cards)
                        tipCards = cards;
                    elseif #selectedCardValues <= SELECT_CARD_VAULE_FIVE and #selectedCardValues > 1 then
                        local cards = self.m_cardTips:getTipsByPart(selectedCardValues);
                        Log.i("getTipsByPart :", cards)
                        if cards and #cards > 0 then
                            tipCards = cards;
                        else
                            local cardType = DDZPKCardTypeAnalyzer.getCardType(selectedCardValues);
                            Log.i("selectedCardValues ", cardType)
                            if cardType > DDZCard.CT_ERROR then
                                tipCards = selectedCardValues;
                            end
                        end
                    elseif #selectedCardValues == 1 then
                        tipCards = self.m_cardTips:getTipsBy1card(lastOutCardValues, selectedCardValues[1]);
                        Log.i("getTipsBy1card", tipCards)
                    end
                else
                    local cardTip = DDZPKCardTips.new(selectedCardValues);
                    Log.i("DDZPKCardTips.new222")
                    tipCards = cardTip:getTipsLoop(lastOutCardValues, nil, lastOutCardType);
                end
                Log.i("tipCards: ", tipCards)
                if tipCards and #tipCards > 0 then
                    info.selCardLegal = true;
                    self:popCards(tipCards);
                end 
                print("******************************************************************************************moveTipEND")
            else
                print("******************************************************************************************notMoveTip")
                local isLegal = DDZPKCardTypeAnalyzer.isLegal(selectedCardValues, lastOutCardValues, lastOutCardType, lastKeyCard);
                if isLegal then
                    info.selCardLegal = true;
                end
            end
        end
    end
    Log.i("===========================select==========================:", info)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_SELECARDLEGAL, info.selCardLegal);

    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
end


--函数功能：    获取选中手牌的值
--返回值:       选中手牌的值
function DDZMyHandCardView:getSelectedCardValues()
    local selectedCardValues = {};
    for k, v in pairs(self.m_cards) do
        if v:getStatus() == DDZCard.STATUS_POP then
            table.insert(selectedCardValues, v:getValue());
        end
    end
    return selectedCardValues;
end


--函数功能：    获取手牌的值
--返回值:       手牌的值
function DDZMyHandCardView:getHandCardValues()
    local cardValues = {};
    for k, v in pairs(self.m_cards) do
        table.insert(cardValues, v:getValue());
    end
    return cardValues;
end

--函数功能：      触摸改变牌的状态
--返回值:         手牌的值
--curTouchIndex ：目前点击的牌的下标
function DDZMyHandCardView:updateCardsStateInMoveRegion(curTouchIndex)
    Log.i("DDZMyHandCardView:updateCardsStateInMoveRegion ", curTouchIndex, self.m_beginTouchIndex, curTouchIndex)
    self:changeStatus(DDZCard.STATUS_NORMAL, DDZCard.STATUS_NORMAL_SELECT, self.m_beginTouchIndex, curTouchIndex);
    self:changeStatus(DDZCard.STATUS_POP, DDZCard.STATUS_POP_SELECT, self.m_beginTouchIndex, curTouchIndex);

    --move direction has changed
    if (self.m_lastTouchIndex - self.m_beginTouchIndex)*(curTouchIndex - self.m_lastTouchIndex) < 0 then 
        local endIndex = curTouchIndex + (self.m_lastTouchIndex < curTouchIndex and -1 or 1);
        self:changeStatus(DDZCard.STATUS_NORMAL_SELECT, DDZCard.STATUS_NORMAL, self.m_lastTouchIndex, endIndex);
        self:changeStatus(DDZCard.STATUS_POP_SELECT, DDZCard.STATUS_POP, self.m_lastTouchIndex, endIndex);
    end
end


--函数功能：      改变牌的状态
--返回值:         无
--srcStatus ：    牌原来的状态
--destStatus:     牌目标状态
--begIndex:       手牌的起始下标
--endIndex:       手牌的终止下标
function DDZMyHandCardView:changeStatus(srcStatus, destStatus, begIndex, endIndex)
    begIndex = begIndex or 1;
    endIndex = endIndex or #self.m_cards;

    for i = begIndex, endIndex, (begIndex < endIndex) and 1 or -1 do
        local card = self.m_cards[i];
        if card and card:getStatus() == srcStatus then
            card:setStatus(destStatus);
        end
    end
end


--函数功能：      更新牌的状态
--返回值:         无
--isUpateAll ：   是否更新所有牌
function DDZMyHandCardView:updatePoker(isUpateAll)
    local isChange = false;
    for _, v in pairs(self.m_cards) do 
        if v:isStatusChanged() or isUpateAll then 
            isChange = true;
            if v:getStatus() == DDZCard.STATUS_NORMAL or v:getStatus() == DDZCard.STATUS_POP then
                v:setColor(NOAMEL_COLOR);
            elseif v:getStatus() == DDZCard.STATUS_NORMAL_SELECT or v:getStatus() == DDZCard.STATUS_POP_SELECT then
                v:setColor(SELECT_COLOR);
            end
        end
    end

    if self.m_cards and #self.m_cards > 0 then
        for i,v in ipairs(self.m_cards) do
            if i == #self.m_cards then
                self.m_cards[#self.m_cards]:showFlowerImg()
            else
                self.m_cards[i]:hideFlowerImg()
            end
        end
        
    end

    local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
    local isStartPlay = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    local isSureLord = DataMgr:getInstance():getsureLordFlag()
    Log.i("--wangzhi--可以确定地主了吗--",isSureLord)
    if lordId == HallAPI.DataAPI:getUserId() and isStartPlay>=3 then
        if self.m_cards and #self.m_cards > 0 then
            Log.i("--wangzhi--增加地主角标")
            self.m_cards[#self.m_cards]:addLordTag()
        end
    end
    if isChange then
        self:resetPosition();
    end
end


--函数功能：      重设牌位置
--返回值:         无
function DDZMyHandCardView:resetPosition()
    local cardNum = #self.m_cards;
    if cardNum > 0 then
        local space = self:getSpace(cardNum);
        local x = self.width/2  - cardNum/2*space - (DDZCard.WIDTH - space)/2 + DDZCard.WIDTH/2;
        for k, v in ipairs(self.m_cards) do 
            if v:getStatus() == DDZCard.STATUS_NORMAL or v:getStatus() == DDZCard.STATUS_NORMAL_SELECT then
                v:setPosition(cc.p(x, DDZCard.HEIGHT/2));
            else
                v:setPosition(cc.p(x, DDZCard.HEIGHT/2 + DDZCard.POPHEIGHT));   
            end
            
            x = x + space;
        end
    end
end


--函数功能：      提起牌
--返回值:         无
--cardValues:     要弹起的牌的牌值
function DDZMyHandCardView:popCards(cardValues)
    -- print(debug.traceback())
    -- Log.i("DDZMyHandCardView:popCards ", cardValues)
    if not cardValues then
        return;
    end

    table.sort(cardValues, function(a, b)
        return a > b;
    end);

    local popCards = self:getCardsByStatus(DDZCard.STATUS_POP);

    for k, v in ipairs(popCards) do
        local value = v:getValue();
        local ret = false;
        for kk, vv in ipairs(cardValues) do 
            if vv == value then
                table.remove(cardValues, kk);
                ret = true;
                break;
            end
        end

        if not ret then
            v:setStatus(DDZCard.STATUS_NORMAL);
        end
    end

    if #cardValues > 0 then
        local cardValuesIndex = 1;
        local lastQualifiedIndex = -1; 
        for i, v in pairs(self.m_cards) do 
            if v:getStatus() ~= DDZCard.STATUS_POP and v:getValue() == cardValues[cardValuesIndex] then 
                v:setStatus(DDZCard.STATUS_POP);
                cardValuesIndex = cardValuesIndex + 1;
            end
        end
    end
    
    self:updatePoker(false);
end 

--函数功能：      返回某种状态的牌函数
--返回值:         同种状态的手牌
--status:         状态
function DDZMyHandCardView:getCardsByStatus(status)
    local ret = {};
    for k, v in ipairs(self.m_cards) do
        if v:getStatus() == status then
            ret[#ret + 1] = v;
        end
    end
    return ret;
end

--函数功能：      返回手牌之间的牌距
--返回值:         牌距
--cardNum:        牌的数量
function DDZMyHandCardView:getSpace(cardNum)
    local space = DDZCard.NORMALSPACE;
    if cardNum > 1 then
        space = (self.width - DDZCard.WIDTH)/(cardNum - 1);
    else
        return 0;
    end
    space = space > DDZCard.MAXSPACE and DDZCard.MAXSPACE or space;

    return space;
end


--函数功能：      检测能不能压过上手牌
--返回值:         无
function DDZMyHandCardView:checkIsBiggerCard()
    Log.i("DDZMyHandCardView:checkIsBiggerCard")
    local isBigger = false
    local tipCards = self:getTipCards();
    if tipCards and #tipCards > 0 then
        isBigger = true
        self:setIsBiggerCard(true);
        self:onHandCardSelect(false);
        --出牌后就剩一张牌,自动出。
        -- if #self.m_cards == 1 then
        --     Log.i("只剩一张牌自动不出")
        --     self.m_cards[1]:setStatus(DDZCard.STATUS_POP);
        --     self:updatePoker(true);
        --     self:onChuClick();
        -- end
    else
        isBigger = false
        self:setIsBiggerCard(false);
        self:onStopMoving();
        --只剩一张自动不出
        if #self.m_cards == 1 and HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
            self:onBuChuClick();
        end
    end
    return isBigger
end


--函数功能：     设置能否压过上手牌UI状态展示
--返回值:        无
--isBigger：     是否有压过的牌
function DDZMyHandCardView:setIsBiggerCard(isBigger)
    Log.i("DDZMyHandCardView:setIsBiggerCard",  isBigger)

    if isBigger then 
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.SHOWNOBIGGER, not isBigger)
        self:setTouchEnabled(true);
    else
        local tuoguanState = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
        if tuoguanState == DDZConst.TUOGUAN_STATE_0 then
             HallAPI.EventAPI:dispatchEvent(DDZGameEvent.SHOWNOBIGGER, not isBigger)
        end
        self:setTouchEnabled(false);
    end
end


--函数功能：     获取提示牌
--返回值:        提示牌    
function DDZMyHandCardView:getTipCards()
    local lastOutCards = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_LASTOUTCARDS)
    local lastOutCardType = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LASTCARDTYPE)
    local lastOutCardValues = self:getCardValues(lastOutCards);
    local lastTipCardValues = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LASTCARDTIPS)
    -- local lastOutCards = DDZGameManager.getInstance():getLastOutCards();
    -- local lastOutCardType = DDZGameManager.getInstance():getLastOutCardType();
    -- local lastOutCardValues = self:getCardValues(lastOutCards);
    -- local lastTipCardValues = DDZGameManager.getInstance():getLastTipCardValues();
    Log.i("------lastOutCardValues", lastOutCardValues);
    Log.i("------lastTipCardValues", lastTipCardValues);
    Log.i("------lastOutCardType", lastOutCardType);
    local tipCards = self.m_cardTips:getTipsLoop(lastOutCardValues, lastTipCardValues, lastOutCardType);
    Log.i("------tipCards", tipCards);
    return tipCards;
end

--函数功能：     不出按钮回调
--返回值:        无    
--notSendMsg：   不发送信息
function DDZMyHandCardView:onBuChuClick(notSendMsg)
    self:popCards({});
    -- DDZGameManager.getInstance():setLastTipCardValues({});
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTIPS, {});
    if notSendMsg then
        return;
    end
    local data = {};
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
    data.fl = 0;
    data.usI = HallAPI.DataAPI:getUserId();
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_OUTCARD, data);
end


--函数功能：     重选
--返回值:        无    
function DDZMyHandCardView:onChongXuanClick()
    self:popCards({});
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTIPS, {});
    -- DDZGameManager.getInstance():setLastTipCardValues({});
end


--函数功能：     提示
--返回值:        无   
function DDZMyHandCardView:onTiShiClick()
    Log.i("DDZMyHandCardView:onTiShiClick ")
    local tuoguanState = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)

    if tuoguanState == DDZConst.TUOGUAN_STATE_1 then
        self:onBuChuClick();
        -- self.m_delegate:onHandCardTishiBuchu();
        local info = {}
        info.action = "tishibuchu";
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
        return;
    end
    
    local tipCards = self:getTipCards();
    if tipCards and #tipCards > 0 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTIPS, clone(tipCards));
        -- DDZGameManager.getInstance():setLastTipCardValues(tipCards);
        self:popCards(tipCards);
        self:onHandCardSelect(true);
    end
end


--函数功能：     出牌
--返回值:        无  
function DDZMyHandCardView:onChuClick()
    local cardViews = self:getCardsByStatus(DDZCard.STATUS_POP);
    local cards = self:getCardsByView(cardViews);
    local data = {};
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
    data.fl = 1;
    data.usI = HallAPI.DataAPI:getUserId();
    data.plC = cards;
    for k, v in pairs(data.plC) do
        data.plC[k] = DDZCard.ConvertToserver(v);
    end
    -- dump(data)
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_OUTCARD, data);
end

--函数功能：     获取某个手牌的牌值
--返回值:        手牌的牌值  
--cardViews：    手牌
function DDZMyHandCardView:getCardsByView(cardViews)
    local cards = {};
    if cardViews and #cardViews > 0 then
        for k, v in pairs(cardViews) do
            local val = v:getCard();
            table.insert(cards, val);
        end
    end
    return cards;
end

--函数功能：     获取牌值
--返回值:        牌值 
--cards：        牌组
function DDZMyHandCardView:getCardValues(cards)
    local cardValues = {};
    if cards and #cards > 0 then
        for k, v in pairs(cards) do
            local type, val = DDZCard.cardConvert(v);
            table.insert(cardValues, val);
        end
    end
    return cardValues;
end


--函数功能：     出牌后
--返回值:        无 
--cards：        牌组
function DDZMyHandCardView:onOutCard(cards)
    self:setIsBiggerCard(true);
    local cardValues = self:getCardValues(cards);
    if not cardValues or #cardValues == 0 then
        self:onBuChuClick(true);
    else
        self.m_cardTips:remove(self:getCardValues(cards));
        self:removeCards(cards);
        self:onBuChuClick(true);
    end
end

--函数功能：     托管改变
--返回值:        无 
function DDZMyHandCardView:onTuoGuanChange()
    Log.i("DDZMyHandCardView:onTuoGuanChange ")
    local tuoguanState = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
    Log.i("tuoguanState", tuoguanState);
    if tuoguanState == DDZConst.TUOGUAN_STATE_1 then
        self:setTouchEnabled(false);
        self:onStopMoving();
    else
        self:setTouchEnabled(true);
    end
end

--函数功能：     游戏结束
--返回值:        无 
function DDZMyHandCardView:onGameOver()
    self:onStopMoving();
    self:setIsBiggerCard(true);
    self:setTouchEnabled(false);
    self.sortByNum = false;
end

--函数功能：     点击排序
--返回值:        无 
function DDZMyHandCardView:onSortClick()
    if self.sortByNum then
        self.sortByNum = false;
        self:sortByValue();
    else
        self.sortByNum = true;
        self:sortByCount();
    end
end

return DDZMyHandCardView