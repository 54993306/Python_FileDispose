local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")

local FanMaAnimation = require "package_src.games.maomingmj.ui.fanma.FanMaAnimation"

local GamePlayLayer     = require "package_src.games.maomingmj.ui.playlayer.BranchGamePlayLayer"

local BgLayer        = require "package_src.games.maomingmj.ui.bglayer.BranchBgLayer"

local BranchGameLayer = class("BranchGameLayer",GameLayer)

function BranchGameLayer:ctor()
	BranchGameLayer.super.ctor(self)
    self:createBgLayer()
end
function BranchGameLayer:createBgLayer()
    if self._bgLayer then
        for i = 1, #self.layers do
            if self.layers[i] == self._bgLayer then
                table.remove(self.layers, i)
            end
        end
        self._bgLayer:onClose()
    	self._bgLayer:removeFromParent()
    end

	--用工厂去创建,可以继承实现相关功能
    self._bgLayer = BgLayer.new()
    table.insert(self.layers, self._bgLayer)
    self._bgLayer:addTo(self)
end
--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function BranchGameLayer:onShowUI()
    self.super.onShowUI(self)

    if self._playLayer then
        for i = 1, #self.layers do
            if self.layers[i] == self._playLayer then
                table.remove(self.layers, i)
            end
        end
        self._playLayer:onClose()
        self._playLayer:removeFromParent()
    end

    self._playLayer = GamePlayLayer.new()
    table.insert(self.layers, self._playLayer)
    self._playLayer:addTo(self, self._playLayerZOrder)
    self._playLayer:setDelegate(self);
    self._playLayer:setGameLayer(self)

end
--[[
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function BranchGameLayer:onGameOver()
    package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
    package.loaded["package_src.games.maomingmj.ui.gameover.BranchFriendOverView"] = nil
    FriendOverView = require "package_src.games.maomingmj.ui.gameover.BranchFriendOverView"
--    self.super.onGameOver(self)
    --如果已经结束游戏了则不需要走小结算界面
    
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
    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

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

    if data.huCount > 1 then --一炮多响
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
    self:performWithDelay(function ()
        if MjMediator.getInstance():gameOverIsEnd() then
            Log.i("牌局已经解散了.....")
            return
        end
        local time = 0
        if #data.maList > 0 then
            self:drawFanMa(data.maList)
            time = 0.5+#data.maList[1].fanma*0.32
        end
        self:performWithDelay(function ()
            -- 重设头像位置
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);   
            -- 隐藏操作
            self.operateLayer:onHide()
        end,time)
    end, delayTime)
end

function BranchGameLayer:drawFanMa(data)
    self.m_fanma = FanMaAnimation.new(data,false):addTo(self:getParent(),20)
end
return BranchGameLayer