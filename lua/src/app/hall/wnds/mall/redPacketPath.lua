-----------------------------------------------------------
--  @file   RedPacketPath.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local kRedPacketPathConfig = {
    tagTip1 = "Label_10_0_1_2", -- 提示语1
    tagTip2 = "lab_wechat", -- 提示语2
    tagTip3 = "Label_10_0_1_3", -- 提示语3
    tagTip4 = "Label_10_0_1_3_4", -- 提示语4
    replaceTips = {"tagTip2", "tagTip3", }, -- 需要替换的提示
    originWechatName = "66麻将",
}
if IsPortrait then -- TODO
    kRedPacketPathConfig = {
        tagTip1 = "Label_1", -- 提示语1
        tagTip1_0 = "Label_1_0", -- 提示语1下面的文字
        tagTip2 = "Label_2", -- 提示语2
        tagTip3 = "Label_3", -- 提示语3
        tagTip4 = "Label_4", -- 提示语4
        replaceTips = {"tagTip2", }, -- 需要替换的提示
        originWechatName = "来来麻将",
    }
end

local RedPacketPath = class("RedPacketPath",UIWndBase)

function RedPacketPath:ctor()
    self.super.ctor(self,"hall/wechat_path.csb")
end

function RedPacketPath:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
        if btn_close ~= nil then
            btn_close:addTouchEventListener(function(widget,touchType)   -- 触摸的回调函数默认传入两个参数
                if touchType == ccui.TouchEventType.ended and 
                   widget:getName() == "btn_close"then
                    self:keyBack() 
                end
            end)
        end

        local btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_back")
        if btn_back ~= nil then
            btn_back:addTouchEventListener(function(widget,touchType)   -- 触摸的回调函数默认传入两个参数
                if touchType == ccui.TouchEventType.ended and 
                   widget:getName() == "btn_back"then
                    self:keyBack() 
                end
            end)
        end
    else
        local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
        btn_close:addTouchEventListener(function(widget,touchType)   -- 触摸的回调函数默认传入两个参数
            if touchType == ccui.TouchEventType.ended and 
               widget:getName() == "btn_close"then
                self:keyBack() 
            end
        end)
    end
    
    local Image_2 = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_2")
    if Image_2 and cc.FileUtils:getInstance():isFileExist(_WeChatNameImage) then
        Image_2:loadTexture(_WeChatNameImage)
    end

    for i, v in ipairs(kRedPacketPathConfig.replaceTips) do
        local tip = ccui.Helper:seekWidgetByName(self.m_pWidget, kRedPacketPathConfig[v])
        local str = string.gsub(tip:getString(), kRedPacketPathConfig.originWechatName, _OFFICIALWECHAT)
        tip:setString(str)
    end
end

return RedPacketPath