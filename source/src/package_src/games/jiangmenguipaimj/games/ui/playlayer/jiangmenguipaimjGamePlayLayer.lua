--
-- Author: RuiHao Lin
-- Date: 2017-07-11 10:58:54
--

local UIFactory  = require "app.games.common.ui.UIFactory"
local GamePlayLayer = require("app.games.common.ui.playlayer.GamePlayLayer")
local jiangmenguipaimjGamePlayLayer = class("jiangmenguipaimjGamePlayLayer", GamePlayLayer)

--	override
--[[
-- @brief  运行番子动画
-- @param  void
-- @return void
--]]
function jiangmenguipaimjGamePlayLayer:runFanziCard()
	-- 获取游戏数据
	local data = self.gamePlaySystem:getGameStartDatas()
	assert(data ~= nil)
	if data.laizi and #data.laizi > 0 then
        self.turnLaizigou = UIFactory.createMJTurnLaizigou(_gameType, data.laizi[1])
        self.turnLaizigou:addTo(self)
	end
end

return jiangmenguipaimjGamePlayLayer