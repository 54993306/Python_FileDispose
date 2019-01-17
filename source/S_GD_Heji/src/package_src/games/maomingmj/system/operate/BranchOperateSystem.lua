--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
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
	self.super.setOperateSystemDatas(self,cmd, context)
	self.operateData.showGangAnimation 	= context.showGangAnimation or false 	-- 操作的牌
	
    
end

return BranchOperateSystem


--endregion
