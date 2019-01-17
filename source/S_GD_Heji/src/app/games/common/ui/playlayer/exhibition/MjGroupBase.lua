-------------------------------------------------------------
--  @file   MjGroupBase.lua
--  @brief  麻将组基类,提供给外部去继承
--  @author Zhu Can Qin
--  @DateTime:2016-08-09 09:36:56
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================

-- 操作类型，碰（包括明杠）或暗杠
local mjOperatorType =
{
	PENG = 1,
	GANG = 2
}

-- 麻将显示类型
local mjShowType = 
{
	normal = 1, -- 正常摆放
	tang   = 2, -- 躺下摆放
}

local kPengType =
{
	{

	},
	{
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.OTHER_PENG,
			[mjShowType.tang]   = enMjType.OTHER_PENG_TANG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.MYSELF_PENG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG_TANG
		}
	},
	{
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.RIGHT_PENG,
			[mjShowType.tang]   = enMjType.RIGHT_PENG_TANG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.MYSELF_PENG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG_TANG
		},
		[enSiteDirection.SITE_OTHER] = {
			[mjShowType.normal] = enMjType.LEFT_PENG,
			[mjShowType.tang]   = enMjType.LEFT_PENG_TANG
		}
	},
	{
		[enSiteDirection.SITE_LEFT] = {
			[mjShowType.normal] = enMjType.LEFT_PENG,
			[mjShowType.tang]   = enMjType.LEFT_PENG_TANG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.MYSELF_PENG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG_TANG
		},
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.RIGHT_PENG,
			[mjShowType.tang]   = enMjType.RIGHT_PENG_TANG
		},
		[enSiteDirection.SITE_OTHER] = {
			[mjShowType.normal] = enMjType.OTHER_PENG,
			[mjShowType.tang]   = enMjType.OTHER_PENG_TANG
		}
	}
}

local kGangType = 
{
	{

	},
	{
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.EMPTY_OTHER_GANG,
			[mjShowType.tang]   = enMjType.OTHER_PENG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.EMPTY_MYSELF_GANG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG
		}
	},
	{
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.EMPTY_RIGHT_GANG,
			[mjShowType.tang]   = enMjType.RIGHT_PENG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.EMPTY_MYSELF_GANG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG
		},
		[enSiteDirection.SITE_OTHER] = {
			[mjShowType.normal] = enMjType.EMPTY_LEFT_GANG,
			[mjShowType.tang]   = enMjType.LEFT_PENG
		}
	},
	{
		[enSiteDirection.SITE_LEFT] = {
			[mjShowType.normal] = enMjType.EMPTY_LEFT_GANG,
			[mjShowType.tang]   = enMjType.LEFT_PENG
		},
		[enSiteDirection.SITE_MYSELF] = {
			[mjShowType.normal] = enMjType.EMPTY_MYSELF_GANG,
			[mjShowType.tang]   = enMjType.MYSELF_PENG
		},
		[enSiteDirection.SITE_RIGHT] = {
			[mjShowType.normal] = enMjType.EMPTY_RIGHT_GANG,
			[mjShowType.tang]   = enMjType.RIGHT_PENG
		},
		[enSiteDirection.SITE_OTHER] = {
			[mjShowType.normal] = enMjType.EMPTY_OTHER_GANG,
			[mjShowType.tang]   = enMjType.OTHER_PENG
		}
	}
}

local MjGroupBase 	= class("MjGroupBase", function ()
	local ret = ccui.Widget:create()
    ret:ignoreContentAdaptWithSize(false)
    ret:setAnchorPoint(cc.p(0, 0.5))
    return ret
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MjGroupBase:ctor(content)
	--content = content
	-- 重算座位
	-- if content.beOperator then
	-- 	local site = (content.beOperator - content.operator + 4)%4 +1
	-- 	content.beOperator = site
	-- end
	--获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

	self.content = content
end

--[[
-- @brief 获取麻将类型
-- @param type 碰或者杠
-- @return 返回房间人数对应的麻将类型
]]
function MjGroupBase:getMjType(type)
	if type == mjOperatorType.PENG  then
		return kPengType[self.playerCount]
	elseif type == mjOperatorType.GANG then
		return kGangType[self.playerCount]
	end
	-- print("invalid mj type============>>>", type)
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function  MjGroupBase:onShow()
	
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function MjGroupBase:onClose()
	self.content = nil
end

--[[
-- @brief  获取对象内容
-- @param  void
-- @return void
--]]
function MjGroupBase:getContent()
	return nil
end

--[[
-- @brief  获取躺下麻将对象函数
-- @param  void
-- @return void
--]]
function MjGroupBase:getTangObj()
	return nil
end

return MjGroupBase