--
-- Author: Jinds
-- Date: 2017-07-06 12:17:04
--
 local OperateSystem = import("app.games.common.system.operate.OperateSystem")
 local huizhoumjOperateSystem = class("huizhoumjOperateSystem", OperateSystem)


function huizhoumjOperateSystem:setOperateSystemDatas(cmd, context)
	self.super.setOperateSystemDatas(self, cmd, context)
	self.operateData.tingCards 	= context.tiC or 0 

end

--[[
-- @brief  请求报大哥的操作
-- @param  void
-- @return void
--]]
function huizhoumjOperateSystem:sendBaoDaGeOperate()
	-- local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_BAO_DA_GE, 
		1, 
		0)
end


--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function huizhoumjOperateSystem:getActions()
	local needActions = {}
	if #self.actionDatas.actions > 0  then
		for i=1,#self.actionDatas.actions do
			local v = self.actionDatas.actions[i]
			if v == enOperate.OPERATE_DIAN_PAO_HU 
				or v == enOperate.OPERATE_ZI_MO_HU
				or v == enOperate.OPERATE_QIANG_GANG_HU 
				or v == enOperate.OPERATE_MING_GANG
				or v == enOperate.OPERATE_AN_GANG 
				or v == enOperate.OPERATE_JIA_GANG 
				or v == enOperate.OPERATE_PENG
				or v == enOperate.OPERATE_CHI 
				or v == enOperate.OPERATE_TING
				or v == enOperate.OPERATE_TIAN_TING
				or v == enOperate.OPERATE_TIAN_HU
				or v == enOperate.OPERATE_DIAN_TIAN_HU
				 
				--------------------add----------------------
				or v == enOperate.OPERATE_BAO_DA_GE 
				-----------------------------------------------
				or v == enOperate.OPERATE_TING_RECONNECT
				or v == enOperate.OPERATE_DIAN_DI_HU
				or v == enOperate.OPERATE_YANGMA
				or v == enOperate.OPERATE_DI_HU then
				needActions[#needActions + 1] = v
			end
		end
	end
	return needActions or {}
end



 return huizhoumjOperateSystem