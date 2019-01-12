-------------------------------------------------------------
--  @file   Entity.lua
--  @brief  生物基类
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:34:31
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local Entity       = import(".Entity", currentModuleName)

--[
-- @class Creature
-- @brief 生物
--
--]
local Creature = class("Creature", Entity)

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function Creature:ctor(context)
    Creature.super.ctor(self, context)
    cc(self):addComponent("app.games.common.entity.com.EntityPartComponent"):exportMethods()
    cc(self):addComponent("app.games.common.entity.com.CreatureStateComponent"):exportMethods()
    self:initialize(context)
end

--[
-- @brief  初始化函数
-- @param  context 现场
-- @return 本身
--]
function Creature:initialize(context)
    self.context = context
    return self
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function Creature:release()
    self:deactivate()
    cc(self):removeComponent("app.games.common.entity.com.EntityPartComponent")
    cc(self):removeComponent("app.games.common.entity.com.CreatureStateComponent")
    Creature.super.release(self)
end

--[
-- @brief  激活对象
-- @param  void
-- @return void
--]
function Creature:activate()
    self:activateParts()
end

--[
-- @brief  反激活对象
-- @param  void
-- @return void
--]
function Creature:deactivate()
  
end

--[[
-- @brief  获取生物现场
-- @param  void
-- @return table
--]]
function Creature:getContext()
    return self.context
end


return Creature
