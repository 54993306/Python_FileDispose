-------------------------------------------------------------
--  @file   SystemManager.lua
--  @brief  系统管理器
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 19:10:52
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local currentModuleName = ...
local GamePlaySystem    = import(".gameplay.GamePlaySystem", currentModuleName)
local ChatSystem        = import(".chat.ChatSystem", currentModuleName)
--local OperateSystem     = import(".operate.OperateSystem", currentModuleName)
local SystemFactory         = import(".SystemFactory")
local OperateSystemPath = SystemFactory.getOperateSystemPath(_gameType)
local OperateSystem  =  require(OperateSystemPath)
local FlowerOperateSystem      = import(".flower.FlowerOperateSystem", currentModuleName)
local ClockSystem       = import(".clock.ClockSystem", currentModuleName)
local SystemFacade      = import(".SystemFacade")

SystemManager           = class("SystemManager")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SystemManager:ctor()
    self.systems = {}
    self:addSystem(GamePlaySystem.new(self))
    self:addSystem(ChatSystem.new(self))
    self:addSystem(OperateSystem.new(self))
    self:addSystem(FlowerOperateSystem.new(self))
    self:addSystem(ClockSystem.new(self))
end

--[
-- @brief  析构函数
-- @param  void
-- @return void
--]
function SystemManager:dtor()
    table.walk(self.systems, function(system)
        system:release()
    end)
    self.systems = nil
end

--[
-- @brief  添加系统
-- @param  system
-- @return void
--]
function SystemManager:addSystem(system)
    self.systems[system:getSystemId()] = system
end

-- --[
-- -- @brief  释放函数
-- -- @param  void
-- -- @return void
-- --]
-- function SystemManager:release()
--     table.walk(self.systems, function(system)
--         system:release()
--     end)
--     self.systems = nil
-- end

--[
-- @brief  激活所有系统
-- @param  context
-- @return void
--]
function SystemManager:activate(context)
    self:getSystem(enSystemDef.CHAT_SYSTEM):activate(context)
    self:getSystem(enSystemDef.GAME_PLAY_SYSTEM):activate(context)
    self:getSystem(enSystemDef.OPERATE_SYSTEM):activate(context)
    self:getSystem(enSystemDef.FLOWER_OPERATE_SYSTEM):activate(context)
    self:getSystem(enSystemDef.CLOCK_SYSTEM):activate(context)
    return true
end

--[
-- @brief  反激活所有系统
-- @param  void
-- @return void
--]
function SystemManager:deactivate()
    table.walk(self.systems, function(system)
        system:deactivate()
    end)
    SystemFacade.releaseInstance()
end

--[
-- @brief  获取系统
-- @param  sysid
-- @return void
--]
function SystemManager:getSystem(sysid)
    return self.systems[sysid]
end

return SystemManager
