--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
local Define            = require "app.games.common.Define"
local SetDialog         = require "app.games.common.ui.set.SetDialog"
local PaoPeiAnimLayer   = require ("app.games.common.ui.paopei.PaoPeiAnimLayer")
local UIFactory         = require "app.games.common.ui.UIFactory"
-- local GamePlayLayer     = require "app.games.common.ui.playlayer.GamePlayLayer"
-- local GameUIView        = require "app.games.common.ui.bglayer.GameUIView"
-- local PlayerHead        = require "app.games.common.ui.bglayer.PlayerHead"
-- local PlayerFlower      = require "app.games.common.ui.gamelayer.PlayerFlower"
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"

local GameLayerBase     = import("..GameLayerBase")
local GameLayer = class("GameLayer", GameLayerBase)

-- 结算配置
local kGameOverConfig = {
    overLayerColor = cc.c4b(0, 0, 0, 100), -- 暗层配置
    needFanma = 1, -- 是否需要显示翻马
    localZOrderFanma = 50, -- 层级
    timeFanma = 3, -- 显示翻马层的时间
}

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameLayer:ctor()
	Log.i("------GameLayer:ctor")

    self._playLayerZOrder = 11;
    self._uiLayerZOrder = 12;
    self._animLayerZOrder = 13;

    MjMediator.getInstance():suitDefinePos()
    MjMediator.getInstance():getStateManager():activate()
    self.layers = {};

	--语音变量
    self.m_speaking = false;
    self.m_speakTable = {};

    self.Events = {}
	
    -- 获取游戏系统
    self.gameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)

    if self._bgLayer then
        self._bgLayer:onClose()
    	self._bgLayer:removeFromParent()
    end

	--用工厂去创建,可以继承实现相关功能
    self._bgLayer = UIFactory.createBgLayer(_gameType);
    table.insert(self.layers, self._bgLayer)
    self._bgLayer:addTo(self)

     ------------- 操作超时提示-------------------------
    if self._opOverTimeTip then
        self._opOverTimeTip:onClose()
        self._opOverTimeTip:removeFromParent()
    end
    --用工厂去创建,可以继承实现相关功能
    self._opOverTimeTip = UIFactory.createOpOverTimeLayer(_gameType);
    table.insert(self.layers, self._opOverTimeTip)
    self._opOverTimeTip:setDelegate(self)
    self._opOverTimeTip:addTo(self, self._uiLayerZOrder)

     ------------- 加入录像回放控制层-------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- 加入录像回放控制层
        if self._videoLayer then
            self._videoLayer:removeFromParent()
        end
        self._videoLayer = VideoControlLayer.new()
        self._videoLayer:addTo(self, 1000)
    end
    ----------------------------------------------------------

    --测试------------------
    -- self.operateLayer:onShow({1,2, 4, 6})
    -------------------------------
    self.handlers = {}
    -- 监听事件
    -- 游戏开始事件
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_START_NTF, 
        handler(self, self.onGameStart)))
    -- 恢复游戏事件
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_RESUME_START_NTF, 
        handler(self, self.onGameResume)))
    -- 游戏结束
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_OVER_START_NTF, 
        handler(self, self.onGameOver)))

    -- 牌落地
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, 
        handler(self, self.onPutDownMj)))

    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_PUT_OUT_START_NTF, 
        handler(self, self.onPlayCard)))
    -- 骰子结束
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_TRICKS_END_NTF, 
        handler(self, self.onTricksEnd)))

    -- 监听动作通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_START_NTF, 
        handler(self, self.onAction)))

    -- 拿牌通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_DISPENSE_START_NTF, 
        handler(self, self.onDispenseCard)))

    ------------------------
    -- 取消托管通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_CANCEL_SUB_NTF, 
        handler(self, self.onCancelSub)))

    -- -- 显示吃碰杠通知
    -- table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
    --     enMjNtfEvent.GAME_ACTION_ONSHOW_NTF, 
    --     handler(self, self.onShowOperateLab)))

    -- 监听发牌结束
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_START_FINISH_NTF, 
        handler(self, self.onMjDistrubuteEnd)))

    -- 用户聊天信息返回
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_CHAT_USER_MESSAGE_RES, 
        handler(self, self.onMsgUserChatRes)))
    -- 默认短语聊天信息返回
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_CHAT_DEFAULT_MESSAGE_RES, 
        handler(self, self.onMsgDefaultChatRes))) 

    -- 监听续局游戏
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_CONTINUE_START_NTF, 
        handler(self, self.onContinueRes))) 

    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_CHECK_START_NTF, 
        handler(self, self.gameStart)))


    -- table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
    --     enMjNtfEvent.GAME_PUT_OUT_START_NTF, 
    --     handler(self, self.onMsgPlayCard))) 
    self:addSpriteFrames()

    self:addOneEventListener(NativeCall.Events.YYCallFuncChange, function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end)
    self:addOneEventListener(NativeCall.Events.YYCallFuncFinish, function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end)
end
function GameLayer:addSpriteFrames()
    display.addSpriteFrames("games/common/mj/cardlight.plist", "games/common/mj/cardlight.png")
end
-- function GameLayer:onMsgPlayCard()
--     if self.operateLayer:isVisible() then
--         Log.i("GameLayer:onMsgPlayCard........................")
--         self.operateLayer:onBtnClick(nil, enOperate.OPERATE_GUO)
--     end
    
-- end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function GameLayer:onShow()
    
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function GameLayer:onClose()

    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
    -- 关闭层
    table.walk(self.layers, function(h)
        h:onClose()
    end)
    if self.m_gameUIView then
        self.m_gameUIView:onClose()
    end

    -- 反激活状态管理器
    MjMediator.getInstance():getStateManager():deactivate()

    if self.m_schedulerCheckCanPlay then
        scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
        self.m_schedulerCheckCanPlay = nil
    end
    
    table.walk(self.Events,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.Events = {}
end

--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
function GameLayer:onShowUI()
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

function GameLayer:onContinueGame()
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

function GameLayer:onKeyboard()
    Log.i("------GameLayer:onKeyboard");
end

function GameLayer:onEnter()
	Log.i("GameLayer:onEnter#######################")
end

function GameLayer:recChargeResult(packetInfo)
    --CommonAnimManager.getInstance():showMoneyWinAnim();
    --Toast.getInstance():show("充值成功");
end
--发送系统定义的表情和文字短语 
function GameLayer:sendDefaultChat(m_type,index)
    local data  = {};
    data.usI    = MjProxy:getInstance():getMyUserId()
    data.gaPI   = MjProxy:getInstance():getGameId()
    data.ty     = m_type
    data.emI    = index;
    SocketManager.getInstance():send(CODE_TYPE_GAME, enMjMsgSendId.MSG_SEND_DEFAULT_CHAT, data);
end
--发送自定文字
function GameLayer:sendUserChat(content)
    local data  = {}
    data.usI    = tonumber(MjProxy:getInstance():getMyUserId())
    data.gaPI   = tonumber(MjProxy:getInstance():getGameId())
    data.co     = content
    data.ty     = 0
    SocketManager.getInstance():send(CODE_TYPE_GAME, enMjMsgSendId.MSG_SEND_USER_CHAT, data)
end

function GameLayer:gameStart(event)
    self._bgLayer:onCheckGameStart()
    -- self:gameVibration();
end

--[[
-- @brief  游戏开始函数
-- @param  void
-- @return void
--]]
function GameLayer:onGameStart()
    -- 等待收到开局消息时显示ui
    self:gameVibration();
    self:onShowUI()
    self._playLayer:onGameStart()
    self._bgLayer:onGameStart()
    self._opOverTimeTip:onGameStart()
    
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local hasLaPaoZuoDi = playSystem:hasLaPaoZuoDi()
    if not hasLaPaoZuoDi then
        self:gameStart()
    else
        --[[
            当存在拉跑坐等操作时, 之前是0.1s延迟后判断是否可以显示开局UI, 所以会存在以下问题:
            若开局和下跑完成的消息连续到达, 间隔小于这个延迟, 就会先在GamePlayLayer中进行第一次判断,
            再到这里进行第二次判断, 先后发送两次GAME_CHECK_START_NTF消息
        ]]
        local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local isTrue = playSystem:checkGameStart()
        self:performWithDelay(function ()
            --恢复牌局显示已经选择的结果
            self:initLaPaoZuoDiOperation()
            if isTrue then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHECK_START_NTF);
            end
        end, 0.1)
    end
end

--[[
-- @brief  游戏第一局震动
-- @param  void
-- @return void
--]]
function GameLayer:gameVibration()
  if SettingInfo.getInstance():getGameVibrationStatus() then
    local jushu  = SystemFacade.getInstance():getCurrentGameCount()
    Log.i("游戏第一局震动:" .. jushu)
	
    if jushu >1 or VideotapeManager.getInstance():isPlayingVideo() then
        return
    end
	--android/ios call 
    local data = {};
    data.cmd = NativeCall.CMD_SHAKE;
    data.send = 1;
    NativeCall.getInstance():callNative(data);
  end
end

function GameLayer:resumeEvent(event)
    -- 分发恢复对局完成通知
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_RESUME_FINISH_NTF);
end

--[[
-- @brief  游戏恢复函数
-- @param  void
-- @return void
--]]
function GameLayer:onGameResume()
    -- 等待收到恢复对局消息时显示ui
    self:onShowUI()

    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local checkGameStart = playSystem:checkGameStart()
    self._bgLayer:onGameResume()
    Log.d("onGameResume=================>>>>", checkGameStart)
    if checkGameStart then
        local startData = playSystem:getGameStartDatas()
        
        if IsPortrait then -- TODO
            if _gameChatTxtCfg == nil or #_gameChatTxtCfg <=0 then
                MjProxy:getInstance():get_gameChatTxtCfg()
            end
        else
            MjProxy:getInstance():get_gameChatTxtCfg()
        end
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
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function GameLayer:onGameOver()
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
        if IsPortrait then -- TODO
            self:addChild(armature,kGameOverConfig.localZOrderFanma)
        else
            self:addChild(armature,5)
        end

        -- ---------- 流局不显示流局界面录像回放相关-----------------------------
        -- if VideotapeManager.getInstance():isPlayingVideo() then
        --     return      
        -- end
        ----------------------------------------------------
    end

    -- 亮出其他玩家的牌
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

        -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        -- local armature = ccs.Armature:create("yipaoduoxiang")
        -- armature:getAnimation():play("Animation1")
        if IsPortrait then -- TODO
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
            local armature = ccs.Armature:create("yipaoduoxiang")
            armature:getAnimation():play("Animation1")
            
            armature:performWithDelay(function()
                     armature:removeFromParent(true)
                end, 0.7);
            armature:setPosition(cc.p(display.cx, display.cy))
            self:addChild(armature,kGameOverConfig.localZOrderFanma)
        else
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
            local armature = ccs.Armature:create("CpghAnimation")
            armature:getAnimation():play("AnimationYPDX")
            
            armature:performWithDelay(function()
                     armature:removeFromParent(true)
                end, 0.7);
            armature:setPosition(cc.p(display.cx, display.cy))
            self:addChild(armature,50)
        end
    end

    -- 结算界面
    self:showGameOverUI(data, delayTime)    
end

-- 显示结算UI
-- data: getGameOverDatas() 结算数据
-- delayTime: 显示延迟(用于亮牌)
function GameLayer:showGameOverUI(data, delayTime)
    self.m_overLayerColor = cc.LayerColor:create(kGameOverConfig.overLayerColor, cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    self.m_overLayerColor:addTo(self)

    self:performWithDelay(function ()
        -- 重设头像位置
        self.m_playerHeadNode:setHeadSrcPos()
        -- 移除指示
        self._playLayer:removeIndicator()
        if not self:customOverView(data) then
            self:defaultOverView()
        end
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

-- 跳转结算界面
function GameLayer:defaultOverView()
    if UIManager:getInstance():getWnd(FriendTotalOverView) then
        return
    end
    self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
    self.m_gameOverDialogUI:setDelegate(self);
    if self.m_overLayerColor then
        self.m_overLayerColor:removeFromParent()
        self.m_overLayerColor = nil
    end
end

-- 替换跳转结算界面逻辑(以翻马为例)
-- data: getGameOverDatas() 结算数据
function GameLayer:customOverView(gameOverData)
    -- Log.i("是否要显示翻马UI(0: 不用显示, 1: 要显示)", gameOverData.isND)
    if gameOverData.isND ~= kGameOverConfig.needFanma then --是否显示翻马UI(0: 不用显示, 1: 要显示)
        return false
    else
        local MJFanMa= require("app.games.common.ui.gameover.MJFanMa")
        local famaLayer= MJFanMa.new(self:getFanmaData(gameOverData), self:getFanmaConfig(gameOverData))

        self:addChild(famaLayer, kGameOverConfig.localZOrderFanma)
        self:performWithDelay(function ()
            famaLayer:removeFromParent()
            self:defaultOverView()
        end, kGameOverConfig.timeFanma)
        return true
    end
end

-- 抽取翻马数据
-- data: getGameOverDatas() 结算数据
function GameLayer:getFanmaData(gameOverData)
    local fanmaData = {}
    local compatibleFanma = gameOverData.faI or gameOverData.fanma -- 部分麻将的翻马数据设置在外面这层
    if compatibleFanma then
        table.insert(fanmaData, compatibleFanma)
    else
        for i, v in ipairs(gameOverData.score) do
            local fanmaList = v.faI9 or {}
            table.insert(fanmaData, fanmaList)
        end
    end
    -- Log.i("GameLayer:getFanmaData", fanmaData)
    return fanmaData
end

-- 获取翻马配置(地方组改写)
-- data: getGameOverDatas() 结算数据
function GameLayer:getFanmaConfig(gameOverData)
    local config = {
        -- titlePng = "games/".._gameType.."/game/fanmaTitle.png", -- 标题图片
        -- titleScale = 2.0, -- 标题缩放大小
        -- titleOff = cc.p(0, -20), -- 标题偏移
        -- hideHead = false, -- 是否隐藏头像
        -- composeType = 2, -- 0 不合并, 1 翻的牌大于一定数量后合并(所有玩家的最大牌数), 2 翻出的马大于一定数量后合并(所有玩家的最大牌数)
        -- composeMinNum = 5, -- 合并麻将的起始值, 比如设定为大于等于10张后合并
        -- isTouchClose = true, -- 点击后关闭
    }
    local compatibleFanma = gameOverData.faI or gameOverData.fanma -- 部分麻将的翻马数据设置在外面这层, 此时需要隐藏头像
    if compatibleFanma then
        config.hideHead = true
    end
    -- Log.i("GameLayer:getFanmaConfig", config)
    return config
end

--[[
-- @brief  游戏动作函数
-- @param  void
-- @return void
--]]
function GameLayer:onAction()
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

--[[
-- @brief 取消托管通知
-- @param  void
-- @return void
--]]
function GameLayer:onCancelSub()
    self._bgLayer:onCancelSub()
end

-- function GameLayer:showLaiziMj()
--     local turn = require("app.games.common.custom.MJTurnLaizigou")
--     local turnLaizigou = turn.new(MjProxy:getInstance():getLaizi())
--     turnLaizigou:addTo(self,10)
-- end

--[[
-- @brief  打牌函数
-- @param  void
-- @return void
--]]
function GameLayer:onPlayCard()
	Log.i("------GameLayer:onPlayCard")
    SoundManager.playEffect("dapai", false);
    self.operateLayer:onPlayCard() -- 先显示操作栏, 再进行后续流程
    self._playLayer:onPlayCard()
    self._bgLayer:onPlayCard()
    self._opOverTimeTip:onPlayCard()
   
    --查胡状态
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
end
--[[
-- @brief  拿牌函数
-- @param  void
-- @return void
--]]
function GameLayer:onDispenseCard(packageInfo)
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

    -- -- 拿牌结束
    -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
end

--[[
-- @brief  骰子结束通知函数
-- @param  void
-- @return void
--]]
function GameLayer:onTricksEnd()
    if self._playLayer == nil then
        Log.d("--wangzhi--self._playLayer--为空--")
        print(debug.traceback())
        return
    end
	self._playLayer:onTricksEnd()
end 

--[[
-- @brief  发牌结束函数
-- @param  void
-- @return void
--]]
function GameLayer:onMjDistrubuteEnd()
    Log.i("------onMjDistrubuteEnd");
	assert(self._playLayer ~= nil)
    self._playLayer:onMjDistrubuteEnd()
	self._bgLayer:onMjDistrubuteEnd()
    self._opOverTimeTip:onMjDistrubuteEnd()
    self:showDingqueOperation();
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    playSystem:setMjDistrubuteEnd(true)
    if IsPortrait then -- TODO
        -- 发牌结束，牌局开始，更新定位数据
        self:sendLocationToServer()
    end
end

--[[
    --- @brief 恢复牌局的时候，显示已经选择的玩家拉跑坐底操作结果
]]
function GameLayer:initLaPaoZuoDiOperation()
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local players   = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()

    local hasDi = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_XIADI)
    local hasPao = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_XIA_PAO)
    local hasLa = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_LAZHUANG)
    local hasZuo = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_ZUO)

    for i = 1, #players do
        local player = players[i]
        local isBackar = player:getProp(enCreatureEntityProp.BANKER)

        if hasDi then
            local xiaDiNum = player:getProp(enCreatureEntityProp.XIA_DI_NUM)
            if xiaDiNum >= 0 then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, enOperate.OPERATE_XIADI, xiaDiNum, i);
            end
        end

        if hasPao then
            local xiaPaoNum = player:getProp(enCreatureEntityProp.XIA_PAO_NUM)
            if xiaPaoNum >= 0 then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, enOperate.OPERATE_XIA_PAO, xiaPaoNum, i);
            end 
        end

        if hasLa and not isBackar then
            local xiaLaNum = player:getProp(enCreatureEntityProp.XIA_LA_NUM)
            if xiaLaNum >= 0 then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, enOperate.OPERATE_LAZHUANG, xiaLaNum, i);
            end
        end

        if hasZuo and isBackar then
            local xiaZuoNum = player:getProp(enCreatureEntityProp.XIA_ZUO_NUM)
            if xiaZuoNum >= 0 then
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, enOperate.OPERATE_ZUO, xiaZuoNum, i);
            end
        end
    end
end

--显示定缺操作
function GameLayer:showDingqueOperation()
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM);
    if playSystem:getIsHasDingQue() and not VideotapeManager.getInstance():isPlayingVideo() then
        if self.m_gameUIView then
            self.m_gameUIView:initDingquePanel();
        end
    end
end

function GameLayer:onPutDownMj(event)
	-- assert(self._bgLayer ~= nil)
    Log.i("onPutDownMj(event)", event)
	self._playLayer:onPutDownMj(event)
    -- self._bgLayer:onPutDownMj()
end

function GameLayer:on_msgGameOver()

end

--新增 通过手牌数获取当前出牌的人
--不可靠的实现方式 暂定 加了数据层之后再更换
--都不能则返回0
function GameLayer:getCanDoCardSite()

    if self._playLayer ~= nil and type(self._playLayer.playerPannel) == "table" then
        local playerPannels = self._playLayer.playerPannel
        local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local players   = gamePlaySystem:gameStartGetPlayers()
        for i=1,#players do
            if playerPannels[i] ~= nil and playerPannels[i].getHandCardsList ~= nil then
                local cardnum = #playerPannels[i]:getHandCardsList()
                if cardnum > 0 and cardnum%3 == 2 then
                    return i
                end
            end
        end
    end
    return 0
end

-- function GameLayer:on_msgChat()
-- 	local players = self.gameSystem:gameStartGetPlayers()
--     -- local chatData = MjProxy:getInstance()._chatData
--     local chatSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.CHAT_SYSTEM)
--     local chatData = chatSystem:getChatCustomInfo()
--     dump(chatData)
--     for i,v in pairs(players) do
--         if chatData.usI == v:getProp(enCreatureEntityProp.USERID) then
--             local site = i
--             self._playerChat:showChat(chatData, site)
--         end
--     end
-- end

--[[
-- @brief  用户聊天返回
-- @param  void
-- @return void
--]]
function GameLayer:onMsgUserChatRes()
    local chatSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.CHAT_SYSTEM)
    local chatData      = chatSystem:getChatCustomInfo()
    self.m_playerHeadNode:showChatMessage(chatData)
end

--[[
-- @brief  默认聊天返回
-- @param  void
-- @return void
--]]
function GameLayer:onMsgDefaultChatRes()
    local chatSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.CHAT_SYSTEM)
    local chatData      = chatSystem:getChatDefaultInfo()
    self.m_playerHeadNode:showDefaulyChatMessage(chatData)
end
function GameLayer:on_msgProp()
    local magicID = MjProxy:getInstance()._propData.PropId
    local fid = MjProxy:getInstance()._magicIDFid[magicID]
    local propCount = MjProxy:getInstance()._propCount[fid]
    local fromUserID = MjProxy:getInstance()._propData.FromUserId
    local fromSite = fromUserID == MjProxy:getInstance():getMyUserId() and enSiteDirection.SITE_MYSELF or enSiteDirection.SITE_OTHER
    local toSite = fromSite == enSiteDirection.SITE_MYSELF and enSiteDirection.SITE_OTHER or enSiteDirection.SITE_MYSELF

    if propCount > 0 then
        MjProxy:getInstance()._propCount[fid] = propCount - 1
    end
  
end

function GameLayer:on_msgBuyProp()
    local buyPropData = MjProxy:getInstance()._buyPropData
    if buyPropData.result == 0 then
        local money = ww.mj.waBean
        local price = buyPropData.buyPrice
        MjProxy:getInstance():setWaBean(tonumber(buyPropData.userCash))

        local label = cc.Label:createWithSystemFont("-" .. price, "", 24)
        label:setTextColor(cc.c3b(0xbc, 0xff, 0xb1))
        label:setPosition(cc.p(525, 40))
        self:addChild(label, 1)

        label:runAction(cc.Sequence:create(
        		cc.Spawn:create(cc.EaseIn:create(cc.FadeOut:create(1), 2), 
                    cc.EaseOut:create(cc.MoveBy:create(1, cc.p(0, 100)), 2)),
				cc.RemoveSelf:create()))
    elseif buyPropData.result == 1 then
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(COMMON_EVENTS.SHOW_TOAST, "主人，您的豆太少啦，要不充个值？", 2)
    else
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(COMMON_EVENTS.SHOW_TOAST, "使用道具失败!", 2)
    end
end

function GameLayer:onContinueRes()
    local myselfObj = self.gameSystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF) 
    local myId = myselfObj:getProp(enCreatureEntityProp.USERID)
    local usids = {}
    table.insert(usids, myId)
    self:on_continueReady(usids)
end

function GameLayer:on_continueReady(userIds)
    if self.m_playerHeadNode == nil then
        return
    end
	for i=1, #userIds do
		local site = self.gameSystem:getPlayerSiteById(userIds[i])
        self.m_playerHeadNode:showReadySpr(site)
	end
    local players   = self.gameSystem:gameStartGetPlayers()
    for i=1,#players do 
        self.m_playerHeadNode:refreshFortune(i)
        self.m_playerHeadNode:showTinPaiOp(i, false)
        self.m_playerHeadNode:showZhuangOp(i, false)
    end
    
    self._bgLayer:hideShengyuStr()
    -- local continueDatas = self.gameSystem:getContinueDatas()
    -- for i=1, #continueDatas.userIds do
    --     local site = self.gameSystem:getPlayerSiteById(userIds[i])
    --     self.m_playerHeadNode:showReadySpr(site)
    -- end

end

function GameLayer:on_removeContinueReady()
	self._bgLayer:removeContinueReadyUi()
end

function GameLayer:on_showPaoMaDeng(content)
	self._bgLayer:on_showPaoMaDeng(content)
end

function GameLayer:on_dismissDesk(info)
    self._bgLayer:on_dismissDesk(info)
    
end

--[[
-- @brief  创建头像函数
-- @param  void
-- @return void
--]]
function GameLayer:createHead()
    Log.i("------GameLayer:showHead....")
    self:removeHead()
    self.m_playerHeadNode = UIFactory.createPlayerHead(_gameType);--PlayerHead:new()
    self.m_playerHeadNode.m_pWidget:addTo(self, self._uiLayerZOrder)
    self.m_playerHeadNode:setDelegate(self);
    self.m_playerHeadNode:onInit()
    self.m_playerHeadNode:setGameLayer()
end

function GameLayer:removeHead()
    if self.m_playerHeadNode ~= nil and self.m_playerHeadNode.m_pWidget ~= nil then
        self.m_playerHeadNode:onClose();
        self.m_playerHeadNode.m_pWidget:removeFromParent()
        self.m_playerHeadNode = nil
    end
end

function GameLayer:getDingQueResultPosition(site)
    if self.m_playerHeadNode then
        return self.m_playerHeadNode:getDingQueResultPosition(site);
    end
end

function GameLayer:updatePlayerStatus(site, statusId, newValue, oldValue)
    --[[if self.m_playerHeadNode and statusId == enCreatureEntityState.ONLINE then
        if self.m_playerHeadNode.showOffline ~= nil then
            self.m_playerHeadNode:showOffline(site, newValue == enOnlineStatus.OFFLINE)
        end
    end]]
end


--------------------------------------
--语音功能
--------------------------------------
--检测上传状态
function GameLayer:getUploadStatus()
    if COMPATIBLE_VERSION < 1 then
        if self.m_getUploadThread then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
        end
        self.m_getUploadThread = scheduler.scheduleGlobal(function()
            local data = {};
            data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
            NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
        end, 0.1);
    end
end

function GameLayer:addOneEventListener(eventName, listenerFunc)
    local signalLst = cc.EventListenerCustom:create(eventName, listenerFunc)
    table.insert(self.Events,signalLst)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalLst, 1)
end

function GameLayer:onUpdateUploadStatus(info)
    Log.i("接收到服务语音播放信息", info.fileUrl)
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        if COMPATIBLE_VERSION < 1 and self.m_getUploadThread then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
            self.m_getUploadThread = nil;
        end
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus", matchStr);

        --发送语音聊天
        if matchStr and kFriendRoomInfo:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = kUserInfo:getUserId();
            tmpData.niN = kUserInfo:getUserName();
            tmpData.roI = kFriendRoomInfo:getRoomInfo().roI;
            tmpData.ty = 1;
            tmpData.co = info.fileUrl;
            FriendRoomSocketProcesser.sendSayMsg(tmpData);
        end
    end
end

--检测播放状态
function GameLayer:getSpeakingStatus()
    if COMPATIBLE_VERSION < 1 then
        if self.m_getSpeakingThread then
            scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        end
        self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
            local data = {};
            data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
            NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
        end, 0.5);
    end
end

function GameLayer:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        if COMPATIBLE_VERSION < 1 and self.m_getSpeakingThread then
            scheduler.unscheduleGlobal(self.m_getSpeakingThread);
            self.m_getSpeakingThread = nil
        end
        self:on_hideSpeaking(info.usI);
    end
end

function GameLayer:on_speaking(packetInfo)
    if not YY_IS_LOGIN then
        --语音初始化失败
		Log.i("语音初始化失败")
        return;
    end

    if packetInfo and packetInfo.usI and #self.m_speakTable < 10 then
        table.insert(self.m_speakTable, packetInfo);
        Log.i("please say queue.....self.m_speakTable", self.m_speakTable)
    end
    self:playNextSpeaking()
end

function GameLayer:canPlayNextSpeaking()
    if self.m_speaking then
        return false
    elseif self.m_gameUIView.m_isTouchBegan then
        return false
    else
        return true
    end
end

function GameLayer:playNextSpeaking()
    if self:canPlayNextSpeaking() then
        Log.i("self:canPlayNextSpeaking() self.m_speakTable", self.m_speakTable)
        self:playSpeaking(table.remove(self.m_speakTable, 1))
    elseif not self.m_schedulerCheckCanPlay then
        self.m_schedulerCheckCanPlay = scheduler.scheduleGlobal(
            function()
                if not next(self.m_speakTable) then
                    scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
                    self.m_schedulerCheckCanPlay = nil
                end

                if self:canPlayNextSpeaking() then
                    Log.i("self:m_schedulerCheckCanPlay() self.m_speakTable", self.m_speakTable)
                    self:playSpeaking(table.remove(self.m_speakTable, 1))
                    scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
                    self.m_schedulerCheckCanPlay = nil
                end
            end, 0.1);
    end
end

function GameLayer:playSpeaking(packetInfo)
    Log.i("开始说话。。。。。", packetInfo.usI)
    Log.i("find say player id")
	local playerEntity = self.gameSystem:gameStartGetPlayerByUserid(packetInfo.usI)
    if(playerEntity~=nil) then
		self.m_speaking = true;
		Log.i("显示说话的语音条")
		-- 显示说话的语音条
		local side = self.gameSystem:getPlayerSiteById(packetInfo.usI)
		self.m_playerHeadNode:showSpeakPanel(side)
		--
		audio.pauseMusic();
		--
		local data = {};
		data.cmd = NativeCall.CMD_YY_PLAY;
		data.fileUrl = packetInfo.co;
		data.usI = packetInfo.usI .. "";
		NativeCall.getInstance():callNative(data);             
		self:getSpeakingStatus();
		--防止没有收到播放结束回调
		self.m_gameUIView:stopButtonAction()
		self:performWithDelay(function()
			   self.m_playerHeadNode:hideSpeakPanel(side)
			end, 60);
    end
end

function GameLayer:on_hideSpeaking(userId)
    Log.i("------GameLayer:on_hideSpeaking userId", userId);
    userId = userId or "0";
    local playerList = self.gameSystem:gameStartGetPlayers();
	for i=1, #playerList do
		 self.m_playerHeadNode:hideSpeakPanel(i);
	end

    self.m_speaking = false;
    Log.i("self.m_speakTable", self.m_speakTable)
    if #self.m_speakTable > 0 then
        -- self:on_speaking(table.remove(self.m_speakTable, 1));
        self:playNextSpeaking()
    else
        -- self.m_gameUIView:hideMic();
    end
end

--[[
type = 2,code=22021, 游戏中分数发生改变  client  <--  server
PlayerInfo      
##    usI  long  玩家id
##    sc  long  更改后的分数
##    chS  long  更改分数的值
##  pl:[PlayerInfo]  pl  List<PlayerInfo>   玩家列表
]]
--杠积分结算
function GameLayer:handleJieSuanImmediately(info)
    Log.i("GameLayer:handleJieSuanImmediately", info)
    --[[ local pl={}
    pl[1]={usI=1102464,sc=998,chS=-2}
    pl[2]={usI=1102465,sc=998,chS=-2}
    pl[3]={usI=1102462,sc=998,chS=6}
    pl[4]={usI=1102463,sc=998,chS=-2}]]

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
end

-- 设置金额显示的不同位置
local kMoneyLabelPos = {
    bottom = cc.p(display.cx - 150, 250),
    right  = cc.p(display.cx + 150, display.cy),
    top    = cc.p(display.cx - 150, display.height - 150),
    left   = cc.p(display.cx - 450, display.cy),
}
local kMoneyLabelConfigs = {
    {
        kMoneyLabelPos.bottom,
    },
    {
        kMoneyLabelPos.bottom, kMoneyLabelPos.top,
    },
    {
        kMoneyLabelPos.bottom, kMoneyLabelPos.right, kMoneyLabelPos.left,
    },
    {
        kMoneyLabelPos.bottom, kMoneyLabelPos.right, kMoneyLabelPos.top, kMoneyLabelPos.left,
    },
}

---------------------
-- 显示分数动画
function GameLayer:showMoneyLabel(tmpSite, tmpMoney)
    local moneyLabel = nil
    if(tmpMoney > 0) then --玩家增加了积分
        local tx = "+" .. tmpMoney
        local jifen = {
            text = tx,
            font = "games/common/gameCommon/add_num.fnt",
        }
        moneyLabel = display.newBMFontLabel(jifen);

    elseif(tmpMoney < 0) then --玩家减了积分
        local tx = "" .. tmpMoney
        local jifen = {
            text = tx,
            font = "games/common/gameCommon/sub_num.fnt",
        }
        moneyLabel = display.newBMFontLabel(jifen);
    end

    local posConfig = kMoneyLabelConfigs[self.gameSystem:getGameStartDatas().playerNum] -- 设置位置配置
    Log.i("posConfig", self.gameSystem:getGameStartDatas().playerNum, posConfig)
    if(moneyLabel ~= nil) then
        moneyLabel:setScale(2)
        moneyLabel:addTo(self, self._uiLayerZOrder)
        moneyLabel:setPosition(posConfig[tmpSite])
        if IsPortrait then -- TODO
            moneyLabel:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveBy:create(1,cc.p(200,0)),3),cc.RemoveSelf:create()))
        else
            moneyLabel:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveBy:create(1,cc.p(200,0)),3),
                cc.RemoveSelf:create(),
                cc.CallFunc:create(
                    function() 
                        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)  
                    end)
                )
            )
        end
    end
end

function GameLayer:sendLocationToServer()
    -- 牌局开始时获取一次定位
    NativeCall.getInstance():callNative({cmd = NativeCall.CMD_LOCATION}, function(info)
        local tmpData = {}
        tmpData.jiD = info.longitude
        tmpData.weD = info.latitude
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOCATION, tmpData);
    end)
end

return GameLayer
