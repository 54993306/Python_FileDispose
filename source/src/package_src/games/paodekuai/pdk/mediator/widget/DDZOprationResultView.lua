--
-- 三人斗地主操作结果界面(叫\抢\加倍\出牌\游戏结束后显示牌)
--
local PokerCardView = require("package_src.games.paodekuai.pdkcommon.widget.PokerCardView")
local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local PokerUtils =require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local DDZCard = require("package_src.games.paodekuai.pdk.utils.card.DDZCard")
local DDZPKCardTypeAnalyzer = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZOprationResultView = class("DDZOprationResultView", DDZRoomView);



function DDZOprationResultView:initView()
    self.img_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_status");
    self.img_status:ignoreContentAdaptWithSize(true)
    self.m_cards = {};
    if self.m_data == DDZConst.SEAT_MINE then
        self.m_scale = DDZCard.OPRASCALE;
    else
        self.m_scale = DDZCard.OPRASCALE;
    end
    self.m_outCard_y = DDZCard.HEIGHT/2 * self.m_scale;
    local size = self.m_pWidget:getContentSize();
    self.width  = size.width;
    self.height = size.height;
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

-----------------------------------------------------
-- @desc 收到监听事件 监听玩家属性改变
-- @pram: prop_id 属性id  
--        value:新的值
--        oldvalue:旧的值
--        extinfo:其他信息 一般是seat用来区分那个人来接受这个事件
-----------------------------------------------------
function DDZOprationResultView:onRecvEvent(prop_id, value, oldvalue, extinfo)
    -- Log.i("prop_id ", prop_id)
    -- Log.i("value ", value)
    local PlayerModel = self:getPlayerModel()
    if prop_id == DDZDefine.DOUBLE and extinfo == self.m_data then
        self:onDouble(value)
    end
end

--函数功能：   刷新叫地主，抢地主提示
--返回值：     无
--visible_tag：加倍tag值
function DDZOprationResultView:updateCallTips(visible_tag)
    if visible_tag  == 0 then return end

    self.m_pWidget:setVisible(true);
    self.img_status:setVisible(true);
    ---1,2,3,4:不叫，叫，不抢，抢
    if visible_tag  == 1 then
        self.img_status:loadTexture("common/status_0.png", ccui.TextureResType.plistType);
    elseif visible_tag  == 2 then
        self.img_status:loadTexture("common/status_1.png", ccui.TextureResType.plistType);
    elseif visible_tag  == 3 then
        self.img_status:loadTexture("common/status_2.png", ccui.TextureResType.plistType);
    elseif visible_tag  == 4 then
        self.img_status:loadTexture("common/status_3.png", ccui.TextureResType.plistType);
    else
        self.m_pWidget:setVisible(false);
        self.img_status:setVisible(false);
    end
end

--函数功能：   刷新加倍提示
--返回值：     无
--visible_tag：加倍tag值
function  DDZOprationResultView:updateDoubleTips(visible_tag)
    if visible_tag  == 0 then return end
    self.m_pWidget:setVisible(true);
    self.img_status:setVisible(true);

    ---5，6 表示：不加倍，加倍
    if visible_tag == 5 then
        self.img_status:loadTexture("common/status_4.png", ccui.TextureResType.plistType);
    elseif visible_tag == 6 then
        self.img_status:loadTexture("common/status_5.png", ccui.TextureResType.plistType);
    else
        self.m_pWidget:setVisible(false);
        self.img_status:setVisible(false);
    end
end

-----------------------------------------------------
-- @desc 叫地主
-- @pram isCall:是否叫地主
-----------------------------------------------------
function DDZOprationResultView:onCallLord(isCall)
    Log.i("DDZOprationResultView:onCallLord", isCall)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)

    self.m_pWidget:setVisible(true);
    self.img_status:setVisible(true);
    if isCall == 1 then  --叫地主
        self.img_status:loadTexture("common/status_1.png", ccui.TextureResType.plistType);
        kPokerSoundPlayer:playEffect("op_jiaodizhu1" .. sex);
        kPokerSoundPlayer:playEffect("jiaodizhu");
    else
        self.img_status:loadTexture("common/status_0.png",ccui.TextureResType.plistType);
        kPokerSoundPlayer:playEffect("op_jiaodizhu0" .. sex);
    end
end

-----------------------------------------------------
-- @desc 抢地主
-- @pram isRob:是否抢地主
-----------------------------------------------------
function DDZOprationResultView:onRobLord(isRob)
    Log.i("DDZOprationResultView:onRobLord",isRob)

    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)

    self.m_pWidget:setVisible(true);
    self.img_status:setVisible(true);
    if isRob == 1 then --抢地主
        self.img_status:loadTexture("common/status_3.png",ccui.TextureResType.plistType);
        local random = math.random(1, 2);
        kPokerSoundPlayer:playEffect("op_qiangdizhu" .. random .. sex);
    else
        self.img_status:loadTexture("common/status_2.png",ccui.TextureResType.plistType);
        kPokerSoundPlayer:playEffect("op_qiangdizhu0" .. sex);
    end
end

--开局前抢地主音效
function DDZOprationResultView:onEndRobLord( isRob )
    Log.i("--wangzhi--DDZOprationResultView:onEndRobLord--",isRob)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)

     if isRob == 1 then --抢地主
        local random = math.random(1, 2);
        kPokerSoundPlayer:playEffect("op_qiangdizhu" .. random .. sex);
    elseif isRob == 0 then
        kPokerSoundPlayer:playEffect("op_qiangdizhu0" .. sex);
    else
        
    end   
end

-----------------------------------------------------
-- @desc 加倍
-- @pram multi:加倍的倍数
-----------------------------------------------------
function DDZOprationResultView:onDouble(multi)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)

    self.m_pWidget:setVisible(false);
    self.img_status:setVisible(false);

    if multi > 1 then
        self.img_status:loadTexture("common/status_5.png",ccui.TextureResType.plistType);
        --kPokerSoundPlayer:playEffect("op_jiabei1" .. sex);
    else
        self.img_status:loadTexture("common/status_4.png",ccui.TextureResType.plistType);
        --kPokerSoundPlayer:playEffect("op_jiabei0" .. sex);
    end
end

-----------------------------------------------------
-- @desc 玩家打牌
-- @pram info 打牌的信息
-----------------------------------------------------
function DDZOprationResultView:onPlayCard(info)
    self.m_pWidget:setVisible(true);

    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)
    local userId = PlayerModel:getProp(DDZDefine.USERID)

    Log.i("DDZOprationResultView:onPlayCard info", info)
    Log.i("DDZOprationResultView:onPlayCard userId", userId)
    Log.i("DDZOprationResultView:onPlayCard sex", sex)
    if not info.cards then return end
    if info.fl == 0 then
        self.img_status:setVisible(true);
        self.img_status:loadTexture("common/status_6.png",ccui.TextureResType.plistType);
        local random = math.random(1, 3);
        kPokerSoundPlayer:playEffect("op_buchu" .. random .. sex);
    else
        self.img_status:setVisible(false);
        self:showOutCards(info.cards, info.cardType, info.keyCardValue, userId);
        local lastSeat = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LASTOUTSEAT)
        if lastSeat == 0 or lastSeat == self.m_data or info.cardType <= 3 or info.cardType >= 11 then
            self:playEffect(info.cardType, info.keyCardValue, #info.cards, sex);
        else
            local random = math.random(1, 3)
            kPokerSoundPlayer:playEffect("op_chu" .. random .. sex);
        end
        
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTOUTSEAT, self.m_data);
    end
end

-----------------------------------------------------
-- @desc 游戏结束其他玩家亮牌
-- @pram info.ca :其他玩家的手牌
--       userId:玩家id
--       sex:玩家性别
-----------------------------------------------------
function DDZOprationResultView:onGameOver(info, userId, sex)
    self.m_pWidget:setVisible(true);
    self.img_status:setVisible(false);
    if self.m_data ~= DDZConst.SEAT_MINE then
        if info.ca and #info.ca > 0 then
            self:showOutCards(info.ca, -1,nil,userId);
        end
    end
end

-----------------------------------------------------
-- @desc 播放玩家牌型的音效
-- @pram cardType :牌的类型
--       keyCardValue:牌的关键值
--       cardLenght:牌的类型
--       sex:出牌的人的性别
-----------------------------------------------------
function DDZOprationResultView:playEffect(cardType, keyCardValue, cardLenght, sex)
    Log.i("playEffect cardType = ", cardType);
    Log.i("playEffect keyCardValue = ", keyCardValue);
    if cardType == DDZCard.CT_ERROR or keyCardValue == 0 then
        return
    end
    if cardType == DDZCard.CT_SINGLE then
        kPokerSoundPlayer:playEffect("danzhang_" .. keyCardValue .. sex);
    elseif cardType == DDZCard.CT_DOUBLE then
        kPokerSoundPlayer:playEffect("dui_" .. keyCardValue .. sex);
    elseif cardType == DDZCard.CT_THREE then
        kPokerSoundPlayer:playEffect("sanzhang_" .. keyCardValue .. sex);
    elseif cardType == DDZCard.CT_THREE_LINE_TAKE_ONE
        or  ((cardType == DDZCard.CT_THREE_LINE_TAKE_X or cardType == DDZCard.CT_THREE_TAKE_X) and DDZGUIZE.stRule3kinds == 1)  then
        if cardLenght <= 4 then
            kPokerSoundPlayer:playEffect("ct_sandaiyi" .. sex);
        else
            kPokerSoundPlayer:playEffect("ct_feiji1" .. sex);
        end
    elseif cardType == DDZCard.CT_THREE_LINE_TAKE_DOUBLE
        or cardType == DDZCard.CT_THREE_TAKE_DOUBLE
        or  ((cardType == DDZCard.CT_THREE_LINE_TAKE_X or cardType == DDZCard.CT_THREE_TAKE_X) and DDZGUIZE.stRule3kinds == 2) then
        if cardLenght <= 5 then
            -- local random = math.random(1, 2);
            -- Log.i("------random", random)
            -- kPokerSoundPlayer:playEffect("ct_sandaier" .. random .. sex);
            kPokerSoundPlayer:playEffect("ct_sandaier2" .. sex);
        else
            kPokerSoundPlayer:playEffect("ct_feiji1" .. sex);
        end  
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_ONE then
        kPokerSoundPlayer:playEffect("ct_sidaier" .. sex);
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_DOUBLE then
        kPokerSoundPlayer:playEffect("ct_sidaier" .. sex);
    elseif cardType == DDZCard.CT_ONE_LINE then
        kPokerSoundPlayer:playEffect("ct_shunzi" .. sex);
    elseif cardType == DDZCard.CT_DOUBLE_LINE then
        kPokerSoundPlayer:playEffect("ct_liandui" .. sex);
    elseif cardType == DDZCard.CT_THREE_LINE then
        kPokerSoundPlayer:playEffect("ct_feiji" .. sex);
    elseif cardType == DDZCard.CT_BOMB then
        local random = math.random(1, 2);
        kPokerSoundPlayer:playEffect("ct_zhadan" .. random .. sex);
    elseif cardType == DDZCard.CT_MISSILE then
        local random = math.random(1, 3);
        kPokerSoundPlayer:playEffect("ct_huojian" .. random .. sex);      
    end
end

-----------------------------------------------------
-- @desc 隐藏玩家操作
-- @pram 无 
-----------------------------------------------------
function DDZOprationResultView:hideOprationResult()
   -- Log.i("hideOprationResult seat = ", self.m_data);
    --self.m_pWidget:setVisible(false);
    self.img_status:setVisible(false);
    for i = 1, #self.m_cards do
        self.m_pWidget:removeChild(self.m_cards[i]);
        self.m_cards[i] = nil;
    end
end

---------------------------------------
-- 函数功能：    显示出去的牌
-- 返回值：      无
---------------------------------------
function DDZOprationResultView:showOutCards(cards, cardType, keyCardValue,userId)
    Log.i("DDZOprationResultView:showOutCards userId",userId)
    if self.m_data == DDZConst.SEAT_MINE then
        self:showSelfOutCard(cards, cardType, keyCardValue,userId);
    elseif self.m_data == DDZConst.SEAT_RIGHT then
        self:showRightOutCard(cards, cardType, keyCardValue,userId)
    elseif self.m_data == DDZConst.SEAT_LEFT then
        self:showLeftOutCard(cards, cardType, keyCardValue,userId)
    end
end

---------------------------------------
-- @desc    对手牌进行排序
-- @pram    cardViews 手牌ui
--          cardType 牌型
--          keyCardValue 牌的关键值
-- @return  无
---------------------------------------
function DDZOprationResultView:sortCards(cardViews, cardType, keyCardValue)
    --Log.i("cardViews, cardType, keyCardValue", cardViews, cardType, keyCardValue)
    local cardLenght = #cardViews;
    
    local getCardValue = function(card)
        return card:getValue() * 4 + card:getType();
    end

    for i = 2, cardLenght do 
        local card = cardViews[i];

        local index = 1;
        for j = i - 1, 1, -1 do
            if getCardValue(card) > getCardValue(cardViews[j]) then
                cardViews[j + 1] = cardViews[j];
            else
                index = j + 1;
                break;
            end
        end

        cardViews[index] = card;
    end


    --Log.i("========出牌====cardType========",cardType)
    --DDZCard.CT_THREE_LINE                     = 6    --6.三连，如：333＋444，333＋444＋555...
    --DDZCard.CT_THREE_LINE_TAKE_ONE              = 7;   --7.三带一单，如：333＋4，33344456 
    --DDZCard.CT_THREE_LINE_TAKE_DOUBLE           = 8;   --8.三带一双，如：333＋44，777888+5566
    --DDZCard.CT_FOUR_LINE_TAKE_ONE               = 9;   --9.四带两单，如：3333＋45，7777＋89
    --DDZCard.CT_FOUR_LINE_TAKE_DOUBLE            = 10;  --10.四带两双，如：3333＋4455，7777＋8899or (cardType == DDZCard.CT_THREE_LINE)
    --为了显示的时候能够全部拆开，这里将类型换成飞机 DDZCard.CT_THREE_LINE,尽量减少改动,所以不是3连的不进行替换
    if (cardType == DDZCard.CT_THREE_LINE_TAKE_ONE and cardLenght>=8) or (cardType == DDZCard.CT_THREE_LINE_TAKE_DOUBLE and cardLenght>=10)then
        cardType = DDZCard.CT_THREE_LINE
    end
    if cardType == DDZCard.CT_THREE_LINE_TAKE_ONE then
        local newCardViews = {};
        local num = cardLenght/4;
        local index = cardLenght;
        for i = cardLenght, 1, -1 do
            if cardViews[i]:getValue() == keyCardValue then
                index = i;
                break;
            end 
        end

        if index > cardLenght - num then

            for i = index, index - num * 3 + 1, -1 do
                table.insert(newCardViews, cardViews[i]);
            end

            for i = 1, index - num * 3 do
                table.insert(newCardViews, cardViews[i]);
            end

            for i = index + 1, cardLenght do
                table.insert(newCardViews, cardViews[i]);
            end
            cardViews = newCardViews;
        end

    elseif cardType == DDZCard.CT_THREE_LINE_TAKE_DOUBLE then
        local newCardViews = {};
        local num = cardLenght/5;
        local index = cardLenght;
        for i = cardLenght, 1, -1 do
            if cardViews[i]:getValue() == keyCardValue then
                index = i;
                break;
            end 
        end
        if index > cardLenght - num * 2 then
            for i = index, index - num*3 + 1, -1 do
                table.insert(newCardViews, cardViews[i]);
            end
            for i = 1, index - num*3 do
                table.insert(newCardViews, cardViews[i]);
            end
            for i = index + 1, cardLenght do
                table.insert(newCardViews, cardViews[i]);
            end
            cardViews = newCardViews;
        end
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_ONE then
        if cardViews[1]:getValue() ~= keyCardValue then
            cardViews[1], cardViews[5] = cardViews[5], cardViews[1];
            if cardViews[2]:getValue() ~= keyCardValue then
                cardViews[2], cardViews[6] = cardViews[6], cardViews[2];
            end
        end
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_DOUBLE then
        if cardViews[1]:getValue() ~= keyCardValue then
            cardViews[1], cardViews[5] = cardViews[5], cardViews[1];
            cardViews[2], cardViews[6] = cardViews[6], cardViews[2];
            if cardViews[3]:getValue() ~= keyCardValue then
                cardViews[3], cardViews[7] = cardViews[7], cardViews[3];
                cardViews[4], cardViews[8] = cardViews[8], cardViews[4];
            end
        end

    --飞机
    elseif cardType == DDZCard.CT_THREE_LINE then
        
        local is_three_two = false
        if cardLenght%5 == 0  then
            is_three_two = true
        end

        local cardsList = {}
        for k,v in pairs(cardViews) do
           cardsList[#cardsList + 1] = v:getValue()
        end

        local cardsToNum = DDZPKCardTypeAnalyzer:add(cardsList)

        local mainCards = {}
        local otherCards = {}

        --区分主牌和翅膀
        local getMainCards = function (cardsValue, cardsNum)
                local numTag = 1
                for k,v in pairs(cardViews) do

                    local three_one_tag = (cardsNum >= 3)
                    local three_two_tag = (cardsNum == 3)

                    local cardsNumTag = three_one_tag
                    if is_three_two then
                        cardsNumTag = three_two_tag
                    end

                    if v:getValue() == cardsValue and cardsNumTag and numTag <= 3 and cardsValue < 15 then
                        numTag = numTag + 1
                        mainCards[#mainCards + 1] = v
                    elseif v:getValue() == cardsValue and cardsNumTag and numTag > 3 then
                        otherCards[#otherCards + 1] = v
                    elseif v:getValue() == cardsValue then
                        otherCards[#otherCards + 1] = v
                    end
                end
        end

        for k,v in pairs(cardsToNum) do
            getMainCards(k,v)
        end

        table.sort(mainCards,function (a,b)
            return a:getValue() > b:getValue()
        end)

        table.sort(otherCards,function (a,b)
            return a:getValue() > b:getValue()
        end)

        for k,v in pairs(otherCards) do
            mainCards[#mainCards+ 1] = v
        end

        cardViews = mainCards;
    end

    return cardViews;
end

----------------------------------------------------------------------------
-- @desc 显示自己出的牌
-- @pram    cardViews 手牌ui
--          cardType 牌型
--          keyCardValue 牌的关键值
--          userId:玩家的userid
----------------------------------------------------------------------------
function DDZOprationResultView:showSelfOutCard(cards, cardType, keyCardValue, userId)
    Log.i("DDZOprationResultView:showSelfOutCard ", cards, userId, DataMgr.getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LORDID))
    local isMeLord = DataMgr.getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    local cardNum = #cards
    local space = self:getSpace(cardNum)
    local x = self.width/2  - (cardNum - 1)/2*space
    local cardViews = {}
    for i, card in pairs(cards) do
        local type, value = DDZCard.cardConvert(card)
        local cardView = PokerCardView.new(type, value, card)
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
        Log.i("where is error:", cardView:getCard())
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

----------------------------------------------------------------------------
-- @desc 显示右边玩家出的牌
-- @pram    cardViews 手牌ui
--          cardType 牌型
--          keyCardValue 牌的关键值
--          userId:玩家的userid
----------------------------------------------------------------------------
function DDZOprationResultView:showRightOutCard(cards, cardType, keyCardValue,userId)
    local cardNum = #cards;
    local space = self:getSpace(cardNum);
    local x = self.width  - (cardNum - 1)*space - DDZCard.WIDTH/2 * self.m_scale;
    local cardViews = {};
    for i, card in pairs(cards) do
        local cardType, cardValue = DDZCard.cardConvert(card);
        local cardView = PokerCardView.new(cardType, cardValue,card);
        cardView:setScale(self.m_scale);
        table.insert(cardViews, cardView);
    end
    cardViews = self:sortCards(cardViews, cardType, keyCardValue);
    for k, cardView in pairs(cardViews) do
        self.m_pWidget:addChild(cardView)
        cardView:setPosition(cc.p(x,self.m_outCard_y))
        table.insert(self.m_cards,cardView)

        if k == #cardViews then
            cardView:showFlowerImg()
        end
        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        if lordId == userId and k == #cardViews then
            cardView:addLordTag()
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

----------------------------------------------------------------------------
-- @desc 显示左边玩家出的牌
-- @pram    cardViews 手牌ui
--          cardType 牌型
--          keyCardValue 牌的关键值
--          userId:玩家的userid
----------------------------------------------------------------------------
function DDZOprationResultView:showLeftOutCard(cards, cardType, keyCardValue,userId)
    local cardNum = #cards;
    local space = self:getSpace(cardNum);
    local x = DDZCard.WIDTH/2 * self.m_scale;
    local cardViews = {};
    for i, card in pairs(cards) do
        local cardType, cardValue = DDZCard.cardConvert(card);
        local cardView = PokerCardView.new(cardType, cardValue,card);
        cardView:setScale(self.m_scale);
        table.insert(cardViews, cardView);
    end
    cardViews = self:sortCards(cardViews, cardType, keyCardValue);
    for k, cardView in pairs(cardViews) do
        self.m_pWidget:addChild(cardView);
        cardView:setPosition(cc.p(x, self.m_outCard_y));
        table.insert(self.m_cards, cardView);

        if k == #cardViews then
            cardView:showFlowerImg()
        end

        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        if lordId == userId and k == #cardViews then
            cardView:addLordTag()
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

------------------------------------------------------------------
-- @desc 返回牌距
-- @pram cardNum 拍的数量
------------------------------------------------------------------
function DDZOprationResultView:getSpace(cardNum)
    local space = DDZCard.NORMALSPACE * self.m_scale;
    if cardNum > 1 then
        space = (self.width - DDZCard.WIDTH * self.m_scale)/(cardNum - 1);
    else
        return 0;
    end
    space = space > DDZCard.MAXSPACE * self.m_scale and DDZCard.MAXSPACE * self.m_scale or space;

    return space;
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZOprationResultView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    -- Log.i("DDZDefine.SITE ",DDZDefine.SITE)
    -- Log.i("self.m_data ", self.m_data)
    for k,v in pairs(PlayerModelList) do
        -- Log.i("v:getProp(DDZDefine.SITE) ", v:getProp(DDZDefine.SITE))
        if v:getProp(DDZDefine.SITE) == self.m_data then
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

return DDZOprationResultView