-------------------------------------------------------------
--  @file   ActionHu.lua
--  @brief  行为处理器 -- 胡牌
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:59:03
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local ActionHandler     = import(".ActionHandler")
local ActionHu = class("ActionHu", ActionHandler)

--[
-- @brief  执行
-- @param  context
-- @return void
--]
function ActionHu:run(context)
    local owner = self.manager.owner

end

return ActionHu
