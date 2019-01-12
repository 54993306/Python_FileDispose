-------------------------------------------------------------
--  @file   ActionAnGang.lua
--  @brief  行为处理器 -- 暗杠
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:59:31
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local ActionHandler     = import(".ActionHandler")
local ActionAnGang = class("ActionAnGang", ActionHandler)

--[
-- @brief  执行
-- @param  context
-- @return void
--]
function ActionAnGang:run(context)
    local owner = self.manager.owner
   
end

return ActionAnGang
