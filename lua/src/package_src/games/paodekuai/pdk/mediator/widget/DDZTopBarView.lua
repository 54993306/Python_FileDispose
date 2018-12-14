--
-- 三人斗地主顶部栏  底牌、倍数、房间信息 (电量\信号暂不要)
--

local PokerCardView = require("package_src.games.paodekuai.pdkcommon.widget.PokerCardView")
local PokerUtils = require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZCard = require("package_src.games.paodekuai.pdk.utils.card.DDZCard")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local DDZTopBarView = class("DDZTopBarView", DDZRoomView);
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")

function DDZTopBarView:initView()
    self.aniCards = {}
    -- self.img_signalWiFi = {}
    -- self.img_bat = {}
    -- self.img_signalCell = {}
    -- self.btm_card1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btm_card1");
    -- self.btm_card2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btm_card2");
    -- self.btm_card3 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btm_card3");
    -- self.btm_card1:setVisible(false)
    -- self.btm_card2:setVisible(false)
    -- self.btm_card3:setVisible(false)
    -- self.blb_mul = ccui.Helper:seekWidgetByName(self.m_pWidget, "blb_mul");
    -- self.img_base = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_base")
    -- self.img_base:setAnchorPoint(cc.p(0.0,0.5))

    self.cardContainer = ccui.Helper:seekWidgetByName(self.m_pWidget, "cardContainer");
    self.cardContainer:setVisible(true)
    self.lab_mul = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_mul");
    self.lab_base = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_base");

    self.Image_multi = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_multi");
    self.Label_times = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_times");
    self.Image_multi:setVisible(false)
    -- self.topCard1 = ccui.Helper:seekWidgetByName(self.m_pWidgets,"topCard_1")
    -- self.topCard2 = ccui.Helper:seekWidgetByName(self.m_pWidget,"topCard_2")
    -- self.topCard3 = ccui.Helper:seekWidgetByName(self.m_pWidget,"topCard_3")

    -- self.time = ccui.Helper:seekWidgetByName(self.m_pWidget,"time")
    -- self.wifi = ccui.Helper:seekWidgetByName(self.m_pWidget,"wifiContainer")
    -- self.energy = ccui.Helper:seekWidgetByName(self.m_pWidget,"bat")
    --self.jushu = ccui.Helper:seekWidgetByName(self.m_pWidget,"jushu")
    --self.jushu:setVisible(HallAPI.DataAPI:isFriendRoom())

    -- for i=1,5 do
    --     self.img_bat[i] = ccui.Helper:seekWidgetByName(self.m_pWidget,"energy"..i)
    -- end

    -- for i=1,3 do
    --     self.img_signalWiFi[i] = ccui.Helper:seekWidgetByName(self.m_pWidget,"wifi"..(i+1))
    -- end

    -- self:updateBattery()
    -- self:updateSignal()
end

-------------------------------------------------------
--@ desc重置
-------------------------------------------------------
function DDZTopBarView:reset()
    -- self.m_topBarView:hideTopPan()
    -- self.m_topBarView:setMultiple(1);
    -- self:hideBottomCard()

    --self:hide()
    self.Image_multi:setVisible(false)
    for i = 1,#self.aniCards do
        if not tolua.isnull(self.aniCards[i]) then
            self.aniCards[i]:removeFromParent()
        end
    end
    self.aniCards = {}
end

-------------------------------------------------------
--@ desc 显示本控件
-------------------------------------------------------
function DDZTopBarView:showTopPan()
    -- self.img_base:setVisible(true)
    -- self.lab_base:setVisible(true)
    -- self.blb_base:setVisible(true)
    --self.jushu:setVisible(true)
    self:show()
end

-------------------------------------------------------
--@ desc 显示底牌
--@pram :isReconnect:是否重连  不是重连需要显示底牌翻牌动画
-------------------------------------------------------
function DDZTopBarView:showBottomCard(isReconnect)
    local cards = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_BOTTOMCADS)
    Log.i("********************************************showBottomCard",cards,isReconnect)
    Log.i("clean showBottomCard")
    for i = 1,#self.aniCards do
        if not tolua.isnull(self.aniCards[i]) then
            self.aniCards[i]:removeFromParent()
        end
    end
    self.aniCards = {}

    self:show()
    if cards and #cards == 3 then
        kPokerSoundPlayer:playEffect("bottom_card");
        for i = 1, 3 do
            local card = cards[i];
            if card and card ~= -1 then
                local cardType, cardValue = DDZCard.cardConvert(card);
                local btm_card = ccui.Helper:seekWidgetByName(self.m_pWidget, "btm_card"..i);
                btm_card:setVisible(false)
                local topCard = ccui.Helper:seekWidgetByName(self.m_pWidget,"topCard_"..i)
                --local backCard = cc.Sprite:create("#cardbg.png")
                local backCard = PokerCardView.new(cardType,cardValue,card)
                backCard:showAsBackBg()
                backCard:setPosition(cc.p(btm_card:getPositionX(),btm_card:getPositionY()))
                btm_card:getParent():addChild(backCard,1)
                backCard:setScale(0.55)
                local frontCard = PokerCardView.new(cardType,cardValue,card)--cc.Sprite:create("package_res/games/ddz/card/" .. cardType .. cardValue ..".png")
                frontCard:convertToBottomType()
                frontCard:setPosition(cc.p(btm_card:getPositionX(),btm_card:getPositionY()))
                btm_card:getParent():addChild(frontCard,0)
                local btm_cardSize = btm_card:getContentSize()
                local frontCardSize = frontCard:getContentSize()
                frontCard:setScale(0.55)
                frontCard:setVisible(false)
                table.insert(self.aniCards,frontCard)
                if not isReconnect then
                    self:cardAnimation(backCard,frontCard, cc.p(topCard:getPositionX(),topCard:getPositionY()))
                else
                    backCard:setVisible(false)
                    frontCard:setVisible(true)
                    frontCard:setScale(0.45)
                    frontCard:setPosition(cc.p(topCard:getPositionX(),topCard:getPositionY()))
                end
            end
        end
    else
        self:hideBottomCard()
    end
end

---------------------------------------
-- 函数功能：   卡牌翻转动画
-- 返回值：     无
--[[
    参数：
    cardBg     牌背面
    cardFg     牌面
    toPos      动画终点
    time       动画时间
]]
---------------------------------------
function DDZTopBarView:cardAnimation(cardBg,cardFg,toPos)
    Log.i("******************************************cardAnimation")
    local time = 0.2
    --cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
    cardBg:runAction(cc.Sequence:create(cc.OrbitCamera:create(time,1,0,0,90,0,0),cc.Hide:create(),cc.CallFunc:create(
        function()
            cardFg:runAction(cc.Sequence:create(cc.Show:create(),cc.OrbitCamera:create(time,1,0,270,90,0,0),cc.CallFunc:create(function()
                transition.execute(cardFg,cc.Spawn:create(cc.ScaleTo:create(0.3,0.45), cc.MoveTo:create(0.3, toPos)), {
                    onComplete = function()
                    -- self.time:setVisible(false)
                    -- self.energy:setVisible(false)
                    -- self.wifi:setVisible(false)
                    end
                });
            end)))
        end
    )))
end

---------------------------------------
-- 函数功能：   更新电量和信号
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:updateBatteryAndSignal()
    self:updateBattery()
    self:updateSignal()
end

---------------------------------------
-- 函数功能：   隐藏底牌函数
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:hideBottomCard()
    for i = 1, 3 do
        ccui.Helper:seekWidgetByName(self.m_pWidget, "btm_card"..i):setVisible(false);
        --ccui.Helper:seekWidgetByName(self.m_pWidget,"topCard_"..i):setVisible(false)
    end
    Log.i("clean hideBottomCard")
    for i = 1,#self.aniCards do
        self.aniCards[i]:removeFromParent()
    end
    self.aniCards = {}
    self.Image_multi:setVisible(false)
    --self:hide()

    -- self.time:setVisible(true)
    -- self.energy:setVisible(true)
    -- self.wifi:setVisible(true)
    -- self:updateBatteryAndSignal()
end

---------------------------------------
-- 函数功能：   更新倍数  
-- 参数:        multiple :倍数
-- 返回值：     无
---------------------------------------
function DDZTopBarView:setMultiple(multiple)
    --multiple = 16
    -- self.blb_mul:setString(multiple);
    -- self.img_base:setPositionX(self.blb_mul:getContentSize().width+5)
end

---------------------------------------
-- 函数功能：   设置房间付费信息
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:setRoomjushu()
    --self.jushu:setVisible(false)
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local curCount = roomInfo.noRS
    local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
    local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
    --self.jushu:setString(string.format("局数:%d/%d",curCount,totalCount))
end

---------------------------------------
-- 函数功能：   设置房底数
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:setBaseNum()
    local baseNum = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_BASEROOM);
    self.blb_base:setString("" .. baseNum);
end

---------------------------------------
-- 函数功能：   更新电量
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:updateBattery()
    local data = {};
    data.cmd = NativeCall.CMD_GETBATTERY;
    NativeCall.getInstance():callNative(data, self.onUpdateBattery, self); 

    -- --时间
    -- local stime = PokerUtils:getLocalTimeStr()
    -- Log.i("DDZTopBarView:updateBattery ", stime)
    -- self.time:setString(stime);
end

---------------------------------------
-- 函数功能：   取到系统电量，显示
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:onUpdateBattery(info)
    -- self.blb_bat:setString(info.baPro .. "%");
    -- if not self then return end
    -- dump(info, "<jinds>: info is : ")
    if not tolua.isnull(self.time)  then

        local  shownum = math.floor(info.baPro / 20)
        -- print("<jinds>: ", shownum)
        for i=1,5 do
            if shownum >= i then
                self.img_bat[i]:setVisible(true)
            else
                self.img_bat[i]:setVisible(false)
            end  
        end
    end
    
    if not tolua.isnull(self.m_pWidget) then
        self.m_pWidget:stopAllActions()
        self.m_pWidget:performWithDelay(function()
            self:updateBattery();
        end, 30);
    end

end

---------------------------------------
-- 函数功能：   更新信号
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:updateSignal()
    local data = {};
    data.cmd = NativeCall.CMD_WECHAT_SIGNAL;
    NativeCall.getInstance():callNative(data, self.onUpdateSignal, self); 
end


-- 函数功能：   更新倍数
-- 参数:        无
-- 返回值：     无
function DDZTopBarView:updateTopMulti()
    --local userMulti = DataMgr:getInstance():getDiZhuMultiple()

    local userID = kUserInfo:getUserId()
    local userMulti = DataMgr:getInstance():getPlayerMultipleById(userID)  

    if userMulti <= 0 then
        self.Image_multi:setVisible(false)
    else
        self.Image_multi:setVisible(true)
        self.Label_times:setString("倍数:x" .. userMulti)
    end
end

---------------------------------------
-- 函数功能：   取到信号显示  暂不清楚蜂窝信号是否可以有不同强度显示    ---todo
-- 参数:        无
-- 返回值：     无
---------------------------------------
function DDZTopBarView:onUpdateSignal(info)
    self.m_pWidget:stopAllActions()
    self.m_pWidget:performWithDelay(function()
        self:updateSignal();
    end, 5);

    -- local info = event.data
    if info.type ~= "Wi-Fi" then
        --self.img_signalWiFiBg:setVisible(false)
        --self.img_signalCellBg:setVisible(true)
        return
    else
        --self.img_signalWiFiBg:setVisible(true)
        --self.img_signalCellBg:setVisible(false)
    end

    if info.rssi == 4 then
        self.img_signalWiFi[1]:setVisible(true)
        self.img_signalWiFi[2]:setVisible(true)
        self.img_signalWiFi[3]:setVisible(true)
    elseif info.rssi == 3 then
        self.img_signalWiFi[1]:setVisible(true)
        self.img_signalWiFi[2]:setVisible(true)
        self.img_signalWiFi[3]:setVisible(false)
    elseif info.rssi == 2 then
        self.img_signalWiFi[1]:setVisible(true)
        self.img_signalWiFi[2]:setVisible(false)
        self.img_signalWiFi[3]:setVisible(false)
    elseif info.rssi == 1 then
        self.img_signalWiFi[1]:setVisible(false)
        self.img_signalWiFi[2]:setVisible(false)
        self.img_signalWiFi[3]:setVisible(false)
    end

end

return DDZTopBarView