--
-- Author: Your Name
-- Date: 2017-05-23 20:06:43
--
local Define            = require "app.games.common.Define"

local UIFactory         = require "app.games.common.ui.UIFactory"
local GameUIView        = require "app.games.common.ui.bglayer.GameUIView"
local PlayerHead        = require "app.games.common.ui.bglayer.PlayerHead"
local PlayerFlower      = require "app.games.common.ui.gamelayer.PlayerFlower"
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"

local commonGameLayer = import("app.games.common.ui.gamelayer.GameLayer")
local shantoumjGameLayer = class("shantoumjGameLayer", commonGameLayer)

function shantoumjGameLayer:ctor()
	shantoumjGameLayer.super.ctor(self,"shantoumjGameLayer")

end

--[[
-- @brief  游戏动作函数
-- @param  void
-- @return void
--]]
function shantoumjGameLayer:onAction()
    self._playLayer:onAction()
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    
    -- 补花操作
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    local site  = self.gameSystem:getPlayerSiteById(operateSysData.userid)
    
    if operateSysData.actionID == enOperate.OPERATE_BU_HUA then
        if operateSysData.buyHorses and #operateSysData.buyHorses > 0 then
            print("sunbinLog:---------shantoumjGameLayer")
            for k, v in pairs(operateSysData.buyHorses)  do
                self.m_flowerNode:setBuhuaNumber(site, v)
            end
            local remainCards = SystemFacade:getInstance():getRemainPaiCount() - #operateSysData.buyHorses
            SystemFacade:getInstance():setRemainPaiCount(remainCards)
            self._bgLayer:refreshRemainCount()
        end
    elseif operateSysData.actionID == enOperate.OPERATE_TING 
        or operateSysData.actionID == enOperate.OPERATE_TIAN_TING then    -- 更新听的状态

        local player = self.gameSystem:gameStartGetPlayerByUserid(operateSysData.userid) 
        local tingState  = player:getState(enCreatureEntityState.TING)
        if tingState == enTingStatus.TING_TRUE then
            self.m_playerHeadNode:showTinPaiOp(site, true)

            --是否需要报听后才翻出暗杠牌的特殊操作
            if _isTingShowAnGangCards and _isTingShowAnGangCards==true then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_SHOW_ANGANG_NTF, site, true)
            end

        elseif tingState == enTingStatus.TING_FALSE then
            self.m_playerHeadNode:showTinPaiOp(site, false)
        end
    elseif operateSysData.actionID == enOperate.OPERATE_CANCEL_TING then
        self.m_playerHeadNode:showTinPaiOp(site, false)
        if site == enSiteDirection.SITE_MYSELF then
            if self.m_gameUIView then
                self.m_gameUIView:checkChahuStatus();
            end
        end
    elseif  operateSysData.actionID == enOperate.OPERATE_CHI 
        and operateSysData.userid == MjProxy.getInstance():getMyUserId() then
        self.gameSystem:gameStartLogic_setHuMjs();  --自己吃的时候把胡牌提示刷新一遍
        if self.m_gameUIView then
            self.m_gameUIView:checkChahuStatus();
        end
    end             
end

--[[
-- @brief  拿牌函数
-- @param  void
-- @return void
--]]
function shantoumjGameLayer:onDispenseCard(packageInfo)
    Log.i("------GameLayer:onDispenseCard")
    local info = packageInfo
    local clock = self._bgLayer._clock
    SoundManager.playEffect("fapai", false);
    self._playLayer:onDispenseCard()
    self._bgLayer:onDispenseCard()
    self._opOverTimeTip:onDispenseCard()

    local stayCards = 0
    local NotStayCards = kFriendRoomInfo:isHavePlayByName("jiangmabuliupai")
    if not NotStayCards then
        if kFriendRoomInfo:isHavePlayByName("jm2") then
            stayCards = 2 
        elseif kFriendRoomInfo:isHavePlayByName("jm4") then
            stayCards = 4
        elseif kFriendRoomInfo:isHavePlayByName("jm5") then
            stayCards = 5
        elseif kFriendRoomInfo:isHavePlayByName("jm6") then
            stayCards = 6
        elseif kFriendRoomInfo:isHavePlayByName("jm7") then
            stayCards = 7
        elseif kFriendRoomInfo:isHavePlayByName("jm8") then
            stayCards = 8
        elseif kFriendRoomInfo:isHavePlayByName("jm9") then
            stayCards = 9
        elseif kFriendRoomInfo:isHavePlayByName("jm10") then
            stayCards = 10
        end
    end
    local count = SystemFacade:getInstance():getRemainPaiCount()
    if count < 1+stayCards then
        --把手牌全制为不能打出状态
        local myCards    = self._playLayer.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
    end

    --查胡状态
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
    end

    -- -- 拿牌结束
    -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
end


return shantoumjGameLayer