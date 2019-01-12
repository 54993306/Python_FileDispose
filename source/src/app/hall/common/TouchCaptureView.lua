--等待中提示

TouchCaptureView = class("TouchCaptureView");

TouchCaptureView.getInstance = function()
    if not TouchCaptureView.s_instance then
        TouchCaptureView.s_instance = TouchCaptureView.new();
    end

    return TouchCaptureView.s_instance;
end

TouchCaptureView.release = function()
    if TouchCaptureView.s_instance then
        if TouchCaptureView.s_instance.m_pWidget then
            TouchCaptureView.s_instance.m_pWidget:removeFromParent();
        end
        TouchCaptureView.s_instance = nil;
    end
end

TouchCaptureView.ctor = function(self)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    self.m_pWidget:setContentSize(cc.size(display.width, display.height));
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);

    self.m_norSwallow = false
    self.m_timeSwallow = false
    UIManager.getInstance():addToRoot(self.m_pWidget, 1010);
end 

--显示
TouchCaptureView.show = function(self)
    self.m_norSwallow = true
    self:refreshVisible()
end 

TouchCaptureView.hide = function(self)
    self.m_norSwallow = false
    self:refreshVisible()
end

TouchCaptureView.showWithTime = function(self, time)
    if time == nil then
        time = 0.3
    end
    
    self.m_pWidget:stopAllActions()    
    self.m_timeSwallow = true
    self.m_pWidget:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function() self.m_timeSwallow = false; self:refreshVisible() end)))
    self:refreshVisible()
end 

TouchCaptureView.refreshVisible = function(self)
    self.m_pWidget:setVisible(self.m_norSwallow or self.m_timeSwallow);
end