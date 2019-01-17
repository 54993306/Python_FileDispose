-------------------------------------------------------------
--  @file   ContinueLogic.lua
--  @brief  续局数据
--  @author ZCQ
--  @DateTime:2017-03-06 16:17:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
--============================================================

local Component = cc.Component
local ContinueLogic = class("ContinueLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ContinueLogic:ctor()
	ContinueLogic.super.ctor(self, "ContinueLogic")
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function ContinueLogic:onBind_()
	self.continueDatas = {}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function ContinueLogic:onUnbind_()
	self.continueDatas = {}
end

--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function ContinueLogic:setContinueDatas(cmd, context)
	self.continueDatas = {}
	self.continueDatas.userIDList = context.usI
end

--[[
-- @brief  获取数据函数
-- @param  void
-- @return void
--]]
function ContinueLogic:getContinueDatas()
	return self.continueDatas
end
--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function ContinueLogic:exportMethods()
	self:exportMethods_({
    	"setContinueDatas", 
    	"getContinueDatas", 
    })
    return self.target_
end

return ContinueLogic