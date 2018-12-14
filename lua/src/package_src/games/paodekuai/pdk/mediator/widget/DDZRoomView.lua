local DDZRoomView = class("DDZRoomView");

function DDZRoomView:ctor( widget, data)
    self.m_pWidget = widget;
    self.m_data = data;
    self.listeners = {};
    
    self:initView();
    return self;
end

function DDZRoomView:initView()
end

--------------------------------------------------------
-- @desc 获取子控件时赋予特殊属性(支持Label,TextField)
--------------------------------------------------------
function DDZRoomView:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
    if(widget == nil) then 
        return; 
    end
    local m_type = widget:getDescription();
    if m_type == "Label" then
        if args then
            if args.shadow == true then
                widget:enableShadow();
            elseif args.bold == true then
                widget:setFontName("hall/font/bold.ttf");
            end
        end
    end
    return widget;
end

--------------------------------------------------------
-- @desc 显示控件
--------------------------------------------------------
function DDZRoomView:show()
    self.m_pWidget:setVisible(true);
end

--------------------------------------------------------
-- @desc 隐藏控件
--------------------------------------------------------
function DDZRoomView:hide()
    self.m_pWidget:setVisible(false);
end

--------------------------------------------------------
-- @desc 析构函数 默认移除监听事件
--------------------------------------------------------
function DDZRoomView:dtor()
    for k,v in pairs(self.listeners) do
        Log.i("-----------------------------------remove event", v)
        HallAPI.EventAPI:removeEvent(v)
    end
end

return DDZRoomView