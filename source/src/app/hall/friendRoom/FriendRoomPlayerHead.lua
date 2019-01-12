--朋友开房的玩家头像

FriendRoomPlayerHead = class("FriendRoomPlayerHead");

function FriendRoomPlayerHead:ctor(delegate, widget, data)
    self.m_delegate = delegate;
    self.m_pWidget = widget;
    self.m_data = data;
    self:initView();
    return self;
end

function FriendRoomPlayerHead:initView()
    self.headImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "headImg");
    self.playerName = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerName");
    self.leaveImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "leaveImg");
    self.speakingImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "speaking");
    local headFrame = ccui.Helper:seekWidgetByName(self.m_pWidget, "headframe")

    if not IsPortrait then -- TODO
        local rootSize = self.m_pWidget:getContentSize()
        local headBg = cc.Sprite:create("hall/Common/head_bg.png")
        headBg:setPosition(cc.p(rootSize.width * 0.5 - 2, 10))
        headBg:setAnchorPoint(cc.p(0.5, 0))
        self.m_pWidget:addChild(headBg, 5)

        headFrame:setVisible(false)

        self.headImg:setScale(72 / self.headImg:getContentSize().width)
        self.headImg:setPosition(cc.p(rootSize.width * 0.5 - 2, 10))
        self.headImg:setAnchorPoint(cc.p(0.5, 0))

        local roomMain = ccui.Helper:seekWidgetByName(self.m_pWidget, "room_main")
        roomMain:setPosition(cc.p(rootSize.width * 0.5 - 2, rootSize.height + 10))
        roomMain:setAnchorPoint(cc.p(0.5, 1))

        self.headImg:setVisible(false);
        self.playerName:setVisible(false);
        self.leaveImg:setVisible(false);
    end
end

function FriendRoomPlayerHead:getHeadImg()
    return  self.headImg;  
end

function FriendRoomPlayerHead:getPlayerName()
    return  self.playerName;  
end

function FriendRoomPlayerHead:getLeaveImg()
    return  self.leaveImg;  
end

--显示正在说话
function FriendRoomPlayerHead:showSpeaking()
    self.speakingImg:stopAllActions();
    self.speakingImg:setVisible(true);
    self.speaking_img_index = 1;
    self.speakingImg:loadTexture("hall/friendRoom/speaking_" .. self.speaking_img_index .. ".png");
    self.speakingImg:performWithDelay(function ()
            self:updateSpeakingImg();
        end, 0.1);

    --防止没有收到播放结束回调
    self.m_pWidget:stopAllActions();
    self.m_pWidget:performWithDelay(function ()
            self:hideSpeaking();
    end, 60);
end

function FriendRoomPlayerHead:updateSpeakingImg()
    self.speaking_img_index = self.speaking_img_index + 1;
    if self.speaking_img_index >= 4 then
        self.speaking_img_index = 1;
    end
    self.speakingImg:loadTexture("hall/friendRoom/speaking_" .. self.speaking_img_index .. ".png");
    self.speakingImg:performWithDelay(function ()
            self:updateSpeakingImg();
        end, 0.2);
end

--隐藏正在说话
function FriendRoomPlayerHead:hideSpeaking()
    self.speakingImg:setVisible(false);
    self.speakingImg:stopAllActions();
    self.m_pWidget:stopAllActions();
end

function FriendRoomPlayerHead:dtor()   
end