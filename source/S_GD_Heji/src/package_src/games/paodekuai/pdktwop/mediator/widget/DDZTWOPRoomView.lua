-------------------------------------------------------------------------
-- Desc:   二人斗地主子Vewi父类
-- Author:   
-------------------------------------------------------------------------
local PokerConst = require("package_src.games.paodekuai.pdkcommon.data.PokerConst")
local DDZTWOPConst = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPConst")
local DDZTWOPRoomView = class("DDZTWOPRoomView")

---------------------------------------
-- 函数功能：   构造函数
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:ctor(delegate, widget, data)
    self.m_delegate = delegate
    self.m_pWidget = widget
    self.m_data = data
    self.listeners = {}
    self:initView()
    return self
end

---------------------------------------
-- 函数功能：   初始化UI数据  子类需要重写
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:initView()
end

---------------------------------------
-- 函数功能：   --获取子控件时赋予特殊属性(支持Label,TextField)
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:getWidget(parent, name, ...)
    local widget = nil
    local args = ...
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name)
    if(widget == nil) then 
        return 
    end
    local m_type = widget:getDescription()
    if m_type == "Label" then
        if args then
            if args.shadow == true then
                widget:enableShadow()
            elseif args.bold == true then
                widget:setFontName(PokerConst.FONT)
            end
        end
    end
    return widget
end

---------------------------------------
-- 函数功能：   展示UI 
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:show()
    self.m_pWidget:setVisible(true)
end

---------------------------------------
-- 函数功能：   隐藏UI
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:hide()
    self.m_pWidget:setVisible(false)
end

---------------------------------------
-- 函数功能：   析构
-- 返回值：     无
---------------------------------------
function DDZTWOPRoomView:dtor()
    for k,v in pairs(self.listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

return DDZTWOPRoomView