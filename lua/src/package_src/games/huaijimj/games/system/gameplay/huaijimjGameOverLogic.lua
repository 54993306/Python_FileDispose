local Component = cc.Component
local commonGameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local huaijimjGameOverLogic = class("huaijimjGameOverLogic", commonGameOverLogic)

--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function huaijimjGameOverLogic:setGameOverDatas(cmd, context)
	self.super.setGameOverDatas(self, cmd, context)
	--新加的翻马字段
    self.gameOverDatas.yimaduorenhu       	= context.yimaduorenhu or false --判断是否一马多人胡牌
    self.gameOverDatas.duoren       	= context.duoren or false --判断是否多人胡牌
	self.gameOverDatas.faI				= context.faI	or {}
	if context.faI and #context.faI > 0 then
		self.gameOverDatas.hasF = true
	end
end

--设置不同麻将玩家数据，可以给子类重写该方法
function huaijimjGameOverLogic:setPlayerDatas(site,context)
	Log.i("overwrite GameOverLogic:setPlayerDatas");
	self.gameOverDatas.score[site].chosedMaCards	= context.chosedMaCards or {} --翻中的马
    self.gameOverDatas.score[site].faI       	= context.faI or {} --单独展示的翻马
end

return huaijimjGameOverLogic