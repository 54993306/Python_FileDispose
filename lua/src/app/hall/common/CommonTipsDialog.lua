--通用提示界面

CommonTipsDialog = class("CommonTipsDialog", UIWndBase);

function CommonTipsDialog:ctor(info)
    self.super.ctor(self, "hall/tips_dialog.csb", info);
end

function CommonTipsDialog:onInit()

    local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");
    title:setString(self.m_data.title or "提示");
    title:enableShadow();
    --
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.lis_content = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_content");
end

-- 响应窗口显示
function CommonTipsDialog:onShow()
    if self.m_data.isUserAgreement then
       self.lis_content:setVisible(false);
    else
        local content = ccui.Text:create();
        content:setFontName("font/bold.ttf");
        content:enableShadow();
        content:setTextAreaSize(cc.size(600, 0));
        content:setString(self.m_data.content or "提示内容");
        content:setFontSize(26);
        content:ignoreContentAdaptWithSize(false)

        self.lis_content:pushBackCustomItem(content);
    end

end

function CommonTipsDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack();
        end;
    end 
end