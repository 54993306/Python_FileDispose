
-------------------------------------------------------------------------
-- Desc:   二人斗地主上方数据显示层UI
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPRoomView")
local PokerCardView = require("package_src.games.paodekuai.pdkcommon.widget.PokerCardView")
local DDZTWOPConst = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPConst")
local ToolKit = require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZTWOPGameEvent = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPGameEvent")
local DDZTWOPCard = require("package_src.games.paodekuai.pdktwop.utils.card.DDZTWOPCard")
local DDZTWOPTopBarView = class("DDZTWOPTopBarView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:initView()
    local baseNum = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_BASEROOM)
    --底牌开始动画位置
    self.cardBeganPos = {cc.p(display.cx - 120,display.cy+60),cc.p(display.cx,display.cy+60),cc.p(display.cx + 120,display.cy+60)}
    self.aniCards = {}

    self.pan_showBottom = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_5") 
    self.pan_showBottom:setVisible(false)
    --底牌动画前缩放比例
    self.showFanScale = 0.42
    --底牌动画缩放后比例
    self.showButtomScale = 0.3
    --底牌缩放时间
    self.scaleTime = 0.3
    --底牌移动时间
    self.moveTime = 0.3

    --底牌旋转时间
    self.xTime = 0.3
    --旋转起始半径
    self.beganRadios = 1
    --旋转半径差
    self.radiosSub = 0
    --起始z角
    self.zAngle = 0
    --旋转z角度差
    self.zAngleSub = 90
    --旋转起始x角
    self.angleSub = 0
    --旋转x角差
    self.xAngleSub = 0

    --第二次旋转z角度
    self.secondZangle = 270


    --底牌移动速度
    self.speed = 2000
    --底牌索引
    self.cardIndx = {3,2,1}
end

---------------------------------------
-- 函数功能：   隐藏底牌UI
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:hideTopPan()
    self.pan_showBottom:setVisible(false)
end

---------------------------------------
-- 函数功能：   显示底牌UI
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:showTopPan()
    self.pan_showBottom:setVisible(true)
end

---------------------------------------
-- 函数功能：   显示地主底牌动画
-- 返回值：     无
-- isReconnet:  是否重新连接
---------------------------------------
function DDZTWOPTopBarView:showBottomCard(isReconnet)
    if isReconnet then
        self:showCardNotAnimation()
    else
        self:showCardAnimation()
    end
end

---------------------------------------
-- 函数功能：   重新连接不需要播放底牌动画
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:showCardNotAnimation()
    local cards = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_BOTTOMCADS)
    Log.i("*******************************************************bottomCard Count:",#cards)
    if #cards > 0  then self.pan_showBottom:setVisible(true) end
    for i=1,3 do
        local card = cards[i]
        if card and card ~= DDZTWOPCard.DEBUGCARD then
            local cardType, cardValue = DDZTWOPCard.cardConvert(card)
            local topCard = ccui.Helper:seekWidgetByName(self.m_pWidget,"btm_card"..i)
            local cardView = PokerCardView.new(cardType,cardValue,card)
            cardView:convertToBottomType()
            cardView:setPosition(topCard:getPositionX(),topCard:getPositionY())
            cardView:setScale(self.showButtomScale)
            topCard:getParent():addChild(cardView)
            table.insert(self.aniCards,cardView)
        end
    end
end

---------------------------------------
-- 函数功能：   不是重新连接需要播放底牌动画
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:showCardAnimation()
    local cards = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_BOTTOMCADS)
    if #cards > 0  then self.pan_showBottom:setVisible(true) end
    local speed = self.speed
    if cards and #cards == 3 then
        kPokerSoundPlayer:playEffect("bottom_card")
        local indexs = self.cardIndx
        for i = 1,3 do
            local card = cards[i]
            if card and card ~= -1 then
                local cardType, cardValue = DDZTWOPCard.cardConvert(card)
                local topCard = ccui.Helper:seekWidgetByName(self.m_pWidget,"btm_card"..i)
                local bePos = topCard:getParent():convertToNodeSpace(self.cardBeganPos[i]) 

                local backCard = PokerCardView.new(cardType,cardValue,card)
                backCard:showAsBackBg()
                backCard:setPosition( cc.p(bePos.x,bePos.y))
                topCard:getParent():addChild(backCard,1)
                backCard:setScale(self.showFanScale)
                local frontCard = PokerCardView.new(cardType,cardValue,card)
                frontCard:convertToBottomType()
                frontCard:setPosition(cc.p(bePos.x,bePos.y))
                topCard:getParent():addChild(frontCard,0)
                local frontCardSize = frontCard:getContentSize()
                frontCard:setScale(self.showFanScale)
                frontCard:setVisible(false)
                table.insert(self.aniCards,frontCard)
                local startPos = cc.p(bePos.x,bePos.y)
                local endPos = cc.p(topCard:getPositionX(),topCard:getPositionY())
                local distance = math.sqrt((startPos.x-endPos.x)*(startPos.x-endPos.x)+(startPos.y-endPos.y)*(startPos.y-endPos.y))
                local time = distance/speed
                self:cardAnimation(backCard,frontCard, endPos,time)
            end
        end
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
function DDZTWOPTopBarView:cardAnimation(cardBg,cardFg,toPos,time)
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
    cardBg:runAction(cc.Sequence:create(cc.OrbitCamera:create(self.xTime, self.beganRadios,self.radiosSub,self.zAngle,self.zAngleSub,self.angleSub,self.xAngleSub),cc.Hide:create(),cc.CallFunc:create(
        function()
            cardFg:runAction(cc.Sequence:create(cc.Show:create(),cc.OrbitCamera:create(self.xTime,self.beganRadios,self.radiosSub,self.secondZangle,self.zAngleSub,self.angleSub,self.xAngleSub),cc.CallFunc:create(function()
                transition.execute(cardFg,cc.Spawn:create(cc.ScaleTo:create(self.scaleTime,self.showButtomScale), cc.MoveTo:create(self.moveTime, toPos)), {
                    onComplete = function()
            
                    end
                })
            end)))
        end
    )))
end

---------------------------------------
-- 函数功能：   隐藏底牌函数
-- 返回值：     无
---------------------------------------
function DDZTWOPTopBarView:hideBottomCard()
    for i = 1,#self.aniCards do
        self.aniCards[i]:removeFromParent()
    end
    self.aniCards = {}
    self.pan_showBottom:setVisible(false)
end

return DDZTWOPTopBarView