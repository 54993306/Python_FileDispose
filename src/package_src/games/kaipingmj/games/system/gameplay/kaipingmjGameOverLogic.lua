local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local kaipingmjGameOverLogic = class("kaipingmjGameOverLogic",GameOverLogic)

function kaipingmjGameOverLogic:ctor()
	kaipingmjGameOverLogic.super.ctor(self)
end

function kaipingmjGameOverLogic:setPlayerDatas(site,context)
	self.gameOverDatas.score[site].fanMaCards = context.fanMaCards or {}
	self.gameOverDatas.score[site].zhongMaCards = context.zhongMaCards or {}
	Log.i("kaipingmjGameOverLogic,context//", self.gameOverDatas.score[site].fanMaCards)
end
function kaipingmjGameOverLogic:setGameOverDatas(cmd, context)
	Log.i("kaipingmjGameOverLogic:setGameOverDatas2....", context)
	self.super.setGameOverDatas(self, cmd, context)
	self.gameOverDatas.maList = context.maList or {}

	Log.i("kaipingmjGameOverLogic:setGameOverDatas", self.gameOverDatas.maList)
end

return kaipingmjGameOverLogic
