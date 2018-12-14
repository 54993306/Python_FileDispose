-------------------------------------------------------------
--  @file   MjMediator.lua
--  @brief  调度器
--  @author Zhu Can Qin
--  @DateTime:2016-08-30 09:39:54
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local GamePlayLayer     = require("package_src.games.guangdongjihumj.ui.gamelayer.BranchGameLayer")
local BranchMediator = class("BranchMediator",MjMediator)
function BranchMediator:ctor()
	Log.i("BranchMediator:ctor........")
    BranchMediator.super.ctor(self)
end

function BranchMediator:onGameEntryComplete(data)
    local roomInfo = kGameManager:getRoomInfo(data.gaI, data.roI);
    MjProxy:getInstance():setRoomInfo(roomInfo)
    MjProxy:getInstance():setRoomId(kFriendRoomInfo:getRoomId());
    MjProxy:getInstance():setGameId(data.gaI)
 
    -- UIManager.getInstance():changeToLandscape()
    self:suitDefinePos()
    if data.isRusumeGame == nil or data.isRusumeGame == false then
		--用工厂去创建,可以继承实现相关功能
--        self._gameLayer = UIFactory.createGameLayer(_gameType,false);
        self._gameLayer = GamePlayLayer.new(false)
        self._scene:addChild(self._gameLayer)   
    else 
        self._gameLayer = GamePlayLayer.new(true)
		--用工厂去创建,可以继承实现相关功能
--        self._gameLayer = UIFactory.createGameLayer(_gameType,true);
        self._scene:addChild(self._gameLayer)
    end
    self._scene:setRunningLayer(self._gameLayer)
    kGameManager:setEntryComplete(true);
    SocketManager.getInstance().pauseDispatchMsg = false
end
--[
-- @brief  初始化游戏模块
-- @param  void
-- @return void
--]
function BranchMediator:initGameModules()
	self.entityModule 	= nil
    self.systemManager  = nil
    self.gameStateManager 	= nil
    self.entityModule   = require("app.games.common.entity.EntityModule").new()
    self.systemManager  = require("package_src.games.guangdongjihumj.system.BranchSystemManager").new()
    self.enventServer   = require("app.games.common.components.EventServer").new()
    self.gameStateManager = require("app.games.common.playingstate.gameStateManager").new()
end
function BranchMediator:setGameOverIsEnd(boolean)
    self._gameOverIsEnd = boolean
end
function BranchMediator:gameOverIsEnd()
    if self._gameOverIsEnd == nil then
        self._gameOverIsEnd = false
    end
    return self._gameOverIsEnd
end
return BranchMediator