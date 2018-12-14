--[[---------------------------------------- 
-- 修改： 徐松 
-- 日期： 2018.01.11
-- 摘要： 招募代理弹窗。
]]-------------------------------------------


RecruitDialog = class("RecruitDialog", UIWndBase)
local UmengClickEvent = require("app.common.UmengClickEvent")

local kRes = {
	view_csb = "hall/recruit_dialog.csb"
}

-- Widget里的子元素名字
local kCsbElement = {
	window_title = "txt_title",
	btn_close = "btn_return",

	-- 广告图的容器
	panel_advert = "panel_advert_bg",
	img_advert = "img_advert",

	-- 显示微信号的容器
	panel_weixin = "panel_weixin",
	txt_weixin = "txt_weixin",

	-- 复制微信号
	btn_copy = "btn_copy",
}


function RecruitDialog.initData( reS )
	Log.i("$RecruitDialog<---initData--->", reS)
	local res = json.decode(reS) or {}
	local wxids = nil
	if res and res.wxid then
		wxids = string.split(res.wxid, "|")
		for i = 1, #wxids do
			wxids[i] = tostring(wxids[i])
		end
	end
	res.wxtime = tonumber(res.wxtime)

	RecruitDialog.mData = {
		winTitle = res.winTitle or "",
		banner = res.banner or "",
		wxids = wxids or {""},
		wxtime = res.wxtime or 3,
	}
end

function RecruitDialog.hasData()
	return RecruitDialog.mData and true or false
end

function RecruitDialog:ctor()
	RecruitDialog.super.ctor(self, kRes.view_csb)

	self.mWxIndex = 1
end

-- 功能： 初始化
-- 返回值： 无
function RecruitDialog:onInit()
    local function getWidget( name )
        return ccui.Helper:seekWidgetByName(self.m_pWidget, name)
    end

    -- 窗口出现效果
    self.baseShowType = UIWndBase.BaseShowType.RTOL

    -- 窗口标题
    self.mWindowTitle = getWidget(kCsbElement.window_title)

    -- 关闭窗口按钮
    self.mCloseWindow = getWidget(kCsbElement.btn_close)
    self.mCloseWindow:addTouchEventListener(handler(self, self.onClickButton))

    self.mAdvertPanel = getWidget(kCsbElement.panel_advert_bg)
    self.mAdvertImg = getWidget(kCsbElement.img_advert)

    self.mWeixinPanel = getWidget(kCsbElement.panel_weixin)
    self.mWeixinTxt = getWidget(kCsbElement.txt_weixin)
    self.mWeixinTxt:setVisible(false)

    self.mCopyBtn = getWidget(kCsbElement.btn_copy)
    self.mCopyBtn:addTouchEventListener(handler(self, self.onClickButton))

    local data = RecruitDialog.mData
    self.mWindowTitle:setString(data.winTitle)

    -- 设置微信号的显示
    local wmax = self.mWeixinPanel:getContentSize().width - 20
    -- 字符长度超出背景字符框的显示适配处理
   	local function displayText( text )
   		self.mWeixinTxt:setScale(1)
   		self.mWeixinTxt:setString(text)
        self.mWeixinTxt:setVisible(true)

   		local w = self.mWeixinTxt:getContentSize().width
   		local dist = w - wmax
   		-- 如果超出长度了，缩小文字以适应
   		if dist > 0 then
   			self.mWeixinTxt:setScale(1 - dist / w)
   		end
   	end
   	displayText(data.wxids[self.mWxIndex])
   	if #data.wxids > 1 then
   		self.mWeixinTxt:schedule(function ()
    		self.mWxIndex = (self.mWxIndex < #data.wxids) and (self.mWxIndex + 1) or 1
    		displayText(data.wxids[self.mWxIndex])
    	end, data.wxtime)
   	end

    -- 获得资源地址IP
    local rurl = kSystemConfig:getDataByKe("resource_url")
	if rurl ~= false then
		if rurl.va and rurl.va ~= "" then
			if data.banner ~= "" then
		    	local str = string.split(data.banner, "/")
		    	local imgName = str[#str]
		    	if imgName and string.len(imgName) > 4 then
		    		local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
		            if io.exists(imgFile) then
                        LoadingView.getInstance():hide()
		                self.mAdvertImg:loadTexture(imgFile)
		            else
                        LoadingView.getInstance():hide()
                        LoadingView.getInstance():show("正在加载图片,请稍后...",nil, nil, nil, -150, -65,true)
		                HttpManager.getNetworkImage(rurl.va .. data.banner, imgName)
		            end
		    	end
		    end
		end
	end
end

-- 功能： 按钮回调函数
-- 返回值： 无
function RecruitDialog:onClickButton( pWidget, eventType )
    if eventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        if pWidget == self.mCloseWindow then
          LoadingView.getInstance():hide()
        	self:keyBack()
        elseif pWidget == self.mCopyBtn then
        	local wxids = RecruitDialog.mData.wxids
        	local data = {
        		cmd = NativeCall.CMD_CLIPBOARD_COPY,
        		content = wxids[self.mWxIndex] or wxids[1],
        	}
        	Log.i("$RecruitDialog<---copy code--->", data)
        	NativeCall.getInstance():callNative(data)
        	Toast.getInstance():show("微信号已复制")
          NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallDaiLiWXCopyButton)
        end
    end
end

-- 功能： 关闭窗口
-- 返回值： 无
function RecruitDialog:keyBack()
    UIManager:getInstance():popWnd(RecruitDialog)
end

--返回网络图片
function RecruitDialog:onResponseNetImg( fileName )
    Log.i("$RecruitDialog<---onResponseNetImg--->", fileName)
	local imgFile = cc.FileUtils:getInstance():fullPathForFilename(fileName)
	if io.exists(imgFile) then
        LoadingView.getInstance():hide()
		self.mAdvertImg:loadTexture(imgFile)
	end 
end