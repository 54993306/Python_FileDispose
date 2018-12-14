---------------------------------------------------------------
--      @file  BasePart.lua
--     @brief  部件基类
--  @author Zhu Can Qin
--  @DateTime:2016-08-26 19:56:06
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--===============================================================

--[
-- @class BasePart
-- @brief 实体部件
--
--]
local BasePart = class("BasePart")

--[
-- @brief  构造函数
-- @param  owner 部件拥有者
-- @return void
--]
function BasePart:ctor(owner)
    self.owner = owner
    self.paused = false
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function BasePart:release()
    self:deactivate()
    self.owner = nil
end

--[
-- @brief  激活部件
-- @param  void
-- @return true/false
--]
function BasePart:activate()
    return true
end

--[
-- @brief  反激活部件
-- @param  void
-- @return true/false
--]
function BasePart:deactivate()
    return true
end

--[[
-- @brief  暂停
-- @param  void
-- @return void
--]]
function BasePart:pause()
    self.paused = true
end

--[[
-- @brief  恢复
-- @param  void
-- @return void
--]]
function BasePart:resume()
    self.paused = false
end

--[
-- @brief  获得部件ID
-- @param  void
-- @return id
--]
function BasePart:getPartId()
    return enPartDef.INVALID
end

return BasePart
