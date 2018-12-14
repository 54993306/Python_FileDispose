-------------------------------------------------------------
--  @file   ChatDefaultLogic.lua
--  @brief  默认聊天逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-31 11:37:29
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local Component = cc.Component
local ChatDefaultLogic = class("ChatDefaultLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ChatDefaultLogic:ctor()
	ChatDefaultLogic.super.ctor(self, "ChatDefaultLogic")
	
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function ChatDefaultLogic:onBind_()
	self.chatDefaultInfo ={}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function ChatDefaultLogic:onUnbind_()
	self.chatDefaultInfo ={}
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ChatDefaultLogic:setChatDefaultInfo(cmd, context)
	self.chatDefaultInfo = {}
	self.chatDefaultInfo = context
end

--[[
-- @brief  获取开始游戏数据
-- @param  void
-- @return void
--]]
function ChatDefaultLogic:getChatDefaultInfo()
	return self.chatDefaultInfo
end

--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function ChatDefaultLogic:exportMethods()
	self:exportMethods_({
        "setChatDefaultInfo",
        "getChatDefaultInfo",
    })
    return self.target_
end

return ChatDefaultLogic
