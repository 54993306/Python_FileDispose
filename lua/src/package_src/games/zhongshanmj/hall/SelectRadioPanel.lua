--
-- Author: Nong Jinxia
-- Date: 2017-04-10 09:52:25
--

local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")

local CommonParentPanel=require("app.hall.common.SelectRadioPanel")
local SelectRadioPanel = class("SelectRadioPanel",CommonParentPanel)


-- 设置选中的Index
function SelectRadioPanel:setSelectedIndexShow(index)
    self.m_selectedIndex = index
    for k, v in ipairs(self.m_radioBtns) do
        v:setSelected(v:getIndex() == self.m_selectedIndex)
    end
end

return SelectRadioPanel