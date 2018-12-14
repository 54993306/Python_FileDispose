-------------------------------------------------------------
--  @file   ChatCustomLogic.lua
--  @brief  自定义聊天逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-31 11:33:10
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Component = cc.Component
local ChatCustomLogic = class("ChatCustomLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ChatCustomLogic:ctor()
	ChatCustomLogic.super.ctor(self, "ChatCustomLogic")
	
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function ChatCustomLogic:onBind_()
	self.chatCustomInfo ={}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function ChatCustomLogic:onUnbind_()
	self.chatCustomInfo ={}
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ChatCustomLogic:setChatCustomInfo(cmd, context)
	self.chatCustomInfo = {}
	self.chatCustomInfo = context
end

--[[
-- @brief  获取开始游戏数据
-- @param  void
-- @return void
--]]
function ChatCustomLogic:getChatCustomInfo()
	return self.chatCustomInfo
end

--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function ChatCustomLogic:exportMethods()
	self:exportMethods_({
        "setChatCustomInfo",
        "getChatCustomInfo",
    })
    return self.target_
end

return ChatCustomLogic
