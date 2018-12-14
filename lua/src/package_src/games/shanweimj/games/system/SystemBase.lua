-------------------------------------------------------------
--  @file   SystemBase.lua
--  @brief  系统基类
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 16:52:33
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local SystemBase = class("SystemBase")

function SystemBase:ctor(manager)
    self.manager = manager
end

--[
-- need override me
--]
function SystemBase:release()
end

--[
-- need override me
--]
function SystemBase:activate(context)
    return true
end

--[
-- need override me
--]
function SystemBase:deactivate()
end

--[
-- need override me
--]
function SystemBase:updateContext(context)
end

--[
-- need override me
--]
function SystemBase:shouldNotify()
    return false
end

--[
-- need override me
--]
function SystemBase:getSystemId()
    return enSystemDef.INVALID
end

return SystemBase
