--
-- Author: Your Name
-- Date: 2017-05-22 10:36:48
--
-- require("app.DebugHelper")
local CheckBoxPanel = class("CheckBoxPanel",function()
    return display.newNode()
end)

function CheckBoxPanel:ctor(data)
    self.m_data=data
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/zhongshanmj/friendRoom/check_box.csb")
    self.m_pWidget:addTo(self)

    self.m_title=ccui.Helper:seekWidgetByName(self.m_pWidget, "text_title")
    self.m_title:setString(data.title)
    self.m_title:setFontName("hall/font/fangzhengcuyuan.TTF")
    self.m_title:setColor(cc.c3b(255,0,0))
    self.m_title:setFontSize(29)

    self.m_check_box=ccui.Helper:seekWidgetByName(self.m_pWidget, "check_box")
    self.m_check_box:addEventListener(function(target,event)
        -- dump(target)
        -- dump(event)
        -- if event==0 then
        --     self.m_title:setColor(cc.c3b(255,0,0))
        -- else
        --     self.m_title:setColor(cc.c3b(43,76,1))
        -- end
        -- if data.callback then  data.callback(event==0) end
        self:setSelected(event==0)
    end)
    self:setContentSize(self.m_pWidget:getContentSize())
end

function CheckBoxPanel:setEnabled(enable)
    print(enable)
    self.m_check_box:setEnabled(enable)
    -- self.m_check_box:setSelected(enable)
    -- if self.m_data.callback then  self.m_data.callback(enable) end
    self:setSelected(enable)
    if enable then
        self.m_title:setColor(cc.c3b(255,0,0))
    else
        self.m_title:setColor(cc.c3b(160,160,160))
    end
end

function CheckBoxPanel:setSelected(enable)
    if self.m_check_box:isEnabled() then
        if enable then
            self.m_title:setColor(cc.c3b(255,0,0))
        else
            self.m_title:setColor(cc.c3b(43,76,1))
        end
    end
    self.m_check_box:setSelected(enable)
    if self.m_data.callback then  self.m_data.callback(enable) end
end




return CheckBoxPanel