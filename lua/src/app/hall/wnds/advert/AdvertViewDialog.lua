--[[----------------------------------------
-- 作者： 林先成
-- 日期： 2018-01-16
-- 摘要： 广告弹出框
]]-------------------------------------------

local AdvertViewDialog = class("AdvertViewDialog", UIWndBase);

-- 功能:       构造方法
-- 返回:       无
function AdvertViewDialog:ctor(...)
    self.super.ctor(self, "hall/redPacket.csb", ...);
    Log.i("url:" ..self.m_data.url .. "       " .. "imageFileName:" .. self.m_data.imageFileName)
end

-- 功能:       初始化方法
-- 返回:       无
function AdvertViewDialog:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn");
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));

    self.midPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "midPanel");
    self.midPanel:addTouchEventListener(handler(self, self.onClickButton));

    self.bg =  ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
    if IsPortrait then -- TODO
        self.bg:setVisible(false)
    end
    self.bg:loadTexture(GC_GameHallRedpacketAdPath or _gameRedpacketAdPath);

    self:initBgTexture()
end

-- 功能:       初始化背景图片
-- 返回:       无
function AdvertViewDialog:initBgTexture()
    if IS_YINGYONGBAO then return end
    local imgName = self.m_data.imageFileName;
    if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgFile) then
            self.bg:loadTexture(imgFile);
            if IsPortrait then -- TODO
                LoadingView.getInstance():hide("AdvertView")
                self.bg:setVisible(true)
                self:updateWechatId()
            end
        else
            if IsPortrait then -- TODO
                LoadingView.getInstance():hide("AdvertView")
                LoadingView.getInstance():show("图片正在加载中...", nil, nil, "AdvertView",nil,nil,true)
            end
            HttpManager.getNetworkImage(self.m_data.url .. imgName, imgName);
        end
    end
end

if IsPortrait then -- TODO
    -- 功能:       刷新微信ID
    -- 返回:       无
    function AdvertViewDialog:updateWechatId(  )
        if tolua.isnull(self.bg) then return end
        local img_size = self.bg:getContentSize()
        local wechat_id ,wechat_id_2 = kUserData_userExtInfo:getAddWeChatID()

        if self.wechat_label then
            self.wechat_label:removeFromParent()
            self.wechat_label = nil
            self.wechat_label_1:removeFromParent()
            self.wechat_label_1 = nil
        end
        self.wechat_label =  cc.Label:createWithTTF(wechat_id, "hall/font/fangzhengcuyuan.TTF", 36)
        self.wechat_label:setPosition(cc.p(img_size.width * 0.5 - 140 , img_size.height* 0.5 - 160 ))
        self.wechat_label:setColor(cc.c3b(255,253,87))
        self.wechat_label:setAnchorPoint(cc.p(0.5, 0.5))

        self.wechat_label_1 =  cc.Label:createWithTTF(wechat_id_2, "hall/font/fangzhengcuyuan.TTF", 36)
        self.wechat_label_1:setPosition(cc.p(img_size.width * 0.5 - 140 , img_size.height* 0.5 - 230 ))
        self.wechat_label_1:setColor(cc.c3b(255,253,87))
        self.wechat_label_1:setAnchorPoint(cc.p(0.5, 0.5))

        self.bg:addChild(self.wechat_label_1, 1)
        self.bg:addChild(self.wechat_label, 1)
    end
end

-- 功能:       下载图片回调方法
-- 返回:       无
function AdvertViewDialog:onResponseNetImg(fileName)
    if not self.m_data.url or self.m_data.url == "" then return end
    Log.i("------AdvertViewDialog:onResponseNetImg fileName", fileName);
    local imgFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
    if io.exists(imgFile) then
        self.bg:loadTexture(imgFile);
        if IsPortrait then -- TODO
            LoadingView.getInstance():hide("AdvertView")
            self.bg:setVisible(true)
            self:updateWechatId()
        end
    end
end

-- 功能:       按钮点击回调
-- 返回:       无
function AdvertViewDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        UIManager:getInstance():popWnd(AdvertViewDialog);
    end
end

return AdvertViewDialog
