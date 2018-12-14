--
-- Author: Jinds
-- Date: 2017-06-26 19:37:34
--
local GameStartLogic = require("app.games.common.system.gameplay.GameStartLogic")
local huizhoumjGameStartLogic = class("huizhoumjGameStartLogic", GameStartLogic)

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function huizhoumjGameStartLogic:setAttachDatas( context)
----------------------------------add-------------------------------------------------------------
	self.gameStartDatas.horseCards 	= context.cMa or {}   --开局发过来的翻马的牌
----------------------------------------------------------------------------------------------------
end



return huizhoumjGameStartLogic