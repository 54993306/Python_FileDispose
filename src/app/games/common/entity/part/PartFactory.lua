---------------------------------------------------------------
--  @file  PartFactory.lua
--  @brief  部件工厂
--  @author Zhu Can Qin
--  @DateTime:2016-08-26 19:56:53
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--===============================================================

local CURRENT_MODULE_NAME = ...
--[
-- @class PartFactory
-- @brief 部件工厂
--]
local PartFactory = class("PartFactory")

local classes = {
    [enPartDef.ACTION_PART]    = ".action.ActionPart",
}

--[
-- @brief  创建部件
-- @param  partid 部件ID
-- @param  owner 部件拥有者
-- @return part
--]
function PartFactory.createPart(partid, owner)
    if nil == classes[partid] then
        printError("PartFactory.createPart - 无效的部件ID：%s", tostring(partid))
        return nil
    end

    local cls = import(classes[partid], CURRENT_MODULE_NAME)
    return cls.new(owner)
end

return PartFactory
