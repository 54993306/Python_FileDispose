--
-- Author: Machine
-- Date: 2017-12-19
--
--PokerToast
local scheduler = require("app.framework.scheduler")

PokerToast = class("PokerToast")

function PokerToast:getInstance()
    if not PokerToast.s_instance or tolua.isnull(PokerToast.s_instance.m_pWidget) then
        PokerToast.s_instance = PokerToast.new()
    end

    return PokerToast.s_instance
end

function PokerToast:releaseInstance()
    if PokerToast.s_instance then
        if PokerToast.s_instance.m_pWidget and not tolua.isnull(PokerToast.s_instance.m_pWidget) then
            PokerToast.s_instance.m_pWidget:removeFromParent()
        end
        PokerToast.s_instance.m_pWidget = nil
        PokerToast.s_instance = nil
    end
end

function PokerToast:ctor()
    self.m_delay = 0
    self.m_pWidget = ccui.Layout:create()
    self.m_pWidget:setContentSize(cc.size(display.width, display.height))
    self.m_pWidget:setTouchEnabled(false)

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

    self.toastWaitTab = {}
    display.getRunningScene():addChild(self.m_pWidget, 255)
end

--显示内容为text的toast
function PokerToast:show(text)
    if self.toastWaitTab[text] ~= nil then return end
    local toast = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/guandan/toast.csb")
    toast:setTouchEnabled(false)

    local label = ccui.Helper:seekWidgetByName(toast, "txt")

    --内容
    local testHeight = ccui.Text:create()
    testHeight:setTextAreaSize(cc.size(900, 0))
    testHeight:setString(text or "提示")
    testHeight:setFontSize(30)
    testHeight:setFontName("hall/font/fangzhengcuyuan.TTF")
    local size = testHeight:getContentSize()

    label:setString(text or "提示")
    label:setFontName("hall/font/fangzhengcuyuan.TTF")

    local size = toast:getContentSize()
    toast:setPosition(cc.p((display.width - size.width)/2, 0.4*display.height))
    self.m_pWidget:addChild(toast)
    toast:setVisible(false)    
    self.toastWaitTab[text] = 1
    transition.execute(toast, 
        cc.Sequence:create(
            cc.CallFunc:create(function()
                self.toastWaitTab[text] = nil
                toast:setVisible(true)
            end)
            , cc.MoveBy:create(1.7, cc.p(0, 0.3*display.height))
        ),
        {
        onComplete = function()
            toast:removeFromParent()
        end,
        delay = self.m_delay
    })
    self.m_delay = self.m_delay + 0.6
end