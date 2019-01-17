local GameOverLogic = import("app.games.common.system.gameplay.GameOverLogic")

local hongzhongmjGameOverLogic = class("hongzhongmjGameOverLogic", GameOverLogic)

--[[
-- @brief  设置游戏结束数据函数
-- @param  void
-- @return void
--]]
function hongzhongmjGameOverLogic:setGameOverDatas(cmd, context)
    self.super.setGameOverDatas(self, cmd, context)
    self.gameOverDatas.isND = context.isND or 0  -- 是否显示翻马
    self.gameOverDatas.faI = context.faI or {}  -- 翻马数据
end

return hongzhongmjGameOverLogic
