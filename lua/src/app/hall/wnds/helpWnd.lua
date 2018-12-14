-----------------------------------------------------------
--  @file   HelpWnd.lua
--  @brief  免责声明
--  @author huangrulin
--  @DateTime:2017-10-14
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local HelpWnd = class("HelpWnd",UIWndBase)

function HelpWnd:ctor(data)
    HelpWnd.super.ctor(self,"hall/helpWnd.csb",data)
end 

local function createText(text, textWidth)
    local index = string.find(text,"##")

    local horizontalAlignment = cc.TEXT_ALIGNMENT_LEFT
    local str_size = 24
    if index then
        str_size = 28 
        local str_content = string.split(text,"##")
        text = str_content[2]
        horizontalAlignment = cc.TEXT_ALIGNMENT_CENTER
    end

    local content = ccui.Text:create();
    content:setFontName("hall/font/fangzhengcuyuan.TTF")
    if IsPortrait then -- TODO
        content:setColor(cc.c3b(0x33,0x33,0x33))
    else
        content:setColor(cc.c3b(0xff,0xff,0xff))
        content:setOpacity(179)
    end
    content:setTextAreaSize(cc.size(textWidth, 0));    
    content:setTextHorizontalAlignment(horizontalAlignment)
    content:setString(text);
    content:setFontSize(str_size);
    content:ignoreContentAdaptWithSize(false)
    return content
end

function HelpWnd:onInit()
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")
    if self.m_data and self.m_data.title then
        lab_title:setString(self.m_data.title)
    end
    
    local txt_str = self.m_data.content
    if type(txt_str) ~= "table" then
        txt_str = {txt_str}
    end

    local list = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_content")
    local textWidth = list:getContentSize().width - 20
    for _,text in ipairs(txt_str) do 
        list:pushBackCustomItem( createText( text, textWidth) );
    end

    local keyback = function(widget, touchType)
        if touchType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            self.keyBack()
        end
    end

    local btn_return = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_return")
    btn_return:addTouchEventListener(keyback)
end

return HelpWnd
