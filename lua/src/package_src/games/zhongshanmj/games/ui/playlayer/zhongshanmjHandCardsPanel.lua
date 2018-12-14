local HandCardsPanel = import("app.games.common.ui.playlayer.HandCardsPanel")

local zhongshanmjHandCardsPanel = class("zhongshanmjHandCardsPanel", HandCardsPanel)

--[[
-- @brief  添加麻将对象，数据和麻将对应
-- @param  obj 麻将对象
-- @return void
--]]
-- function zhongshanmjHandCardsPanel:addHandMjObj(obj)
--     self.super.addHandMjObj(self, obj)
--     local value = obj:getValue()

--     -- 设置癞子不可选中
--     local laiziList = self.playSystem:getGameStartDatas().laizi
--     for k, v in pairs(laiziList)  do
--         if value == v then
--             obj:setMjState(enMjState.MJ_STATE_CANT_TOUCH)
--         end
--     end
-- end

--[[
-- @brief  触摸结束函数
-- @param  void
-- @return void
--]]
function zhongshanmjHandCardsPanel:onTouchEnd(touch, event)
    -- 鬼牌提示
    self.super.onTouchEnd(self, touch, event)
    local laiziList = self.playSystem:getGameStartDatas().laizi;
    local guipai;
    for i = 1, #laiziList do
        guipai = laiziList[i];
    end

    for i=1,#self.handCardsObjs do
        if self.handCardsObjs[i]:isContainsTouch(touch:getLocation().x, touch:getLocation().y) then
        -- and self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
            if self.handCardsObjs[i]:getValue() == guipai then
                Toast.getInstance():show("鬼牌不可碰,不可杠,4张全鬼直接胡牌");
            end
        end
    end
end

return zhongshanmjHandCardsPanel