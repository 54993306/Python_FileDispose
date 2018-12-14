--等待中提示

LoadingView = class("LoadingView");

LoadingView.getInstance = function()
    if not LoadingView.s_instance or tolua.isnull(LoadingView.s_instance.m_pWidget) then
        LoadingView.s_instance = LoadingView.new();
    end

    return LoadingView.s_instance;
end

LoadingView.releaseInstance = function()
    if LoadingView.s_instance then
        LoadingView.s_instance:dtor()
        LoadingView.s_instance = nil;
    end
end

LoadingView.ctor = function(self)
    self.m_keyMap = {}
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    self.m_pWidget:setContentSize(cc.size(display.width, display.height));
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setSwallowTouches(true);
    UIManager.getInstance():addToRoot(self.m_pWidget, WND_ZORDER_LOADINGVIEW);

    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));

    self.m_disableSwallowMap = {}
end

LoadingView.dtor = function(self)
    if self.m_pWidget and not tolua.isnull(self.m_pWidget) then
        self.m_pWidget:removeFromParent();
    end
    self.m_pWidget = nil
    self.m_keyMap = {}

    self.m_disableSwallowMap = {}
end

function LoadingView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if self.isTouchable then
            self:hide();
        end
    end
end

--显示内容为text的LoadingView
LoadingView.show = function(self, text, time, touchable, key, offX, offY, disableSwallow)
    if key == nil then key = "common" end
    if self.m_keyMap[key] ~= nil then
        loadingView = self.m_keyMap[key]
    else
        loadingView = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/loading.csb");
        self.m_pWidget:addChild(loadingView);
        self.m_keyMap[key] = loadingView
    end

    self.isTouchable = touchable;
    time = time or 10;
    self.m_pWidget:setVisible(true);

    self.m_disableSwallowMap[key] = disableSwallow
    if not disableSwallow then
        self.m_pWidget:setSwallowTouches(true)
    end

    local widgetSize = cc.size(display.width, display.height)
    self.m_pWidget:setContentSize(widgetSize);
    local size = loadingView:getContentSize();
    offX = offX or 0
    offY = offY or 0
    loadingView:setPosition(cc.p((display.width - size.width)/2 + offX, 0.5*display.height  + offY));

    transition.stopTarget(loadingView);
    local img_load = ccui.Helper:seekWidgetByName(loadingView, "img_load");
    local txt_load = ccui.Helper:seekWidgetByName(loadingView, "txt_load");
    --
    transition.stopTarget(img_load);
    img_load:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)));
    txt_load:setFontName("hall/font/fangzhengcuyuan.TTF");
    txt_load:setString(text or "正在加载中，请稍后...");
    if time and time > 0 then
        loadingView:stopAllActions()
        loadingView:runAction(cc.Sequence:create(cc.DelayTime:create(time)
            , cc.CallFunc:create(function() self:hide(key) end)))
    end
    loadingView:setVisible(true)
end

LoadingView.hide = function(self, key)
    if key == nil then key = "common" end
    local loadingView = self.m_keyMap[key]
    if loadingView ~= nil then
        loadingView:stopAllActions()
        loadingView:setVisible(false)
    end
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setSwallowTouches(false)
    for k,v in pairs(self.m_keyMap) do
        if v:isVisible() then
            self.m_pWidget:setVisible(true)

            if not self.m_disableSwallowMap[k] then
                self.m_pWidget:setSwallowTouches(true)
                return
            end
        end
    end
end

LoadingView.getVisible = function(self)
    return self.m_pWidget:isVisible();
end