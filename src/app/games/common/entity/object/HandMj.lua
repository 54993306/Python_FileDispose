-------------------------------------------------------------
--  @file   HandMj.lua
--  @brief  玩家对象
--  @author Zhu Can Qin
--  @DateTime:2016-08-26 18:28:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local Entity 	= import(".Entity", currentModuleName)
local HandMj 	= class("HandMj", Entity)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
-- 实体属性
-- enCreatureEntityProp = {
-- 	USERID  = 1, 	-- 用户id
-- 	NAME 	= 2,	-- 名字  
-- 	LEVEL   = 3,    -- 等级
-- 	GENDER  = 4,    -- 性别
-- 	FORTUNE = 5,    -- 财富
-- 	VIP_EXP = 6,    -- VIP经验
-- 	VIP     = 7,    -- VIP等级
-- 	ICON_ID = 8,    -- 头像 
--  WIN     = 9,    -- 赢
-- 	WIN_PRE = 10,   -- 之前赢
-- 	TOTAL   = 11,  -- 总
-- 	SEX     = 12,   -- 性别
-- 	FLOWER  = 13,   -- 花牌
-- 	BANKER  = 14,   -- 庄家或者是先出牌的玩家
-- },
function HandMj:ctor(context)
	HandMj.super.ctor(self, context)
	-- 设置属性
	self:setProp(enGoodsProp.VALUE, 	context.value)
	-- self:setProp(enGoodsProp.ID, 		context.id or 0)
	self:setProp(enGoodsProp.NUMBER, 	context.number or 0)
end
	
--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function HandMj:release()
    HandMj.super.release(self)
end

--[
-- @override
--]
function HandMj:activate()
    HandMj.super.activate(self)
end

--[
-- @override
--]
function HandMj:deactivate()
    HandMj.super.deactivate(self)
end
return HandMj