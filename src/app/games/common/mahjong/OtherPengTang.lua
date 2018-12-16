-------------------------------------------------------------
--  @file   OtherPengTang.lua
--  @brief  其他的碰躺下的牌
--  @author Zhu Can Qin
--  @DateTime:2016-08-08 09:37:16
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local MjBase 			= import(".MjBase")
local OtherPengTang 	= class("OtherPengTang", MjBase)
local offsetHeight = -7 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function OtherPengTang:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function OtherPengTang:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	self.spMjBg = display.newSprite("#other_poker_tang.png")
	self:addChild(self.spMjBg)

    if not IsPortrait then -- TODO
        --  盖牌纹理
        self.m_Reverse = display.newSprite("#hengpaidun.png")
        self:addChild(self.m_Reverse)
        self.m_Reverse:setVisible(false)
        --self.m_Reverse:setScale(1.35)
    end

	if reality then
		self:setContentSize(self.spMjBg:getContentSize())
	else
		self.spMjBg:setPosition(cc.p(0, -10))
        if not IsPortrait then -- TODO
            self.m_Reverse:setPosition(cc.p(0, -10))
        end
		self:setContentSize(cc.size(42, 27))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(self.spMjBg:getContentSize().width / 2, self.spMjBg:getContentSize().height / 2 - offsetHeight))
	self.spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.35)
	self:setWordScaleY(0.35)
	self:setWordRotation(-90)
end

--[[
    @biref  设置麻将是否盖牌
    @param  isClosed    true：盖牌；false：盖牌
--]]
function OtherPengTang:closedCard(isClosed)
    self.spMjBg:setVisible(not isClosed)
    self.m_Reverse:setVisible(isClosed)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function OtherPengTang:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function OtherPengTang:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function OtherPengTang:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return OtherPengTang