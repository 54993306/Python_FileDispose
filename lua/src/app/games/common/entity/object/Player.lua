-------------------------------------------------------------
--  @file   Player.lua
--  @brief  玩家对象
--  @author Zhu Can Qin
--  @DateTime:2016-08-26 18:28:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local Define 	= require "app.games.common.Define"
local Creature 	= import(".Creature", currentModuleName)
local Player 	= class("Player", Creature)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
-- 实体属性
-- enCreatureEntityProp = {
-- 	USERID  = 1, 	-- 用户id
-- 	NAME 	= 2,	-- 名字  
-- 	LEVEL   = 3,    -- 等级
-- 	GENDER  = 4,    -- 性别
-- 	FORTUNE = 5,    -- 财富
-- 	VIP_EXP = 6,    -- VIP经验
-- 	VIP     = 7,    -- VIP等级
-- 	ICON_ID = 8,    -- 头像 
--  WIN     = 9,    -- 赢
-- 	WIN_PRE = 10,   -- 之前赢
-- 	TOTAL   = 11,  -- 总
-- 	SEX     = 12,   -- 性别
-- 	FLOWER  = 13,   -- 花牌
-- 	BANKER  = 14,   -- 庄家或者是先出牌的玩家
-- 	DOOR_WIND = 15, -- 门风方便显示哪家打牌
-- 	USER_STATUS = 16, 	-- 玩家状态
-- 	TING_STATUS = 17, 	-- 听状态
-- 	SITE 	= 18, 		-- 座次
-- 	OUT_CARD = 19,  -- 打出去的牌列表
-- },
function Player:ctor(context)
	Player.super.ctor(self, context)
end

--[
-- @brief  初始化函数
-- @param  context 现场
-- @return 本身
--]
function Player:initialize(context)
	Player.super.initialize(self, context)
	-- 设置属性
	self:setProp(enCreatureEntityProp.USERID, 	context.usID)
	self:setProp(enCreatureEntityProp.NAME, 	context.niN or "")
	self:setProp(enCreatureEntityProp.LEVEL, 	context.le or "")
	self:setProp(enCreatureEntityProp.GENDER, 	context.ge or 0)
	self:setProp(enCreatureEntityProp.FORTUNE, 	context.mo or 0)
	self:setProp(enCreatureEntityProp.VIP_EXP, 	context.vip_exp or 0)
	self:setProp(enCreatureEntityProp.VIP, 		context.vip or 0)
	self:setProp(enCreatureEntityProp.ICON_ID,  context.icID or 0)
	self:setProp(enCreatureEntityProp.WIN, 		context.wi or 0)
	self:setProp(enCreatureEntityProp.WIN_PRE, 	context.wiP or 0)
	self:setProp(enCreatureEntityProp.TOTAL, 	context.to or 0)
	self:setProp(enCreatureEntityProp.SEX, 	    context.se or 2)
	self:setProp(enCreatureEntityProp.FLOWER, 	context.flC or {})
	self:setProp(enCreatureEntityProp.BANKER, 	context.banker or false)
	self:setProp(enCreatureEntityProp.SITE, 	context.site or 1)
	self:setProp(enCreatureEntityProp.CARD_NUM, context.caN)
	self:setProp(enCreatureEntityProp.IP, 		context.ipA)

	self:setProp(enCreatureEntityProp.JING_DU,  context.jiD)
	self:setProp(enCreatureEntityProp.WEI_DU,   context.weD)
	self:setProp(enCreatureEntityProp.LOCATION_TIME,   context.gpT)  -- 定位时间
	self:setProp(enCreatureEntityProp.DOOR_WIND, context.doW)
	-- 恢复对局吃碰杠相关
	self:setProp(enCreatureEntityProp.OPERATE_CARD,   context.opC   or {})	-- 动作牌第一个牌
	self:setProp(enCreatureEntityProp.OPERATE_CARD_LIST, context.opCO   or {})	-- 动作牌数组
	self:setProp(enCreatureEntityProp.OPERATE_TYPE,   context.opCT  or {}) 	-- 动作类型
	self:setProp(enCreatureEntityProp.BEOPERATER_ID,  context.opCUI or {}) 	-- 被操作玩家的用户id
	self:setProp(enCreatureEntityProp.ACTION_CARD,    context.opCAC or {}) 	-- 动作的牌
	self:setProp(enCreatureEntityProp.BET,   context.ji) --下注

	self:setProp(enCreatureEntityProp.XIA_PAO_NUM,    context.xiN or -1)    ---- 	下跑数：xiN
	self:setProp(enCreatureEntityProp.XIA_LA_NUM,    (context.laZN and not context.banker) and context.laZN or -1) 	---- 下拉数：laZN, 只有闲家才能有拉
	self:setProp(enCreatureEntityProp.XIA_ZUO_NUM,   (context.zuN and context.banker) and context.zuN or -1)	--   坐数：zuN, 只有庄家才能有坐
	self:setProp(enCreatureEntityProp.XIA_DI_NUM,    context.ji or -1)		-- 下底数：xdN

	-- 因为被别的玩家拿去的牌在玩家手牌里面是负数所以去掉
	local outCard = {}
	if context.diC0 then
		for i=1,#context.diC0 do
			if context.diC0[i] > 0  then
				table.insert(outCard, context.diC0[i])
			end
		end
	end
	
	self:setProp(enCreatureEntityProp.OUT_CARD, outCard or {})
	-- 设置状态
	self:setState(enCreatureEntityState.SUBSTITUTE, context.usS or enSubstitusStatus.CANCEL)
	self:setState(enCreatureEntityState.TING, context.ti or enTingStatus.TING_FALSE)
	self:setState(enCreatureEntityState.ONLINE, (context.onL == nil or context.onL) and enOnlineStatus.ONLINE or enOnlineStatus.OFFLINE)
	self:setProp(enCreatureEntityProp.DINGQUE_VAL, context.laC or 0);
	
	-- 需要重算
	-- self:setProp(enCreatureEntityProp.DOOR_WIND, 1)
	-- -- 添加动作部件
	-- self:addPart(Define.enPartDef.ACTION_PART)
	return self
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function Player:release()
    Player.super.release(self)
end

--[
-- @brief  重设action属性
-- @param  context = {
	-- firstCard 	= 动作第一个牌
	-- operateType 	= 动作类型
	-- beoperateUid = 被操作玩家的用户id
	-- operateCard  = 操作的牌
-- }
-- @return void
--]
function Player:changeActionProps(context)
    -- 恢复对局吃碰杠相关
    local data = {
		firstCard 		= self:getProp(enCreatureEntityProp.OPERATE_CARD),
		operateType 	= self:getProp(enCreatureEntityProp.OPERATE_TYPE),
		beoperateUid 	= self:getProp(enCreatureEntityProp.BEOPERATER_ID),
		operateCard  	= self:getProp(enCreatureEntityProp.ACTION_CARD),
	}
	-- 加杠要做特殊处理,只改
	if context.operateType == enOperate.OPERATE_JIA_GANG then
		for i=1,#data.firstCard do
			if data.operateType[i] == enOperate.OPERATE_PENG 
		   		and data.firstCard[i] == context.firstCard then
		   		data.operateType[i] = context.operateType
		   		self:setProp(enCreatureEntityProp.OPERATE_CARD,   data.firstCard    or {})	-- 动作牌第一个牌
				self:setProp(enCreatureEntityProp.OPERATE_TYPE,   data.operateType  or {}) 	-- 动作类型
				self:setProp(enCreatureEntityProp.BEOPERATER_ID,  data.beoperateUid or {}) 	-- 被操作玩家的用户id
				self:setProp(enCreatureEntityProp.ACTION_CARD,    data.operateCard  or {}) 	-- 动作的牌
	   		end
		end
	else
		table.insert(data.firstCard, 	context.firstCard)
		table.insert(data.operateType, 	context.operateType)
		table.insert(data.beoperateUid, context.beoperateUid)
		table.insert(data.operateCard, 	context.operateCard)

		self:setProp(enCreatureEntityProp.OPERATE_CARD,   data.firstCard    or {})	-- 动作牌第一个牌
		self:setProp(enCreatureEntityProp.OPERATE_TYPE,   data.operateType  or {}) 	-- 动作类型
		self:setProp(enCreatureEntityProp.BEOPERATER_ID,  data.beoperateUid or {}) 	-- 被操作玩家的用户id
		self:setProp(enCreatureEntityProp.ACTION_CARD,    data.operateCard  or {}) 	-- 动作的牌
	end	
end

--- 拉跑坐属性更新
function Player:changeLaPaoZuoProp(context)
	if context.operateType == enOperate.OPERATE_XIADI then
		self:setProp(enCreatureEntityProp.XIA_DI_NUM, context.operateCard or -1)
	elseif context.operateType == enOperate.OPERATE_XIA_PAO then
		self:setProp(enCreatureEntityProp.XIA_PAO_NUM, context.operateCard or -1)
	elseif context.operateType == enOperate.OPERATE_LAZHUANG then
		self:setProp(enCreatureEntityProp.XIA_LA_NUM, context.operateCard or -1)
	elseif context.operateType == enOperate.OPERATE_ZUO then
		self:setProp(enCreatureEntityProp.XIA_ZUO_NUM, context.operateCard or -1)
	end
end

--[
-- @brief  移除杠的动作, 将其变为碰
-- @param  gangValue 要移除的杠牌值
-- }
-- @return void
--]
function Player:removeGang(gangValue)
    -- 提取原动作数据
    local data = {
		firstCard 		= self:getProp(enCreatureEntityProp.OPERATE_CARD),
		operateType 	= self:getProp(enCreatureEntityProp.OPERATE_TYPE)
	}
	for i = 1, #data.firstCard do
		if data.firstCard[i] == gangValue and
			(data.operateType[i] == enOperate.OPERATE_MING_GANG or 
				data.operateType[i] == enOperate.OPERATE_JIA_GANG or 
				data.operateType[i] == enOperate.OPERATE_AN_GANG) then
			data.operateType[i] = enOperate.OPERATE_PENG
			break;
		end
	end
	self:setProp(enCreatureEntityProp.OPERATE_TYPE,   data.operateType  or {}) 	-- 动作类型
end

-- 定位信息更新
function Player:refreshLocationInfo(locationInfo)
	self:setProp(enCreatureEntityProp.JING_DU,  locationInfo.jiD)
	self:setProp(enCreatureEntityProp.WEI_DU,   locationInfo.weD)
	self:setProp(enCreatureEntityProp.LOCATION_TIME,   locationInfo.gpT)  -- 定位时间
end
--[
-- @override
--]
function Player:activate()
    Player.super.activate(self)
end

--[
-- @override
--]
function Player:deactivate()
    Player.super.deactivate(self)
end
return Player
