--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.common.Define"
--local WWFacade = require("app.games.common.custom.WWFacade")
local Mj            = require "app.games.common.mahjong.Mj"
local MJTriacks = class("MJTriacks", function ()
	return display.newNode()
end)
function MJTriacks:ctor(args)
    self._diceTime = false
    -- self:initTriacks()
end
function MJTriacks:initTriacks()
    local myCards = display.newSprite("#shupaidun.png")
    local leftCards = display.newSprite("#hengpaidun.png")
    local otherCards = display.newSprite("#shupaidun.png")
    local rightCards = display.newSprite("#hengpaidun.png")

    local myCards       = Mj.new(enMjType.EMPTY_SHU_PAI)
    local leftCards     = Mj.new(enMjType.EMPTY_HENG_PAI)
    local otherCards    = Mj.new(enMjType.EMPTY_SHU_PAI)
    local rightCards    = Mj.new(enMjType.EMPTY_HENG_PAI)

    self._myCards = {}
    self._leftCards = {}
    self._otherCards = {}
    self._rightCards = {}
    for i=1,(Define.mj_tricks*2) do
--        Log.i("添加麻将...."..i)
        --自家前面的墩数
        local scale = 1
        local myMj = myCards:clone()
        local mjBSz = myMj:getContentSize()
        --左边玩家前面的墩数
        local leftMj = leftCards:clone()
        local leftMjSZ = leftMj:getContentSize()
         --对面玩家前面的墩数
        local otherMj = otherCards:clone()
        local otherMjSZ = otherMj:getContentSize()
        --右边玩家前面的墩数
        local rightMj = rightCards:clone()
        local rightMjSZ = rightMj:getContentSize()
        local transposition = 0
        if i % 2 == 1 then 
            myMj:setPosition(cc.p(Define.mj_myCards_position_wall_x-(i/2)*mjBSz.width*scale, Define.mj_myCards_position_wall_y))
            leftMj:setPosition(cc.p(Define.mj_leftCards_position_wall_x,Define.mj_leftCards_position_wall_y+(i/2)*(leftMjSZ.height-12)*scale))
            otherMj:setPosition(cc.p(Define.mj_otherCards_position_wall_x +(i/2)*otherMjSZ.width*scale,Define.mj_otherCards_postion_wall_y))
            rightMj:setPosition(cc.p(Define.mj_rightCards_position_wall_x,Define.mj_rightCards_position_wall_y-(i/2)*(rightMjSZ.height-12)*scale))
            transposition = i+1
        else
            myMj:setPosition(cc.p(Define.mj_myCards_position_wall_x-((i-1)/2)*mjBSz.width*scale, Define.mj_myCards_position_wall_y+9*scale))
            leftMj:setPosition(cc.p(Define.mj_leftCards_position_wall_x, Define.mj_leftCards_position_wall_y+((i-1)/2)*(leftMjSZ.height-12)*scale+15*scale))
            otherMj:setPosition(cc.p(Define.mj_otherCards_position_wall_x+((i-1)/2)*otherMjSZ.width*scale,Define.mj_otherCards_postion_wall_y+10*scale))
            rightMj:setPosition(cc.p(Define.mj_rightCards_position_wall_x,Define.mj_rightCards_position_wall_y-((i-1)/2)*(rightMjSZ.height-12)*scale+15*scale))
            transposition = i-1
        end
        myMj:setScale(scale)
	    myMj:addTo(self,80-transposition)
        table.insert(self._myCards,transposition,myMj)

        leftMj:setScale(scale)
        leftMj:addTo(self,40-transposition)
        table.insert(self._leftCards,transposition,leftMj)

        otherMj:setScale(scale)
        otherMj:addTo(self,40-transposition)
        table.insert(self._otherCards,transposition,otherMj)

        rightMj:setScale(scale)
        rightMj:addTo(self,40+i)
        table.insert(self._rightCards,transposition,rightMj)

        if i%2 == 0 then
            table.insert(self._myCards,i,self._myCards[i+1])
            table.insert(self._leftCards,i,self._leftCards[i+1])
            table.insert(self._otherCards,i,self._otherCards[i+1])
            table.insert(self._rightCards,i,self._rightCards[i+1])

            table.remove(self._myCards,i+1)
            table.remove(self._leftCards,i+1)
            table.remove(self._otherCards,i+1)
            table.remove(self._rightCards,i+1)
        end
    end
end
--加载拿牌位置
function MJTriacks:initTriacksCard(direction,position)
    --方向问题，1表示自己前面的牌，2表示自己左边的牌，3表示自己对面的牌，4表示自己右边的牌
    self._cardTricks = {}
    self._direction = direction
    --拿走的墩数
    self._takes = 0
    self._position = position
    self.trick = 0
    if self._direction == 1 then
        self._cardTricks = self._myCards
    elseif self._direction == 2 then
        self._cardTricks = self._leftCards
    elseif self._direction == 3 then
        self._cardTricks = self._otherCards
    elseif self._direction == 4 then
        self._cardTricks = self._rightCards
    end
--    self:licensing()
    local function removeFunc()
        self:removeAllChildren()
        for i = 1,#self._myCards do
            table.remove(self._myCards)
            table.remove(self._leftCards)
            table.remove(self._otherCards)
            table.remove(self._rightCards)
        end
        
        Define.isVisibleTrick = true
        self:removeFromParent()
    end
    local cf = cc.CallFunc:create(removeFunc)
    local dt = cc.DelayTime:create(0.3)
    self:runAction(cc.Sequence:create(dt,cf))
end
--拿墩牌的动画
function MJTriacks:licensing()
    
    local isOutBounds = false
    local outBoundsNum = 0
    for i = 1,4 do
        self.trick = (self._position*2)+i
        if self.trick > 0 and self.trick <= #self._cardTricks then
            self._cardTricks[self.trick]:setVisible(false)
        else
            isOutBounds = true
            outBoundsNum = i
            if self._direction == 1 then
                self._cardTricks = self._leftCards
            elseif self._direction == 2 then
                self._cardTricks = self._otherCards
            elseif self._direction == 3 then
                self._cardTricks = self._rightCards
            elseif self._direction == 4 then
                self._cardTricks = self._myCards
            end
            if self._direction > 0 and self._direction < 4 then
                self._direction = self._direction+1
            elseif self._direction == 4 then
                self._direction = 1
            end
            self._position = 0
            break
        end
    end
    if isOutBounds then
        for i=outBoundsNum,4 do
            self.trick = (self._position*2)+(4-i+1)
            self._cardTricks[self.trick]:setVisible(false)
        end
    end
    if isOutBounds == true then
        isOutBounds = false
        if outBoundsNum == 3 then
            self._position = self._position+1
        else
            self._position = self._position+2
        end
        outBoundsNum = 0
    else
        self._position = self._position+2
    end
    Define.cards_tricks_position_x,Define.cards_tricks_position_y = self._cardTricks[self.trick]:getPosition()
    self._takes = self._takes+1
--    Log.i("takes....",self._takes)
    
    if self._takes == Define.mj_takes then
        local trick = 0
        self.trick = self.trick+1
        self:jumpCard(self._direction,self.trick)
        return
    end
   
    Define.isVisibleTrick = false
    local cf = cc.CallFunc:create(self.licensing)
    local dt = cc.DelayTime:create(0.2)
    self:runAction(cc.Sequence:create(dt,cf))

    
end
--那完牌后的跳牌动画
function MJTriacks:jumpCard(direction,trick)
    local cardTricks = {}
    if trick>=36 then
        if direction > 0 and direction < 4 then
            direction = direction+1
        elseif direction == 4 then
            direction = 1
        end
        trick = 1
    end
    if direction == 1 then
        cardTricks = self._myCards
    elseif direction == 2 then
        cardTricks = self._leftCards
    elseif direction == 3 then
        cardTricks = self._otherCards
    elseif direction == 4 then
        cardTricks = self._rightCards
    end
    cardTricks[trick]:setVisible(false)
    Define.cards_tricks_position_x,Define.cards_tricks_position_y = cardTricks[trick]:getPosition()
    Define.isVisibleTrick = false
    
end

-- --色子动画
-- function MJTriacks:diceAnimation(pointMin,pointMax, gangAnim)
--     ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yaoshaizi.csb")
--     local armature = ccs.Armature:create("yaoshaizi")
--     armature:setPosition(cc.p(display.cx+120, display.cy))
--     armature:getAnimation():play("Animation1")
--     armature:performWithDelay(function()
--              armature:removeFromParent(true)
--         end, Define.shaizi_time);
--     self:addChild(armature,500)
--     local function diceFunc()
--         local dice_1_image = string.format("#00000%s.png",pointMin)
--         local dice_2_image = string.format("#00000%s.png",pointMax)

--         local dice_1_sprite = display.newSprite(dice_1_image)
--         dice_1_sprite:setPosition(cc.p(display.cx-35,display.cy))
--         dice_1_sprite:addTo(self,0)
--         self:removeChild(dice_1,true)

--         local dice_2_sprite = display.newSprite(dice_2_image)
--         dice_2_sprite:setPosition(cc.p(display.cx+35,display.cy))
--         dice_2_sprite:addTo(self,0)
--         self:removeChild(dice_2,true)
        
--         if gangAnim == nil then
--             WWFacade:dispatchCustomEvent(MJ_EVENT.GAME_startAniEnd)
--         else
--              self:performWithDelay(function ()
--                 self:removeFromParent()
--             end, 0.4)
--         end
--     end
--     local diceCF = cc.CallFunc:create(diceFunc)
--     local diceDT = cc.DelayTime:create(Define.shaizi_time)
--     self:runAction(cc.Sequence:create(diceDT,diceCF))

-- --    local diceRemove = cc.CallFunc:create(function ()

-- --    end)
-- end

--[[
-- @brief  播放骰子动画函数
-- @param  void
-- @return void
--]]
function MJTriacks:diceAnimation(pointMin, pointMax, gangAnim)
    SoundManager.playEffect("dasezi", false);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yaoshaizi.csb")
    local armature = ccs.Armature:create("yaoshaizi")
    armature:setPosition(cc.p(display.cx+120, display.cy))
    armature:getAnimation():play("Animation1")
    armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, Define.shaizi_time)
    self:addChild(armature, 500)
    local function diceFunc()
        local dice_1_image = string.format("#00000%s.png",pointMin)
        local dice_2_image = string.format("#00000%s.png",pointMax)

        local dice_1_sprite = display.newSprite(dice_1_image)
        dice_1_sprite:setPosition(cc.p(display.cx-35,display.cy))
        dice_1_sprite:addTo(self,0)
        self:removeChild(dice_1, true)

        local dice_2_sprite = display.newSprite(dice_2_image)
        dice_2_sprite:setPosition(cc.p(display.cx+35,display.cy))
        dice_2_sprite:addTo(self,0)
        self:removeChild(dice_2, true)
        
        if gangAnim == nil then
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TRICKS_END_NTF)
        end
        self:performWithDelay(function ()
            self:removeFromParent()
        end, 0.4)
    end
    local diceCF = cc.CallFunc:create(diceFunc)
    local diceDT = cc.DelayTime:create(Define.shaizi_time)
    self:runAction(cc.Sequence:create(diceDT, diceCF))

--    local diceRemove = cc.CallFunc:create(function ()

--    end)
end
return MJTriacks
--endregion
