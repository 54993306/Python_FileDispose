local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local gaozhoumjGameOverLogic = class("gaozhoumjGameOverLogic",GameOverLogic)

function gaozhoumjGameOverLogic:ctor()
	self.super.ctor(self)
end

function gaozhoumjGameOverLogic:setGameOverDatas(site,context)
self.super.setGameOverDatas(self, site, context)
	self.gameOverDatas.ma = context.ma or {}
    self.gameOverDatas.maList = context.maList or {}
	Log.i("gaozhoumjGameOverLogic,context", self.gameOverDatas.ma)
end


function gaozhoumjGameOverLogic:setPlayerDatas(site,context)

   self.gameOverDatas.score[site].zhongMaList = context.zhongMaList 
end

return gaozhoumjGameOverLogic
