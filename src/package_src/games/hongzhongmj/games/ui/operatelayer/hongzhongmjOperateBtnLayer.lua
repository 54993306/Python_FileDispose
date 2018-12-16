local Define            = require "app.games.common.Define"

local OperateBtnLayer = import("app.games.common.ui.operatelayer.OperateBtnLayer")

local hongzhongmjOperateBtnLayer = class("hongzhongmjOperateBtnLayer", OperateBtnLayer)

----------------------------
-- 在这里增加或删除操作选项
function hongzhongmjOperateBtnLayer:modifyActionList(operateList)
    -- Log.i("hongzhongmjOperateBtnLayer:modifyActionList", operateList)
    if #operateList > 0 then
        local gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local handCards = gameSystem:gameStartGetHandMjs()
        -- dump(handCards)
        local hideGuo = true
        
        -- Log.i("hongzhongmjOperateBtnLayer:modifyActionList", #handCards)
        -- 判断手牌中是否有不是赖子的牌
        local laiziList = gameSystem:getGameStartDatas().laizi
        local cardNum = 0
        for handCardValue, handMj in pairs(handCards) do
            Log.i("handCard value", handCardValue)
            local isLaizi = false
            for k, v in pairs(laiziList)  do
                if v == handCardValue then
                    isLaizi = true -- 手牌是赖子
                    break
                end
            end
            if not isLaizi then -- 发现手牌不是赖子, 不需要再做后续判断
                hideGuo = false
                break
            end
            cardNum = cardNum + handMj:getProp(enGoodsProp.NUMBER)
        end
        if cardNum % 3 ~= 2 then hideGuo = false end -- 如果不是轮到自己出牌, 那么可以显示过
        
        if not hideGuo then
           table.insert(operateList, 1, enOperate.OPERATE_GUO)
        end
    end

    return operateList
end

return hongzhongmjOperateBtnLayer