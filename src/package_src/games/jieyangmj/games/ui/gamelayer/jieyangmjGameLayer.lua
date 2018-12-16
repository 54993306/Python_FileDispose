--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
local Define            = require "app.games.common.Define"
local SetDialog         = require "app.games.common.ui.set.SetDialog"
local PaoPeiAnimLayer   = require ("app.games.common.ui.paopei.PaoPeiAnimLayer")
local UIFactory         = require "app.games.common.ui.UIFactory"
-- local GamePlayLayer     = require "app.games.common.ui.playlayer.GamePlayLayer"
local GamePlayLayer     = require "package_src.games.jieyangmj.games.ui.playlayer.jieyangmjGamePlayLayer"
-- local GameUIView        = require "app.games.common.ui.bglayer.GameUIView"
local jieyangGameUIView        = require "package_src.games.jieyangmj.games.ui.bglayer.jieyangmjGameUIView"
local PlayerHead        = require "app.games.common.ui.bglayer.PlayerHead"
-- local PlayerFlower      = require "app.games.common.ui.gamelayer.PlayerFlower"
local PlayerFlower      = require "package_src.games.jieyangmj.games.ui.gamelayer.jieyangmjPlayerFlower"
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"

-- local MJFanma = require "package_src.games.jieyangmj.custom.MJFanMa1"
local MJFanma= require("app.games.common.ui.gameover.MJFanMa")
local fanMaimaWnd = require "package_src.games.jieyangmj.custom.fanMaimaWnd"

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
local jieyangGameLayer  = class("jieyangGameLayer", GameLayer)



--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function jieyangGameLayer:onShowUI()
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
    self.m_gameUIView = jieyangGameUIView:new()
    self.m_gameUIView.m_pWidget:addTo(self, self._uiLayerZOrder)
    self.m_gameUIView:setDelegate(self);
    self.m_gameUIView:onInit()

    -- 补花层
    if self.m_flowerNode then
        self.m_flowerNode.m_pWidget:removeFromParent()
        self.m_flowerNode = nil
    end
    self.m_flowerNode = PlayerFlower.new()
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

function jieyangGameLayer:onAction()

    if self._playLayer then
      self._playLayer:onAction()
    end

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
    end             
end


function jieyangGameLayer:onContinueGame()
    if self._playLayer then
        for i = 1, #self.layers do
            if self.layers[i] == self._playLayer then
                table.remove(self.layers, i)
            end
        end
        self._playLayer:onClose()
        self._playLayer:removeFromParent()
        self._playLayer = nil;
    end

    -- 操作层
    if self.operateLayer then
        self.operateLayer:onClose()
        self.operateLayer:removeFromParent()
        self.operateLayer = nil
    end
end

-- function jieyangGameLayer:showLaiziMj()
--     local turn = require("app.games.common.custom.MJTurnLaizigou")
--     local turnLaizigou = turn.new(MjProxy:getInstance():getLaizi())
--     turnLaizigou:addTo(self,10)
-- end

function jieyangGameLayer:onGameOver()
 --把手牌全制为不能打出状态
    local myCards    = self._playLayer.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    for i=1,#myCards do
        myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
    end


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
    data.hasF = true

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
        -- 结算界面
        local delayTime = 1.5
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
        layer:addTo(self)
        self:performWithDelay(function ()
            -- 重设头像位置
            --print("sunbinLog ****** setHeadSrcPos")
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);   
                -- 隐藏操作
                self.operateLayer:onHide()
        
        end, delayTime)
    else
        --结算界面
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
        layer:addTo(self)
        local  haveMaima = false
        for i = 1,#data.score do
            if data.score[i].maCards and #data.score[i].maCards>0 then
                haveMaima = true
                break
            end
        end
        -- 翻马之后买马
         self:performWithDelay(function()
             if data.fanma and #data.fanma > 0 then --是否显示翻马UI false:不用显示, true：要显示
                -- local tmpFanUI = UIManager:getInstance():pushWnd(MJFanma);
                -- local famaLayer=MJFanma.new(data,false);
                local famaLayer=MJFanma.new(self:getFanmaData(data), self:getFanmaConfig(data));
                self:addChild(famaLayer,50)
                self:performWithDelay(function ()
                    self.m_playerHeadNode:setHeadSrcPos()
                    -- 移除指示
                    self._playLayer:removeIndicator()
                    layer:removeFromParent()
                    if haveMaima then
                        -- UIManager:getInstance():popWnd(MJFanma);
                        famaLayer:removeFromParent()
                        local tmpMaimaUI = UIManager:getInstance():pushWnd(fanMaimaWnd)
                        tmpMaimaUI.m_pWidget:performWithDelay(function()
                            UIManager:getInstance():popWnd(fanMaimaWnd);
                            local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                            gameOverDialogUI:setDelegate(self);
                            end,2.5)
                    else
                        -- UIManager:getInstance():popWnd(MJFanma);
                        famaLayer:removeFromParent()
                        local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                        gameOverDialogUI:setDelegate(self);
                    end
                 end,3)
             elseif haveMaima then
                local tmpFanUI = UIManager:getInstance():pushWnd(fanMaimaWnd)
                tmpFanUI.m_pWidget:performWithDelay(function ()
                    
                    -- UIManager:getInstance():popWnd(MJFanma);
                    UIManager:getInstance():popWnd(fanMaimaWnd);
                    self.m_playerHeadNode:setHeadSrcPos()
                    -- 移除指示
                    self._playLayer:removeIndicator()
                    layer:removeFromParent()
                    local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                    gameOverDialogUI:setDelegate(self);
                end, 3)
             else
                self:performWithDelay(function()
                    -- 重设头像位置
                    self.m_playerHeadNode:setHeadSrcPos()
                    -- 移除指示
                    self._playLayer:removeIndicator()
                    layer:removeFromParent()
                    self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                    self.m_gameOverDialogUI:setDelegate(self);   
                    -- 隐藏操作
                    self.operateLayer:onHide()
                    --朋友开房逻辑特殊处理
                    -- if(kFriendRoomInfo:isFriendRoom()) then
                    -- else            
                    -- end
                end, 0.25)
             end  
        end,2.0)
    end
    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

    --查胡提示
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    gamePlaySystem:gameStartLogic_setHuMjs();
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    -- 补花层
    self.m_flowerNode:onGameOver()
    self._opOverTimeTip._operatorOverTimeTip:endUpdate()    
end


function jieyangGameLayer:handleJieSuanImmediately(info)
    Log.i("jieyangmjGameLayer:handleJieSuanImmediately", info)

    for i=1,#info.pl do
        local netPlayerInfo = info.pl[i]
        Log.i("立即结算",netPlayerInfo)

        -- 获取对应的玩家
        local playerInfo = self.gameSystem:gameStartGetPlayerByUserid(netPlayerInfo.usI);

        local tmpSite = playerInfo:getProp(enCreatureEntityProp.SITE) --玩家方位
        Log.i("当前玩家位置" .. tmpSite)
        --更改后的分数
        playerInfo:setProp(enCreatureEntityProp.FORTUNE, netPlayerInfo.sc or 0)
        self.m_playerHeadNode:refreshFortune(tmpSite)

        -- 显示分数动画
        self:showMoneyLabel(tmpSite, netPlayerInfo.chS)
    end

    --显示跟庄动画
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/jieyangmj/genzhuang/extraAnimation.csb")
    local armature = ccs.Armature:create("extraAnimation")
    armature:setPosition(cc.p(display.width/2, display.height/2))
    armature:getAnimation():play("AnimationGENZHUANG")
    armature:performWithDelay(function()
             armature:removeFromParent(true)
        end, 1);
    self:addChild(armature,500)
    
end


return jieyangGameLayer
