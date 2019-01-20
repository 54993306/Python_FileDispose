-----------------------------------------------------------
--  @file   CommonTips.lua
--  @brief  小弹出框
--  @author linxiancheng
--  @DateTime:2017-07-12 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local CommonTips = class("CommonTips",UIWndBase)


function CommonTips:ctor(...)
    CommonTips.super.ctor(self,"hall/common_tips.csb",...)
end

function CommonTips:onInit()
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    if IsPortrait then -- TODO
        self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
        self.btn_close:addTouchEventListener(handler(self, self.onClickButton))
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    if self.m_data.type == 2 then
        self:DynamicNode()
    else
        self:DynamicLabel()
    end
     --因为webView一直会保持在最上层导致弹出框被覆盖所以要关闭
     local ActivityDialog = require("app.hall.wnds.activity.ActivityDialog")
     if UIManager.getInstance():getWnd(ActivityDialog) then
         self:keyBack()
     end
end

function CommonTips:onClickButton(pWidget, EventType)
 if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        end
    end    
end

function CommonTips:DynamicLabel()
    -- params.text = "了肯德基爱丽丝肯德基阿斯达搜啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节"
    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_content");
    content:setVisible(false)
    local textSize = 36
    local params = {}
    params.text = self.m_data.content or "暂无信息"
    params.font = "res_TTF/1016001.TTF"
    params.size = textSize
    params.align =  cc.TEXT_ALIGNMENT_CENTER
    params.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    if IsPortrait then -- TODO
        params.color = cc.c3b(51,51,51)              --cc.c3b
    else
        params.color = cc.c3b(255,255,255)              --cc.c3b
    end
    local lenth = ToolKit.widthSingle(params.text)
    local tDynamicLabel = display.newTTFLabel(params)
    local tMaxLength = 30
    if IsPortrait then -- TODO
        tMaxLength = 15
    end
    if lenth < tMaxLength then
        tDynamicLabel:setDimensions(lenth*textSize,textSize+20)
    else
        local texLen = math.ceil(lenth/tMaxLength)
        tDynamicLabel:setDimensions(tMaxLength*textSize,(textSize+10)*texLen)
    end
    local contentSize = tDynamicLabel:getContentSize()
    tDynamicLabel:setPosition(content:getPosition())
    content:getParent():addChild(tDynamicLabel)
    self.content = tDynamicLabel
    Util.updateNickName(tDynamicLabel, params.text, textSize)
end

function CommonTips:DynamicNode()
    if not tolua.isnull(self.m_data.contentNode) then
        local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_content");
        content:setString("")
        self.m_data.contentNode:setPosition(content:getPosition())
        content:getParent():addChild(self.m_data.contentNode)
    else
        self:DynamicLabel()
    end
end

return CommonTips