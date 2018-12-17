local HandCardsPanel = require("app.games.common.ui.playlayer.HandCardsPanel")
local shanweimjHandCardsPanel = class("shanweimjHandCardsPanel", HandCardsPanel)

--[[
-- @brief  移除手牌
-- @param  content
-- @return void
--]]
function shanweimjHandCardsPanel:removeHandMjAction(content)
	local removeList 	= {} -- 需要移除的对象列表
	local handCardsList = {} -- 剩下手牌的对象列表
	
	if content.actionID == enOperate.OPERATE_YANGMA then
        --  根据牌组列表移除手牌
        local lCBCard = clone(content.cbCards)
		for i, v in pairs(self.handCardsObjs) do
            local isRemove = false
            for j, k in pairs(lCBCard) do
			    if v:getValue() == k then
				    table.insert(removeList, v)
                    lCBCard[j] = nil
                    isRemove = true
                    break
			    end
            end
            if not isRemove then
			    table.insert(handCardsList, v)
            end
		end
		self.handCardsObjs = handCardsList
		if #removeList > 0 then
			-- 移除手牌麻将并重新排位
			self:actionMoveHandMj(removeList)
			-- 重新排序
			self:reSortMjListPosition()
		end
	else
		shanweimjHandCardsPanel.super.removeHandMjAction(self, content)
	end
end

return shanweimjHandCardsPanel
