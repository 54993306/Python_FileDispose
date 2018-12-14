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
    self.gameOverDatas.score[site].TurnCardList = context.fm or {}   --  �����б�
    self.gameOverDatas.score[site].TurnCardType = context.maT or {}   --  �������ͣ�0����1����2ȫ��
end

return jiangmenguipaimjGameOverLogic