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
-- @brief  ������Ϸ�������ݺ���
-- @param  void
-- @return void
--]]
function gaozhoumaimamjGameOverLogic:setGameOverDatas(cmd, context)
    self.super.setGameOverDatas(self, cmd, context)
    self.gameOverDatas.MaList = context.maList  --  �����б�
end

return gaozhoumaimamjGameOverLogic