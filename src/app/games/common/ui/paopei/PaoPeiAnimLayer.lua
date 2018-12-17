local Mj = require "app.games.common.mahjong.Mj"
local Define = require "app.games.common.Define"

local PaoPeiAnimLayer = class("PaoPeiAnimLayer", function ()
	return display.newLayer()
end)

function PaoPeiAnimLayer:ctor()
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mj/paopei.csb");
   	self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
    self.m_pWidget:addTo(self)
    self.winnerSite = MjProxy:getInstance():getPlayerSiteById(MjProxy:getInstance()._gameOverData.winnerId) -- 赢家的位置
    self.img_bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_bg");
    -- self.img_bg:addTouchEventListener(handler(self, self.onClickButton));
    self.startXPos = 190
    self.startYPos = 200
    self.actionWidth = 200
    local actionMjs = MjProxy:getInstance()._players[self.winnerSite].m_arrMyActionMj
    local actionTypes = MjProxy:getInstance()._players[self.winnerSite].m_arrMyActionType
    local lastPlayerIndexs = MjProxy:getInstance()._players[self.winnerSite].m_arrLastPlayerIndexs
    
    for i = 1, #actionTypes do
        self:ui_drawActionMj(actionTypes[i], actionMjs[i], lastPlayerIndexs[i], i -1)
    end
    self:showAnim()
end

function PaoPeiAnimLayer:showAnim()
    local winType = MjProxy:getInstance()._gameOverData.winType --1 自摸 2 点炮 3 流局
    local mjValues = MjProxy:getInstance()._gameOverData.scoreItems[self.winnerSite].closeCards
    local allMjValues = {}

    for i=1,#mjValues do
        allMjValues[i] = mjValues[i]
    end
    if winType == 1 then
        local huMj = MjProxy:getInstance():getHuMj()
        if huMj ~= 0 then
            for i=1,#allMjValues do
                if huMj == allMjValues[i] then --自摸且不是天胡时，胡的牌已经在closecards里了，要去掉
                    table.remove(allMjValues, i)
                    break
                end
            end
        end
    end
    local laiziMj = {}
    local otherMj = {}
    for i=1,#allMjValues do
        if allMjValues[i] == MjProxy:getInstance():getLaizi() then
            laiziMj[#laiziMj + 1] = allMjValues[i]
        else
            otherMj[#otherMj + 1] = allMjValues[i]
        end
    end
    allMjValues = {}
    for i=1,#laiziMj do
        allMjValues[#allMjValues +1] = laiziMj[i]
    end
    for i=1,#otherMj do
        allMjValues[#allMjValues +1] = otherMj[i]
    end
    local mjyPos = self.img_bg:getContentSize().height / 2 - 25
    local mjCards = {}
    for i = 1, #allMjValues do
        local mj = Mj.new(allMjValues[i], Mj._EType.e_type_normal)
        mj:setPosition(cc.p( (i -1)* Define.g_pai_width - #allMjValues*Define.g_pai_width  , mjyPos))
        mjCards[i] = mj
        self.img_bg:addChild(mj)
        if mj._value == MjProxy:getInstance():getLaizi() then
            if mj:getChildByName("mjLaizi") == nil then
                local mjLaizi = display.newSprite("#xuanzhonglaizi.png")
                mjLaizi:setName("mjLaizi")
                mjLaizi:setPosition(cc.p(0, 0))
                mj:addChild(mjLaizi)
            end
        end
    end
    for i=1, #mjCards do
        local mj = mjCards[i]
        transition.execute(mj, cc.MoveBy:create(0.5, cc.p(self.img_bg:getContentSize().width / 2 + #allMjValues *Define.g_pai_width /2 , 0)), {
            onComplete = function()
                if i== #mjCards then
                    if MjProxy:getInstance():getHuMj() ~= 0 then
                        local huMj = Mj.new(MjProxy:getInstance():getHuMj(), Mj._EType.e_type_normal)
                        huMj:addTo(self.img_bg)
                        huMj:setPosition(cc.p(mjCards[#mjCards]:getPositionX() + Define.g_pai_width+15 , mjyPos))
                        huMj:setScale(3)
                        if huMj._value == MjProxy:getInstance():getLaizi() then
                            if huMj:getChildByName("mjLaizi") == nil then
                                local mjLaizi = display.newSprite("#xuanzhonglaizi.png")
                                mjLaizi:setName("mjLaizi")
                                mjLaizi:setPosition(cc.p(0, 0))
                                huMj:addChild(mjLaizi)
                            end
                        end
                        local scaleto = cc.ScaleTo:create(0.3,1)
                        huMj:runAction(scaleto)
                    end
                end
            end
        });                    
    end
end

function PaoPeiAnimLayer:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.img_bg then 
            self:removeFromParent()
        end
    end
end

function PaoPeiAnimLayer:ui_drawActionMj(actionType, mjs, lastPlayerIndex, index)
    if actionType == enOperate.OPERATE_CHI or actionType == enOperate.OPERATE_PENG then
        self:ui_drawActionThree(mjs, actionType, lastPlayerIndex, index)
    elseif actionType == enOperate.OPERATE_MING_GANG or actionType == enOperate.OPERATE_AN_GANG or actionType == enOperate.OPERATE_JIA_GANG then
        self:ui_drawActionFour(mjs, actionType, lastPlayerIndex, index)
    end
end

function PaoPeiAnimLayer:ui_drawActionFour(mjs, actionType, lastPlayerIndex, index)
    local mj = mjs[1]
    if actionType == enOperate.OPERATE_AN_GANG then
        self:ui_drawActionThreeGang(mj, actionType, index)
    elseif actionType == enOperate.OPERATE_MING_GANG or actionType == enOperate.OPERATE_JIA_GANG then
        self:ui_drawActionThree(mjs, actionType, lastPlayerIndex, index)
    end
    local actionNode = self:getChildByTag(150 + mj)
    if actionNode then
        local node = nil
        if actionType == enOperate.OPERATE_AN_GANG then
            node = Mj.new(mj, Mj._EType.e_type_action,Mj._ESide.e_side_self)
            node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() +20))
            node:addTo(self,3)
        else
            local yPre = 0
            local xPre = 1      
            node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
            if lastPlayerIndex == 2 then
                node:setPosition(cc.p(actionNode:getPositionX()+Define.g_action_pai_width+xPre, actionNode:getPositionY() + Define.g_action_tang_pai_height-yPre))
            elseif lastPlayerIndex == 3 then
                node:setPosition(cc.p(actionNode:getPositionX(), actionNode:getPositionY() + Define.g_action_tang_pai_height+8-yPre))
            elseif lastPlayerIndex == 4 then
                node:setPosition(cc.p(actionNode:getPositionX()-Define.g_action_tang_pai_width+2, actionNode:getPositionY() + Define.g_action_tang_pai_height-yPre))
            end
            node:addTo(self,1)
        end     
        node:setAnchorPoint(cc.p(-0.5, 0))
        
    else
        Log.i("drawActionThree 没找到 %d 的tag值", mj)
    end    
end

function PaoPeiAnimLayer:ui_drawActionThreeGang(mj, actionType, index)

    local actionPaiWidth = self.actionWidth *index

    for i = 0, 2 do
        local node = nil
        if actionType == enOperate.OPERATE_AN_GANG then
            node = display.newSprite("#self_gang_poker.png")
            node:setAnchorPoint(cc.p(0, 0.5))

        else
            node = Mj.new(mj, Mj._EType.e_type_action,Mj._ESide.e_side_self)
            node:setAnchorPoint(cc.p(-0.5, 0))
        end

        node:setPosition(cc.p(self.startXPos + i * Define.g_action_pai_width + actionPaiWidth, self.startYPos))
        self:addChild(node,2)

        if i == 1 and(actionType == enOperate.OPERATE_PENG or actionType == enOperate.OPERATE_MING_GANG
            or actionType == enOperate.OPERATE_AN_GANG or actionType == enOperate.OPERATE_JIA_GANG) then
            node:setTag(150 + mj)
        end
        if i == 1 and(actionType == enOperate.OPERATE_PENG or actionType == enOperate.OPERATE_MING_GANG
            or actionType == enOperate.OPERATE_AN_GANG or actionType == enOperate.OPERATE_JIA_GANG) then
            node:setTag(150 + mj)
        end
        
    end
end

function PaoPeiAnimLayer:ui_drawActionThree(mjs, actionType, lastPlayerIndex, index)
 
    local actionPaiWidth = self.actionWidth *index 
    
    for i = 0, 2 do
        local node = nil
        local yPre = 6
        local xPre = 2
        local xOffer = 1
        local mj = mjs[1]
        if actionType == enOperate.OPERATE_CHI then
            mj = mjs[i+1]
        end
        if lastPlayerIndex == 2 then --下家
            if i == 2 then
                node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos + 2*Define.g_action_pai_width  + actionPaiWidth+xOffer, self.startYPos - yPre))
            else
                node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos + i * Define.g_action_pai_width + actionPaiWidth, self.startYPos))
            end
        elseif lastPlayerIndex == 3 then --对家
            if i == 1 then
                node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos +Define.g_action_pai_width  + actionPaiWidth+xOffer, self.startYPos - yPre))
            elseif i == 0 then
                node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos  + actionPaiWidth, self.startYPos))

            elseif i == 2 then
                node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos +  Define.g_action_pai_width + Define.g_action_tang_pai_width + actionPaiWidth-xPre, self.startYPos))
            end         
        elseif lastPlayerIndex == 4 then --上家 
            if i == 0 then
                node = Mj.new(mj, Mj._EType.e_type_action_tang, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos + i*Define.g_action_pai_width  + actionPaiWidth, self.startYPos - yPre))
            else
                node = Mj.new(mj, Mj._EType.e_type_action, Mj._ESide.e_side_self)
                node:setPosition(cc.p(self.startXPos + (i -1)* Define.g_action_pai_width + Define.g_action_tang_pai_width + actionPaiWidth-xPre, self.startYPos))
            end         
        end
        self:addChild(node,2)
        node:setAnchorPoint(cc.p(-0.5, 0))
        if i == 1 and(actionType == enOperate.OPERATE_PENG or actionType == enOperate.OPERATE_MING_GANG
            or actionType == enOperate.OPERATE_AN_GANG or actionType == enOperate.OPERATE_JIA_GANG) then
            node:setTag(150 + mj)
        end
    end
end

return PaoPeiAnimLayer