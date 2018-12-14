-------------------------------------------------------------
--  @file   GameOverLogic.lua
--  @brief  打牌逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 20:10:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Component = cc.Component
local GameOverLogic = class("GameOverLogic", Component)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameOverLogic:ctor()
    GameOverLogic.super.ctor(self, "GameOverLogic")
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function GameOverLogic:onBind_()
	self.gameOverDatas = {}
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function GameOverLogic:onUnbind_()
	self.gameOverDatas = {}
end

--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function GameOverLogic:setGameOverDatas(cmd, context)
	-- Log.i("----------------------------------------setGameOverDatas",context)
	self.gameOverDatas 	= {}
	self.gameOverDatas.score = {}
	self.winerId 		= 0 -- 赢家id 

	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    sys:setGameStarted(false)
    sys:setMjDistrubuteEnd(false)

	for i=1, playerCount do
		local site = i
		local index = self:getOverPlayerIndex(site, context)
		if nil == index then
			printError("无效的索引%d", index)
			return 
		end
		if nil == self.gameOverDatas.score[site] then
			self.gameOverDatas.score[site] = {}
		end
		self.gameOverDatas.score[site].userid 		= context.scI[index].usID
		self.gameOverDatas.score[site].nick 		= context.scI[index].niN
		self.gameOverDatas.score[site].totalFan 	= context.scI[index].toF
		self.gameOverDatas.score[site].totalScore 	= context.scI[index].toS
		self.gameOverDatas.score[site].totalMutil 	= context.scI[index].toM
		self.gameOverDatas.score[site].anGang 		= context.scI[index].anG
		self.gameOverDatas.score[site].gang 		= context.scI[index].toGG or 0
		self.gameOverDatas.score[site].result 		= context.scI[index].re
		self.gameOverDatas.score[site].totalGold  	= context.scI[index].toG
		self.gameOverDatas.score[site].tiwaiTotalGold = context.scI[index].tiwaiTotalGold --体外分数
		self.gameOverDatas.score[site].totalHuGold 	= context.scI[index].toHG
		self.gameOverDatas.score[site].totalGangGold 	= context.scI[index].toGG
		self.gameOverDatas.score[site].totalCash  		= context.scI[index].taC
		self.gameOverDatas.score[site].totalPaoGold 	= context.scI[index].toPG
		self.gameOverDatas.score[site].lastCard 		= context.scI[index].laC
        self.gameOverDatas.score[site].HuCard	        = context.scI[index].huCard --  真正要胡的牌（lastCard可能是癞子）
		self.gameOverDatas.score[site].broker 			= context.scI[index].ba
		self.gameOverDatas.score[site].closeCards 		= context.scI[index].clC       --手牌
		self.gameOverDatas.score[site].policyName 		= context.scI[index].PoN
		self.gameOverDatas.score[site].policyScore 		= context.scI[index].PoS
		self.gameOverDatas.score[site].tiwaiPolicyNames 		= context.scI[index].tiwaiPolicyNames --体外翻型名
		self.gameOverDatas.score[site].tiwaiPolicyScores 		= context.scI[index].tiwaiPolicyScores --体外翻型分值
        self.gameOverDatas.score[site].addPolicyName 	= context.scI[index].adPN
        self.gameOverDatas.score[site].addPolicyScore 	= context.scI[index].adPS
        self.gameOverDatas.score[site].flowerCards 		= context.scI[index].flC or {} 	-- 花牌数组
        self.gameOverDatas.score[site].operatefirstCard	= context.scI[index].opC or {}  -- 吃碰杠的牌
        self.gameOverDatas.score[site].operateCard		= context.scI[index].opCAC or {} --吃碰杠哪张牌
        self.gameOverDatas.score[site].operateType		= context.scI[index].opCT or {}  --吃碰杠类型
        self.gameOverDatas.score[site].operateUserid	= context.scI[index].opCUI or {} --吃碰谁的牌
        self.gameOverDatas.score[site].operateCardGroup	= context.scI[index].opCO or {} --  吃碰杠牌组
       -- -- 根据获得的总财富值大于0来设置赢家的id
        -- if self.gameOverDatas.score[site].totalGold > 0 then
        -- 	self.gameOverDatas.winnerId = self.gameOverDatas.score[site].userid or 0
        -- end
        -- 根据result来设置赢家的id
        if self.gameOverDatas.score[site].result == 1 then
            self.gameOverDatas.winnerId = self.gameOverDatas.score[site].userid or 0
        end
        -- 重设财富值
       	local player = self.target_:gameStartGetPlayerBySite(site)
        player:setProp(enCreatureEntityProp.FORTUNE, self.gameOverDatas.score[site].totalCash)
		
		self:setPlayerDatas(site,context.scI[index]);--设置不同麻将玩家数据，可以给子类重写该方法
	end
	self.gameOverDatas.paymentDetails = {info.de or {}, info.de7 or {}, info.de8 or {}, info.de9 or {}} 
	self.gameOverDatas.winType = context.wi or 0   	--1自摸 2 炮胡 3 流局
	self.gameOverDatas.huCount = context.haHC or 0 	-- 胡牌人数
	self.gameOverDatas.isOver = context.isO or false 	-- 是不是最后一局 旧版上一直是false
end

--设置不同麻将玩家数据，可以给子类重写该方法
function GameOverLogic:setPlayerDatas(site,context)
   Log.i("overwrite GameOverLogic:setPlayerDatas");
end

--[[
-- @brief  获取玩家数据索引函数
-- @param  void
-- @return void
--]]
function GameOverLogic:getOverPlayerIndex(site, context)
	-- local gameStartSys = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	-- dump(self.target_:gameStartGetPlayerBySite(site):getProp(enCreatureEntityProp.USERID))
	for i=1,#context.scI do
		if self.target_:gameStartGetPlayerBySite(site):getProp(enCreatureEntityProp.USERID) == context.scI[i].usID then
			return i
		end
	end
	return nil
end

--[[
-- @brief  获取游戏结束数据函数
-- @param  void
-- @return void
--]]
function GameOverLogic:getGameOverDatas()
	return self.gameOverDatas
end

-- --[[
-- -- @brief  设置赢家id
-- -- @param  id 赢家id
-- -- @return void
-- --]]
-- function GameOverLogic:setWinerId(id)
-- 	self.winerId = id
-- end

-- --[[
-- -- @brief  获取赢家id
-- -- @param  void
-- -- @return void
-- --]]
-- function GameOverLogic:getWinerId()
-- 	return self.winerId
-- end

--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function GameOverLogic:exportMethods()
	self:exportMethods_({
        "setGameOverDatas",
        "getGameOverDatas",
        "getWinerId",
    })
    return self.target_
end

return GameOverLogic
