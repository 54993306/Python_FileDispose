-------------------------------------------------------------
--  @file   PlayCardLogic.lua
--  @brief  打牌逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 20:10:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Component = cc.Component
local PlayCardLogic = class("PlayCardLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function PlayCardLogic:ctor()
	PlayCardLogic.super.ctor(self, "PlayCardLogic")
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function PlayCardLogic:onBind_()
	self.playCardDatas = {}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function PlayCardLogic:onUnbind_()
	self.playCardDatas = {}
end

--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function PlayCardLogic:setPlayCardDatas(cmd, context)
	local tingCards = {}
	local tingAftCards = {}
	local players = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if tingState == enTingStatus.TING_TRUE then
    	if self.playCardDatas.tingCards and #self.playCardDatas.tingCards > 0 then
    		tingCards = self.playCardDatas.tingCards
    	end
    	if self.playCardDatas.tingAftCards and #self.playCardDatas.tingAftCards > 0 then
    		tingAftCards = self.playCardDatas.tingAftCards
    	end
    end
	self.playCardDatas = {}
	-- local doorCardV = 0
	-- if context.plC > 0 then
	-- 	doorCardV = context.plC
	-- end
	self.playCardDatas.playedbyID   = context.pl or 0
	self.playCardDatas.playCard    	= context.plC or 0
	self.playCardDatas.nextplayerID = context.neP or 0
	if IsPortrait then -- TODO
		self.playCardDatas.doorcard    	= context.Do or 0
	else
		self.playCardDatas.doorCard    	= context.Do or 0
	end
	self.playCardDatas.flowerCards  = context.flC or {}
	self.playCardDatas.actions   	= context.ac0 or {}
	self.playCardDatas.addGangCards = context.adGC or {}
	self.playCardDatas.anGangCards  = context.anGC or {}
	self.playCardDatas.tingCards    = context.tiC or {}  -- 可听的牌
	self.playCardDatas.tingAftCards = context.tiHC or {} -- 听牌之后可胡的牌组
	self.playCardDatas.remainCount  = context.reC or 0
	self.playCardDatas.repeatt    	= context.re or 0
	self.playCardDatas.totalFan    	= context.toF or 0
	self.playCardDatas.actionCard   = context.acC1 or 0
	self.playCardDatas.flag    		= context.fl or 0
	self.playCardDatas.nextDoorCard = context.neD or 0
	self.playCardDatas.chiCards 	= context.chC or {} -- 吃牌组
	self.playCardDatas.genda  		= context.isGd or false
	self.playCardDatas.yangmaCards  = context.yangMC or {}
	self.playCardDatas.GangHuaCards  = context.fanPiGus or {}   --  杠花
	self.playCardDatas.ChosedGang  = context.gangChoses or {}   --  杠牌列表

	-- -- 移除打出去的牌 
	-- if self.playCardDatas.playedbyID == self.target_:getMyUserId() 
	-- 	and self.playCardDatas.playCard > 0 then
	-- 	self.target_:removeHandMj(self.playCardDatas.playCard, 1)
	-- end
	-- if context.plC == 0 then
		
	-- else
	-- 	self.playCardDatas.playCard = 0
	-- end

	-- 重设操作牌
	local operateSystem 	= MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	-- 重设动作数据
	local actionDatas = {
		-- doorCard   		= context.plC,
		flowerCards 	= self.playCardDatas.flowerCards,
		actions   		= self.playCardDatas.actions,
		addGangCards 	= self.playCardDatas.addGangCards,
		anGangCards  	= self.playCardDatas.anGangCards,
		tingCards       = #self.playCardDatas.tingCards > 0 and self.playCardDatas.tingCards or tingCards,
		tingAftCards    = #self.playCardDatas.tingAftCards > 0 and self.playCardDatas.tingAftCards or tingAftCards,
		actionCard		= self.playCardDatas.actionCard,
		chiCards 		= self.playCardDatas.chiCards,
		yangmaCards		= self.playCardDatas.yangmaCards,
		GangHuaCards	= self.playCardDatas.GangHuaCards,
		ChosedGang	    = self.playCardDatas.ChosedGang,
	}

	if self.playCardDatas.playCard > 0 then
		actionDatas.doorCard = self.playCardDatas.playCard
	else
		-- 打牌动作只是作为弹出操作提示时，重设当前门牌为前一个门牌
		actionDatas.doorCard = operateSystem:getDoorCard()
	end
	operateSystem:resetActionDatas(actionDatas)

	self:setCurrentPlayer(self.playCardDatas.playedbyID)
	-- self:isShowOperateLab()
end

--[[
-- @brief  设置当前出牌的玩家
-- @param  void
-- @return void
--]]
function PlayCardLogic:setCurrentPlayer(id)
	self.currentindex = self.target_:getPlayerSiteById(id)
end
--[[
-- @brief  获取当前出牌的玩家
-- @param  void
-- @return void
--]]
function PlayCardLogic:getCurrentPlayer()
	return self.currentindex 
end
--[[
-- @brief  是否显示操作栏
-- @param  void
-- @return void
--]]
function PlayCardLogic:isShowOperateLab()
	-- local datas = self:getPlayCardDatas()
	local operateSystem 	= MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	local actions  		= operateSystem:getActions()
	if #actions > 0 then
		local myPlayer 	= self.target_:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
		local status 	= myPlayer:getState(enCreatureEntityState.SUBSTITUTE)
		if status == enSubstitusStatus.SUBSTITUTE then
			-- print("托管中")
			return false
		else
			-- print("有吃碰杠操作")
			-- 发送显示操作栏
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACTION_ONSHOW_NTF)
			return true
		end
	end
	return false
end

--[[
-- @brief  获取数据函数
-- @param  void
-- @return void
--]]
function PlayCardLogic:getPlayCardDatas()
	return self.playCardDatas
end
--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function PlayCardLogic:exportMethods()
	self:exportMethods_({
    	"setPlayCardDatas", 
    	"getPlayCardDatas", 
    	"getChiGroupCards",
    	-- "isShowOperateLab",
    	"getCurrentPlayer",
    })
    return self.target_
end

return PlayCardLogic
