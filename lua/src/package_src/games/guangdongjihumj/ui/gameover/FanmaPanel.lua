--
-- Author: Van
-- Date: 2017-08-03 17:43:10
--
local CardPanel=require("app.games.common.custom.TurnCard.CardPanel")

local FanmaPanel=class("CardPanel",CardPanel)

--  左对齐排列
function FanmaPanel:layoutForAlignLeft()
    local col = 0    --  列
    local row = 1    --  行
    local count = #self.m_ListCard    --  卡牌总数
    local lActualCol = count >= self.m_Options.MaxCol and self.m_Options.MaxCol or count    --  实际列数
    local lActualRow = math.ceil(count / lActualCol)    --  实际行数

    local lCardSize = self.m_ListCard[1]:getContentSize()
    for i = 1, count do
        local offsetX = col * self.m_Options.ColGap
        local posX = lCardSize.width * col + offsetX

        local nY = -(row - ((lActualRow + 1) / 2))
        local offsetY = -nY * -self.m_Options.RowGap
        local posY = lCardSize.height * nY + offsetY

        self.m_ListCard[i]:setPosition(cc.p(posX, posY))

        col = col + 1
        if col >= self.m_Options.MaxCol and col ~= count then
            col = 0
            row = row + 1
        end
    end

    self.m_ActualCol = lActualCol
    self.m_ActualRow = lActualRow

    local lPanelWidth = self.m_ActualCol * lCardSize.width + self.m_Options.ColGap * (self.m_ActualCol - 1)
    local lPanelHeight = self.m_ActualRow * lCardSize.height + self.m_Options.RowGap * (self.m_ActualRow - 1)
    self:setContentSize(cc.size(lPanelWidth, lPanelHeight))
end

return FanmaPanel