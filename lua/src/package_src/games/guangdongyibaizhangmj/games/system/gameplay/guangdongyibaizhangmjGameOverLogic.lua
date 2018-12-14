local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local guangdongyibaizhangmjGameOverLogic = class("guangdongyibaizhangmjGameOverLogic",GameOverLogic)

function guangdongyibaizhangmjGameOverLogic:ctor()
	guangdongyibaizhangmjGameOverLogic.super.ctor(self)
end

function guangdongyibaizhangmjGameOverLogic:setPlayerDatas(site,context)
	self.gameOverDatas.score[site].fanMaCards = context.fanMaCards or {}
	self.gameOverDatas.score[site].zhongMaCards = context.zhongMaCards or {}
	Log.i("guangdongyibaizhangmjGameOverLogic,context//", self.gameOverDatas.score[site].fanMaCards)
end
function guangdongyibaizhangmjGameOverLogic:setGameOverDatas(cmd, context)
	Log.i("guangdongyibaizhangmjGameOverLogic:setGameOverDatas2....", context)
	self.super.setGameOverDatas(self, cmd, context)
	self.gameOverDatas.maList = context.maList or {}
	-- Log.i("guangdongyibaizhangmjGameOverLogic:setGameOverDatas", self.gameOverDatas.maList)
end

return guangdongyibaizhangmjGameOverLogic
