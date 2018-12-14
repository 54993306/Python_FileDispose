--
-- Author: Jinds
-- Date: 2017-06-27 16:30:44
--
local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local huizhoumjGameOverLogic = class("huizhoumjGameOverLogic", GameOverLogic)

--[[
-- @brief  玩家数据
-- @param  void
-- @return void
--]]
function huizhoumjGameOverLogic:setPlayerDatas(site, context)
    print("<jinds>:  kid gameover ", context.zc)
	self.gameOverDatas.score[site].maCards = context.zc or {} 	--中马的牌
	self.gameOverDatas.score[site].showMaCards = context.sm or 0 	--是否需要显示马牌
end



return huizhoumjGameOverLogic