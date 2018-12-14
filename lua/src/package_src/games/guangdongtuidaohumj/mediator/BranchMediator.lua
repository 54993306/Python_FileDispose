--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayLayer     = require("package_src.games.guangdongtuidaohumj.games.ui.gamelayer.guangdongtuidaohumjGameLayer")
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
    --消息的恢复接收要放到onEnter之后，不然有概率出错
    SocketManager.getInstance().pauseDispatchMsg = false
end
function BranchMediator:initGameModules()
	self.entityModule 	= nil
    self.systemManager  = nil
    self.gameStateManager 	= nil
    self.entityModule   = require("app.games.common.entity.EntityModule").new()
    self.systemManager  = require("package_src.games.guangdongtuidaohumj.system.BranchSystemManager").new()
    self.enventServer   = require("app.games.common.components.EventServer").new()
    self.gameStateManager = require("app.games.common.playingstate.gameStateManager").new()
end
return BranchMediator

--endregion
