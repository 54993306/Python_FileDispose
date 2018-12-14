--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")

local BranchGameOverLogic = class("BranchGameOverLogic",GameOverLogic)

function BranchGameOverLogic:ctor()
    self.super.ctor(self)
end

--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function BranchGameOverLogic:setGameOverDatas(cmd, context)
   self.super.setGameOverDatas(self,cmd, context)
   local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    sys:setGameStarted(false)
    sys:setMjDistrubuteEnd(false)

	for i=1, playerCount do
		local site = i
		local index = self:getOverPlayerIndex(site, context)
		if nil == index then
			printError("无效的索引%d", index)
			return 
		end
		if nil == self.gameOverDatas.score[site] then
			self.gameOverDatas.score[site] = {}
		end
        self.gameOverDatas.score[site].fanma = context.scI[index].fanma
        self.gameOverDatas.score[site].zhongma = context.scI[index].zhongma
    end

   self.gameOverDatas.maList = context.mas
   local maList = {}
    self.gameOverDatas.fanMaShow = {}
    for i,v in pairs(self.gameOverDatas.maList) do
        self.gameOverDatas.fanMaShow = v.fanma or {}
        table.insert(maList,v)
    end
    self.gameOverDatas.maList = maList or {}
    self.gameOverDatas.isQuanMa = context.isQuanMa or false
end
return BranchGameOverLogic



--endregion
