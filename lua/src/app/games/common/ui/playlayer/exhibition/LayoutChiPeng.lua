-------------------------------------------------------------
--  @file   LayoutChiPeng.lua
--  @brief  吃牌显示界面操作
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 16:02:10
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Mj    		= require "app.games.common.mahjong.Mj"
local MjGroupBase   = import ".MjGroupBase"
local LayoutChiPeng 	= class("LayoutChiPeng", MjGroupBase)
-- 麻将摆放的方向
local kMjSite = {
	left 	= 1,
	middle  = 2,
	right   = 3,
}
-- 正常座次
local  kMjNormalDirection = {
	[kMjSite.left] 		= enSiteDirection.SITE_LEFT,
	[kMjSite.middle]  	= enSiteDirection.SITE_OTHER,
	[kMjSite.right]  	= enSiteDirection.SITE_RIGHT,
} 

-- 三人局座次
local  kMjSanNormalDirection = {
	[kMjSite.middle]  	= enSiteDirection.SITE_OTHER,
	[kMjSite.right]  	= enSiteDirection.SITE_RIGHT,
} 
-- 左边和对家座次
local  kMjLeftOtherDirection = {
	[kMjSite.right] 	= enSiteDirection.SITE_LEFT,
	[kMjSite.middle]  	= enSiteDirection.SITE_OTHER,
	[kMjSite.left]  	= enSiteDirection.SITE_RIGHT,
}

-- 麻将显示类型
local mjShowType = {
	normal = 1, -- 正常摆放
	tang   = 2, -- 躺下摆放
}

--[[
-- @brief  构造函数
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠, 里面的 enExhibitionStyle
--  operator		操作者的座次	
--  beOperator    	被操作的座位,被操作者不能是自己，暗杠和加杠不需要传进来
-- }
-- @return void
--]]
function  LayoutChiPeng:ctor(content)
	LayoutChiPeng.super.ctor(self, content)
	
	self.mjType = self:getMjType(1)

	self.tangMjObj      = nil
	self.putOutObjs 	= {} -- 打出去牌当对象
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function LayoutChiPeng:onShow()
	LayoutChiPeng.super.onShow(self)
	local mjElement
	local mjPos = 0
	local layoutSize 	= {
		width 	= 0,
		height  = 0, 
	}
	if nil == self.content then
		-- print("LayoutChiPeng:onShow 无效实体self.content")
		return
	end
	if self.content.actionType == enOperate.OPERATE_CHI then
		self:isSortChiMjs()
	end
    --判断是几人麻将
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum

	local beOperatSite =0
    if 3 == playerCount then
        beOperatSite = self:getSanBeoperatorNum(self.content.operator, self.content.beOperator)
    else
        beOperatSite = self:getBeoperatorNum(self.content.operator, self.content.beOperator)
    end
	for i=1, #self.content.mjs do
		assert(self.content.mjs[i])
		assert(beOperatSite)
		-- 判断是否是被操作者的座次
        if (2 == playerCount and i == 2) 
            or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
            or (4 == playerCount and beOperatSite == kMjNormalDirection[i])  then
            mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.tang], self.content.mjs[i])
			self:setTangObj(mjElement)
		else
			assert(self.content.operator)
			mjElement = Mj.new(self.mjType[self.content.operator][mjShowType.normal], self.content.mjs[i])
        end
		-- 存储打出去的牌
		table.insert(self.putOutObjs, mjElement)
		self:addChild(mjElement)
		
		-- 设置位置
		local  size = mjElement:getContentSize()
		--  左右由于方向的问题所以要取高度
		if self.content.operator == enSiteDirection.SITE_LEFT then
			local weiPos = 0
			if i > 1 then
				mjPos = mjPos - size.height
			else
                if (2 == playerCount and i == 2) 
                    or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                    or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
					mjPos = mjPos -7
				end
			end	
			if beOperatSite == kMjNormalDirection[i] then
				mjElement:setPosition(cc.p(-7, mjPos))
			else
				mjElement:setPosition(cc.p(-0.5, mjPos))
			end
			-- 设置麻将本地层级关系
			mjElement:setLocalZOrder(i)
			layoutSize.height  	= layoutSize.height + size.height
		elseif self.content.operator == enSiteDirection.SITE_RIGHT then
			if self.playerCount == 2 then
				if i > 1 then
					mjPos = mjPos - size.width
				end
				if (2 == playerCount and i == 2) 
                    or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                    or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
					mjElement:setPosition(cc.p(mjPos-0.3, 0))
				else
					mjElement:setPosition(cc.p(mjPos - 2.5, 0))
				end
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(i)
				layoutSize.width  	= layoutSize.width + size.width
			elseif self.playerCount == 3 or self.playerCount == 4 then
				if i > 1 then
					mjPos = mjPos + size.height
				else
					if (2 == playerCount and i == 2) 
                    or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                    or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
						mjPos = mjPos + 5
					end
				end
				if (2 == playerCount and i == 2) 
                    or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                    or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
					mjElement:setPosition(cc.p(7, mjPos - 6))
				else
					mjElement:setPosition(cc.p(0, mjPos - 5))
				end
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(-i)
				layoutSize.height  	= layoutSize.height + size.height
			end			
			
		elseif self.content.operator == enSiteDirection.SITE_MYSELF then 
			if i > 1 then
				mjPos = mjPos + size.width
			end
			if (2 == playerCount and i == 2) 
                or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
				mjElement:setPosition(cc.p(mjPos, -12))
			else
				mjElement:setPosition(cc.p(mjPos, 0))
			end
			-- 设置麻将本地层级关系
			mjElement:setLocalZOrder(i)
			layoutSize.width  	= layoutSize.width + size.width
		elseif self.content.operator == enSiteDirection.SITE_OTHER then
			if self.playerCount == 3 then --3人房
				local weiPos = 0
				if i > 1 then
					mjPos = mjPos - size.height
				else
					if beOperatSite == kMjNormalDirection[i] then
						mjPos = mjPos -7
					end
				end	
				if (2 == playerCount and i == 2) 
                    or (3 == playerCount and beOperatSite == kMjLeftOtherDirection[i]) 
                    or ( 4 == playerCount and beOperatSite == kMjNormalDirection[i]) then
					mjElement:setPosition(cc.p(-7, mjPos))
				else
					mjElement:setPosition(cc.p(-0.5, mjPos))
				end
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(i)
				layoutSize.height  	= layoutSize.height + size.height
			elseif self.playerCount == 4 then --4人房
				if i > 1 then
					mjPos = mjPos - size.width
				end
				if beOperatSite == kMjNormalDirection[i] then
					mjElement:setPosition(cc.p(mjPos, 0))
				else
					mjElement:setPosition(cc.p(mjPos - 2.5, 0))
				end
				-- 设置麻将本地层级关系
				mjElement:setLocalZOrder(i)
				layoutSize.width  	= layoutSize.width + size.width
			end
		else
			-- print("LayoutChiPeng:onShow 无效的方向"..self.content.operator)
		end
	end
	-- 设置麻将组大小
	self:setContentSize(cc.size(layoutSize.width, layoutSize.height+5))
end

--麻将吃重新排序排序
function LayoutChiPeng:isSortChiMjs()
	for i , v in pairs(self.content.mjs) do
		if self.content.actionCard == nil then
			return
		end
		if v == self.content.actionCard then
			table.removebyvalue(self.content.mjs, self.content.actionCard)
			table.insert(self.content.mjs,1,self.content.actionCard)
		end
	end
end
--[[
-- @brief  关闭函数
-- @param  reoperator, 转换之前的操作者
-- @param  reBeoperator, 转换之前的被操作者
-- @return void
--]]
function LayoutChiPeng:getBeoperatorNum(reoperator, reBeoperator)
	if reoperator == 1 then
		return reBeoperator
	elseif reoperator == 2 then
		if reBeoperator == 1 then
			return 4
		elseif reBeoperator == 2 then
			return 1
		elseif reBeoperator == 3 then
			return 2
		elseif reBeoperator == 4 then
			return 3
		end
	elseif reoperator == 3 then
		if reBeoperator == 1 then
			return 3
		elseif reBeoperator == 2 then
			return 4
		elseif reBeoperator == 3 then
			return 1
		elseif reBeoperator == 4 then
			return 2
		end
	elseif reoperator == 4 then
		if reBeoperator == 1 then
			return 2
		elseif reBeoperator == 2 then
			return 3
		elseif reBeoperator == 3 then
			return 4
		elseif reBeoperator == 4 then
			return 1
		end
	else
		-- print("LayoutChiPeng:getBeoperatorNum 无效的方向")
	end
end

function LayoutChiPeng:getSanBeoperatorNum(reoperator, reBeoperator)
	if reoperator == 1 then
        if reBeoperator == 2 then
            return 4
        elseif reBeoperator == 3 then
            return 2
        end
		return reBeoperator
	elseif reoperator == 2 then
		if reBeoperator == 1 then
			return 2
		elseif reBeoperator == 2 then
			return 1
		elseif reBeoperator == 3 then
			return 3
		elseif reBeoperator == 4 then
			return 3
		end
	elseif reoperator == 3 then
		if reBeoperator == 1 then
			return 4
		elseif reBeoperator == 2 then
			return 3
		elseif reBeoperator == 3 then
			return 1
		elseif reBeoperator == 4 then
			return 2
		end
	elseif reoperator == 4 then
		if reBeoperator == 1 then
			return 2
		elseif reBeoperator == 2 then
			return 3
		elseif reBeoperator == 3 then
			return 4
		elseif reBeoperator == 4 then
			return 1
		end
	else
		-- print("LayoutChiPeng:getBeoperatorNum 无效的方向")
	end
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function LayoutChiPeng:onClose()
	-- LayoutChiPeng.super.onClose(self)
	self:removeFromParent()
	self.content 	= nil
	self.tangMjObj  = nil
end

--[[
-- @brief  获取对象内容
-- @param  void
-- @return void
--]]
function LayoutChiPeng:getContent()
	return self.content
end

--[[
-- @brief  设置躺下麻将对象函数
-- @param  void
-- @return void
--]]
function LayoutChiPeng:setTangObj(mjObj)
	self.tangMjObj = mjObj
end

--[[
-- @brief  获取躺下麻将对象函数
-- @param  void
-- @return void
--]]
function LayoutChiPeng:getTangObj()
	return self.tangMjObj
end

--[[
-- @brief  获取操作的牌对象
-- @param  void
-- @return void
--]]
function LayoutChiPeng:getPutOutObjs()
	return self.putOutObjs
end

return LayoutChiPeng
