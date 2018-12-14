-----------------------------------------------------------
--  @file   RealName.lua
--  @brief  实名认证
--  @author linxiancheng
--  @DateTime:2017-09-07 10:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local RealName = class("RealName", UIWndBase)

function RealName:ctor(...)
    RealName.super.ctor(self, "hall/real_name.csb",...)
end

local function sendInfo(tab)
    local data = {}
    data.ty = 1
    data.na = tab.name
    data.IdC = tab.id
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_PLAYERCARDINFO, data)
    LoadingView.getInstance():show("信息发送中...")
end

local function judgeInfo(self,widget,touchType)
    if touchType == ccui.TouchEventType.ended then
        if IsPortrait then -- TODO
            SoundManager.playEffect("btn");
        end
        local name = self.input_name:getText()
        local id = self.input_id:getText()
        if name ==  "" then
            Toast.getInstance():show("姓名不能为空")
        elseif id == "" then
            Toast.getInstance():show("身份证不能为空")
        else
            sendInfo({name = name , id = id})
        end
    end
end

local function initInput(self)
    local pan_input = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_input")
    self.input_name = self:getWidget(pan_input, "input_name");

    self.input_id = self:getWidget(pan_input, "input_id")
    if self.input_id.setInputMode then 
        -- self.input_id:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) 
    end
end

local function initPanel(self)
    local keyBack = function(widget, touchType)
        if touchType == ccui.TouchEventType.ended then
            if IsPortrait then -- TODO
                SoundManager.playEffect("btn");
            end
            self.keyBack()  -- 父类构造的时候已经保存了子类的self指针
        end
    end

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close")
    btn_close:addTouchEventListener(keyBack)

    local btn_real = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_real")
    btn_real:addTouchEventListener(keyBack)
    btn_real:setTouchEnabled(false)

    local btn_send = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_send")
    btn_send:addTouchEventListener(handler(self,judgeInfo))

    initInput(self)
end

local function initRealPanel(self)
    local lab_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_name")
    if IsPortrait then -- TODO
        lab_name:setString( ToolKit.subUtfStrByCn(self.m_data.na, 0, 14, "...") )
    else
        lab_name:setString(self.m_data.na)
    end

    local lab_id = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_id")
    lab_id:setString(self.m_data.IdC)
end

local function setPanelState(self,isReal)
    local pan_input = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_input")
    local pan_real = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_real")
    if isReal then
        pan_input:setVisible(true)
        pan_real:setVisible(false)
    else
        pan_input:setVisible(false)
        pan_real:setVisible(true)
    end
end

function RealName:onInit()
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self,self.popSelf))
    end
    
    if not self.m_data.IdC or self.m_data.IdC == "" then
        setPanelState(self,true)
    else
        setPanelState(self,false)
    end

    initRealPanel(self)
    initPanel(self)
end

-- 处理发送身份信息返回
function RealName:disposeRec(data)
    self.m_data = data
    setPanelState(self,false)
    initRealPanel(self)
end

return RealName