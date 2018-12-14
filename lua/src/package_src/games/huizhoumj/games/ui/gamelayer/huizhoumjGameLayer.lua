--
-- Author: Jinds
-- Date: 2017-06-26 11:51:39
--


local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
local huizhoumjGameLayer = class("huizhoumjGameLayer", GameLayer)

local UIFactory         = require "app.games.common.ui.UIFactory"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"

--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function huizhoumjGameLayer:onShowUI()
    if self._playLayer then
        for i = 1, #self.layers do
            if self.layers[i] == self._playLayer then
                table.remove(self.layers, i)
            end
        end
        self._playLayer:onClose()
        self._playLayer:removeFromParent()
    end

    self._playLayer = UIFactory.createGamePlayLayer(_gameType)
    table.insert(self.layers, self._playLayer)
    self._playLayer:addTo(self, self._playLayerZOrder)
    self._playLayer:setDelegate(self);
    self._playLayer:setGameLayer(self)

    -- 操作层
    if self.operateLayer then
        self.operateLayer:onClose()
        self.operateLayer:removeFromParent()
        self.operateLayer = nil
    end
    self.operateLayer = UIFactory.createOperateBtnLayer(_gameType)
    self.operateLayer:addTo(self, self._uiLayerZOrder)
       
    --绘制游戏界面ui
    if self.m_gameUIView then
        self.m_gameUIView.m_pWidget:removeFromParent()
        self.m_gameUIView:onClose();
        self.m_gameUIView = nil
    end
    
    self.m_gameUIView = UIFactory.createGameUIView(_gameType)
    self.m_gameUIView.m_pWidget:addTo(self, self._uiLayerZOrder)
    self.m_gameUIView:setDelegate(self);
    self.m_gameUIView:onInit()

    -- 补花层
    if self.m_flowerNode then
        self.m_flowerNode.m_pWidget:removeFromParent()
        self.m_flowerNode = nil
    end
    self.m_flowerNode = UIFactory.createPlayerFlower(_gameType)
    self.m_flowerNode.m_pWidget:addTo(self)
    self.m_flowerNode:setDelegate(self)
    self.m_flowerNode:onInit()

    -- 创建头像
    self:createHead()

    -- 操作层
    if self.animLayer then
        self.animLayer:onClose()
        self.animLayer:getView():removeFromParent()
        self.animLayer = nil
    end
    if self.animLayer == nil then
        self.animLayer = AnimLayer:new()
        self.animLayer:getView():addTo(self, self._animLayerZOrder)
    end 
end


--[[
-- @brief  游戏恢复函数
-- @param  void
-- @return void
--]]
function huizhoumjGameLayer:onGameResume()
    -- 等待收到恢复对局消息时显示ui
    self:onShowUI()

    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local checkGameStart = playSystem:checkGameStart()
    self._bgLayer:onGameResume()
    print("onGameResume=================>>>>", checkGameStart)
    if checkGameStart then
        local startData = playSystem:getGameStartDatas()
        
        MjProxy:getInstance():get_gameChatTxtCfg()
        self._playLayer:onGameResume()
        self.operateLayer:onShowActions(#startData.closeCards % 3 ~= 2)
        self._opOverTimeTip:onGameResume()

        playSystem:setMjDistrubuteEnd(true)
        
        -- 恢复对局显示花牌
        local players   = self.gameSystem:gameStartGetPlayers()
        for i=1, #players do
            local flowers = players[i]:getProp(enCreatureEntityProp.FLOWER)
            for t=1, #flowers do
                self.m_flowerNode:setBuhuaNumber(i, flowers[t])
            end
            -- 听状态
            local tingState  = players[i]:getState(enCreatureEntityState.TING)
            if tingState == enTingStatus.TING_TRUE then
                self.m_playerHeadNode:showTinPaiOp(i, true)
            elseif tingState == enTingStatus.TING_FALSE then
                self.m_playerHeadNode:showTinPaiOp(i, false)
            end
            ----------------------------------------------------------add1---------------

            local isBDG = players[i]:getProp(enCreatureEntityProp.XIA_PAO_NUM)
            self.m_playerHeadNode:showBaoDaGeOp(i, isBDG)
            --------------------------------------------------------------
            self.m_playerHeadNode:refreshFortune(i)
        end

        if self.m_gameUIView then
            self.m_gameUIView:checkChahuStatus();
        end

        self:showDingqueOperation();
    end

    self:performWithDelay(function ()
        --恢复牌局显示已经选择的结果
        self:initLaPaoZuoDiOperation()
        end, 0.1)
    
    self:resumeEvent()
end


--[[
-- @brief  拿牌函数
-- @param  void
-- @return void
--]]
function huizhoumjGameLayer:onDispenseCard(packageInfo)
    Log.i("------GameLayer:onDispenseCard")
    local info = packageInfo
    local clock = self._bgLayer._clock
    SoundManager.playEffect("fapai", false);
    self._playLayer:onDispenseCard()
    self._bgLayer:onDispenseCard()
	self._opOverTimeTip:onDispenseCard()

    --查胡状态
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
    end

    local dispenseData  = self.gameSystem:getDispenseCardDatas()
    print("<jinds>: self.dispenseCardDatas.maCard " , dispenseData.maCard)
    if dispenseData.maCard and dispenseData.maCard > 0 then
        local site  = self.gameSystem:getPlayerSiteById(dispenseData.userId)
        self.m_flowerNode:setBuhuaNumber(site, dispenseData.maCard)
    end

    -- -- 拿牌结束
    -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
end



-- --[[
-- -- @brief  游戏结束函数
-- -- @param  void
-- -- @return void
-- --]]
-- function huizhoumjGameLayer:onGameOver()
--     Log.i("处理结算逻辑")
--     local data = self.gameSystem:getGameOverDatas()
--     assert(data ~= nil)
--     --停止背景音乐
--     audio.stopMusic()
--     local clock = self._bgLayer._clock
--     if clock then
--         clock:stoptUpdate()
--     end
-- 	self._opOverTimeTip:stopOverTimeTip()

--     local showResult = false
--     if data.winType == 3 then --流局了
--         showResult = true
--         SoundManager.playEffect("liuju", false);
--         ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/liuju.csb")
--         local armature = ccs.Armature:create("liuju")
--         armature:getAnimation():play("Animation1")
--         armature:performWithDelay(function()
--                 armature:removeFromParent(true)
--             end, 0.7);
--         armature:setPosition(cc.p(display.cx, display.cy))
--         self:addChild(armature,5)

--         ---------- 流局不显示流局界面录像回放相关-----------------------------
--         if VideotapeManager.getInstance():isPlayingVideo() then
--             return      
--         end
--         ----------------------------------------------------

--         -- 结算界面
--         local delayTime = 1.5
--         local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
--         layer:addTo(self)
--         -- Log.i("GameLayer:on_msgGameOver winnerSite="..winnerSite..';winType='..data.winType)
--         self:performWithDelay(function ()
--             -- 重设头像位置
--             print("sunbinLog ****** setHeadSrcPos")
--             self.m_playerHeadNode:setHeadSrcPos()
--             -- 移除指示
--             self._playLayer:removeIndicator()
--             layer:removeFromParent()
--                 self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
--                 self.m_gameOverDialogUI:setDelegate(self);   
--                 -- 隐藏操作
--                 self.operateLayer:onHide()
--             --朋友开房逻辑特殊处理
--             -- if(kFriendRoomInfo:isFriendRoom()) then
--             -- else            
--             -- end
        
--         end, delayTime)

--     else
--         local startdata = self.gameSystem:getGameStartDatas()

--         print("<jinds>: horse card----------------- " )
--         dump(startdata.horseCards)
--         --翻马 结算界面
--         local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
--         layer:addTo(self)
--         self:performWithDelay(function ()
--             if #startdata.horseCards > 0 then --是否显示翻马UI false:不用显示, true：要显示
--                 local tmpFanUI = UIManager:getInstance():pushWnd(MJFanma);
--                 tmpFanUI.m_pWidget:performWithDelay(function ()
--                     UIManager:getInstance():popWnd(MJFanma);
--                     self.m_playerHeadNode:setHeadSrcPos()
--                     -- 移除指示
--                     self._playLayer:removeIndicator()
--                     layer:removeFromParent()
--                     local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
--                     gameOverDialogUI:setDelegate(self);
            
--                 end, 3)
--             else
--                 local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
--                 gameOverDialogUI:setDelegate(self);     
--             end
--         end,0.25)        

--     end

--     -- -- 亮出其他玩家的牌
--     local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

--     -- 结算界面
--     local delayTime = 1.5
--     -- 游戏层
--     self._playLayer:onGameOver(delayTime)
--     --查胡提示
--     local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
--     gamePlaySystem:gameStartLogic_setHuMjs();
--     if self.m_gameUIView then
--         self.m_gameUIView:checkChahuStatus();
--     end
--     -- 补花层
--     self.m_flowerNode:onGameOver()
       
-- end

--[[
-- @brief  游戏动作函数
-- @param  void
-- @return void
--]]
function huizhoumjGameLayer:onAction()
    self._playLayer:onAction()
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    
    -- 补花操作
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    local site  = self.gameSystem:getPlayerSiteById(operateSysData.userid)
    
    if operateSysData.actionID == enOperate.OPERATE_BU_HUA then
        self.m_flowerNode:setBuhuaNumber(site, operateSysData.actionCard)
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

    --------------------------------------add------------------------------------
    elseif  operateSysData.actionID == enOperate.OPERATE_BAO_DA_GE then
        -- and operateSysData.userid == MjProxy.getInstance():getMyUserId() then
        self.m_playerHeadNode:showBaoDaGeOp(site, true)

        -- self.gameSystem:gameStartLogic_setHuMjs();

        local tingCards = operateSysData.tingCards or {}
        Log.i("------huizhoumjGameLayer:onAction OPERATE_BAO_DA_GE", tingCards);
        -- if #tingCards > 0 then
            
            self.gameSystem:gameStartLogic_setHuMjs(tingCards);
        -- end
    end             
    --------------------------------------------------------------------------------
end



return huizhoumjGameLayer