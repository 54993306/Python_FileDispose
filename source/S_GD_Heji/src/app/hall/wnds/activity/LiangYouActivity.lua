-------------------------------------------------------------
--  @file   LiangYouActivity.lua
--  @brief  粮油活动弹窗界面
--  @author army
--  @DateTime:2018-09-13
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

local LiangYouActivity = class("LiangYouActivity", UIWndBase)

local certainOffex = - 30
local certainTop = 880

function LiangYouActivity:ctor(...)
    self.super.ctor(self, "hall/liangyou.csb", ...)
end

function LiangYouActivity:onInit()
    -- if not self:reducedTime() then
    --     self.m_pBaseNode:removeFromParent()
    --     return false
    -- end
    self.m_pBaseNode:setVisible(false)
    -- if not IsPortrait then
    --     self.m_pWidget:setScale(0.8)
    --     local contenSize = self.m_pWidget:getContentSize()
    --     self.m_pWidget:getLayoutParameter():setMargin({ left = display.cx - 0, right = 0, top = 0, bottom = 0})
    -- end
    self.m_certain_Button = ccui.Helper:seekWidgetByName(self.m_pWidget,"certain_Button")
    self.m_certain_Button:addTouchEventListener(handler(self, self.onCertainButton));
    if IsPortrait then
        self.m_certain_Button:getLayoutParameter():setMargin({ left = display.cx - self.m_certain_Button:getContentSize().width/2 + certainOffex, right = 0, top = certainTop, bottom = 0})
    else
        self.m_certain_Button:getLayoutParameter():setMargin({ left = 0, right = 0, top = 600, bottom = 0})
    end
    self.bg_Image = ccui.Helper:seekWidgetByName(self.m_pWidget,"bg_Image")

    self.m_close_Button = ccui.Helper:seekWidgetByName(self.m_pWidget,"close_Button")
    if IsPortrait then
        self.m_close_Button:getLayoutParameter():setMargin({ left = 0, right = 90, top = 270, bottom = 0})
    end

    self.m_close_Button:addTouchEventListener(handler(self, self.onCloseButton));

    -- local activity = kSystemConfig:getDataByKe("php_activity")
    -- if not activity then
    --     return
    -- end
    self:getAdvertFromServer(self.m_data.login_tips_image)
end

--从服务器获取数据
function LiangYouActivity:getAdvertFromServer(url)
	local tmpInfo = url --json.decode(kServerInfo:getPoAURL());
    if(tmpInfo~=nil) then
        local urlSplit = Util.split(tmpInfo,"/")
		local imgName = urlSplit[#urlSplit]
		local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
		-- print("AdvertView_page:getAdvertFromServer+++++++++",imgName,self.curIndex,io.exists(imgFile))
		if io.exists(imgFile) then
            self.bg_Image:loadTexture(imgFile);
            self.m_pBaseNode:setVisible(true)
        else
            self.m_pWidget:setVisible(false)
			self:getNetworkImage(tmpInfo, imgName)
		end

	else
	   Log.i("服务器广告数据格式错误")
	end
end

function LiangYouActivity:getNetworkImage(url, fileName)
    Log.i("HttpManager.getNetworkImage", "-------url = " .. url);
    if not url or string.len(url) < 4 then  -- 图片都是http请求下载的
        if kLoginInfo:isNewAccredit() then
            kLoginInfo:setNewAccredit(false)
            WX_HEADMD5 = "2"
            cc.UserDefault:getInstance():setStringForKey("wx_headmd5",WX_HEADMD5)
        end
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        Log.i("HttpManager.getNetworkImage", "-------savePath = " .. savePath);
        request:saveResponseData(savePath);
        self:onResponseImg(fileName);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end


function LiangYouActivity:onResponseImg(imgName)
    imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    self.m_pWidget:setVisible(true)
    if io.exists(imgName) then
        self.bg_Image:loadTexture(imgName);
        self.m_pBaseNode:setVisible(true)
    end
end

function LiangYouActivity:onCertainButton(Widget, EventType)
    if EventType == ccui.TouchEventType.ended then
        -- Log.i("去活动")
        self.m_data.parent:openAcitvityListView(self.m_data)
        UIManager:getInstance():popWnd(LiangYouActivity)
    end
end

function LiangYouActivity:reducedTime()
    local loadTime = cc.UserDefault:getInstance():getStringForKey("liangyou_new_user_time", 0)
    
    local socket = require "socket"
    local t = socket.gettime()
    local time = os.date("%Y%m%d%H",t)
    local year = os.date("%Y",t)
    local month = os.date("%m",t)
    local day = os.date("%d",t)
    cc.UserDefault:getInstance():setStringForKey("liangyou_new_user_time",string.format("%s_%s_%s",year,month,day))
    if loadTime == "0" then
        return true
    end
    local loadTable = Util.analyzeString_3(loadTime)
    -- Log.i("reducedTime...",t)
    local newTime = {year = year,month = month,day = day}
    local oldTime = {year = loadTable[1],month = loadTable[2],day = loadTable[3]}
    return self:leadTime(newTime,oldTime)
end

function LiangYouActivity:leadTime(newTime,oldTime)
    if tonumber(newTime.year) > tonumber(oldTime.year) then
        return true
    end
    if tonumber(newTime.month) > tonumber(oldTime.month) then
        return true
    end
    if tonumber(newTime.day) > tonumber(oldTime.day) then
        return
    end
    return false
end

function LiangYouActivity:onCloseButton(Widget, EventType)
    if EventType == ccui.TouchEventType.ended then
        UIManager:getInstance():popWnd(LiangYouActivity)
    end
end
return LiangYouActivity
