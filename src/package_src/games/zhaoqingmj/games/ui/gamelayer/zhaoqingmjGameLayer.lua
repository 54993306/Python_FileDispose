--
-- Author: Jinds
-- Date: 2017-06-26 11:51:39
--


local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
local zhaoqingmjGameLayer = class("zhaoqingmjGameLayer", GameLayer)

local UIFactory         = require "app.games.common.ui.UIFactory"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"

--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function zhaoqingmjGameLayer:onShowUI()
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
    print("<jinds>:call factory opeBtnLayer")
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
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function zhaoqingmjGameLayer:onGameOver()
    Log.i("处理结算逻辑")
    local data = self.gameSystem:getGameOverDatas()
    assert(data ~= nil)
    --停止背景音乐
    audio.stopMusic()
    local clock = self._bgLayer._clock
    if clock then
        clock:stoptUpdate()
    end
    self._opOverTimeTip:stopOverTimeTip()

    local showResult = false
    if data.winType == 3 then --流局了
        showResult = true
        SoundManager.playEffect("liuju", false);
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
        local armature = ccs.Armature:create("CpghAnimation")
        armature:getAnimation():play("AnimationLIUJV")
        armature:performWithDelay(function()
                armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)

        ---------- 流局不显示流局界面录像回放相关-----------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            return      
        end
        ----------------------------------------------------
    end
    -- self._playLayer:setPlayerTouchEnabled(false)

    -- local actionList = self._playLayer:getChildByTag(Define.e_tag_player_layer_action)
    -- if actionList then
    --     actionList:removeFromParent()
    --     actionList = nil
    -- end

    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

    -- for i=1, #self.gameSystem:gameStartGetPlayers() do
    --     local lastCard = 0
    --     if i == winnerSite then
    --         lastCard = data.score[i].lastCard
    --     end
        
    --     self._playLayer:gameEndMingPai(i, data.score[i].closeCards, lastCard)
    -- end
    -- 
    -- 结算界面
    local delayTime = 1.5
    -- 游戏层
    self._playLayer:onGameOver(delayTime)
    --查胡提示
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    gamePlaySystem:gameStartLogic_setHuMjs();
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    -- 补花层
    self.m_flowerNode:onGameOver()
    

    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    layer:addTo(self)
    Log.i("GameLayer:on_msgGameOver winnerSite="..winnerSite..';winType='..data.winType)
    
    local isPaoPei = false
    if winnerSite == 1 then
        showResult = true
        local pon = data.score[winnerSite].policyName
        if pon ~= nil and #pon> 0 then 
            for i=1, #pon do
                if pon[i] == "跑配" then
                    isPaoPei = true
                end
            end
        end
    end
-------------------------------------------sub-----------------------------
--肇庆麻将不要一炮多响 （多家抢杠和的情况）
--[[   if data.huCount > 1 then --一炮多响
        showResult = true

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        local armature = ccs.Armature:create("yipaoduoxiang")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
                 armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)
    end
    --]]
---------------------------------------------------------------------------------------------------------
    -- if isPaoPei == true and MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
    --     delayTime = 3
    --     self:performWithDelay(function ()
    --         local paoPeiAnimLayer = PaoPeiAnimLayer.new()
    --         cc.Director:getInstance():getRunningScene():addChild(paoPeiAnimLayer)
    --         paoPeiAnimLayer:performWithDelay(function ()
    --             paoPeiAnimLayer:removeFromParent()
    --         end, 2)
    --     end, 1)        

    -- end

    self:performWithDelay(function ()
        -- 重设头像位置
        self.m_playerHeadNode:setHeadSrcPos()
        -- 移除指示
        self._playLayer:removeIndicator()
        layer:removeFromParent()
  --       self.m_gameOverDialogUI = GameOverDialog.new()
        -- cc.Director:getInstance():getRunningScene():addChild(self.m_gameOverDialogUI);

            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);   
            -- 隐藏操作
            self.operateLayer:onHide()
        --朋友开房逻辑特殊处理
        if(kFriendRoomInfo:isFriendRoom()) then
            -- local tmpData={}
            -- tmpData.gameoverUI = self.m_gameOverDialogUI;
            -- local tmpScene = MjMediator:getInstance():getScene();
            -- tmpScene.m_friendOpenRoom:onShowGameOverUI(tmpData); 

        else
            -- Log.i("结算了.....")
            -- local roomInfo = MjProxy:getInstance():getRoomInfo()
            -- if kUserInfo:getMoney() < roomInfo.thM and roomInfo.ta == 1 and kSubsidyInfo:isCanSubsidy() then
            --     self:performWithDelay(function()
            --         UIManager:getInstance():pushWnd(SubsidyWnd);
            --     end, 0.5);
            -- end            
        end
        
    end, delayTime)
    
end


--[[
-- @brief  拿牌函数
-- @param  void
-- @return void
--]]
function zhaoqingmjGameLayer:onDispenseCard(packageInfo)
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
---------------------------------------add-----------------------------------------
    local dispenseData  = self.gameSystem:getDispenseCardDatas()
    print("<jinds>: self.dispenseCardDatas.maCard " , dispenseData.maCard)
    if dispenseData.maCard and dispenseData.maCard > 0 then
        local site  = self.gameSystem:getPlayerSiteById(dispenseData.userId)
        print("<jinds>： site is : ", site)
        self.m_flowerNode:setBuhuaNumber(site, dispenseData.maCard)
    end
-----------------------------------------------------------------------------------

    -- -- 拿牌结束
    -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
end





return zhaoqingmjGameLayer