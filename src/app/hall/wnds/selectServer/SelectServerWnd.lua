
--[[
    @desc:  服务器选择测试界面
    author:{author}
    time:2017-11-19 13:20:59
    return
]]

local SelectServerWnd = class("SelectServerWnd", UIWndBase)
local crypto = require "app.framework.crypto"

local Index = {
    Input = "InputLayer",
    Btns  = "BtnsLayer",
    Tacs  = "TestAccounts",
}

function SelectServerWnd:ctor()
	self.super.ctor(self)
	self.m_pWidget = display.newLayer()
	self.m_pWidget:setContentSize(display.width,display.height)
	self:regTouchEvent()

    self.lays = {}      -- 独立显示的节点容器

    if IsPortrait then -- TODO
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    end

    self:initInputLayer()   -- 初始化输入信息界面

	self:BtnLoginLayer()    -- 初始化按钮登陆界面

    self:initTestWebView()  -- 初始化webview测试界面

    self:initTAccountPanel()  -- 初始化测试功能界面
end

-- 根据key显示层
function SelectServerWnd:showLayer(key)
    Log.i("=============" , key,self.lays)
    for k,lay in pairs(self.lays) do
        lay:setVisible( k == key and not lay:isVisible() or false )
    end
end

-- 输入信息界面初始化
function SelectServerWnd:initInputLayer()
    self.InputLayer = cc.Node:create()
    self.InputLayer:addTo(self.m_pWidget)
    self.lays[Index.Input] = self.InputLayer
    self.InputLayer:setVisible(false)
    self:createServerList()
    self:createInputBgLayer()
    self:initInputLyaerWidget()
end

-- 服务器选择列表初始化
function SelectServerWnd:createServerList()
    local serverLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 150))
    serverLayer:setContentSize(cc.size(280, 500))
    serverLayer:setPosition(cc.p(display.cx - serverLayer:getContentSize().width - 60 , 100))
    serverLayer:addTo(self.InputLayer)

    self.serverListView = ccui.ListView:create()
    self.serverListView:setContentSize(serverLayer:getContentSize().width - 20, serverLayer:getContentSize().height-40)
    self.serverListView:setBounceEnabled(true)
    self.serverListView:setPosition(cc.p(10, 20))
    self.serverListView:addTo(serverLayer)
    -- self.serverListView:setBackGroundColor(cc.c3b(200, 0, 0))
    -- setDirection
    -- ccui.LayoutType.VERTICAL

    self.btnListView = ccui.ListView:create()
    self.btnListView:setContentSize(serverLayer:getContentSize().width - 20, serverLayer:getContentSize().height-40)
    self.btnListView:setBounceEnabled(true)
    self.btnListView:setPosition(cc.p(10, 20))
    -- self.btnListView:addTo(serverLayer)

    local labelChoose = cc.LabelTTF:create("服务器选择", "hall/font/fangzhengcuyuan.TTF", 30)
    labelChoose:setPosition(cc.p(serverLayer:getContentSize().width/2, serverLayer:getContentSize().height + 30))
    labelChoose:setColor(cc.c3b(0, 255, 0))
    labelChoose:addTo(serverLayer)

    self.btn_list = {}
    self:initDefaultServerList()
    self.serverLayer = serverLayer
end

-- 创建输入信息界面背景
function SelectServerWnd:createInputBgLayer()
    local layInPut = cc.LayerColor:create(cc.c4b(255, 255, 255, 180))
    layInPut:setContentSize(cc.size(400, 500))
    layInPut:setPosition(cc.p(display.cx-50, 100))
    layInPut:addTo(self.InputLayer)

    local labelChoose = cc.LabelTTF:create("服务器所需数据", "hall/font/fangzhengcuyuan.TTF", 30)
    labelChoose:setPosition(cc.p(layInPut:getContentSize().width/2, layInPut:getContentSize().height + 30))
    labelChoose:setColor(cc.c3b(0, 255, 0))
    labelChoose:addTo(layInPut)
    self.layInPut = layInPut
end

-- 初始化输入信息界面控件
function SelectServerWnd:initInputLyaerWidget()
    layInPut = self.layInPut
	local size = cc.size(300, 30)
	local position = cc.p(195, 200)

	inp_Wname = ccui.EditBox:create(size, "hall/Common/advertNoSelect.png")
	inp_Wname:setPosition(position)
	inp_Wname:setFontColor(cc.c3b(0, 0, 0))
	inp_Wname:setMaxLength(100)
	inp_Wname:setPlaceHolder("在此输入微信昵称")
	inp_Wname:addTo(layInPut)
	local strAccountCache = self:getAccountCache()
	if strAccountCache ~= "" then
		inp_Wname:setText(strAccountCache)
	end

	inp_headUrl = ccui.EditBox:create(size, "hall/Common/advertNoSelect.png")
	inp_headUrl:setPosition(position.x, position.y + 50)
	inp_headUrl:setFontColor(cc.c3b(0, 0, 0))
	inp_headUrl:setMaxLength(1000)
	inp_headUrl:setPlaceHolder("在此输入头像url地址")
	inp_headUrl:addTo(layInPut)

	inp_UniID = ccui.EditBox:create(size, "hall/Common/advertNoSelect.png")
	inp_UniID:setPosition(position.x, position.y + 100)
	inp_UniID:setFontColor(cc.c3b(0, 0, 0))
	inp_UniID:setMaxLength(100)
	inp_UniID:setPlaceHolder("在此输入uni id")
	inp_UniID:addTo(layInPut)

	inp_openID = ccui.EditBox:create(size, "hall/Common/advertNoSelect.png")
	inp_openID:setPosition(position.x, position.y + 150)
	inp_openID:setFontColor(cc.c3b(0, 0, 0))
	inp_openID:setMaxLength(100)
	inp_openID:setPlaceHolder("在此输入open id")
	inp_openID:addTo(layInPut)
    -- 编辑框绑定事件
    local function openIDEditboxEventHandler(eventType)
        if eventType == "began" then   -- 点击编辑框,输入法显示
        elseif eventType == "ended" then  -- 当编辑框失去焦点并且键盘消失的时候被调用
        elseif eventType == "changed" then  -- 输入内容改变时调用
        elseif eventType == "return" then  -- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
            if inp_UniID then
                inp_UniID:setText("u_" .. inp_openID:getText())
            end
            if inp_Wname then
                inp_Wname:setText("n_" .. inp_openID:getText())
            end
        end
    end
    inp_openID:registerScriptEditBoxHandler(openIDEditboxEventHandler)

	inp_md5 = ccui.EditBox:create(size, "hall/Common/advertNoSelect.png")
	inp_md5:setPosition(position.x, position.y + 200)
	inp_md5:setFontColor(cc.c3b(0, 0, 0))
	inp_md5:setMaxLength(100)
	inp_md5:setPlaceHolder("在此输入md5")
	inp_md5:addTo(layInPut)

	self.server_IP = ccui.EditBox:create(cc.size(170, size.height), "hall/Common/advertNoSelect.png")
	self.server_IP:setPosition(cc.p(position.x - 65,position.y - 50))
	self.server_IP:setFontColor(cc.c3b(0, 0, 0))
	self.server_IP:setMaxLength(32)
	self.server_IP:setPlaceHolder("当前选择的IP")
	self.server_IP:addTo(layInPut)
	self.server_IP:setText(SERVER_IP)
	self.server_IP:registerScriptEditBoxHandler(
	function(eventname,sender)
		if eventname == "ended" then
			SERVER_IP = self.server_IP:getText()
		end
	end)

	self.serverPort = ccui.EditBox:create(cc.size(110, size.height), "hall/Common/advertNoSelect.png")
	self.serverPort:setPosition(cc.p(position.x + self.server_IP:getContentSize().width/2,position.y - 50))
	self.serverPort:setFontColor(cc.c3b(0, 0, 0))
	self.serverPort:setMaxLength(15)
	self.serverPort:setPlaceHolder("当前选择的端口")
	self.serverPort:addTo(layInPut)
	self.serverPort:setText(SERVIER_PORT)
	self.serverPort:registerScriptEditBoxHandler(
	function(eventname,sender)
		if eventname == "ended" then
			SERVIER_PORT = self.serverPort:getText()
		end
	end)

    local btnLogin = ccui.Button:create("hall/GUI/selected01.png")  -- 点击登陆按钮
    btnLogin:setPosition(cc.p(180,60))
    btnLogin:setScaleX(3)
    btnLogin:addTo(self.layInPut)
    btnLogin:addTouchEventListener(function(widget , touchType)
        if touchType == ccui.TouchEventType.ended then
            if not self:checkPort(self.serverPort:getText()) then
                return
            end
            WX_HEAD = inp_headUrl:getText()
            WX_UID = inp_UniID:getText()
            WX_OPENID = inp_openID:getText()
            WX_NAME = inp_Wname:getText()
            WX_HEADMD5 = inp_md5:getText()
            cc.UserDefault:getInstance():setStringForKey("testServerIPCache", SERVER_IP)
            cc.UserDefault:getInstance():setStringForKey("testServerPortCache", SERVIER_PORT)
            kLoginInfo:getPhoneInfoAndLink();
        end
    end)
end

 -- 根据 TEST_SERVERS 列表创建服务器选项
function SelectServerWnd:initDefaultServerList()
    local tabText = {"06服务器", "142服务器", "外网测试服(18)","预发布服"}
	for i = 1, #TEST_SERVERS do
		local btn = ccui.Button:create();
		self.btn_list[#self.btn_list + 1] = btn
		btn:setTitleText(tabText[i])
		btn:setTitleFontSize(28)
		self.serverListView:pushBackCustomItem(btn)
		btn:addTouchEventListener(function ()
			SERVER_IP = TEST_SERVERS[i]
			local color = cc.c3b(255, 255, 255)
			for k,v in pairs(self.btn_list) do
				if btn == v then
					color = cc.c3b(38, 204, 38)
				else
					color = cc.c3b(255, 255, 255)
				end
				v:setTitleColor(color)
			end
		end)
	end
end

-- 根据服务器传回的url初始化docker选择列表
function SelectServerWnd:refreshDockServerList(serverURLs)
    for i,url in ipairs(serverURLs) do
        local btn = ccui.Button:create();
        self.btn_list[#self.btn_list + 1] = btn
        local list =string.split(url,":")
        btn:setTitleText("Dk_"..list[2]..list[4])
        btn:setTitleFontSize(28)
        btn:addTouchEventListener(function()
            SERVER_IP = list[3]
            local color = cc.c3b(255, 255, 255)
            for k,v in pairs(self.btn_list) do
                if btn == v then
                    color = cc.c3b(38, 204, 38)
                else
                    color = cc.c3b(255, 255, 255)
                end
                v:setTitleColor(color)
            end
        end)
        self.serverListView:pushBackCustomItem(btn)
    end
end

function SelectServerWnd:createBtnLayer(key)
    local btnLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 180))
    btnLayer:setContentSize(cc.size(600, 500))
    btnLayer:setPosition(cc.p(display.cx - btnLayer:getContentSize().width/2 , 100))
    btnLayer:addTo(self.m_pWidget)
    key = key or tostring(btnLayer)
    self.lays[key] = btnLayer
    return btnLayer
end

-- 按钮的界面初始化
function SelectServerWnd:BtnLoginLayer()
	self.btnLayer = self:createBtnLayer(Index.Btns)
	local BtnPanel = ccui.Button:create("hall/GUI/selected01.png")
	BtnPanel:setPosition(cc.p(display.cx - 250,self.btnLayer:getContentSize().height + 150))
	BtnPanel:addTo(self.m_pWidget)
	BtnPanel:setTitleText("BtnPanel") -- 设置按钮文字
	BtnPanel:setTitleFontSize(18) -- 按钮文字的字体大小
	BtnPanel:addTouchEventListener(function(_, EventType)
		if EventType ~= ccui.TouchEventType.ended then
			self:showLayer(Index.Btns)
		end
	end)
    self:addTestLoginBtn(self.btnLayer)

	local InputPanel = ccui.Button:create("hall/GUI/selected01.png")
	InputPanel:setPosition(cc.p( display.cx - 150, self.btnLayer:getContentSize().height + 150 )) -- 按钮位置(相对于父节点)
	InputPanel:addTo(self.m_pWidget)
	InputPanel:setTitleText("InputPanel") -- 设置按钮文字
	InputPanel:setTitleFontSize(18) -- 按钮文字的字体大小
	InputPanel:addTouchEventListener(function( _,touchType)
		if touchType == ccui.TouchEventType.ended then
            self:showLayer(Index.Input)
		end
	end) -- 按钮回调
end

function SelectServerWnd:initTestWebView()
    local webviewBtn = ccui.Button:create("hall/GUI/selected01.png")
    webviewBtn:setPosition(cc.p( display.cx + 50, self.btnLayer:getContentSize().height + 150 )) -- 按钮位置(相对于父节点)
    webviewBtn:addTo(self.m_pWidget)
    webviewBtn:setTitleText("WebView") -- 设置按钮文字
    webviewBtn:setTitleFontSize(18) -- 按钮文字的字体大小
    webviewBtn:addTouchEventListener(function( _,touchType)
        if touchType == ccui.TouchEventType.ended then
            local ActivityDialog = require("app.hall.wnds.activity.ActivityDialog")
            local data = {}
            data.url = "http://www.baidu.com"
            data.callback = function() end
            data.obj = self
            -- UIManager.getInstance():pushWnd(ActivityDialog, data)
        end
    end) -- 按钮回调
end

function SelectServerWnd:initTAccountPanel()
    local btnLayer = self:createBtnLayer(Index.Tacs)
    local TAccount = ccui.Button:create("hall/GUI/selected01.png")
    TAccount:addTo(self.m_pWidget)
    TAccount:setPosition(cc.p(display.cx - 50,self.btnLayer:getContentSize().height + 150))
    TAccount:setTitleText("TAccount") -- 设置按钮文字
    TAccount:setTitleFontSize(18) -- 按钮文字的字体大小
    TAccount:addTouchEventListener(function(_, EventType)
        if EventType == ccui.TouchEventType.ended then
            self:showLayer(Index.Tacs)
        end
    end)
    local btns = self:addTestLoginBtn(btnLayer,"TAct")
    self:customBtn(btns)
end

-- 自定义处理按钮的接口
function SelectServerWnd:customBtn(btns)
    local t_btn = btns[15]
    t_btn:setTitleText("666")
    t_btn:setColor(display.COLOR_RED)
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/Common/test.plist")
    t_btn:addTouchEventListener( function(pWidget,touchType)   -- 使用异步加载精灵帧的方式来判断，合集图片是否会影响界面创建
        if touchType ==ccui.TouchEventType.ended then
            display.addSpriteFrames("ccc.plist" , "ccc.png" , function(plist, image)
                local layc = class("layc", UIWndBase)
                function layc:ctor(...)
                    self.super.ctor(self, "lay_test.csb", ...);   -- 实验修改json脚本的情况会不会影响界面创建
                end

                Log.i("===========>>>" , plist , image)
                UIManager:getInstance():pushWnd(layc)
            end)
        end
    end)
end

-- 创建快捷登陆按钮
function SelectServerWnd:addTestLoginBtn(lay,inp)
    local btns = {}
    inp = inp or "user"
	for i = 1, 16, 1 do
		local t_btn = ccui.Button:create("hall/GUI/selected01.png")
		t_btn:setPosition(cc.p((i - 1) % 4 * 130 + 100, 430 - math.floor((i - 1) / 4) * 120)) -- 按钮位置(相对于父节点)
        t_btn:addTo(lay)
		t_btn:setTitleText(inp .. i) -- 设置按钮文字
		t_btn:setTitleFontSize(18) -- 按钮文字的字体大小
		t_btn:setColor(display.COLOR_GREEN)
		t_btn:setScale(2.0)
		t_btn:addTouchEventListener( function(pWidget,touchType)
			if touchType ~= ccui.TouchEventType.ended then
                WX_OPENID = GC_TestID .. i .. inp -- 登录的openID, 服务器以此为标记确定登录的帐号
                WX_NAME = inp .. i -- 玩家昵称
                WX_UID = crypto.md5(WX_OPENID)  -- 生成一个md5码作为unioin id
                self.m_data.hallLogin:onLoginGetWhiteLists(function() kLoginInfo:getPhoneInfoAndLink(); end)
            end
		end)
        table.insert(btns , t_btn)
	end
    return btns
end

function SelectServerWnd:setLogin(hallLogin)
    self.m_data.hallLogin = hallLogin
end

function SelectServerWnd:onTouchBegan(touch, event)
	return true;
end

function SelectServerWnd:onTouchEnded(touch, event)
	local location = touch:getLocation()
end

-- 检查端口
function SelectServerWnd:checkPort(str)
    if not str then
        Toast.getInstance():show("请输入帐号")
        return false
    else
        local len = string.len(str)
        local strTemp = string.match(str, "^[0-9]*$")
        if not strTemp or len ~= string.len(strTemp) then
            Toast.getInstance():show("请输入正确的端口号，仅为数字")
            return false
        end
    end
    return true
end

-- 检测账号合法性
function SelectServerWnd:checkAccount(str)
    if not str then
        Toast.getInstance():show("请输入帐号")
        return false
    elseif string.len(str) < 6 then
        Toast.getInstance():show("请输入至少6位数的帐号")
        return false
    else
        local len = string.len(str)
        local strTemp = string.match(str, "%w+")
        if not strTemp or len ~= string.len(strTemp) then
            Toast.getInstance():show("请输入正确的帐号，不含空格、字符、汉字等")
            return false
        end
    end
    return true
end

-- 得到缓存账号数据
function SelectServerWnd:getAccountCache()
    local STR_WXID_FIRST = "WX_OPEN_ID_"
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("account")
    if accountInfoStr and accountInfoStr ~= "" then
    	local accountInfo = json.decode(accountInfoStr)
    	for v, k in pairs(accountInfo) do
    		local account = k.act
    		if account and type(account) == "string" then
    			local nLengthAll = string.len(account)
    			local nLengthFirst = string.len(STR_WXID_FIRST)
    			local strAccountFirst = string.sub(account, 1, nLengthFirst)
    			if strAccountFirst == STR_WXID_FIRST then
    				return string.sub(account, nLengthFirst + 1, nLengthAll)
    			end
    		end
    	end
    end
    return ""
end

-- 得到缓存ip
function SelectServerWnd:getIPCache()
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("testServerIPCache")
    if accountInfoStr and accountInfoStr ~= "" then
    	return accountInfoStr
    end
    return SERVER_IP
end

-- 得到缓存端口
function SelectServerWnd:getPortCache()
    local accountInfoStr = cc.UserDefault:getInstance():getStringForKey("testServerPortCache")
    if accountInfoStr and accountInfoStr ~= "" then
    	if self:checkPort(accountInfoStr) then
    		return accountInfoStr
    	end
    end
    return SERVIER_PORT
end

return SelectServerWnd
