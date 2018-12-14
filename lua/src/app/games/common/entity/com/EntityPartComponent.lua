-------------------------------------------------------------
--  @file   EntityPartComponent.lua
--  @brief  实体部件组件
--  @author Zhu Can Qin
--  @DateTime:2016-08-26 19:50:38
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local Component = cc.Component
local PartFactory = import("..part.PartFactory", currentModuleName)

local EntityPartComponent = class("EntityPartComponent", Component)

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function EntityPartComponent:ctor()
    EntityPartComponent.super.ctor(self, "EntityPartComponent")
    self.parts = {}
    self.isActive = false
end

--[
-- @brief  激活部件
-- @param  void
-- @return void
--]
function EntityPartComponent:activateParts()
    if self.isActive then
        return
    end
    table.walk(self.parts, function(part)
        return part and part:activate()
    end)
    self.isActive = true
end

--[
-- @brief  反激活部件
-- @param  void
-- @return void
--]
function EntityPartComponent:deactivateParts()
    table.walk(self.parts, function(part)
        return part and part:deactivate()
    end)
    self.isActive = false
end

--[[
-- @brief  暂停
-- @param  void
-- @return void
--]]
function EntityPartComponent:pause()
    table.walk(self.parts, function(part)
        return part.pause and part:pause()
    end)
end

--[[
-- @brief  恢复
-- @param  void
-- @return void
--]]
function EntityPartComponent:resume()
    table.walk(self.parts, function(part)
        return part.resume and part:resume()
    end)
end

--[
-- @brief  添加部件
-- @param  partId
-- @return void
--]
function EntityPartComponent:addPart(partId)
    local part = PartFactory.createPart(partId, self.target_)

    assert(enPartDef.INVALID ~= part:getPartId(),
        "EntityPartComponent:addPart - 无效的部件ID, "..part.__cname)
    assert(nil == self.parts[part:getPartId()],
        "EntityPartComponent:addPart - 部件已经存在，ID="..part:getPartId())

    self.parts[part:getPartId()] = part
end

--[
-- @brief  移除部件
-- @param  partId 部件ID
-- @return part
--]
function EntityPartComponent:removePart(partId)
    assert(enPartDef.INVALID ~= partId,
        "EntityPartComponent:removePart - 无效的部件ID")
    assert(self.parts[partId],
        "EntityPartComponent:removePart - 移除的部件不存在，ID="..partId)

    local part = self.parts[partId]
    self.parts[partId] = nil
    return part
end

--[
-- @brief  获取部件
-- @param  partId 部件ID
-- @return 部件
--]
function EntityPartComponent:getPart(partId)
    assert(self.parts[partId],
        "EntityPartComponent:getPart - 不存在对应部件，ID="..partId)

    return self.parts[partId]
end

--[[
-- @brief  部件是否存在
-- @param  partId
-- @return true/false
--]]
function EntityPartComponent:hasPart(partId)
    return not not self.parts[partId]
end

--[
-- @brief  取消绑定
-- @param  void
-- @return void
--]
function EntityPartComponent:onUnbind_()
    table.walk(self.parts, function(part)
        part:release()
    end)
    self.parts = nil
end

--[
-- @brief  导出方法
-- @param  void
-- @return void
--]
function EntityPartComponent:exportMethods()
    self:exportMethods_({
        "addPart",
        "removePart",
        "getPart",
        "hasPart",
        "activateParts",
        "deactivateParts",
    })
    return self.target_
end

return EntityPartComponent
