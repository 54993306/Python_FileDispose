-------------------------------------------------------------
--  @file   OtherPeng.lua
--  @brief  其他玩家麻将碰，杠，胡，显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local OtherPeng 	= class("OtherPeng", MjBase)
local offsetHeight = -5 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function OtherPeng:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function OtherPeng:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#other_peng_poker.png")
	self:addChild(spMjBg)

	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(0, -5))
		self:setContentSize(cc.size(38, 54))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.45)
	self:setWordScaleY(0.45)
	self:setWordRotation(180)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function OtherPeng:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function OtherPeng:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function OtherPeng:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return OtherPeng