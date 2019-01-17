--
-- Author: RuiHao Lin
-- Date: 2017-06-05 20:28:35
--

local GameUIView = require("app.games.common.ui.bglayer.GameUIView")
local jiangmenguipaimjGameUIView = class("jiangmenguipaimjGameUIView", GameUIView)

--  override
function jiangmenguipaimjGameUIView:ctor(data)
    self.super.ctor(self, data)
end

--  override
function jiangmenguipaimjGameUIView:onInit()
    self.super.onInit(self)
    self:changeLaPaoZuoPosition()
end

--  ������������ťλ��Ϊˮƽ����
function jiangmenguipaimjGameUIView:changeLaPaoZuoPosition()
    local panels =
    {
        self.paoPanel,
        self.laPanel,
        self.zuoPanel,
    }

    local btns = 
    {
        self.paoBtns,
        self.laBtns,
        self.zuoBtns,
    }

    local gapValue = 30 --���

    for i, v in ipairs(panels) do
        self:changeLaPaoZuoBtnGap(btns[i], gapValue)
        v:setContentSize(cc.size(display.width, v:getContentSize().height))
        local currMargin = v:getLayoutParameter():getMargin()
        local offset = v:getContentSize().width / 2
        currMargin.right = display.cx - offset
        currMargin.bottom = currMargin.bottom - 50
        v:getLayoutParameter():setMargin(currMargin)
    end
end

--[[
    @brief      ������������ť��϶
    @btnList    ��ť�б�
    @gapValue   ���
--]]
function jiangmenguipaimjGameUIView:changeLaPaoZuoBtnGap(btnList, gapValue)
    local lBtnCount = #btnList
    for i, v in ipairs(btnList) do
        local n = i - ((lBtnCount + 1) / 2)
        local offset = n * gapValue
        v:setPositionX(display.cx + v:getContentSize().width * n + offset)
    end
end

return jiangmenguipaimjGameUIView