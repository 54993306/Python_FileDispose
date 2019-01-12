-----------------------------------------------------------
--  @file   Contact_us.lua
--  @brief  关于界面
--  @author linxiancheng
--  @DateTime:2017-05-27 10:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

about_us = class("about_us", UIWndBase)

function about_us:ctor(...)
    self.super.ctor(self,"hall/about_us.csb",...)
end

function about_us:keyBack()
    UIManager:getInstance():popWnd(about_us)
end

function about_us:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.lab_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_name");
    self.lab_name:setString(_gameName);

    self.lab_owner = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_owner");
    self.lab_owner:setString(_copyright);

    self.lab_publisher = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_publisher");
    self.lab_publisher:setString(_publishcompany);

    self.lab_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_num");
    self.lab_num:setString(_AuditingFileNo);

    self.lab_lsbn = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_lsbn");
    self.lab_lsbn:setString(_ISBN);
end

function about_us:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_agency then
            self:agency()
        end
    end
end
