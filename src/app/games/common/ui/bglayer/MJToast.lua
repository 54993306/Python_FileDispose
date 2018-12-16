--MJToast

MJToast = class("MJToast");

MJToast.getInstance = function()
    if not MJToast.s_instance or tolua.isnull(MJToast.s_instance.m_pWidget) then
        MJToast.s_instance = MJToast.new();
    end

    return MJToast.s_instance;
end

MJToast.releaseInstance = function()
    if MJToast.s_instance then
        if MJToast.s_instance.m_pWidget and not tolua.isnull(MJToast.s_instance.m_pWidget) then
            MJToast.s_instance.m_pWidget:removeFromParent();
        end
        MJToast.s_instance = nil;
    end
end

MJToast.ctor = function(self)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_toast.csb");
    self.m_pWidget:setTouchEnabled(false);
    UIManager.getInstance():addToRoot(self.m_pWidget, 1000);
    self.m_pWidget:setVisible(false);
end

--显示内容为text的MJToast
MJToast.show = function(self, text,fontSize)
    self.m_pWidget:setVisible(true);
    self.m_pWidget:stopAllActions();
    local label = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_content");
    label:setString(text or "提示");
    label:setFontName("hall/font/fangzhengcuyuan.TTF");
    if(fontSize~=nil) then  
	   label:setFontSize(fontSize);
	end
    self.m_pWidget:performWithDelay(function ()
        self.m_pWidget:setVisible(false);
    end, 1.2);
end