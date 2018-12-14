-------------------------------------------------------------
--  @file   GameLayerBase.lua
--  @brief  游戏层基类
--  @author Zhu Can Qin
--  @DateTime:2016-09-02 12:24:55
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local GameLayerBase = class("GameLayerBase", function ()
	return display.newLayer()
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameLayerBase:ctor()
	local scene = MjMediator:getInstance():getScene()
	scene:addChild(self)
end


return GameLayerBase