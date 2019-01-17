-------------------------------------------------------------
--  @file   MjMediator.lua
--  @brief  调度器
--  @author Zhu Can Qin
--  @DateTime:2016-08-30 09:39:54
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local MjGameScene       = require "app.games.common.mediator.MjGameScene"
local MjGameSocketProcesser = require ("app.games.common.mediator.MjGameSocketProcesser")
local UIFactory         = require("app.games.common.ui.UIFactory")
local GamePlayLayer     = require("app.games.common.ui.playlayer.GamePlayLayer")
local Define 			= require("app.games.common.Define")
-- local HandCardsPanel 	= require("app.games.common.ui.playlayer.HandCardsPanel")
local PlayerLeftPanel 	= require("app.games.common.ui.playlayer.PlayerLeftPanel")
local PlayerRightPanel 	= require("app.games.common.ui.playlayer.PlayerRightPanel")
local PlayerOtherPanel 	= require("app.games.common.ui.playlayer.PlayerOtherPanel")
local MjGroups          = require("app.games.common.ui.playlayer.exhibition.MjGroups")
require("app.games.common.ui.bglayer.MJToast")

MjMediator = class("MjMediator")

--先判断各个模块是否有重写该类有的话先加载模块里面的
MjMediator.getInstance = function()
    if not MjMediator.s_instance then
        local filePath = "src/package_src/games/".._gameType.."/mediator/BranchMediator.lua"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
        local file = io.exists(filePath)
        assert(file ~= nil)
        local moduleMediator = nil
        if not file then
            filePath = "src/package_src/games/".._gameType.."/mediator/BranchMediator.luac"
            filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
            file = io.exists(filePath)
            assert(file ~= nil)
        end
        if file then
            moduleMediator = require("package_src.games.".._gameType..".mediator.BranchMediator")
        end
        if moduleMediator ~= nil then
            MjMediator.s_instance = moduleMediator.new()
        else
            MjMediator.s_instance = MjMediator.new()
        end

    end
    return MjMediator.s_instance;
end

MjMediator.releaseInstance = function()
    if MjMediator.s_instance then
        MjMediator.s_instance:dtor();
    end
    MjMediator.s_instance = nil;
end

MjMediator.ctor = function(self)
    -- 初始化在socket处理之前
	self:init()
	self.m_socketProcesser = MjGameSocketProcesser.new(self)
	SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
end

MjMediator.dtor = function(self)
	SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
	for i=1,#self._listeners do
		self:getEventServer():removeEventListener(self._listeners[i])
	end
	self._listeners= {}
    -- 反激活模块
    self:deactivateModules()
end

function MjMediator:init()
    self:initGameModules()
    self:activateModules()
	self._listeners = {}
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.MSG_SEND, handler(self, self.onMsgSend)))
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_distrubuteEnd, handler(self, self.onMjDistrubuteEnd)))
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_msgFlower, handler(self, self.on_flower)))
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_msgAction, handler(self, self.on_action)))
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_msgGameOver, handler(self, self.on_msgGameOver)))
	table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_msgResume, handler(self, self.onGameResume)))
    table.insert(self._listeners,
       self:getEventServer():addCustomEventListener(MJ_EVENT.GAME_msgFlowAction, handler(self, self.on_flowaction)))
    self.scene = UIManager.getInstance():getCurScene()
end

--[
-- @brief  初始化游戏模块
-- @param  void
-- @return void
--]
function MjMediator:initGameModules()
	self.entityModule 	= nil
    self.systemManager  = nil
    self.gameStateManager 	= nil
    package.loaded["app.games.common.system.SystemManager"] = nil
    self.entityModule   = require("app.games.common.entity.EntityModule").new()
    self.systemManager  = require("app.games.common.system.SystemManager").new()
    self.enventServer   = require("app.games.common.components.EventServer").new()
    self.gameStateManager = require("app.games.common.playingstate.gameStateManager").new()
end

--[
-- @brief  激活游戏模块
-- @param  void
-- @return void
--]
function MjMediator:activateModules()
    local modules = {
        self.entityModule,
        self.systemManager,
        self.enventServer,
    }
    table.walk(modules, function(k)
        if k.activate then
            k:activate()
        end
    end)
end

--[
-- @brief  反激活游戏模块
-- @param  void
-- @return void
--]
function MjMediator:deactivateModules()
    local modules = {
        self.entityModule,
        self.systemManager,
    }
    table.walk(modules, function(k)
        if k.deactivate then
            k:deactivate()
        end
    end)
end

--[
-- @brief  获取实体模块
-- @param  void
-- @return void
--]
function MjMediator:getEntityModule()
   return self.entityModule
end

--[
-- @brief  获取系统管理器
-- @param  void
-- @return void
--]
function MjMediator:getSystemManager()
   return self.systemManager
end

--[
-- @brief  获取游戏状态管理器
-- @param  void
-- @return void
--]
function MjMediator:getStateManager()
   return self.gameStateManager
end

--[
-- @brief  获取事件服
-- @param  void
-- @return void
--]
function MjMediator:getEventServer()
   return self.enventServer
end

--进入房间
function MjMediator:onGameEntry(data)
    kGameManager:setEntryComplete(false);

    LoadingView.releaseInstance();
    Toast.releaseInstance()
    TouchCaptureView.release()
    --解决真机上闪屏的问题
    SocketManager.getInstance().pauseDispatchMsg = true
    if Util.isBezelLess() then
        UIManager.getInstance():changeToLandscape("FIXED_HEIGHT")
    else
        UIManager.getInstance():changeToLandscape()
    end
    local bg = display.newSprite("games/common/mj/games/game_bg.png")--"package_res/games/pokercommon/standings/aaaaaa.png")
    cc.Director:getInstance():getRunningScene():addChild(bg,999)
    bg:setPosition(cc.p(display.width/2,display.height/2))
    bgCSize = bg:getContentSize()

    -- bg:setPosition(cc.p(display.width/2 - bgCSize.width,display.height/2-bgCSize.height))
    if display.width - bgCSize.width > display.height - bgCSize.height then
        bg:setScale(display.width/bgCSize.width)
    else
        bg:setScale(display.height/bgCSize.height)
    end

    local schdeuleTime = 0.4
    if not data.isRusumeGame then
        schdeuleTime = 0.4
    end
    scheduler.performWithDelayGlobal(function()
            UIManager.getInstance():popAllWnd(true);
            bg:removeFromParent()
            self._scene = MjGameScene.new(data)
            UIManager:getInstance():pushScene(self._scene)
    end, schdeuleTime);
end

--进入房间
function MjMediator:onGameEntryComplete(data)
    local roomInfo = kGameManager:getRoomInfo(data.gaI, data.roI);
    MjProxy:getInstance():setRoomInfo(roomInfo)
    MjProxy:getInstance():setRoomId(kFriendRoomInfo:getRoomId());
    MjProxy:getInstance():setGameId(CONFIG_GAEMID)

    self:suitDefinePos()
    if data.isRusumeGame == nil or data.isRusumeGame == false then
		--用工厂去创建,可以继承实现相关功能
        self._gameLayer = UIFactory.createGameLayer(_gameType,false);
        self._scene:addChild(self._gameLayer)
    else
		--用工厂去创建,可以继承实现相关功能
        self._gameLayer = UIFactory.createGameLayer(_gameType,true);
        self._scene:addChild(self._gameLayer)
    end

    self._scene:setRunningLayer(self._gameLayer)
    kGameManager:setEntryComplete(true);
    SocketManager.getInstance().pauseDispatchMsg = false
end

function MjMediator:suitDefinePos()
    Define.visibleWidth = cc.Director:getInstance():getVisibleSize().width
    Define.visibleHeight = cc.Director:getInstance():getVisibleSize().height
    Define.ViewSizeType = 0
    if Util.isBezelLess() then
        Define.ViewSizeType = 1
    end

    Define.g_pai_out_x = Define.visibleWidth / 2 - 173
    Define.g_pai_out_x_two_player = Define.visibleWidth / 2 - 390
    Define.g_pai_out_x_three_player = Define.visibleWidth / 2 - 214
    Define.g_pai_out_y = Define.visibleHeight / 2 - 60
    Define.g_other_pai_y = Define.visibleHeight - 80
    Define.g_other_show_pai_y = Define.visibleHeight - 100
    if IsPortrait then -- TODO
        Define.g_other_pai_out_y = Define.visibleHeight - 178
    else
        Define.g_other_pai_out_y = Define.visibleHeight - 165
    end
    Define.g_other_pai_out_x = Define.visibleWidth / 2 + 177
    Define.g_other_pai_start_x = Define.visibleWidth  - 390
    Define.g_left_pai_out_x = Define.visibleWidth / 2 - 235
    Define.g_left_pai_out_y = Define.visibleHeight / 2 + 210
    Define.g_left_pai_start_y = Define.visibleHeight / 2  + 270
    Define.g_left_pai_action_start_y = Define.visibleHeight - 10
    Define.g_right_pai_start_y = Define.visibleHeight / 2 - 160
    Define.g_right_action_pai_start_y = Define.visibleHeight / 2 - 200
    Define.g_right_pai_out_x = Define.visibleWidth / 2 + 235
    Define.g_right_pai_out_y = Define.visibleHeight / 2 - 65
    Define.g_right_pai_x = Define.visibleWidth  - 192
    Define.g_right_pai_action_x = Define.visibleWidth - 280
    Define.g_right_show_pai_x = Define.visibleWidth - 227

    Define.mj_myCards_position_x = 70
    Define.mj_myCards_position_y = 125

    Define.mj_myCards_action_x = Define.visibleWidth / 2 - 560
    Define.mj_myCards_action_y = 125

    Define.mj_leftCards_position_x = 180
    Define.mj_leftCards_position_y = Define.visibleHeight - 10
    Define.mj_otherCards_position_x = Define.visibleWidth / 2 + 250
    Define.mj_otherCards_position_y = Define.visibleHeight - 18
    Define.mj_rightCards_position_x = Define.visibleWidth - 180
    Define.mj_rightCards_position_y = Define.visibleHeight / 2 - 158

    -- 牌墙起始位置
    Define.mj_myCards_position_wall_x = Define.visibleWidth / 2 + 212
    Define.mj_myCards_position_wall_y = Define.visibleHeight / 2 - 191
    Define.mj_leftCards_position_wall_x = Define.visibleWidth / 2 -230
    Define.mj_leftCards_position_wall_y = Define.visibleHeight / 2 -175
    Define.mj_otherCards_position_wall_x = Define.visibleWidth / 2 - 209
    Define.mj_otherCards_postion_wall_y = Define.visibleHeight / 2 + 185
    Define.mj_rightCards_position_wall_x = Define.visibleWidth / 2 + 235
    Define.mj_rightCards_position_wall_y = Define.visibleHeight / 2 + 165

    -- 吃碰杠操作显示起始X轴
    if IsPortrait then -- TODO
        --修改 20171116 start 竖版换皮 牌局中吃碰杠位置  diyal.yin
        -- Define.g_action_start_x =       Define.visibleWidth - 350
        Define.g_action_start_x =       Define.visibleWidth - 160
        --修改 20171116 end 竖版换皮 diyal.yin
    else
        Define.g_action_start_x =       Define.visibleWidth - 350
    end

    -- 吃碰杠操作显示起始Y轴
    Define.g_action_start_y =       140

    if Define.ViewSizeType == 1 then
        Define.mj_myCards_scale = 1
        Define.mj_myCards_position_x = (Define.visibleWidth-1280)/2 + Define.mj_myCards_position_x
        Define.mj_common_scale = 1
        Define.mj_buhua_pos_scale = 1
    end
end

function MjMediator:onGameStart()

end

function MjMediator:on_startAniEnd()
	if self._gameLayer then
		self._gameLayer:on_startAniEnd()
	end
end
--[[
-- @brief  开始游戏发牌结束函数
-- @param  void
-- @return void
--]]
function MjMediator:onMjDistrubuteEnd()
	if self._gameLayer then
		self._gameLayer:onMjDistrubuteEnd()
	end
end

function MjMediator:on_flower()
	if self._gameLayer then
		self._gameLayer:on_flower()
	end
end
function MjMediator:showActionButton(actions,playCard)

    if self._gameLayer then
       self._gameLayer:showActionButton(actions,playCard)
    end
end

function MjMediator:on_payerAction(amimation,time)
    if self._gameLayer then
        return self._gameLayer:on_payerAction(amimation,time)
    end
    return nil
end
function MjMediator:on_playerHU(cx,cy)
    if self._gameLayer then
        return self._gameLayer:on_playerHU(cx,cy)
    end
end

--[[
-- @brief  发牌回调函数
-- @param  void
-- @return void
--]]
function MjMediator:onDispenseCard(packageInfo)
	if self._gameLayer then
		self._gameLayer:performWithDelay(function ()
			self._gameLayer:onDispenseCard(packageInfo)
		end, 0.3)
	end
end

function MjMediator:on_action()
    Log.i("MjMediator:on_action")
	if self._gameLayer then
		self._gameLayer:on_action()
	end
end
function MjMediator:on_otherFlower()
    if self._gameLayer then
        self._gameLayer:on_otherFlower()
    end
end
function MjMediator:on_flowaction()
    if self._gameLayer then
        self._gameLayer:on_flower()
    end
end

function MjMediator:on_msgGameOver()
	if self._gameLayer then
		self._gameLayer:on_msgGameOver()
	end
end

function MjMediator:on_msgChat()
	if self._gameLayer then
		self._gameLayer:on_msgChat()
	end
end

function MjMediator:on_msgDefaultChar()
    if self._gameLayer then
        self._gameLayer:on_msgDefaultChar()
    end
end

function MjMediator:on_recChargeResult(packetInfo)
    if self._gameLayer then
        self._gameLayer:recChargeResult(packetInfo)
    end
end
--[[
-- @brief  游戏恢复函数
-- @param  void
-- @return void
--]]
function MjMediator:onGameResume()

end

--[[
-- @brief  获取场景
-- @param  void
-- @return void
--]]
function MjMediator:getScene()
   return self._scene
end

--[[
-- @brief  继续游戏函数
-- @param  void
-- @return void
--]]
function MjMediator:continueGame(ctype)
	-- self:newGameLayer(ctype)
    local data = {};
    data.gaI = MjProxy:getInstance():getGameId()
    data.roI = MjProxy:getInstance():getRoomId()
    data.ty = ctype -- 1 续局 2 换桌
    Log.i("MjMediator:continueGame data=", data)
    SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_GAMESTART, data)

    --播放背景音乐
    _playGameMusic();

    if self._gameLayer then
        self._gameLayer:onContinueGame();
    end
end

function MjMediator:exitGame()
    local FileLog = require("app.common.FileLog")
    FileLog.manualUploadLogs()

    kGameManager:setEntryComplete(false);
    if self._gameLayer then
        self._gameLayer:onClose();
        self._gameLayer:removeFromParent()
        self._gameLayer = nil
    end
    LoadingView.getInstance():hide()
    Toast.releaseInstance()
    LoadingView.releaseInstance()
    MJToast.releaseInstance();
    UIManager.getInstance():popAllWnd(true); --要删除管理类中的窗口，不然在换场景是报错是。
    MjProxy:releaseInstance()
    TouchCaptureView.release()
    if self._scene and self._scene.m_friendOpenRoom then
        self._scene.m_friendOpenRoom:exitGame()
    end
    self:releaseInstance()

    --
    audio.stopMusic();
    UIManager.getInstance():recoverToDesignOrient()
    UIManager:getInstance():popScene();
    display.removeUnusedSpriteFrames()
end

function MjMediator:on_xiaPao()
	self._gameLayer:showXiaPaoNum()
end

function MjMediator:on_showFlowerNumber(number)
    self._gameLayer:showFlowNumber(number)
end

function MjMediator:isFanZi(card)
    local fazi = 0
    local laizi = MjProxy:getInstance():getLaizi()
    if laizi == nil or laizi < 10 then
        return
    end
    if laizi<40 then
        if laizi%10 ~= 1 then
            fazi = laizi-1
        elseif laizi%10== 1 then
            fanzi = laizi-laizi%10+9
        end
    elseif laizi > 40 and laizi < 50 then
        if (laizi > 41 and laizi < 45) or (laizi > 45 and laizi < 48) then
            fanzi = laizi -1
        elseif laizi == 41 then
            fanzi = 44
        elseif laizi == 45 then
            fanzi = 47
        end
    end
    if card == fanzi then
        -- Log.i("为幡子。。。。")
        return true
    end
    return false
end

function MjMediator:on_continueReady(userIds)
    if self._gameLayer then
        self._gameLayer:on_continueReady(userIds)
    end
end

function MjMediator:on_removeContinueReady()
    if self._gameLayer then
        self._gameLayer:on_removeContinueReady()
    end
end

function MjMediator:on_showPaoMaDeng(content)
    if self._gameLayer then
        self._gameLayer:on_showPaoMaDeng(content)
    end
end

function MjMediator:on_dismissDesk(info)
    if self._gameLayer then
        self._gameLayer:on_dismissDesk(info)
    end
end

-- 网络异常处理--

--重连成功
function MjMediator:onNetWorkReconnected()
    if not self._gameLayer then
        return
    end
    self._gameLayer:performWithDelay(function()
        HttpManager.getLocalNetworkIP()
        LoadingView.getInstance():hide();

        local dismissDeskView = UIManager.getInstance():getWnd(DismissDeskView)
        if dismissDeskView then
            UIManager.getInstance():popWnd(DismissDeskView)
        end

        Toast.getInstance():show("网络已连接");
    	MjProxy:getInstance()._msgCache = {}
		SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME,  { plID = MjProxy:getInstance():getPlayId()});
    end, 1);
end

--正在重连
function MjMediator:onNetWorkReconnect()

end

-- 断网通知
-- 正常情况下不会回调这里, 因为SocketManager:onClosed方法中,
-- 只会回调队列中第一个Processer的onNetWorkClosed方法,
-- 既OpenRoomGame中创建的FriendRoomSocketProcesser
function MjMediator:onNetWorkClosed()
    Log.i("------MjMediator:onNetWorkClosed")
    LoadingView.getInstance():hide();
    LoadingView.getInstance():hide("networkState");
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end
    Log.i("------MjMediator:onNetWorkClosed")

    -- local data = {}
    -- data.type = 1;
    -- data.title = "提示";
    -- data.content = "网络异常，请检查您的网络是否正常再进入游戏";

    local str_content = "网络异常，请检查您的网络是否正常再进入游戏！代码-008"
    local is_maintain = kLoginInfo:isServerMaintain()
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;

    data.closeCallback = function ()
        SocketManager.getInstance():closeSocket();
        if not UIManager.getInstance():getWnd(HallLogin) then
            UIManager.getInstance():recoverToDesignOrient();
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
    end

    if is_maintain then
        -- local notify = kServerInfo:getNotifyMessage()
        -- if notify then
        --     local Duty = require "app.hall.wnds.duty.Duty"
        --     data.title = notify.title
        --     data.serverTips = notify.content
        --     data.type = Duty.DIALOG_TYPE.SERVER_NOTICE
        --     UIManager.getInstance():pushWnd(Duty, data)
        --     return
        --     -- data.title = notify.title
        --     -- data.content = notify.content
        -- else
            str_content = "服务器即将进行维护！代码-007"
        -- end
    end
    data.content = str_content
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

function MjMediator:onNetWorkClose()
    LoadingView.getInstance():hide();
    LoadingView.getInstance():hide("networkState");
end

function MjMediator:onNetWorkConnectFail()
    Log.i("------MjMediator:onNetWorkConnectFail")
    LoadingView.getInstance():hide();
    LoadingView.getInstance():hide("networkState");

    local data = {}
    data.type = 2
    data.title = "提示";
    data.content = "连接服务器失败，请检查您的网络是否正常再进入游戏";
    data.yesStr = "重连"
    data.yesCallback = function ()
        SocketManager.getInstance():onConnectException()
    end
    data.cancalStr = "退出"
    data.cancalCallback = function ()
        SocketManager.getInstance():closeSocket();
        if not UIManager.getInstance():getWnd(HallLogin) then
            UIManager.getInstance():recoverToDesignOrient();
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

function MjMediator:onNetWorkConnectException()
    Log.i("------MjMediator:onNetWorkConnectException");
    LoadingView.getInstance():show("网络异常，正在重连...",1000, true, "networkState");
end

--服务器通知
function MjMediator:repBrocast(packetInfo)
    if packetInfo.ti == 4 then  -- 被踢下线
        SocketManager.getInstance():closeSocket()
        SocketManager.getInstance().m_status = NETWORK_EXCEPTION -- 设置网络状态, 使得在 MainScene:onEnter 函数中可以跳转到登录界面
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.contentType = COMNONDIALOG_TYPE_KICKED;
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理";
        data.canKeyBack = false
        data.closeCallback = function ()
            Log.i("MjMediator:repBrocast closeCallback")
            self:exitGame();
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif packetInfo.ti == 5 or packetInfo.ti == 6 then --ti == 5关服通知  ti==6只在牌局里面弹出
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        UIManager.getInstance():pushWnd(CommonDialog, data);
    end
end

--连接弱
function MjMediator:onNetWorkConnectWeak()
    Log.i("------MjMediator:onNetWorkConnectWeak");
    LoadingView.getInstance():show("您当前的网络不稳定，请检查您的网络", 1000, true);
end
-- 网络异常处理--

function MjMediator:onNetWorkConnectHealthly()
    LoadingView.getInstance():hide("networkState");
end

-- 请求离开游戏
function MjMediator:requestExitRoom()
	SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_ExitRoom,  {});
    LoadingView.releaseInstance()
	LoadingView.getInstance():show("正在退出游戏，请稍后...");
	self._gameLayer:performWithDelay(function ()
        self:exitGame();
    end, 2);
end

function MjMediator:clearData(mType)
	MjProxy:getInstance()._gameStartData = nil
	MjProxy:getInstance()._msgCache = nil
	MjProxy:getInstance()._flowerData = nil
	MjProxy:getInstance()._playCardData = nil
	MjProxy:getInstance()._actionData = nil
	MjProxy:getInstance()._substituteData = nil
	MjProxy:getInstance()._gameOverData = nil
	MjProxy:getInstance()._userInfoData = nil
	MjProxy:getInstance()._chatData = nil
	MjProxy:getInstance()._propData = nil
	MjProxy:getInstance()._missionData = nil
	if mType  and mType == 1 then
	else
		MjProxy:getInstance()._players = nil
	end
	MjProxy:getInstance()._commonOverData = nil
	MjProxy:getInstance()._gameStartData = nil

end

--统一消息发送接口
function MjMediator:onMsgSend(event)
	local msgId = unpack(event._userdata)
	assert(msgId and type(msgId) == "number")
	Log.i("MjMediator:onMsgSend: %x", msgId)
    local playSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local myUserid      = playSystem:getMyUserId()
    local playid        = playSystem:getGameStartDatas().gamePlayID
	if msgId == enMjMsgSendId.MSG_SEND_SUBSTITUTE then
        -- 发出托管消息不能操作
        -- local playLayer = self._gameLayer._playLayer
        -- playLayer:setPlayerTouchEnabled(false)
		local _, param = unpack(event._userdata)
		--1托管，0取消托管
		SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, {maPI = myUserid, isM = param})
	elseif msgId == enMjMsgSendId.MSG_SEND_TURN_OUT then
		local _, card,param = unpack(event._userdata)
        --新家扩展字段
        if param == nil then
            param = 0
        end
        -- dump(param, "打牌操作数据")
		SocketManager.getInstance():send(CODE_TYPE_GAME, msgId, {plID = playid, usID = myUserid, ca = card,fl = param});
	--请求操作
	elseif msgId == enMjMsgSendId.MSG_SEND_MJ_ACTION then
		-- dump(event._userdata, "发送操作数据")
		local _, actionId, actionResult, actionCard, cbCard = unpack(event._userdata)
		Log.i("发送消息",myUserid,actionId, actionResult, actionCard, cbCard)
		if cbCard then
			SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, {plID = playid, usID = myUserid, acID = actionId, acR = actionResult, acC0 = actionCard, cbC = cbCard});

		else
			SocketManager.getInstance():send(CODE_TYPE_GAME,msgId, {plID = playid, usID = myUserid, acID = actionId, acR = actionResult, acC0 = actionCard});
		end
	end

end

--[[
-- @brief  打牌能标志函数
-- @param  void
-- @return remainder = 1 不可以打牌 remainder = 2 可以打牌
--]]
function MjMediator:isCanPlayCard()
    local myCards   = MjProxy:getInstance()._players[Define.site_self].cards
    local remainder = #myCards % 3
    return remainder
end

--语音聊天
function MjMediator:on_speaking(packetInfo)
    Log.i("--语音聊天玩家ID", packetInfo.usI);
    if self._gameLayer then
        self._gameLayer:on_speaking(packetInfo);
    end
end

--语音聊天
function MjMediator:on_hideSpeaking(userId)
    Log.i("------MjMediator:on_hideSpeaking userId", userId);
    if self._gameLayer then
        self._gameLayer:on_hideSpeaking(userId)
    end
end

-- 打麻将中立即结算消息
function MjMediator:onHandleJieSuanImmediately(packetInfo)
    if self._gameLayer then
        self._gameLayer:handleJieSuanImmediately(packetInfo)
    end
end

-- 接收玩家定位信息
function MjMediator:repLocationInfo(packetInfo)
    if packetInfo == nil or packetInfo.usI == nil then
        Log.i("----- MjMediator:repLocationInfo 数据有误")
        return
    end

    local systemManager = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local userID = systemManager:getMyUserId()
    if userID == nil or tonumber(userID) == 0 then
        kUserInfo:setUserId(packetInfo.usI)
    end
    local player = systemManager:gameStartGetPlayerByUserid(packetInfo.usI)
    if player then
        player:refreshLocationInfo(packetInfo)
    end
end
