-------------------------------------------------------------
--  @file   ActivityDialog.lua
--  @brief  战绩类定义
--  @author Zhu Can Qin
--  @DateTime:2016-09-22 12:05:19
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local ActivityDialog = class("ActivityDialog", UIWndBase)
local kWidgets = {
    tagTitle    = "lab_title",
    tagBg       = "result_bg",
    tagTop      = "Image_64",
}
local btnTopMargin = 25
local btnPadding = 80
local btnToLeft = 40

if not IsPortrait then
	kWidgets = {
	    tagPanel        = "Panel_105",
	    tagCloseBtn     = "close_btn",
	    tagTitle        = "Label_title",
	    tagBg           = "result_bg",
	    tagTop          = "bg_top_line",
	}
	local btnTopMargin = 12
	local btnPadding = 100
	local btnToLeft = 50

end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ActivityDialog:ctor(...)
    self.super.ctor(self, "hall/record_dialog.csb", ...)
    -- self.baseShowType = UIWndBase.BaseShowType.RTOL
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function ActivityDialog:onShow()
    Log.i("ActivityDialog:onShow")
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function ActivityDialog:onClose()
    Log.i("ActivityDialog:onClose")
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser)
        self.m_socketProcesser = nil
    end
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function ActivityDialog:onInit()

	if IsPortrait then
	    Util.printAllChildren(self.m_pWidget)

	    self.Label_title = self.m_pWidget:getChildByName(kWidgets.tagTitle)
	    if self.Label_title then
	        self.Label_title:setString(self.m_data.title or "活动")
	    end
	    self.result_bg = self.m_pWidget:getChildByName(kWidgets.tagBg)
	    self.bg_top_line = self.m_pWidget:getChildByName(kWidgets.tagTop)

	    for i, v in ipairs(self.m_pWidget:getChildren()) do
	        if v ~= self.result_bg and v ~= self.bg_top_line and self.Label_title and v ~= self.Label_title then
	            v:removeFromParent()
	        end
	    end

	    local bgSize = self.result_bg:getContentSize()
	else
	    local Panel_105 = self.m_pWidget:getChildByName(kWidgets.tagPanel)

	    self.Label_title = Panel_105:getChildByName(kWidgets.tagTitle)
	    self.Label_title:setString(self.m_data.title or "活动")

	    self.result_bg = Panel_105:getChildByName(kWidgets.tagBg)
	    self.bg_top_line = Panel_105:getChildByName(kWidgets.tagTop)
	    -- self.noRecordTip:setVisible(false)

	    self.button_close = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
	    self.button_close:addTouchEventListener(handler(self, self.onClickButton));
	    local btnCloseMargin = self.button_close:getLayoutParameter():getMargin()

	    for i, v in ipairs(Panel_105:getChildren()) do
	        if v ~= self.result_bg and v ~= self.bg_top_line and v ~= self.Label_title then
	            v:removeFromParent()
	        end
	    end

	    
	    local margin = self.bg_top_line:getLayoutParameter():getMargin()
    end
    local bgSize = self.result_bg:getContentSize()
    bgSize.height = bgSize.height - self.bg_top_line:getContentSize().height

    if device.platform == "android" or device.platform == "ios" then
        if ccexp and ccexp.WebView then
            self:initWebView(bgSize)
        else
            self:openURLDirectly()
        end
    else
        local layout = ccui.Layout:create()
        layout:addTo(self.result_bg)
        layout:setContentSize(bgSize)

        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        layout:setBackGroundColor(cc.c3b(127, 127, 127))

        self:createBtns()

        local data = {}
        data.cmd = NativeCall.CMD_OPEN_URL
        data.url = self.m_data.url
        NativeCall.getInstance():callNative(data, self.m_data.callback, self.m_data.obj)

        self:jumpCallback()
    end

    Util.printAllChildren(self.m_pWidget)
end

function ActivityDialog:openURLDirectly()
    local data = {}
    data.cmd = NativeCall.CMD_OPEN_URL
    data.url = self.m_data.url
    NativeCall.getInstance():callNative(data, self.m_data.callback, self.m_data.obj)
end

function ActivityDialog:initWebView(bgSize)
    local webview = ccexp.WebView:create()
    webview:setAnchorPoint(cc.p(0, 0))
    webview:addTo(self.result_bg)

    webview:setContentSize(bgSize)
    -- webview:setScalesPageToFit(true)
    webview:loadURL(self.m_data.url)

    self:createBtns(webview)
    self:addWebInterface()
end

function ActivityDialog:addWebInterface()
    local data = {}
    data.cmd = NativeCall.CDM_JS_WEB_INTERFACE
    data.url = self.m_data.url
    Log.i("data........",data)
    NativeCall.getInstance():addWebInterface(data,function(arg) self:jumpCallback(arg) end)

    if device.platform == "ios" then
        local customEventDispatch=cc.Director:getInstance():getEventDispatcher()
        local function MsgRecvCallBack(event)
            -- printf("Test Custom Event"..event)
            -- printf("event name.."..event:_myName)
            local arg = event:getDataString()
            printf("arg........"..arg)
            self:jumpCallback(arg)
        end

        local listenerMsgRecv=cc.EventListenerCustom:create("WebViewCB_Event",MsgRecvCallBack)
        
        customEventDispatch:addEventListenerWithFixedPriority(listenerMsgRecv, 1)
    end
end
--跳转回调
function ActivityDialog:jumpCallback(arg)
	print("活动返回了",arg)
	local atgTable = json.decode(arg)
    --local argArr = string.split(arg,"&")
    Log.i("js返回值....",atgTable)
    -- if ret then
    self.m_data.parent:shareActivity(atgTable)
    UIManager:getInstance():popWnd(ActivityDialog)

   
    -- end
end

function ActivityDialog:createOneButton(img, callback, margin, alignType)
    btn = ccui.Button:create(img or "hall/huanpi2/Common/x.png")
    btn:addTo(self.m_pWidget)
    btn:getLayoutParameter():setAlign(alignType or ccui.RelativeAlign.alignParentTopLeft)
    btn:getLayoutParameter():setMargin(margin)
    btn:addTouchEventListener(function(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended and callback then
            callback(pWidget, EventType)
        end
    end)
    return btn
end

function ActivityDialog:createBtns(webview)
    --[[
    local function backCallback()
        Log.i("self.btn_back")
        if webview then
            webview:goBack()
        end
    end
    if IsPortrait then
    	self.btn_back = self:createOneButton("hall/huanpi2/Common/btn_up.png", backCallback, {left = btnToLeft, top = btnTopMargin})
    	self.btn_back:setRotation(270)
    else
	self.btn_back = self:createOneButton("hall/huanpi2/Common/btn_back.png", backCallback, {left = btnToLeft, top = btnTopMargin})
    	-- self.btn_back:setScaleX(-0.8):setScaleY(0.8)
    end
    local function forwardCallback()
        Log.i("self.btn_forward")
        if webview then
            webview:goForward()
        end
    end
    if IsPortrait then
    	self.btn_forward = self:createOneButton("hall/huanpi2/Common/btn_up.png", forwardCallback, {left = btnToLeft + btnPadding, top = btnTopMargin})
    	self.btn_forward:setRotation(90)
    else
    	self.btn_forward = self:createOneButton("hall/huanpi2/Common/btn_back.png", forwardCallback, {left = btnToLeft + btnPadding, top = btnTopMargin})
    	self.btn_forward:setScaleX(-1)
    end
    local function refreshCallback()
        Log.i("self.btn_refresh")
        if webview then
            webview:reload()
        end
    end
    if IsPortrait then
    	self.btn_refresh = self:createOneButton("hall/huanpi2/main_portrait/icon_back.png", refreshCallback, {left = btnToLeft + btnPadding * 2, top = btnTopMargin - 20})
    	self.btn_refresh:setScaleX(-0.8):setScaleY(0.8)
    	self.btn_refresh:setRotation(90)

    else
    self.btn_refresh = self:createOneButton("hall/huanpi2/main/icon_back.png", refreshCallback, {left = btnToLeft + btnPadding * 2, top = btnTopMargin - 13})
    self.btn_refresh:setScaleX(-0.8):setScaleY(0.8)	
    end
    
    --]]
    if IsPortrait then
    	self.button_close = self:createOneButton("hall/huanpi2/Common/btn_x.png", handler(self, self.onClickButton), {right = -5, top = btnTopMargin - 30}, ccui.RelativeAlign.alignParentTopRight)
    	self.button_close:setScale(0.8)
	end	
end

--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function ActivityDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

function ActivityDialog:keyBack()
    self.m_data.parent:recvPHPActivityData()
    UIManager:getInstance():popWnd(ActivityDialog)
end

--endregion
return ActivityDialog