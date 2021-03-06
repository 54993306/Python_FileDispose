-------------------------------------------------------------
--  @file   MyselfOut.lua
--  @brief  自己打出去麻将显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 	= import(".MjBase")
local MyselfOut = class("MyselfOut", MjBase)
local offsetHeight = -5 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MyselfOut:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MyselfOut:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil, "self.mjValue = "..self.mjValue)
	local spMjBg = display.newSprite("#self_out_poker.png")
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
	self:setWordScaleX(0.52)
	self:setWordScaleY(0.40)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfOut:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfOut:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function MyselfOut:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return MyselfOut