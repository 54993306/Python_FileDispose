-------------------------------------------------------------
--  @file   PropertyComponent.lua
--  @brief  实体属性组件
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 09:48:26
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Component = cc.Component
local PropertyComponent = class("PropertyComponent", Component)

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function PropertyComponent:ctor()
    PropertyComponent.super.ctor(self, "PropertyComponent")
    self.props = {}
end

--[
-- @brief  设置属性
-- @param  prop_id 属性ID
-- @param  value 属性值
-- @return void
--]
function PropertyComponent:setProp(prop_id, value)
    if type(prop_id) ~= "number" then
        printError("PropertypCom:setProp - prop_id不是数字")
        return
    end
    local oldvalue  = self:getProp(prop_id)
    local changed   = self.props[prop_id] ~= value
    if type(value) == "number" then
        self.props[prop_id] = self:pxnr(value)
    else
        self.props[prop_id] = value
    end
    -- 属性变更就向外部发送通知
    if changed then
        self:getTarget():dispatchCustomEvent(enEntityEvent.ENTITY_PROP_CHANGED_NTF, prop_id, value, oldvalue)
    end
end

--[
-- @brief  取得属性
-- @param  prop_id 属性ID
-- @return number
--]
function PropertyComponent:getProp(prop_id)
    return self.props[prop_id]
end

--[
-- @brief  获取所有属性
-- @param  void
-- @return table
--]
function PropertyComponent:getProps()
    return self.props
end

--[[
-- @brief  prop xnor
-- @param  value
-- @return number
--]]
function PropertyComponent:pxnr(value)
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
function PropertyComponent:onBind_()

end

--[
-- @brief  取消绑定
-- @param  void
-- @return void
--]
function PropertyComponent:onUnbind_()
    self.props = nil
end

--[
-- @brief  导出方法
-- @param  void
-- @return void
--]
function PropertyComponent:exportMethods()
    self:exportMethods_({
        "setProp",
        "getProp",
        "getProps",
    })
    return self.target_
end

return PropertyComponent
