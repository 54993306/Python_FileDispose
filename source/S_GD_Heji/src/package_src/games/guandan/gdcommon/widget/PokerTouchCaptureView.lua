--等待中提示
PokerTouchCaptureView = class("PokerTouchCaptureView")

PokerTouchCaptureView.getInstance = function()
    if not PokerTouchCaptureView.s_instance then
        PokerTouchCaptureView.s_instance = PokerTouchCaptureView.new()
    end

    return PokerTouchCaptureView.s_instance
end

PokerTouchCaptureView.release = function()
    if PokerTouchCaptureView.s_instance then
        if PokerTouchCaptureView.s_instance.m_pWidget then
            PokerTouchCaptureView.s_instance.m_pWidget:stopAllActions()
            PokerTouchCaptureView.s_instance.m_pWidget:removeFromParent()
            PokerTouchCaptureView.s_instance.m_pWidget = nil
        end
        PokerTouchCaptureView.s_instance = nil
    end
end

PokerTouchCaptureView.ctor = function(self)
    self.m_pWidget = ccui.Layout:create()
    self.m_pWidget:setContentSize(cc.size(display.width, display.height))
    self.m_pWidget:setTouchEnabled(true)
    self.m_pWidget:setTouchSwallowEnabled(true)

    self.m_norSwallow = false
    self.m_timeSwallow = false
    PokerUIManager.getInstance():addToRoot(self.m_pWidget, 1010)
end 

--显示
PokerTouchCaptureView.show = function(self)
    self.m_norSwallow = true
    self:refreshVisible()
end 

PokerTouchCaptureView.hide = function(self)
    self.m_norSwallow = false
    self:refreshVisible()
end

PokerTouchCaptureView.showWithTime = function(self, time)
    if time == nil then
        time = 0.3
    end
    
    self.m_pWidget:stopAllActions()
    self.m_timeSwallow = true
    self.m_pWidget:runAction(cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(function()
            self.m_timeSwallow = false
            self:refreshVisible()
        end)))
    self:refreshVisible()
end

PokerTouchCaptureView.refreshVisible = function(self)
    if tolua.isnull(self.m_pWidget) then
        Log.i("--wangzhi--PokerTouchCaptureView--",debug.traceback())
        Log.i("--wangzhi--PokerTouchCaptureView.refreshVisible--error")
        return
    end
    self.m_pWidget:setVisible(self.m_norSwallow or self.m_timeSwallow)
end