--
local AdvertView_page = class("AdvertView_page", UIWndBase);

function AdvertView_page:ctor(index)
    if IsPortrait then -- TODO
        local zOrder = 66
        self.super.ctor(self, "hall/adverView_page.csb", index,zOrder);
    else
        self.super.ctor(self, "hall/adverView_page_heng.csb", index, 9);
    end
    --初始化当前广告index
    if index then
    	self.curIndex = index
    else
    	self.curIndex = 1
    end
    --初始化广告总数量
    self.totalNum = 0
    self.layoutData = {UIWndBase.LayoutTypeX.CENTER,UIWndBase.LayoutTypeY.CENTER}
end

function AdvertView_page:onClose()
end

function AdvertView_page:onInit()
    if IsPortrait then -- TODO
        self.panelAdvertBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_content")

        self.txtTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")

        self.txtWeiXin = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_wx")

        self.imgAdvert = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_content")
    else
    	self.panelAdvertBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_advert_bg")
       
        self.txtTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_title")

        self.txtWeiXin = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_weixin")

        self.imgAdvert = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_advert")
    end

    self.btnClose = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_return")
    self.btnClose:addTouchEventListener(handler(self, self.onCloseClickButton))
    self.txtTitle:setString("")--提示
    self.txtWeiXin:setString("")--读取不到图片

    self.btnCopy = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_copy")
    self.btnCopy:addTouchEventListener(handler(self, self.copyBtnBack))

    self.txtTips = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_tips")
    self.txtTips:setString("详情咨询：")
    self.imgAdvert:setVisible(false)

    self:getAdvertFromServer()
end

--从服务器获取数据
function AdvertView_page:getAdvertFromServer()
	local tmpInfo = json.decode(kServerInfo:getPoAURL());
	if(tmpInfo~=nil) then
		self.m_advertList = tmpInfo;
		Log.i("AdvertView_page:getAdvertFromServer广告信息:",self.m_advertList)

		self.totalNum = #self.m_advertList

		local imgName = self.m_advertList[self.curIndex].img
		
		local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
		-- print("AdvertView_page:getAdvertFromServer+++++++++",imgName,self.curIndex,io.exists(imgFile))
		if io.exists(imgFile) then
			if IS_YINGYONGBAO == false then
				self:createAdvertView();
			end
		else
            if IsPortrait then -- TODO
                LoadingView.getInstance():hide("AdvertView")
                LoadingView.getInstance():show("图片正在加载中...",nil,nil, "AdvertView",nil,nil,true)
            else
    			LoadingView.getInstance():hide()
    			LoadingView.getInstance():show("正在加载图片,请稍后...",nil, nil, nil, -150, -65,true)
            end
			HttpManager.getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName)
		end

	else
	   Log.i("服务器广告数据格式错误")
	end
end

--返回网络图片
function AdvertView_page:onResponseNetImg(fileName)
	Log.i("开始加载网络广告图")

	local imgName = self.m_advertList[self.curIndex].img
	local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
	if io.exists(imgFile) then
		if IS_YINGYONGBAO == false then
			self:createAdvertView();
		end
	else
        if IsPortrait then -- TODO
            LoadingView.getInstance():hide("AdvertView")
            LoadingView.getInstance():show("图片正在加载中...",nil,nil, "AdvertView",nil,nil,true)
        else
    		LoadingView.getInstance():hide()
    		LoadingView.getInstance():show("正在加载图片,请稍后...",nil, nil, nil, -150, -65,true)
        end
		HttpManager.getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName)
	end
end

--关闭按钮回调
function AdvertView_page:onCloseClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if IsPortrait then -- TODO
            LoadingView.getInstance():hide("AdvertView")
        else
        	LoadingView.getInstance():hide()
        end
		UIManager:getInstance():popWnd(AdvertView_page);

		if (self.curIndex+1) <= self.totalNum then
			UIManager:getInstance():pushWnd(AdvertView_page,self.curIndex+1)
		else
			if self.finishCallFunc then
				self.finishCallFunc()
			end
		end
    end
end

--复制按钮回调
function AdvertView_page:copyBtnBack(pWidget, EventType)
	--此时self.curIndex已经+1 所以-1之后才是当前真正的index
    if EventType == ccui.TouchEventType.ended then
	    local tmpInfo = json.decode(kServerInfo:getPoAURL())
	    if tmpInfo then
	    	if tmpInfo[self.curIndex] and tmpInfo[self.curIndex].wechat then
		        SoundManager.playEffect("btn");
		        local data = {}
		        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
		        data.content = string.format("%s",tmpInfo[self.curIndex].wechat)--
		        Log.i("-----copy code----->" .. tmpInfo[self.curIndex].wechat)
		        NativeCall.getInstance():callNative(data);
		        Toast.getInstance():show("复制信息成功");
	    	end
	    end
    end
end

--创建广告视图
function AdvertView_page:createAdvertView()
	self:setTitleAndWx()
	self:createPageView()
end

--创建广告视图
function AdvertView_page:createPageView()
	if self.curIndex > self.totalNum then
		return
	end
	local fileName = self.m_advertList[self.curIndex].img;
	fileName = cc.FileUtils:getInstance():fullPathForFilename(fileName);
	Log.i("加载路径",fileName)

    if IsPortrait then -- TODO
        LoadingView.getInstance():hide("AdvertView")
    else
    	LoadingView.getInstance():hide()
    end
	self.imgAdvert:loadTexture(fileName)
	self.imgAdvert:setVisible(true)

	self.panelAdvertBg:requestDoLayout()
end

--
function AdvertView_page:setTitleAndWx( )
    local tmpInfo = json.decode(kServerInfo:getPoAURL())
    if tmpInfo then
    	if tmpInfo[self.curIndex] and tmpInfo[self.curIndex].title then
    		self.txtTitle:setString(tmpInfo[self.curIndex].title)
    	end
    	if tmpInfo[self.curIndex] and tmpInfo[self.curIndex].wechat then
    		self.txtWeiXin:setString(tmpInfo[self.curIndex].wechat)
    	end
    end
end

--设置广告图播放完毕后的回调事件
function AdvertView_page:setFinishCallBack(callFunc)
	self.finishCallFunc = callFunc
end

AdvertView_page.s_socketCmdFuncMap = {

};

return AdvertView_page