-------------------------------------------------------------
--  @file   PlayerPanelBase.lua
--  @brief  玩家版块
--  @author Zhu Can Qin
--  @DateTime:2016-09-18 12:26:08
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define        	= require "app.games.common.Define"
local MjGroups 			= require("app.games.common.ui.playlayer.exhibition.MjGroups")
local PlayerPanelBase 	= class("PlayerPanelBase",function ()
	local ret = ccui.Widget:create()
    ret:ignoreContentAdaptWithSize(true)
    ret:setAnchorPoint(cc.p(0, 0.5))
    return ret
end )

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function PlayerPanelBase:ctor()
	-- 存储所有打开牌的对象
    self.handCardsObjs  = {}
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function PlayerPanelBase:dtor()

end

--[[
    -- @brief 检查判断table中是否包含有该麻将
    -- @param tab table, obj 麻将值
    -- @return true 包含，false 不包含
]]
function PlayerPanelBase:isContainsObj(tab, value)
    for i, v in ipairs(tab) do
        if v:getValue() == value then
            return true
        end
    end
    return false
end

--[[
-- @brief  播放动作动画函数
-- @param  site 坐位 isHide 是否消失
-- @return void
--]]
function PlayerPanelBase:playActionAnimation(amimation, site, time, isHide)
    time = time or 1
    if isHide == nil then
        isHide = true
    end
    if not amimation then -- 不显示动画, 直接发送动画结束消息
        self:performWithDelay(function()
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
            end,time)
        return
    end
    Log.i("amimation.....", amimation, "time.....", time)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
    local armature = ccs.Armature:create("CpghAnimation")
    armature:getAnimation():play(amimation)
    armature:performWithDelay(function()        
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF, amimation)
            if isHide then
                armature:removeFromParent(true)
            end
        end, time);
    self:setPositionBySite(armature,site)
    self:addChild(armature, 50)
end

--[[
-- @brief  播放动作动画函数
-- @param  site 坐位 isHide 是否消失
-- @param  aniInfo =
                    {
                        ArmatureFile    --  文件路径
                        Armature        --  名称
                        Animation       --  动画
                    }
-- @return void
--]]
function PlayerPanelBase:playAnimation(aniInfo, site, time, isHide)
    time = time or 1
    if isHide == nil then
        isHide = true
    end
    if not aniInfo then -- 不显示动画, 直接发送动画结束消息
        self:performWithDelay(function()
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
            end,time)
        return
    end
    Log.i("amimation.....", aniInfo.Animation, "time.....", time)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(aniInfo.ArmatureFile)
    local armature = ccs.Armature:create(aniInfo.Armature)
    armature:getAnimation():play(aniInfo.Animation)
    armature:performWithDelay(function()        
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF, aniInfo.Animation)
            if isHide then
                armature:removeFromParent(true)
            end
        end, time);
    self:setPositionBySite(armature,site)
    self:addChild(armature, 50)
end

function PlayerPanelBase:setPositionBySite(armature,site)
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum

    if site == Define.site_self then
        armature:setPosition(cc.p(display.cx, display.cy - 150))
    elseif site == Define.site_right then
        if playerCount == 2 then
            armature:setPosition(cc.p(display.cx, display.cy + 260))
        else
            armature:setPosition(cc.p(display.cx + 260, display.cy))
        end
    elseif site == Define.site_other then
        if playerCount == 3 then
            armature:setPosition(cc.p(display.cx - 190, display.cy))
        else
            armature:setPosition(cc.p(display.cx, display.cy + 170))
        end
    elseif site == Define.site_left then
        armature:setPosition(cc.p(display.cx - 260, display.cy))
    else
        armature:setPosition(cc.p(display.cx, display.cy))
    end
end

--[[
-- @brief  移最后一个麻将函数
-- @param  void
-- @return void
--]]
function PlayerPanelBase:moveLastMj()

end

--定缺结果
function PlayerPanelBase:onDingqueResult(result)

end

--[[
-- @brief  打牌能标志函数
-- @param  void
-- @return remainder = 1 不可以打牌 remainder = 2 可以打牌
--]]
function PlayerPanelBase:isCanPlayCard(myCardsNum)
    local remainder = myCardsNum % 3

    -- 获取花牌
    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local flowers = playSystem:getGameStartDatas().isFlowers
    local hasFlower = false
    -- 遍历手牌判断是否有花牌
    if flowers and #flowers > 0 and self.handCardsObjs and #self.handCardsObjs > 0 then
        for i = 1, #self.handCardsObjs do
            local cardValue = self.handCardsObjs[i]:getValue()
            for j=1, #flowers do
                if cardValue == flowers[j] then
                    Log.i("hasFlower")
                    hasFlower = true
                    remainder = 1
                    break
                end
            end
        end
    end
    -- -- 有花牌的话判断动作状态
    if hasFlower then
        if MjMediator:getInstance():getStateManager():getCurState() == enGamePlayingState.STATE_ACT_ANIMATE then
            Log.i("inAction")
            remainder = 1
        end
    end

    return remainder == enHandCardRemainder.CAN_PLAY
end

return PlayerPanelBase
