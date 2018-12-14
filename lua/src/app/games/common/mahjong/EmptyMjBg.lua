-------------------------------------------------------------
--  @file   EmptyMjBg.lua
--  @brief  没有字杠的时候显示
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 14:49:53
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 			= require "app.games.common.Define"
local MjBase 			= import(".MjBase") 
local EmptyMjBg 		= class("EmptyMjBg", MjBase)
local Define            = require("app.games.common.Define")
local kMjBg = {
	[enMjType.EMPTY_MYSELF_GANG] = "#self_gang_poker.png", --
	[enMjType.EMPTY_RIGHT_GANG]  = "#right_gang_poker.png",--
	[enMjType.EMPTY_RIGHT_IDLE]  = "#right_poker.png",--
	[enMjType.EMPTY_LEFT_GANG]   = "#left_gang_poker.png",--
	[enMjType.EMPTY_LEFT_IDLE]   = "#left_poker.png",--
	[enMjType.EMPTY_OTHER_GANG]  = "#other_gang_poker.png",
	[enMjType.EMPTY_OTHER_IDLE]  = "#other_poker.png",--
	[enMjType.EMPTY_SHU_PAI]     = "#shupaidun.png",--
	[enMjType.EMPTY_HENG_PAI]    = "#hengpaidun.png",--
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]

local function posOrSizeScale(arg, scaleRatio)
	if type(arg) == "table" and type(scaleRatio) == "number" then
		if arg.x then arg.x = arg.x * scaleRatio end
		if arg.y then arg.y = arg.y * scaleRatio end
		if arg.width then arg.width = arg.width * scaleRatio end
		if arg.height then arg.height = arg.height * scaleRatio end
	end
	return arg
end

function EmptyMjBg:ctor(valuePng, mjValue)
	local scaleRatio = Define.mj_common_scale
	self.mjValue = mjValue
 	local spMjBg = display.newSprite(kMjBg[valuePng])
 	spMjBg:setScale(scaleRatio)
	self:addChild(spMjBg)

	if enMjType.EMPTY_LEFT_IDLE == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, -18), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(30, 30), scaleRatio))
	elseif enMjType.EMPTY_RIGHT_IDLE == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, 0), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(30, 30), scaleRatio))
	elseif enMjType.EMPTY_OTHER_IDLE == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, 0), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(37, 50), scaleRatio))
	elseif enMjType.EMPTY_OTHER_GANG == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, -6), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(36, 50), scaleRatio))
	elseif enMjType.EMPTY_MYSELF_GANG == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(-2, -16), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(51, 59), scaleRatio))
	elseif enMjType.EMPTY_RIGHT_GANG == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, -16), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(57, 35), scaleRatio))
	elseif enMjType.EMPTY_LEFT_GANG == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, -16), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(34, 35), scaleRatio))
	elseif enMjType.EMPTY_SHU_PAI == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(-4, -4), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(30, 35), scaleRatio))
	elseif enMjType.EMPTY_HENG_PAI == valuePng then
		spMjBg:setPosition(posOrSizeScale(cc.p(0, 0), scaleRatio))
		self:setContentSize(posOrSizeScale(cc.size(47, 39), scaleRatio))
	else
		self:setContentSize(posOrSizeScale(spMjBg:getContentSize()), scaleRatio)
	end
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function EmptyMjBg:onShowView()
	
end

return EmptyMjBg
