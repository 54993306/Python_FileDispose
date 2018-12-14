-------------------------------------------------------------
--  @file   LeftOut.lua
--  @brief  其他人麻将碰，杠，胡，显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local LeftOut 		= class("LeftOut", MjBase)
local offsetHeight = -7 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function LeftOut:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function LeftOut:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#left_out_poker.png")
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
	self:setWordScaleY(0.40)
	self:setWordRotation(90)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function LeftOut:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function LeftOut:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function LeftOut:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return LeftOut