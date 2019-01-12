--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local OperateSystem = require("app.games.common.system.operate.OperateSystem")

local BranchOperateSystem = class("BranchOperateSystem",OperateSystem)

function BranchOperateSystem:ctor()
	BranchOperateSystem.super.ctor(self)
end
--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function BranchOperateSystem:setOperateSystemDatas(cmd, context)
    self.super.setOperateSystemDatas(self,cmd,context)
    self.operateData.fanmas = context.mas
    self.operateData.isQuanMa = context.isQuanMa
    self.operateData.losIds = context.losIds
    self.operateData.score  = context.sco
end

--[[
-- @brief  请求抢杠胡的操作
-- @param  void
-- @return void
--]]
function BranchOperateSystem:sendQiangGangHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_DIAN_PAO_HU, 
		1, 
		playCard)
end
--[[
-- @brief  请求过的操作
-- @param  void
-- @return void
--]]
function BranchOperateSystem:sendGuoOperate(acs)
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
    local actionid = actions[1]
    if actionid == enOperate.OPERATE_QIANG_GANG_HU then
        actionid = enOperate.OPERATE_DIAN_PAO_HU
    end
	if actionid == enOperate.OPERATE_TING then
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		actionid, 
		0)
	else
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		actionid, 
		0, 
		playCard)
	end

	-- 点过也要重置动作
	local haveTing = false
	for k, v in pairs(self.actionDatas.actions) do
		if v == enOperate.OPERATE_TING or v == enOperate.OPERATE_TIAN_TING then
			haveTing = true
		end		
	end

	if not haveTing then self:initActionDatas() end

	-- 点过发消息去根据手牌数量更新超时操作提示
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_REFRESH_OPERATOR_OVER_TIME)

end
return BranchOperateSystem


--endregion
