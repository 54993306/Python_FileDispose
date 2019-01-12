-------------------------------------------------------------
--  @file   MyselfNormal.lua
--  @brief  自己麻将正常显示
--
--  @author Zhu Can Qin
--
--  @DateTime:2016-08-05 12:17:54
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjBase 		= import(".MjBase") 
local MyselfNormal 	= class("MyselfNormal", MjBase)
local Define            = require("app.games.common.Define")

local offsetHeight = 12 -- 高度偏移量

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MyselfNormal:ctor(mjValue)
	self.mjValue = mjValue 
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function MyselfNormal:onShowView(reality)
	local pai 	= getCardPngByValue(self.mjValue)
	assert(pai ~= "" and pai ~= nil)
	local spMjBg = display.newSprite("#self_poker.png")
	self:addChild(spMjBg)
    spMjBg:setScale(Define.mj_myCards_scale)
	if reality then
		self:setContentSize(cc.size(spMjBg:getContentSize().width * Define.mj_myCards_scale, spMjBg:getContentSize().height * Define.mj_myCards_scale))
	else
		spMjBg:setPosition(cc.p(0, 0))
		self:setContentSize(cc.size(86 * Define.mj_myCards_scale, 100 * Define.mj_myCards_scale))
	end
	self.spMj = cc.Sprite:createWithSpriteFrameName(pai)
	self.spMj:setPosition(cc.p(spMjBg:getContentSize().width / 2+2, spMjBg:getContentSize().height / 2 - offsetHeight))
	spMjBg:addChild(self.spMj)
	self:setWordScaleX(0.85)
	self:setWordScaleY(0.83)
	-- self:setContentSize(spMjBg:getContentSize())
	self:initHighLight(spMjBg)
end

--[[
-- @brief  x轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfNormal:setWordScaleX(scaleto)
	self.spMj:setScaleX(scaleto)
end

--[[
-- @brief  y轴缩放函数
-- @param  void
-- @return void
--]]
function MyselfNormal:setWordScaleY(scaleto)
	self.spMj:setScaleY(scaleto)
end

--[[
-- @brief  旋转
-- @param  void
-- @return void
--]]
function MyselfNormal:setWordRotation(rate)
	self.spMj:setRotation(rate)
end

--[[
-- @brief  初始化高亮效果
-- @param  void
-- @return void
--]]
function MyselfNormal:initHighLight(spMjBg)

	local clipSize = spMjBg:getContentSize()
	self.spark = display.newSprite("#lightsweep_01.png")
	
	--动画依附的精灵
	local data = {}
	data.sprite = self.spark
	--动画的图片名称前缀
	data.imageName = "lightsweep"
	--动画的总共帧数
	data.frame = 31
	--动画播放几秒
	data.delayTime = 1
	--循环播放的间隔时间（不传值则不循环）
	data.delay = 3
	--第一帧动画的起始数
	data.sfn = 0
	--动画的命名规则
	data.fn = "%02d.png"
	AnimationManager.runAction(data)
	self.spark:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)--0x1, 0x0)
    -- self.spark:setOpacity(200)

	self.spark:setVisible(false)
	self.spark:setAnchorPoint(cc.p(0,0))
	spMjBg:addChild(self.spark)
end

--[[
-- @brief  高亮显示处理
-- @param  void
-- @return void
--]]
function MyselfNormal:highLight(value)
	if self.spark then
		self.spark:setVisible(value)
	else
		-- print("[ ERROR ] MyselfNormal:highLight by Linxiancheng")
	end
end

return MyselfNormal