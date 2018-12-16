-------------------------------------------------------------
--  @file   GameSubstituteLogic.lua
--  @brief  托管逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-31 11:05:26
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Component = cc.Component
local GameSubstituteLogic = class("GameSubstituteLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameSubstituteLogic:ctor()
	GameSubstituteLogic.super.ctor(self, "GameSubstituteLogic")
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function GameSubstituteLogic:onBind_()
	self.gameSubstituteDatas = {}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function GameSubstituteLogic:onUnbind_()
	self.gameSubstituteDatas = {}
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameSubstituteLogic:setGameSubstituteDatas(cmd, context)
	self.gameSubstituteDatas = {}
	self.gameSubstituteDatas = context
	--  获取托管操作的玩家
	dump(context)
	local player = self.target_:gameStartGetPlayerByUserid(context.maPI)
	--  状态改变之后重设玩家状态
	if player:getState(enCreatureEntityState.SUBSTITUTE) ~= context.isM then
		player:setState(enCreatureEntityState.SUBSTITUTE, context.isM)
	end
end

function GameSubstituteLogic:setPlayeOnlineDatas(cmd, context)	
	--[[
	if context == nil or context.plI == nil then
		return
	end
	local player = self.target_:gameStartGetPlayerByUserid(context.plI)
	--  状态改变之后重设玩家状态
	if player:getState(enCreatureEntityState.ONLINE) ~= context.plI then
		player:setState(enCreatureEntityState.ONLINE, context.leS == 0 and enOnlineStatus.ONLINE or enOnlineStatus.OFFLINE)
	end
	]]
end
--[[
-- @brief  获取开始游戏数据
-- @param  void
-- @return void
--]]
function GameSubstituteLogic:getGameSubstituteDatas()
	return self.gameSubstituteDatas
end

--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function GameSubstituteLogic:exportMethods()
	self:exportMethods_({
        "setGameSubstituteDatas",
        "getGameSubstituteDatas",
        "setPlayeOnlineDatas",
    })
    return self.target_
end

return GameSubstituteLogic