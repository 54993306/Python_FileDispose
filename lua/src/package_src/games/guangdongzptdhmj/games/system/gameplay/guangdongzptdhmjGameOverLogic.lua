local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local guangdongzptdhmjGameOverLogic = class("guangdongzptdhmjGameOverLogic",GameOverLogic)

function guangdongzptdhmjGameOverLogic:ctor()
	self.super.ctor(self)
end

function guangdongzptdhmjGameOverLogic:setGameOverDatas(site,context)
	self.super.setGameOverDatas(self, site, context)
	self.gameOverDatas.ma = context.ma or {}
    self.gameOverDatas.faI = context.faI or {}
    self.gameOverDatas.fanmaTypeInfo = context.fanmaTypeInfo or {}
    self.gameOverDatas.maList = context.maList or {}
	Log.i("guangdongzptdhmjGameOverLogic,context", context)
end

--设置不同麻将玩家数据，可以给子类重写该方法
function guangdongzptdhmjGameOverLogic:setPlayerDatas(site,context)
	self.gameOverDatas.score[site].showMa	= context.showMa or 0 --  是否显示翻马
end

return guangdongzptdhmjGameOverLogic
