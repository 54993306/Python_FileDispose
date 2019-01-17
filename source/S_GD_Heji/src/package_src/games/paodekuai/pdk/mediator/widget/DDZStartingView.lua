--
-- 速配开始倒计时
--

local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZStartingView = class("DDZStartingView", DDZRoomView);

function DDZStartingView:initView()
    self.lb_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "alb_time");
end

------------------------------------------------------------
-- @desc 显示倒计时
------------------------------------------------------------
function DDZStartingView:show()
    self.m_pWidget:setVisible(true);
    self.m_startingTime = self.m_data;
    self.lb_time:setString(self.m_startingTime);
    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateStartingTime), 1);
end

------------------------------------------------------------
-- @desc 更新开始时间
------------------------------------------------------------
function DDZStartingView:updateStartingTime()
    self.m_startingTime = self.m_startingTime - 1;
    if self.m_startingTime < 0 then
        self.m_startingTime = 20;
    end
    if self.m_startingTime < 10 then
        self.lb_time:setString("0" .. self.m_startingTime);
    else
        self.lb_time:setString(self.m_startingTime);
    end
    

    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateStartingTime), 1);
end

------------------------------------------------------------
-- @desc 隐藏倒计时
------------------------------------------------------------
function DDZStartingView:hide()
    self.m_pWidget:setVisible(false);
    if self.m_time_update then
        transition.removeAction(self.m_time_update);
        self.m_time_update = nil;
    end
end

------------------------------------------------------------
-- @desc 获取是否可见
------------------------------------------------------------
function DDZStartingView:getIsVisible()
    return self.m_pWidget:isVisible()
end

return DDZStartingView