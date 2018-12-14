local HallQinyouquanZhiYin = class("HallQinyouquanZhiYin", UIWndBase)

function HallQinyouquanZhiYin:ctor(info)
    self.super.ctor(self, "hall/qinyouquanzhiyin.csb", info, 1);
end

function HallQinyouquanZhiYin:onShow()
    local panel = ccui.Helper:seekWidgetByName(self.m_pWidget, "Panel");
    panel:addTouchEventListener(handler(self, self.onClickButton));
end

function HallQinyouquanZhiYin:onClickButton(pWidget, EventType)
    ----------------------------------------------
    if EventType == ccui.TouchEventType.ended then
        SettingInfo.getInstance():setClubGuidance(true)
        UIManager.getInstance():popWnd(HallQinyouquanZhiYin)
    end
end

-- 收到返回键事件
function HallQinyouquanZhiYin:onKeyBack()
    Log.i("HallQinyouquanZhiYin:onKeyBack....", self.m_pWidget:isTouchEnabled())
    SettingInfo.getInstance():setClubGuidance(true)
    self.super.onKeyBack(self)
end

return HallQinyouquanZhiYin
