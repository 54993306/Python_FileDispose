-- 斗地主房间
-- Meditor管理类
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local PokerRoomChatView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomChatView")
local DDZPKGameoverView = require("package_src.games.paodekuai.pdkcommon.widget.DDZPKGameoverView")
local PokerOpenRoomGame = require("package_src.games.paodekuai.pdkcommon.widget.PokerOpenRoomGame")
local PokerRoomBase = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomBase")
local csvConfig = require("package_src.games.paodekuai.pdk.data.config_GameData")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local DDZSocketCmd = require("package_src.games.paodekuai.pdk.proxy.delegate.DDZSocketCmd")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local DDZChatView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZChatView")
local DDZTrustView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZTrustView")
local DDZNobiggerView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZNobiggerView")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local DDZStartingView =require("package_src.games.paodekuai.pdk.mediator.widget.DDZStartingView")
local DDZTopBarView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZTopBarView")
local DDZPlayerView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZPlayerView")
local DDZOprationView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZOprationView")
local DDZOprationResultView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZOprationResultView")
local DDZHandCardView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZHandCardView")
local DDZPKTotalGameoverView =  require("package_src.games.paodekuai.pdkcommon.widget.DDZPKTotalGameoverView")
local PokerDataConst = require("package_src.games.paodekuai.pdkcommon.data.PokerDataConst")
local DDZPKCardTypeAnalyzer = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZCard = require("package_src.games.paodekuai.pdk.utils.card.DDZCard")

local PokerRoomRuleView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomRuleView")
local PokerDismissDeskView = require("package_src.games.paodekuai.pdkcommon.widget.PokerDismissDeskView")
local PokerRoomSettingView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomSettingView")

local DDZMoreLayer = require("package_src.games.paodekuai.pdk.mediator.widget.DDZMoreLayer")
local DDZAnimView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZAnimView") 
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
-- 加入战绩
local DDZRecord = require "package_src.games.paodekuai.pdk.mediator.widget.DDZRecord"
local LocalEvent = require("app.hall.common.LocalEvent")
local UmengClickEvent = require("app.common.UmengClickEvent")

-- local DDZRecordwnd = DDZRecord.new()
local DDZRoom = class("DDZRoom", PokerRoomBase);

--背景音乐延迟时间
local nBgDelay = 0.5
--自动发送不叫的轮数
local autoCall = 4 - 1
--最大缓存语音数量
local nMaxVoiceNum = 10
--没有收到结束回调时默认隐藏语音条时间
local nDefHideSpeakTime = 60

----------------------------------------------
-- @desc 构造函数
----------------------------------------------
function DDZRoom:ctor()
    self.super.ctor(self, "package_res/games/ddz/room.csb");
    self:init_gameChatCfg()

    self.m_brocastContent = {};
    self.m_listeners = {}
    self:registMsgs()
    --语音聊天队列
    self.m_speakTable = {}

    --UI
    self.m_handCardViews = {}--手牌
    self.m_oprationViews = {}--操作面板
    self.m_oprationResultViews = {}--操作结果面板
    self.m_AnimView = nil --动画
    self.m_seatViews = {} -- 头像
    self.m_topBarView = nil --桌子顶部信息
    self.moreLayer = nil --更多界面
    self.chatView = nil  --聊天界面
    self.trustView = nil --托管界面
    self.isLockContinue = false 
    self.Events   = {};

    self.m_showSignal = true -- 是显示信号还是显示电量
    
    --朋友开房逻辑特殊处理
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        Log.i("当前游戏是从朋友开房进入")
        local baseNum = kFriendRoomInfo:getCurRoomBaseInfo().an; --底注
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BASEROOM, baseNum);
        local data ={}
        data.startGameWay = StartGameType.FIRENDROOM;
        data.m_delegate = self;
        data.roomGameType = FriendRoomGameType.DDZ; --打地主游戏
        self.m_friendOpenRoom = PokerOpenRoomGame.new(data)
    else
        local gameid = HallAPI.DataAPI:getGameId()
        local roomid = HallAPI.DataAPI:getRoomId()
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEID, gameid)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_ROOMID, roomid)
        self.roomInfo = HallAPI.DataAPI:getRoomInfoById(gameid, roomid);
        Log.i("PDKRoom: ctor baseNum is ", self.roomInfo)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BASEROOM, self.roomInfo.an);
    end

    ------------- 加入录像回放控制层-------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- 加入录像回放控制层
        if self._videoLayer then
            self._videoLayer:removeFromParent()
        end
        local data = {}
        data.isDDZ = true
        self._videoLayer = VideoControlLayer.new(data)
        PokerUIManager:getInstance():addToRoot(self._videoLayer,100);
    end

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
-- @desc 初始化ui函数
----------------------------------------------
function DDZRoom:onInit()
    SocketManager.getInstance().pauseDispatchMsg = false
    Log.i("PDKRoom:onInit")
    self.noBiggerView = DDZNobiggerView.new( ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_nobigger"))
    for i = 1, DDZConst.PLAYER_NUM  do
        self.m_seatViews[i] = DDZPlayerView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i), i)
        self.m_oprationViews[i] = DDZOprationView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration" .. i), i)
        self.m_oprationViews[i].m_pWidget:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self.m_oprationResultViews[i] = DDZOprationResultView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration_result" .. i), i)
        self.m_handCardViews[i] = DDZHandCardView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard" .. i), i)
        self.m_handCardViews[i].m_pWidget:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    end
    local img_bg1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg")
    img_bg1:loadTexture("package_res/games/ddz/bg.jpg")
    -- self.m_topBarView = DDZTopBarView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_topbar"))
    self.pan_topbar = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_topbar");
    self.pan_topbar:setVisible(false)
    self.m_AnimView = DDZAnimView.new( ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_anim"))

    local ui= ccui.Helper:seekWidgetByName(self.m_pWidget,"Panel_MoreLayer")
    self.moreLayer = DDZMoreLayer.new(ui)
    self.chatView = DDZChatView.new( ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_chat"))
    self.trustView = DDZTrustView.new( ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_trust"))

    self.btn_menu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_menu");
    self.btn_menu:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chat");
    self.btn_chat:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_voice_chat = ccui.Helper:seekWidgetByName(self.m_pWidget,"voice_chat")
    self.btn_voice_chat:addTouchEventListener(handler(self,self.onTouchSayButton))

    self.btn_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_touch");
    self.btn_root:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_root:setSwallowTouches(false)

    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_weixin")
    self.btn_share:addTouchEventListener(handler(self,self.onClickButton))
    self.room_id = ccui.Helper:seekWidgetByName(self.m_pWidget,"room_id")

    self.pan_roomInfo = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_room_info")
    self.lab_roomId = ccui.Helper:seekWidgetByName(self.pan_roomInfo,"lab_roomid")
    self.lab_roomPayType = ccui.Helper:seekWidgetByName(self.pan_roomInfo,"lab_paytype")
    self.lab_roomPayType_ext = ccui.Helper:seekWidgetByName(self.pan_roomInfo,"lab_paytype_ext")

    self.free_panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"free_panel")
    self.blb_bat = ccui.Helper:seekWidgetByName(self.m_pWidget, "blb_bat");

    self.btn_trust = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_tuoguan");
    self.btn_trust:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_rule = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_rule");
    self.btn_rule:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_jiesan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_jiesan");
    self.btn_jiesan:addTouchEventListener(handler(self, self.onClickButton));

    -- 加入战绩界面
    self.btn_record = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_record");
    self.btn_record:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_record:setVisible(true)

    self.panel_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_say")
    self.img_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_say1")

    self.top_beishu = ccui.Helper:seekWidgetByName(self.m_pWidget, "top_beishu");
    self.top_beishu:setVisible(false)
    self.top_beishu:setPositionY(self.top_beishu:getPositionY()+10)

    self.paodekuaiTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_144");
    self.paodekuaiTitle:loadTexture("package_res/games/pokercommon/paodekuai/pdklogo.png")
    self.paodekuaiTitle:setPositionY(self.paodekuaiTitle:getPositionY()-10)

    self.bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
    -- self.bg:setTouchEnabled(true)

    self.recordTishi = ccui.Helper:seekWidgetByName(self.m_pWidget, "recordTishi");
    self.recordTishi:addTouchEventListener(handler(self, self.onClickButton));
    self.recordTishi:setVisible(false)
    self.label_tishi = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_tishi");
    self.label_tishi:setColor(cc.c3b(70, 72, 79))

    self:showBase()
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        if VideotapeManager.getInstance():isPlayingVideo() then
            local roomID = kFriendRoomInfo:getRoomId()
            self.room_id:setString("房间号:" .. roomID)
        else
            local roomInfo = kFriendRoomInfo:getRoomInfo()
            self.room_id:setString("房间号:" .. roomInfo.roI)
        end
        self:setTrustBtnVisiable(false)
        self.btn_rule:setVisible(false)
        self.pan_roomInfo:setVisible(true)
    else
        self:hideWinxinSahre()
        self:setTrustBtnVisiable(true)
        self.btn_rule:setVisible(true) 
        self.pan_roomInfo:setVisible(false)
    end

end

----------------------------------------------
-- @desc 初始化之后的函数
----------------------------------------------
function DDZRoom:onShow()
    self.m_pWidget:setTouchEnabled(false);
    self.m_pWidget:setTouchSwallowEnabled(false);
    self:clearDesk();

    Log.i("HallAPI.DataAPI:getGameType()", HallAPI.DataAPI:getGameType())
    Log.i("HallAPI.DataAPI:StartGameType.FIRENDROOM()", StartGameType.FIRENDROOM)
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,0);
    end
    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    -- self:oneTest()
    --背景音乐
    self.m_pWidget:performWithDelay(function()
            self:playBgMusic();
    end, nBgDelay);

    --朋友开房逻辑特殊处理
    if(HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM and self.m_friendOpenRoom ~= nil) then
       Log.i("当前游戏是从朋友开房进入")
       self:updateRoomSceneInfo()
       self:updateRoomJushuInfo()
    else
        self:showStarting();
    end
    self:showTimeAndSingel()

end

-- 显示时间和信号信息
function DDZRoom:showTimeAndSingel()
    self.image_xinhao          = ccui.Helper:seekWidgetByName(self.m_pWidget, "signal");
    self.image_wifi            = ccui.Helper:seekWidgetByName(self.m_pWidget, "wifi");
    self.progressBar_pro = ccui.Helper:seekWidgetByName(self.m_pWidget, "ProgressBar_pro");
    self.label_time      = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_time");
    self.image_bat_bg      = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_bat");

    self:initTime()

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

function DDZRoom:addOneEventListener(eventName, listenerFunc)
    local signalLst = cc.EventListenerCustom:create(eventName, listenerFunc)
    table.insert(self.Events,signalLst)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalLst, 1)
end

function DDZRoom:updateSignal()
    self.image_wifi:stopAllActions()
    self.image_wifi:schedule(updateNativeSignal, 5)
    updateNativeSignal()

    self:addOneEventListener(LocalEvent.GameUISignal, handler(self,self.onUpdateSignal))
    self:addOneEventListener(NativeCall.Events.NetStateChange, updateNativeSignal)
end

function DDZRoom:onUpdateSignal(event)
    if type(event) ~= 'userdata' or type(event.data) ~= 'table' then
        return
    end
    local info = event.data
    Log.i("PDKRoom:onUpdateSignal info", info)
    if Util.table_eq(info, HallAPI.DataAPI:getNetStateInfo()) then
        return
    else
        HallAPI.DataAPI:setNetStateInfo(info)
        self:refreshSignalAndBattery(true)
    end
end

function DDZRoom:refreshSignalAndBattery(refreshSignal)
    Log.i("PDKRoom:refreshSignalAndBattery", "self.m_showSignal:", self.m_showSignal, "isWifi():", HallAPI.DataAPI:isWifi(), "refreshSignal:", refreshSignal)
    self.image_wifi:setVisible(self.m_showSignal and HallAPI.DataAPI:isWifi())
    self.image_xinhao:setVisible(self.m_showSignal and not HallAPI.DataAPI:isWifi())
    self.image_bat_bg:setVisible(not self.m_showSignal)

    if refreshSignal then
        local rssi = HallAPI.DataAPI:getNetStateInfo().rssi
        Log.i("PDKRoom:refreshSignalAndBattery", "rssi:", rssi)
        if rssi >= 4 then
            self.image_wifi:loadTexture("package_res/games/ddz/time/wifi_1.png")
        elseif rssi == 3 then
            self.image_wifi:loadTexture("package_res/games/ddz/time/wifi_2.png")
        elseif rssi == 2 then
            self.image_wifi:loadTexture("package_res/games/ddz/time/wifi_3.png")
        elseif rssi <= 1 then
            self.image_wifi:loadTexture("package_res/games/ddz/time/wifi_4.png")
        end
    end
end

function DDZRoom:updateBattery()
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

function DDZRoom:batteryCallBack(info)
    local event = cc.EventCustom:new(LocalEvent.GameUIBattery)
    event.data = info
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function DDZRoom:onUpdateBattery(event)
    Log.i("event..................",event.data)
    if event.data.baPro and self.progressBar_pro then
        self.progressBar_pro:setPercent(event.data.baPro)
    end
end


-- 初始化时间
function DDZRoom:initTime()

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


---------------------------------------
-- @聊天测试 后面会删除
--------------------------------------
function DDZRoom:oneTest()
    local content = "Aaaaaaaaa"
    for i = 1, DDZConst.PLAYER_NUM do 
        local info = {}
        local sex = 1
        if i % 3  == 1 then
            content = "Aaaaaaaaa111111"
        elseif i % 3  == 2 then
            content = "新年好啊， 新年好啊， 新年好啊， 新年好啊"
        elseif i % 3  == 0 then
            content = "新年好"
            --todo
        end
        info.content = content 
        info.ty = 2 
        info.sex = sex
        info.seat = i
        info.emI = 2
        -- info.headPos = self:getHeadPosBySeat(i)
        -- self.playerView[seat]:showDefaultChat(info);
        self.chatView:showDefaultChat(info)
    end
end

----------------------------------------------
-- @desc 播放背景音乐
----------------------------------------------
function DDZRoom:playBgMusic()
    kPokerSoundPlayer:playBGMusic(csvConfig.musicList["bgpath"]["path"], true);
    audio.setMusicVolume(HallAPI.SoundAPI:getMusicVolume())
    if HallAPI.SoundAPI:getMusicVolume() <= 0 then
        HallAPI.SoundAPI:pauseMusic()
    end
end

----------------------------------------------
-- @desc 设置托管按钮显示
----------------------------------------------
function DDZRoom:setTrustBtnVisiable(isVisible)
    if not tolua.isnull(self.btn_trust) then
        if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
            self.btn_trust:setVisible(false)
        else
            self.btn_trust:setVisible(isVisible)
        end
    end
end

----------------------------------------------
-- @desc 窗口关闭函数  注销事件 释放资源等
----------------------------------------------
function DDZRoom:onClose()
    Log.i("PDKRoom:onClose")
    HallAPI.SoundAPI:stopMusic()
    
    --朋友开房逻辑特殊处理
    if(self.m_friendOpenRoom~=nil) then
       self.m_friendOpenRoom:dtor();
       self.m_friendOpenRoom=nil
    end

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end
    
    if self.global then
        scheduler.unscheduleGlobal(self.global)
        self.global = nil
    end
    -- --是否有打开退出房间提示框
    -- if(PokerUIManager.getInstance():getWnd(CommonDialog)~=nil) then
    --    PokerUIManager.getInstance():popWnd(CommonDialog)
    -- end
    --  --是否有打开解散房间提示框
    -- if(DismissDeskView and PokerUIManager.getInstance():getWnd(DismissDeskView)~=nil) then
    --    PokerUIManager.getInstance():popWnd(DismissDeskView)
    -- end

    self:unRegistMsgs()

    -- self.m_topBarView:dtor()
    self.m_AnimView:dtor()
    self.moreLayer:dtor()
    self.chatView:dtor()
    self.trustView:dtor()
    self.noBiggerView:dtor()

    for k,v in pairs(self.m_handCardViews) do
        v:dtor()
    end
    for k,v in pairs(self.m_oprationViews) do
        v:dtor()
    end
    for k,v in pairs(self.m_oprationResultViews) do
        v:dtor()
    end
    for k,v in pairs(self.m_seatViews) do
        v:dtor()
    end

    scheduler.unscheduleGlobal(self.m_batteryScheduler)

    table.walk(self.Events,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.Events = {}

    self.image_xinhao = nil
    self.image_wifi = nil
    self.progressBar_pro = nil
    self.label_time = nil
    self.image_bat_bg = nil
    self.isLockContinue = nil
    
    if self.m_schedulerCheckCanPlay then
        scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
        self.m_schedulerCheckCanPlay = nil
    end
end

----------------------------------------------
-- @desc 注册事件监听
----------------------------------------------
function DDZRoom:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        table.insert(self.m_listeners, nhandle)
    end
    --网络消息
    addEvent(DDZGameEvent.ONGAMESTART)
    addEvent(DDZGameEvent.ONCALLLORD)
    addEvent(DDZGameEvent.ONROBLORD)
    addEvent(DDZGameEvent.ONDOUBLE)
    addEvent(DDZGameEvent.ONSTRATPLAY)
    addEvent(DDZGameEvent.ONOUTCARD)
    addEvent(DDZGameEvent.GAMEOVER)
    addEvent(DDZGameEvent.ONTUOGUAN)
    addEvent(DDZGameEvent.ONRECONNECT)
    addEvent(DDZGameEvent.ONEXITROOM)
    addEvent(DDZGameEvent.ONUSERDEFCHAT)
    addEvent(DDZGameEvent.RECVBROCAST)
    addEvent(DDZGameEvent.ONRECVENTERROOM)
    addEvent(DDZGameEvent.ONRECVREQDISSMISS)
    addEvent(DDZGameEvent.ONRECVDISSMISSEND)
    addEvent(DDZGameEvent.RESAYCHAT)
    addEvent(DDZGameEvent.ONRECVFRIENDCONTINUE)
    addEvent(DDZGameEvent.ONRECVTOTALGAMEOVER)
    addEvent(DDZGameEvent.ONLINE)

    -- addEvent(DDZGameEvent.)

    addEvent(DDZGameEvent.UPDATEOPERATION)

--游戏内事件
    addEvent(DDZGameEvent.UIREQCONTINUE)
    addEvent(DDZGameEvent.UIREQCHANGEDESK)
    addEvent(DDZGameEvent.ONDEALCARDEND)
    addEvent(DDZGameEvent.HIDEMORELAYER)
    addEvent(DDZGameEvent.SHOWSETTING)
    addEvent(DDZGameEvent.SHOWNOBIGGER)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_JIESAN)
    addEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CLOSE)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONFAIL)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONWEAK)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONEXCEPTION)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_RECONNECTED)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONNECTHEALTHLY)

    addEvent(PokerEventDef.GameEvent.GAME_SCORE_SETTLEMENT)



--大厅事件  
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_CLOSED)
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_CONNECT_FAILURE)
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_RECONNECTED)
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_CONNECTWEAK)
    addEvent(HallAPI.EventAPI.EXIT_GAME_FORCE)
end


----------------------------------------------
-- @desc 取消注册事件监听
----------------------------------------------
function DDZRoom:unRegistMsgs()
    Log.i("PDKRoom:unRegistMsgs")
    for k,v in pairs(self.m_listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

----------------------------------------------
-- @desc 监听事件分发
-- @pram id:注册事件id
--       ...:参数
----------------------------------------------
function DDZRoom:ListenToEvent(id, ... )
    Log.i("PDKRoom:ListenToEvent id", id)
    if id == DDZGameEvent.ONGAMESTART then
        self:onGameStart(...)
    elseif id == DDZGameEvent.ONCALLLORD then
        Log.i("--wangzhi--DDZGameEvent.ONCALLLORD--", ...)
        self:onCallLord(...)
    elseif id == DDZGameEvent.ONROBLORD then
        self:onRecvCallRob(...)
    elseif id == DDZGameEvent.ONDOUBLE then
        self:onRecvDouble(...)
    elseif id == DDZGameEvent.ONSTRATPLAY then
        self:onRecvStartPlay(...)
    elseif id == DDZGameEvent.ONOUTCARD then
        self:onRecvOutCard(...)
    elseif id == DDZGameEvent.GAMEOVER then
        self:onRecvGameOver(...)
    elseif id == DDZGameEvent.ONTUOGUAN then
        self:onRecvTuoGuan(...)
    elseif id == DDZGameEvent.ONRECONNECT then
        self:onRecvReconnect(...)
    elseif id == DDZGameEvent.ONEXITROOM or id == PokerEventDef.GameEvent.GAME_EXIT_GAME then
        self:onRecvExitRoom(...)
    elseif id == DDZGameEvent.ONUSERDEFCHAT then
        self:onRecvDefaultChat(...)
    elseif id == DDZGameEvent.RECVBROCAST then
        self:onRecvBrocast(...)
    elseif id == DDZGameEvent.ONRECVENTERROOM then
        self:showBase()
    elseif id == DDZGameEvent.ONRECVREQDISSMISS then
        self:onRecvReqDismiss(...)
        -- 收到解散的结果,放开锁定,并且判断是否续局
        self:GameContinue()
    elseif id == DDZGameEvent.ONRECVDISSMISSEND then
        self:onRecvDismissEnd(...)
    elseif id == DDZGameEvent.RESAYCHAT then
        self:onRecvSayChat(...)
    elseif id == DDZGameEvent.ONRECVFRIENDCONTINUE then
        self:onRecvFriendContinue(...)
    elseif id == DDZGameEvent.ONRECVTOTALGAMEOVER then
        self:onRecvFriendTotalOver(...)

    elseif id == DDZGameEvent.UPDATEOPERATION then
        self:updateOpration(...)
    elseif id == DDZGameEvent.UIREQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == DDZGameEvent.UIREQCONTINUE then
        self:reqContinueGame(...)
    elseif id == DDZGameEvent.ONDEALCARDEND then
        self:onDealcardEnd()
    elseif id == DDZGameEvent.HIDEMORELAYER then
        self:hideMoreLayer(...)
    elseif id == DDZGameEvent.SHOWSETTING then
        self:showSetting(...)
    elseif id == DDZGameEvent.SHOWNOBIGGER then
        self:showNoBigger(...)
    elseif id == PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT then
        self:keyBack()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER then
        self:gameOverUICallBack()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_JIESAN then
        self:jiesanBtnEvent()
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_CLOSE then
        self:onNetWorkClosed(...)
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_CONFAIL then
        self:onNetWorkConnectFail()
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_CONWEAK then
        self:onNetWorkWeak()
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_CONEXCEPTION then
        self:onNetWorkException()
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_RECONNECTED then
        self:onNetWorkReconnected()    
    elseif id == PokerEventDef.GameEvent.GAME_NETWORK_CONNECTHEALTHLY then
        self:onNetWorkConnectHealthly()
    elseif id == PokerEventDef.GameEvent.GAME_SCORE_SETTLEMENT then
        self:Settlement(...)
    --刷新离线状态
    elseif id == DDZGameEvent.ONLINE then
        self:onLineUpdate()
    -- elseif id == DDZGameEvent. then


    -- elseif id == DDZGameEvent. then
    elseif id == HallAPI.EventAPI.SOCKET_EVENT_CLOSED then
        self:onNetWorkClosed(...)
    elseif id == HallAPI.EventAPI.SOCKET_EVENT_CONNECT_FAILURE then
        self:onNetWorkConnectFail()
    elseif id == HallAPI.EventAPI.SOCKET_EVENT_RECONNECTED then
        self:onNetWorkReconnected()
    elseif id == HallAPI.EventAPI.SOCKET_EVENT_CONNECTWEAK then
        self:onNetWorkWeak()
    elseif id == HallAPI.EventAPI.EXIT_GAME_FORCE then
        self:onExitRoom()
    end
end

--[[
-- @brief  游戏第一局震动
-- @param  void
-- @return void
--]]
function DDZRoom:gameVibration()
    if SettingInfo.getInstance():getGameVibrationStatus() then
        local jushu = HallAPI.DataAPI:getJuNowCnt()
        Log.i("游戏第一局震动:" .. jushu)

        if jushu >1 or VideotapeManager.getInstance():isPlayingVideo() then
            return
        end
        --android/ios call 
        local data = {};
        data.cmd = NativeCall.CMD_SHAKE;
        data.send = 1;
        NativeCall.getInstance():callNative(data);
    end
end


----------------------------------------------
-- @desc 游戏开始
-- @pram dealCards:发的牌
--       firstID: 第一个出牌的人的id
----------------------------------------------
function DDZRoom:onGameStart(dealCards, firstID)
    Log.i("PDKRoom:onGameStart")
    self:gameVibration()
    self.m_isShowGameOverUI = false
    self:showBase()
    self:hideAllReady()
    self:resetHandCardView()
    self.trustView:hide()
    self.noBiggerView:hide()
    self:hideAllOprationResult()
    self:hideStarting()
    self:setTrustBtnVisiable(true)
    for i = 1, DDZConst.PLAYER_NUM  do
        self:updatePlayerInfo(i) 
    end

    self:onLineUpdate()
    if self.m_topBarView then
        self.m_topBarView:reset();
    end
    self:hideWinxinSahre()
    self:dealCard(false)

    self:sendLocationInfo()
    
    local nowJuCnt = HallAPI.DataAPI:getJuNowCnt()
    if (nowJuCnt - 1) == 1 then
        self.recordTishi:setVisible(true)
        local hideTishiTime = 3
        self.m_pWidget:performWithDelay(function()
            self.recordTishi:setVisible(false)
        end, hideTishiTime);
    end
end



function DDZRoom:onLineUpdate()
    for i=1,DDZConst.PLAYER_NUM  do
        self.m_seatViews[i]:showOnline()
    end
end

----------------------------------------------
-- @desc 更新玩家信息
-- @pram:seat 玩家座位id
----------------------------------------------
function DDZRoom:updatePlayerInfo(seat)
    self.m_seatViews[seat]:updatePlayerInfo()
end

----------------------------------------------
-- @desc 发牌
-- @pram isReconnect:是否重连
----------------------------------------------
function DDZRoom:dealCard(isReconnect)
    if not isReconnect then
        kPokerSoundPlayer:playEffect("fapai");
    end

    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        local seat = v:getProp(DDZDefine.SITE)
        self.m_handCardViews[seat]:dealCard(isReconnect);  
    end
end

----------------------------------------------
-- @desc 显示玩家操作选项
-- @pram playerId:玩家id
--       info:玩家显示操作相关信息
----------------------------------------------
function DDZRoom:showOpration(playerId, info)
    local isExist = DataMgr:getInstance():isPlayerExist(playerId)
    if not isExist then
        return 
    end
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("PDKRoom:showOpration seat", seat);
    -- Log.i("PDKRoom:showOpration info", info);
    if self:isLegalSeat(seat) then
        local status = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
        Log.i("PDKRoom:showOpration status", status);

        if status == DDZConst.STATUS_DOUBLE then
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_OPERATESEATID, 0)
        else
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_OPERATESEATID, seat)
        end
        self.m_oprationResultViews[seat]:hideOprationResult();
        self.m_oprationViews[seat]:hideOpration();
        self.m_oprationViews[seat]:showOpration(info);
        self.m_handCardViews[seat]:showOpration(info);
    end
end

----------------------------------------------
-- @desc 玩家seatid是否合法
-- @pram seat 玩家座位id
----------------------------------------------
function DDZRoom:isLegalSeat(seat)
    if seat and seat > DDZConst.SEAT_NONE and seat <= DDZConst.PLAYER_NUM then
        return true;
    end
    return false;
end

-------------------------------------------------------
-- @desc 叫地主
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function DDZRoom:onCallLord(packetInfo)

    Log.i("==========DDZRoom============fffffffffffffffffffffffffffff",packetInfo)
    self:showOprationResult(packetInfo.usI, packetInfo, true);
    --叫地主
    if packetInfo.fl == 1 then
        self:updateUserMulti()
    end

    --已确定地主
    if packetInfo.fl0 == 1 then
        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        self:setRole()
        self:updateUserMulti()

        if self.m_topBarView then
            self.m_topBarView:showBottomCard()
        end

        self:addBottomCard(lordId);
        self:showAllOpration();
    else
        self:showOpration(packetInfo.neP);
    end
end

----------------------------------------------
-- @desc 设置地主角色（地主 or 农民）
----------------------------------------------
function DDZRoom:setRole()
    for k, v in pairs(self.m_seatViews) do
        v:setRole();
    end
end

----------------------------------------------
-- @desc 设置玩家倍数 
----------------------------------------------
function DDZRoom:updateUserMulti()
    -- for k,v in pairs(self.m_seatViews) do
    --     v:setMultiple()
    -- end

    --更新倍数
    if self.m_topBarView then
        self.m_topBarView:updateTopMulti()
    end
end

----------------------------------------------
-- @desc 添加底牌 
-- @pram playerId :玩家id
----------------------------------------------
function DDZRoom:addBottomCard(playerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("PDKRoom:addBottomCard ",playerId, seat);
    if self:isLegalSeat(seat) then
        self.m_handCardViews[seat]:addBottomCard();
    end
end

----------------------------------------------
-- @desc 显示玩家操作
----------------------------------------------
function DDZRoom:showAllOpration()
    for seat = 1, DDZConst.PLAYER_NUM do
        self.m_oprationResultViews[seat]:hideOprationResult();
        self.m_oprationViews[seat]:hideOpration();
        self.m_oprationViews[seat]:showOpration();
    end
end

--------------------------------------------------------------
-- @desc 根据当前游戏状态显示操作结果
-- @pram palyerId:玩家id
--       info:相关信息
--       isReconnect:是否重连
--------------------------------------------------------------
function DDZRoom:showOprationResult(playerId, info, isReconnect)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("PDKRoom:showOprationResult seat", seat);
    Log.i("PDKRoom:showOprationResult info ", info);
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration();
        self.m_oprationResultViews[seat]:hideOprationResult();

        local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
        local sex = DDZConst.MALE
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId)
        if PlayerModel then
            sex = PlayerModel:getProp(DDZDefine.SEX)
        end
        
        Log.i("PDKRoom:showOprationResult gameStatus", gameStatus,isReconnect)
        if gameStatus == DDZConst.STATUS_CALL or (gameStatus == DDZConst.STATUS_ROB and isReconnect ) or (gameStatus == DDZConst.STATUS_DOUBLE and isReconnect )then --此处isReconnect表示上个玩家是否叫地主
            Log.i("--wangzhi--为何没进叫地主--",info.fl)
            self.m_oprationResultViews[seat]:onCallLord(info.fl)
        elseif gameStatus == DDZConst.STATUS_ROB then        
            self.m_oprationResultViews[seat]:onRobLord(info.fl)
        elseif gameStatus == DDZConst.STATUS_DOUBLE then 
            PlayerModel:setProp(DDZDefine.DOUBLE, info.cuD, true, seat)
            self.m_oprationResultViews[seat]:onEndRobLord(info.fl)
        elseif gameStatus == DDZConst.STATUS_PLAY then
            PlayerModel:delCards(info.cards, true)
            self.m_oprationResultViews[seat]:onPlayCard(info)
            self.m_handCardViews[seat]:onPlayCard(info, isReconnect, sex)
            if not info.cards then return end
            if info.fl == 0 then
            else
                self:showCardType(seat, info.cardType, #info.cards)   
            end
        elseif gameStatus == DDZConst.STATUS_GAMEOVER then
            self.m_oprationResultViews[seat]:onGameOver(info, playerId, sex)
            self.m_handCardViews[seat]:onGameOver(info, playerId, sex)
            self.trustView:hide()
            self.noBiggerView:hide()
        end
    end
end


----------------------------------------------
-- @desc 牌型动画 
-- @pram seat :玩家座位id
--       cardType:牌型
--       cardLength:牌的长度
----------------------------------------------
function DDZRoom:showCardType(seat, cardType, cardLength)
    self.m_AnimView:showCardTypeAnim(seat, cardType, cardLength);
end

-------------------------------------------------------
-- @desc 抢地主
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function DDZRoom:onRecvCallRob(packetInfo)
    Log.i("PDKRoom:onRecvCallRob", packetInfo)
    self:showOprationResult(packetInfo.usI, packetInfo);
    if packetInfo.fl == 1 then
        self:updateUserMulti()
    end
    if packetInfo.fl0 == 1 then
        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        self:setRole(lordId, 1)
        self:updateUserMulti()
        if self.m_topBarView then
            self.m_topBarView:showBottomCard();
        end

        self:addBottomCard(lordId);
        self:showAllOpration();
        --self:showOpration(packetInfo.neP)
    else
        self:showOpration(packetInfo.neP);
    end
end


-------------------------------------------------------
-- @desc 加倍
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function DDZRoom:onRecvDouble(packetInfo)
    Log.i("PDKRoom:onRecvDouble",packetInfo)
    packetInfo = checktable(packetInfo);
    if packetInfo.usI == HallAPI.DataAPI:getUserId() then
        if packetInfo.cuD > 1 then
            self:showGameAnim(DDZConst.SEAT_MINE, 3);
        end
    end

    self:updateUserMulti()
    self:showOprationResult(packetInfo.usI, packetInfo);
end

-------------------------------------------------------
-- @desc 开始打牌
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function DDZRoom:onRecvStartPlay(packetInfo)
    Log.i("PDKRoom",packetInfo)
    packetInfo = checktable(packetInfo)

    self:hideAllOpration();
    self:hideAllOprationResult();

    local info = {};
    info.isMustOut = true;
    self:showOpration(packetInfo.fiPI, info);
    if packetInfo.mapInfos and #packetInfo.mapInfos>0 then
        for k,v in pairs(packetInfo.mapInfos) do
            if tonumber(k) ~= HallAPI.DataAPI:getUserId() then
                self:showOprationResult(tonumber(k),packetInfo);
            end
        end
    end 
end


-------------------------------------------------------
-- @desc 出牌
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function DDZRoom:onRecvOutCard(packetInfo, isReconnect)
    kPokerSoundPlayer:playEffect("card_out")
    Log.i("PDKRoom:onRecvOutCard",packetInfo)
    packetInfo = checktable(packetInfo);

    self:hideOpration(packetInfo.usI);

    if not isReconnect then
        local cards = packetInfo.plC or {};
        local cardValues = {};
        -- for k, v in pairs(cards) do
        --     local type, val = DDZCard.cardConvert(v);
        --     table.insert(cardValues, val);
        -- end
        DDZGUIZE.isSiteMy = false
        local cardType, keyCard = DDZPKCardTypeAnalyzer.getCardType(cards);
        if cardType >= DDZCard.CT_BOMB then
            self:updateUserMulti()
        end

        local outCardInfo = {};
        outCardInfo.cards = cards;
        outCardInfo.cardValues = cardValues;
        outCardInfo.cardType = cardType;
        _,outCardInfo.keyCardValue = DDZCard.cardConvert(keyCard);
        outCardInfo.fl = packetInfo.fl;
        outCardInfo.usI = packetInfo.usI
        outCardInfo.mapInfos = packetInfo.mapInfos
        Log.i("--wangzhi--正常对局出牌属性--",outCardInfo)
        self:showOprationResult(packetInfo.usI, outCardInfo, isReconnect);
    else
        local cardsList = packetInfo.gplC or {};
        Log.i("========== isReconnecsssss",cardsList)

        for k,v in pairs(cardsList) do

            local cardValues = {};
            for kay, vule in pairs(v.cards) do
                if vule ~= 0 then
                    -- local type, val = DDZCard.cardConvert(vule);
                    -- table.insert(cardValues, val);
                    packetInfo.fl = 1
                else
                    packetInfo.fl = 0
                end
            end
            
            local cardType, keyCard = DDZPKCardTypeAnalyzer.getCardType(cardValues);

            local outCardInfo = {};
            outCardInfo.cards = v.cards;
            outCardInfo.cardValues = cardValues;
            outCardInfo.cardType = cardType;
            _,outCardInfo.keyCardValue = DDZCard.cardConvert(keyCard);
            outCardInfo.fl = packetInfo.fl;
            outCardInfo.usI = v.userId
            outCardInfo.mapInfos = packetInfo.mapInfos
            Log.i("--wangzhi--断线重连出牌属性--",outCardInfo)
            self:showOprationResult(outCardInfo.usI, outCardInfo, isReconnect);
        end
    end

    if packetInfo.neP > 0 then
        local info = {};
        info.isMustOut = false;
        info.playCard = true
        if packetInfo.neP == HallAPI.DataAPI:getUserId() then
            local lastOutCards = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_LASTOUTCARDS)
            Log.i("lastOutCards :", lastOutCards)
            if not lastOutCards or #lastOutCards == 0 then
                info.isMustOut = true;
            elseif cardType == DDZCard.CT_MISSILE then
                info.autoNotOut = true;
            end
            local handCardView = self.m_handCardViews[DDZConst.SEAT_MINE]
            local isBigger = handCardView.m_handCardView:checkIsBiggerCard()
            info.isBigger = isBigger
        end 
        self:showOpration(packetInfo.neP, info);
    end
end

-------------------------------------------------------
-- @desc 叫地主
-- @return 无
-- @pram packetInfo 网络包
--       sp (spring)
-------------------------------------------------------
function DDZRoom:onRecvGameOver(packetInfo)
    --[[--  原有斗地主的结算
    -- -- Log.i("onRecvGameOver packetInfo",packetInfo)
    self:onTuoGuanChangeAll();
    self:setTrustBtnVisiable(false)
    self.m_pWidget:performWithDelay(function()
        

        if packetInfo.sp == 2 then
            self:showGameAnim(DDZConst.SEAT_MINE, 1);
        elseif packetInfo.anS == 2 then
            self:showGameAnim(DDZConst.SEAT_MINE, 2);
        end
        self:updateUserMulti()

        --显示结算界面
        self.m_pWidget:performWithDelay(function()
            -- PokerUIManager.getInstance():popToWnd(DDZRoom);
            local gameoverView = PokerUIManager.getInstance():pushWnd(DDZPKGameoverView, packetInfo);
            gameoverView:setDelegate(self); 
        end, DDZConst.DELAY_SHOW_CARD); 

    end, DDZConst.DELAY_LAST_CARD);
    --]]

    ---[[ 跑的快只播放动画,不进单局结算
    self.m_pWidget:performWithDelay(function()
        local AnimTimeNo1 = 0

        local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
        local guanpai = false
        for i,v in pairs(PlayerModelList) do
            local userId = v:getProp(DDZDefine.USERID)
            for j,jv in pairs(packetInfo.plI1) do
                if jv.plI == userId and jv.st > 0 then
                    local seat = v:getProp(DDZDefine.SITE)
                    local player = self.m_seatViews[seat]
                    local playerWidget = player.m_pWidget
                    local plCS = playerWidget:getContentSize()
                    local pos = cc.p(playerWidget:getPositionX() + plCS.width/2,playerWidget:getPositionY() + plCS.height/2)
                    self.m_AnimView:showGuanAnim(jv.st + 2,pos,seat)
                    guanpai = true
                end
            end
        end

        if guanpai then
            self.m_AnimView:showGuanAnim(1)
            AnimTimeNo1 = 1
        end

        --显示结算界面
        self.m_pWidget:performWithDelay(function()
            local myWinAnimTime = 3
            -- 判断是否赢了
            for i,v in ipairs(packetInfo.wiIds) do
                if HallAPI.DataAPI:getUserId() == v then
                    -- 播放赢了的动画
                    self:showGameAnim(DDZConst.SEAT_MINE, 4);
                    -- myWinAnimTime = myWinAnimTime + 2
                    break
                end
            end
            for k, v in pairs(packetInfo.plI1) do
                self:showOprationResult(v.plI, v);
             end

            for i,v in pairs(PlayerModelList) do
                local userId = v:getProp(DDZDefine.USERID)
                local seat = v:getProp(DDZDefine.SITE)
                --飘分
                for j,jv in pairs(packetInfo.AGR.playFenMap) do
                    if tostring(j) == tostring(userId) and tonumber(jv) ~= 0 then
                        local function addMoney()
                            self.m_seatViews[seat]:setMoney(v:getProp(DDZDefine.MONEY) + jv - DataMgr:getInstance():GetPlayerScore(userId))
                        end
                        self:SettlementAnimation(seat,jv - DataMgr:getInstance():GetPlayerScore(userId),1.5,0.5,addMoney)
                       
                    end
                end
                --显示剩余牌数
                for j,jv in pairs(packetInfo.AGR.playCloseCardMap) do
                    if tostring(j) == tostring(userId) then
                        if #jv > 0 then
                            self:DrawGameOverCardsNumber(seat,table.nums(jv))
                        else
                            self:DrawGameOverWin(seat)
                        end
                    end
                end
            end
            
            self:DrawGameOVerTimer()
            self.m_pWidget:performWithDelay(function()

                local nowJuCnt = HallAPI.DataAPI:getJuNowCnt()
                local juTotal = HallAPI.DataAPI:getJuTotal()

                local disMissFlag = DataMgr:getInstance():getDisMissFlag()
                Log.i("--wangzhi--disMissFlag--",disMissFlag)
                -- 判断游戏是否结束
                if HallAPI.DataAPI:isGameEnd() then
                    if not PokerUIManager:getInstance():getWnd(DDZPKTotalGameoverView) then
                        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
                    end
                -- 增加判断,防止牌局状态还未完成
                elseif (nowJuCnt - 1) == juTotal and not disMissFlag then
                    self:GameTotalOver()
                elseif not disMissFlag then
                    if not PokerUIManager:getInstance():getWnd(DDZPKTotalGameoverView) then
                        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE,1)
                    end
                elseif disMissFlag then  
                    self.isLockContinue = true 
                    Log.i("--wangzhi--是否进了锁定--",self.isLockContinue)
                end
            end, myWinAnimTime);
        end, AnimTimeNo1); 
    end, 0.5); 
end

function DDZRoom:GameContinue()
    -- 锁定还未解除
    local disMissFlag = DataMgr:getInstance():getDisMissFlag()
    Log.i("--wangzhi--GameContinue--",self.isLockContinue,disMissFlag)
    if not self.isLockContinue or disMissFlag then
        Log.i("--wangzhi--直接return",self.isLockContinue,disMissFlag)
        return
    end

    local nowJuCnt = HallAPI.DataAPI:getJuNowCnt()
    local juTotal = HallAPI.DataAPI:getJuTotal()

    -- 判断游戏是否结束
    if HallAPI.DataAPI:isGameEnd() then
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
    -- 增加判断,防止牌局状态还未完成
    elseif (nowJuCnt - 1) == juTotal then
        self:GameTotalOver()
    else
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE,1)
    end    
    self.isLockContinue = false
end

-- 开启一个调度器,判断牌局是否结束
function DDZRoom:GameTotalOver()
    if self.m_getGameTotalOverThread then
        scheduler.unscheduleGlobal(self.m_getGameTotalOverThread)
    end
    self.m_getGameTotalOverThread = scheduler.scheduleGlobal(function()
        if HallAPI.DataAPI:isGameEnd() then
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
            scheduler.unscheduleGlobal(self.m_getGameTotalOverThread);
            self.m_getGameTotalOverThread = nil;
        end
    end, 0.1)
end

--函数功能：    显示玩家结算剩余牌数
--site:         玩家位置
--number:       牌的数量
--返回值：      无
function DDZRoom:DrawGameOverCardsNumber(site,number)
    local player = self.m_seatViews[site]
    local playerWidget = player.m_pWidget
    self.m_score_layer = self.m_score_layer or {}
    self.m_score_layer[site] = display.newLayer()
    local pwCS = playerWidget:getContentSize()
    local pos = cc.p( pwCS.width/2,pwCS.height+20)
    if site == DDZConst.SEAT_RIGHT  then
        pos = cc.p( -160,pwCS.height+20)
    elseif site == DDZConst.SEAT_LEFT then
        pos = cc.p( pwCS.width + 150,pwCS.height+25)
    elseif site == DDZConst.SEAT_MINE then
        pos = cc.p( pwCS.width + 145,pwCS.height+25)
    end
    self.m_score_layer[site]:setPosition(pos)
    self.m_score_layer[site]:addTo(playerWidget)

    local color = cc.c3b(255,163,102)
    local label = string.format("%d",number)
    local font = "package_res/games/pokercommon/font/num4.fnt"
    local score_label = display.newBMFontLabel({
        text = label,
        font = font,
        size = 30,
        color = color,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })
    score_label:setAnchorPoint(cc.p(0,0.5))
    score_label:addTo( self.m_score_layer[site])
    local labelCS = score_label:getContentSize()
    local shengyu = display.newSprite("package_res/games/pokercommon/paodekuai/img_shengyu.png")
    shengyu:addTo( self.m_score_layer[site])
    shengyu:setPosition(cc.p(-shengyu:getContentSize().width/2,13))
    
    local zhangpai = display.newSprite("package_res/games/pokercommon/paodekuai/img_pai.png")
    zhangpai:addTo( self.m_score_layer[site])
    zhangpai:setPosition(cc.p(zhangpai:getContentSize().width/2 + labelCS.width,13))
end

--函数功能：    显示赢了的文字
--site:        玩家位置
--返回值：      无
function DDZRoom:DrawGameOverWin(site)
    local player = self.m_seatViews[site]
    local playerWidget = player.m_pWidget
    local pwCS = playerWidget:getContentSize()
    local pos = cc.p( pwCS.width/2,pwCS.height)
    if site == DDZConst.SEAT_RIGHT  then
        pos = cc.p( -150,pwCS.height + 30)
    elseif site == DDZConst.SEAT_LEFT or site == DDZConst.SEAT_MINE then
        pos = cc.p( pwCS.width + 117,pwCS.height + 40)
    end
    self.m_winImage = display.newSprite("package_res/games/pokercommon/paodekuai/img_yingle.png")
    self.m_winImage:addTo(playerWidget)
    self.m_winImage:setPosition(pos)
end

--函数功能：    结算倒计时
function DDZRoom:DrawGameOVerTimer()
    local widget = self.m_pWidget
    local pwCS = widget:getContentSize()
    self.m_gameOvertimer = display.newSprite("package_res/games/pokercommon/paodekuai/img_youxikaishi.png")
    self.m_gameOvertimer:addTo(widget)
    local timerCS = self.m_gameOvertimer:getContentSize()
    self.m_gameOvertimer:setAnchorPoint(cc.p(0,0))
    self.m_gameOvertimer:setPosition(cc.p(display.cx - timerCS.width/2,display.cy))
    local kuohao_l = display.newSprite("package_res/games/pokercommon/paodekuai/img_kuohao.png")
    kuohao_l:setPosition(cc.p(display.cx+timerCS.width/2 + 5,display.cy + timerCS.height/2))
    kuohao_l:addTo(widget)
    local kuohao_r = display.newSprite("package_res/games/pokercommon/paodekuai/img_kuohao.png")
    kuohao_r:setPosition(cc.p(display.cx+timerCS.width/2 + 47,display.cy + timerCS.height/2))
    kuohao_r:setScale(-1)
    kuohao_r:addTo(widget)
    
    local juNowCnt = HallAPI.DataAPI:getJuNowCnt() or 0
    local juTotal = HallAPI.DataAPI:getJuTotal() or 0
    if juNowCnt > juTotal then
        self.m_gameOvertimer:setVisible(false)
        kuohao_l:setVisible(false)
        kuohao_r:setVisible(false)
    end
    local timerNumber = 3
	local function drawLabel()
		timerNumber = timerNumber or 0
        if timerNumber <= 0 then
			if self.m_score_layer and table.nums(self.m_score_layer) > 0 then
                for i,v in pairs(self.m_score_layer) do
                    if v then
                        v:removeFromParent()
                        v = nil
                    end
                end
            end
            self.m_score_layer = nil
            if  self.m_winImage then
                self.m_winImage:removeFromParent()
                self.m_winImage = nil
            end
            
            if self.m_gameOvertimer then
                self.m_gameOvertimer:removeFromParent()
                self.m_gameOvertimer = nil
            end
            
            if kuohao_l then
                kuohao_l:removeFromParent()
                kuohao_l = nil
            end
           
            if kuohao_r then
                kuohao_r:removeFromParent()
                kuohao_r = nil
            end
            
            if self.global then
                scheduler.unscheduleGlobal(self.global)
                self.global = nil
            end
            
            if self.label_timer then
                self.label_timer:removeFromParent()
                self.label_timer = nil
            end
            return
        end
        local color = cc.c3b(249,201,73)
        local label = string.format("%ds",timerNumber)
        if not self.label_timer then
            local font = "package_res/games/pokercommon/font/num3.fnt"
            self.label_timer = display.newTTFLabel({
                text = label,
                font = "hall/font/fangzhengcuyuan.TTF",
                size = 30,
                color = color,
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
            self.label_timer:addTo(widget)
            local labelCs = self.label_timer:getContentSize()
            self.label_timer:setPosition(cc.p(display.cx+timerCS.width/2 + labelCs.width/2 + 10,display.cy + timerCS.height/2))
        else
            self.label_timer:setString(label)
        end
        timerNumber = timerNumber - 1
        local juNowCnt = HallAPI.DataAPI:getJuNowCnt() or 0
		local juTotal = HallAPI.DataAPI:getJuTotal() or 0
		if juNowCnt > juTotal then
            self.label_timer:setVisible(false)
        end
    end
    drawLabel()
    self.global = scheduler.scheduleGlobal(function()
        drawLabel()
    end,1)
end

----------------------------------------------
-- @desc 托管改变玩家状态 
----------------------------------------------
function DDZRoom:onTuoGuanChangeAll()
    for i =1, DDZConst.PLAYER_NUM do
        self.m_seatViews[i]:onTuoGuanChange();
    end
end

----------------------------------------------
-- @desc 游戏动画 
-- @pram seat :玩家座位id
--       type:动画类型
----------------------------------------------
function DDZRoom:showGameAnim(seat, type)
    self.m_AnimView:showGameAnim(seat, type);
end

----------------------------------------------
-- @desc 游戏托管 
-- @pram packetInfo :网络消息
--##            托管玩家id maPI
--##            是否被托管 isM
----------------------------------------------
function DDZRoom:onRecvTuoGuan(packetInfo)

    -- Log.i("PDKRoom onRecvTuoGuan packetInfo", packetInfo);
    PokerUIManager.getInstance():popToWnd(self)
    self:onTuoGuanChange(packetInfo.maPI, packetInfo);
end

----------------------------------------------
-- @desc 添加底牌 
-- @pram playerId :玩家id
--       packetInfo :网络消息
----------------------------------------------
function DDZRoom:onTuoGuanChange(playerId, packetInfo)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    -- Log.i("PDKRoom:onTuoGuanChange ", seat);
    if self:isLegalSeat(seat) then
        local tuoguanState = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
        Log.i("tuoguanState", tuoguanState);
        if tuoguanState == DDZConst.TUOGUAN_STATE_1 then
            self.trustView:show()
        else
            self.trustView:hide()
        end
        self.m_handCardViews[seat]:onTuoGuanChange(playerId);
        self.m_oprationViews[seat]:onTuoGuanChange();
        self.m_seatViews[seat]:onTuoGuanChange(packetInfo);
    end
end

----------------------------------------------
-- @desc 重连成功 
-- @pram packetInfo :网络消息
----------------------------------------------
function DDZRoom:onRecvReconnect(packetInfo)
    Log.i("onRecvReconnect packetInfo", packetInfo)
    packetInfo = checktable(packetInfo);
    -- PokerToast.getInstance():show("恢复对局成功");
    self:clearDesk()
    self:hideAllReady()
    self:setTrustBtnVisiable(true)
    self:hideStarting()

    for i = 1, DDZConst.PLAYER_NUM  do
        self:updatePlayerInfo(i)
    end

    self:onLineUpdate()
    if self.m_topBarView then
        self.m_topBarView:reset()
        self.m_topBarView:showBottomCard(true);
        self:updateUserMulti()
    end

    if packetInfo.loI and packetInfo.loI > 0 then
        self:setRole( packetInfo.loI, 1);
    end

    self:dealCard(packetInfo.plI1, true);

    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)

    Log.i("================gameStatus============",gameStatus)
    if gameStatus == DDZConst.STATUS_CALL or gameStatus == DDZConst.STATUS_ROB then
        local userID = HallAPI.DataAPI:getUserId()
        if packetInfo.fiPUID == -1 and packetInfo.cuPl == userID and gameStatus == DDZConst.STATUS_CALL then
            self:showOpration(packetInfo.cuPl);
        else
            self:showOpration(packetInfo.fiPUID);           
        end
    elseif gameStatus == DDZConst.STATUS_DOUBLE then
        for k, v in pairs(packetInfo.plI1) do
            if v.cuD and v.cuD == -1 then
                self:showOpration(v.plI);
            end
        end
    end

    for k, v in pairs(packetInfo.plI1) do
       self:updateTips(v.plI, v);
    end

    self:updateWanfa()
end

--函数功能：   更新封顶
--返回值：     无
function DDZRoom:uodateTopBeiShu()
    local beishu = DataMgr:getInstance():getFullBeiShu()
    if beishu then
        self.top_beishu:setVisible(true)
        self.top_beishu:setString(string.format("%d倍封顶",beishu))
    end
end

-- 创建规则提示
-- function DDZRoom:createRuleTip()
--     Log.i("BgLayer:createRuleTip")
--     local ruleStrRet = kFriendRoomInfo:getRuleStrRet(kRuleWidth, kRuleFontSize)
--     -- 非回放且大于一行时, 将规则说明放到GameUIView中
--     if not VideotapeManager.getInstance():isPlayingVideo() and ruleStrRet.rows > 1 then
--         self:addRuleBtn()
--     elseif ruleStrRet.rows > 0 then
--         self:createCustomRuleTip(ruleStrRet.ruleStr)
--     end
-- end


---------------------
-- 添加规则按钮
function DDZRoom:addRuleBtn()
    Log.i("-----------DDZRoom:addRuleBtn()------------")
    local logoPosY = self.paodekuaiTitle:getPositionY()
    local beishuPosY = self.top_beishu:getPositionY()
    local kRuleBtnSize = cc.size(100, 70)
    local parent = self.top_beishu:getParent()
    -- 规则触摸容器
    self.ruleBtnLayout = ccui.Layout:create()
    self.ruleBtnLayout:setContentSize(kRuleBtnSize)
    -- self.btn_root:addChild(self.ruleBtnLayout)
    self.bg:addChild(self.ruleBtnLayout)

    self.ruleBtnLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.ruleBtnLayout:setPosition(cc.p(display.cx, 180))

    -- 文字
    self.ruleBtnLabel = cc.Label:createWithTTF("规则", "hall/font/fangzhengcuyuan.TTF", 25)
    self.ruleBtnLabel:setColor(cc.c3b(255,255,255))
    self.ruleBtnLabel:setOpacity(128)
    self.ruleBtnLabel:setPosition(cc.p(kRuleBtnSize.width *0.5, kRuleBtnSize.height *0.5))
    -- self.ruleBtnLabel:setPositionY(logoPosY- 30)
    self.ruleBtnLayout:addChild(self.ruleBtnLabel)
    self.ruleBtnLayout:setPositionY(beishuPosY-15)


    -- self.ruleBtnLayout:setBackGroundColorType(1)
    -- self.ruleBtnLayout:setBackGroundColor(cc.c3b(255, 0, 0))
    -- 下划线
    local labelSize = self.ruleBtnLabel:getContentSize()
    local startX = self.ruleBtnLabel:getPositionX() - labelSize.width * self.ruleBtnLabel:getAnchorPoint().x
    local startY = self.ruleBtnLabel:getPositionY() - labelSize.height * self.ruleBtnLabel:getAnchorPoint().y
    local points = {}
    points[1] = {startX, startY}
    points[2] = {startX + labelSize.width, startY}
    local ruleBtnLineParams = {}
    ruleBtnLineParams.borderColor = cc.c4f(255 / 255, 255 / 255, 255 / 255, 100/255)
    ruleBtnLineParams.borderWidth = 1.5
    self.ruleBtnLine = display.newLine(points, ruleBtnLineParams)
    self.ruleBtnLine:addTo(self.ruleBtnLayout)

    -- 触摸事件
    self.ruleBtnLayout:setTouchEnabled(true)
    self.ruleBtnLayout:setTouchSwallowEnabled(true)
    self.ruleBtnLayout:addTouchEventListener(function (pWidget,EventType)
        if EventType == ccui.TouchEventType.ended then
            Log.i("ended", pWidget:getTouchEndPosition().x)
            self:showRuleLabel(true)
        elseif EventType == ccui.TouchEventType.began then
            Log.i("began", pWidget:getTouchBeganPosition().x)
        end
    end)
end

--函数功能：   更新封顶
--返回值：     无
function DDZRoom:updateWanfa()
    local wanfa = DataMgr:getInstance():getWanfaData()
    local wanfa2 = DataMgr:getInstance():getWanfaData()
    Log.i("--wangzhi--updateWanfa--wanfa--",wanfa)
    
    local lineCount = 1
    if wanfa then
        local tmpWanfa = ""
        for i=1,#wanfa do
            local w = wanfa[i]
            if kFriendRoomInfo:getPlayingInfoByTitle2(w) then
                tmpWanfa =tmpWanfa .." ".. kFriendRoomInfo:getPlayingInfoByTitle2(w).ch
            end
        end
        local wanfaLen = string.len(tmpWanfa)
        local tmpWanfa3 = ""
        local isChangeLine = false
        if wanfaLen > 60 then
            local tmpWanfa2 = ""
            for i=1,#wanfa2 do
                local w2 = wanfa2[i]
                if kFriendRoomInfo:getPlayingInfoByTitle2(w2) then

                    if i==1 then
                        tmpWanfa2 = kFriendRoomInfo:getPlayingInfoByTitle2(w2).ch
                    else
                        tmpWanfa2 =tmpWanfa2 .." ".. kFriendRoomInfo:getPlayingInfoByTitle2(w2).ch
                    end
                    
                    local wanfaLen2 = string.len(tmpWanfa2)
                    if not isChangeLine and wanfaLen2 > wanfaLen/2 then
                        tmpWanfa3 =tmpWanfa3 .." ".. kFriendRoomInfo:getPlayingInfoByTitle2(w2).ch.."\n"
                        isChangeLine = true
                        lineCount = lineCount + 1
                    else
                        if i==1 then
                            tmpWanfa3 = kFriendRoomInfo:getPlayingInfoByTitle2(w2).ch
                        else
                            tmpWanfa3 =tmpWanfa3 .." ".. kFriendRoomInfo:getPlayingInfoByTitle2(w2).ch
                        end                        
                    end
                end
            end
        else
            tmpWanfa3 = tmpWanfa
        end
        local logoPosY = self.paodekuaiTitle:getPositionY()
        self.top_beishu:setVisible(true)
        self.top_beishu:setString(tmpWanfa3)
        -- self.top_beishu:setPositionY(logoPosY- 110)
        self.top_beishu:setFontSize(24)
        -- if HallAPI.DataAPI:getJuNowCnt() == 1 then
        --     self.top_beishu:setPositionY(self.top_beishu:getPositionY()-10)
        -- end

        if not VideotapeManager.getInstance():isPlayingVideo() and lineCount > 1  then
            if not self.ruleBtnLabel then
                self:addRuleBtn()                
            end
            self:showRuleLabel(false)
        end

    end
end

function DDZRoom:showRuleLabel(state)
    self.ruleBtnLayout:setVisible(not state)
    self.top_beishu:setVisible(state)
end

--函数功能：   重登更新叫地主，抢地主，加倍等提示
--返回值：     无
--playerId：   玩家id
--info：       玩家信息
function DDZRoom:updateTips(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("PDKRoom:updateTips seat", seat);
    Log.i("PDKRoom:updateTips info ", info);
    if self:isLegalSeat(seat) then
        self.m_oprationResultViews[seat]:hideOprationResult();

        local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
        Log.i("PDKRoom:updateTips gameStatus", gameStatus)
        if gameStatus == DDZConst.STATUS_CALL or (gameStatus == DDZConst.STATUS_ROB) then
            self.m_oprationResultViews[seat]:updateCallTips(info.staV)
        -- elseif(gameStatus == DDZConst.STATUS_DOUBLE) then
        --     self.m_oprationResultViews[seat]:updateDoubleTips(info.staV)
        end
    end
end
----------------------------------------------
-- @desc 退出结果 
-- @pram packetInfo :网络消息
----------------------------------------------
function DDZRoom:onRecvExitRoom(packetInfo)
    self:onExitRoom();
end

----------------------------------------------
-- @desc 退出到大厅 
----------------------------------------------
function DDZRoom:onExitRoom()
    Log.i("PDKRoom:onExitRoom")
    local FileLog = require("app.common.FileLog")
    FileLog.manualUploadLogs()
    
    -- Toast.releaseInstance();
    -- LoadingView.releaseInstance();
    HallAPI.DataAPI:clearRoomData()
    PokerUIManager.getInstance():popAllWnd();
    cc.Director:getInstance():popScene();
end

---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function DDZRoom:onRecvSayChat(packetInfo)
    Log.i("PDKRoom say chat packetInfo:",packetInfo)
    if packetInfo.ty == DDZConst.CHATTYPE.VOICECHAT then
        if packetInfo.co then
            local status = kSettingInfo:getPlayerVoiceStatus()
            if status and packetInfo.usI ~= HallAPI.DataAPI:getUserId() then
               Log.i("关闭玩家语音。。。。。。。。");
            else
                self:showSpeaking(packetInfo);
            end
        end
    elseif packetInfo.ty == DDZConst.CHATTYPE.CUSTOMCHAT then
        local seat = DataMgr:getInstance():getSeatByPlayerId(packetInfo.usI);
        if self:isLegalSeat(seat) then
            info = {}
            info.ty = DDZConst.TEXTTYPE
            info.content = packetInfo.co 
            -- self.m_seatViews[seat]:showCustomChat(info)
            info.seat = seat
            self.chatView:showCustomChat(info)
        end
    end
end

---------------------------------------
-- 函数功能：    续局重置头像
-- 返回值：      无
-- packetInfo:   服务器返回数据
---------------------------------------
function DDZRoom:onRecvFriendContinue(packetInfo)
    -- if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
    --     return 
    -- end
    Log.i("PDKRoom:onRecvFriendContinue", packetInfo)
    for i,v in ipairs(packetInfo.usI) do
        local seat = DataMgr.getInstance():getSeatByPlayerId(v)
        if self.m_seatViews[seat] then
            self.m_seatViews[seat]:reset()
            self.m_seatViews[seat]:showReady()
        end
    end
    
end

---------------------------------------
-- 函数功能：    续局重置头像
-- 返回值：      无
-- packetInfo:   服务器返回数据
---------------------------------------
function DDZRoom:OnRecvRoomReWard()
    local totalData = DataMgr.getInstance():getObjectByKey(PokerDataConst.DataMgrKey_FRIENDTOTALDATA)
    PokerUIManager.getInstance():popToWnd(DDZRoom);
    local gameoverView = PokerUIManager.getInstance():pushWnd(DDZPKTotalGameoverView, totalData);
end

---------------------------------------
-- 函数功能：    续局重置头像
-- 返回值：      无
-- packetInfo:   服务器返回数据
---------------------------------------
function DDZRoom:hideAllReady()
    for i=1,DDZConst.PLAYER_NUM do
        if self.m_seatViews[i] then
            self.m_seatViews[i]:hideReady()
        end
    end  
end

---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function DDZRoom:showSpeaking(packetInfo)
    Log.i("PDKRoom showSpeaking",packetInfo)
    if not YY_IS_LOGIN then
        return ;
    end
    
    if packetInfo and packetInfo.usI and #self.m_speakTable < nMaxVoiceNum then

        Log.i("**************************** showSpeaking2")
        table.insert(self.m_speakTable, packetInfo);
    end
    self:playNextSpeaking()
end

function DDZRoom:canPlayNextSpeaking()
    if self.m_speaking then
        return false
    elseif self.m_isTouchBegan then
        return false
    else
        return true
    end
end

function DDZRoom:playNextSpeaking()
    if self:canPlayNextSpeaking() then
        Log.i("DDZRoom:canPlayNextSpeaking() self.m_speakTable", self.m_speakTable)
        self:playSpeaking(table.remove(self.m_speakTable, 1))
    elseif not self.m_schedulerCheckCanPlay then
        self.m_schedulerCheckCanPlay = scheduler.scheduleGlobal(
            function()
                if not next(self.m_speakTable) then
                    scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
                    self.m_schedulerCheckCanPlay = nil
                end

                if self:canPlayNextSpeaking() then
                    Log.i("DDZRoom:m_schedulerCheckCanPlay() self.m_speakTable", self.m_speakTable)
                    self:playSpeaking(table.remove(self.m_speakTable, 1))
                    scheduler.unscheduleGlobal(self.m_schedulerCheckCanPlay);
                    self.m_schedulerCheckCanPlay = nil
                end
            end, 0.1);
    end
end

function DDZRoom:playSpeaking(packetInfo)
    --local playerInfos = kFriendRoomInfo:getRoomInfo();
    --Log.i("**************************** showSpeaking1",playerInfos)
    local playerInfos = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    Log.i("**************************** showSpeaking3",#playerInfos)
    for k, v in pairs(playerInfos) do
        if v:getProp(DDZDefine.USERID) == packetInfo.usI then
           Log.i("v:getProp(DDZDefine.SITE)", v:getProp(DDZDefine.SITE))
            if self.m_seatViews[v:getProp(DDZDefine.SITE)] then
                self.m_speaking = true;
                self.m_seatViews[v:getProp(DDZDefine.SITE)]:showSpeaking();
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
                self.btn_voice_chat:stopAllActions();
                self.btn_voice_chat:performWithDelay(function()
                    self:hideSpeaking();
                end, nDefHideSpeakTime);
            end
            break;
        end
    end
end

---------------------------------------
-- 函数功能：    隐藏聊天
-- playerId      玩家id
---------------------------------------
function DDZRoom:hideSpeaking(playerId)
    Log.i("PDKRoom:hideSpeaking", playerId)
    playerId = playerId or "0"
    local playerInfos = DataMgr.getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    for k, v in pairs(playerInfos) do
        Log.i("PDKRoom:hideSpeaking1")
        if v:getProp(DDZDefine.USERID) == tonumber(playerId) then
        Log.i("PDKRoom:hideSpeaking2")

            if self.m_seatViews[v:getProp(DDZDefine.SITE)] then
        Log.i("PDKRoom:hideSpeaking3")

                self.m_seatViews[v:getProp(DDZDefine.SITE)]:hideSpeaking()
            end
            break
        end
    end
    self.m_speaking = false
    audio.resumeMusic()
    if #self.m_speakTable > 0 then
        self:playNextSpeaking()
    end
end
---------------------------------------
-- 函数功能：    检测语音播放状态
-- 返回值：      无
---------------------------------------
function DDZRoom:getSpeakingStatus()
    Log.i("PDKRoom:getSpeakingStatus")
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

function DDZRoom:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        if self.m_getSpeakingThread and COMPATIBLE_VERSION < 1 then
            scheduler.unscheduleGlobal(self.m_getSpeakingThread);
            self.m_getSpeakingThread = nil;
        end
        self:hideSpeaking(info.usI);
    end
end

----------------------------------------------
-- @desc 请求换桌 
-- @pram isReq 是否请求换桌
----------------------------------------------
function DDZRoom:reqChangeDesk(isReq)
    Log.i("PDKRoom:reqChangeDesk ", isReq)
    self:playBgMusic();
    self:showStarting();
    if not isReq then
        Log.i("PDKRoom:reqChangeDesk1 ", isReq)
        return;
    end
    Log.i("PDKRoom:reqChangeDesk2 ", isReq)

    PokerUIManager.getInstance():popToWnd(DDZRoom);
    if DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS) > DDZConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS) == DDZConst.STATUS_GAMEOVER then
        Log.i("PDKRoom:reqChangeDesk 3", isReq)
        self:clearDesk();
    end
end

----------------------------------------------
-- @desc 内置聊天 
-- @pram packetInfo :网络消息
----------------------------------------------
function DDZRoom:onRecvDefaultChat(packetInfo)
    if packetInfo.re == 1 then
        if packetInfo.ty == 1 or packetInfo.ty == 2 then 
            self:showDefaultChat(packetInfo.usI, packetInfo);
        else
            self:showDefaultChat(packetInfo.usI, packetInfo, packetInfo.reI);
        end
    else
        PokerToast.getInstance():show("发送失败");
    end
end

----------------------------------------------
-- @desc 内置聊天 
-- @pram playerId :玩家id
--       packetInfo :网络消息
--       dplayerId:暂时没有用到
----------------------------------------------
function DDZRoom:showDefaultChat(playerId, info, dplayerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        info.seat = seat
        if info.ty == 3 then
        else

            local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId);
            local sex = PlayerModel:getProp(DDZDefine.SEX)
            info.sex = sex
            if info.ty == 2 then
                info.content = self:getChatContent(sex, info.emI)
            end
            -- self.m_oprationResultViews[seat]:showDefaultChat(info);
            self.chatView:showDefaultChat(info)
        end
    end
end

----------------------------------------------
-- @desc 续局 
----------------------------------------------
function DDZRoom:reqContinueGame()
    Log.i("PDKRoom:reqContinueGame : ")
    self:playBgMusic()
    self:showStarting()

    PokerUIManager.getInstance():popToWnd(DDZRoom)
    local status = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    if status > DDZConst.STATUS_NONE or status == DDZConst.STATUS_GAMEOVER then
        self:clearDesk()
        self:updateRoomJushuInfo()
    end
end

----------------------------------------------
-- @desc 發牌結束的一些處理 --当第四轮的时候 直接默认给后台发送不叫 
----------------------------------------------
function DDZRoom:onDealcardEnd()
    local firstID = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_OPERATESEATID)
    local nocall = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_NOCALLTURN);
    Log.i("nocall is ",nocall)
    if nocall < autoCall then
        self:showOpration(firstID)
    end
end

----------------------------------------------
-- @desc 收起更多頁面 
----------------------------------------------
function DDZRoom:hideMoreLayer()
    self.btn_menu:setRotation(0)
    self.moreLayer:hidehide()
end

----------------------------------------------
-- @desc 显示设置 
----------------------------------------------
function DDZRoom:showSetting()
    PokerUIManager:getInstance():pushWnd(PokerRoomSettingView)
end

----------------------------------------------
-- @desc 是否显示"没有牌过的上大家" 
-- @pram isShow:是否显示
----------------------------------------------
function DDZRoom:showNoBigger(isShow)
    Log.i("PDKRoom:showNoBigger", isShow)
    if isShow then
        self.noBiggerView:show()
    else
        self.noBiggerView:hide()
    end
end

----------------------------------------------
-- @desc 被踢下线 
-- @pram packetInfo :网络消息  暂时不用
----------------------------------------------
function DDZRoom:onRecvBrocast(packetInfo)
    Log.i("PDKRoom:onRecvBrocast packetInfo")
    if packetInfo.ti == DDZConst.MULTILOGIN then
        SocketManager.getInstance():closeSocket()
        SocketManager.getInstance().m_status = NETWORK_EXCEPTION -- 设置网络状态, 使得在 MainScene:onEnter 函数中可以跳转到登录界面
        
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.contentType = COMNONDIALOG_TYPE_KICKED;
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理";
        data.yesCallback = function ()
            Log.i("enter the tirne")
            PokerUIManager.getInstance():popAllWnd(true)
            self:onExitRoom();
        end
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data, 255);
    elseif packetInfo.ti == DDZConst.CLOSESERVER then -- 关服通知
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data, 255);
    end
end

----------------------------------------------
-- @desc 显示跑马灯 
-- @pram content :跑马灯内容
----------------------------------------------
function DDZRoom:showBrocast(content)
    if content then
        self.pan_notice = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_notice");
        if not self.pan_notice:isVisible() then
            if not self.lb_notice then
                self.lb_notice = self:getWidget(self.m_pWidget, "lb_notice", {bold = true});
            end
            self.pan_notice:setVisible(true);
            self.lb_notice:setString(content);
            local size = self.lb_notice:getContentSize();
            local moveX = -808 - size.width;
            local showTime = -moveX/130;
            transition.execute(self.lb_notice, cc.MoveBy:create(showTime, cc.p(moveX, 0)), {
                onComplete = function()
                    self.lb_notice:setPosition(cc.p(808, 21));
                    self.pan_notice:setVisible(false);
                    --
                    if #self.m_brocastContent > 0 then
                        local content = table.remove(self.m_brocastContent, 1);
                        self:showBrocast(content);
                    end
                end
            });
        else
            table.insert(self.m_brocastContent, content);
        end
    end     
end

----------------------------------------------
-- @desc 清除牌桌 
----------------------------------------------
function DDZRoom:clearDesk()
    self:setTrustBtnVisiable(false)
    self.noBiggerView:hide()
    self.trustView:hide()
    self:clearAllPlayer()
    -- self:resetTopBar()
end

----------------------------------------------
-- @desc 重置 
----------------------------------------------
function DDZRoom:resetTopBar()
    self.m_topBarView:reset()

end

----------------------------------------------
-- @desc 清除玩家 
----------------------------------------------
function DDZRoom:clearAllPlayer()
    self.m_playerInfos = {};
    for seat = 1, DDZConst.PLAYER_NUM do
        if self.m_seatViews[seat] then
            self.m_seatViews[seat]:reset()
        end
        if self.m_oprationViews[seat] then
            self.m_oprationViews[seat]:hideOpration();

        end
        if self.m_handCardViews[seat] then
            self.m_handCardViews[seat]:reset();
        end
        if self.m_oprationResultViews[seat] then
            self.m_oprationResultViews[seat]:hideOprationResult();
        end
    end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function DDZRoom:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        if pWidget == self.btn_back then
            self:keyBack();
        elseif pWidget == self.btn_menu then
            self.btn_menu:setRotation(-180)
            self.moreLayer:showshow()
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKMoreButton)
        elseif pWidget == self.btn_setting then
            PokerToast.getInstance():show("暂未开发");
        elseif pWidget == self.btn_reconnect then
            local data = {};
            data.plI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_RESUMEGAME, data);
        elseif pWidget == self.btn_chat then
            local chatView = PokerUIManager.getInstance():pushWnd(PokerRoomChatView, self.gameChatTxtCfg, 0);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameChatText)
        elseif pWidget == self.btn_root then
            self:onClickRoot();
        elseif pWidget == self.btn_trust then
            local data = {};
            data.maPI = HallAPI.DataAPI:getUserId();
            data.isM = 1;
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_TUOGUAN, data);
        elseif pWidget == self.btn_rule then
            local info = {}
            info.gamepath = "ddz"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView, info);
        elseif pWidget == self.btn_share then
            -- self:onWxLogic(2)
        elseif pWidget == self.btn_jiesan then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameDissmissRoom)
            self:jiesanBtnEvent()
        elseif pWidget == self.btn_canceltrust then
            local data = {};
            data.maPI = HallAPI.DataAPI:getUserId();
            data.isM = 0;
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_TUOGUAN, data);
        elseif pWidget == self.btn_record then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameRecord)
            local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()
            if not next(matchTotalInfo) then
                PokerToast.getInstance():show("还没有战绩，请对局后再查看");
                return
            else
                self.recordTishi:setVisible(false)
                PokerUIManager:getInstance():pushWnd(DDZRecord)       
            end
        elseif pWidget == self.recordTishi then
            self.recordTishi:setVisible(false)
        end
    end
end


---------------------------------------------------
-- @desc点击语音按钮
-- @pram pWidget :点击的ui
--       EventType:点击的类型
---------------------------------------------------
function DDZRoom:onTouchSayButton(pWidget, EventType)
    Log.i("************")
    if EventType == ccui.TouchEventType.began then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameVoiceInput)

        if not YY_IS_LOGIN then
            --语音初始化失败
            Log.i("语音初始化失败")
            Toast.getInstance():show("功能未初始化完成，请稍后")
            return;
        end

        if not self.m_isTouching then
            -- 停止播放录音
            local data = {}
            data.cmd = NativeCall.CMD_YY_STOP_PLAY
            NativeCall.getInstance():callNative(data);

            self.m_isTouchBegan = true;
            --开始录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_START;
            NativeCall.getInstance():callNative(data);
            self:showMic();
            HallAPI.SoundAPI:stopMusic()
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
            self:playBgMusic()
            
            self:getUploadStatus();

            self.m_isTouchBegan = false;
            self.m_isTouching = true;
            self.m_pWidget:performWithDelay(function ()
                self.m_isTouching = false;
            end, 0.5);
        end
        -- self.m_isTouchBegan = false;
        -- local tmpData  ={};
        -- tmpData.usI = HallAPI.DataAPI:getUserId();
        -- tmpData.niN = HallAPI.DataAPI:getUserName();
        -- tmpData.roI = HallAPI.DataAPI:getRoomInfo().roI;
        -- tmpData.ty = 1;
        -- tmpData.co = ""
        -- HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,tmpData)
    elseif EventType == ccui.TouchEventType.canceled then
        if  self.m_isTouchBegan then
            --停止录音
            local data = {};
            data.cmd = NativeCall.CMD_YY_STOP;
            data.send = 0;
            NativeCall.getInstance():callNative(data);
            self:hideMic();
            self:playBgMusic()
            -- self.beginSayTxt:setString("按住 说话");

            self.m_isTouchBegan = false;
        end
    end
end

---------------------------------------
-- 函数功能：  显示录音动画
-- 返回值：    无
---------------------------------------
function DDZRoom:showMic()
    self.img_mic:stopAllActions();
    self.panel_mic:setVisible(true);
    self.panel_mic_index = 0;
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
end

---------------------------------------
-- 函数功能：  播放语音动画
-- 返回值：    无
---------------------------------------
function DDZRoom:updateMic()
    Log.i("*******************",self.panel_mic_index)
    self.panel_mic_index = self.panel_mic_index + 1;
    if self.panel_mic_index > 4 then
        self.panel_mic_index = 0;
    end
    self.img_mic:loadTexture("common/" .. self.panel_mic_index .. ".png" , ccui.TextureResType.plistType)
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
 end

 ---------------------------------------
-- 函数功能：  停止语音动画
-- 返回值：    无
---------------------------------------
function DDZRoom:hideMic()
    self.panel_mic:setVisible(false);
    self.img_mic:stopAllActions();
end


---------------------------------------
-- 函数功能：  检测语音上传状态
-- 返回值：    无
---------------------------------------
function DDZRoom:getUploadStatus()
    Log.i("*************************PokerRoomChatSay4")
    if COMPATIBLE_VERSION < 1 then
        if self.m_getUploadThread then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
            self.m_getUploadThread = nil
        end
        self.m_getUploadThread = scheduler.scheduleGlobal(function()
            Log.i("*************************PokerRoomChatSay5")
            local data = {};
            data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
            NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
        end, 0.1);
    end
end

---------------------------------------
-- 函数功能：  检测完成发送语音消息
-- 返回值：    无
---------------------------------------
function DDZRoom:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus 1", info.fileUrl);
    if info.fileUrl then
        if self.m_getUploadThread and COMPATIBLE_VERSION < 1 then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
            self.m_getUploadThread = nil;
        end
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus 2", matchStr, HallAPI.DataAPI:getRoomId());

         --发送语音聊天
         if matchStr and HallAPI.DataAPI:getRoomId() then
            local tmpData  ={};
            tmpData.usI = HallAPI.DataAPI:getUserId();
            tmpData.niN = HallAPI.DataAPI:getUserName();
            tmpData.roI = HallAPI.DataAPI:getRoomInfo().roI;
            tmpData.ty = DDZConst.CHATTYPE.VOICECHAT
            tmpData.co = info.fileUrl;
            Log.i("dispatch say event")
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,tmpData)
        end

    end
end

----------------------------------------------
-- @desc 点击牌以外地方（重选牌） 
----------------------------------------------
function DDZRoom:onClickRoot()
    self.root_click_time = self.root_click_time or 1;
    self.root_click_time = self.root_click_time + 1;
    Log.i("------onClickButton self.root_click_time", self.root_click_time);
    if self.m_clear_click_time then
        self.m_pWidget:stopAction(self.m_clear_click_time);
        self.m_clear_click_time = nil;
    end 
    if self.root_click_time == 2 then
        self.root_click_time = 1;
        local info = {};
        info.action = "chongxuan";
        --self:onClickChongXuanBtn(info);
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
    else
        self.m_clear_click_time = self.m_pWidget:performWithDelay(function()
            self.root_click_time = 1;
        end, 0.5);
    end

    if self.ruleBtnLayout and not self.ruleBtnLayout:isVisible() then
        self:showRuleLabel(false)
    end
end

----------------------------------------------
-- @desc 显示速配倒计时 
----------------------------------------------
function DDZRoom:showStarting()
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        return
    end

    if not self.m_startingView then
        local mWidget = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_starting");
        self.m_startingView = DDZStartingView.new(mWidget, 20);
    end

    self.m_startingView:show();
    self.btn_chat:setVisible(false); 
end

----------------------------------------------
-- @desc 隐藏速配倒计时 
----------------------------------------------
function DDZRoom:hideStarting()
    if self.m_startingView then
        self.m_startingView:hide();
    end
    self.btn_chat:setVisible(true);
end

----------------------------------------------
-- @desc 显示底注 
----------------------------------------------
function DDZRoom:showBase()
    Log.i("PDKRoom:showBase")
    self.blb_base = ccui.Helper:seekWidgetByName(self.m_pWidget, "blb_base");
    local baseNum = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_BASEROOM);
    self.blb_base:setString("底分：" .. baseNum);
    -- self.blb_base:setLocalZOrder(-100)

    self:updateWanfa()

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        self:updateRoomJushuInfo()
    end
end

----------------------------------------------
-- @desc 显示设置 
----------------------------------------------
function DDZRoom:showSettingView()
    local settingView = PokerUIManager.getInstance():pushWnd(RoomMenuView);
    settingView:setDelegate(self);
end

----------------------------------------------
-- @desc 隐藏微信分享按钮 
----------------------------------------------
function DDZRoom:hideWinxinSahre()
    self.btn_share:setVisible(false)
    self.room_id:setVisible(false)
end

----------------------------------------------
-- @desc 返回 
----------------------------------------------
function DDZRoom:keyBack()
    if self:isInGame() then
        local data = {}
        data.type = 2;
        data.title = "提示";                        
        data.yesTitle  = "退出游戏";
        data.cancelTitle = "关闭";
        data.content = "现在离开会由笨笨的机器人代打哦！\n\n 输了不能怪它哟！";
        data.yesCallback = function()
            HallAPI.EventAPI:dispatchEvent(DDZGameEvent.REQEXITROOM)
        end
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data);
    else
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.REQEXITROOM)
    end
end

----------------------------------------------
-- @desc 是否在游戏中 
----------------------------------------------
function DDZRoom:isInGame()
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    Log.i("gameStatus is ", gameStatus)
    if gameStatus >= DDZConst.STATUS_CALL and gameStatus <= DDZConst.STATUS_PLAY then
        return true
    end
    return false
end

----------------------------------------------
-- @desc 更新房间玩家信息 
----------------------------------------------
function DDZRoom:updateRoomSceneInfo()
    for i=1, DDZConst.PLAYER_NUM do
        -- self.GameLogic:getSeatView(i):reset()
    end

    local playerInfos = kFriendRoomInfo:getRoomInfo()
    if VideotapeManager.getInstance():isPlayingVideo() then
        playerInfos.pl = playerInfos.plI1
    end
    for i,v in ipairs(playerInfos.pl) do
        -- self.GameLogic:getSeatView(i):updateHeadImg(v)
    end
end

----------------------------------------------
-- @desc 初始化聊天内容 
----------------------------------------------
function DDZRoom:init_gameChatCfg()
    Log.i("PDKRoom:init_gameChatCfg")
    local sex = HallAPI.DataAPI:getUserSex();
    Log.i("------sex", sex);
    if sex == DDZConst.FEMALE then
        self.gameChatTxtCfg = csvConfig.maleChatList
    else
        self.gameChatTxtCfg = csvConfig.femaleChatList    
    end
end

----------------------------------------------
-- @desc 获取聊天内容 
-- @pram sex :玩家性别
--       emjI: 表情id
----------------------------------------------
function DDZRoom:getChatContent(sex, emjI)
    Log.i("------sex   emjI", sex, emjI);

    if sex == DDZConst.MALE then
        return csvConfig.maleChatList[emjI].content
    else
        return csvConfig.femaleChatList[emjI].content
    end
end

----------------------------------------------
-- @desc 充值底牌
----------------------------------------------
function DDZRoom:resetHandCardView()
    for seat=1,DDZConst.PLAYER_NUM do
        if self.m_handCardViews[seat] then
            self.m_handCardViews[seat]:reset();
        end
    end
end

----------------------------------------------
-- @desc 隐藏操作结果 
----------------------------------------------
function DDZRoom:hideAllOprationResult()
    for seat = 1, DDZConst.PLAYER_NUM do
        self.m_oprationResultViews[seat]:hideOprationResult();
    end
end

----------------------------------------------
-- @desc 隐藏操作结果 
-- @pram playerId :玩家id
----------------------------------------------
function DDZRoom:hideOpration(playerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration();
    end
end

----------------------------------------------
-- @desc 隐藏操作 
----------------------------------------------
function DDZRoom:hideAllOpration()
    for seat = 1, DDZConst.PLAYER_NUM do
        self.m_oprationViews[seat]:hideOpration();
    end
end

----------------------------------------------
-- @desc 更新操作 
-- @pram playerId :玩家id
--       info:更新相关信息
----------------------------------------------
function DDZRoom:updateOpration(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("PDKRoom:updateOpration ", seat);
    Log.i("PDKRoom:updateOpration info", info)
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:updateOpration(info, self.m_handCardViews[DDZConst.SEAT_MINE]);
        self.m_handCardViews[seat]:updateOpration(info);
    end
end


---------------------------------------
-- 函数功能：    更新房间信息
-- 返回值：      无
---------------------------------------
function DDZRoom:updateRoomJushuInfo()
    Log.i("PDKRoom:updateRoomJushuInfo", HallAPI.DataAPI:getJuNowCnt())
    local roomInfo = HallAPI.DataAPI:getRoomInfo()
    local PAYTYPEDES = {
    "房主付费",
    "大赢家付费",
    "AA付费(每人%s钻石)",
    "亲友圈付费"
    }
    PAYTYPEDES[0] = "亲友圈付费"
    local logoPosY = self.paodekuaiTitle:getPositionY()
    if VideotapeManager.getInstance():isPlayingVideo() then 
        self.blb_base:setString(string.format("底分:%d 第 %d 局",1,kPlaybackInfo:getCurrentGamesNum() or 0))
        self.blb_base:setPositionY(logoPosY-10)
        self.lab_roomPayType:setVisible(false)
    else
        self.blb_base:setString(string.format("局数:%d/%d",HallAPI.DataAPI:getJuNowCnt() or 0, HallAPI.DataAPI:getJuTotal() or 0))
        self.blb_base:setPositionY(logoPosY-10)
        self.lab_roomPayType:setVisible(true)
    end
    self.lab_roomId:setString(string.format("房间号:%d",HallAPI.DataAPI:getRoomId()))
    if roomInfo.RoJST == PAYTYPE.PAYTYPE1 or roomInfo.RoJST == PAYTYPE.PAYTYPE2 or roomInfo.RoJST == PAYTYPE.PAYTYPE0 then
        self.lab_roomPayType:setString(PAYTYPEDES[roomInfo.RoJST])
        if roomInfo.RoJST == PAYTYPE.PAYTYPE0 then
            local clubId = kFriendRoomInfo:getRoomInfo().clI
            self.lab_roomPayType:setString(string.format("亲友圈ID:%s", tostring(clubId)))
            self.lab_roomPayType_ext:setVisible(true)
            self.lab_roomPayType_ext:setString(PAYTYPEDES[0])
        else
            self.lab_roomPayType:setString(PAYTYPEDES[roomInfo.RoJST])
        end
    elseif roomInfo.RoJST == PAYTYPE.PAYTYPE3 then
        self.lab_roomPayType:setString(string.format(PAYTYPEDES[PAYTYPE.PAYTYPE3],math.ceil( roomInfo.RoFS / roomInfo.plS )))
    end
end
--函数功能：    及时结算
--返回值：      无
function DDZRoom:Settlement(packetInfo,isReconnect)
    local data = packetInfo.DprB
    if isReconnect then
        data = packetInfo.prB
    end
    if not data or table.nums(data) <= 0 then
        return
    end
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    for i,v in pairs(PlayerModelList) do
        local userId = v:getProp(DDZDefine.USERID)
        local seat = v:getProp(DDZDefine.SITE)
        for j,jv in pairs(data) do
            if tostring(j) == tostring(userId) and tonumber(jv) ~= 0 then
                local score = jv
                if score == 0 then
                    break
                end
                
                if not isReconnect then
                    if j == 1 then
                        kPokerSoundPlayer:playEffect("gold")
                    end
                    self:SettlementAnimation(seat,score)
                end
                DataMgr:getInstance():SetPlayerScore(userId,DataMgr:getInstance():GetPlayerScore(userId) + score)
                v:setProp(DDZDefine.MONEY,v:getProp(DDZDefine.MONEY) + score)
                self.m_seatViews[seat]:setMoney(v:getProp(DDZDefine.MONEY))
                break
            end
        end
    end
end
--函数功能：      及时结算动画
--返回值：        无
function DDZRoom:SettlementAnimation(site,score,dtTime,moveTime,addMoney)
    dtTime = dtTime or 1
    moveTime = moveTime or 0.2
    local player = self.m_seatViews[site]
    local playerWidget = player.m_pWidget
    local color = cc.c3b(255,240,128)
    local label = string.format("+%d",score)
    local font = "package_res/games/pokercommon/font/num1.fnt"
    if tonumber(score) < 0 then
        color = cc.c3b(180,244,246)
        label = string.format("%d",score)
        font = "package_res/games/pokercommon/font/num2.fnt"
    end
    local score_label = display.newBMFontLabel({
        text = label,
        font = font,
        size = 25,
        color = color,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    })
    
    score_label:setAnchorPoint(cc.p(0.5,0.5))
    score_label:addTo(playerWidget)
    local pwCS = playerWidget:getContentSize()
    score_label:setPosition(cc.p( pwCS.width/2+5,pwCS.height+15))
    if site == DDZConst.SEAT_LEFT then
        score_label:setPosition(cc.p( pwCS.width/2+10,pwCS.height*3/2 + 5))
    elseif site == DDZConst.SEAT_RIGHT then
        score_label:setPosition(cc.p( pwCS.width/2-10,pwCS.height*3/2))
    end
    local dt = cc.DelayTime:create(dtTime)
    local moveBy = cc.MoveBy:create(moveTime,cc.p(0,20))
    local sineOut = cc.EaseSineOut:create(moveBy)
    local fadeOut = cc.FadeOut:create(moveTime)
    local cafunc = cc.CallFunc:create(function()
        score_label:removeFromParent()
        score_label = nil
        if addMoney then
            addMoney()
        end
    end)
    score_label:runAction(cc.Sequence:create(dt,cc.Spawn:create(sineOut,fadeOut),cafunc))
end


function DDZRoom:sendLocationInfo()
    -- 牌局开始时获取一次定位
    Log.i("sunbin:------ DDZRoom:sendLocationInfo")
    NativeCall.getInstance():callNative({cmd = NativeCall.CMD_LOCATION}, function(info)
        local tmpData = {}
        tmpData.jiD = info.longitude
        tmpData.weD = info.latitude
        Log.i("sunbin:------ DDZRoom:sendLocationInfo -- send")
        HallAPI.DataAPI:send(CODE_TYPE_HALL, DDZSocketCmd.CODE_SEND_LOCATION, tmpData);
    end)
end


return DDZRoom