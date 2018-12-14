local PokerRoomRuleView = class("PokerRoomRuleView",PokerUIWndBase)

function PokerRoomRuleView:ctor(data)
    self.super.ctor(self,"package_res/games/pokercommon/poker_rule_view.csb", data);
end
local TITLE_COLOR = cc.c3b(255,255,237)
local CONTENT_COLOR = cc.c3b(174,187,232)

function PokerRoomRuleView:onInit()
    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget,"root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));

    self.pListView = ccui.Helper:seekWidgetByName(self.m_pWidget,"rule_listView");

end

function PokerRoomRuleView:onShow()
    local contentc = ccui.Text:create();
    local ruleData = require("package_src.games." .. self.m_data.gamepath .. ".data.config_GameData")
    for i=1,#ruleData.ruleList do
        local fontSize = ruleData.ruleList[i].isTitle == 1 and 40 or 26
        local isNewLine = i ~= 1 and ruleData.ruleList[i].isTitle == 1 and true or false
        local ruleText = ""
        local color = ruleData.ruleList[i].isTitle == 1 and TITLE_COLOR or CONTENT_COLOR
        local content = contentc:clone()
        content:setColor(color)
        content:setTextAreaSize(cc.size(850, 0));
        if isNewLine then
            ruleText = "\n" .. ruleData.ruleList[i].data
        else
            ruleText = ruleData.ruleList[i].data
        end
        content:setString( ruleText or "提示内容");
        content:setFontSize(fontSize);
        content:ignoreContentAdaptWithSize(false)
        self.pListView:pushBackCustomItem(content);
    end
end

function PokerRoomRuleView:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerRoomRuleView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        self:keyBack()
    end
end
return PokerRoomRuleView