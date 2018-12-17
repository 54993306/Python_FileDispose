local Define        = require "app.games.common.Define"
-- Define.g_pai_out_y = Define.visibleHeight / 2 - 110
local HandCardsPanel = import("app.games.common.ui.playlayer.HandCardsPanel")

local hongzhongmjHandCardsPanel = class("hongzhongmjHandCardsPanel", HandCardsPanel)

--[[
-- @brief  添加麻将对象，数据和麻将对应
-- @param  obj 麻将对象
-- @return void
--]]
function hongzhongmjHandCardsPanel:addHandMjObj(obj)
    self.super.addHandMjObj(self, obj)
    local value = obj:getValue()

    -- 设置癞子不可选中
    local laiziList = self.playSystem:getGameStartDatas().laizi
    for k, v in pairs(laiziList)  do
        if value == v then
            obj:setMjState(enMjState.MJ_STATE_CANT_TOUCH)
        end
    end
end

return hongzhongmjHandCardsPanel