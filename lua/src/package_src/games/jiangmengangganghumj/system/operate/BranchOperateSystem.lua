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
    self.operateData.losIds = context.losIds
    self.operateData.score  = context.sco
    self.operateData.ma  = context.ma

end

function BranchOperateSystem:sendQiangGangHuOperate()
	local playCard 		= self:getDoorCard()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
		enMjMsgSendId.MSG_SEND_MJ_ACTION, 
		enOperate.OPERATE_DIAN_PAO_HU, 
		1, 
		playCard)
end

return BranchOperateSystem


--endregion
