-------------------------------------------------------------
--  @file   GamePlaySystem.lua
--  @brief  lua 类定义
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 19:36:55
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local currentModuleName = ...
local SystemBase 		= import("..SystemBase", currentModuleName)
local GamePlaySystem 	= class("GamePlaySystem", SystemBase)
local SystemFactory 		= import("..SystemFactory", currentModuleName)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GamePlaySystem:ctor()
	
end

--[
-- @override
--]
function GamePlaySystem:release()
   
end

--[
-- @override
--]
function GamePlaySystem:activate(context)
    self.myUserId = kUserInfo:getUserId() or 0
	
    self.gameStartLogicPath= SystemFactory.getGameStartLogicPath(_gameType);
   	cc(self):addComponent(self.gameStartLogicPath):exportMethods()
	
	  self.gameOverLogicPath = SystemFactory.getGameOverLogicPath(_gameType); --因为不同麻将结算数据不一样。可能继承处理。
   	cc(self):addComponent(self.gameOverLogicPath):exportMethods()
	
    self.gameDispenseLogic = SystemFactory.getGameDispenseLogicPath(_gameType)
    cc(self):addComponent(self.gameDispenseLogic):exportMethods()
  
    self.playCardLogicPath = SystemFactory.getPlayCardLogicPath(_gameType)
    cc(self):addComponent(self.playCardLogicPath):exportMethods()
    -- cc(self):addComponent("app.games.common.system.gameplay.PlayCardLogic"):exportMethods()
    cc(self):addComponent("app.games.common.system.gameplay.GameSubstituteLogic"):exportMethods()
    -- cc(self):addComponent("app.games.common.system.gameplay.GameDispenseLogic"):exportMethods()
   	cc(self):addComponent("app.games.common.system.gameplay.ContinueLogic"):exportMethods()
end

--[
-- @override
--]
function GamePlaySystem:deactivate()
   	cc(self):removeComponent(self.gameStartLogicPath)
  	cc(self):removeComponent(self.gameOverLogicPath)
    cc(self):removeComponent(self.playCardLogicPath)
    -- cc(self):removeComponent("app.games.common.system.gameplay.PlayCardLogic")
    cc(self):removeComponent("app.games.common.system.gameplay.GameSubstituteLogic")
    cc(self):removeComponent(self.gameDispenseLogic)
    -- cc(self):removeComponent("app.games.common.system.gameplay.GameDispenseLogic")
   	cc(self):removeComponent("app.games.common.system.gameplay.ContinueLogic")
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function GamePlaySystem:updateData(cmd, context)
   
end

--[[
-- @brief  获取自己的id
-- @param  void
-- @return void
--]]
function GamePlaySystem:getMyUserId()
   return self.myUserId
end

--[[
-- @brief  获取自己的id
-- @param  void
-- @return void
--]]
function GamePlaySystem:getMyUserId()
   return self.myUserId
end

--[
-- @override
--]
function GamePlaySystem:getSystemId()
    return enSystemDef.GAME_PLAY_SYSTEM
end

return GamePlaySystem
