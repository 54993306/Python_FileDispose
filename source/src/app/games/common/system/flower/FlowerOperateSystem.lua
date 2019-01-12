-------------------------------------------------------------
--  @file   FlowerOperateSystem.lua
--  @brief  补花操作
--  @author Zhu Can Qin
--  @DateTime:2016-08-31 10:08:27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local SystemBase 	= import("..SystemBase", currentModuleName)
local FlowerOperateSystem 	= class("FlowerOperateSystem", SystemBase)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function FlowerOperateSystem:ctor()
	
end

--[
-- @override
--]
function FlowerOperateSystem:release()
   
end

--[
-- @override
--]
function FlowerOperateSystem:activate(context)
   
end

--[
-- @override
--]
function FlowerOperateSystem:deactivate()
   
end

--[[
-- @brief  设置补花数据数据
-- @param  void
-- @return void
--]]
function FlowerOperateSystem:setFlowerOperateDatas(cmd, context)
	dump(context)
   	self.flowerDatas = {}
   	self.flowerDatas.userid 	= info.usID
    self.flowerDatas.actionCard = info.flC
    self.flowerDatas.plyerCard 	= info.ca
end

--[
-- @override
--]
function FlowerOperateSystem:getSystemId()
    return enSystemDef.FLOWER_OPERATE_SYSTEM
end

return FlowerOperateSystem