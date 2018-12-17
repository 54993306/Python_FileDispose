-------------------------------------------------------------
--  @file   MyselfPeng.lua
--  @brief  自己麻将碰，杠，胡，显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase")
local MyselfPeng 	= class("MyselfPeng", MjBase)
local offsetHeight = -8 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MyselfPeng:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MyselfPeng:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#self_peng_poker.png")
	self:addChild(spMjBg)
	-- self:setContentSize(spMjBg:getContentSize())
	if reality then
		self:setContentSize(spMjBg:getContentSize())
	else
		spMjBg:setPosition(cc.p(-2, -16))
		self:setContentSize(cc.size(51, 59))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)

	self:setWordScaleX(0.58)
	self:setWordScaleY(0.55)

	self:blackInit(spMjBg)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfPeng:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfPeng:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function MyselfPeng:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

function MyselfPeng:blackInit(spMjBg)
	local contentSize = spMjBg:getContentSize()
    self.blackLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 128), contentSize.width, contentSize.height)
    self.blackLayer:setAnchorPoint(cc.p(0.5, 0.5))
    spMjBg:addChild(self.blackLayer)
    self.blackLayer:setVisible(false)
end

function MyselfPeng:blackMj(value)
	if self.blackLayer then
		self.blackLayer:setVisible(value)
	else
		-- print("[ ERROR ] MyselfPeng:highLight by Linxiancheng")
	end
end

return MyselfPeng
