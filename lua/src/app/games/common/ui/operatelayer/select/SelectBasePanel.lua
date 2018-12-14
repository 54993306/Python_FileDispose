-------------------------------------------------------------
--  @file   SelectBasePanel.lua
--  @brief  操作基类
--  @author Zhu Can Qin
--  @DateTime:2016-09-06 18:07:57
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local SelectBasePanel = class("SelectBasePanel", function ()
	local ret = ccui.Widget:create()
    ret:ignoreContentAdaptWithSize(false)
    ret:setAnchorPoint(cc.p(0.5, 0.5))
    return ret
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SelectBasePanel:ctor()
	self.content = nil
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function SelectBasePanel:onShow(content)
	self.content = content
end

--[[
-- @brief  隐藏函数
-- @param  void
-- @return void
--]]
function SelectBasePanel:onHide()
	self:removeAllChildren()
end

--[[
-- @brief  获取传进来的内容
-- @param  void
-- @return void
--]]
function SelectBasePanel:getContent()
	return self.content
end

return SelectBasePanel