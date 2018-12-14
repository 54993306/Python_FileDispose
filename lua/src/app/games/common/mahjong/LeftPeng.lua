-------------------------------------------------------------
--  @file   LeftPeng.lua
--  @brief  其他人麻将碰，杠，胡，显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local LeftPeng 		= class("LeftPeng", MjBase)
local offsetHeight = -9 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function LeftPeng:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function LeftPeng:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#left_peng_poker.png")
	self:addChild(spMjBg)
	
	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(0, -18))
		self:setContentSize(cc.size(52, 34))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.46)
	self:setWordScaleY(0.44)
	self:setWordRotation(90)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function LeftPeng:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function LeftPeng:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function LeftPeng:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return LeftPeng