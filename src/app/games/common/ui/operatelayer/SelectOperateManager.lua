-------------------------------------------------------------
--  @file   SelectOperateManager.lua
--  @brief  操作管理器
--  @author Zhu Can Qin
--  @DateTime:2016-09-07 11:48:48
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local SelectChiPanel 	= import(".select.SelectChiPanel", currentModuleName)
local SelectGangPanel 	= import(".select.SelectGangPanel", currentModuleName)
local SelectOperateManager = class("SelectOperateManager")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SelectOperateManager:ctor()
	self.selecteType = {
		[enOperate.OPERATE_CHI] 		= SelectChiPanel,
		[enOperate.OPERATE_AN_GANG] 	= SelectGangPanel,
	}
end

--[[
-- @brief  显示函数
-- @param  selectType 显示类型
-- @return void
--]]
function SelectOperateManager:getOperateType(selectedType)
	local selectObj = self.selecteType[selectedType].new()
	return selectObj
end

return SelectOperateManager