local GameDispenseLogic = import("app.games.common.system.gameplay.GameDispenseLogic")
local huaijimjGameDispenseLogic = class("huaijimjGameDispenseLogic", GameDispenseLogic)

--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function huaijimjGameDispenseLogic:setDispenseCardDatas(cmd, context)
	self.dispenseCardDatas = {}
	self.dispenseCardDatas.playId 	= context.plID
	self.dispenseCardDatas.userId 	= context.usID
	self.dispenseCardDatas.card 	= context.ca
	self.dispenseCardDatas.isBaoma  = context.isBaoMa or false
	self.dispenseCardDatas.baomaCard  = context.baoMa
	self.dispenseCardDatas.isHaveNextAct 	= context.haA or false -- 是否有后续操作
	local remainCards = SystemFacade:getInstance():getRemainPaiCount() - 1
	SystemFacade:getInstance():setRemainPaiCount(remainCards)
	-- -- 发手牌加入到队列里面
	-- self.target_:addHandMj(self.dispenseCardDatas.card, 1)
end

return huaijimjGameDispenseLogic