local commonGameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local shantoumjGameOverLogic = class("shantoumjGameOverLogic", commonGameOverLogic)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function shantoumjGameOverLogic:ctor()
    shantoumjGameOverLogic.super.ctor(self, "shantoumjGameOverLogic")
end


--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function shantoumjGameOverLogic:setGameOverDatas(cmd, context)
	self.super.setGameOverDatas(self, cmd, context)

	self.gameOverDatas.dice = context.dice or {} 	-- 大胡乘以骰子的数值
	--新加的翻马字段
	self.gameOverDatas.ho				= context.faI	or {}  --奖马信息
end

--设置不同麻将玩家数据，可以给子类重写该方法
function shantoumjGameOverLogic:setPlayerDatas(site,context)
   Log.i("overwrite GameOverLogic:setPlayerDatas");
    self.gameOverDatas.score[site].maimaInfo	    = context.faI or {} --买马信息
    self.gameOverDatas.score[site].nofeetypes	    = context.ocnofeetypes or {} --不算分的杠
end

return shantoumjGameOverLogic