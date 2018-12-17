-------------------------------------------------------------
--  @file   GameDispenseLogic.lua
--  @brief  发牌逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 20:10:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Component = cc.Component
local GameDispenseLogic = class("GameDispenseLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameDispenseLogic:ctor()
	GameDispenseLogic.super.ctor(self, "GameDispenseLogic")
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function GameDispenseLogic:onBind_()
	self.dispenseCardDatas = {}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function GameDispenseLogic:onUnbind_()
	self.dispenseCardDatas = {}
end

--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function GameDispenseLogic:setDispenseCardDatas(cmd, context)
	self.dispenseCardDatas = {}
	self.dispenseCardDatas.playId 	= context.plID
	self.dispenseCardDatas.userId 	= context.usID
	self.dispenseCardDatas.card 	= context.ca
	self.dispenseCardDatas.isHaveNextAct 	= context.haA or false -- 是否有后续操作
	local remainCards = SystemFacade:getInstance():getRemainPaiCount() - 1
	SystemFacade:getInstance():setRemainPaiCount(remainCards)
	-- -- 发手牌加入到队列里面
	-- self.target_:addHandMj(self.dispenseCardDatas.card, 1)
end

--[[
-- @brief  获取数据函数
-- @param  void
-- @return void
--]]
function GameDispenseLogic:getDispenseCardDatas()
	return self.dispenseCardDatas
end
--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function GameDispenseLogic:exportMethods()
	self:exportMethods_({
    	"setDispenseCardDatas", 
    	"getDispenseCardDatas", 
    })
    return self.target_
end

return GameDispenseLogic