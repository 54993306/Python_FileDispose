--
-- Author: RuiHao Lin
-- Date: 2017-05-25 20:47:19
--

local GameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local jiangmenguipaimjGameOverLogic = class("jiangmenguipaimjGameOverLogic", GameOverLogic)

function jiangmenguipaimjGameOverLogic:ctor()
    self.super.ctor(self.super)
end

function jiangmenguipaimjGameOverLogic:setPlayerDatas(site,context)
    self.gameOverDatas.score[site].TurnCardList = context.fm or {}   --  翻牌列表
    self.gameOverDatas.score[site].TurnCardType = context.maT or {}   --  翻牌类型（0无马，1中马，2全马）
end

return jiangmenguipaimjGameOverLogic