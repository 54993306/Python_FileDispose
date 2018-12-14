

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
local BranchGamePlayLayer = require("package_src.games.guangdongyibaizhangmj.games.ui.playlayer.BranchGamePlayLayer")
-- local GameUIView        = require ("package_src.games.guangdongyibaizhangmj.games.ui.gameover.changepoint")

 -- FriendOverView = require("package_src.games.guangdongyibaizhangmj.games.ui.gameover.guangdongyibaizhangmjFriendOverView")
local FanMaAnimation = require "package_src.games.guangdongyibaizhangmj.games.ui.fanma.FanMaAnimation"
local guangdongyibaizhangmjGameLayer = class("guangdongyibaizhangmjGameLayer", GameLayer)

function guangdongyibaizhangmjGameLayer:ctor()
    self.super.ctor(self)
end

--[[
-- @brief  ÏÔÊ¾UIº¯Êý
-- @param  void
-- @return void
--]]
function guangdongyibaizhangmjGameLayer:onShowUI()
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

        self._playLayer = BranchGamePlayLayer.new()
    table.insert(self.layers, self._playLayer)
    self._playLayer:addTo(self, self._playLayerZOrder)
    self._playLayer:setDelegate(self);
    self._playLayer:setGameLayer(self)
end

function guangdongyibaizhangmjGameLayer:onGameStart()
    self.super.onGameStart(self)

end

function guangdongyibaizhangmjGameLayer:onGameResume()
    self.super.onGameResume(self)
    -- self:onFanMa()
end
function guangdongyibaizhangmjGameLayer:onFanMa()
    local maList = 
    {
        [1] = 
        {
            ["zhongma"] = 
            {
                -- [1] = 41;
                -- [2] = 45;
            };
            ["userid"] = 1103579;
            ["fanma"] = 
            {
                [1] = 41;
                [2] = 45;
                [3] = 33;
                [4] = 22;

            };
        };
        
    };
    self.m_fanma = FanMaAnimation.new(maList):addTo(self:getParent(),20)
end

function guangdongyibaizhangmjGameLayer:onAction()
    self.super.onAction(self)
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    self:updatePlaydiffScore(operateSysData)
end

function guangdongyibaizhangmjGameLayer:updatePlaydiffScore(operateData)
    if operateData.actionID == enOperate.OPERATE_AN_GANG 
        or operateData.actionID == enOperate.OPERATE_MING_GANG 
        or operateData.actionID == enOperate.OPERATE_JIA_GANG then
        if operateData.userIds == nil then
            return
        end
        local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        for i,v in pairs(operateData.userIds) do
            local operateSite   = gamePlaySystem:getPlayerSiteById(v)
            local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(operateSite)
            local strMoney = playerObj:getProp(enCreatureEntityProp.FORTUNE)
            playerObj:setProp(enCreatureEntityProp.FORTUNE,strMoney-operateData.diffScore)
            self.m_playerHeadNode:refreshFortune(operateSite)
            self:drawdiffScoreAction(operateSite,-operateData.diffScore)
        end
        local actionSite   = gamePlaySystem:getPlayerSiteById(operateData.userid)
        local actionPlayerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(actionSite)
        local actionstrMoney = actionPlayerObj:getProp(enCreatureEntityProp.FORTUNE)
        local diffScore = operateData.diffScore
        if operateData.actionID == enOperate.OPERATE_AN_GANG or operateData.actionID == enOperate.OPERATE_JIA_GANG then
            diffScore = operateData.diffScore*(#(operateData.userIds))
        end
        actionPlayerObj:setProp(enCreatureEntityProp.FORTUNE,actionstrMoney+diffScore)
        self.m_playerHeadNode:refreshFortune(actionSite)
        self:drawdiffScoreAction(actionSite,diffScore)
    end

end
function guangdongyibaizhangmjGameLayer:drawdiffScoreAction(site,diffScore)
    local point = nil
    if diffScore < 0 then
        point = cc.Label:createWithBMFont("hall/font/green_num.fnt", diffScore)
    else
        point = cc.Label:createWithBMFont("hall/font/yellow_num.fnt", "+"..diffScore)
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
function guangdongyibaizhangmjGameLayer:onGameOver()
    
    package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
    package.loaded["package_src.games.guangdongyibaizhangmj.games.ui.gameover.BranchFriendOverView"] = nil
    FriendOverView = require "package_src.games.guangdongyibaizhangmj.games.ui.gameover.BranchFriendOverView"
    
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
        -- self.m_fanma:removeFromParent()

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

    local yipaoduoxiangDelay = 0
    if data.huCount > 1 then --一炮多响
        yipaoduoxiangDelay = 0.7
        showResult = true
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        local armature = ccs.Armature:create("yipaoduoxiang")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
                 armature:removeFromParent(true)
            end, yipaoduoxiangDelay);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)
    end

    local maList = data.maList
    local isHasMa = false
    for i, v in pairs(data.maList) do
        if v and v.showFlag == 1 then
            isHasMa = true
            break
        end
    end
    -- for i, v in pairs(data.score) do
    --     if #v.maList > 0 then
    --         maList = v.maList
    --     end
    -- end


    if isHasMa then
        delayTime = 2.5
        self:performWithDelay(function ()
            self.m_fanma = FanMaAnimation.new(maList):addTo(self:getParent(),20)
        end, yipaoduoxiangDelay)
    
        self:performWithDelay(function ()
            if self.m_fanma then
                self.m_fanma:removeFromParent()
                self.m_fanma = nil
            end
            -- 重设头像位置
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);   
                -- 隐藏操作
                self.operateLayer:onHide()
            
        end, delayTime + yipaoduoxiangDelay)
    else
        self:performWithDelay(function ()
        if self.m_fanma then
        
        end
        -- 重设头像位置
        self.m_playerHeadNode:setHeadSrcPos()
        -- 移除指示
        self._playLayer:removeIndicator()
        layer:removeFromParent()
            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);   
            -- 隐藏操作
            self.operateLayer:onHide()
        
    end, delayTime)
        end
end
return guangdongyibaizhangmjGameLayer