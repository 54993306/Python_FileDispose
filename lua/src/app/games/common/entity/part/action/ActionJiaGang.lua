-------------------------------------------------------------
--  @file   ActionJiaGang.lua
--  @brief  行为处理器 -- 加杠
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 10:58:37
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local ActionHandler    = import(".ActionHandler")
local ActionJiaGang = class("ActionJiaGang", ActionHandler)

--[
-- @brief  构造函数
-- @param  manager
-- @return
--]
function ActionJiaGang:ctor(manager)
    ActionJiaGang.super.ctor(self, manager)
end

--[
-- @brief  执行
-- @param  context
--          {
--              direction, -- 方向
--          }
-- @return void
--]
function ActionJiaGang:run(context)
   
end

--[
-- @brief  停止
-- @param  void
-- @return void
--]
function ActionJiaGang:stop()
    self.manager.owner:setPhysicsSpeedX(0)
end

--[
-- @brief  超时处理
-- @param  dt 间隔
-- @return void
--]
function ActionJiaGang:onTimeout(dt)
    self:stop()
end

return ActionJiaGang
