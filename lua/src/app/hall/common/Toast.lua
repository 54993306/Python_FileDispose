--Toast
local scheduler = require("app.framework.scheduler")

Toast = class("Toast");

Toast.getInstance = function()
    if not Toast.s_instance or tolua.isnull(Toast.s_instance.m_pWidget) then
        Toast.s_instance = Toast.new();
    end

    return Toast.s_instance;
end

Toast.releaseInstance = function()
    if Toast.s_instance then
        if Toast.s_instance.m_pWidget and not tolua.isnull(Toast.s_instance.m_pWidget) then
            Toast.s_instance.m_pWidget:removeFromParent();
        end
        Toast.s_instance.m_pWidget = nil
        Toast.s_instance = nil;
    end
end

Toast.ctor = function(self)
    self.m_delay = 0
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    self.m_pWidget:setTouchEnabled(false);


    local function timeDown(dt)
        self.m_delay = self.m_delay - dt
        if self.m_delay < 0 then
            self.m_delay = 0
        end
    end

    local function onNodeEvent(event)
        if event.name == "enter" then  
            self.m_pWidget.schedulerEntry = scheduler.scheduleUpdateGlobal(timeDown) 
        elseif event.name == "exit" then  
            if self.m_pWidget.schedulerEntry ~= nil then  
                scheduler.unscheduleGlobal(self.m_pWidget.schedulerEntry)  
            end
            self.m_pWidget.schedulerEntry = nil
        end  
    end  
    -- 注册响应事件  
    self.m_pWidget:setNodeEventEnabled(true, onNodeEvent)  

    self.toastWaitTab = {};
    UIManager.getInstance():addToRoot(self.m_pWidget, WND_ZORDER_TOAST);
end

--显示内容为text的toast
Toast.show = function(self, text, showTime)
    -- print( debug.traceback())
    if self.toastWaitTab[text] ~= nil then return end
    local toast = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/toast.csb");
    toast:setTouchEnabled(false);
    --
    local label = ccui.Helper:seekWidgetByName(toast, "txt");
    local bg = ccui.Helper:seekWidgetByName(toast, "toast");

    --内容
    local testHeight = ccui.Text:create();
    testHeight:setTextAreaSize(cc.size(480, 0));
    testHeight:setString(text or "提示");
    testHeight:setFontSize(30);
    testHeight:setFontName("hall/font/fangzhengcuyuan.TTF");
    local size = testHeight:getContentSize();

    label:setString(text or "提示");
    label:setFontName("hall/font/fangzhengcuyuan.TTF");

    if not IsPortrait then -- TODO
        local len,textWidth = ToolKit.widthSingle(text)
        if textWidth > 23 then
            local height = 30*(math.ceil(textWidth/23)) + 10
            label:setTextAreaSize(cc.size(530, height));
            label:setPositionY(label:getPositionY()+20)
        end
        Log.i("width....",textWidth,len)
    end
    local size = toast:getContentSize();
    toast:setPosition(cc.p((display.width - size.width)/2, 0.4*display.height));
    --self.m_pWidget:removeAllChildren();
    self.m_pWidget:addChild(toast);
    toast:setVisible(false)    
    self.toastWaitTab[text] = 1

    showTime = showTime or 1.7
    transition.execute(toast, 
        cc.Sequence:create(
            cc.CallFunc:create(function() self.toastWaitTab[text] = nil; toast:setVisible(true) end)
            , cc.MoveBy:create(showTime, cc.p(0, 0.3*display.height))
        ),
        {
        onComplete = function()
            --self.m_pWidget:removeAllChildren();
            toast:removeFromParent()
        end,
        delay = self.m_delay
    });
    self.m_delay = self.m_delay + 0.6
end

--显示内容为text的toast
Toast.showReminder = function(self, text)
    -- print( debug.traceback())
    if self.toastWaitTab[text] ~= nil then return end
    local toast = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/toast.csb");
    toast:setTouchEnabled(false);
    --
    local label = ccui.Helper:seekWidgetByName(toast, "txt");
    local bg = ccui.Helper:seekWidgetByName(toast, "toast");

    --内容
    local testHeight = ccui.Text:create();
    testHeight:setTextAreaSize(cc.size(480, 0));
    testHeight:setString(text or "提示");
    testHeight:setFontSize(30);
    testHeight:setFontName("hall/font/fangzhengcuyuan.TTF");
    local size = testHeight:getContentSize();

    label:setString(text or "提示");
    label:setFontName("hall/font/fangzhengcuyuan.TTF");
    label:setFontSize(24)
    local size = toast:getContentSize();
    toast:setPosition(cc.p((display.width - size.width)/2, 0.4*display.height));
    --self.m_pWidget:removeAllChildren();
    self.m_pWidget:addChild(toast);
    toast:setVisible(false)    
    self.toastWaitTab[text] = 1
    transition.execute(toast, 
        cc.Sequence:create(
            cc.CallFunc:create(function() self.toastWaitTab[text] = nil; toast:setVisible(true) end)
            , cc.MoveBy:create(3, cc.p(0, 0.3*display.height))
        ),
        {
        onComplete = function()
            --self.m_pWidget:removeAllChildren();
            toast:removeFromParent()
        end,
        delay = self.m_delay
    });
    self.m_delay = self.m_delay + 1.6
end