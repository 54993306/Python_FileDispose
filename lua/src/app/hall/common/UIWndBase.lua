--窗口基类
UIWndBase = class("UIWndBase")

UIWndBase.LayoutTypeX = {
    LEFT       = 1,
    CENTER     = 2,
    RIGHT      = 3
}
UIWndBase.LayoutTypeY = {
    BOTTOM     = 1,
    CENTER     = 2,
    TOP        = 3
} 
UIWndBase.BaseShowType = {
    COMMON = 1,
    RTOL = 2,
    TTPB = 3
}
-- 构造函数
function UIWndBase:ctor(uiConfig, data, zOrder, delegate)
	self.m_uiConfig = uiConfig 	or "";			-- UI配置文件
	self.m_data = data or {};					-- 数据
    self.zOrder = zOrder or 0;                  -- 窗口层级
    self.m_delegate = delegate;                 -- 代理
	self.netImgsTable = {};                     -- 网络加载图片
    self.layoutData = {}          -- 布局参数 {UIWndBase.LayoutTypeX, UIWndBase.LayoutTypeY}
    self.baseShowType = self.baseShowType or UIWndBase.BaseShowType.COMMON --show()的显示效果。

    self.m_maintainCode = "005" -- 维护提示框代码

    -- 网络重连框重连回调
    self.m_netDialogYesCallback = function ()
        Log.i("UIWndBase.m_netDialogYesCallback")
        SocketManager.getInstance():onConnectException()
    end
    -- 网络重连框退出回调
    self.m_netDialogCloseCallback = function ()
        Log.i("UIWndBase.m_netDialogCloseCallback")
        -- 在登录界面
        if UIManager.getInstance():getWnd(HallLogin) then
            UIManager.getInstance():popToWnd(HallLogin)
        end
        -- 在大厅
        if UIManager.getInstance():getWnd(HallMain) then
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
    end
    -- 网络退出框退出回调
    self.m_netDialogCancalCallback = self.m_netDialogCloseCallback
end

function UIWndBase:setDelegate(delegate)
    self.m_delegate = delegate;
end

function UIWndBase:getWidget()
    return self.m_pWidget;
end

-- 响应窗口资源初始化 在执行load后会执行
function UIWndBase:onInit()end

-- 窗口隐藏
function UIWndBase:setVisible(visible)
	if self.m_pWidget then
		self.m_pWidget:setVisible(visible);
	end
end

-- 响应窗口显示
function UIWndBase:onShow()
end

-- 响应窗口回到最上层
function UIWndBase:onResume()
end

-- 窗口被关闭响应
function UIWndBase:onClose()
end

function UIWndBase:onLostFocus()
    if not tolua.isnull(self.m_pBaseNode) then
        self.m_pBaseNode:setBackGroundColorOpacity(0)
    end
end

function UIWndBase:onGetFocus()
    if not tolua.isnull(self.m_pBaseNode) then
        self.m_pBaseNode:setBackGroundColorOpacity(160)
    end
end

--返回网络图片
function UIWndBase:onResponseNetImg(fileName)
    if fileName == nil then
        return;
    end
    local imgViews = self.netImgsTable[fileName];
    if type(imgViews) == "table" then
        for k, v in ipairs(imgViews) do
            if v then
                v:loadTexture(fileName);
            end
        end
    elseif imgViews then
        local errorLog = {
            cname = self.__cname,
            fileName = fileName,
            netImgsTable = self.netImgsTable,
        }
        Log.e("error imgViews type", errorLog)
        Util.reportBugly(93553, errorLog)
    end
end

-- 加载UI资源
function UIWndBase:loadUIConfig()
	if self.m_pWidget ~= nil then
		return
	end

    -- 加载ui配置文件
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.m_uiConfig);
    self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
	if self.m_pWidget == nil then
		printError("加载"..self.m_uiConfig.."文件失败");
		return;
	end


    -- 处理显示位置
    if self.layoutData[1] == UIWndBase.LayoutTypeX.LEFT then
        self.m_pWidget:setPositionX(0)
    elseif self.layoutData[1] == UIWndBase.LayoutTypeX.CENTER then
        self.m_pWidget:setPositionX(display.size.width / 2 - self.m_pWidget:getContentSize().width/2)
    elseif self.layoutData[1] == UIWndBase.LayoutTypeX.RIGHT then
        self.m_pWidget:setPositionX(display.size.width - self.m_pWidget:getContentSize().width)
    end

    if self.layoutData[2] == UIWndBase.LayoutTypeY.BOTTOM then
        self.m_pWidget:setPositionY(0)
    elseif self.layoutData[2] == UIWndBase.LayoutTypeY.CENTER then
        self.m_pWidget:setPositionY(display.size.height / 2 - self.m_pWidget:getContentSize().height/2)
    elseif self.layoutData[2] == UIWndBase.LayoutTypeY.TOP then
        self.m_pWidget:setPositionY(display.size.height - self.m_pWidget:getContentSize().height)
    end
end

function UIWndBase:createBaseNode()
    if self.m_pBaseNode == nil then
        self.m_pBaseNode = ccui.Layout:create()
        self.m_pBaseNode:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self.m_pBaseNode:setBackGroundColor(cc.c3b(0,0,0))
        self.m_pBaseNode:setBackGroundColorOpacity(160)
        self.m_pBaseNode:setContentSize(display.size)
    end
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function UIWndBase:getWidget(parent, name, ...)
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
                widget:setFontName("hall/font/bold.TTF");
            elseif args.shadow_bold == true then
                --新的美術字體效果 cc.c3b(255, 0, 0)  cc.size(2,-2)
                widget:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,-1));
                widget:setFontName("hall/font/fangzhengcuyuan.TTF");
            end
        end
    elseif m_type == "TextField" then             --安卓的时候有bug
        return self:setTextFieldToEditBox(widget,name);
    end
    return widget;
end

function UIWndBase:addWidgetClickFunc(widget, callfunc)
    if widget ~= nil and callfunc ~= nil then
        widget:addTouchEventListener(function(pWidget, EventType)
            if EventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end);
    end
end

function UIWndBase:setTextFieldToEditBox(textfield,tfName)

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
-- 显示窗口 UIManager 中创建对象的时候外部调用
function UIWndBase:show(AnimType)
	-- 如果没有加载过，进行加载
    self:loadUIConfig();
    self:createBaseNode();
    
    self.m_pBaseNode:addChild(self.m_pWidget)
    self.m_baseShowPos = cc.p(self.m_pWidget:getPosition())

    UIManager:getInstance():addToRoot(self.m_pBaseNode, self.zOrder);
	-- 执行初始化
    self.m_pWidget:setVisible(false);
    self.m_pWidget:setTouchEnabled(false);
    TouchCaptureView.getInstance():show();
	self:onInit();
    if AnimType == TRAN_RIGHT_TO_LEFT then
        self.m_AnimType = TRAN_RIGHT_TO_LEFT;
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
            onComplete = function()
                self.m_pWidget:setVisible(true);
                local topWnd = UIManager.getInstance():getSecondTopWnd();
                topWnd.m_pWidget:setTouchEnabled(false);
                topWnd.m_pWidget:moveBy(0.2, -display.width, 0);
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
                    onComplete = function()
                        TouchCaptureView.getInstance():hide();
                        self.m_pWidget:setTouchEnabled(true);
                        local topWnd = UIManager.getInstance():getSecondTopWnd();
                        topWnd.m_pWidget:setTouchEnabled(true);
                    end
                    });
            end
            });
    elseif AnimType == PUSH_BOTTOM_TO_TOP then
        self.m_AnimType = PUSH_BOTTOM_TO_TOP;
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
            onComplete = function()
                self.m_pWidget:setVisible(true);
                local topWnd = UIManager.getInstance():getSecondTopWnd();
                topWnd.m_pWidget:setTouchEnabled(false);
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
                    onComplete = function()
                        TouchCaptureView.getInstance():hide();
                        self.m_pWidget:setTouchEnabled(true);
                        local topWnd = UIManager.getInstance():getSecondTopWnd();
                        topWnd.m_pWidget:setTouchEnabled(true);
                    end
                    });
            end
            });
    else
        if self.baseShowType == UIWndBase.BaseShowType.RTOL then
            if IsPortrait then -- TODO
                --修改 20171110 start 竖版换皮  diyal.yin
                self.m_pWidget:setVisible(true);
                TouchCaptureView.getInstance():hide();
                self.m_pWidget:setTouchEnabled(true);
                --修改 20171110 end 竖版换皮 diyal.yin
            else
                transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
                    onComplete = function()
                        self.m_pWidget:setVisible(true);
                        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
                            onComplete = function()
                                TouchCaptureView.getInstance():hide();
                                self.m_pWidget:setTouchEnabled(true);
                            end
                            });
                    end
                    });
            end
        elseif self.baseShowType == UIWndBase.BaseShowType.TTPB then
            transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
                onComplete = function()
                    self.m_pWidget:setVisible(true);
                    transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
                        onComplete = function()
                            TouchCaptureView.getInstance():hide();
                            self.m_pWidget:setTouchEnabled(true);
                        end
                        });
                end
                });
        else
            TouchCaptureView.getInstance():hide();
            self.m_pWidget:setVisible(true);
            self.m_pWidget:setTouchEnabled(true);
        end
    --todo
    end

end

-- 关闭窗口
function UIWndBase:close(noAnim)
    Log.i("UIWndBase:close......")
	
    if self.m_pWidget == nil then
		return;
	end
    --
    TouchCaptureView.getInstance():show();
    self.m_pWidget:setTouchEnabled(false);
    if not noAnim and self.m_AnimType == TRAN_RIGHT_TO_LEFT then
        self:onClose();
        local topWnd = UIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        topWnd.m_pWidget:moveBy(0.2, display.width, 0);
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(display.width, 0)), {
            onComplete = function()
                TouchCaptureView.getInstance():hide();
                local topWnd = UIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);

                UIManager.getInstance():removeToRoot(self.m_pBaseNode);
                self.m_pBaseNode = nil;
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    elseif not noAnim and self.m_AnimType == PUSH_BOTTOM_TO_TOP then
        local topWnd = UIManager.getInstance():getTopWnd();
        topWnd.m_pWidget:setTouchEnabled(false);
        self:onClose();
        transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, -display.height)), {
            onComplete = function()
                TouchCaptureView.getInstance():hide();
                local topWnd = UIManager.getInstance():getTopWnd();
                topWnd.m_pWidget:setTouchEnabled(true);
                UIManager.getInstance():removeToRoot(self.m_pBaseNode);
                self.m_pBaseNode = nil;
                self.m_pWidget = nil;
                --
                self.netImgsTable = {};
            end
        });
    else
        if noAnim then
            TouchCaptureView.getInstance():hide();
            self:onClose();
            UIManager.getInstance():removeToRoot(self.m_pBaseNode);
            self.m_pBaseNode = nil;
            self.m_pWidget = nil;
            --
            self.netImgsTable = {};
            return
        end
        if self.baseShowType == UIWndBase.BaseShowType.RTOL then
            self:onClose();
            self.netImgsTable = {};
            if IsPortrait then -- TODO
                --修改 20171110 start 竖版换皮  diyal.yin
                TouchCaptureView.getInstance():hide();
                UIManager.getInstance():removeToRoot(self.m_pBaseNode);
                self.m_pBaseNode = nil;
                self.m_pWidget = nil; 
                --修改 20171110 end 竖版换皮 diyal.yin
            else
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(display.width, 0)), {
                    onComplete = function()
                        TouchCaptureView.getInstance():hide();
                        UIManager.getInstance():removeToRoot(self.m_pBaseNode);
                        self.m_pBaseNode = nil;
                        self.m_pWidget = nil; 
                    end
                    });
            end
        elseif self.baseShowType == UIWndBase.BaseShowType.TTPB then
            self:onClose();
            self.netImgsTable = {};
            transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, -display.height)), {
                onComplete = function()
                    TouchCaptureView.getInstance():hide();
                    UIManager.getInstance():removeToRoot(self.m_pBaseNode);
                    self.m_pBaseNode = nil;
                    self.m_pWidget = nil; 
                end
                });
        else
            TouchCaptureView.getInstance():hide();
            self:onClose();
            UIManager.getInstance():removeToRoot(self.m_pBaseNode);
            self.m_pBaseNode = nil;
            self.m_pWidget = nil;
            --
            self.netImgsTable = {};
        end
    end



end

-- 收到返回键事件
function UIWndBase:onKeyBack()
    Log.i("UIWndBase:onKeyBack....",self.m_pWidget:isTouchEnabled())
    if self.m_pWidget and self.m_pWidget:isVisible() then
        self:keyBack();
    end

end

-- 收到返回键事件
function UIWndBase:keyBack()
    UIManager.getInstance():popWnd(self);
end

function UIWndBase:popSelf()
    UIManager.getInstance():popWnd(self);
end

-- 网络连通
function UIWndBase:onNetWorkConnected()
end

-- 网络关闭
function UIWndBase:onNetWorkClosed(event)
    Log.i("------UIWndBase:onNetWorkClosed")
    -- dump(event)
    self:showNetWorkClosedNotify("服务器连接失败，请检查您的网络或稍后尝试！代码-006", kLoginInfo:isServerMaintain(), event._forceReturnToLogin)
end

-- 网络断开通知
function UIWndBase:showNetWorkClosedNotify(content, is_maintain, forceReturnToLogin)
    Log.i("UIWndBase:showNetWorkClosedNotify(content, is_maintain)", content, is_maintain, tostring(forceReturnToLogin))

    if forceReturnToLogin then
        self:showDialogReturnToLogin("重连失败, 请检查您的网络后重新登录!")
        return
    end

    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end

    if is_maintain then
        self:showDialogReturnToLogin("服务器即将进行维护！代码" .. self.m_maintainCode)
    else
        self:showDialogRetryConnect(content)
    end
end

-- 弹框提示玩家返回登录界面
function UIWndBase:showDialogReturnToLogin(content)
    LoadingView.getInstance():hide();
    LoadingView.getInstance():hide("networkState");
    SocketManager.getInstance():closeSocket()

    if UIManager.getInstance():getWnd(HallLogin) then return end

    local data = {}
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;

    data.type = 1;
    data.closeCallback = self.m_netDialogCloseCallback

    data.content = content
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 弹框提示玩家重新连接
function UIWndBase:showDialogRetryConnect(content)
    LoadingView.getInstance():hide();
    LoadingView.getInstance():hide("networkState");
    SocketManager.getInstance():closeSocket()

    local data = {}
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;

    data.type = 2
    data.yesStr = "重连"
    data.yesCallback = self.m_netDialogYesCallback
    data.cancalStr = "退出"
    data.cancalCallback = self.m_netDialogCancalCallback

    data.content = content
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

-- 网络关闭
function UIWndBase:onNetWorkClose()
end

-- 网络连通失败
function UIWndBase:onNetWorkConnectFail()
    Log.i("------UIWndBase:onNetWorkConnectFail")
    self:showNetWorkClosedNotify("服务器连接失败，请检查您的网络或稍后尝试")
end

-- 网络连通异常
function UIWndBase:onNetWorkConnectWeak()
    Log.i("------UIWndBase:onNetWorkConnectWeak");
    LoadingView.releaseInstance();
    LoadingView.getInstance():show("您当前的网络不稳定，请检查您的网络", 1000, true, "networkState");
end

-- 网络连通异常
function UIWndBase:onNetWorkConnectException()
    Log.i("------UIWndBase:onNetWorkConnectException");
    LoadingView.getInstance():show("网络异常，正在重连...",1000, true, "networkState");
end

function UIWndBase:onNetWorkConnectHealthly()
    -- Log.i("------UIWndBase:onNetWorkConnectHealthly");
    LoadingView.getInstance():hide("networkState");
end

-- 网络重连成功
function UIWndBase:onNetWorkReconnected()
    Log.i("------UIWndBase:onNetWorkReconnected");
    LoadingView.getInstance():hide("networkState");
    Toast.getInstance():show("重连成功");
    -- 在大厅
    if UIManager.getInstance():getWnd(HallMain) then
        UIManager.getInstance():popToWnd(HallMain)
    end
end

function UIWndBase:onTouchBegan(touch, event)
  return false;
end

function UIWndBase:onTouchMoved(touch, event)

end

function UIWndBase:onTouchEnded(touch, event)

end

--注册触摸事件
function UIWndBase:regTouchEvent()
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



function UIWndBase:handleSocketCmd(cmd, ...)
	if not self.s_socketCmdFuncMap[cmd] then
		printLog("UIWndBase", "Not such socket cmd="..cmd.."in current wnd");
		return;
	end

	return self.s_socketCmdFuncMap[cmd](self, ...);
end

UIWndBase.s_socketCmdFuncMap = {

};