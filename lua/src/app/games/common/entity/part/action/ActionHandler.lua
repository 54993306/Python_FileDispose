-------------------------------------------------------------
--  @file   ActionHandler.lua
--  @brief  行为处理器
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:00:31
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local ActionHandler = class("ActionHandler")

--[
-- @brief  构造函数
-- @param  manager
-- @return
--]
function ActionHandler:ctor(manager)
    self.manager = manager
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function ActionHandler:release()
    self:stop()
    self.manager = nil
end

--[
-- @brief  执行
-- @param  context
-- @return void
--]
function ActionHandler:run(context)
    return true
end

--[
-- @brief  停止
-- @param  void
-- @return void
--]
function ActionHandler:stop()

end

return ActionHandler
