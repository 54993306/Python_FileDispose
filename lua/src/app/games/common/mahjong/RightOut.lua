-------------------------------------------------------------
--  @file   RightOut.lua
--  @brief  右边打出去的牌
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 12:21:19
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local MjBase 		= import(".MjBase")
local RightOut 	= class("RightOut", MjBase)
local offsetHeight = -8 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RightOut:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RightOut:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#right_out_poker.png")
	self:addChild(spMjBg)

	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(2, 0))
		self:setContentSize(cc.size(50, 46))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.36)
	self:setWordScaleY(0.38)
	self:setWordRotation(-90)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function RightOut:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function RightOut:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function RightOut:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return RightOut