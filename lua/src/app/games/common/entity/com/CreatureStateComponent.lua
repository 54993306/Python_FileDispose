-------------------------------------------------------------
--  @file   CreatureStateComponent.lua
--  @brief  生物状态
--  @author Zhu Can Qin
--  @DateTime:2016-09-09 17:04:38
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Component = cc.Component
local CreatureStateComponent = class("CreatureStateComponent", Component)

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function CreatureStateComponent:ctor()
    CreatureStateComponent.super.ctor(self, "CreatureStateComponent")
    self.States = {}
end

--[
-- @brief  状态组
-- @param  state_id 状态
-- @param  value 状态值
-- @return void
--]
function CreatureStateComponent:setState(state_id, value)
    if type(state_id) ~= "number" then
        printError("PropertypCom:setProp - state_id不是数字")
        return
    end
    local oldvalue  = self:getState(state_id)
    local changed   = self.States[state_id] ~= value
    if type(value) == "number" then
        self.States[state_id] = self:pxnr(value)
    else
        self.States[state_id] = value
    end
    -- 属性变更就向外部发送通知
    if changed then
        self:getTarget():dispatchCustomEvent(enEntityEvent.ENTITY_STATE_CHANGED_NTF, state_id, value, oldvalue)
    end
end

--[
-- @brief  取得状态
-- @param  state_id 状态ID
-- @return number
--]
function CreatureStateComponent:getState(state_id)
    return self.States[state_id]
end

--[
-- @brief  获取所有状态
-- @param  void
-- @return table
--]
function CreatureStateComponent:getStates()
    return self.States
end

--[[
-- @brief  prop xnor
-- @param  value
-- @return number
--]]
function CreatureStateComponent:pxnr(value)
    -- local director = cc.Director:getInstance()
    -- local addr = require "ffi".cast("int*", director)[0]
    -- return bit.bxor(addr, value)
    return value
end

--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function CreatureStateComponent:onBind_()

end

--[
-- @brief  取消绑定
-- @param  void
-- @return void
--]
function CreatureStateComponent:onUnbind_()
    self.States = nil
end

--[
-- @brief  导出方法
-- @param  void
-- @return void
--]
function CreatureStateComponent:exportMethods()
    self:exportMethods_({
        "setState",
        "getState",
        "getStates",
    })
    return self.target_
end

return CreatureStateComponent
