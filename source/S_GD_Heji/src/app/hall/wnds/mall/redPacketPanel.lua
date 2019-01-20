-----------------------------------------------------------
--  @file   RedPacketPanel.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local RedPacketPanel = class("RedPacketPanel",UIWndBase)
local RedPacketPath = require "app.hall.wnds.mall.redPacketPath"

function RedPacketPanel:ctor(data,mall)
    self.Mall = mall
    self.super.ctor(self,"hall/redpacket_panel.csb",data)
end

local function drawUnderline(node)
    local drawNode = cc.DrawNode:create()
    local color = node:getTextColor()
    local size = node:getContentSize()
    -- 2b-4c-01  转化十进制为  43-76-1     43 = 2*16^1 + 11(b) * 16^0(16进制转10进制)
    drawNode:drawLine(cc.p(0, 0), cc.p(size.width, 0), cc.c4f(1,1,1, 0.5))
    drawNode:setPosition(cc.p(0, 0))
    drawNode:setAnchorPoint(cc.p(0, 0))
    node:addChild(drawNode)
end

local function copyGoWechat(self)
    local nativeData = {}
    nativeData.cmd = NativeCall.CMD_CLIPBOARD_COPY;
    nativeData.content = string.format("%s",self.m_data)  -- 格式化字符串可以自定义字符串的情况,例如时间返回00:00:00
    Log.i("RedPacketPanel:copyGoWechat--------------",self.m_data)
    NativeCall:getInstance():callNative(nativeData)

    TouchCaptureView.getInstance():showWithTime()
    if device.platform == "ios" then
        device.openURL("weixin://")
        UIManager.getInstance():popWnd(self.Mall)
        self:keyBack()
    else
        local data = {}
        data.cmd = NativeCall.CMD_OPEN_WEIXIN
        NativeCall.getInstance():callNative(data, function(info)
            if info.errCode and info.errCode == -1 then
                Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
            else
                UIManager.getInstance():popWnd(self.Mall)
                self:keyBack()
            end
        end);
    end
end

local function btnCallBack(self,widget,touchType)
    if touchType == ccui.TouchEventType.ended then
        if widget:getName() == "btn_close" then
            self:keyBack();
        elseif widget:getName() == "lab_path" then
            UIManager.getInstance():pushWnd(RedPacketPath);
        elseif widget:getName() == "btn_goto" then
            copyGoWechat(self)
            UIManager.getInstance():popWnd(self.Mall)
            self:keyBack();
        end
    end
end

local function TipsLab(self)
    local btn_goto = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_goto");
    local params = {}
    local text = string.format("您的红包兑换码为：%s，一键前往微信公众号: “ %s ”，输入兑换码领取红包",self.m_data,_OFFICIALWECHAT)
    params.text = text
    params.font = "res_TTF/1016001.TTF"
    params.size = 30
    params.align =  cc.TEXT_ALIGNMENT_CENTER
    params.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    params.color =  cc.c3b(0xff,0xff,0xff)              --cc.c3b
    if IsPortrait then -- TODO
        params.text = string.format("您的红包兑换码为：%s，一键前往\n微信公众号: “ %s ”，输入兑换码\n领取红包",self.m_data,_OFFICIALWECHAT)
        params.color =  cc.c3b(0x00,0x00,0x00)              --cc.c3b
    end
    local lenth = ToolKit.widthSingle(params.text)
    local tDynamicLabel = display.newTTFLabel(params)
    local tMaxLength = 32
    local textSize = 20
    if lenth < tMaxLength then
        tDynamicLabel:setDimensions(lenth*textSize,textSize+20)
    else
        local texLen = math.ceil(lenth/tMaxLength)
        tDynamicLabel:setDimensions(tMaxLength*textSize,(textSize+10)*texLen)
    end
    tDynamicLabel:pos(display.cx,display.cy + 100)
    self.m_pWidget:addChild(tDynamicLabel)
end

function RedPacketPanel:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
    end
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    btn_close:addTouchEventListener(handler(self,btnCallBack))

    local btn_goto = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_goto");
    btn_goto:addTouchEventListener(handler(self,btnCallBack))

    local lab_path = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_path");
    lab_path:addTouchEventListener(handler(self,btnCallBack))

    drawUnderline(lab_path)

    TipsLab(self)

end

return RedPacketPanel