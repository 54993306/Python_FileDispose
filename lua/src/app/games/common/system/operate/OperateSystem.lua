
-------------------------------------------------------------
--  @file   OperateSystem.lua
--  @brief  操作吃， 碰，杠等系统
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 18:29:50
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define        = require "app.games.common.Define"
local currentModuleName = ...
local SystemBase 	= import("..SystemBase", currentModuleName)
local OperateSystem = class("OperateSystem", SystemBase)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function OperateSystem:ctor()
	self:initOperateActionIDList()
end

--[
-- @override
--]
function OperateSystem:release()
   
end

--[
-- @override
--]
function OperateSystem:activate(context)
	self.operateData = {}
	self.doorCard  = nil -- 操作的牌
	
end

--[
-- @override
--]
function OperateSystem:deactivate()
   self.operateData = {}
end

--  初始化可操作动作ID列表
function OperateSystem:initOperateActionIDList()
    self.m_OperateActionIDList = {}

    self:addOperateActionID(enOperate.OPERATE_DIAN_PAO_HU)
    self:addOperateActionID(enOperate.OPERATE_ZI_MO_HU)
    self:addOperateActionID(enOperate.OPERATE_QIANG_GANG_HU)
    self:addOperateActionID(enOperate.OPERATE_DI_XIA_HU)
    self:addOperateActionID(enOperate.OPERATE_GANG_KAI)
    self:addOperateActionID(enOperate.OPERATE_ZHUA_PAI)
    if IsPortrait then -- TODO
        self:addOperateActionID(enOperate.OPERATE_ASK_BU_HUA)
    end
    self:addOperateActionID(enOperate.OPERATE_MING_GANG)
    self:addOperateActionID(enOperate.OPERATE_AN_GANG)
    self:addOperateActionID(enOperate.OPERATE_JIA_GANG)
    self:addOperateActionID(enOperate.OPERATE_PENG)
    self:addOperateActionID(enOperate.OPERATE_CHI)
    self:addOperateActionID(enOperate.OPERATE_TING)
    self:addOperateActionID(enOperate.OPERATE_TIAN_TING)
    self:addOperateActionID(enOperate.OPERATE_TIAN_HU)
    self:addOperateActionID(enOperate.OPERATE_DIAN_TIAN_HU)
    self:addOperateActionID(enOperate.OPERATE_TING_RECONNECT)
    self:addOperateActionID(enOperate.OPERATE_DIAN_DI_HU)
    self:addOperateActionID(enOperate.OPERATE_YANGMA) 
    self:addOperateActionID(enOperate.OPERATE_DI_HU)
    self:addOperateActionID(enOperate.OPERATE_JIA_PEI_ZI)
end

--  添加可操作动作ID
function OperateSystem:addOperateActionID(actionID)
    table.insert(self.m_OperateActionIDList, actionID)
end

--  判断一个值是否为可操作动作ID
function OperateSystem:isOperateAction(actionID)
    local ret = false
    for i, v in pairs(self.m_OperateActionIDList) do
        if actionID == v then
            ret = true
            break
        end
    end
    
    return ret
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function OperateSystem:setOperateSystemDatas(cmd, context)
	-- 重置动作
	self:initActionDatas()
   	self.operateData = {}
	self.operateData.actionCard 	= context.acC0 or 0 	-- 操作的牌
	self.operateData.actionID  		= context.acID or 0 	-- 动作id
	self.operateData.cbCards  		= context.cbC or {} 	-- 动作组成的牌型
	self.operateData.actionResult  	= context.acR or 0 		-- 操作结果
	self.operateData.userid  		= context.usID or 0 	-- 操作者id
	self.operateData.lastPlayUserId = context.laPUID or 0 	-- 最后的操作者
    self.operateData.playCard 		= context.ca or 0 		-- 打牌
    self.operateData.isHaveNextAct 	= context.haA or false 	-- 是否有后续动作
    self.operateData.HuType 	    = context.diXiaHuType or enHuType.TYPE_NONE --  胡牌类型

    -- 重新改变玩家操作牌的属性数据
    self.gameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local players 	= self.gameSystem:gameStartGetPlayers()
    local site 		= self.gameSystem:getPlayerSiteById(context.usID)
    local firstCard = 0
    if context.cbC then
    	if #context.cbC > 0 then
    		firstCard = context.cbC[#context.cbC] -- 取动作牌的第最后一个，如果有癞子会存放在前面位置
	    end
	    local context = {
			firstCard 		= firstCard or 0,
			operateType 	= context.acID,
			beoperateUid 	= context.laPUID or 0,
			operateCard  	= context.acC0,
		}
	    players[site]:changeActionProps(context)
    end
    -- 抢杠胡(现在是点炮胡的操作ID)移除被抢的杠
    if self.operateData.actionID == enOperate.OPERATE_DIAN_PAO_HU and self.operateData.actionCard > 0 then
    	for i = 1, #players do
    		players[i]:removeGang(self.operateData.actionCard)
    	end
    end
    --- 拉跑坐属性更新
    if self.operateData.actionID == enOperate.OPERATE_XIADI 
    	or self.operateData.actionID == enOperate.OPERATE_XIA_PAO
    	or self.operateData.actionID == enOperate.OPERATE_LAZHUANG
    	or self.operateData.actionID == enOperate.OPERATE_ZUO then
    	local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
    	player:changeLaPaoZuoProp({operateType = context.acID, operateCard = context.acC0})
    end
    -- 更新人物听状态
    if self.operateData.actionID == enOperate.OPERATE_TING or 
    	self.operateData.actionID == enOperate.OPERATE_TIAN_TING then

    	local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
    	player:setState(enCreatureEntityState.TING, self.operateData.actionResult)
    end

    if self.operateData.actionID == enOperate.OPERATE_TING then
    	local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
    	player:setState(enCreatureEntityState.TING, self.operateData.actionResult)
    elseif self.operateData.actionID == enOperate.OPERATE_TIAN_TING then
    	local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
    	player:setState(enCreatureEntityState.TIANTING, self.operateData.actionResult)
    end
    -- 补花的时候要重新设置一下剩余牌数，因为在补花里面会带一张牌
    if self.operateData.actionID == enOperate.OPERATE_BU_HUA and self.operateData.playCard > 0 then
    	local remainCards = SystemFacade:getInstance():getRemainPaiCount() - 1
		SystemFacade:getInstance():setRemainPaiCount(remainCards)
    end

    
    
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function OperateSystem:initActionDatas()
	-- 操作牌需要的数据，后面需要数据可以加在里面，请根据这个格式传入数据
	self.actionDatas = {
		doorCard   		= 0,
		flowerCards 	= {},
		actions   		= {},
		addGangCards 	= {},
		anGangCards  	= {},
		tingCards 		= {}, -- 听牌
		tingAftCards 	= {}, -- 听牌之后可胡的牌组
		actionCard		= 0,
	}
    self.m_sendGuo = false
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function OperateSystem:setOperateSystemDatas1(context)
   	self.operateData = context
end
--[[
-- @brief  获取玩家操作数据
-- @param  void
-- @return void
--]]
function OperateSystem:getOperateSystemDatas()
	return self.operateData
end

--[[
-- @brief  获取暗杠牌牌组函数
-- @param  void
-- @return void
--]]
function OperateSystem:getAnGangGroupCards()
	local anGangGroups = {}
	-- local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	-- local anGangList = playSystem:getPlayCardDatas().anGangCards
	local anGangList = self.actionDatas.anGangCards
	for i=1,#anGangList do
		anGangGroups[i] = {anGangList[i], anGangList[i], anGangList[i], anGangList[i]}
	end
	return anGangGroups
end
--[[
-- @brief  获取吃的牌函数
-- @param  void
-- @return void
--]]
function OperateSystem:getChiGroupCards()
	local mj 		= self:getActionCard()
	local left_a 	= false
	local left_b 	= false
	local right_a 	= false
	local right_b 	= false
	local arrChiCards = {}
	local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	local myCards = playSystem:gameStartGetHandMjs()
	for i,v in pairs(myCards) do
		local node = v
		local value = v:getProp(enGoodsProp.VALUE)
		if value == mj - 2 then
			left_a = true
		end
		if value == mj - 1 then
			left_b = true
		end
		if value == mj + 1 then
			right_a = true
		end
		if value == mj + 2 then
			right_b = true
--			break
		end
	end

	if left_a and left_b then
		table.insert(arrChiCards, {mj - 2, mj - 1, mj})
	end
	if left_b and right_a then
		table.insert(arrChiCards,{mj - 1, mj, mj + 1})
	end
	if right_a and right_b then
		table.insert(arrChiCards, {mj, mj + 1, mj + 2})
	end
	return arrChiCards
end

--[[
-- @brief  请求吃的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendChiOperate(chiCardsGroup)
	local playCard 		= self:getDoorCard()
	-- 发送吃的操作给服务器
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_CHI,
		1, 
		playCard, 
		chiCardsGroup)
end
--[[
-- @brief  请求吃的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendAnGangOperate(anGangCard)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_AN_GANG, 
		1, 
		anGangCard, 
		self:getGangCards(anGangCard))
end

--[[
-- @brief  发送动作消息
-- @param  actionID --  动作ID
-- @param  actionCard --  动作相关的牌
-- @param  groupCards --  动作相关的牌组，无则为nil
-- @return void
--]]
function OperateSystem:sendActionMsg(actionID, actionCard, groupCards)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		actionID, 
		1, 
		actionCard, 
		groupCards)
end

--[[
-- @brief  请求碰的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendPengOperate(anGangCardsGroup)
	local playCard 		= self:getDoorCard()  
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_PENG, 
		1, 
		playCard)
end

--[[
-- @brief  请求明杠的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendMingGangOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_MING_GANG, 
		1, 
		playCard, 
		self:getGangCards(playCard))
end

--[[
-- @brief  请求加杠的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendJiaGangOperate(addCard)
	-- 因为加杠只能有一个所以这里直接取第一个牌作为加杠牌
	-- local addCard 		= self.actionDatas.addGangCards[1]
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_JIA_GANG, 
		1, 
		addCard, 
		self:getGangCards(addCard))
end

--[[
-- @brief  请求自模胡的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendZiMoHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_ZI_MO_HU, 
		1, 
		playCard)
end

--[[
	-- @brief 请求地胡的操作
	-- @params void
	-- @return void
]]
function OperateSystem:sendDiHuOperate()
	local playCard = self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND,
		enMjMsgSendId.MSG_SEND_MJ_ACTION,
		enOperate.OPERATE_DI_HU,
		1,
		playCard)
end

--[[
	-- @brief 请求点炮地胡的操作
	-- @params void
	-- @return void
]]
function OperateSystem:sendDianDiHuOperate()
	local playCard = self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND,
		enMjMsgSendId.MSG_SEND_MJ_ACTION,
		enOperate.OPERATE_DIAN_DI_HU,
		1,
		playCard)
end

--[[
	-- @brief 请求地下胡的操作
	-- @params void
	-- @return void
]]
function OperateSystem:sendDiXiaHuOperate()
	local playCard = self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND,
		enMjMsgSendId.MSG_SEND_MJ_ACTION,
		enOperate.OPERATE_DI_XIA_HU,
		1,
		playCard)
end

function OperateSystem:sendYangmaOperate(card)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND,
		enMjMsgSendId.MSG_SEND_MJ_ACTION,
		enOperate.OPERATE_YANGMA,
		1,
		card, 
		self:getGangCards(card))
end

--[[
-- @brief  请求天胡的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendTianHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_TIAN_HU, 
		1, 
		playCard)
end

--[[
-- @brief  请求点炮天胡的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendDianTianHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_DIAN_TIAN_HU, 
		1, 
		playCard)
end

--[[
-- @brief  请求点炮胡的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendDianPaoHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_DIAN_PAO_HU, 
		1, 
		playCard)
end

--[[
-- @brief  请求抢杠胡的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendQiangGangHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_QIANG_GANG_HU, 
		1, 
		playCard)
end

--[[
-- @brief  点架配子的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendJiaPeiZiOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_JIA_PEI_ZI, 
        1, 
        playCard)
end

--[[
-- @brief  请求过的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendGuoOperate(acs)
    if not IsPortrait then -- TODO
        if self.m_sendGuo then return end
    end
	local playCard = self:getDoorCard()
	local actions  = acs and #acs > 0 and acs or self:getActions()


	local players   = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)

    for i = #actions, 1, -1 do
	    if not MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):getIsHasTing() then
		    if actions[i] == enOperate.OPERATE_TING then
			    table.remove(actions, i)
		    end
	    end

	    if tingState == enTingStatus.TING_TRUE and actions[i] == enOperate.OPERATE_TING then
			table.remove(actions, i)
		end

	    if actions[i] == enOperate.OPERATE_TING_RECONNECT then
		    table.remove(actions, i)
	    end
    end

	if actions[1] == enOperate.OPERATE_TING then
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		actions[1], 
		0)
        self.m_sendGuo = true
	elseif #actions > 0 then
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		actions[1], 
		0, 
		playCard)
        self.m_sendGuo = true
	end

	-- 点过也要重置动作
	local haveTing = false
	for k, v in pairs(self.actionDatas.actions) do
		if v == enOperate.OPERATE_TING or v == enOperate.OPERATE_TIAN_TING then
			haveTing = true
		end		
	end

	if not haveTing then self:initActionDatas() end

    scheduler.performWithDelayGlobal(function()
        -- 点过发消息去根据手牌数量更新超时操作提示
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_REFRESH_OPERATOR_OVER_TIME)
    end, 0.2)

end
--[[
-- @brief  请求听的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendTingOperate(playCard)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_TING, 
		1, 
		playCard)
end

--[[
-- @brief  请求听的操作
-- @param  void
-- @return void
--]]
function OperateSystem:sendTianTingOperate(playCard)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_TIAN_TING, 
		1, 
		playCard)
end


--[[
-- @brief  获取杠牌数组
-- @param  void
-- @return void
--]]
function OperateSystem:getGangCards(card)
	return {card, card, card, card}
end

--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:getDoorCard()
	return self.actionDatas.doorCard
end

--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:setDoorCard()
	-- self.actionDatas.doorCard = 
end
--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:getActionCard()
	return self.actionDatas.actionCard
end

--[[
-- @brief  获取是否已过牌标识
-- @param  void
-- @return void
--]]
function OperateSystem:getIsChooseGuo()
	return self.actionDatas.isChooseGuo
end


--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:getActions()
	local needActions = {}
	if #self.actionDatas.actions > 0  then
		for i, v in pairs(self.actionDatas.actions) do
            local lIsNeedAction = self:isOperateAction(v)
			if lIsNeedAction then
				needActions[#needActions + 1] = v
			end
		end
	end
	return needActions or {}
end

--[[
-- @brief  设置操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:resetActionDatas(datas)
	self.actionDatas = datas
    self.m_sendGuo = false
end
--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function OperateSystem:getActionDatas()
	return self.actionDatas
end

--[[
-- @brief  获取听牌胡的牌
-- @param  void
-- @return void
--]]
function OperateSystem:getHuCardByTingCard(value)
	local tingIndex = 0
	for i=1, #self.actionDatas.tingCards do
		if value == self.actionDatas.tingCards[i] then
			tingIndex = i
			break
		end
	end
	return self.actionDatas.tingAftCards[tingIndex] or {}
end


--[
-- @override
--]
function OperateSystem:getSystemId()
    return enSystemDef.OPERATE_SYSTEM
end

return OperateSystem
