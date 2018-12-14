--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local OperateSystem = require("app.games.common.system.operate.OperateSystem")

local BranchOperateSystem = class("BranchOperateSystem",OperateSystem)

function BranchOperateSystem:ctor()
	Log.i("BranchOperateSystem:ctor")
	BranchOperateSystem.super.ctor(self)
end
--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function BranchOperateSystem:setOperateSystemDatas(cmd, context)
	Log.i("BranchOperateSystem.cmd,", cmd)
	Log.i("BranchOperateSystem.context,", context)
    self.super.setOperateSystemDatas(self,cmd,context)
    self.operateData.userIds = context.userIds
    self.operateData.diffScore  = context.diffScore 
    self.operateData.diffName = context.diffName
    self.operateData.diffType = context.diffType
    self.operateData.zhongma = context.zhongma
    self.operateData.fanma = context.fanma
    self.operateData.showGangAnimation  = context.showGangAnimation or false 
end
return BranchOperateSystem



