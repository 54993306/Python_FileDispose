

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
--local GameUIView        = require ("package_src.games.jiangmengangganghumj.games.ui.gameover.changepoint")
local FanMaAnimation = require "package_src.games.jiangmengangganghumj.games.ui.fanma.FanMaAnimation"
--jmplayLayer = require("package_src.games.jiangmengangganghumj.games.ui.playlayer.BranchGamePlayLayer") ---- 翻马actionId

local jiangmengangganghumjGameLayer = class("jiangmengangganghumjGameLayer", GameLayer)

function jiangmengangganghumjGameLayer:ctor()
    self.super.ctor(self)
end

--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function jiangmengangganghumjGameLayer:onShowUI()
    self.super.onShowUI(self)
    --self:createGameUIView()
end

--function jiangmengangganghumjGameLayer:createGameUIView()
----     --绘制游戏界面ui
--if self._playLayer then
--        for i = 1, #self.layers do
--            if self.layers[i] == self._playLayer then
--                table.remove(self.layers, i)
--            end
--        end
--        self._playLayer:onClose()
--        self._playLayer:removeFromParent()
--    end

--    self._playLayer = jmplayLayer.new()
--    table.insert(self.layers, self._playLayer)
--    self._playLayer:addTo(self, self._playLayerZOrder)
--    self._playLayer:setDelegate(self);
--    self._playLayer:setGameLayer(self)
--end





function jiangmengangganghumjGameLayer:onAction()
    self.super.onAction(self)
    --获取操作系统中吃碰杠等牌局数据数据
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    self:updatePlayScore(operateSysData)
end

function jiangmengangganghumjGameLayer:updatePlayScore(operateData)
Log.i("jiangmengangganghumjGameLayer:updatePlayScore.........................",operateData)
    if operateData.actionID == enOperate.OPERATE_AN_GANG 
        or operateData.actionID == enOperate.OPERATE_MING_GANG 
        or operateData.actionID == enOperate.OPERATE_JIA_GANG then
        if not operateData.losIds then
            return
        end
        local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        for i,v in pairs(operateData.losIds) do
            local operateSite   = gamePlaySystem:getPlayerSiteById(v)
            local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(operateSite)
            local strMoney = playerObj:getProp(enCreatureEntityProp.FORTUNE)
            Log.i("v.....",v,operateSite,strMoney,operateData.score)
            playerObj:setProp(enCreatureEntityProp.FORTUNE,strMoney-operateData.score)
            self.m_playerHeadNode:refreshFortune(operateSite)
            self:drawScoreAction(operateSite,-operateData.score)
        end
        local actionSite   = gamePlaySystem:getPlayerSiteById(operateData.userid)
        local actionPlayerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(actionSite)
        local actionstrMoney = actionPlayerObj:getProp(enCreatureEntityProp.FORTUNE)
        Log.i("actionChaozuo.....",operateData.userid,operateSite,strMoney,operateData.score)
        local score = operateData.score
        if operateData.actionID == enOperate.OPERATE_MING_GANG or enOperate.OPERATE_JIA_GANG  then
          score = operateData.score*(#(operateData.losIds))
        end
        
        
        actionPlayerObj:setProp(enCreatureEntityProp.FORTUNE,actionstrMoney+score)
        self.m_playerHeadNode:refreshFortune(actionSite)
        self:drawScoreAction(actionSite,score)
    end
end
function jiangmengangganghumjGameLayer:drawScoreAction(site,score)
    local point = nil
    if score < 0 then
        point = cc.Label:createWithBMFont("games/common/gameCommon/sub_num.fnt", score)
    else
        point = cc.Label:createWithBMFont("games/common/gameCommon/add_num.fnt", "+"..score)
    end
    local playerHead = self.m_playerHeadNode:getHead(site)
    point:setAnchorPoint(cc.p(0.5, 0.5))
    playerHead:addChild(point, 10)
    point:setScale(1.5)
    if site == enSiteDirection.SITE_MYSELF or site == enSiteDirection.SITE_LEFT then
        point:setPosition(cc.p(200,60))
    else
        point:setPosition(cc.p(-200,60))
    end
    local cf = cc.CallFunc:create(function()
        point:removeFromParent()
        point = nil
    end)
    local move = cc.EaseOut:create(cc.MoveTo:create(0.5,cc.p(80,50)),0.5)
    local sequence = cc.Sequence:create(move,cf)
    point:runAction(sequence)
end
function jiangmengangganghumjGameLayer:onGameOver()
    package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
    package.loaded["package_src.games.jiangmengangganghumj.games.ui.gameover.jiangmengangganghumjFriendOverView"] = nil
    FriendOverView = require "package_src.games.jiangmengangganghumj.games.ui.gameover.jiangmengangganghumjFriendOverView"
    --self.super.onGameOver(self)
     local data = self.gameSystem:getGameOverDatas()
    Log.i("jiangmengangganghumjGameLayer:onGameOver............................................",data)
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

    if data.huCount > 1 then --一炮多响
        showResult = true
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        local armature = ccs.Armature:create("yipaoduoxiang")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
                 armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,50)
    end

Log.i("data.maList.fanma........",data.ma.fanMa)
 if data.ma.fanMa   then
        self:performWithDelay(function ()
            local maList = {}
            maList = data.ma
            Log.i("data.maList........",maList)
            self.m_fanma = FanMaAnimation.new(maList,false):addTo(self:getParent(),20)
            mjs = maList.fanMa or 0
            delayTime =( 0.5) +#mjs*0.32
            end, 0.7)

            self:performWithDelay(function ()
            self.m_fanma:removeFromParent()
            -- 重设头像位置
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);   
                -- 隐藏操作
                self.operateLayer:onHide()        
        end,(2.7))--+(#(data.ma.fanMa or {})*0.32)
else

    self:performWithDelay(function ()
            --self.m_fanma:removeFromParent()
            -- 重设头像位置
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);   
                -- 隐藏操作
                self.operateLayer:onHide()
            
    end,(0.7+(#(data.ma.fanMa or {})*0.32)))
end
end
return jiangmengangganghumjGameLayer