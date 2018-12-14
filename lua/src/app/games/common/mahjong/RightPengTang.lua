-------------------------------------------------------------
--  @file   RightPengTang.lua
--  @brief  右边碰躺下的牌
--  @author Zhu Can Qin
--  @DateTime:2016-08-08 09:33:58
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local MjBase 			= import(".MjBase")
local RightPengTang 	= class("RightPengTang", MjBase)
local offsetHeight = -7 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RightPengTang:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RightPengTang:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	self.spMjBg = display.newSprite("#right_poker_tang.png")
	self:addChild(self.spMjBg)

    if not IsPortrait then -- TODO
        --  盖牌纹理
        self.m_Reverse = display.newSprite("#shupaidun.png")
        self:addChild(self.m_Reverse)
        self.m_Reverse:setVisible(false)
        self.m_Reverse:setScale(1.23)
    end

	if reality then
		self:setContentSize(self.spMjBg:getContentSize())
	else
		self.spMjBg:setPosition(cc.p(0, -14))
        if not IsPortrait then -- TODO
            self.m_Reverse:setPosition(cc.p(0, -14))
        end
		self:setContentSize(cc.size(40, 40))
	end

	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(self.spMjBg:getContentSize().width / 2, self.spMjBg:getContentSize().height / 2 - offsetHeight))
	self.spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.40)
	self:setWordScaleY(0.34)
	self:setWordRotation(180)
end

--[[
    @biref  设置麻将是否盖牌
    @param  isClosed    true：盖牌；false：盖牌
--]]
function RightPengTang:closedCard(isClosed)
    self.spMjBg:setVisible(not isClosed)
    self.m_Reverse:setVisible(isClosed)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function RightPengTang:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function RightPengTang:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function RightPengTang:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

return RightPengTang
