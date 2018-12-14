--
-- Author: Jinds
-- Date: 2017-06-26 19:37:34
--
local GameDispenseLogic = require("app.games.common.system.gameplay.GameDispenseLogic")
local zhaoqingmjGameDispenseLogic = class("zhaoqingmjGameDispenseLogic", GameDispenseLogic)




--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function zhaoqingmjGameDispenseLogic:setDispenseCardDatas(cmd, context)
	-- zhaoqingmjGameDispenseLogic.super:setDispenseCardDatas(cmd, context)
	self.dispenseCardDatas = {}
	self.dispenseCardDatas.playId 	= context.plID
	self.dispenseCardDatas.userId 	= context.usID
	self.dispenseCardDatas.card 	= context.ca
	self.dispenseCardDatas.isHaveNextAct 	= context.haA or false -- 是否有后续操作
	local remainCards = SystemFacade:getInstance():getRemainPaiCount() - 1
	SystemFacade:getInstance():setRemainPaiCount(remainCards)
	if context.neO then
		self.dispenseCardDatas.maCard = context.BHC or 0 
	end
	

end


return zhaoqingmjGameDispenseLogic