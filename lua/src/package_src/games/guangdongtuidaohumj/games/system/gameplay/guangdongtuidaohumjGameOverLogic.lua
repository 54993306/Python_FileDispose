local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local guangdongtuidaohumjGameOverLogic = class("guangdongtuidaohumjGameOverLogic",GameOverLogic)

function guangdongtuidaohumjGameOverLogic:ctor()
	self.super.ctor(self)
end

function guangdongtuidaohumjGameOverLogic:setGameOverDatas(site,context)
self.super.setGameOverDatas(self, site, context)
	self.gameOverDatas.ma = context.ma or {}
    self.gameOverDatas.faI = context.faI or {}
    self.gameOverDatas.fanmaTypeInfo = context.fanmaTypeInfo or {}
    self.gameOverDatas.maList = context.maList or {}
	Log.i("guangdongtuidaohumjGameOverLogic,context", self.gameOverDatas.ma)
end

return guangdongtuidaohumjGameOverLogic
