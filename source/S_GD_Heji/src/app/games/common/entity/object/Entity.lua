-------------------------------------------------------------
--  @file   Entity.lua
--  @brief  游戏实体
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:34:52
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
--[
-- @class Entity
-- @brief 实体基类
--
--]
local Entity = class("Entity")

--[
-- @brief  构造函数
-- @param  context
-- @return void
--]
function Entity:ctor(context)
    cc(self):addComponent("app.games.common.components.EventServer"):exportMethods()
    cc(self):addComponent("app.games.common.entity.com.PropertyComponent"):exportMethods()
    self.context = context
    self.valid = true
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function Entity:release()
    cc(self):removeComponent("app.games.common.components.EventServer")
    cc(self):removeComponent("app.games.common.entity.com.PropertyComponent")
    self.valid      = false
    self.context    = nil
end

--[[
-- @brief  实体是否有效
-- @param  void
-- @return true/false
--]]
function Entity:isValid()
    return self.valid
end

--[[
-- @brief  返回对象地址
-- @param  void
-- @return void
--]]
function Entity:ptr()
    return tonumber((string.gsub(tostring(self), "table: ", "")))
end

--[[
-- @brief  获取现场
-- @param  void
-- @return table or nil
--]]
function Entity:getContext()
    return self.context
end

--[
-- @brief  取得实体类型
-- @param  void
-- @return 见enEntityType定义
--]
function Entity:getType()
    return enEntityType.INVALID_TYPE
end

return Entity

