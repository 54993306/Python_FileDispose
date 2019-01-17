--窗口基类
local PokerConst = require("package_src.games.guandan.gdcommon.data.PokerConst")
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
	self.m_uiConfig = uiConfig 	or ""			-- UI配置文件
	self.m_data = data or {}					-- 数据
    self.zOrder = zOrder or 0                  -- 窗口层级
    self.m_delegate = delegate                 -- 代理
	self.netImgsTable = {}                     -- 网络加载图片
    self.layoutData = {}          -- 布局参数 {PokerUIWndBase.LayoutTypeX, PokerUIWndBase.LayoutTypeY}
    self.baseShowType = self.baseShowType or PokerUIWndBase.BaseShowType.COMMON --show()的显示效果。
end

function PokerUIWndBase:setDelegate(delegate)
    self.m_delegate = delegate
end

-- 响应窗口资源初始化 在执行load后会执行
function PokerUIWndBase:onInit()end

-- 窗口隐藏
function PokerUIWndBase:setVisible(visible)
	if self.m_pWidget then
		self.m_pWidget:setVisible(visible)
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
        return
    end
    local imgViews = self.netImgsTable[fileName]
    if imgViews then
    	for k, v in ipairs(imgViews) do
    		if v then
    			v:loadTexture(fileName)
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
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(self.m_uiConfig)
    self.m_pWidget:setTouchEnabled(true)
    self.m_pWidget:setTouchSwallowEnabled(true)
	if self.m_pWidget == nil then
		printError("加载"..self.m_uiConfig.."文件失败")
		return
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
            elseif args.shadow_bold == true then
                --新的美術字體效果 cc.c3b(255, 0, 0)  cc.size(2,-2)
                widget:enableShadow(cc.c4b(0, 0, 0,255),cc.size(1,-1))
                widget:setFontName("hall/font/fangzhengcuyuan.TTF")
            end
        end
    elseif m_type == "TextField" then             --安卓的时候有bug
        return self:setTextFieldToEditBox(widget)
    end
    return widget
end

function PokerUIWndBase:addWidgetClickFunc(widget, callfunc)
    if widget ~= nil and callfunc ~= nil then
        widget:addTouchEventListener(function(pWidget, EventType)
            if EventType == ccui.TouchEventType.ended then
                callfunc()
            end
        end)
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

    editbox:setContentSize(tfS)
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
    self:loadUIConfig()
    self:createBaseNode()
    
    self.m_pBaseNode:addChild(self.m_pWidget)
    self.m_baseShowPos = cc.p(self.m_pWidget:getPosition())
    --Log.i("PokerUIWndBase:show ", self.zOrder, self.__cname)
    PokerUIManager:getInstance():addToRoot(self.m_pBaseNode, self.zOrder)
	-- 执行初始化
    self.m_pWidget:setVisible(false)
    self.m_pWidget:setTouchEnabled(false)
    PokerTouchCaptureView.getInstance():show()
	self:onInit()

    if self.baseShowType == PokerUIWndBase.BaseShowType.RTOL then
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(display.width, 0)), {
            onComplete = function()
                self.m_pWidget:setVisible(true)
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(-display.width, 0)), {
                    onComplete = function()
                        PokerTouchCaptureView.getInstance():hide()
                        self.m_pWidget:setTouchEnabled(true)
                    end
                    })
            end
            })
    elseif self.baseShowType == PokerUIWndBase.BaseShowType.TTPB then
        transition.execute(self.m_pWidget, cc.MoveBy:create(0, cc.p(0, -display.height)), {
            onComplete = function()
                self.m_pWidget:setVisible(true)
                transition.execute(self.m_pWidget, cc.MoveBy:create(0.2, cc.p(0, display.height)), {
                    onComplete = function()
                        PokerTouchCaptureView.getInstance():hide()
                        self.m_pWidget:setTouchEnabled(true)
                    end
                    })
            end
            })
    else
        PokerTouchCaptureView.getInstance():hide()
        self.m_pWidget:setVisible(true)
        self.m_pWidget:setTouchEnabled(true)
    end
end

-- 关闭窗口
function PokerUIWndBase:close(noAnim)
    -- Log.i("PokerUIWndBase:close......")
	if self.m_pWidget == nil then
		return
	end
    PokerTouchCaptureView.getInstance():show()
    self.m_pWidget:setTouchEnabled(false)

    PokerTouchCaptureView.getInstance():hide()
    self:onClose()
    PokerUIManager.getInstance():removeToRoot(self.m_pBaseNode)
    self.m_pBaseNode = nil
    self.m_pWidget = nil

    self.netImgsTable = {}
    return
end

-- 收到返回键事件
function PokerUIWndBase:onKeyBack()
    Log.i("PokerUIWndBase:onKeyBack....",self.m_pWidget:isTouchEnabled())
    if self.m_pWidget and self.m_pWidget:isVisible() then
        self:keyBack()
    end
end

-- 收到返回键事件
function PokerUIWndBase:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerUIWndBase:popSelf()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerUIWndBase:onTouchBegan(touch, event)
  return false
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