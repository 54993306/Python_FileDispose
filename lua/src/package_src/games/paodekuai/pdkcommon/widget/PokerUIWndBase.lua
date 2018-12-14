--窗口基类
local PokerConst = require("package_src.games.paodekuai.pdkcommon.data.PokerConst")
PokerUIWndBase = class("PokerUIWndBase")

PokerUIWndBase.LayoutTypeX = {
    LEFT       = 1,
    CENTER     = 2,
    RIGHT      = 3
}
PokerUIWndBase.LayoutTypeY = {
    BOTTOM     = 1,
    CENTER     = 2,
    TOP        = 3
} 
PokerUIWndBase.BaseShowType = {
    COMMON = 1,
    RTOL = 2,
    TTPB = 3
}
-- 构造函数
function PokerUIWndBase:ctor(uiConfig, data, zOrder, delegate)
	self.m_uiConfig = uiConfig 	or "";			-- UI配置文件
	self.m_data = data or {};					-- 数据
    self.zOrder = zOrder or 0;                  -- 窗口层级
    self.m_delegate = delegate;                 -- 代理
	self.netImgsTable = {};                     -- 网络加载图片
    self.layoutData = {}          -- 布局参数 {PokerUIWndBase.LayoutTypeX, PokerUIWndBase.LayoutTypeY}
    self.baseShowType = self.baseShowType or PokerUIWndBase.BaseShowType.COMMON --show()的显示效果。
end

function PokerUIWndBase:setDelegate(delegate)
    self.m_delegate = delegate;
end

function PokerUIWndBase:getWidget()
    return self.m_pWidget;
end

-- 响应窗口资源初始化 在执行load后会执行
function PokerUIWndBase:onInit()end

-- 窗口隐藏
function PokerUIWndBase:setVisible(visible)
	if self.m_pWidget then
		self.m_pWidget:setVisible(visible);
	end
end

-- 响应窗口显示
function PokerUIWndBase:onShow()
end

-- 响应窗口回到最上层
function PokerUIWndBase:onResume()
end

-- 窗口被关闭响应
function PokerUIWndBase:onClose()
end

function PokerUIWndBase:onLostFocus()
    if not tolua.isnull(self.m_pBaseNode) then
        self.m_pBaseNode:setBackGroundColorOpacity(0)
    end
end

function PokerUIWndBase:onGetFocus()
    if not tolua.isnull(self.m_pBaseNode) then
        self.m_pBaseNode:setBackGroundColorOpacity(160)
    end
end

--返回网络图片
function PokerUIWndBase:onResponseNetImg(fileName)
    if fileName == nil then
        return;
    end
    local imgViews = self.netImgsTable[fileName];
    if imgViews then
    	for k, v in ipairs(imgViews) do
    		if v then
    			v:loadTexture(fileName);
    		end
    	end

    end
end

-- 加载UI资源
function PokerUIWndBase:loadUIConfig()
	if self.m_pWidget ~= nil then
		return
	end
    Log.i("self.m_uiConfig: ", self.m_uiConfig)
    -- 加载ui配置文件
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.m_uiConfig);
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
	if self.m_pWidget == nil then
		printError("加载"..self.m_uiConfig.."文件失败");
		return;
	end


    -- 处理显示位置
    if self.layoutData[1] == PokerUIWndBase.LayoutTypeX.LEFT then
        self.m_pWidget:setPositionX(0)
    elseif self.layoutData[1] == PokerUIWndBase.LayoutTypeX.CENTER then
        self.m_pWidget:setPositionX(display.size.width / 2 - self.m_pWidget:getContentSize().width/2)
    elseif self.layoutData[1] == PokerUIWndBase.LayoutTypeX.RIGHT then
        self.m_pWidget:setPositionX(display.size.width - self.m_pWidget:getContentSize().width)
    end

    if self.layoutData[2] == PokerUIWndBase.LayoutTypeY.BOTTOM then
        self.m_pWidget:setPositionY(0)
    elseif self.layoutData[2] == PokerUIWndBase.LayoutTypeY.CENTER then
        self.m_pWidget:setPositionY(display.size.height / 2 - self.m_pWidget:getContentSize().height/2)
    elseif self.layoutData[2] == PokerUIWndBase.LayoutTypeY.TOP then
        self.m_pWidget:setPositionY(display.size.height - self.m_pWidget:getContentSize().height)
    end
end

function PokerUIWndBase:createBaseNode()
    if self.m_pBaseNode == nil then
        self.m_pBaseNode = ccui.Layout:create()
        self.m_pBaseNode:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self.m_pBaseNode:setBackGroundColor(cc.c3b(0,0,0))
        self.m_pBaseNode:setBackGroundColorOpacity(160)
        self.m_pBaseNode:setContentSize(display.size)
    end
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function PokerUIWndBase:getWidget(parent, name, ...)
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
                widget:setFontName(PokerConst.FONT);
            elseif args.shadow_bold == true then
                --新的美術字體效果 cc.c3b(255, 0, 0)  cc.size(2,-2)
                widget:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,-1));
                widget:setFontName("hall/font/fangzhengcuyuan.TTF");
            end
        end
    elseif m_type == "TextField" then             --安卓的时候有bug
        return self:setTextFieldToEditBox(widget);
    end
    return widget;
end

function PokerUIWndBase:addWidgetClickFunc(widget, callfunc)
    if widget ~= nil and callfunc ~= nil then
        widget:addTouchEventListener(function(pWidget, EventType)
            if EventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end);
    end
end

function PokerUIWndBase:setTextFieldToEditBox(textfield)

    local tfS = textfield:getContentSize()
    local parent = textfield:getParent()
    local tfPosX = textfield:getPositionX()
    local tfPosY = textfield:getPositionY()
    local tfPH = textfield:getPlaceHolder()
    local anchor = textfield:getAnchorPoint()
    local zorder = textfield:getLocalZOrder()
    local tfColor = textfield:getColor()
    local ispe = textfield:isPasswordEnabled()
    local tfFS = textfield:getFontSize()
    local ftMaxLength = 0
    if textfield:isMaxLengthEnabled() then
        ftMaxLength = textfield:getMaxLength()
    end
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            Log.i("began。。。。。。。")
        elseif event == "changed" then
            Log.i("changed。。。。。。。")
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            Log.i("ended。。。。。。。")
        elseif event == "return" then
            -- 从输入框返回
            Log.i("从输入框返回")
        end
    end
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "hall/Common/blank.png",
        listener = onEdit,
        size = tfS
    })
--    local imageNormal = display.newScale9Sprite("hall/Common/blank.png")

--    local editbox = ccui.EditBox:create(cc.size(tfS.width,tfS.height), imageNormal)
    editbox:setContentSize(tfS)
    editbox:setName(tfName)
    editbox:setPosition(cc.p(tfPosX,tfPosY))
    editbox:setPlaceHolder(tfPH)
    editbox:setFontName("hall/font/bold.ttf")
    editbox:setPlaceholderFontColor(cc.c3b(128,128,128))
    editbox:setAnchorPoint(cc.p(anchor.x,anchor.y))
    editbox:setLocalZOrder(zorder)
    editbox:setFontColor(tfColor)
    editbox:setFontSize(tfFS)

    if ftMaxLength ~= 0 then
        editbox:setMaxLength(ftMaxLength)
    end
    if ispe then
        editbox:setInputFlag(0)
    end
    parent:removeChild(textfield,true)
    parent:addChild(editbox)

    return editbox
end
-- 显示窗口
function PokerUIWndBase:show(AnimType)
	-- 如果没有加载过，进行加载
    self:loadUIConfig();
    self:createBaseNode();
    
    self.m_pBaseNode:addChild(self.m_pWidget)
    self.m_baseShowPos = cc.p(self.m_pWidget:getPosition())
    --Log.i("PokerUIWndBase:show ", self.zOrder, self.__cname)
    PokerUIManager:getInstance():addToRoot(self.m_pBaseNode, self.zOrder);
	-- 执行初始化
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setTouchEnabled(false);
    PokerTouchCaptureView.getInstance():show();
	self:onInit();


    -- if AnimType == TRAN_RIGHT_TO_LEFT then
    --     self.m_AnimType = TRAN_RIGHT_TO_LEFT;
    --     transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
    --         onComplete = function()
    --             self.m_pWidget:setVisible(true);
    --             local topWnd = PokerUIManager.getInstance():getSecondTopWnd();
    --             topWnd.m_pWidget:setTouchEnabled(false);
    --             topWnd.m_pWidget:moveBy(0.2, -display.width, 0);
    --             transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
    --                 onComplete = function()
    --                     PokerTouchCaptureView.getInstance():hide();
    --                     self.m_pWidget:setTouchEnabled(true);
    --                     local topWnd = PokerUIManager.getInstance():getSecondTopWnd();
    --                     topWnd.m_pWidget:setTouchEnabled(true);
    --                 end
    --                 });
    --         end
    --         });
    -- elseif AnimType == PUSH_BOTTOM_TO_TOP then
    --     self.m_AnimType = PUSH_BOTTOM_TO_TOP;
    --     transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
    --         onComplete = function()
    --             self.m_pWidget:setVisible(true);
    --             local topWnd = PokerUIManager.getInstance():getSecondTopWnd();
    --             topWnd.m_pWidget:setTouchEnabled(false);
    --             transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
    --                 onComplete = function()
    --                     PokerTouchCaptureView.getInstance():hide();
    --                     self.m_pWidget:setTouchEnabled(true);
    --                     local topWnd = PokerUIManager.getInstance():getSecondTopWnd();
    --                     topWnd.m_pWidget:setTouchEnabled(true);
    --                 end
    --                 });
    --         end
    --         });
    -- else
        if self.baseShowType == PokerUIWndBase.BaseShowType.RTOL then
            transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
                onComplete = function()
                    self.m_pWidget:setVisible(true);
                    transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
                        onComplete = function()
                            PokerTouchCaptureView.getInstance():hide();
                            self.m_pWidget:setTouchEnabled(true);
                        end
                        });
                end
                });
        elseif self.baseShowType == PokerUIWndBase.BaseShowType.TTPB then
            transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
                onComplete = function()
                    self.m_pWidget:setVisible(true);
                    transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
                        onComplete = function()
                            PokerTouchCaptureView.getInstance():hide();
                            self.m_pWidget:setTouchEnabled(true);
                        end
                        });
                end
                });
        else
            PokerTouchCaptureView.getInstance():hide();
            self.m_pWidget:setVisible(true);
            self.m_pWidget:setTouchEnabled(true);
        end
    --todo
    -- end

end

-- 关闭窗口
function PokerUIWndBase:close(noAnim)
    Log.i("PokerUIWndBase:close......")
	if self.m_pWidget == nil then
		return;
	end
    --
    PokerTouchCaptureView.getInstance():show();
    self.m_pWidget:setTouchEnabled(false);



    ---
    PokerTouchCaptureView.getInstance():hide();
    self:onClose();
    PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
    self.m_pBaseNode = nil;
    self.m_pWidget = nil;
    --
    self.netImgsTable = {};
    return

    --[[
    -------------------------------------------------
    if not noAnim and self.m_AnimType == TRAN_RIGHT_TO_LEFT then
        self:onClose();
        local topWnd = PokerUIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        topWnd.m_pWidget:moveBy(0.2, display.width, 0);
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(display.width, 0)), {
            onComplete = function()
                PokerTouchCaptureView.getInstance():hide();
                local topWnd = PokerUIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);

                PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
                self.m_pBaseNode = nil;
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    elseif not noAnim and self.m_AnimType == PUSH_BOTTOM_TO_TOP then
        local topWnd = PokerUIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        self:onClose();
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, -display.height)), {
            onComplete = function()
                PokerTouchCaptureView.getInstance():hide();
                local topWnd = PokerUIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);
                PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
                self.m_pBaseNode = nil;
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    else
        if noAnim then
            PokerTouchCaptureView.getInstance():hide();
            self:onClose();
            PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
            self.m_pBaseNode = nil;
            self.m_pWidget = nil;
            --
            self.netImgsTable = {};
            return
        end
        if self.baseShowType == PokerUIWndBase.BaseShowType.RTOL then
            self:onClose();
            self.netImgsTable = {};
            transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(display.width, 0)), {
                onComplete = function()
                    PokerTouchCaptureView.getInstance():hide();
                    PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
                    self.m_pBaseNode = nil;
                    self.m_pWidget = nil; 
                end
                });
        elseif self.baseShowType == PokerUIWndBase.BaseShowType.TTPB then
            self:onClose();
            self.netImgsTable = {};
            transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, -display.height)), {
                onComplete = function()
                    PokerTouchCaptureView.getInstance():hide();
                    PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
                    self.m_pBaseNode = nil;
                    self.m_pWidget = nil; 
                end
                });
        else
            PokerTouchCaptureView.getInstance():hide();
            self:onClose();
            PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode);
            self.m_pBaseNode = nil;
            self.m_pWidget = nil;
            --
            self.netImgsTable = {};
        end
    end
    --]]


end

-- 收到返回键事件
function PokerUIWndBase:onKeyBack()
    Log.i("PokerUIWndBase:onKeyBack....",self.m_pWidget:isTouchEnabled())
    if self.m_pWidget and self.m_pWidget:isVisible() then
        self:keyBack();
    end

end

-- 收到返回键事件
function PokerUIWndBase:keyBack()
    PokerUIManager.getInstance():popWnd(self);
end

function PokerUIWndBase:popSelf()
    PokerUIManager.getInstance():popWnd(self);
end

-- -- 网络连通
-- function PokerUIWndBase:onNetWorkConnected()
-- end

-- -- 网络关闭
-- function PokerUIWndBase:onNetWorkClosed()
--     Log.i("------PokerUIWndBase:onNetWorkClosed")
--     LoadingView.getInstance():hide();
--     LoadingView.getInstance():hide("networkState");
--     local commonDialog = PokerUIManager.getInstance():getWnd(CommonDialog);
--     if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
--         or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
--         return;
--     end

--     local str_content = "服务器连接失败，请检查您的网络或稍后尝试"
--     local is_maintain = kLoginInfo:isServerMaintain()

--     if is_maintain then
--         str_content = "亲爱的玩家，服务器正在维护中，请您耐心等候"
--     end
--     local data = {}
--     data.type = 1;
--     data.title = "提示";
--     data.contentType = COMNONDIALOG_TYPE_NETWORK;
--     data.content = str_content
--     data.yesCallback = function ()
--         SocketManager.getInstance():closeSocket();
--         if PokerUIManager.getInstance():getWnd(HallLogin) then
--             --在登录界面
--             return;
--         end

--         if PokerUIManager.getInstance():getWnd(HallMain) then
--             -- 在大厅
--             local info = {};
--             info.isExit = true;
--             PokerUIManager.getInstance():replaceWnd(HallLogin, info);
--         end
--     end
--     PokerUIManager.getInstance():pushWnd(CommonDialog, data);
-- end

-- -- 网络关闭
-- function PokerUIWndBase:onNetWorkClose()
-- end

-- -- 网络连通失败
-- function PokerUIWndBase:onNetWorkConnectFail()
--     Log.i("------PokerUIWndBase:onNetWorkConnectFail")
--     LoadingView.getInstance():hide("networkState");
--     LoadingView.getInstance():hide();
--     local commonDialog = PokerUIManager.getInstance():getWnd(CommonDialog);
--     if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
--         or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
--         return;
--     end
--     local data = {}
--     data.type = 1;
--     data.title = "提示";
--     data.contentType = COMNONDIALOG_TYPE_NETWORK;
--     data.content = "服务器连接失败，请检查您的网络或稍后尝试";
--     data.yesCallback = function ()
--         SocketManager.getInstance():closeSocket();

--         if PokerUIManager.getInstance():getWnd(HallMain) then
--             -- 在大厅
--             local info = {};
--             info.isExit = true;
--             PokerUIManager.getInstance():replaceWnd(HallLogin, info);
--         end
--     end
--     PokerUIManager.getInstance():pushWnd(CommonDialog, data);
-- end

-- -- 网络连通异常
-- function PokerUIWndBase:onNetWorkConnectWeak()
--     Log.i("------PokerUIWndBase:onNetWorkConnectWeak");
--     LoadingView.releaseInstance();
--     LoadingView.getInstance():show("您当前的网络不稳定，请检查您的网络", 30, true, "networkState");
-- end

-- -- 网络连通异常
-- function PokerUIWndBase:onNetWorkConnectException()
--     Log.i("------PokerUIWndBase:onNetWorkConnectException");
--     LoadingView.getInstance():show("网络异常，正在重连...",1000, true, "networkState");
-- end

-- function PokerUIWndBase:onNetWorkConnectHealthly()
--     -- Log.i("------PokerUIWndBase:onNetWorkConnectHealthly");
--     LoadingView.getInstance():hide("networkState");
-- end

-- -- 网络重连成功
-- function PokerUIWndBase:onNetWorkReconnected()
--     Log.i("------PokerUIWndBase:onNetWorkReconnected");
--     LoadingView.getInstance():hide("networkState");
--     HallAPI.ViewAPI:showToast("重连成功");
-- end

function PokerUIWndBase:onTouchBegan(touch, event)
  return false;
end

function PokerUIWndBase:onTouchMoved(touch, event)

end

function PokerUIWndBase:onTouchEnded(touch, event)

end

--注册触摸事件
function PokerUIWndBase:regTouchEvent()
   	    -- handing touch events
        local touchBeginPoint = nil
        local function onTouchBegan(touch, event)
		    local location = touch:getLocation()
            Log.i("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
            return self:onTouchBegan(touch, event)
        end

        local function onTouchMoved(touch, event)
            local location = touch:getLocation()
            Log.i("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
             self:onTouchMoved(touch, event)
        end

        local function onTouchEnded(touch, event)
            local location = touch:getLocation()
            Log.i("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
            self:onTouchEnded(touch, event)
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_pWidget)
end



-- function PokerUIWndBase:handleSocketCmd(cmd, ...)
-- 	if not self.s_socketCmdFuncMap[cmd] then
-- 		printLog("PokerUIWndBase", "Not such socket cmd="..cmd.."in current wnd");
-- 		return;
-- 	end

-- 	return self.s_socketCmdFuncMap[cmd](self, ...);
-- end

-- PokerUIWndBase.s_socketCmdFuncMap = {

-- };