local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local jiangmengangganghumjGameOverLogic = class("jiangmengangganghumjGameOverLogic",GameOverLogic)

function jiangmengangganghumjGameOverLogic:ctor()
	self.super.ctor(self)
end

function jiangmengangganghumjGameOverLogic:setGameOverDatas(site,context)
self.super.setGameOverDatas(self, site, context)
	self.gameOverDatas.ma = context.ma or {}
	Log.i("jiangmengangganghumjGameOverLogic,context", self.gameOverDatas.ma)
end
function jiangmengangganghumjGameOverLogic:setPlayerDatas(site,context)

   self.gameOverDatas.score[site].zhongMaCards = context.zhongMaCards 
  end

return jiangmengangganghumjGameOverLogic
