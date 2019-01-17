--朋友开房的玩家头像

FriendRoomPlayerHead = class("FriendRoomPlayerHead");

function FriendRoomPlayerHead:ctor(delegate, widget, data)
    self.m_delegate = delegate;
    self.m_pWidget = widget;
    self.m_data = data;
    self:initView();
    return self;
end

function FriendRoomPlayerHead:setUserID(id)
    self.userId = id
end


function FriendRoomPlayerHead:initView()
    self.headImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "headImg");
    self.playerName = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerName");
    self.leaveImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "leaveImg");
    self.speakingImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "speaking");
    local headFrame = ccui.Helper:seekWidgetByName(self.m_pWidget, "headframe")

    if kFriendRoomInfo:getGameType() == "gdpk" then
        local tmpData = kFriendRoomInfo:getSelectRoomInfo()
        if string.find(tmpData.wa,"duiyouzudui") then
            self.btnExchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange")
            self.btnExchange:addTouchEventListener(function(pWidget,EventType)
                if EventType == ccui.TouchEventType.ended then
                    if self.isReady then
                        Toast.getInstance():show("需要取消准备后，方可主动交换队伍")
                        return
                    end
                    if kFriendRoomInfo:getExchangeState() then
                        Toast.getInstance():show("玩家正在交换位置中")
                    else
                        local data = {
                            asUI = kUserInfo:getUserId(),
                            beAUI = self.userId,
                            ty = 1,
                            chST = true,
                            beAUS = self.m_data,
                        }
                        FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
                    end
                end
            end)
        end

        self.imgHasReady = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_has_ready")
        self.imgHasReady:setVisible(false)
    end

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

function FriendRoomPlayerHead:setBtnExchange(state)
    self.btnExchange:setVisible(state)
end

function FriendRoomPlayerHead:setReady(state)
    if self.imgHasReady then
        self.imgHasReady:setVisible(state)
    end
end

function FriendRoomPlayerHead:setUserReady(state)
    if state and state == 1 then
        self.isReady = true
    else
        self.isReady = false
    end
end


function FriendRoomPlayerHead:dtor()   
end