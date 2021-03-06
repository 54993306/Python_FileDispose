-------------------------------------------------------------
--  @file   FriendRoomScene.lua
--  @brief  准备界面
--  @author ZCQ
--  @DateTime:2017-02-28 10:44:13
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
--============================================================
local Deque = require("app.hall.common.Deque")
local Define        = require "app.games.common.Define"
local ShareToWX = require "app.hall.common.ShareToWX"
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local BackEndStatistics = require("app.common.BackEndStatistics")
local UmengClickEvent = require("app.common.UmengClickEvent")
local choiceShare = require("app.hall.common.share.choiceShare")

local fun = {}

local kPersonInfos =
{
    {},
    {1, 2},
    {1, 2, 3},
    {1, 2, 3, 4}
}

local kRuleWidth = 320 -- 规则文字宽度
local kRuleFontSize = 16 -- 规则字体大小
--房间UI
FriendRoomScene = class("FriendRoomScene", UIWndBase)

function FriendRoomScene:ctor(data)
    Log.i("--wangzhi--GDFriendRoomScene--")
    self.super.ctor(self.super, "package_res/games/guandan/hall/friendRoomScene.csb", data)
    self.m_sayQueue = Deque.new();
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    --有人正在说话

    local selectSetInfo =kFriendRoomInfo:getRoomInfo()
    self.roomData = selectSetInfo
    self.m_userIds = {}
    self.m_speaking = false;
    self.m_speakTable = {};
    self.m_headImage = {}
    self.m_headIndex = {}
end

function FriendRoomScene:onClose()
    self:stopCountDown(false)
    CountDownData = nil
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end

    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end

    self:closeEditBox()

    --如果打开聊天ui。退出当前UI时，要关闭。
    if(self.m_chatView ~= nil)then
       UIManager.getInstance():popWnd(RoomChatView)
       self.m_chatView = nil
    end

    --是否有打开退出房间提示框
    if(UIManager.getInstance():getWnd(CommonDialog)~=nil) then
       UIManager.getInstance():popWnd(CommonDialog)
    end

end
function FriendRoomScene:closeEditBox()
    local data = {};
    data.cmd = NativeCall.CMD_CLOSEEDITBOX;
    NativeCall.getInstance():callNative(data);
end

function FriendRoomScene:onInit()
    self.m_roomInfo = kFriendRoomInfo:getRoomInfo()

    if not self.roomData or  not self.roomData.plS then
        self:showDialog(self.roomData)
        return
    end

    --退出房间
    self.btnDissmiss = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_dissmiss");
    self.btnDissmiss:addTouchEventListener(handler(self, self.onCloseRoomButton));

    self.shade_panel = ccui.Helper:seekWidgetByName(self.m_pWidget, "shade_panel");
    self.shade_panel:setVisible(false)

    self.chatBtn    = ccui.Helper:seekWidgetByName(self.m_pWidget, "chat_btn");
    self.chatBtn:addTouchEventListener(handler(self, self.onMsgButton));

    self.beginSayBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "beginSayBtn");
    self.beginSayBtn:setVisible(true)
    self.beginSayBtn:addTouchEventListener(handler(self, self.onTouchSayButton));

    self.img_mic = ccui.Helper:seekWidgetByName(self.m_pWidget, "mic");

    --玩法按钮
    self.btn_wanfa = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_wanfa");
    self.btn_wanfa:addTouchEventListener(handler(self, self.onClickButton));

    --对话
    self.sayListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "sayListView");
    self.sayListView:removeAllChildren();

    self.input = ccui.Helper:seekWidgetByName(self.m_pWidget, "input_text");
    self.input_text= self:setTextFieldToEditBox(self.input)
    self.input_text:registerScriptEditBoxHandler(handler(self,self.onEdit));
    if self.input_text.setInputMode then self.input_text:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE) end

    --别人的对话框
    self.itemOther = ccui.Helper:seekWidgetByName(self.m_pWidget, "talk_other")
    self.itemOther:setVisible(false)
     --我的对话框
    self.itemMe = ccui.Helper:seekWidgetByName(self.m_pWidget, "talk_me")
    self.itemMe:setVisible(false)

    self.turnBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_turn")
    self.turnBtn.talkstate = false
    self.turnBtn:addTouchEventListener(handler(self,self.onClickButton))

    self.inputPanel = ccui.Helper:seekWidgetByName(self.m_pWidget,"input_panel")
    self.inputPanel:setVisible(false)

    self.roomName = ccui.Helper:seekWidgetByName(self.m_pWidget,"txt_room_name")

    local panelRoomRandom = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_room_random")
    local panelRoomTeam = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_room_team")
    local roomParent = panelRoomRandom
    local tmpData = kFriendRoomInfo:getSelectRoomInfo()
    self.isOrganizeTeam = false
    if string.find(tmpData.wa,"duiyouzudui") then
        self.isOrganizeTeam = true
        roomParent = panelRoomTeam
        panelRoomTeam:setVisible(true)
        panelRoomRandom:setVisible(false)
    else
        panelRoomTeam:setVisible(false)
        panelRoomRandom:setVisible(true)
    end

    --准备按钮
    self.btnReady = ccui.Helper:seekWidgetByName(roomParent, "btn_ready")
    self.btnReady:addTouchEventListener(handler(self, self.onClickButton))

    local packetInfo = kFriendRoomInfo:getRoomInfo()
    kFriendRoomInfo:setExchangeState(false)
    if packetInfo.ExR == 2 then
        packetInfo.reconnect = true

        self.m_pWidget:performWithDelay(function()
            if not tolua.isnull(self.m_pWidget) then
                if packetInfo.CoD <= 0 and packetInfo.asUI then
                    if packetInfo.asUI == kUserInfo:getUserId() then
                        local data = {
                            asUI = packetInfo.asUI,
                            beAUI = packetInfo.beAUI,
                            ty = 1,
                            chST = false,
                        }
                        FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
                    else
                        --拒绝
                        local data = {
                            asUI = packetInfo.asUI,
                            beAUI = packetInfo.beAUI,
                            ty = 2,
                            chST = false,
                        }
                        FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
                    end
                    return
                end
                if packetInfo.CoD == 0 then
                    self:stopCountDown(true)
                else
                    kFriendRoomInfo:setExchangeState(true)
                    if CountDownData and CountDownData.clockHandle then
                        scheduler.unscheduleGlobal(CountDownData.clockHandle)
                        CountDownData.clockHandle = nil
                    end
                    CountDownData = {}
                    CountDownData.packetInfo = packetInfo
                    CountDownData.time = packetInfo.CoD
                    self:startCountDown(packetInfo.CoD)
                    UIManager.getInstance():pushWnd(ExchangeSeatTips, packetInfo)
                end
            end
        end, 0.1)
    end

     --微信邀请
    self.shardBtn = ccui.Helper:seekWidgetByName(roomParent, "btn_share");
    self.shardBtn:addTouchEventListener(handler(self, self.onClickButton));
    if IS_YINGYONGBAO then --如果是应用宝审核宝，关闭微信分享按钮
        self.shardBtn:setVisible(false)
    end
    self.m_playerHeadList  = {};
    self.playerPanel       = {}
    self.originalPosX      = {} --原始X点
    self.originalPosY      = {} --原始Y点

    for i = 1, 4 do
        local strName = "playerHeadPanel_".. i
        local p = ccui.Helper:seekWidgetByName(roomParent, strName)
        p:setVisible(false)
    end

    -- 根据这个table来获取需要处理的头像对象是哪些
    local personSites = (self.roomData and self.roomData.plS > 1 and self.roomData.plS <= 4) and kPersonInfos[self.roomData.plS] or kPersonInfos[4]
    for i = 1, #personSites do
        local strName = "playerHeadPanel_".. personSites[i]
        self.playerPanel[i] = ccui.Helper:seekWidgetByName(roomParent, strName)
        self.playerPanel[i]:setLocalZOrder(3)
        -- 保存原始位置，后面需要移位
        table.insert(self.originalPosX, self.playerPanel[i]:getPositionX())
        table.insert(self.originalPosY, self.playerPanel[i]:getPositionY())

        self.m_playerHeadList[i] = FriendRoomPlayerHead.new(self, self.playerPanel[i], i);
        if _isPositionVisible ~= false then
            self.playerPanel[i]:addTouchEventListener(handler(self, self.onClickPVButton));
        end
        self.playerPanel[i]:setVisible(true)
        -- 设置用户id
        self:setPlayerId(i, 0)
    end

    --头像下的交换说明
    self.panelExchangeDesc = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_exchange_desc")

    local userID =kUserInfo:getUserId()
    local isRoom = kFriendRoomInfo:isRoomMain(userID)
    if(isRoom) and kFriendRoomInfo:getRoomInfo().teI == 0 then--如果是房主
    -- if(isRoom) then--如果是房主
        self.btnDissmiss:setTitleText("解散房间")
    else
        self.btnDissmiss:setTitleText("退出房间")
    end

    self:updateUI()

    --
    if self.m_data and self.m_data.newerType then
        self.m_NewerType = self.m_data.newerType;
        self:showNewer();
    end

    local playerNum = kFriendRoomInfo:getRoomPlayerNum()
    if playerNum < self.roomData.plS then
        -- 进入邀请房时人数未满获取一次定位
        NativeCall.getInstance():callNative({cmd = NativeCall.CMD_LOCATION}, function(info)
            local tmpData = {}
            tmpData.jiD = info.longitude
            tmpData.weD = info.latitude
            SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOCATION, tmpData);
        end)
    end
end

function FriendRoomScene:showDialog(tmpData)
    local data = {}
    data.type = 2;
    data.textSize = 30
    data.title = "提示";
    data.yesStr = "是"
    data.cancalStr = "联系客服"
    data.content = string.format("您的房间信息异常，您已在房间%s内登陆，是否重新登陆恢复。",(tmpData and tmpData.roI) and tmpData.roI or "");
    data.subjoin = string.format( "您的游戏id为%s",kUserInfo:getUserId())
    data.handle = "(复制)"
    data.yesCallback = function()
        -- MyAppInstance:exit()
        SocketManager.getInstance():closeSocket()
        local info = {};
        info.isExit = true;
        UIManager.getInstance():replaceWnd(HallLogin, info);
        SocketManager.getInstance():openSocket()
    end
    data.cancalCallback = function ()
        self:onOpenKf()
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
    LoadingView.getInstance():hide()
end
function FriendRoomScene:onOpenKf()
    local data = {};
    data.cmd = NativeCall.CMD_KE_FU;
    data.uid, data.uname = self.getKfUserInfo()
    NativeCall.getInstance():callNative(data, self.kefuCallBack, self)

end
function FriendRoomScene:kefuCallBack(result)
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = result
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function FriendRoomScene:getKfUserInfo()
    local uid = kUserInfo:getUserId();
    local uname = kUserInfo:getUserName();
    if uid == 0 then
        local lastAccount = kLoginInfo:getLastAccount();
        if lastAccount and lastAccount.usi then
            uid = lastAccount.usi
        end
    end

    if uname == "" or uname == nil then
        if uid == nil or uid == 0 then
            uname = "游客"
        else
            uname = "游客"..uid
        end
    end

    --此时uid需要传入字符串类型.否则ios那边解析会出问题.
    return ""..uid, uname
end
function FriendRoomScene:setTextFieldToEditBox(textfield)
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
   local imageNormal = display.newScale9Sprite("hall/Common/blank.png")

   local editbox = ccui.EditBox:create(cc.size(tfS.width,tfS.height), imageNormal)
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

function FriendRoomScene:onEdit(event,pWidget)
    if event == "began" then
        self.shade_panel:setVisible(true)
        NativeCallUmengEvent(UmengClickEvent.GameWaitInputText)
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        Log.i("changed","changed");
    elseif event == "ended" then
        -- 输入结束
        --self.shade_panel:setVisible(false)
        --计算输入的字符数
    elseif event == "return" then
        -- 从输入框返回
        transition.execute(self.shade_panel,cc.DelayTime:create(0.2),{onComplete = function( )
            self.shade_panel:setVisible(false)
        end})
    end
end

function FriendRoomScene:onClickPVButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", false);
        if pWidget == self.playerPanel[1] then
            self:setPlayersPos(1)
        elseif pWidget == self.playerPanel[2] then
            self:setPlayersPos(2)
        elseif pWidget == self.playerPanel[3] then
            self:setPlayersPos(3)
        elseif pWidget == self.playerPanel[4] then
            self:setPlayersPos(4)
        end
    end
end

function FriendRoomScene:setPlayersPos(index)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local userID =playerInfos.owI
    local players = playerInfos.pl
    local other = {}
    local jindu = nil
    local weidu = nil
    local ipA = nil
    local usrID = nil
    local wType = 1
    local headImage = nil
    local name = nil
    for i=1,#players do
        --Log.i("i.....",i,userID,players[i])
        if players[i].we == index then
            jindu = players[i].jiD
            weidu = players[i].weD
            ipA = players[i].ipA
            wType = 1
            usrID = players[i].usI
            headImage = self.m_headImage[index]
            name = players[i].niN
        else
            if other[i] == nil then
                other[i] = {}
            end
            other[i].lo =players[i].jiD
            other[i].la = players[i].weD
            other[i].name = players[i].niN
        end
    end
    if ipA then
        local data = {type = wType,playerHeadImage = headImage,playerName = name,playerIP = ipA, playerID = usrID, lo = jindu,la = weidu,site = other}
        self.infoView = UIManager:getInstance():pushWnd(PlayerPosInfoWnd, data);
        self.infoView:setDelegate(self);
    end
end


function FriendRoomScene:onMsgButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then
            MjProxy:getInstance():get_gameChatTxtCfg()
        end
        local text=self.input_text:getText()
        if text and text ~= "" then
            self:sendUserChat(text)
            self.input_text:setText("")
        else
            Toast.getInstance():show("请输入聊天内容")
        end
        SoundManager.playEffect("btn", false);
        NativeCallUmengEvent(UmengClickEvent.GameWaitSendMsg)
        Log.i("--wangzhi--点击发送按钮--")
    end
end

--[[
-- @brief  发送自定文字
-- @param  void
-- @return void
--]]
function FriendRoomScene:sendUserChat(content)
    local data  = {}
    data.usI    = MjProxy:getInstance():getMyUserId()
    data.roI    = kFriendRoomInfo:getRoomInfo().pa
    data.co     = content
    data.ty     = enChatType.DEFAULT
    data.niN    = kUserInfo:getUserName()
    SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG, data);
end

function FriendRoomScene:recvChatMsg2(chatData)
    Log.i("chatData....", chatData)
    -- 1为语音聊天
    if chatData.ty == 1 then
        if chatData.co then
            local status = kSettingInfo:getPlayerVoiceStatus()
            if status and chatData.usI ~= kUserInfo:getUserId() then
               Log.i("关闭玩家语音。。。。。。。。");
            else
                self:showSpeaking(chatData);
            end
        end
    else
        self:insertSayText(chatData);
    end
end

function FriendRoomScene:onSayButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.sayBtn then
            self.sendPanel:setVisible(true);
            self.soundPanel:setVisible(false);
        end
    end
end

function FriendRoomScene:onTouchSayButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.began then
        if not self.m_isTouching then
            self.m_isTouchBegan = true;
            --开始录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data);
            self:showMic();
            -- self.beginSayTxt:setString("松开 发送");
            NativeCallUmengEvent(UmengClickEvent.GameWaitVoice)
        end

    elseif EventType == ccui.TouchEventType.ended then
        if self.m_isTouchBegan then
            --停止录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 1;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            -- self.beginSayTxt:setString("按住 说话");

            if YY_IS_LOGIN then
                self:getUploadStatus();
            else
                Toast.getInstance():show("功能未初始化完成，请稍后");
            end

            self.m_isTouchBegan = false;
            self.m_isTouching = true;
            self.m_pWidget:performWithDelay(function ()
                self.m_isTouching = false;
            end, 0.5);
        end

    elseif EventType == ccui.TouchEventType.canceled then
        if  self.m_isTouchBegan then
            --停止录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 0;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            -- self.beginSayTxt:setString("按住 说话");

            self.m_isTouchBegan = false;
        end
    end
end

function FriendRoomScene:showMic()
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function FriendRoomScene:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("hall/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function FriendRoomScene:hideMic()
    self.img_mic:setVisible(false);
    self.img_mic:stopAllActions();
end


function FriendRoomScene:onClickSoundButton(pWidget, EventType)
  if EventType == ccui.TouchEventType.ended then
    if pWidget == self.soundBtn then
        self.sendPanel:setVisible(false);
        self.soundPanel:setVisible(true);
    end
  end
end

function FriendRoomScene:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", false);
        if pWidget == self.btn_sure then
            UIManager:getInstance():pushWnd(FriendRoomEnterInfo);
        elseif(pWidget == self.chatBtn) then --发送消息
            local sayTextField = self.sayTextField:getText();
            if sayTextField == nil or sayTextField == "" then
                Toast.getInstance():show("请输入聊天内容")
                return
            end
        elseif(pWidget == self.redPackBtn) then--红包
            UIManager:getInstance():pushWnd(FriendRoomRedPacket);
        elseif pWidget == self.btn_wanfa then--玩法
            UIManager:getInstance():pushWnd(FriendRoomEnterInfo);
            NativeCallUmengEvent(UmengClickEvent.GameCurPlayRule)
        elseif pWidget == self.dxBtn then

        elseif pWidget ==  self.shardBtn then
            local shareToWechat = function()
                Util.disableNodeTouchWithinTime(pWidget)
                local data = {}
                data.wa = BackEndStatistics.RoomInviteWXFriend
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
                self:onWxLogic(2)
            end
            local data = {}
            data.shareToWechat = shareToWechat
            data.type = "room" -- 房间等待界面的分享
            UIManager.getInstance():pushWnd(choiceShare, data)
        elseif pWidget == self.frientBtn then
            Util.disableNodeTouchWithinTime(pWidget)
            self:onWxLogic(1)
        elseif pWidget == self.turnBtn then
            local turnimg = ccui.Helper:seekWidgetByName(self.turnBtn,"img")
            if self.turnBtn.talkstate then
                turnimg:loadTexture("hall/huanpi2/friendroomscene/keyboard.png")
                self.turnBtn.talkstate = false
                self.inputPanel:setVisible(false)
                self.beginSayBtn:setVisible(true)
            else
                turnimg:loadTexture("hall/huanpi2/friendroomscene/mic.png")
                self.turnBtn.talkstate = true
                self.inputPanel:setVisible(true)
                self.beginSayBtn:setVisible(false)
            end
            NativeCallUmengEvent(UmengClickEvent.GameWaitChangeMode)
        elseif pWidget == self.copyBtn then

            local data = {};
            data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
            data.content  = string.format("%d",self.m_roomInfo.pa)--
            Log.i("copy code:" .. data.content)
            NativeCall.getInstance():callNative(data);
            Toast.getInstance():show("复制成功");
        elseif pWidget == self.wenHaoBtn then
            local data = {};
            data.title = "客服问题";
            data.content = friendRoomContent
            LoadingView.getInstance():show("正在加载中", 2);
            self.m_pWidget:performWithDelay(function()
              UIManager.getInstance():pushWnd(CommonTipsDialog, data)
              LoadingView.getInstance():hide()
            end, 0.1);
        elseif pWidget == self.btnReady then
            FriendRoomSocketProcesser.sendRoomReady()
        end
    end
end

--新手
function FriendRoomScene:showNewer()
    if not self.m_pan_newer then
        self.m_pan_newer = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_newer");
        self.btn_newer_over = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_over");
        -- if self.m_NewerType == 1 then
        --     self.btn_newer_over:setVisible(false);
        -- end
        self.btn_newer_enter = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn");
        self.btn_newer_over:addTouchEventListener(handler(self,self.onClickButtonNewer));
        self.btn_newer_enter:addTouchEventListener(handler(self,self.onClickButtonNewer));
        self.btn_newer_enter1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn_1");
        self.btn_newer_enter1:addTouchEventListener(handler(self,self.onClickButtonNewer));

        --手指动画
        local img_point = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_point");
        img_point:stopAllActions();
        local sequence = transition.sequence({
                     cc.MoveBy:create(0.3, cc.p(15, 0)),
                     cc.MoveBy:create(0.3, cc.p(-15, 0))
        });
        img_point:runAction(cc.RepeatForever:create(sequence));
    end
    self.m_pan_newer:setVisible(true);
end

function FriendRoomScene:onClickButtonNewer(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_newer_over then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
            end
            --退出房间
            local tmpData={}
            tmpData.usI= kUserInfo:getUserId()
            FriendRoomSocketProcesser.sendRoomQuit(tmpData)
        elseif pWidget == self.btn_newer_enter then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
                self:onWxLogic(2);
            end
        elseif pWidget == self.btn_newer_enter1 then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
                self:onCloseRoom();
            end
        end
    end
end

function FriendRoomScene:createRuleTip(ruleStr)
    local bg = ccui.Scale9Sprite:create(cc.rect(10, 10, 5, 5), "hall/Common/name_scale_bg.png")

    local ruleText = cc.Label:createWithTTF(ruleStr, "hall/font/fangzhengcuyuan.TTF", kRuleFontSize)
    -- ruleText:setAnchorPoint(cc.p(0.5, 0.5))
    ruleText:setColor(cc.c3b(0xb1, 0xcc, 0xa3))
    ruleText:setWidth(kRuleWidth)
    ruleText:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    ruleText:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    bg:addChild(ruleText)
    local size = ruleText:getContentSize()
    size.width = size.width + 10
    size.height = size.height + 2
    bg:setContentSize(size)
    ruleText:setPosition(cc.p(size.width * 0.5, size.height * 0.5))

    return bg
end

function FriendRoomScene:updateUI()
    local roomInfo      = kFriendRoomInfo:getRoomBaseInfo()
    local playerInfos   = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo = kFriendRoomInfo:getSelectRoomInfo();
    -- local playingInfo   = kFriendRoomInfo:getPlayingInfo()

    --房间号
    local roomNumberLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_room_number");
    roomNumberLabel:setFontName("hall/font/fangzhengcuyuan.TTF")
    -- roomNumberLabel:setString(string.format("房间号:%d", playerInfos.pa));

    local roomNum = cc.Label:createWithBMFont("hall/huanpi2/friendroomscene/num_room.fnt",playerInfos.pa)
    roomNum:setPosition(cc.p(roomNumberLabel:getContentSize().width + roomNum:getContentSize().width/2 + 15,roomNumberLabel:getContentSize().height / 2))
    roomNumberLabel:addChild(roomNum)

    if playerInfos.clI == 0 then
        local str = ToolKit.subUtfStrByCn(playerInfos.owN, 0, 8, "...")
        self.roomName:setString(str.."的房间")
    else
        local str = ToolKit.subUtfStrByCn(playerInfos.clN, 0, 8, "...")
        self.roomName:setString(str or "" .. "的亲友圈")
    end
    self:playerListViewUpdate();

    local copyBtnLayout = ccui.Layout:create()
    -- local copyBtnLayout = display.newColorLayer(cc.c4b(100,100,100,255))
    copyBtnLayout:setContentSize(cc.size(200,50))
    roomNumberLabel:addChild(copyBtnLayout)
    copyBtnLayout:setPosition(cc.p(roomNumberLabel:getContentSize().width + roomNum:getContentSize().width + 15,
                                    -roomNumberLabel:getContentSize().height / 2 + copyBtnLayout:getContentSize().height/2 - 5))

    local copyRoomId = cc.Label:create()
    copyRoomId:setString("(复制房间号)")
    copyRoomId:setSystemFontSize(28)
    copyRoomId:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomId:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2))
    copyBtnLayout:addChild(copyRoomId)

    copyBtnLayout:setTouchEnabled(true)
    copyBtnLayout:setTouchSwallowEnabled(true)
    copyBtnLayout:addTouchEventListener(handler(self,self.onLabelClickButton));

    local copyRoomIdLine = cc.Label:create()
    copyRoomIdLine:setString("——————")
    copyRoomIdLine:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomIdLine:setSystemFontSize(28)
    copyRoomIdLine:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2 - 20))
    copyBtnLayout:addChild(copyRoomIdLine)
end

function FriendRoomScene:onCloseRoomButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", false);
        if self.isReady and self.isReady == 1 then
            Toast.getInstance():show("需要取消准备后，才可点击退出/解散房间")
            do return end
        end
        NativeCallUmengEvent(UmengClickEvent.GameDissmissRoom)
        self:onCloseRoom();
    end
end

function FriendRoomScene:onLabelClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        Log.i("onLabelClickButton........")
        local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
        local playerInfo = kFriendRoomInfo:getRoomInfo();
        -- local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
        --22005的付费字段 人数字段有误，用22006的
        --因为getWxShareInfo是地方组自己写的，所以在这里把RoJST进行赋值
        -- selectSetInfo.RoJST = playerInfo.RoJST
        -- selectSetInfo.plS = playerInfo.plS
        -- selectSetInfo.clI = playerInfo.clI  --俱樂部id

        -- local title, desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)

        local content = string.format( "【%s】%d",roomInfo.description,playerInfo.roI)

        local data = {};
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
        data.content  = content--string.format( "%s%s",title,desc )
        -- Log.i("copy code:" .. data)
        NativeCall.getInstance():callNative(data);
        Toast.getInstance():show("复制成功");
        NativeCallUmengEvent(UmengClickEvent.GameCopyRoomInfo)
    end
end

function FriendRoomScene:onCloseRoom()
    local data = {}
    data.type = 2;
    data.title = "提示";
    data.yesTitle  = "确定";
    data.cancelTitle = "取消";

    local userID = kUserInfo:getUserId()
    local isRoom = kFriendRoomInfo:isRoomMain(userID)
    -- if isRoom then--如果是房主
    if(isRoom) and kFriendRoomInfo:getRoomInfo().teI == 0 then--如果是房主
        data.content = "您是否要解散房间?"
    else
        data.content = "退出房间后如本房间仍有座位可重新进入房间!"
    end

    data.yesCallback = function()
        local tmpData={}
        tmpData.usI= kUserInfo:getUserId()
        FriendRoomSocketProcesser.sendRoomQuit(tmpData)
    end

    UIManager.getInstance():pushWnd(CommonDialog, data);
end

--微信
function FriendRoomScene:onWxLogic(shardType)

    local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
    local playerInfo = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
    --22005的付费字段 人数字段有误，用22006的
    --因为getWxShareInfo是地方组自己写的，所以在这里把RoJST进行赋值
    selectSetInfo.RoJST = playerInfo.RoJST
    selectSetInfo.plS = playerInfo.plS
    selectSetInfo.clI = playerInfo.clI  --俱樂部id

    local data = {};
    Log.i("--wangzhi--roomInfo, playerInfo, selectSetInfo--",roomInfo)
    data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)

    data.cmd = NativeCall.CMD_WECHAT_SHARE;
    -- 获取需要传到PHP的信息
    local magicWindowUrl = getMagicWindowUrl(roomInfo, playerInfo, selectSetInfo)

    local i, j = string.find(roomInfo.shareLink, "pkgname");
    if i and i > 0 then
        --应用宝地址直接使用
        data.url = roomInfo.shareLink;
    else
        --拼上房间号，用于直接进入房间
        -- data.url = roomInfo.shareLink .. "&code=" .. playerInfo.pa;

        -- if device.platform == "ios" then
        --     local subStrLength = string.find(roomInfo.shareLink, "?")
        --     local ioShareLink = string.sub( roomInfo.shareLink, 1,subStrLength )
        --     local iosUrl=ioShareLink .."open="..roomInfo.iosOpenurl.. CONFIG_GAEMID.."?code=" .. playerInfo.pa.. "&url="..roomInfo.iosurl..magicWindowUrl
        --     data.url = iosUrl
        -- else
        --     if roomInfo.landingPage ==nil  then
        --         roomInfo.landingPage=""
        --     end
        --     local socket = require("socket")
        --     local subStrLength = string.find(roomInfo.shareLink, "?")
        --     data.url = string.sub( roomInfo.shareLink, 1,subStrLength ) .. "gameID=".. GC_GameTypes[CONFIG_GAEMID] .. "&code=" .. playerInfo.pa .. "&time=".. socket:gettime()*10000 .."&url="..roomInfo.landingPage.."?".."gameId="..PRODUCT_ID..magicWindowUrl;
        -- end
        local shareType = ShareToWX.PaijuShareFriend
        if roomInfo.iosOpenurl and roomInfo.iosurl and roomInfo.landingPage then
            local subStrLength = string.find(roomInfo.shareLink, "?")
            local phpUrl = string.sub( roomInfo.shareLink, 1,subStrLength )
            -- local iosOpen = "iosOpen="..roomInfo.iosOpenurl.. CONFIG_GAEMID.."?code=" .. playerInfo.pa
            local iosOpen = "iosOpen="..WX_APP_ID.."://"
            local androidOpen = "gameID=".. MAGIC_WINDOWS_APP_NAME .. "&code=" .. playerInfo.pa .. "&time=".. socket:gettime()*10000
            local iosUrl = "iosUrl="..roomInfo.iosurl
            local androidUrl = "androidUrl="..roomInfo.landingPage.."?".."gameId="..PRODUCT_ID
            data.url=phpUrl..androidOpen.."&"..iosOpen.."&"..iosUrl.."&"..androidUrl..magicWindowUrl..shareType
        else
            data.url = roomInfo.shareLink .. "&code=" .. playerInfo.pa..shareType;
        end

        Log.i("--wangzhi--data.url--",data.url)
    end

    if(shardType==1) then
       data.type = 1--分享到朋友圈
    elseif(shardType==2) then
       data.type = 2--分享给朋友
    end

    data.headUrl = kUserInfo:getHeadImgSmall();

    LoadingView.getInstance():show("正在分享,请稍后...", 2);
    if data.headUrl and data.headUrl ~= "" then
        HttpManager.testUrlConnect(data.headUrl,
            function(event, code)
                Log.i("FriendRoomScene:onWxLogic testUrlConnect", event, code)
                if code ~= 200 then
                    data.headUrl = ""
                end
                self:shareToWx(data)
            end,
            3)
    else
        self:shareToWx(data)
    end
end

function FriendRoomScene:shareToWx(data)
    Log.i("--wangzhi--data--",data)
    Log.i(string.format("分享标题:") ..  data.title .. "/r/n 分享描述:" .. data.desc .. "/r/n 分享网址:" .. data.url .. "/r/n 分享头像:" .. data.headUrl);
    -- TouchCaptureView.getInstance():showWithTime()
    local callBack = function(info)
        Log.i("shard button:",info);
        LoadingView.getInstance():hide();
        if(info.errCode ==0) then --成功
            local data = {}
            data.wa = 3
            Log.i("--wangzhi--roomSharedata--",data)
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif (info.errCode == -8) then
            self.m_pWidget:performWithDelay(function()
                Toast.getInstance():show("您手机未安装微信");
            end, 0.1);
        else
            self.m_pWidget:performWithDelay(function()
                Toast.getInstance():show("邀请失败");
            end, 0.1);
        end
    end

    data.shareLink = data.url -- 兼容老苹果包的分享

    LoadingView.getInstance():show("正在分享,请稍后...", 2)
    WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.FRIEND_ROOM_FRIEND, callBack, ShareToWX.PaijuShareFriend, data)

    local data = {}
    data.wa = BackEndStatistics.RoomInviteWXFriend
    SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
end

--满足开局条件，开始游戏
function FriendRoomScene:recvFriendRoomStartGame(packetInfo)
    Log.i("------满足开局条件，开始游戏");
    UIManager:getInstance():popWnd(FriendRoomScene);
    kGameManager:enterFriendRoomGame(packetInfo);
end

--邀请房信息
function FriendRoomScene:recvRoomSceneInfo(packetInfo)
    self:playerListViewUpdate();
    if packetInfo.asUI == 0 then
        self:stopCountDown(false)
    end
end

function FriendRoomScene:roomPlayerChange(players)
    if not self.hasPlayer then
        self.hasPlayer = {}   -- 房间中已经存在的玩家信息
        for _,player in pairs(players) do
            table.insert(self.hasPlayer,player)
        end
    end
    if players and #players > #self.hasPlayer then
        -- 表示新增玩家
        for _,player in pairs(players) do
            for __ , _player in pairs(self.hasPlayer) do
                if player.usI ~= _player.usi and player.we ~= 1 then
                    table.insert(self.hasPlayer,player)
                    fun.playerEnterRoom(self,player,true)
                    return
                end
            end
        end
    else
        -- 表示玩家退出
        for index,player in pairs(self.hasPlayer) do
            for __,_player in pairs(players) do
               if player.usI ~= _player.usI then
                    if player.we ~= 1 then
                        fun.playerEnterRoom(self,player,false)
                    end
                    table.remove(self.hasPlayer,index)
                    return
               end
            end
        end
    end
end

-- ["weD"] = 0;
-- ["heI"] = headURL
-- ["usI"] = 17319777;
-- ["niN"] = user3;
-- ["we"] = 2;
-- ["sc"] = 0;
-- ["jiD"] = 0;
-- ["st"] = 0;
-- ["ti"] = 无称号;
-- ["ipA"] = 119.137.33.32;
-- ["caCV"] = 0;
-- ["le"] = 0;
-- ["ra"] = 2;
fun.playerEnterRoom = function(self,playerInfo,isEnter)
    local data = {}
    data.niN = "系统"
    data.usI = playerInfo.usI
    if isEnter then
        data.co = "玩家 [ " .. playerInfo.niN .. " ] 进入房间"
        -- self:insertSayText(data,cc.c3b(0,255,0))
    else
        data.co = "玩家 [ " .. playerInfo.niN .. " ] 离开房间"
        -- self:insertSayText(data,cc.c3b(255,0,0))
    end
end

function FriendRoomScene:updateTeamDesc(index)
    local originMargin_start = self.panelExchangeDesc:getLayoutParameter():getMargin()
    if index <= 2 then
        originMargin_start.left = 63
    else
        originMargin_start.left = 450
    end
    --交换按钮是否可见
    local playerInfos = kFriendRoomInfo:getRoomInfo()
    local totalPlayer = #playerInfos.pl
    for i=1,4 do
        local changeBtnVisible = false
        if (index <= 2 and i > 2)
            or (index > 2 and i <= 2) then
            changeBtnVisible = true
        end
        if self.playerPanel[i] then
            self.playerPanel[i]:getChildByName("btn_exchange"):setVisible(changeBtnVisible)
        end
    end
    self.panelExchangeDesc:getLayoutParameter():setMargin(originMargin_start)
    self.panelExchangeDesc:getParent():requestDoLayout()
end

--更新玩家信息
function FriendRoomScene:playerListViewUpdate()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    self:roomPlayerChange(playerInfos.pl)
    -- self:resetMySelfPosition(playerInfos);

    for i = 1, #self.m_playerHeadList do
        local  headImg = self.m_playerHeadList[i]:getHeadImg();
        local  playerName = self.m_playerHeadList[i]:getPlayerName();
        local  leaveImg = self.m_playerHeadList[i]:getLeaveImg();
        local ower = ccui.Helper:seekWidgetByName(self.playerPanel[i], "room_main")
        ower:setVisible(false)
        leaveImg:setLocalZOrder(10)
        local  playerInfo = nil;
        for k, v in pairs(playerInfos.pl) do
            if v.we == i then
                playerInfo = v;
                break;
            end
        end
        local headFile = "hall/huanpi2/Common/defaultCircleHead.png";
        if playerInfo then
            -- Log.i("------playerInfo", playerInfo);
            if playerInfo.usI==playerInfos.owI then
                ower:setVisible(true)
            end

            --掼蛋处理
            if kFriendRoomInfo:getGameType() == "gdpk" then
                self.m_playerHeadList[i]:setReady(false)
                if playerInfo.isR == 1 then
                    self.m_playerHeadList[i]:setReady(true)
                end

                if playerInfo.usI == kUserInfo:getUserId() then
                    if playerInfo.isR == 1 then
                        self.btnReady:loadTextureNormal("package_res/games/guandan/hall/huanpi2/Common/btn_readyCancel.png")
                    else
                        self.btnReady:loadTextureNormal("package_res/games/guandan/hall/huanpi2/Common/btn_getReady.png")
                    end

                    self.isReady = playerInfo.isR
                    if self.isOrganizeTeam then
                        self:updateTeamDesc(playerInfo.we)
                    end
                end
            end

            self:ipXiangTong(playerInfo, headImg);
            headImg:setVisible(true);
            playerName:setVisible(true);
            playerName:setFontName("hall/font/fangzhengcuyuan.TTF")
            local retName = ToolKit.subUtfStrByCn(playerInfo.niN, 0, 5, "");
            Util.updateNickName(playerName, retName, 20)

            --玩家离线状态
            -- ##  st  int   是否在房间  0 在, 1 =离线
            if(playerInfo.st ~= nil and playerInfo.st == 1) then
               leaveImg:setVisible(true)
               self:setPlayerId(i, 0)
            else
               leaveImg:setVisible(false)
               self:setPlayerId(i, playerInfo.usI)
            end
            self.m_playerHeadList[i]:setUserID(playerInfo.usI)
            --测试头像
            --playerInfo.heI = "http://wx.qlogo.cn/mmopen/ajNVdqHZLLCZHe0PtY7TzmVTYp94c8sDoyo9WN4FVmVz9iapgMqKjKCLWEdl6PU4ugBgwIu4j1wicKiaTpGdIcMqSpdDjRbF1SGdgPUiaJNWcWc/0";
            if playerInfo.heI and string.len(playerInfo.heI) > 4 then
                local imgName = playerInfo.usI .. ".jpg";
                headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
                self.m_headImage[i] = headFile
                if io.exists(headFile) then
                    local width=headImg:getContentSize().width
                    local headIamge = CircleClippingNode.new(headFile, true , width)
                    headIamge:setPosition(width/2, headImg:getContentSize().height/2)
                    --headImg:addChild(headIamge);
                    headImg:loadTexture(headFile);
                    self.m_headIndex[imgName] = i
                else
                    self.netImgsTable[imgName] = headImg;
                    self.m_headIndex[imgName] = i
                    HttpManager.getNetworkImage(playerInfo.heI, imgName);
                end
            else
                self.m_headImage[i] = headFile
                headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
                if io.exists(headFile) then
                    local width=headImg:getContentSize().width
                    local headIamge = CircleClippingNode.new(headFile, true , width)
                    headIamge:setPosition(width/2, headImg:getContentSize().height/2)
                    -- headImg:addChild(headIamge);
                    headImg:loadTexture(headFile);
                end
            end
        else
            headImg:removeAllChildren()
            headImg:loadTexture(headFile);
            playerName:setVisible(false);
            leaveImg:setVisible(false)
            self.m_playerHeadList[i]:hideSpeaking();
            self.m_playerHeadList[i]:setUserID(0)
        end
    end

    for j = 1, #self.m_playerHeadList do
        self.m_playerHeadList[j]:setUserReady(self.isReady)
    end
end


--按自己的视角重新排序
function FriendRoomScene:resetMySelfPosition(info)
    local weizhi = 0;
    for i, v in pairs(info.pl) do
        info.pl[i].zhuang = info.pl[i].we
        if info.pl[i].usI == MjProxy:getInstance():getMyUserId() then
            weizhi = tonumber(info.pl[i].we);
        end
        if info.pl[i].we == 1 then
            info.pl[i].zhuang = true;
        else
            info.pl[i].zhuang = false;
        end
    end
    Log.i("------ my weizhi.....", weizhi);
    if weizhi ~= 0 then
        for i, v in pairs(info.pl) do
            if tonumber(info.pl[i].we) >= weizhi then
                info.pl[i].we = info.pl[i].we - weizhi + 1;
            else
                info.pl[i].we = self.roomData.plS - weizhi + 1 + info.pl[i].we
            end
            Log.i("替换后的位置....",info.pl[i].usI, info.pl[i].we)
            local posX = self.originalPosX[info.pl[i].we]
            local posY = self.originalPosY[info.pl[i].we]
            self.playerPanel[info.pl[i].we]:setPosition(cc.p(posX, posY))
            if info.pl[i].zhuang then
                local ower = ccui.Helper:seekWidgetByName(self.playerPanel[info.pl[i].we], "room_main")
                ower:setLocalZOrder(1)
                ower:setVisible(true)
            end
        end
    end
end

--[[
-- @brief  设置用户id
-- @param  site 座位号
-- @param  usid 玩家id
-- @return void
--]]
function FriendRoomScene:setPlayerId(site, usid)
    self.m_userIds[site] = usid
end

--[[
-- @brief  获取用户id
-- @param  site 座位号
-- @return void
--]]
function FriendRoomScene:getPlayerId(site)
    return self.m_userIds[site]
end

function FriendRoomScene:onResponseNetImg(imgName)
    local falg = false
    for k,v in pairs(self.m_headIndex) do
        if k == imgName then
            falg = true
        end
    end
    if falg then
        local isFalg = false
        for k,v in pairs(self.netImgsTable) do
            if k == imgName then
                isFalg = true
            end
        end
        if isFalg then
            local headImg = self.netImgsTable[imgName];
            local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            self.m_headImage[self.m_headIndex[imgName]] = imageName
            if io.exists(imageName) then
                local width=headImg:getContentSize().width
                local headIamge = CircleClippingNode.new(imageName, true , width)
                headIamge:setPosition(width/2, headImg:getContentSize().height/2)
                -- headImg:addChild(headIamge);
                headImg:loadTexture(imageName);
            end
        end
    else
        return
    end
end

--检测ip是否相同
function FriendRoomScene:ipXiangTong(playerInfo, head)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local players = playerInfos.pl;
    local myIp = playerInfo.ipA;
    local ipA = {};
    local player = 0;
    local isIpHand = false;
    for i = 1, 4 do
        if players[i] ~= nil and playerInfo.usI ~= players[i].usI then
            if players[i] ~= nil then
                if myIp == players[i].ipA then
                    self:drawIpXiangTong(head);
                    isIpHand = true;
                    break;
                end
            end
        end
    end
    if isIpHand == false then
        local headOneIp = head:getChildByName("ipxiangtong")
        if headOneIp ~= nil then
            headOneIp:removeFromParent()
        end
    end
end

--绘制ip相同
function FriendRoomScene:drawIpXiangTong(head)
    local headOneIp = head:getChildByName("ipxiangtong")
    if headOneIp == nil then
        local ip = display.newSprite("games/common/mj/common/ipxiangtong.png")
        ip:setName("ipxiangtong");
        ip:addTo(head);
        local headSize = head:getContentSize();
        ip:setPosition(cc.p(head:getContentSize().width * 0.5, head:getContentSize().height * 0.5));
    end
end


function FriendRoomScene:closeRoomSceneUI(tmpData)

       UIManager:getInstance():popWnd(FriendRoomScene);
       --当从游戏返回时,屏幕会黑屏
       local tmpRet = UIManager:getInstance():getWnd(HallMain)
       if(tmpRet==nil) then
            UIManager:getInstance():pushWnd(HallMain);
       end
end

function FriendRoomScene:recvAddNewPlayerToRoom(packetInfo)
    --local str = string.format("系统:玩家(%s)坐下", packetInfo.niN)
    --self:insertSayText(str, cc.c3b(0, 255, 0));
end

--返回
function FriendRoomScene:keyBack()
   Log.i("FriendRoomScene:keyBack");
   self:onCloseRoomButton(self,ccui.TouchEventType.ended);
end

function FriendRoomScene:recvSayMsg(packetInfo)
    Log.i("------FriendRoomScene:recvSayMsg", packetInfo)
end

--检测上传状态
function FriendRoomScene:getUploadStatus()
    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end
    self.m_getUploadThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end, 0.1);
end

function FriendRoomScene:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
        self.m_getUploadThread = nil;
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus", matchStr);

        --发送语音聊天
        if matchStr and kFriendRoomInfo:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = kUserInfo:getUserId();
            tmpData.niN = kUserInfo:getUserName();
            tmpData.roI = kFriendRoomInfo:getRoomInfo().roI;
            tmpData.ty = 1;
            tmpData.co = info.fileUrl;
            FriendRoomSocketProcesser.sendSayMsg(tmpData);
        end

    end
end

--检测播放状态
function FriendRoomScene:getSpeakingStatus()
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end
    self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end, 0.5);
end

function FriendRoomScene:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        self.m_getSpeakingThread = nil;

        self:hideSpeaking(info.usI);
    end
end

--显示正在说话
function FriendRoomScene:showSpeaking(packetInfo)
    if not YY_IS_LOGIN then
       return ;
    end

    if self.m_speaking or self.m_isTouchBegan then
        if #self.m_speakTable < 10 then
            table.insert(self.m_speakTable, packetInfo);
        end
    else
        local playerInfos = kFriendRoomInfo:getRoomInfo();
        for k, v in pairs(playerInfos.pl) do
            if v.usI == packetInfo.usI then
                if self.m_playerHeadList[v.we] then
                    self.m_speaking = true;
                    self.m_playerHeadList[v.we]:showSpeaking();
                    --
                    audio.pauseMusic();
                    --
                    local data = {};
                    data.cmd = NativeCall.CMD_YY_PLAY;
                    data.fileUrl = packetInfo.co;
                    data.usI = packetInfo.usI .. "";--转字符串，不然IOS会报错。
                    NativeCall.getInstance():callNative(data);

                    self:getSpeakingStatus();

                    --防止没有收到播放结束回调
                    self.beginSayBtn:stopAllActions();
                    self.beginSayBtn:performWithDelay(function()
                        self:hideSpeaking(v.usI);
                    end, 60);
                end
                break;
            end
        end
    end

end

--隐藏正在说话
function FriendRoomScene:hideSpeaking(userId)
    userId = userId or "0";
    Log.i("------hideSpeaking userId", userId)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    for k, v in pairs(playerInfos.pl) do
        if v.usI == tonumber(userId) then
            if self.m_playerHeadList[v.we] then
                self.m_playerHeadList[v.we]:hideSpeaking();
            end
            break;
        end
    end
    self.m_speaking = false;
    self:showNextSpeaking();
end

--隐藏正在说话
function FriendRoomScene:showNextSpeaking(userId)
    if not self.m_speaking and #self.m_speakTable > 0 then
        --Log.i("开始说下一条语音");

        self:showSpeaking(table.remove(self.m_speakTable, 1));
    end
end

--玩家退出房间处理
function FriendRoomScene:recvRoomQuit(packetInfo)
    --##  usI  long  玩家id
    --re  int  结果（-1 失败，1 成功）
    if packetInfo.re == 1 then
        local exitUserID = packetInfo.usI
        local localUserID = kUserInfo:getUserId()

        --如果是房主退出, 房间已解散
        if not kFriendRoomInfo:isRoomMain(exitUserID) or kFriendRoomInfo:getRoomInfo().teI ~= 0 then

            if exitUserID == localUserID then
               kFriendRoomInfo:clearData();
               self:closeRoomSceneUI();
            end
        end
    end
end

function FriendRoomScene:recvRoomEnd(packetInfo)
    if (not kFriendRoomInfo:isRoomMain(kUserInfo:getUserId()) and kFriendRoomInfo:getRoomInfo().teI == 0 )or packetInfo.ty ~= 1 then
        local data = {};
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.ti;
        data.closeCallback = function ()
           kFriendRoomInfo:clearData()
           self:closeRoomSceneUI();
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
    else
        kFriendRoomInfo:clearData()
        self:closeRoomSceneUI();
    end
end
 --
function FriendRoomScene:insertSayText(chatData,color)
    local strText = chatData.niN..":"..chatData.co
    local item = self.itemOther:clone()   -- 都在左侧开始显示聊天内容
    -- if chatData.usI==kUserInfo:getUserId() then
    --     item=self.itemMe:clone()
    --     strText = strText..":"..chatData.niN
    -- else
    --     item=self.itemOther:clone()
    --     strText = chatData.niN..":"..strText
    -- end
    item:setVisible(true)

    local headImg = ccui.Helper:seekWidgetByName(item, "icon_head")

    local img_text_bg = ccui.Helper:seekWidgetByName(item, "img_text_bg")
    local img_arrow = ccui.Helper:seekWidgetByName(item, "img_arrow")

    --头像
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local playerInfo=nil
    for k, v in pairs(playerInfos.pl) do
        if v.usI == chatData.usI then
            playerInfo = v;
            break;
        end
    end

    if playerInfo then
        local imgName = playerInfo.usI .. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            headImg:loadTexture(headFile)
            local width=headImg:getContentSize().width
            local headIamge = CircleClippingNode.new(headFile, true , width)
            headIamge:setPosition(width/2, headImg:getContentSize().height/2)
        end
    end

    --聊天内容
    -- local label_text = ccui.Helper:seekWidgetByName(item, "label_text")
    local label_text = ccui.Helper:seekWidgetByName(item, "content")
    if color then
        label_text:setColor(color)
    end
    local textHeight=label_text:getContentSize().height
    label_text:setString(strText)
    --临时创建一个label计算宽度
    local tempLabel=ccui.Text:create(strText, "hall/font/fangzhengcuyuan.TTF", label_text:getFontSize())
    local labelWidth=tempLabel:getContentSize().width < self.sayListView:getContentSize().width*0.8 and tempLabel:getContentSize().width or self.sayListView:getContentSize().width*0.8

    label_text:setTextAreaSize(cc.size(labelWidth,0))
    label_text:ignoreContentAdaptWithSize(false)

    local textSize=label_text:getContentSize()
    img_text_bg:setContentSize(cc.size(textSize.width+20,textSize.height+30))
    item:setContentSize(cc.size(self.sayListView:getContentSize().width,item:getContentSize().height+textSize.height-textHeight))

    self.sayListView:insertCustomItem(item,0)
    self.sayListView:doLayout()
    --聊天条数超过20，任然有继续显示
    self.m_sayQueue:pushFront(item)
    if(self.m_sayQueue:size() >20) then
        local tmpTable= self.m_sayQueue:back()
        local tmpIndex = self.sayListView:getIndex(tmpTable)
        self.sayListView:removeItem(tmpIndex)
        self.m_sayQueue:popBack()
    end
end

function FriendRoomScene:recvGetRoomEnter(packetInfo)
    --## re  int  结果（1 成功找到 -1 人数已满 -2 房间不存在 -3 房费不足 -4 不是该亲友圈亲友 -5 已在其他房间中 -6 重复加入相同房间）

    -- Toast.getInstance():show("recvGetRoomEnter()--获取魔窗数据-002");

    if(-1 == packetInfo.re) then
        Toast.getInstance():show("人数已满");
    elseif(-2 == packetInfo.re) then
        Toast.getInstance():show("房间不存在");
    elseif(-3 == packetInfo.re) then
        Toast.getInstance():show("钻石不足");
    elseif(-4 == packetInfo.re) then
        LoadingView.getInstance():hide();
        Toast.getInstance():show("您不是该亲友圈亲友");
    elseif(-5 == packetInfo.re) then
        Toast.getInstance():show("已在其他房间中");
    elseif(-6 == packetInfo.re) then
        -- Toast.getInstance():show("重复加入相同房间");
    elseif packetInfo.re == 1 then
        kFriendRoomInfo:saveNumber(self.m_enterRoomNum or packetInfo.pa);
    end
end

function FriendRoomScene:recvRoomSeats(packetInfo)
--##  asUI       发起问询的用户ID 发起人
--##  beAUI     收到请求的玩家Id
--##  re          结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
--##  CoD       倒计时
--##  ty            0默认  1发起交换请求  2回答交换请求
--##  chST  接受交换true 不接受交换false
    self:stopCountDown(false)
    if packetInfo.pr and packetInfo.pr == 2 then
        Toast.getInstance():show("已有玩家在该座位，请重试")
        return
    end
    local exchangeSeatTips = UIManager.getInstance():getWnd(ExchangeSeatTips)
    if exchangeSeatTips then
        UIManager.getInstance():popWnd(ExchangeSeatTips)
    end
    local beInfo = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.beAUI)
    if not beInfo then
        return
    end
    kFriendRoomInfo:setExchangeState(false)
    if packetInfo.ty == 1 and not packetInfo.chST then
        --房主撤回申请
        local str = ""
        if packetInfo.asUI == kUserInfo:getUserId() then
            str = "成功取消交换申请"
        else
            local askInfo = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.asUI)
            str = string.format("玩家%s取消了交换申请", askInfo.niN)
        end
        Toast.getInstance():show(str)
    elseif packetInfo.re ~= -1 then
        if packetInfo.ty == 1 then
            kFriendRoomInfo:setExchangeState(true)
        end
        if packetInfo.ty == 2
            and packetInfo.asUI ~= kUserInfo:getUserId()
            and packetInfo.beAUI ~= kUserInfo:getUserId()
            then
            local name = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.asUI).niN
            local beName = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.beAUI).niN
            local str = ""
            if packetInfo.chST then
                str = string.format("玩家%s与玩家%s交换座位成功", name, beName)
            else
                str = string.format("玩家%s拒绝与玩家%s交换座位", beName, name)
            end
            Toast.getInstance():show(str)
        else
            if packetInfo.ty == 1 and packetInfo.chST then
                if CountDownData and CountDownData.clockHandle then
                    scheduler.unscheduleGlobal(CountDownData.clockHandle)
                    CountDownData.clockHandle = nil
                end
                CountDownData = {}
                CountDownData.packetInfo = packetInfo
                CountDownData.time = packetInfo.CoD
                self:startCountDown(packetInfo.CoD)
            end
            UIManager.getInstance():pushWnd(ExchangeSeatTips, packetInfo)
        end
    end
end

function FriendRoomScene:startCountDown(time)
    if not CountDownData then return end
    if CountDownData.clockHandle then
        scheduler.unscheduleGlobal(CountDownData.clockHandle)
        CountDownData.clockHandle = nil
    end

    CountDownData.clockHandle = scheduler.scheduleGlobal(
        function()
            CountDownData.time = CountDownData.time - 1
            if CountDownData.time <= 0 then
                if CountDownData.clockHandle then
                    scheduler.unscheduleGlobal(CountDownData.clockHandle)
                    CountDownData.clockHandle = nil
                end
                if not CountDownData.packetInfo then return end
                if CountDownData.packetInfo.asUI == kUserInfo:getUserId() then
                    local data = {
                        asUI = CountDownData.packetInfo.asUI,
                        beAUI = CountDownData.packetInfo.beAUI,
                        ty = 1,
                        chST = false,
                    }
                    FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
                else
                    --拒绝
                    local data = {
                        asUI = CountDownData.packetInfo.asUI,
                        beAUI = CountDownData.packetInfo.beAUI,
                        ty = 2,
                        chST = false,
                    }
                    FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
                end
            end
    end, 1)
end

function FriendRoomScene:stopCountDown(send)
    if not CountDownData then return end
    if CountDownData.clockHandle then
        scheduler.unscheduleGlobal(CountDownData.clockHandle)
        CountDownData.clockHandle = nil
    end
    if (not send) or (not CountDownData.packetInfo) then
        return
    end
    if CountDownData.packetInfo.asUI == kUserInfo:getUserId() then
        local data = {
            asUI = CountDownData.packetInfo.asUI,
            beAUI = CountDownData.packetInfo.beAUI,
            ty = 1,
            chST = false,
        }
        FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
    else
        --拒绝
        local data = {
            asUI = CountDownData.packetInfo.asUI,
            beAUI = CountDownData.packetInfo.beAUI,
            ty = 2,
            chST = false,
        }
        FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
    end
end

FriendRoomScene.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = FriendRoomScene.recvRoomQuit; --InviteRoomEnter  退出邀请房结果
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = FriendRoomScene.recvFriendRoomStartGame; --邀请房对局开始
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomScene.recvRoomSceneInfo; --InviteRoomEnter    邀请房信息
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_ADDPLAYER] = FriendRoomScene.recvAddNewPlayerToRoom; --新增玩家到房间
    -- 聊天返回
    [HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = FriendRoomScene.recvChatMsg2; --私有房聊天
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_END] = FriendRoomScene.recvRoomEnd;    --InviteRoomEnd  邀请房结束
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = FriendRoomScene.recvGetRoomEnter; --InviteRoomEnter  进入邀请房结果
    [HallSocketCmd.CODE_PRIVATE_ROOM_SEATS_REQ] = FriendRoomScene.recvRoomSeats;  --私有房玩家座位交换问询
};

return FriendRoomScene
