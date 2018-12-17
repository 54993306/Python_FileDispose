-------------------------------------------------------------
--  @file   MjGroups.lua
--  @brief  麻将组
--  @author Zhu Can Qin
--  @DateTime:2016-08-08 19:54:15
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Mj                = require "app.games.common.mahjong.Mj"
local MjGroupFactory    = import ".MjGroupFactory"
local Deque             = require "app.games.common.utils.Deque"
-- 麻将显示类型
local kMjShowType = {
	normal = 1, -- 正常摆放
	tang   = 2, -- 躺下摆放
}
local  kMjType = {
	[enSiteDirection.SITE_LEFT] = {
		[kMjShowType.normal] = enMjType.LEFT_PENG,
		[kMjShowType.tang]   = enMjType.LEFT_PENG_TANG, 
	},
	[enSiteDirection.SITE_MYSELF] = {
		[kMjShowType.normal] = enMjType.MYSELF_PENG,
		[kMjShowType.tang]   = enMjType.MYSELF_PENG_TANG, 
	},
	[enSiteDirection.SITE_RIGHT] = {
		[kMjShowType.normal] = enMjType.RIGHT_PENG,
		[kMjShowType.tang]   = enMjType.RIGHT_PENG_TANG, 
	},
	[enSiteDirection.SITE_OTHER] = {
		[kMjShowType.normal] = enMjType.OTHER_PENG,
		[kMjShowType.tang]   = enMjType.OTHER_PENG_TANG, 
	}
}

local kSanmjType = {
    [enSiteDirection.SITE_LEFT] = {
		[kMjShowType.normal] = enMjType.LEFT_PENG,
		[kMjShowType.tang]   = enMjType.LEFT_PENG_TANG, 
	},
	[enSiteDirection.SITE_MYSELF] = {
		[kMjShowType.normal] = enMjType.MYSELF_PENG,
		[kMjShowType.tang]   = enMjType.MYSELF_PENG_TANG, 
	},
	[enSiteDirection.SITE_RIGHT] = {
		[kMjShowType.normal] = enMjType.RIGHT_PENG,
		[kMjShowType.tang]   = enMjType.RIGHT_PENG_TANG, 
	},
	[enSiteDirection.SITE_OTHER] = {
		[kMjShowType.normal] = enMjType.LEFT_PENG,
		[kMjShowType.tang]   = enMjType.LEFT_PENG_TANG, 
	}
}
local grapX = 20 -- x 轴之间的间隙

local MjGroups 				= class("MjGroups")

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function  MjGroups:ctor()
    self.mjsGroupsQueue = {}
    self.putOutObjs     = {} -- 打出去的麻将对象
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function MjGroups:release()
    for k, v in pairs(self.mjsGroupsQueue) do
        for i=1, #v  do
            v[i]:onClose()
        end
    end
    self.mjsGroupsQueue = {}
    self.putOutObjs     = {} -- 打出去的麻将对象
end
--[[
-- @brief  添加函数
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--  operator		操作者的座次	
--  beOperator      被操作的座位，暗杠和加杠不需要传进来	
-- }
-- @return void
--]]
function MjGroups:addMjGroup(content)
    -- if content.operator == content.beOperator then
    --     printError("MjGroups:addMjGroup 操作者和被操作者不能是同一个人")
    --     return
    -- end
    local mjGroup = MjGroupFactory:createMjGroup(content)
    mjGroup:onShow()
    -- 将设置的组加入队列里面
    if nil == self.mjsGroupsQueue[content.operator] then
        self.mjsGroupsQueue[content.operator] = {}
        table.insert(self.mjsGroupsQueue[content.operator], mjGroup)
    else
        table.insert(self.mjsGroupsQueue[content.operator], mjGroup)
    end
    -- 统计打出去的麻将
    local outObjs = mjGroup:getPutOutObjs()
    for i=1,#outObjs do
        table.insert(self.putOutObjs, outObjs[i])
    end
    return mjGroup
end

--[[
-- @brief  加杠函数
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--  operator		操作者的座次 参考 enSiteDirection 
-- }
-- @return void
--]]
function  MjGroups:addJiaGangGroup(content)
	if nil == content then
		printError("MjGroups:addGangToGroup 无效的内容content")
		return 
	end
    local jiaGangSuccess = false
    for i=1,#self.mjsGroupsQueue[content.operator] do
   		local objContent = self.mjsGroupsQueue[content.operator][i]:getContent()
   		-- 判断之前是否有碰过这个牌, 默认取麻将牌第一个对比是否是需要加杠的牌,还有判断是否是同一个操作者

        Log.i("jiagaong-====..????>>>", objContent, content)
   		if objContent.actionType 	== enOperate.OPERATE_PENG 
   			and objContent.mjs[1] 	== content.mjs[1] 
   			and objContent.operator == content.operator then

   			local tangObj 	= self.mjsGroupsQueue[content.operator][i]:getTangObj()
            --判断是几人麻将
	        local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
            local playerCount = sys:getGameStartDatas().playerNum
            local operator = content.operator
            if playerCount == 2 and operator == 2 then
                operator = enSiteDirection.SITE_OTHER
            elseif playerCount == 3 and operator == 3 then
                operator = enSiteDirection.SITE_LEFT
            end
   			local mjElement = Mj.new(kMjType[operator][2], content.mjs[1])
   			local tangPosX 	= tangObj:getPositionX()
   			local tangPosY 	= tangObj:getPositionY()
   			local tangSize  = tangObj:getContentSize()
   			-- 设置加杠麻将的位置
   			if operator == enSiteDirection.SITE_LEFT then
                mjElement:setPosition(cc.p(tangPosX + tangSize.width, tangPosY))
                self.mjsGroupsQueue[content.operator][i]:addChild(mjElement, tangObj:getLocalZOrder() - 1)
			elseif operator == enSiteDirection.SITE_RIGHT then
				mjElement:setPosition(cc.p(tangPosX - tangSize.width, tangPosY))
                self.mjsGroupsQueue[content.operator][i]:addChild(mjElement, tangObj:getLocalZOrder() - 1)
   			elseif operator == enSiteDirection.SITE_MYSELF then
                mjElement:setPosition(cc.p(tangPosX, tangPosY + tangSize.height))
                self.mjsGroupsQueue[content.operator][i]:addChild(mjElement, tangObj:getLocalZOrder() - 1)
			elseif operator == enSiteDirection.SITE_OTHER then
   				mjElement:setPosition(cc.p(tangPosX, tangPosY - tangSize.height))
                self.mjsGroupsQueue[content.operator][i]:addChild(mjElement, tangObj:getLocalZOrder() + 1)
   			end
   			
   			-- 设置为加杠
   			objContent.actionType = content.actionType or enOperate.OPERATE_JIA_GANG
   			table.insert(objContent.mjs, content.mjs[1]) 	
            jiaGangSuccess = true
            -- 统计打出去的牌对象
            table.insert(self.putOutObjs, mjElement)
            return self.mjsGroupsQueue[content.operator][i]
   		else
   			-- print("MjGroups:addGangToGroup 加杠添加失败")
   		end
    end
    if not jiaGangSuccess then
        printError("MjGroups:addJiaGangGroup 加杠失败")
    end
end


--[[
-- @brief  加杠函数
-- @param  content{
--  mjs     =  {},  麻将的列表
--  actionType      动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--  operator        操作者的座次 参考 enSiteDirection 
-- }
-- @return void
--]]

--[[
-- @brief  获取麻将组的队列
-- @param  void
-- @return void
--]]
function MjGroups:getMjGroupsQueue()
	return self.mjsGroupsQueue
end

--[[
-- @brief  通过操作者座位获取吃碰杠的麻将
-- @param  operateSite 操作者座位
-- @return void
--]]
function MjGroups:getMjGroupsBySite(operateSite)
    return self.mjsGroupsQueue[operateSite] or {}
end

--[[
-- @brief  通过操作者座位获取麻将组的宽度
-- @param  operateSite 类型
-- @return void
--]]
function MjGroups:getMjGroupsSizeBySite(operateSite)
    local width     = 0
    local height    = 0
    if nil == self.mjsGroupsQueue[operateSite] then
        return cc.size(width, height)
    end
    for k, v in pairs(self.mjsGroupsQueue[operateSite]) do
        local size = v:getContentSize()
        width   = width + size.width
        height  = height + size.height 
    end
    return cc.size(width, height)
end

--[[
-- @brief  获取操作的牌对象
-- @param  void
-- @return void
--]]
function MjGroups:getPutOutObjs()
    return self.putOutObjs
end


return MjGroups