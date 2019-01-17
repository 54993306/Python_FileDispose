-------------------------------------------------------------
--  @file   OtherOut.lua
--  @brief  lua 类定义
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 18:24:58
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local OtherOut 	= class("OtherOut", MjBase)
local offsetHeight = -5 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function OtherOut:ctor(mjValue)
	self.mjValue = mjValue
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function OtherOut:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#other_out_poker.png")
	self:addChild(spMjBg)

	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(0, 0))
		self:setContentSize(cc.size(40, 59))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	-- self:setWordScaleX(0.56)
	-- self:setWordScaleY(0.37)

	self:setWordScaleX(0.44)
	self:setWordScaleY(0.40)

	--self:setWordRotation(180)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function OtherOut:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function OtherOut:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function OtherOut:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return OtherOut