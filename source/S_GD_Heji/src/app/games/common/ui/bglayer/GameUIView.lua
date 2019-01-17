--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--local WWFacade = require("app.games.common.custom.WWFacade")
local Define = require "app.games.common.Define"
GameUIView = class("GameUIView")

local LocalEvent = require("app.hall.common.LocalEvent")

local kRuleWidth = 500 -- 规则文字宽度
if IsPortrait then -- TODO
    kRuleWidth = 400
end
local kRuleFontSize = 25 -- 规则字体大小
local UmengClickEvent = require("app.common.UmengClickEvent")

function GameUIView:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/gameItem.csb");
    self.m_data = data
    self._selectBtn = {
        agree = false,
        agreeTime = 0.5,
    }
    self.finishXia = false -- 下嘴完成标志
    self.chaHuBtnStatus = 0 --查胡状态

    self.m_showSignal = true -- 是显示信号还是显示电量
    
    self.handlers = {};
    self.Events   = {};
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_dingque_Anim_start,
        handler(self, self.onDingqueAnimStart)))
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF,
        handler(self, self.setChaHuButtonHide)))
    self:listenerExit()

    self:initRule()
end

--------------------------
-- 初始化规则
function GameUIView:initRule()
    local ruleStrRet = kFriendRoomInfo:getRuleStrRet(kRuleWidth, kRuleFontSize)
    -- 回放或只有一行时, 直接在BgLayer中显示规则
    if VideotapeManager.getInstance():isPlayingVideo() or ruleStrRet.rows <= 1 then return end
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_setRuleVisible,
            handler(self, self.setRuleVisible)))

    self:createRuleTip(ruleStrRet.ruleStr)
end

--------------------------
-- 创建规则
-- @param size 规则文字的大小尺寸, 在此只用到了width
-- @string str 规则文字
function GameUIView:createRuleTip(str)
    Log.i("GameUIView:createRuleTip")
    if str == nil then
        str = ""
    end
    -- str = "随便测试一下长规ad则看看 是什么形式 随便测试一 下长规则看看是什么形式 下长规则看看是什么形式"
    -- 初始化规则背景
    self.ruleTextBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/rule_bg.png")
    self.ruleTextBg:setAnchorPoint(cc.p(0.5, 1))
    self.ruleTextBg:setPosition(cc.p(display.cx, display.cy - 35))

    self.ruleTextBg:addTo(self.m_pWidget)

    self.ruleText = cc.Label:createWithTTF(str, "hall/font/fangzhengcuyuan.TTF", kRuleFontSize)
    self.ruleText:setWidth(kRuleWidth) -- 通过此方法可以设置最大宽度, 同时其contentSize也为自动适应的大小
    -- self.ruleText:setAnchorPoint(cc.p(0.5, 0.5))
    self.ruleText:setColor(cc.c3b(238,253,72))
    -- ruleText:setDimensions(size.width,size.height) -- 通过此方法可以设置大小和高度, 一旦设置后, setMaxLineWidth就无效了, 其contentSize为设置的Dimensions的大小
    self.ruleText:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.ruleText:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.ruleText:addTo(self.ruleTextBg)

    local size = self.ruleText:getContentSize()
    size.width = size.width + 10
    size.height = size.height + 2
    self.ruleTextBg:setContentSize(size)
    if IsPortrait then -- TODO
        self.ruleText:setPosition(cc.p(size.width * 0.5-5, size.height * 0.5))
    else
        self.ruleText:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    end
    -- 初始化为不可见
    self:setRuleVisible(nil, false)
end

------------------
-- 设置规则可见性
-- @bool isVisible 可见性
function GameUIView:setRuleVisible(event, isVisible)
    if event then
        Log.i("------GameUIView:setRuleVisible event", unpack(event._userdata))
        isVisible = unpack(event._userdata)
    end
    self.ruleTextBg:setVisible(isVisible)
end

function GameUIView:listenerExit()
    self.m_pWidget:addNodeEventListener(cc.NODE_EVENT, function(event)
        if event.name == "exit" then
            self:onExit()
        end
    end)
end

function GameUIView:onExit()
    -- print("----------------------GameUIViewonExit:")
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
    table.walk(self.Events,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.Events = {}
end

function GameUIView:dtor()

end

function GameUIView:onClose()
    scheduler.unscheduleGlobal(self.m_batteryScheduler)
end

function GameUIView:setDelegate(delegate)
    self.m_delegate = delegate;
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function GameUIView:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
	if(widget == nil) then
        return;
    end

    return widget;
end

    --分辨率适配
function GameUIView:resolutionAdaptation()
    local chatPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "chat_panel");
    if chatPanel and Define.ViewSizeType == 1 then
        dump(Define.ViewSizeType)
        chatPanel:setContentSize(chatPanel:getContentSize().width, chatPanel:getContentSize().height+Define.mj_ui_chat_panel_offset_y)
        ccui.Helper:doLayout(chatPanel)
    end
end

function GameUIView:onInit()
    self:resolutionAdaptation()
    self:updateTitle()
    self:updateString()
    self:updateRoomId()
    self:parseOpWidget()
end

function GameUIView:initSignalIcon(title_panel)
    --wifi信号
    self.image_wifi = self:getWidget(title_panel,"Image_wifi")
    self.wifi_1 = self:getWidget(self.image_wifi,"wifi_1")
    self.wifi_2 = self:getWidget(self.image_wifi,"wifi_2")
    self.wifi_3 = self:getWidget(self.image_wifi,"wifi_3")
    self.wifi_4 = self:getWidget(self.image_wifi,"wifi_4")
    --手机信号
    self.image_xinhao = self:getWidget(title_panel,"Image_xinhao")
    self.xinhao_1 = self:getWidget(self.image_xinhao,"xinhao_1")
    self.xinhao_2 = self:getWidget(self.image_xinhao,"xinhao_2")
    self.xinhao_3 = self:getWidget(self.image_xinhao,"xinhao_3")
    self.xinhao_4 = self:getWidget(self.image_xinhao,"xinhao_4")
    self.image_xinhao:setScale(0.7)
end

function GameUIView:initTime(title_panel)
    -- local bg = ccui.Helper:seekWidgetByName(title_panel, "Image_bg")
    -- bg:setVisible(false)

    -- local newBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/name_scale_bg.png")
    -- newBg:setContentSize(cc.size(bg:getContentSize().width - 16, self.image_bat_bg:getContentSize().height + 8))
    -- newBg:setPosition(cc.p(bg:getPositionX() - 4, bg:getPositionY() + 6))
    -- title_panel:addChild(newBg, -1)

    --系统时间
    local label_time = self:getWidget(title_panel,"Label_time")
    -- self.label_time = cc.Label:createWithBMFont("hall/Common/batteryFont.fnt", "10:03")
    -- self.label_time:setPosition(cc.p(newBg:getContentSize().width * 0.5, -22))
    -- newBg:addChild(self.label_time)
    -- label_time:setVisible(false)
    self.label_time=label_time
    self.label_time:setString(os.date("%H:%M", os.time()))
    local function refreshTimeFun ()
        local time = os.date("%H:%M", os.time())
        if time == nil then
            time = " "
        end
        time = string.format(time)
        if self.label_time ~= nil then
            self.label_time:setString(time.."")
        end
        self.label_time:performWithDelay(refreshTimeFun,1)
    end
    refreshTimeFun()
end

--更新电量信号时间信息
function GameUIView:updateTitle()
    local title_panel = self:getWidget(self.m_pWidget,"title_panel")

    local image_bg = self:getWidget(title_panel,"Image_bg")
    image_bg:setContentSize(cc.size(image_bg:getContentSize().width-70,image_bg:getContentSize().height))
    image_bg:setPositionX(image_bg:getPositionX()-30)
    --手机电量
    self.image_bat_bg = self:getWidget(title_panel,"Image_bat_bg")
    self.progressBar_pro = self:getWidget(self.image_bat_bg,"ProgressBar_pro")

    self:initSignalIcon(title_panel)
    self:initTime(title_panel)
    
    if IsPortrait then -- TODO
        self.image_bat_bg:setPositionX(self.image_wifi:getPositionX())
    else
        self.image_bat_bg:setPositionY(self.image_bat_bg:getPositionY()-5)
        self.image_wifi:setPositionY(self.image_wifi:getPositionY()-5)
        self.image_wifi:setPositionX(self.image_bat_bg:getPositionX())
        self.image_xinhao:setPosition(cc.p(self.image_wifi:getPosition()))
    end

    -- 刷新一遍信号显示
    self:refreshSignalAndBattery()

    self.m_pWidget:performWithDelay(function()
        self:updateSignal()
        self:updateBattery()
    end, 2)
    
    self.m_batteryScheduler = scheduler.scheduleGlobal(function()
        if self.image_bat_bg then
            self.m_showSignal = not self.m_showSignal
            self:refreshSignalAndBattery()
        else
            scheduler.unscheduleGlobal(self.m_batteryScheduler)
        end
    end,20)
end

local function updateNativeSignal()
    local data = {}
    data.cmd = NativeCall.CMD_WECHAT_SIGNAL
    NativeCall.getInstance():callNative(data, function(info)
            local event = cc.EventCustom:new(LocalEvent.GameUISignal)
            event.data = info
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
        end)
end

function GameUIView:addOneEventListener(eventName, listenerFunc)
    local signalLst = cc.EventListenerCustom:create(eventName, listenerFunc)
    table.insert(self.Events,signalLst)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalLst, 1)
end

function GameUIView:updateSignal()
    self.image_wifi:stopAllActions()
    self.image_wifi:schedule(updateNativeSignal, 5)
    updateNativeSignal()

    self:addOneEventListener(LocalEvent.GameUISignal, handler(self,self.onUpdateSignal))
    self:addOneEventListener(NativeCall.Events.NetStateChange, updateNativeSignal)
end

function GameUIView:onUpdateSignal(event)
    if type(event) ~= 'userdata' or type(event.data) ~= 'table' then
        return
    end
    local info = event.data
    Log.i("GameUIView:onUpdateSignal info", info)
    if Util.table_eq(info, HallAPI.DataAPI:getNetStateInfo()) then
        return
    else
        HallAPI.DataAPI:setNetStateInfo(info)
        self:refreshSignalAndBattery(true)
    end
end

function GameUIView:refreshSignalAndBattery(refreshSignal)
    Log.i("GameUIView:refreshSignalAndBattery", "self.m_showSignal:", self.m_showSignal, "isWifi():", HallAPI.DataAPI:isWifi(), "refreshSignal:", refreshSignal)
    self.image_wifi:setVisible(self.m_showSignal and HallAPI.DataAPI:isWifi())
    self.image_xinhao:setVisible(self.m_showSignal and not HallAPI.DataAPI:isWifi())
    self.image_bat_bg:setVisible(not self.m_showSignal)

    if refreshSignal then
        local rssi = HallAPI.DataAPI:getNetStateInfo().rssi
        Log.i("GameUIView:refreshSignalAndBattery", "rssi:", rssi)
        self.wifi_1:setVisible(rssi >= 1)
        self.wifi_2:setVisible(rssi >= 2)
        self.wifi_3:setVisible(rssi >= 3)
        self.wifi_4:setVisible(rssi >= 4)
    end
end

function GameUIView:updateBattery()
    local update = cc.CallFunc:create(function()
        local data = {};
        data.cmd = NativeCall.CMD_GETBATTERY;
        NativeCall.getInstance():callNative(data, self.batteryCallBack, self);
    end)
    self.progressBar_pro:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),update)))
    local EventListener = cc.EventListenerCustom:create(LocalEvent.GameUIBattery,handler(self,self.onUpdateBattery))
    table.insert(self.Events,EventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(EventListener, 1)
end

function GameUIView:batteryCallBack(info)
    local event = cc.EventCustom:new(LocalEvent.GameUIBattery)
    event.data = info
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function GameUIView:onUpdateBattery(event)
    self.progressBar_pro:setPercent(event.data.baPro)
end
--实现设置聊天按钮
function GameUIView:updateString()
    local stting_panel = self:getWidget(self.m_pWidget,"stting_panel")
    self.button_stting = self:getWidget(stting_panel,"Button_stting")
    self.button_stting:addTouchEventListener(handler(self, self.sttingButton));
    self.button_jieshan = self:getWidget(stting_panel,"Button_back")
    self.button_jieshan:setVisible(false)
    --self.button_jieshan:addTouchEventListener(handler(self,self.sttingButton))

    --微信按钮
    self.button_weixin = self:getWidget(stting_panel, "Button_weixin")
    self.button_weixin:addTouchEventListener(handler(self, self.sttingButton))

    if IsPortrait then -- TODO
        if IS_YINGYONGBAO or (_isOpenWeiXin ==nil or _isOpenWeiXin==false) then
            self.button_weixin:setVisible(false);
        end
    else
        if(_isOpenWeiXin ==nil or _isOpenWeiXin==false) then
            self.button_weixin:setVisible(false);
        end
    end

    local chat_panel = self:getWidget(self.m_pWidget,"chat_panel")
    --输入框按钮
    self.button_chat = self:getWidget(chat_panel,"Button_chat")
    self.button_chat:addTouchEventListener(handler(self,self.sttingButton))

    -- 语音按钮
    self.Button_yuyin = self:getWidget(chat_panel,"Button_yuyin")
    self.Button_yuyin:addTouchEventListener(handler(self,self.onTouchSayButton))
    self.Button_yuyin:setVisible(true)

    -- 查胡按钮
    self.Button_chahu = self:getWidget(chat_panel,"Button_chahu")
    self.Button_chahu:addTouchEventListener(handler(self,self.chahuButton))
    self.Button_chahu:setVisible(false)

    local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height

    -- 语音图片
    local voice_panel = self:getWidget(self.m_pWidget,"voice_panel")
    self.img_mic = self:getWidget(voice_panel,"mic_img")
    self.img_mic:setPosition(cc.p(visibleWidth/2, visibleHeight/2))
    self.img_mic:setVisible(false)

    ---------- 录像回放相关----------------------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        stting_panel:setVisible(false)
    end
    --------------------------------------------------------------
end

function GameUIView:chahuButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.Button_chahu then
            --显示查胡
            --SoundManager.playEffect("btn", false);
            --self.m_delegate:onSelectChahuCardNtf();
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SELECTED_CHAHU_NTF);
        end
    end
end

function GameUIView:setChaHuButtonHide(event)
    local status = unpack(event._userdata)
    self.chaHuBtnStatus = status
end

--查胡状态
function GameUIView:checkChahuStatus()
    -- 如果在听之后才能显示胡牌提示, 那么非听牌状态直接return
    local players   = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local huHintNeedTing = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if huHintNeedTing and (tingState == enTingStatus.TING_FALSE or tingState == enTingStatus.TING_BTN_OFF) then
        self.Button_chahu:setVisible(false)
        return
    end

    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM);
    local huCards = playSystem:gameStartLogic_getHuMjs();
    if #huCards > 0 then
        self.Button_chahu:setVisible(self.chaHuBtnStatus ~= 1);
    else
        self.Button_chahu:setVisible(false);
    end
end

function GameUIView:jiesanBtnEvent()
    local data = {}
    data.type = 2
    data.content = "确认申请解散牌局吗？\n解散后按目前得分最终排名。"
    data.yesCallback = function()
    --[[
        type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
        ##  usI  long  玩家id
        ##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
        ##  niN  String  发起的用户昵称
        ##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
        if self._selectBtn.agree == false then
            local tmpData={}
            tmpData.usI =  kUserInfo:getUserId()
            tmpData.re = 1
            tmpData.niN = kUserInfo:getUserName()
            tmpData.isF = 0
            SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            Log.i("press GameAskDismiss")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameAskDismiss)
            self._selectBtn.agree = true
            if not tolua.isnull(self.button_jieshan) then
                self.button_jieshan:runAction(cc.Sequence:create(cc.DelayTime:create(self._selectBtn.agreeTime),cc.CallFunc:create(function() self._selectBtn.agree = false end)))
            end
        end
    end

    data.cancalCallback = function()
        Log.i("press cancalCallback")

    end

    data.closeCallback = function()
        Log.i("press closeCallback")

    end

    data.yesStr = "申请解散"                               --确定按钮文本
    data.cancalStr = "继续游戏"                            --取消按钮文本
    local cDialog = UIManager:getInstance():pushWnd(CommonDialog, data)

    --[[local yesBtn = cDialog:getYesBtn()
    local cancelBtn = cDialog:getCancelBtn()

    yesBtn:loadTextureNormal("games/common/game/common/btn_yellow.png")
    cancelBtn:loadTextureNormal("games/common/game/common/btn_gree.png")

    local size = yesBtn:getContentSize()

    local textureLeave = cc.Sprite:create("games/common/game/common/apply_leave.png")
    local textureContinue = cc.Sprite:create("games/common/game/common/continue_game.png")
    textureLeave:setPosition(cc.p(size.width * 0.5 + 2, size.height * 0.5))
    textureContinue:setPosition(cc.p(size.width * 0.5 + 2, size.height * 0.5))
    yesBtn:addChild(textureContinue)
    cancelBtn:addChild(textureLeave)]]
end

function GameUIView:sttingButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.button_stting then
            UIManager:getInstance():pushWnd(HallSetDialog, 2);
            SoundManager.playEffect("btn", false);
            Log.i("press setting")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameSetting)
        elseif pWidget == self.button_chat then
            Log.i("press chat")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChat)

            if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then
                MjProxy:getInstance():get_gameChatTxtCfg()
            end
            self.m_chatView = UIManager.getInstance():pushWnd(RoomChatView);
            self.m_chatView:setDelegate(self.m_delegate);
            SoundManager.playEffect("btn", false);
        elseif pWidget == self.button_jieshan then
            Log.i("press button_jieshan")

		    --告诉服务器玩家解散桌子
            if not IsPortrait then -- TODO
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameDismiss)
            end
			self:jiesanBtnEvent()
        elseif pWidget == self.button_weixin then

            Log.i("press button_wx")

            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameOpenWX)
            TouchCaptureView.getInstance():showWithTime()
            if IsPortrait then -- TODO
                if device.platform == "ios" then
                    device.openURL("weixin://")
                else
                    local data = {}
                    data.cmd = NativeCall.CMD_OPEN_WEIXIN
                    NativeCall.getInstance():callNative(data, function(info)
                        if info.errCode and info.errCode == -1 then
                            Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
                        end
                    end);
                end
            else
                --device.openURL("weixin://")
                local data = {}
                data.cmd = NativeCall.CMD_OPEN_WEIXIN
                NativeCall.getInstance():callNative(data, function(info)
                    if info.errCode and info.errCode == -1 then
                        Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
                    end
                end);
            end
        end
    end
end

--房间号
function GameUIView:updateRoomId()
    local playerInfos = kFriendRoomInfo:getRoomInfo()

    local room_Panel = self:getWidget(self.m_pWidget,"room_Panel")
    if IsPortrait then -- TODO
        local img_roomId=self:getWidget(self.m_pWidget,"img_roomid")
        img_roomId:setVisible(false)
        local room_id = cc.Label:createWithTTF("房号:"..MjProxy:getInstance():getRoomId(), "hall/font/fangzhengcuyuan.TTF", 20)--cc.Label:createWithBMFont("hall/font/room_num.fnt", MjProxy:getInstance():getRoomId())
        -- room_id:setScale(0.82)
        room_id:setColor(cc.c3b(187,238,168))
        room_id:setPosition(cc.p(50,img_roomId:getPositionY()))
        room_Panel:addChild(room_id)

        local img_paytype = self:getWidget(room_Panel,"img_paytype")
        img_paytype:setVisible(false)
        local room_pay=cc.Label:createWithTTF("", "hall/font/fangzhengcuyuan.TTF", 20)
        room_pay:setColor(cc.c3b(187,238,168))
        room_pay:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
        room_pay:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        room_Panel:addChild(room_pay)
        room_pay:setAnchorPoint(cc.p(0.5,1))
        room_pay:setPosition(cc.p(50,img_paytype:getPositionY()))

        local room_pay_ext=cc.Label:createWithTTF("", "hall/font/fangzhengcuyuan.TTF", 20)
        room_pay_ext:setColor(cc.c3b(187, 238, 168))
        room_pay_ext:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
        room_pay_ext:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        room_Panel:addChild(room_pay_ext)
        room_pay_ext:setAnchorPoint(cc.p(0.5, 1))
        room_pay_ext:setPosition(cc.p(50, img_paytype:getPositionY() - 26))
        room_pay_ext:setVisible(false)

        if IS_YINGYONGBAO then
            img_paytype:setVisible(false)
            return
        end

        if playerInfos.clI ~= nil and playerInfos.clI > 0 then
            img_paytype:loadTexture("hall/Common/clubpay.png", ccui.TextureResType.localType)

            room_pay_ext:setVisible(true)
            room_pay_ext:setString("亲友圈付费")
            local clubId = kFriendRoomInfo:getRoomInfo().clI
            room_pay:setString(string.format("亲友圈ID:%s", tostring(clubId)))
        else
            if playerInfos.RoFS and playerInfos.plS then
                if playerInfos.RoJST == 1 then          --是否需要考虑写成可拓展可配置的？
                    room_pay:setString("房主付费")
                    -- img_paytype:loadTexture("hall/Common/wonpay.png", ccui.TextureResType.localType)
                elseif playerInfos.RoJST == 2 then
                    room_pay:setString("大赢家付费")
                    -- img_paytype:loadTexture("hall/Common/winpay.png", ccui.TextureResType.localType)
                elseif playerInfos.RoJST == 3 then
                    room_pay:setString(string.format("AA付费\n(每人%s钻石)",math.ceil( playerInfos.RoFS / playerInfos.plS )))
                    -- local paynum = cc.Label:createWithBMFont("hall/font/room_num.fnt",math.ceil( playerInfos.RoFS / playerInfos.plS ))
                    -- paynum:setScale(0.82)
                    -- paynum:setPosition(cc.p(55,-16))
                    -- room_Panel:addChild(paynum)
                end
            else
                img_paytype:setVisible(false)
            end
        end
    else
        local room_id = cc.Label:createWithBMFont("hall/font/room_num.fnt", MjProxy:getInstance():getRoomId())
        room_id:setScale(0.82)
        room_id:setPosition(cc.p(90,29))
        room_Panel:addChild(room_id)

        local img_paytype = self:getWidget(room_Panel,"img_paytype")
        if playerInfos.clI ~= nil and playerInfos.clI > 0 then
            img_paytype:loadTexture("hall/Common/clubpay.png", ccui.TextureResType.localType)
        else
            if playerInfos.RoFS and playerInfos.plS then
                if playerInfos.RoJST == 1 then          --是否需要考虑写成可拓展可配置的？
                    img_paytype:loadTexture("hall/Common/wonpay.png", ccui.TextureResType.localType)
                elseif playerInfos.RoJST == 2 then
                    img_paytype:loadTexture("hall/Common/winpay.png", ccui.TextureResType.localType)
                elseif playerInfos.RoJST == 3 then
                    local paynum = cc.Label:createWithBMFont("hall/font/room_num.fnt",math.ceil( playerInfos.RoFS / playerInfos.plS ))
                    paynum:setScale(0.82)
                    paynum:setPosition(cc.p(55,-16))
                    room_Panel:addChild(paynum)
                end
            else
                img_paytype:setVisible(false)
            end
        end
    end
end

function GameUIView:parseLaPaoZuoDiBtn(parent, btns, dataList)
    table.sort(dataList, function(a, b) return a <= b end)
    local lastBtns = {}
    for i, v in ipairs(dataList) do
        table.insert(lastBtns, btns[v + 1]:clone())
    end

    parent:removeAllChildren()
    local size = parent:getContentSize()
    local i = 1
    while (i <= #lastBtns) do
        local btn = lastBtns[i]
        btn:setPosition(cc.p(size.width - btn:getContentSize().width * (#lastBtns - i + 0.5), size.height * 0.5))
        btn:setTouchEnabled(true)
        btn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn));
        parent:addChild(btn)
        i = i + 1
    end

    return lastBtns
end

--[[
    --@brief 解析拉跑坐底功能模块的版块
    --@param void
    --@return void
]]
function GameUIView:parseOpWidget()
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local players   = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local selfPlayer = players[enSiteDirection.SITE_MYSELF]
    local isBackar = selfPlayer:getProp(enCreatureEntityProp.BANKER)

    local xiaDiNum = selfPlayer:getProp(enCreatureEntityProp.XIA_DI_NUM)
    local xiaPaoNum = selfPlayer:getProp(enCreatureEntityProp.XIA_PAO_NUM)
    local xiaLaNum = selfPlayer:getProp(enCreatureEntityProp.XIA_LA_NUM)
    local xiaZuoNum = selfPlayer:getProp(enCreatureEntityProp.XIA_ZUO_NUM)

    self.diPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "di_panel")
    local hasDiAction = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_XIADI)
    self.diPanel:setVisible(hasDiAction and xiaDiNum == -1)
    self.diBtns = {}
    self:initDiPaoLaZuoPanel(self.diPanel, self.diBtns, 39)
    self.diBtns = self:parseLaPaoZuoDiBtn(self.diPanel, self.diBtns, playSystem:getGameStartDatas().xiaDiList)

    self.paoPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "pao_panel")
    local hasPaoPanel = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_XIA_PAO)
    self.paoPanel:setVisible(hasPaoPanel and xiaPaoNum == -1)
    self.paoBtns = {}
    self:initDiPaoLaZuoPanel(self.paoPanel, self.paoBtns, 29)
    self.paoBtns = self:parseLaPaoZuoDiBtn(self.paoPanel, self.paoBtns, playSystem:getGameStartDatas().xiaPaoList)

    -- 拉，只有闲家才能拉
    self.laPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "la_panel")
    local hasLaPanel = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_LAZHUANG)
    self.laPanel:setVisible(hasLaPanel and not isBackar and xiaLaNum == -1)
    self.laBtns = {}
    self:initDiPaoLaZuoPanel(self.laPanel, self.laBtns, 32)
    self.laBtns = self:parseLaPaoZuoDiBtn(self.laPanel, self.laBtns, playSystem:getGameStartDatas().xiaLaList)

    --坐，只有庄家才能坐
    self.zuoPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "zuo_panel")
    local hasZuoPanel = playSystem:checkLaPaoZuoDi(enOperate.OPERATE_ZUO)
    self.zuoPanel:setVisible(hasZuoPanel and isBackar and xiaZuoNum == -1)
    self.zuoBtns = {}
    self:initDiPaoLaZuoPanel(self.zuoPanel, self.zuoBtns, 33)
    self.zuoBtns = self:parseLaPaoZuoDiBtn(self.zuoPanel, self.zuoBtns, playSystem:getGameStartDatas().xiaZuoList)

    ---------- 录像回放相关----------------------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- stting_panel:setVisible(false)
        self.diPanel:setVisible(false)
        self.paoPanel:setVisible(false)
        self.laPanel:setVisible(false)
        self.zuoPanel:setVisible(false)
    end
    --------------------------------------------------------------
end

--[[
-- @brief 初始化底版块函数
-- @param panel 拉跑坐底的版块， btns 按钮的集合，tag 大模块的tag
-- @return void
]]
function GameUIView:initDiPaoLaZuoPanel(panel, btns, tag)
    local noSeleBtn = ccui.Helper:seekWidgetByName(panel, "no_btn")
    noSeleBtn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn))
    noSeleBtn:setTag(tag * 10)
    table.insert(btns, noSeleBtn)
    noSeleBtn:setTouchEnabled(true)

    for i = 1, 5 do
        local btn = ccui.Helper:seekWidgetByName(panel, "run_btn_" .. i)
        btn:setTag(tag * 10 + i)
        btn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn))
        btn:setTouchEnabled(true)
        table.insert(btns, btn)
    end
end

local function hideLaPaoZuoPanel(node, type)
    if type == enOperate.OPERATE_XIA_PAO then
        node.paoPanel:setVisible(false)
    elseif type == enOperate.OPERATE_LAZHUANG then
        node.laPanel:setVisible(false)
    elseif type == enOperate.OPERATE_ZUO then
        node.zuoPanel:setVisible(false)
    elseif type == enOperate.OPERATE_XIADI then
        node.diPanel:setVisible(false)
    end
end

function GameUIView:setLaPaoZuoBtns(enabled)
    for i, v in ipairs(self.diBtns) do
        v:setTouchEnabled(enabled)
    end

    for i, v in ipairs(self.laBtns) do
        v:setTouchEnabled(enabled)
    end

    for i, v in ipairs(self.zuoBtns) do
        v:setTouchEnabled(enabled)
    end

    for i, v in ipairs(self.paoBtns) do
        v:setTouchEnabled(enabled)
    end
end

--[[
    -- @底按钮的响应事件
    -- @param btn 按钮， EventType 事件类型
    -- @return void
]]
function GameUIView:onClickDiPaoLaZuoBtn(btn, EventType)
    if EventType == ccui.TouchEventType.began then
        -- self:setLaPaoZuoBtns(false)
    elseif EventType == ccui.TouchEventType.ended then
        local tag = btn:getTag()
        local oType = math.modf(tag/10)
        local oNum = tag%10
        hideLaPaoZuoPanel(self, oType)
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND,
        enMjMsgSendId.MSG_SEND_MJ_ACTION,
        oType, 1, oNum)
        -- self:setLaPaoZuoBtns(true)
    end
end

--[[
-- @brief  初始化定缺版块函数
-- @param  void
-- @return void
--]]
function GameUIView:initDingquePanel()
    self.dingquePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_dingque");
    self.dingquePanel:setVisible(true);

    local dingqueTip2 = ccui.Helper:seekWidgetByName(self.dingquePanel, "dingqueing_2");
    local dingqueTip3 = ccui.Helper:seekWidgetByName(self.dingquePanel, "dingqueing_3");
    local dingqueTip4 = ccui.Helper:seekWidgetByName(self.dingquePanel, "dingqueing_4");
    local setVisibleWithCheck = function(obj, value)
        if obj ~= nil and obj.setVisible ~= nil then
            obj:setVisible(value)
        end
    end

    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    if sys ~= nil then
        local playerNum = sys:getGameStartDatas().playerNum
        setVisibleWithCheck(dingqueTip2, true)
        setVisibleWithCheck(dingqueTip3, true)
        setVisibleWithCheck(dingqueTip4, true)
        if playerNum == 2 then
            setVisibleWithCheck(dingqueTip2, false)
            setVisibleWithCheck(dingqueTip4, false)
        elseif playerNum == 3 then
            setVisibleWithCheck(dingqueTip3, false)
        end
    end

    self.dingque_panself = ccui.Helper:seekWidgetByName(self.dingquePanel, "pan_self");
    --万
    self.btn_wan = ccui.Helper:seekWidgetByName(self.dingquePanel, "btn_wan")
    self.btn_wan:setTag(1);
    self.btn_wan:addTouchEventListener(handler(self, self.onClickDingque));
    --条
    self.btn_tiao = ccui.Helper:seekWidgetByName(self.dingquePanel, "btn_tiao")
    self.btn_tiao:setTag(2);
    self.btn_tiao:addTouchEventListener(handler(self, self.onClickDingque));
    --筒
    self.btn_tong = ccui.Helper:seekWidgetByName(self.dingquePanel, "btn_tong")
    self.btn_tong:setTag(3);
    self.btn_tong:addTouchEventListener(handler(self, self.onClickDingque));

    self.btn_wan:setTouchEnabled(true)
    self.btn_tiao:setTouchEnabled(true)
    self.btn_tong:setTouchEnabled(true)

    local players   = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    if IsPortrait then -- TODO
        local dingqueVal = players[enSiteDirection.SITE_RIGHT]:getProp(enCreatureEntityProp.DINGQUE_VAL);
        if dingqueVal > 0 then
            self.dingquePanel:setVisible(false);
            return;
        end
    end
    local dingqueVal = players[enSiteDirection.SITE_MYSELF]:getProp(enCreatureEntityProp.DINGQUE_VAL);
    if dingqueVal > 0 then
        self.dingque_panself:setVisible(false);
        if not IsPortrait then -- TODO
            setVisibleWithCheck(dingqueTip2, false)
            setVisibleWithCheck(dingqueTip3, false)
            setVisibleWithCheck(dingqueTip4, false)
        end
    end
end

function GameUIView:onDingqueAnimStart(event)
    Log.i("------GameUIView:onDingqueAnimStart event", unpack(event._userdata));
    local result, site, srcPoint, desPoint = unpack(event._userdata);
    local resultImg = nil;
    if site == enSiteDirection.SITE_MYSELF then
        if self.dingquePanel then
            self.dingquePanel:setVisible(false);
        end
    end

end

function GameUIView:onClickDingque(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        self.dingque_panself:setVisible(false);
        self.btn_wan:setTouchEnabled(false)
        self.btn_tiao:setTouchEnabled(false)
        self.btn_tong:setTouchEnabled(false)

        SoundManager.playEffect("btn");
        local tag = pWidget:getTag();
        local btnPositionX = pWidget:getPositionX();
        local btnPositionY = pWidget:getPositionY();
        local wp = self.dingque_panself:convertToWorldSpace(cc.p(btnPositionX, btnPositionY));
        local deWp = self.m_delegate:getDingQueResultPosition(1);
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_dingque_Anim_start, tag, 1, wp, deWp);
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_MJ_ACTION, enOperate.OPERATE_DINGQUE, 1, tag);
        self.dingque_panself:setVisible(false);
    end
end

function GameUIView:hideDingQuePanel()
    if self.dingquePanel then
        self.dingquePanel:setVisible(false);
    end
end

-------------------------------------------------------------------------
--
-----------------------------------
function GameUIView:onTouchSayButton(pWidget, EventType)
    -- Log.i("------GameUIView:onTouchSayButton--EventType", EventType);
    if EventType == ccui.TouchEventType.began then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameVoiceInput)

        if not YY_IS_LOGIN then
            --语音初始化失败
            Log.i("语音初始化失败")
            Toast.getInstance():show("功能未初始化完成，请稍后")
            return;
        end

        --开始录音
        if not self.m_isTouching then
            -- 停止播放录音
            local data = {}
            data.cmd = NativeCall.CMD_YY_STOP_PLAY
            NativeCall.getInstance():callNative(data);
            
            self.m_isTouchBegan = true;
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data);
            self:showMic();
            pWidget:stopAllActions()
            pWidget:performWithDelay(function()
                Toast.getInstance():show("语音超长自动发送");
                self:recordStop()
            end,60)
        end
    elseif EventType == ccui.TouchEventType.ended then
        if self.m_isTouchBegan then
            --停止录音
            pWidget:stopAllActions()
            self:recordStop()
        end
    elseif EventType == ccui.TouchEventType.canceled then
        --停止录音
        if  self.m_isTouchBegan then
            self.m_isTouchBegan = false;
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 0;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            pWidget:stopAllActions()
        end
    end
end

--停止录音
function GameUIView:recordStop()
    if self.m_isTouchBegan then
        self.m_isTouchBegan = false;
        local data = {};
        data.cmd = NativeCall.CMD_YY_STOP;
        data.send = 1;
        NativeCall.getInstance():callNative(data);
        self:hideMic();

        self.m_delegate:getUploadStatus();

        self.m_isTouching = true;
        self.m_delegate:performWithDelay(function ()
            self.m_isTouching = false;
        end, 0.5);
    end
end

function GameUIView:showMic()
    audio.pauseMusic();
    self.img_mic:stopAllActions();
    self.img_mic:setVisible(true);
    self.img_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameUIView:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("hall/friendRoom/mic/" .. self.img_mic_index .. ".png");
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

function GameUIView:hideMic()
    if not kSettingInfo:getGameVoiceStatus() then
        audio.resumeMusic();
    end
    self.img_mic:setVisible(false);
end

--[[
-- @brief  停止语音动作和延时
-- @param  void
-- @return void
--]]
function GameUIView:stopButtonAction()
    --防止没有收到播放结束回调
    self.Button_yuyin:stopAllActions();
    -- self.m_delegate:performWithDelay(function()
    --     self:hideSpeaking();
    -- end, 60);
end


return GameUIView;
