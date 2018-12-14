-------------------------------------------------------------
--  @file   RightPeng.lua
--  @brief  右边碰，杠
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 12:19:00
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local RightPeng 	= class("RightPeng", MjBase)
local offsetHeight = -9 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RightPeng:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RightPeng:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#right_peng_poker.png")
	self:addChild(spMjBg)

	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(0, -18))
		self:setContentSize(cc.size(54, 34))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.46)
	self:setWordScaleY(0.44)
	self:setWordRotation(-90)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function RightPeng:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function RightPeng:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function RightPeng:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return RightPeng
