
-------------------------------------------------------------
--  @file   Mj.lua
--  @brief  麻将对象
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 09:51:42
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 		= require "app.games.common.Define"
local MyselfNormal 	= require "app.games.common.mahjong.MyselfNormal"
local MyselfPeng 	= require "app.games.common.mahjong.MyselfPeng"
local MyselfPengTang = require "app.games.common.mahjong.MyselfPengTang"
local MyselfOut 	= require "app.games.common.mahjong.MyselfOut"
local LeftPeng  	= require "app.games.common.mahjong.LeftPeng"
local LeftPengTang  = require "app.games.common.mahjong.LeftPengTang"
local LeftOut    	= require "app.games.common.mahjong.LeftOut"
local RightPeng  	= require "app.games.common.mahjong.RightPeng"
local RightPengTang = require "app.games.common.mahjong.RightPengTang"
local RightOut    	= require "app.games.common.mahjong.RightOut"
local OtherPeng    	= require "app.games.common.mahjong.OtherPeng"
local OtherPengTang = require "app.games.common.mahjong.OtherPengTang"
local OtherOut    	= require "app.games.common.mahjong.OtherOut"
local EmptyMjBg    	= require "app.games.common.mahjong.EmptyMjBg"

local Mj = class("Mj", function ()
	-- local ret = ccui.Widget:create()
 --    ret:ignoreContentAdaptWithSize(false)
 --    ret:setAnchorPoint(cc.p(0, 0.5))
 --    return ret
 	local ret = display.newNode()
    ret:setCascadeOpacityEnabled(true)
    ret:setCascadeColorEnabled(true)
    ret:setAnchorPoint(cc.p(0, 0.5))
    return ret
end)

--[[
-- @brief  构造函数
-- @param  mjType 	麻将类型
-- @param  mjValue  麻将值
-- @param  isReality  是否是实际大小，bool类型
-- @return void
--]]
function  Mj:ctor(mjType, mjValue, isReality)
	self.value 		= mjValue or nil
	self.sortValue 	= mjValue or 200
	self.mjState = enMjState.MJ_STATE_NORMAL
	self._isQueCard = false;
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
 --    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
 --    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    -- 根据类型选择麻将显示方式
    self.mjType = mjType
	local mjTypeCls = {
		[enMjType.MYSELF_NORMAL] 	= MyselfNormal,
		[enMjType.MYSELF_PENG] 		= MyselfPeng,
		[enMjType.MYSELF_PENG_TANG] = MyselfPengTang,
		[enMjType.MYSELF_OUT] 		= MyselfOut,
		[enMjType.LEFT_PENG] 		= LeftPeng,
		[enMjType.LEFT_PENG_TANG] 	= LeftPengTang,
		[enMjType.LEFT_OUT] 	    = LeftOut,
		[enMjType.RIGHT_PENG] 		= RightPeng,
		[enMjType.RIGHT_PENG_TANG] 	= RightPengTang,
		[enMjType.RIGHT_OUT] 		= RightOut,
		[enMjType.OTHER_PENG] 		= OtherPeng,
		[enMjType.OTHER_PENG_TANG] 	= OtherPengTang,
		[enMjType.OTHER_OUT] 		= OtherOut,
		[enMjType.EMPTY_MYSELF_GANG] = EmptyMjBg,
		[enMjType.EMPTY_RIGHT_GANG]  = EmptyMjBg,
		[enMjType.EMPTY_RIGHT_IDLE]  = EmptyMjBg,
		[enMjType.EMPTY_LEFT_GANG]   = EmptyMjBg,
		[enMjType.EMPTY_LEFT_IDLE]   = EmptyMjBg,
		[enMjType.EMPTY_OTHER_GANG]  = EmptyMjBg,
		[enMjType.EMPTY_OTHER_IDLE]  = EmptyMjBg,
		[enMjType.EMPTY_HENG_PAI]  	= EmptyMjBg,
		[enMjType.EMPTY_SHU_PAI]  	= EmptyMjBg,
	}
	-- 区分是空的还是有字的麻将
	if mjValue and  mjTypeCls[mjType] then
		self.mjCls = mjTypeCls[mjType].new(mjValue)
	elseif mjType >= enMjType.EMPTY_MYSELF_GANG 
		and  mjTypeCls[mjType]  then
		self.mjCls = mjTypeCls[mjType].new(mjType, 0)
	else
		if nil == mjValue then
			-- print("Mj:ctor 无效的牌值 mjValue = nil")
		elseif nil == mjType then
			-- print("Mj:ctor 麻将类型索引 mjType = nil")
		end
		return 
	end
	if not isReality then
		self.mjCls:onShowView(isReality)
	else
		self.mjCls:onShowView(true)
	end
	
	-- 设置大小
	self:setContentSize(self.mjCls:getContentSize())

	self:addChild(self.mjCls)
end
--[[
-- @brief  释放函数
-- @param  void
-- @return void
--]]
function Mj:dtor()
	-- self:removeFromParent()
end

--[[
-- @brief  设置麻将状态函数
-- @param  state 麻将状态
-- @return void
--]]
function Mj:setMjState(state)
	if self.mjState == enMjState.MJ_STATE_CANT_TOUCH then return end
	if state == enMjState.MJ_STATE_NORMAL then
		if self:getNumberOfRunningActions() == 0 then
			if self:getPositionY() ~= Define.mj_myCards_position_y then
				self.mjState = state
				self:setPosition(cc.p(self:getPositionX(), Define.mj_myCards_position_y))
			end
		end
	elseif state == enMjState.MJ_STATE_SELECTED then
		if self:getPositionY() == Define.mj_myCards_position_y then
			self.mjState = state
			self:setPosition(cc.p(self:getPositionX(), 
				Define.mj_myCards_position_y + enHandCardPos.STANDING_HEIGHT))
		end
	elseif state == enMjState.MJ_STATE_TOUCH_INVALID then
		self.mjState = state
		self:setColor(cc.c3b(166, 166, 166))
	elseif state == enMjState.MJ_STATE_TOUCH_VALID then
		self.mjState = state
		if not self._isQueCard then
			self:setColor(display.COLOR_WHITE)
		end
	elseif state == enMjState.MJ_STATE_ALREADY_SELECTED then
		self.mjState = state
    elseif state == enMjState.MJ_STATE_TOUCH_OUT then
        self.mjState = state
        self:setColor(cc.c3b(140, 140, 230))
    elseif state == enMjState.MJ_STATE_CANT_TOUCH then
		self.mjState = state
		self:setColor(cc.c3b(166, 166, 166))
	end
end

--定缺牌型
function Mj:setDingQueType(queType)
	if queType and queType > 0 then
		if math.floor(self.value/10) == queType then
			self._isQueCard = true;
			self:setColor(cc.c3b(166, 166, 166));
		end
	end
end

--是否定缺牌型
function Mj:isDingQueType()
	return self._isQueCard or false;
end

--[[
-- @brief  获取麻将状态函数
-- @param  void
-- @return void
--]]
function Mj:getMjState()
	return self.mjState
end

--[[
-- @brief  检查是否与麻将相交函数
-- @param  px x坐标
-- @param  py y坐标
-- @return void
--]]
function Mj:isContainsTouch(px, py)
	local nodePoint = cc.p(px, py)
	local rect = self:getBoundingBox()
	rect.x = rect.x - self:getContentSize().width / 2
	rect.y = rect.y - self:getContentSize().height
    rect.height = rect.height+self:getContentSize().height / 2
	local b = cc.rectContainsPoint(rect, nodePoint)
	return b
end

--[[
-- @brief  检查拖拽区域
-- @param  px:相交的x坐标
-- @param  py:相交的y坐标
-- @return void
--]]
function Mj:isContainsDragTouch(px, py)
	local nodePoint = cc.p(px, py)
	local rect = self:getBoundingBox()
	rect.x = rect.x - self:getContentSize().width / 2
	rect.y = rect.y 
	local b = cc.rectContainsPoint(rect, nodePoint)
	return b
end

--[[
-- @brief  获取麻将的值函数
-- @param  void
-- @return void
--]]
function Mj:getValue()
	return self.value
end

--[[
-- @brief  设置麻将的排序值
-- @param  void
-- @return void
--]]
function Mj:setSortValue(value)
	self.sortValue = value
end

--[[
-- @brief  获取当前麻将的类型，其实就是获取它创建的摆放方式
-- @param  void
-- @return void
--]]
function Mj:getCardPutType()
	return self.mjType
end

--[[
-- @brief  获取麻将排序值
-- @param  void
-- @return void
--]]
function Mj:getSortValue()
	if self._isQueCard and self.value > 0 then
		local value = self.value % 10 + 60;
		return value;
	else
		return self.sortValue
	end
	
end

--[[
-- @brief  高亮显示处理
-- @param  void
-- @return void
--]]
function Mj:highLight(value)
	if self.mjType ~=  enMjType.MYSELF_NORMAL then
		return
	end
	self.mjCls:highLight(value)
end

function Mj:blackMj(value)
	if self.mjType ~=  enMjType.MYSELF_PENG then
		return
	end
	self.mjCls:blackMj(value)
end

return Mj
