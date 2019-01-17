-------------------------------------------------------------------------
-- Desc:   二人斗地主开始游戏速配倒计时UI
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPRoomView")
local PokerConst = require("package_src.games.paodekuai.pdkcommon.data.PokerConst")
local DDZTWOPConst = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPConst")
local DDZTWOPStartingView = class("DDZTWOPStartingView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPStartingView:initView()
    self.lb_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "alb_time")
    ccui.Helper:seekWidgetByName(self.m_pWidget,"tips"):setFontName(PokerConst.FONT)
    --倒计时时间
    self.m_startingTime = 20
end

---------------------------------------
-- 函数功能：   显示UI
-- 返回值：     无
---------------------------------------
function DDZTWOPStartingView:show()
    self.m_pWidget:setVisible(true)
    self.lb_time:setString(self.m_startingTime)
    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateStartingTime), 1)
end

---------------------------------------
-- 函数功能：   更新速配时间
-- 返回值：     无
---------------------------------------
function DDZTWOPStartingView:updateStartingTime()
    self.m_startingTime = self.m_startingTime - 1
    if self.m_startingTime < 0 then
        self.m_startingTime = 20
    end
    if self.m_startingTime < 10 then
        self.lb_time:setString("0" .. self.m_startingTime)
    else
        self.lb_time:setString(self.m_startingTime)
    end
    

    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateStartingTime), 1)
end

---------------------------------------
-- 函数功能：   隐藏速配时间
-- 返回值：     无
---------------------------------------
function DDZTWOPStartingView:hide()
    self.m_pWidget:setVisible(false)
    if self.m_time_update then
        transition.removeAction(self.m_time_update)
        self.m_time_update = nil
    end
end

return DDZTWOPStartingView