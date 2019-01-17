-------------------------------------------------------------
--  @file   LayoutAnGang.lua
--  @brief  布局暗杠的牌摆放
--  @author Zhu Can Qin
--  @DateTime:2016-08-10 11:12:32
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Mj    		= require "app.games.common.mahjong.Mj"
local MjGroupBase   = import ".MjGroupBase"
local LayoutAnGang 	= class("LayoutAnGang", MjGroupBase)
-- 麻将显示类型
local mjShowType = {
	normal = 1, -- 正常摆放
	tang   = 2, -- 躺下摆放
}

-- 默认躺着的牌的位置
local defaultTangId = 2

--[[
-- @brief  构造函数
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 enExhibitionStyle
--  operator		操作者的座次	
--  beOperator    	被操作的座位,被操作者不能是自己，暗杠和加杠不需要传进来	
-- }
-- @return void
--]]
function  LayoutAnGang:ctor(content)
	LayoutAnGang.super.ctor(self, content)
	self.content 		= content
	self.tangMjObj      = nil
	self.putOutObjs 	= {} -- 打出去牌当对象

    --注册一个是否报听的监听事件
	self.handlers = {}
	table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_TING_SHOW_ANGANG_NTF, 
        handler(self, self.showAnGangCards)))

	--是否显示暗杠牌的变量
	local isShowAnGangCard=false
	local gameId = kFriendRoomInfo:getGameID()
end

function LayoutAnGang:dtor()
-- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = nil
    self.isShowAnGangCard=nil
end



function LayoutAnGang:showAnGangCards(event)
	local site, state = unpack(event._userdata)
	if site ~= self.content.operator then
		return
	end
	self:switchAnGang(state)
end

function LayoutAnGang:switchAnGang(state)
	if self.m_state == state then
		return
	else
		self.m_state = state
	end

	if _isTingShowAnGangCards and _isTingShowAnGangCards==true then		
		isShowAnGangCard=true
	else
		isShowAnGangCard=false
	end

	self:onShow()
end



--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function LayoutAnGang:onShow()
	LayoutAnGang.super.onShow(self)

	self.mjType = self:getMjType(2)
	local mjElement = nil
	local offsetPos = 0
	local mjPos 	= 0
	-- 布局麻将的高和宽
	local layoutSize 	= {
		width 	= 0,
		height  = 0, 
	}

	local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	gameId = kFriendRoomInfo:getGameID()
	-- Log.i("游戏名称为：",GC_GameTypes[gameId])

	for i=1, #self.content.mjs  do
		if _isTingShowAnGangCards and _isTingShowAnGangCards==true then
			--Log.i("进入报听翻暗杠牌操作。")
			if isShowAnGangCard == true and (self.content.operator == enSiteDirection.SITE_MYSELF or playSystem:getIsAnGangShow()) then
				-- 最后一个显示麻将字
				mjElement = self:getChildByTag(4)
				-- mjElement:removeFromParent()
				--Log.i("需要翻的那张牌",self.content.mjs[4])
				mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.tang], self.content.mjs[4])
				-- 自己的存储4个对象方便统计打出去的牌
				-- for i=1,4 do
				-- 	table.insert(self.putOutObjs, mjElement)
				-- end
				mjElement:setTag(i)
				self:addChild(mjElement)
				local tangMjObj = self:getTangObj()
				local tangPosX 	= tangMjObj:getPositionX()
				local tangPosY 	= tangMjObj:getPositionY()
				local tangSize  = tangMjObj:getContentSize()
				-- 设置有字的麻将的位置
				mjElement:setPosition(cc.p(tangPosX, tangPosY + 12))
				-- 设置层级
				mjElement:setLocalZOrder(tangMjObj:getLocalZOrder() + 100)

				isShowAnGangCard=false
				return
			else
				if i == 4 and self.content.operator == enSiteDirection.SITE_MYSELF and (self.content.operator == enSiteDirection.SITE_MYSELF or playSystem:getIsAnGangShow()) then
				-- 最后一个显示麻将字
					mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.tang], self.content.mjs[i])
				-- 自己的存储4个对象方便统计打出去的牌
					for i=1,4 do
						table.insert(self.putOutObjs, mjElement)
					end
				else
					mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.normal])
				end
			end
		elseif _isAngangOpenTwoCard ~= nil and  _isAngangOpenTwoCard == true then
			if (i == 1 or i == 3 )and (self.content.operator == enSiteDirection.SITE_MYSELF or playSystem:getIsAnGangShow()) then
			-- 最后一个显示麻将字
				mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.tang], self.content.mjs[i])
			-- 自己的存储4个对象方便统计打出去的牌
				if i == 1 then
					for i=1,4 do
						table.insert(self.putOutObjs, mjElement)
					end
				end
			else
				mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.normal])
			end
		else
			Log.i("进入非太和麻将操作")
			if i == 4 and (self.content.operator == enSiteDirection.SITE_MYSELF or playSystem:getIsAnGangShow()) then
			-- 最后一个显示麻将字
				mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.tang], self.content.mjs[i])
			-- 自己的存储4个对象方便统计打出去的牌
				for i=1,4 do
					table.insert(self.putOutObjs, mjElement)
				end
			else
				mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.normal])
			end

		end
			mjElement:setTag(i)
			self:addChild(mjElement)

		if i == defaultTangId then
			self:setTangObj(mjElement)
		end
		local  size = mjElement:getContentSize()
		if i < 4 then
			--  左右由于方向的问题所以要取高度
			if self.content.operator == enSiteDirection.SITE_LEFT then
				if i > 1 then
					mjPos = mjPos - size.height
				end	
				mjElement:setPosition(cc.p(0, mjPos))
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(i)
				layoutSize.height  	= layoutSize.height + size.height
			elseif self.content.operator == enSiteDirection.SITE_RIGHT then
				if self.playerCount == 2 then -- 2人房
					if i > 1 then
						mjPos = mjPos - size.width
					end
					mjElement:setPosition(cc.p(mjPos, 0))
					-- 设置麻将本地层级关系
					mjElement:setLocalZOrder(-i)	
					layoutSize.width  	= layoutSize.width + size.width
				elseif self.playerCount == 3 or self.playerCount == 4 then
					if i > 1 then
						mjPos = mjPos + size.height
					end	
					mjElement:setPosition(cc.p(0, mjPos))
					-- 设置麻将本地层级关系
					mjElement:setLocalZOrder(-i) 
					layoutSize.height  	= layoutSize.height + size.height
				end			
			elseif self.content.operator == enSiteDirection.SITE_MYSELF then 
				if i > 1 then
					mjPos = mjPos + size.width
				end
				mjElement:setPosition(cc.p(mjPos, 0))
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(i)
				layoutSize.width  	= layoutSize.width + size.width
			elseif self.content.operator == enSiteDirection.SITE_OTHER then
				if self.playerCount == 3 then
					if i > 1 then
						mjPos = mjPos - size.height
					end	
					mjElement:setPosition(cc.p(0, mjPos))
					-- 设置麻将本地层级关系
					mjElement:setLocalZOrder(i)
					layoutSize.height  	= layoutSize.height + size.height
				elseif self.playerCount == 4 then
					if i > 1 then
						mjPos = mjPos - size.width
					end
					mjElement:setPosition(cc.p(mjPos, 0))				
					-- 设置麻将本地层级关系
					mjElement:setLocalZOrder(-i)	
					layoutSize.width  	= layoutSize.width + size.width
				end
			else
				print("LayoutMingGang:onShow 无效的方向"..self.content.operator)
			end

		elseif i == 4 then
			local tangMjObj = self:getTangObj()
			local tangPosX 	= tangMjObj:getPositionX()
   			local tangPosY 	= tangMjObj:getPositionY()
   			local tangSize  = tangMjObj:getContentSize()
   			-- 设置有字的麻将的位置
			mjElement:setPosition(cc.p(tangPosX, tangPosY + 12))
   			-- 设置层级
   			mjElement:setLocalZOrder(tangMjObj:getLocalZOrder() + i)
		end
	end
	-- 设置麻将组大小
	self:setContentSize(cc.size(layoutSize.width, layoutSize.height))
end


--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function LayoutAnGang:onClose()
	-- LayoutAnGang.super.onClose(self)
	self:removeFromParent()
	self.content 	= nil
	self.tangMjObj  = nil
end

--[[
-- @brief  设置第二个躺着的牌的位置
-- @param  void
-- @return void
--]]
function LayoutAnGang:getContent()
	return self.content
end

--[[
-- @brief  设置躺下麻将对象函数
-- @param  void
-- @return void
--]]
function LayoutAnGang:setTangObj(mjObj)
	self.tangMjObj = mjObj
end

--[[
-- @brief  获取躺下麻将对象函数
-- @param  void
-- @return void
--]]
function LayoutAnGang:getTangObj()
	return self.tangMjObj
end
--[[
-- @brief  获取操作的牌对象
-- @param  void
-- @return void
--]]
function LayoutAnGang:getPutOutObjs()
	return self.putOutObjs
end
return LayoutAnGang
