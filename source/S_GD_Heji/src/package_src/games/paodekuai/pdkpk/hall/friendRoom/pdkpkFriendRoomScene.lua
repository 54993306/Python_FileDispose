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
local SignalInfoNode =  import("app.hall.friendRoom.SignalInfoNode")
local Define        = require "app.games.common.Define"
local ShareToWX = require "app.hall.common.ShareToWX"
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local DDZMoreLayer = require("package_src.games.paodekuai.pdk.mediator.widget.DDZMoreLayer")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local BackEndStatistics = require("app.common.BackEndStatistics")
local UmengClickEvent = require("app.common.UmengClickEvent")
local choiceShare = require("app.hall.common.share.choiceShare")
local kPersonInfos =
{
    {},
    {1, 3},
    {1, 2, 4},
    {1, 2, 3, 4}
}

local kRuleWidth = 320 -- 规则文字宽度
local kRuleFontSize = 16 -- 规则字体大小
local kRuleOffY = -18

--房间UI
FriendRoomScene = class("FriendRoomScene", UIWndBase)

local function createNameTip(name)
    local bg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/name_scale_bg.png")
    bg:setContentSize(cc.size(80, 22))
    bg:setName("headnamebg")
    local nameLabel = cc.Label:createWithTTF(name, "hall/font/fangzhengcuyuan.TTF", 18)
    nameLabel:setColor(cc.c3b(0xff, 0xfe, 0xad))
    nameLabel:setPosition(cc.p(40, 11))
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    bg:addChild(nameLabel)
    return bg, nameLabel
end

function FriendRoomScene:ctor(data)
    Log.i("--wangzhi--进入跑得快的friendroomscene")

    local selectSetInfo =kFriendRoomInfo:getRoomInfo()
    self.roomData = selectSetInfo
    self.isDDZ = false
    self.m_listeners = {}
    self:registMsgs()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/pokercommon/pokercommon.plist","package_res/games/pokercommon/pokercommon.png")
    self.super.ctor(self.super,"package_res/games/pokercommon/friendRoomScene_ddz.csb", data)
    self.isDDZ = true
    self:init_gameChatCfg()


    self.m_sayQueue = Deque.new();
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    --有人正在说话

    -- local selectSetInfo =kFriendRoomInfo:getRoomInfo()
    -- self.roomData = selectSetInfo
    self.m_userIds = {}
    self.m_speaking = false;
    self.m_speakTable = {};
    self.m_headImage = {}
    self.m_headIndex = {}

    self.Events = {}

    self:addOneEventListener(NativeCall.Events.YYCallFuncChange, function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end)
    self:addOneEventListener(NativeCall.Events.YYCallFuncFinish, function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end)
end

----------------------------------------------
-- @desc 注册事件监听
----------------------------------------------
function FriendRoomScene:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        table.insert(self.m_listeners, nhandle)
    end
    addEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_JIESAN)
    addEvent(DDZGameEvent.HIDEMORELAYER)

end

----------------------------------------------
-- @desc 监听事件分发
-- @pram id:注册事件id
--       ...:参数
----------------------------------------------
function FriendRoomScene:ListenToEvent(id, ... )
    Log.i("FriendRoomScene:ListenToEvent id", id)
    if id == PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT then
        self:keyBack()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_JIESAN then
        self:DDZCloseRoomButton()
    elseif id == DDZGameEvent.HIDEMORELAYER then
        self:hideMoreLayer(...)
    end
end


----------------------------------------------
-- @desc 取消注册事件监听
----------------------------------------------
function FriendRoomScene:unRegistMsgs()
    Log.i("FriendRoomScene:unRegistMsgs")
    for k,v in pairs(self.m_listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end


----------------------------------------------
-- @desc 收起更多頁面
----------------------------------------------
function FriendRoomScene:hideMoreLayer()
    self.btn_menu:setRotation(0)
    self.moreLayer:hidehide()
end


-- 加载斗地主的聊天语音
function FriendRoomScene:init_gameChatCfg()
    Log.i("PDKRoom:init_gameChatCfg")
    local sex = HallAPI.DataAPI:getUserSex();
    Log.i("------sex", sex);
    if sex == DDZConst.FEMALE then
        -- self.gameChatTxtCfg = csvConfig.maleChatList
        -- _gameChatTxtCfg = csvConfig.maleChatList
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "和我斗，你还嫩了点！",
            "不是吧！这样都能赢！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要走再战300回合!",
        };
    else
        -- self.gameChatTxtCfg = csvConfig.femaleChatList
        -- _gameChatTxtCfg = csvConfig.femaleChatList
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "和我斗，你还嫩了点！",
            "不是吧！这样都能赢！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要走再战300回合!",
        };
    end
end


function FriendRoomScene:onClose()
    if self.isDDZ then
        self:unRegistMsgs()
    end

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
    self.isDDZ = nil

    table.walk(self.Events,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.Events = {}
end
function FriendRoomScene:closeEditBox()
    local data = {};
    data.cmd = NativeCall.CMD_CLOSEEDITBOX;
    NativeCall.getInstance():callNative(data);
end

function FriendRoomScene:onInit()
    self.m_roomInfo = kFriendRoomInfo:getRoomInfo()
    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height

    for i = 1, 4 do
        local strName = "playerHeadPanel_".. i
        local p = ccui.Helper:seekWidgetByName(self.m_pWidget, strName)
        p:setVisible(false)
    end

    local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg")

    -- local subSprite = display.newSprite("games/common/mj/games/game_bg_wenli_1.png")
    -- subSprite:setBlendFunc(gl.DST_COLOR, gl.ONE_MINUS_SRC_ALPHA)
    -- subSprite:setPosition(cc.p(visibleWidth * 0.5, visibleHeight * 0.5))
    -- if Util.isBezelLess() then
    --     subSprite:setScale(0.8)
    -- end
    -- bg:addChild(subSprite)
    if self.isDDZ then
        self.btn_menu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_menu");
        self.btn_menu:addTouchEventListener(handler(self, self.onClickButton));

        local ui= ccui.Helper:seekWidgetByName(self.m_pWidget,"Panel_MoreLayer")
        ui:setVisible(false)
        self.moreLayer = DDZMoreLayer.new(ui)
        self.lab_roomId = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_roomid")
        self.lab_roomPayType = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_paytype")


        local playerInfos   = kFriendRoomInfo:getRoomInfo();
        self.lab_roomId:setString(string.format("房间号:%d",playerInfos.pa))
        Log.i("--wangzhi--playerInfos--",playerInfos)
        if playerInfos.RoJST == 0  then
            self.lab_roomPayType:setString("亲友圈付费")
        elseif playerInfos.RoJST == 1  then
            self.lab_roomPayType:setString("房主付费")
        elseif playerInfos.RoJST == 2  then
            self.lab_roomPayType:setString("大赢家付费")
        elseif playerInfos.RoJST == 3 then
            self.lab_roomPayType:setString(string.format("AA付费(每人%s钻石)",math.ceil( playerInfos.RoFS / playerInfos.plS )))
        end
    else
        local signalInfo = SignalInfoNode.new()
        self.m_pWidget:addChild(signalInfo)
        signalInfo:updateTitle()
        signalInfo:updateRoomId()
    end

    --退出房间
    self.cancleBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "cancleBtn");
    self.cancleBtn:addTouchEventListener(handler(self, self.onCloseRoomButton));

    --微信邀请
    self.shardBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "shardBtn");
    self.shardBtn:addTouchEventListener(handler(self, self.onClickButton));
	if IS_YINGYONGBAO then --如果是应用宝审核宝，关闭微信分享按钮
	    self.shardBtn:setVisible(false)
	end

    self.chatBtn    = ccui.Helper:seekWidgetByName(self.m_pWidget, "chat_btn");
    self.chatBtn:addTouchEventListener(handler(self, self.onMsgButton));

    self.beginSayBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "beginSayBtn");
    self.beginSayBtn:addTouchEventListener(handler(self, self.onTouchSayButton));

    self.img_mic    = ccui.Helper:seekWidgetByName(self.m_pWidget, "mic");
    -- 规则文本
    self.ruleText = {}
    for i=1,3 do
        local ruleStr = "rule_Text_"..i
        self.ruleText[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, ruleStr)
        self.ruleText[i]:setVisible(false)
    end
    self.m_playerHeadList  = {};
    self.playerPanel       = {}
    self.originalPosX      = {} --原始X点
    self.originalPosY      = {} --原始Y点

    local personSites = (self.roomData and self.roomData.plS > 1 and self.roomData.plS <= 4) and kPersonInfos[self.roomData.plS] or kPersonInfos[4]

    for i = 1, #personSites do
        local strName = "playerHeadPanel_".. personSites[i]
        self.playerPanel[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, strName)
        self.playerPanel[i]:setLocalZOrder(3)
        -- 保存原始位置，后面需要移位
        table.insert(self.originalPosX, self.playerPanel[i]:getPositionX())
        table.insert(self.originalPosY, self.playerPanel[i]:getPositionY())

        self.m_playerHeadList[i] = FriendRoomPlayerHead.new(self, self.playerPanel[i],self.isDDZ);
        if _isPositionVisible ~= false then
            self.playerPanel[i]:addTouchEventListener(handler(self, self.onClickPVButton));
        end
        self.playerPanel[i]:setVisible(false)
        -- 设置用户id
        self:setPlayerId(i, 0)
    end

    local userID =kUserInfo:getUserId()
    local isRoom = kFriendRoomInfo:isRoomMain(userID)
    if isRoom and kFriendRoomInfo:getRoomInfo().teI == 0 then--如果是房主
        if self.isDDZ then
            -- self.cancleBtn:loadTextureNormal("hall/Common/btn_jieshan.png")
        else
            self.cancleBtn:loadTextureNormal("hall/Common/btn_jieshan.png")
        end
    else
        if self.isDDZ then
            self.cancleBtn:loadTextureNormal("package_res/games/pokercommon/ddzroom/ddzroom/Btn_quit.png")
        else
            self.cancleBtn:loadTextureNormal("hall/Common/btn_tuichu.png")
        end
    end

    self:updateUI()

    --
    if self.m_data and self.m_data.newerType then
        self.m_NewerType = self.m_data.newerType;
        self:showNewer();
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
    local data = {type = wType,playerHeadImage = headImage,playerName = name,playerIP = ipA, playerID = usrID, lo = jindu,la = weidu,site = other}
    self.infoView = UIManager:getInstance():pushWnd(PlayerPosInfoWnd, data);
    self.infoView:setDelegate(self);
end


function FriendRoomScene:onMsgButton(pWidget, EventType)
  if EventType == ccui.TouchEventType.ended then
    if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then
            MjProxy:getInstance():get_gameChatTxtCfg()
        end
        Log.i("--wangzhi--pdk--chat--")
        self.m_chatView = UIManager.getInstance():pushWnd(RoomChatView)
        self.m_chatView:setDelegate(self)
        SoundManager.playEffect("btn", false);
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

function FriendRoomScene:recvChatMsg(chatData)
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
        for i,v in pairs(self.playerPanel) do
            if chatData.usI == self:getPlayerId(i) then
                if chatData.ty == 0 then
                    local site = i;
                    local content = chatData.co;
                    local face = string.sub(content, 0, 5);
                    local duanyu = string.sub(content, 0, 7);
                    Log.i("face...", face);
                    Log.i("duanyu...", duanyu);
                    if face == "face_" then
                        local index = string.sub(content, 6, string.len(content));
                        chatData.ty = enChatType.FACE;
                        chatData.emI = index;
                        if tonumber(index) > 0 and tonumber(index) <= 24 then
                            local chat_bg = ccui.Helper:seekWidgetByName(self.playerPanel[site], "Image_cat_bg");
                            local playerChat = PlayerChat.new(site, self.playerPanel[site], 2, chatData, chat_bg)
                        else
                            local chat_bg = ccui.Helper:seekWidgetByName(self.playerPanel[site], "Image_cat_bg");
                            local playerChat = PlayerChat.new(site, self.playerPanel[site], 1, chatData, chat_bg)
                        end
                    elseif duanyu == "duanyu_" then
                        local index = string.sub(content, 8, string.len(content));
                        chatData.ty = enChatType.PHRASE;
                        chatData.emI = index;
                        index = tonumber(index);
                        if index > 0 then
							if _gameChatTxtCfg == nil or #_gameChatTxtCfg <=0 then
								MjProxy.getInstance():get_gameChatTxtCfg()
							end
                            if _gameChatTxtCfg[index] then
                                chatData.co = _gameChatTxtCfg[index];
                                local playerInfos = kFriendRoomInfo:getRoomInfo();
                                for k, v in pairs(playerInfos.pl) do
                                    if v.usI == chatData.usI then
                                        if self.isDDZ then
                                            SoundManager.playEffect(_getGameLiaotianduanyuKey3(v.se or 2, index));
                                        else
                                            SoundManager.playEffect(_getGameLiaotianduanyuKey(v.se or 2, index));
                                        end
                                        break;
                                    end
                                end
                            end
                            local chat_bg = ccui.Helper:seekWidgetByName(self.playerPanel[site], "Image_cat_bg");
                            local playerChat = PlayerChat.new(site, self.playerPanel[site], 1, chatData, chat_bg)

                        end
                    else
                        local chat_bg = ccui.Helper:seekWidgetByName(self.playerPanel[site], "Image_cat_bg");
                        local playerChat = PlayerChat.new(site, self.playerPanel[site], 1, chatData, chat_bg)
                    end
                    break;
                end
            end
        end
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

        if not YY_IS_LOGIN then
            --语音初始化失败
            Log.i("语音初始化失败")
            Toast.getInstance():show("功能未初始化完成，请稍后")
            return;
        end

        if not self.m_isTouching then
            self.m_isTouchBegan = true;
            --开始录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data);
            self:showMic();
            -- self.beginSayTxt:setString("松开 发送");
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

            self:getUploadStatus();

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
Log.i("--wangzhi--点击了按钮--")
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
            --type = 2,code=20015, 获取邀请房信息   client  <--> server
            local tmpData={}

            --FriendRoomSocketProcesser.sendRoomGetRoomInfo(tmpData)
        elseif(pWidget == self.redPackBtn) then--红包
            UIManager:getInstance():pushWnd(FriendRoomRedPacket);

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
                turnimg:loadTexture("hall/huanpi2/FriendRoomScene/keyboard.png")
                self.turnBtn.talkstate = false
                self.inputPanel:setVisible(false)
                self.beginSayBtn:setVisible(true)
            else
                turnimg:loadTexture("hall/huanpi2/FriendRoomScene/mic.png")
                self.turnBtn.talkstate = true
                self.inputPanel:setVisible(true)
                self.beginSayBtn:setVisible(false)
            end
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
        elseif pWidget == self.btn_menu then
            self.btn_menu:setRotation(-180)
            self.moreLayer:showshow()
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
    local ruleText = cc.Label:createWithTTF(ruleStr, "hall/font/fangzhengcuyuan.TTF", kRuleFontSize)
    ruleText:setAnchorPoint(cc.p(0.5, 1))
    if self.isDDZ then
        ruleText:setColor(cc.c3b(0xff, 0xff, 0xff))
    else
        ruleText:setColor(cc.c3b(0xb1, 0xcc, 0xa3))
    end
    ruleText:setWidth(kRuleWidth)
    ruleText:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    ruleText:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

    local size = self.ruleText[1]:getContentSize()
    local x, y = self.ruleText[1]:getPosition()
    ruleText:setPosition(cc.p(x, y + size.height + kRuleOffY))
    self.ruleText[1]:getParent():addChild(ruleText, 10)
end

function FriendRoomScene:updateUI()
    local roomInfo      = kFriendRoomInfo:getRoomBaseInfo()
    local playerInfos   = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo = kFriendRoomInfo:getSelectRoomInfo();
    -- local playingInfo   = kFriendRoomInfo:getPlayingInfo()

    --房间号
    local roomNumberLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "roomNumberLabel");
    roomNumberLabel:setFontName("hall/font/fangzhengcuyuan.TTF")
    roomNumberLabel:setString(string.format("房间号:%d", playerInfos.pa));
    self:playerListViewUpdate();

    local ruleStrRet = kFriendRoomInfo:getRuleStrRet(kRuleWidth, kRuleFontSize)
    if ruleStrRet.rows > 0 then
        self:createRuleTip(ruleStrRet.ruleStr)
        -- local x, y = self.ruleText[1]:getPosition()
        -- Log.i("-==========x, y ====================",x, y)
        -- ruleTip:setPosition(cc.p(x, y))
        -- self.ruleText[1]:setAnchorPoint(cc.p(0.5, 1))
        -- --ruleTip:setAnchorPoint(self.ruleText[1]:getAnchorPoint())
        -- self.ruleText[1]:getParent():addChild(ruleTip, 10)
    end

    local copyBtnLayout = ccui.Layout:create()
    -- local copyBtnLayout = display.newColorLayer(cc.c4b(100,100,100,255))
    copyBtnLayout:setContentSize(cc.size(200,50))
    roomNumberLabel:addChild(copyBtnLayout)
    copyBtnLayout:setPosition(cc.p(self.shardBtn:getContentSize().width - 30,
                                    -self.shardBtn:getContentSize().height + copyBtnLayout:getContentSize().height/2 - 10))

    local copyRoomId = cc.Label:create()
    copyRoomId:setString("(复制房间信息)")
    copyRoomId:setSystemFontSize(28)
    copyRoomId:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomId:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2))
    copyBtnLayout:addChild(copyRoomId)

    copyBtnLayout:setTouchEnabled(true)
    copyBtnLayout:setTouchSwallowEnabled(true)
    copyBtnLayout:addTouchEventListener(handler(self,self.onLabelClickButton));

    local copyRoomIdLine = cc.Label:create()
    copyRoomIdLine:setString("_____________")
    copyRoomIdLine:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomIdLine:setSystemFontSize(28)
    copyRoomIdLine:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2 - 5))
    copyBtnLayout:addChild(copyRoomIdLine)
end

function FriendRoomScene:DDZCloseRoomButton()
    self:onCloseRoom();
end

function FriendRoomScene:onCloseRoomButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn", false);
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
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameCopyRoomInfo)
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
    if isRoom and kFriendRoomInfo:getRoomInfo().teI == 0 then--如果是房主
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
    Log.i("111111111111111111111111111111111111111-----", shardType)
    local roomInfo=kFriendRoomInfo:getRoomBaseInfo()
    Log.i("--wangzhi--roomInfo--",roomInfo)
    local playerInfo = kFriendRoomInfo:getRoomInfo();
	local selectSetInfo =kFriendRoomInfo:getSelectRoomInfo()
    --22005的付费字段 人数字段有误，用22006的
    --因为getWxShareInfo是地方组自己写的，所以在这里把RoJST进行赋值
    selectSetInfo.RoJST = playerInfo.RoJST
    selectSetInfo.plS = playerInfo.plS
    selectSetInfo.clI = playerInfo.clI

    local data = {};

    data.title, data.desc = getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    Log.i("--wangzhi--data.title--",data.title)
    Log.i("--wangzhi--data.desc--",data.desc)
	data.cmd = NativeCall.CMD_WECHAT_SHARE;

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
            local iosOpen = "iosOpen="..roomInfo.iosOpenurl.. PRODUCT_ID.."?code=" .. playerInfo.pa   --这个是可以直接拉入房间，需要提审
            -- local iosOpen = "iosOpen="..WX_APP_ID.."://"
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

    LoadingView.getInstance():show("正在分享,请稍后...", 2)
	 data.shardMold = 2
    WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.FRIEND_ROOM_FRIEND, callBack, ShareToWX.PaijuShareFriend, data)
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
end


--更新玩家信息
function FriendRoomScene:playerListViewUpdate()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local player_list = self:resetMySelfPosition(playerInfos);
    playerInfos.pl = player_list
    for i = 1, #self.m_playerHeadList do
        local  headImg = self.m_playerHeadList[i]:getHeadImg();
        local  playerName = self.m_playerHeadList[i]:getPlayerName();
        local  leaveImg = self.m_playerHeadList[i]:getLeaveImg();
        leaveImg:setLocalZOrder(10)
        local  playerInfo = nil;
        for k, v in pairs(playerInfos.pl) do
            if v.we == i then
                playerInfo = v;
                break;
            end
        end
        if playerInfo then
            self:ipXiangTong(playerInfo, headImg);

            headImg:setVisible(true);
            playerName:setVisible(true);
            playerName:setFontName("hall/font/fangzhengcuyuan.TTF")
            local retName = ToolKit.subUtfStrByCn(playerInfo.niN, 0, 5, "");
            -- playerName:setString(retName);
            Util.updateNickName(playerName, retName, 19)
            local headnamebg = playerName:getParent():getChildByName("headnamebg")
            if headnamebg then
                headnamebg:removeFromParent()
                headnamebg = nil
            end
            local nameBg, nameLabel = createNameTip(retName)
            local xx, yy = playerName:getPosition()
            nameBg:setPosition(cc.p(xx, yy))
            nameBg:setAnchorPoint(playerName:getAnchorPoint())
            playerName:getParent():addChild(nameBg)
            playerName:setVisible(false)
            Util.updateNickName(nameLabel, retName, 20)

            --玩家离线状态
            -- ##  st  int   是否在房间  0 在, 1 =离线
            if(playerInfo.st ~= nil and playerInfo.st == 1) then
               leaveImg:setVisible(true)
               self.playerPanel[i]:setVisible(true);
               self:setPlayerId(i, 0)
            else
               leaveImg:setVisible(false)
               self.playerPanel[i]:setVisible(true)
               self:setPlayerId(i, playerInfo.usI)
            end
            --测试头像
            --playerInfo.heI = "http://wx.qlogo.cn/mmopen/ajNVdqHZLLCZHe0PtY7TzmVTYp94c8sDoyo9WN4FVmVz9iapgMqKjKCLWEdl6PU4ugBgwIu4j1wicKiaTpGdIcMqSpdDjRbF1SGdgPUiaJNWcWc/0";
            if playerInfo.heI and string.len(playerInfo.heI) > 4 then
                local imgName = playerInfo.usI .. ".jpg";
                local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
                self.m_headImage[i] = headFile
                if io.exists(headFile) then
                    headImg:loadTexture(headFile);
                    self.m_headIndex[imgName] = i
                else
                    self.netImgsTable[imgName] = headImg;
                    self.m_headIndex[imgName] = i
                    HttpManager.getNetworkImage(playerInfo.heI, imgName);
                end
            else
                local headFile = "hall/Common/default_head_2.png";
                self.m_headImage[i] = headFile
                headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
                if io.exists(headFile) then
                    headImg:loadTexture(headFile);
                end
            end
        else
            self.playerPanel[i]:setVisible(false);
            self.m_playerHeadList[i]:hideSpeaking();
        end
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

    local player_list = clone(info.pl)
    if weizhi ~= 0 then
        for i, v in pairs(player_list) do
            if tonumber(player_list[i].we) >= weizhi then
                player_list[i].we = player_list[i].we - weizhi + 1;
            else
                player_list[i].we = self.roomData.plS - weizhi + 1 + player_list[i].we
            end
            Log.i("替换后的位置....",player_list[i].usI, player_list[i].we)
            local posX = self.originalPosX[player_list[i].we]
            local posY = self.originalPosY[player_list[i].we]
            self.playerPanel[player_list[i].we]:setPosition(cc.p(posX, posY))
            local ower = ccui.Helper:seekWidgetByName(self.playerPanel[player_list[i].we], "room_main")
            ower:setLocalZOrder(1)
            if player_list[i].zhuang then
                ower:setVisible(true)
            else
                ower:setVisible(false)
            end
        end
    end

    return player_list
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
    if not imgName then return end
    if not self.m_headIndex[imgName] then return end

    local  headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    self.m_headImage[self.m_headIndex[imgName]] = imageName
    if headImg and io.exists(imageName) then
        headImg:loadTexture(imageName);
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
    if COMPATIBLE_VERSION < 1 then
        if self.m_getUploadThread then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
        end
        self.m_getUploadThread = scheduler.scheduleGlobal(function()
            local data = {};
            data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
            NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
        end, 0.1);
    end
end

function FriendRoomScene:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        if self.m_getUploadThread and COMPATIBLE_VERSION < 1 then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
            self.m_getUploadThread = nil;
        end
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
    if COMPATIBLE_VERSION < 1 then
        if self.m_getSpeakingThread then
            scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        end
        self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
            local data = {};
            data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
            NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
        end, 0.5);
    end
end

function FriendRoomScene:addOneEventListener(eventName, listenerFunc)
    local signalLst = cc.EventListenerCustom:create(eventName, listenerFunc)
    table.insert(self.Events,signalLst)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalLst, 1)
end

function FriendRoomScene:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        -- if UIManager.getInstance():getWnd(HallMain) then
        --     local FriendRoomScene = UIManager.getInstance():getWnd(FriendRoomScene);
        --     if FriendRoomScene then
        --         FriendRoomScene:hideSpeaking(info.usI);
        --     end
        -- else
        --     MjMediator:getInstance():on_hideSpeaking(data.usI);
        -- end
        if self.m_getSpeakingThread and COMPATIBLE_VERSION < 1 then
            scheduler.unscheduleGlobal(self.m_getSpeakingThread);
            self.m_getSpeakingThread = nil;
        end

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
                        self:hideSpeaking();
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
    if not kFriendRoomInfo:isRoomMain(kUserInfo:getUserId()) or packetInfo.ty ~= 1 then
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



FriendRoomScene.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = FriendRoomScene.recvRoomQuit; --InviteRoomEnter  退出邀请房结果
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = FriendRoomScene.recvFriendRoomStartGame; --邀请房对局开始
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomScene.recvRoomSceneInfo; --InviteRoomEnter    邀请房信息
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_ADDPLAYER] = FriendRoomScene.recvAddNewPlayerToRoom; --新增玩家到房间
    -- 聊天返回
    [HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = FriendRoomScene.recvChatMsg; --私有房聊天
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_END] = FriendRoomScene.recvRoomEnd; 	--InviteRoomEnd	 邀请房结束
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = FriendRoomScene.recvGetRoomEnter; --InviteRoomEnter  进入邀请房结果
};

return FriendRoomScene
