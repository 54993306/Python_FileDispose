--
-- Author: RuiHao Lin
-- Date: 2017-05-25 20:47:19
--

local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local gaozhoumaimamjGameOverLogic = class("gaozhoumaimamjGameOverLogic", GameOverLogic)

function gaozhoumaimamjGameOverLogic:ctor()
    self.super.ctor(self.super)
end

--override
--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function gaozhoumaimamjGameOverLogic:setGameOverDatas(cmd, context)
    self.super.setGameOverDatas(self, cmd, context)
    self.gameOverDatas.MaList = context.maList  --  翻马列表
end

return gaozhoumaimamjGameOverLogic