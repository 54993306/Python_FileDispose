-------------------------------------------------------------
--  @file   ChatSystem.lua
--  @brief  聊天系统
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 19:36:55
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local SystemBase 	= import("..SystemBase", currentModuleName)
local ChatSystem 	= class("ChatSystem", SystemBase)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ChatSystem:ctor()

end

--[
-- @override
--]
function ChatSystem:release()
   	
end

--[
-- @override
--]
function ChatSystem:activate(context)
   	cc(self):addComponent("app.games.common.system.chat.ChatDefaultLogic"):exportMethods()
   	cc(self):addComponent("app.games.common.system.chat.ChatCustomLogic"):exportMethods()
end

--[
-- @override
--]
function ChatSystem:deactivate()
   	cc(self):removeComponent("app.games.common.system.chat.ChatDefaultLogic")
   	cc(self):removeComponent("app.games.common.system.chat.ChatCustomLogic")
end

--[
-- @override
--]
function ChatSystem:getSystemId()
    return enSystemDef.CHAT_SYSTEM
end

return ChatSystem