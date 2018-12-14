-------------------------------------------------------------
--  @file   GameStartLogic.lua
--  @brief  开始游戏逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 19:59:17
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Component = cc.Component
local GameStartLogic = require("app.games.common.system.gameplay.GameStartLogic")
local jieyangmjGameStartLogic = class("jieyangmjGameOverLogic", GameStartLogic)
local EntityFactory =  require("app.games.common.entity.EntityFactory")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]

function jieyangmjGameStartLogic:setGameStartDatas(cmd, context)
    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    local itemList = Util.analyzeString_2(palyingInfo.wa);
    GC_TurnLaiziPath = "package_res/games/jieyangmj/common/fanpai.png"
	for _,v in ipairs(itemList) do
		-- GC_TurnLaiziPath = "package_res/games/jieyangmj/common/fanpai.png"
		if v == "baibanzuogui" then
			context.fa = 47;
			GC_TurnLaiziPath = "package_res/games/jieyangmj/common/guipai.png"
		end

		if v == "zhongzuogui" then
			context.fa = 45;
			GC_TurnLaiziPath = "package_res/games/jieyangmj/common/guipai.png"
		end
	end

	 jieyangmjGameStartLogic.super.setGameStartDatas(self,cmd, context)

end


return jieyangmjGameStartLogic
