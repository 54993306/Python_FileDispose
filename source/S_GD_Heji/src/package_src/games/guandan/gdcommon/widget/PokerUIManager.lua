--窗口管理器

PokerUIManager = class("PokerUIManager");

PokerUIManager.getInstance = function()
    if not PokerUIManager.s_instance then
        PokerUIManager.s_instance = PokerUIManager.new();
    end

    return PokerUIManager.s_instance;
end

PokerUIManager.releaseInstance = function()
    if PokerUIManager.s_instance then
        PokerUIManager.s_instance:dtor();
    end
    PokerUIManager.s_instance = nil;
end

function PokerUIManager:ctor()
    self.m_scene = nil;    -- 场景
    self.m_wndsInRoot = {};    -- 在场景的所有窗口
    self.m_screen_orient = 1;
end

function PokerUIManager:dtor()
end

--场景
function PokerUIManager:setCurScene(scene)
    self.m_scene = scene;
end

--场景
function PokerUIManager:getCurScene()
    return self.m_scene;
end

--添加到场景显示
function PokerUIManager:addToRoot(widget, zOrder)
    display.getRunningScene():addChild(widget, zOrder);
end

--从场景删除
function PokerUIManager:removeToRoot(widget)
    display.getRunningScene():removeChild(widget, true);
    widget = nil;
end

--添加窗口到场景
function PokerUIManager:pushWnd(wndClass, ...)
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    m_wnd:show();
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:onShow();

    if #self.m_wndsInRoot > 1
        and self.m_wndsInRoot[#self.m_wndsInRoot-1].wnd
        and self.m_wndsInRoot[#self.m_wndsInRoot-1].wnd.onLostFocus then
        self.m_wndsInRoot[#self.m_wndsInRoot-1].wnd:onLostFocus() --PokerUIWndBase处理不是最高
    end
    return m_wnd;
end

--添加窗口到场景
function PokerUIManager:pushWndwithAnim(wndClass, AnimType, ...)
    Log.i("PokerUIManager:pushWnd", wndClass.__cname);
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:show(AnimType);
    m_wnd:onShow();
    return m_wnd;
end

--替换窗口到场景
function PokerUIManager:replaceWnd(wndClass, ...)
    Log.i("PokerUIManager:replaceWnd", wndClass.__cname);
    local m_wnd = wndClass.new(...);
    local wndData = {};
    wndData.key = wndClass.__cname;
    wndData.wnd = m_wnd;
    table.insert(self.m_wndsInRoot, wndData);
    m_wnd:show();
    for i = #self.m_wndsInRoot - 1, 1, -1 do
        wndData = table.remove(self.m_wndsInRoot, i);
        if wndData and wndData.wnd then
            wndData.wnd:close(true);
            wndData.wnd = nil;
        end
        wndData = nil; 
    end
    m_wnd:onShow();
    return m_wnd;
end

--从场景中移除目标窗口上所有的窗口
function PokerUIManager:popToWnd(wndClass, noAnim)
    Log.i("PokerUIManager:popToWnd", wndClass.__cname);
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        for i = 1 , #self.m_wndsInRoot do
            if self.m_wndsInRoot[i].key == wndClass.__cname then
                wndData = self.m_wndsInRoot[i];
                break;
            end
        end
        if wndData then
            while true do
                if self.m_wndsInRoot[#self.m_wndsInRoot].key ~= wndClass.__cname then
                    self:popWnd(nil, noAnim);
                else
                    break;
                end
            end
        end
    end
end

function PokerUIManager:popAllWnd(noAnim)
    Log.i("PokerUIManager:popAllWnd");
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        for i = 1 , #self.m_wndsInRoot do
            self:popWnd(nil, noAnim);
        end
    end
end

--如果存在指定窗口，返回指定窗口
function PokerUIManager:getWnd(wndClass)
    Log.i("从场景中查找目标窗口", "------wndClass = "..wndClass.__cname);
    if #self.m_wndsInRoot > 0 then
        for i = 1 , #self.m_wndsInRoot do
            if self.m_wndsInRoot[i].key == wndClass.__cname then
                return self.m_wndsInRoot[i].wnd;
            end
        end
    end
	return nil
end


function PokerUIManager:recoverToDesignOrient()
    local glview = cc.Director:getInstance():getOpenGLView()
    local size = glview:getFrameSize();
    if size.width < size.height then
        self.m_screen_orient = 2
    end         
    if Util.isBezelLess() then
        self:changeToPortrait("FIXED_WIDTH")
    else
        self:changeToPortrait("FIXED_HEIGHT")
    end
end

--切换到横屏
function PokerUIManager:changeToLandscape(autoScale)
    Log.i("PokerUIManager:changeToLandscape.....")
    if autoScale == nil then autoScale = "FIXED_WIDTH" end
    local glview = cc.Director:getInstance():getOpenGLView()
    local size = glview:getFrameSize();
    if self.m_screen_orient == 1 
        and autoScale == CONFIG_SCREEN_AUTOSCALE
        and  size.width > size.height then
        return;
    end
    -- design resolution
    CONFIG_SCREEN_WIDTH  = 1280;
    CONFIG_SCREEN_HEIGHT = 720;
    -- auto scale mode
    CONFIG_SCREEN_AUTOSCALE = autoScale;

    if device.platform == "android" or device.platform == "ios" and self.m_screen_orient ~= 1 then
        local data = {};
        data.cmd = NativeCall.CMD_CHANGE_ORIENTAION;
        data.orient = 1;
        NativeCall.getInstance():callNative(data);
    end

    self.m_screen_orient = 1;
    self:refreshScreenConfig(self.m_screen_orient)
end

--返回最上层窗口
function PokerUIManager:getSecondTopWnd()
    Log.i("------getTopWnd #self.m_wndsInRoot", #self.m_wndsInRoot);
    if #self.m_wndsInRoot > 0 then
        Log.i("------getTopWnd #self.m_wndsInRoot", self.m_wndsInRoot[#self.m_wndsInRoot - 1].key);
        return self.m_wndsInRoot[#self.m_wndsInRoot - 1].wnd;    
    end
end

--返回最上层窗口
function PokerUIManager:getTopWnd()
    if #self.m_wndsInRoot > 0 then
        return self.m_wndsInRoot[#self.m_wndsInRoot].wnd;    
    end
end

--从场景中移除窗口
function PokerUIManager:popWnd(wndClass, noAnim)
    Log.i("PokerUIManager:popWnd", wndClass and wndClass.__cname);
    if #self.m_wndsInRoot > 0 then
        local wndData = nil;
        if wndClass then
            for i = #self.m_wndsInRoot, 1, -1 do
                Log.i("PokerUIManager:popWnd self.m_wndsInRoot[i].key ", self.m_wndsInRoot[i].key)
                if self.m_wndsInRoot[i].key == wndClass.__cname then
                    wndData = table.remove(self.m_wndsInRoot, i);
                    break;
                end
            end
        else
            wndData = table.remove(self.m_wndsInRoot);
        end
        if wndData and wndData.wnd then
            Log.i("wndData key", wndData.key)
            wndData.wnd:close(noAnim);
            wndData.wnd = nil;
        end
        if self.m_wndsInRoot[#self.m_wndsInRoot] and self.m_wndsInRoot[#self.m_wndsInRoot].wnd then
            self.m_wndsInRoot[#self.m_wndsInRoot].wnd:onResume()
            if self.m_wndsInRoot[#self.m_wndsInRoot].wnd.onGetFocus then
                self.m_wndsInRoot[#self.m_wndsInRoot].wnd:onGetFocus(); --PokerUIWndBase处理回到最高
            end
        end
    end
end

--安卓返回键分发
function PokerUIManager:disPatchKeyBackEvent()
    if #self.m_wndsInRoot > 0 then
        self.m_wndsInRoot[#self.m_wndsInRoot].wnd:onKeyBack();
    end
end

--网络获取图片返回
function PokerUIManager:onResponseNetImg(url)
    printLog("onResponseNetImg", "---------url = "..url);
    if #self.m_wndsInRoot > 0 then
        for i = 1 , #self.m_wndsInRoot do
            local wndData = self.m_wndsInRoot[i];
            if wndData and wndData.wnd then
                wndData.wnd:onResponseNetImg(url);
            end
        end
    end
end

--网络获取回放数据返回
function PokerUIManager:onResponseNetJson(url)
    printLog("onResponseNetJson", "---------url = "..url);
    if #self.m_wndsInRoot > 0 then
        -- 找到当前界面
        local wndData = self.m_wndsInRoot[#self.m_wndsInRoot]
        if wndData and wndData.wnd then
            wndData.wnd:onResponseNetJson(url)
        end
    end
end