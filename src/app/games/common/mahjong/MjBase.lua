-------------------------------------------------------------
--  @file   MjBase.lua
--  @brief  自己打出去麻将显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase = class("MjBase", function ()
	local ret = display.newNode()
    ret:setCascadeOpacityEnabled(true)
    ret:setCascadeColorEnabled(true)
    return ret
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MjBase:ctor(mjValue)
	
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MjBase:onShowView()

end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function MjBase:setWordRotation(rate)
	
end

return MjBase