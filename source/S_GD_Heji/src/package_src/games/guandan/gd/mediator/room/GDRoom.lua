-- 斗地主房间
-- Meditor管理类
local PokerRoomBase = require("package_src.games.guandan.gdcommon.widget.PokerRoomBase")
local GDRoom = class("GDRoom", PokerRoomBase)
local PokerRoomDialogView = require("package_src.games.guandan.gdcommon.widget.PokerRoomDialogView")
local PokerRoomChatView = require("package_src.games.guandan.gdcommon.widget.PokerRoomChatView")
local csvConfig = require("package_src.games.guandan.gd.data.config_GameData")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local GDGameEvent = require("package_src.games.guandan.gd.data.GDGameEvent")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDSocketCmd = require("package_src.games.guandan.gd.proxy.delegate.GDSocketCmd")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDChatView = require("package_src.games.guandan.gd.mediator.widget.GDChatView")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDPlayerView = require("package_src.games.guandan.gd.mediator.widget.GDPlayerView")
local GDOprationView = require("package_src.games.guandan.gd.mediator.widget.GDOprationView")
local GDOprationResultView = require("package_src.games.guandan.gd.mediator.widget.GDOprationResultView")
local GDHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDHandCardView")
local PokerDataConst = require("package_src.games.guandan.gdcommon.data.PokerDataConst")
local GDPKCardTypeAnalyzer = require("package_src.games.guandan.gdcommon.utils.card.GDPKCardTypeAnalyzer")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local PokerRoomSettingView = require("package_src.games.guandan.gdcommon.widget.PokerRoomSettingView")
local GDMoreLayer = require("package_src.games.guandan.gd.mediator.widget.GDMoreLayer")
local GDAnimView = require("package_src.games.guandan.gd.mediator.widget.GDAnimView") 
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
-- 加入战绩
local LocalEvent = require("app.hall.common.LocalEvent")
local UmengClickEvent = require("app.common.UmengClickEvent")
local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")
local GDPKGameoverView = require("package_src.games.guandan.gdcommon.widget.GDPKGameoverView")
local GDOverHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDOverHandCardView")

--背景音乐延迟时间
local nBgDelay = 0.5
--最大缓存语音数量
local nMaxVoiceNum = 10
--没有收到结束回调时默认隐藏语音条时间
local nDefHideSpeakTime = 60

----------------------------------------------
-- @desc 构造函数
----------------------------------------------
function GDRoom:ctor()
    self.super.ctor(self, "package_res/games/guandan/room.csb")
    self:init_gameChatCfg()

    self.m_brocastContent = {}
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
    self.moreLayer = nil --更多界面
    self.chatView = nil  --聊天界面
    self.isLockContinue = false 
    self.Events = {}
    
    --朋友开房逻辑特殊处理
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        local baseNum = kFriendRoomInfo:getCurRoomBaseInfo().an --底注
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_BASEROOM, baseNum)
    else
        local gameid = HallAPI.DataAPI:getGameId()
        local roomid = HallAPI.DataAPI:getRoomId()
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEID, gameid)
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_ROOMID, roomid)
        local roomInfo = HallAPI.DataAPI:getRoomInfoById(gameid, roomid)
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_BASEROOM, roomInfo.an)
    end

    ------------- 加入录像回放控制层-------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        -- 加入录像回放控制层
        if self._videoLayer then
            self._videoLayer:removeFromParent()
        end
        local data = {}
        data.isGD = true
        self._videoLayer = VideoControlLayer.new(data)
        PokerUIManager:getInstance():addToRoot(self._videoLayer,100)
    end
end

----------------------------------------------
-- @desc 初始化ui函数
----------------------------------------------
function GDRoom:onInit()
    self.gameType = GDConst.GAME_UP_TYPE.UP_GRADE
    local roomInfo = kFriendRoomInfo:getSelectRoomInfo()
    if VideotapeManager.getInstance():isPlayingVideo() then
        for i,v in ipairs(roomInfo.wanfa) do
            if v == "bushengji" then
                self.gameType = GDConst.GAME_UP_TYPE.NO_UP_GRADE
            end
        end
    else
        if string.find(roomInfo.wa,"bushengji") then
            self.gameType = GDConst.GAME_UP_TYPE.NO_UP_GRADE
        end
    end


    SocketManager.getInstance().pauseDispatchMsg = false
    self.imgNoBigger = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_no_bigger")
    for i = 1, GDConst.PLAYER_NUM  do
        local data = {seat = i, gameType = self.gameType}
        self.m_seatViews[i] = GDPlayerView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i), data)
        self.m_oprationViews[i] = GDOprationView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration" .. i), data)
        self.m_oprationResultViews[i] = GDOprationResultView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration_result" .. i), data)
        self.m_handCardViews[i] = GDHandCardView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard" .. i), data)
    end
    local imgBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg")
    imgBg:loadTexture("package_res/games/guandan/bg.jpg")
    self.m_AnimView = GDAnimView.new(ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_anim"), self.gameType)

    local panelMore = ccui.Helper:seekWidgetByName(self.m_pWidget,"Panel_MoreLayer")
    self.moreLayer = GDMoreLayer.new(panelMore)
    self.chatView = GDChatView.new(ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_chat"), self.gameType)

    self.btn_menu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_menu")
    self.btn_menu:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chat")
    self.btn_chat:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_voice_chat = ccui.Helper:seekWidgetByName(self.m_pWidget,"voice_chat")
    self.btn_voice_chat:addTouchEventListener(handler(self,self.onTouchSayButton))

    self.lab_roomId = ccui.Helper:seekWidgetByName(self.m_pWidget,"text_room_id")
    self.btn_jiesan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_jiesan")
    self.btn_jiesan:addTouchEventListener(handler(self, self.onClickButton))

    self.panel_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_say")
    self.img_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_say1")

    --进贡/还贡中 等待
    self.imgTxtGiveWait = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_txt_give_wait")
    self.imgTxtGiveWait:setVisible(false)
    self.imgTxtTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_text_tip")
    self.imgTxtTip:setVisible(false)
    --本局您先出牌
    self.imgYouPlay = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_you_play")
    self.imgYouPlay:setVisible(false)

    --级牌提示
    self.panelGameGradeTips = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_game_grade_tips")
    self.panelGameGradeTips:setVisible(false)

    self:showBase()
end

----------------------------------------------
-- @desc 初始化之后的函数
----------------------------------------------
function GDRoom:onShow()
    self.m_pWidget:setTouchEnabled(false)
    self:clearDesk()

    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,0)
    end
    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    --背景音乐
    self.m_pWidget:performWithDelay(function()
        self:playBgMusic()
    end, nBgDelay)

    --朋友开房逻辑特殊处理
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
       self:updateRoomJushuInfo()
    end
    self:showTimeAndSingel()
end

-- 更新级牌信息
function GDRoom:updateGradeTips(isReconnect)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local myUserId = HallAPI.DataAPI:getUserId()
    local ourGrade = 0
    local otherGrade = 0
    for k,v in pairs(PlayerModelList) do
        local userId = v:getProp(GDDefine.USERID)
        if myUserId == userId then
            ourGrade = v:getProp(GDDefine.OUR_GRADE)
            otherGrade = v:getProp(GDDefine.OTHER_GRADE)
            break
        end
    end

    local gradeCard = {
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "J",
        "Q",
        "K",
        "A",
        "2",
    }
    -- 我方的级牌
    local fnt_our_side_grade = ccui.Helper:seekWidgetByName(self.m_pWidget, "fnt_our_side_grade")
    -- 对方的级牌
    local fnt_other_side_grade = ccui.Helper:seekWidgetByName(self.m_pWidget, "fnt_other_side_grade")

    fnt_our_side_grade:setString(tostring(gradeCard[ourGrade]) or "2")
    fnt_other_side_grade:setString(tostring(gradeCard[otherGrade]) or "2")

    --级牌提示
    local grade_num = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LEVEL_USER)
    local fnt_grade_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "fnt_grade_num")

    -- 默认为别人的级牌等级
    local grade = otherGrade
    local isOurGrade = false
    for i,v in ipairs(grade_num) do
        if myUserId == v then
            -- 改为自己的级牌等级
            grade = ourGrade 
            isOurGrade = true
        end
    end
    local panel_our_side = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_our_side")
    local panel_other_side = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_other_side")
    panel_our_side:getChildByName("img_mask"):setVisible(not isOurGrade)
    panel_our_side:getChildByName("img_arrow"):setVisible(isOurGrade)
    panel_other_side:getChildByName("img_mask"):setVisible(isOurGrade)
    panel_other_side:getChildByName("img_arrow"):setVisible(not isOurGrade)

    fnt_grade_num:setString(tostring(gradeCard[grade]) or "2")
    if RULESETTING.nLevelCard then
        RULESETTING.nLevelCard = grade
    end

    if not isReconnect then
        self.panelGameGradeTips:setVisible(true)
        self.m_pWidget:performWithDelay(function()
            self.panelGameGradeTips:setVisible(false)
        end, 2)
    end

    local text_grade = ccui.Helper:seekWidgetByName(self.m_pWidget, "text_grade")
    local nowJuCnt = HallAPI.DataAPI:getJuNowCnt()
    local totalJuCnt = HallAPI.DataAPI:getJuTotal()
    local data = DataMgr:getInstance():getWanfaData()
    local isShengJi = false
    for k,v in pairs(data) do
        if v == "shengji" then
            isShengJi = true
            break
        end
    end
    local str = ""
    if isShengJi then
        local shengjiRule = ""
        for k,v in pairs(data) do
            if v == "guoA" then
                shengjiRule = "过A"
                break
            elseif v == "guo6" then
                shengjiRule = "过6"
                break
            elseif v == "guo10" then
                shengjiRule = "过10"
                break
            elseif v == "guo3" then
                shengjiRule = "过3"
                break
            elseif v == "guo4" then
                shengjiRule = "过4"
                break
            elseif v == "guo5" then
                shengjiRule = "过5"
                break
            elseif v == "guo7" then
                shengjiRule = "过7"
                break
            elseif v == "guo8" then
                shengjiRule = "过8"
                break
            elseif v == "guo9" then
                shengjiRule = "过9"
                break
            elseif v == "guoJ" then
                shengjiRule = "过J"
                break
            elseif v == "guoQ" then
                shengjiRule = "过Q"
                break
            elseif v == "guoK" then
                shengjiRule = "过K"
                break
            end
        end
        str = string.format("%s 第%d局", shengjiRule, nowJuCnt)
    else
        str = string.format("局数 第%d/%d局", nowJuCnt, totalJuCnt)
    end
    text_grade:setString(str)
end


-- 显示时间和信号信息
function GDRoom:showTimeAndSingel()
    self.image_xinhao = ccui.Helper:seekWidgetByName(self.m_pWidget, "signal")
    self.image_wifi = ccui.Helper:seekWidgetByName(self.m_pWidget, "wifi")
    self.progressBar_pro = ccui.Helper:seekWidgetByName(self.m_pWidget, "ProgressBar_pro")
    self.label_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_time")
    self.image_bat_bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_bat")

    self:initTime()

    if self.m_isWifi then
        self.image_wifi:setVisible(self.image_bat_bg:isVisible())
    elseif self.m_showSignal then
        self.image_xinhao:setVisible(self.image_bat_bg:isVisible())
    end

    self.m_pWidget:performWithDelay(function()
        self:updateSignal()
        self:updateBattery()
    end, 2)
    self.m_showSignal = true
    self.m_batteryScheduler = scheduler.scheduleGlobal(function()
        if self.image_bat_bg then
            if self.m_isWifi and self.image_wifi then
                self.image_wifi:setVisible(self.image_bat_bg:isVisible())
                self.m_showSignal = self.image_wifi:isVisible()
            elseif self.image_xinhao and self.image_bat_bg then
                self.image_xinhao:setVisible(self.image_bat_bg:isVisible())
                self.m_showSignal = self.image_xinhao:isVisible()
            end
            self.image_bat_bg:setVisible(not self.image_bat_bg:isVisible())
            if self.image_bat_bg:isVisible() then
                self.image_wifi:setVisible(false)
                self.image_xinhao:setVisible(false)
            end
        else
            scheduler.unscheduleGlobal(self.m_batteryScheduler)
        end
    end,20)
end

function GDRoom:updateSignal()
    local update = cc.CallFunc:create(function()
        local data = {}
        data.cmd = NativeCall.CMD_WECHAT_SIGNAL
        NativeCall.getInstance():callNative(data, self.signalCallBack, self)
     end)
    self.image_wifi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5),update)))
    local signalLst = cc.EventListenerCustom:create(LocalEvent.GameUISignal, handler(self,self.onUpdateSignal))
    table.insert(self.Events,signalLst)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalLst, 1)
end

function GDRoom:signalCallBack(info)
    local event = cc.EventCustom:new(LocalEvent.GameUISignal)
    event.data = info
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function GDRoom:onUpdateSignal(event)
    local info = event.data
    self.m_isWifi = false
    if info.type ~= "Wi-Fi" then
        self.image_wifi:setVisible(false)
        self.image_xinhao:setVisible(not self.image_bat_bg:isVisible())
        return
    else
        self.m_isWifi = true
        self.image_wifi:setVisible(not self.image_bat_bg:isVisible())
        self.image_xinhao:setVisible(false)
    end
    if not self.m_showSignal then
        self.image_wifi:setVisible(false)
        self.image_xinhao:setVisible(false)
        return
    end
    if info.rssi == 4 then
        self.image_wifi:loadTexture("package_res/games/guandan/time/wifi_1.png")
    elseif info.rssi == 3 then
        self.image_wifi:loadTexture("package_res/games/guandan/time/wifi_2.png")
    elseif info.rssi == 2 then
        self.image_wifi:loadTexture("package_res/games/guandan/time/wifi_3.png")
    elseif info.rssi == 1 then
        self.image_wifi:loadTexture("package_res/games/guandan/time/wifi_4.png")
    end
end

function GDRoom:updateBattery()
    local update = cc.CallFunc:create(function()
        local data = {}
        data.cmd = NativeCall.CMD_GETBATTERY
        NativeCall.getInstance():callNative(data, self.batteryCallBack, self)
    end)
    self.progressBar_pro:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),update)))
    local EventListener = cc.EventListenerCustom:create(LocalEvent.GameUIBattery,handler(self,self.onUpdateBattery))
    table.insert(self.Events,EventListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(EventListener, 1)
end

function GDRoom:batteryCallBack(info)
    local event = cc.EventCustom:new(LocalEvent.GameUIBattery)
    event.data = info
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function GDRoom:onUpdateBattery(event)
    if event.data.baPro and self.progressBar_pro then
        self.progressBar_pro:setPercent(event.data.baPro)
    end
end

-- 初始化时间
function GDRoom:initTime()
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

----------------------------------------------
-- @desc 播放背景音乐
----------------------------------------------
function GDRoom:playBgMusic()
    kPokerSoundPlayer:playBGMusic(csvConfig.musicList["bgpath"]["path"], true)
    audio.setMusicVolume(HallAPI.SoundAPI:getMusicVolume())
    if HallAPI.SoundAPI:getMusicVolume() <= 0 then
        HallAPI.SoundAPI:pauseMusic()
    end
end

----------------------------------------------
-- @desc 窗口关闭函数  注销事件 释放资源等
----------------------------------------------
function GDRoom:onClose()
    HallAPI.SoundAPI:stopMusic()
    --朋友开房逻辑特殊处理
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        kFriendRoomInfo:clearData()
    end

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread)
    end
    
    if self.global then
        scheduler.unscheduleGlobal(self.global)
        self.global = nil
    end

    self:unRegistMsgs()

    self.m_AnimView:dtor()
    self.moreLayer:dtor()
    self.chatView:dtor()

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
end

----------------------------------------------
-- @desc 注册事件监听
----------------------------------------------
function GDRoom:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        table.insert(self.m_listeners, nhandle)
    end
    --网络消息
    addEvent(GDGameEvent.ONGAMESTART)
    addEvent(GDGameEvent.ONDEALGONG)
    addEvent(GDGameEvent.ONPLAYERCARD)
    addEvent(GDGameEvent.ONSTRATPLAY)
    addEvent(GDGameEvent.ONOUTCARD)
    addEvent(GDGameEvent.GAMEOVER)
    addEvent(GDGameEvent.ONTUOGUAN)
    addEvent(GDGameEvent.ONRECONNECT)
    addEvent(GDGameEvent.ONEXITROOM)
    addEvent(GDGameEvent.ONUSERDEFCHAT)
    addEvent(GDGameEvent.RECVBROCAST)
    addEvent(GDGameEvent.ONRECVENTERROOM)
    addEvent(GDGameEvent.ONRECVREQDISSMISS)
    addEvent(GDGameEvent.ONRECVDISSMISSEND)
    addEvent(GDGameEvent.RESAYCHAT)
    addEvent(GDGameEvent.ONRECVFRIENDCONTINUE)
    addEvent(GDGameEvent.ONRECVTOTALGAMEOVER)
    addEvent(GDGameEvent.ONLINE)
    addEvent(GDGameEvent.UPDATEOPERATION)

    --游戏内事件
    addEvent(GDGameEvent.UIREQCONTINUE)
    addEvent(GDGameEvent.UIREQCHANGEDESK)
    addEvent(GDGameEvent.ONDEALCARDEND)
    addEvent(GDGameEvent.HIDEMORELAYER)
    addEvent(GDGameEvent.SHOWSETTING)
    addEvent(GDGameEvent.SHOWNOBIGGER)
    addEvent(GDGameEvent.SHOWEXCHANGEHEAD)
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
function GDRoom:unRegistMsgs()
    Log.i("GDRoom:unRegistMsgs")
    for k,v in pairs(self.m_listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

----------------------------------------------
-- @desc 监听事件分发
-- @pram id:注册事件id
--       ...:参数
----------------------------------------------
function GDRoom:ListenToEvent(id, ... )
    -- Log.i("GDRoom:ListenToEvent id", id)
    if id == GDGameEvent.ONGAMESTART then
        self:onGameStart(...)
    elseif id == GDGameEvent.ONDEALGONG then
        self:onDealGong(...)
    elseif id == GDGameEvent.ONPLAYERCARD then
        self.m_handCardViews[...]:onPlayCard()
    elseif id == GDGameEvent.ONSTRATPLAY then
        self:onRecvStartPlay(...)
    elseif id == GDGameEvent.ONOUTCARD then
        self:onRecvOutCard(...)
    elseif id == GDGameEvent.GAMEOVER then
        self:onRecvGameOver(...)
    elseif id == GDGameEvent.ONTUOGUAN then
        self:onRecvTuoGuan(...)
    elseif id == GDGameEvent.ONRECONNECT then
        self:onRecvReconnect(...)
    elseif id == GDGameEvent.ONEXITROOM or id == PokerEventDef.GameEvent.GAME_EXIT_GAME then
        self:onRecvExitRoom(...)
    elseif id == GDGameEvent.ONUSERDEFCHAT then
        self:onRecvDefaultChat(...)
    elseif id == GDGameEvent.RECVBROCAST then
        self:onRecvBrocast(...)
    elseif id == GDGameEvent.ONRECVENTERROOM then
        self:showBase()
    elseif id == GDGameEvent.ONRECVREQDISSMISS then
        self:onRecvReqDismiss(...)
        -- 收到解散的结果,放开锁定,并且判断是否续局
        self:GameContinue()
    elseif id == GDGameEvent.ONRECVDISSMISSEND then
        self:onRecvDismissEnd(...)
    elseif id == GDGameEvent.RESAYCHAT then
        self:onRecvSayChat(...)
    elseif id == GDGameEvent.ONRECVFRIENDCONTINUE then
        self:onRecvFriendContinue(...)
    elseif id == GDGameEvent.ONRECVTOTALGAMEOVER then
        self:onRecvFriendTotalOver(...)
    elseif id == GDGameEvent.UPDATEOPERATION then
        self:updateOpration(...)
    elseif id == GDGameEvent.UIREQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == GDGameEvent.UIREQCONTINUE then
        self:reqContinueGame(...)
    elseif id == GDGameEvent.ONDEALCARDEND then
        self:onDealcardEnd()
    elseif id == GDGameEvent.HIDEMORELAYER then
        self:hideMoreLayer(...)
    elseif id == GDGameEvent.SHOWSETTING then
        self:showSetting(...)
    elseif id == GDGameEvent.SHOWNOBIGGER then
        self:showNoBigger(...)
    elseif id == GDGameEvent.SHOWEXCHANGEHEAD then
        self:showExchangeHead(...)
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
    --刷新离线状态
    elseif id == GDGameEvent.ONLINE then
        self:onLineUpdate()
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

----------------------------------------------
-- @desc 游戏开始
-- @pram dealCards:发的牌
--       firstID: 第一个出牌的人的id
----------------------------------------------
function GDRoom:onGameStart()
    Log.i("GDRoom:onGameStart")
    self:showBase()
    self:hideAllReady()
    self:resetHandCardView()
    self:hideAllOprationResult()
    self:updateGradeTips()
    self.imgNoBigger:setVisible(false)
    self.imgTxtTip:setVisible(false)
    for i = 1, GDConst.PLAYER_NUM  do
        self:updatePlayerInfo(i) 
    end
    if self.m_rightHandCardView then
        self.m_rightHandCardView:removeFromParent()
        self.m_rightHandCardView = nil
    end
    if self.m_topHandCardView then
        self.m_topHandCardView:removeFromParent()
        self.m_topHandCardView = nil
    end
    if self.m_leftHandCardView then
        self.m_leftHandCardView:removeFromParent()
        self.m_leftHandCardView = nil
    end

    self:onLineUpdate()
    self:dealCard(false)

    self:sendLocationInfo()
end

function GDRoom:onLineUpdate()
    if #self.m_seatViews ~= GDConst.PLAYER_NUM then
        Log.d("--wangzhi--头像还未绘制完,不能刷新角色状态--")
        print(debug.traceback())
        return
    end
    for i=1,GDConst.PLAYER_NUM  do
        self.m_seatViews[i]:showOnline()
    end
end

----------------------------------------------
-- @desc 更新玩家信息
-- @pram:seat 玩家座位id
----------------------------------------------
function GDRoom:updatePlayerInfo(seat)
    self.m_seatViews[seat]:updatePlayerInfo()
end

----------------------------------------------
-- @desc 发牌
-- @pram isReconnect:是否重连
----------------------------------------------
function GDRoom:dealCard(isReconnect)
    if not isReconnect then
        kPokerSoundPlayer:playEffect("fapai")
        self.panelGameGradeTips:setVisible(true)
    end
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        local seat = v:getProp(GDDefine.SITE)
        self.m_handCardViews[seat]:dealCard(isReconnect)  
    end
end

----------------------------------------------
-- @desc 显示玩家操作选项
-- @pram playerId:玩家id
--       info:玩家显示操作相关信息
----------------------------------------------
function GDRoom:showOpration(playerId, info)
    local isExist = DataMgr:getInstance():isPlayerExist(playerId)
    if not isExist then
        return 
    end
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    Log.i("GDRoom:showOpration seat", seat)
    -- Log.i("GDRoom:showOpration info", info)
    if self:isLegalSeat(seat) then
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_OPERATESEATID, seat)
        self.m_oprationResultViews[seat]:hideOprationResult()
        self.m_oprationViews[seat]:hideOpration()
        self.m_oprationViews[seat]:showOpration(info)
        self.m_handCardViews[seat]:showOpration(info)

        if info and info.jieFengFlag and tonumber(info.jieFengFlag) == 1 then
            for i=1, 4 do
                self.m_oprationResultViews[i]:hideOprationResult()
            end
            local disX = 0
            if seat == GDConst.SEAT_MINE then
                disX = 0
            elseif seat == GDConst.SEAT_RIGHT then
                disX = -460
            elseif seat == GDConst.SEAT_TOP then
                disX = -450
            elseif seat == GDConst.SEAT_LEFT then
                disX = -370
            end
            self.m_AnimView:showShunAnim("package_res/games/guandan/anim/image/guandan_text_jiefeng.png", seat, disX, true)
            local player = DataMgr:getInstance():getPlayerInfo(playerId)
            local sex = player:getProp(GDDefine.SEX)
            kPokerSoundPlayer:playEffect("jie_feng_" .. sex)
            kPokerSoundPlayer:playEffect("jie_feng")
        end
    end
end

----------------------------------------------
-- @desc 玩家seatid是否合法
-- @pram seat 玩家座位id
----------------------------------------------
function GDRoom:isLegalSeat(seat)
    if seat and seat > GDConst.SEAT_NONE and seat <= GDConst.PLAYER_NUM then
        return true
    end
    return false
end

function GDRoom:onDealGong(JGBack, HGBack, isReconnect, hasReceHGID)
    local JinGongMap = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_JINGGONGMAP)
    local HuanGongMap = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_HUANGONGMAP)

    local status = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    local handCardView = self.m_handCardViews[GDConst.SEAT_MINE]
    if status == GDConst.STATUS_ON_JINGONG then
        for k,v in pairs(JinGongMap) do
            local isExist = DataMgr:getInstance():isPlayerExist(tonumber(k))
            if isExist then
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(k))
                if self:isLegalSeat(seat) then
                    self.m_oprationViews[seat]:hideOpration()
                    self.m_oprationViews[seat]:showOpration()
                end
                if tonumber(k) == kUserInfo:getUserId() then
                    if not next(v) then--未进贡
                        self.imgTxtGiveWait:setVisible(false)
                        self.imgTxtTip:setVisible(true)
                        self.imgTxtTip:loadTexture("guandan_tips_give.png", ccui.TextureResType.plistType)
                        handCardView.m_handCardView:grayGongCards()
                    else--已进贡
                        self.imgTxtGiveWait:setVisible(true)
                        self.imgTxtTip:setVisible(false)
                        handCardView.m_handCardView:removeGrayGongCards()
                    end
                end
            end
        end
        --自己不是进贡方 显示正在进贡提示
        if not JinGongMap[tostring(kUserInfo:getUserId())] then
            self.imgTxtGiveWait:setVisible(true)
            self.imgTxtTip:setVisible(false)
        end
        self:addGongCard(JinGongMap, "jinGong")
    elseif status == GDConst.STATUS_ON_HUANGONG then
        for k,v in pairs(HuanGongMap) do
            local isExist = DataMgr:getInstance():isPlayerExist(tonumber(k))
            if isExist then
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(k))
                if self:isLegalSeat(seat) and isReconnect then
                    self.m_oprationViews[seat]:hideOpration()
                    self.m_oprationViews[seat]:showOpration()
                else
                    if next(v) then
                        self.m_oprationViews[seat]:hideOpration()
                    end
                end
            end
            if tonumber(k) == kUserInfo:getUserId() then
                if not next(v) then
                    self.imgTxtGiveWait:setVisible(false)
                    self.imgTxtTip:loadTexture("guandan_tips_back.png", ccui.TextureResType.plistType)
                    if isReconnect then
                        handCardView.m_handCardView:grayGongCards()
                        self.imgTxtTip:setVisible(true)
                    end
                else
                    self.imgTxtGiveWait:setVisible(true)
                    self.imgTxtTip:setVisible(false)
                    handCardView.m_handCardView:removeGrayGongCards()
                end
            end
        end
        if not HuanGongMap[tostring(kUserInfo:getUserId())] then
            self.imgTxtGiveWait:setVisible(true)
            self.imgTxtTip:setVisible(false)
        end
        if JGBack then
            self:addGongCard(JinGongMap, "jinGong")
        else
            self:addGongCard(HuanGongMap, "huanGong")
        end
        if isReconnect then
            for k,v in pairs(JinGongMap) do
                for kk,vv in pairs(v) do
                    local PlayerModel = DataMgr:getInstance():getPlayerInfo(tonumber(kk))
                    local seat = PlayerModel:getProp(GDDefine.SITE)
                    local player = self.m_seatViews[seat]
                    player:addGongCard(vv)
                end
            end
        end
    else
        if HGBack then
            self:addGongCard(HuanGongMap, "huanGong", hasReceHGID)
        elseif isReconnect then
            for i=1, 2 do
                local node = self.m_pWidget:getChildByName("huanGong"..i)
                if node then
                    node:removeFromParent()
                end
                local node2 = self.m_pWidget:getChildByName("jinGong"..i)
                if node2 then
                    node2:removeFromParent()
                end
            end
        end
        handCardView.m_handCardView:removeGrayGongCards()
        self.imgTxtGiveWait:setVisible(false)
        if not isReconnect then
            self.imgTxtTip:setVisible(false)
        end
        if isReconnect then
            for k,v in pairs(JinGongMap) do
                for kk,vv in pairs(v) do
                    local PlayerModel = DataMgr:getInstance():getPlayerInfo(tonumber(kk))
                    local seat = PlayerModel:getProp(GDDefine.SITE)
                    local player = self.m_seatViews[seat]
                    player:addGongCard(vv)
                end
            end
            for k,v in pairs(HuanGongMap) do
                for kk,vv in pairs(v) do
                    local PlayerModel = DataMgr:getInstance():getPlayerInfo(tonumber(kk))
                    local seat = PlayerModel:getProp(GDDefine.SITE)
                    local player = self.m_seatViews[seat]
                    player:addGongCard(vv)
                end
            end
        end
    end
    if not isReconnect and not JGBack and not HGBack then
        local flag = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_KANG_GONG_FLAG)
        if flag and flag == 2 then
            kPokerSoundPlayer:playEffect("kang_gong")
            local myPlayer = DataMgr:getInstance():getMyPlayerModel()
            local sex = myPlayer:getProp(GDDefine.SEX)
            kPokerSoundPlayer:playEffect("kang_gong_"..sex)
            self.m_AnimView:showAnimationGuandan("kang_gong")
            PokerToast.getInstance():show("抗贡，本局头游先出")
        end
    end
end

function GDRoom:addGongCard(info, tagName, hasReceHGID)
    local count = 0
    for k,v in pairs(info) do
        count = count + 1
    end
    local startPosX = display.cx
    if count == 2 then
        startPosX = display.cx - 100
    end
    local index = 0
    for k,v in pairs(info) do
        for kk,vv in pairs(v) do
            index = index + 1
            local node = self.m_pWidget:getChildByName(tagName..index)
            if node then
                node:removeFromParent()
            end
            local nodeBg = self.m_pWidget:getChildByName(tagName..index+10)
            if nodeBg then
                nodeBg:removeFromParent()
            end
            local type, value = GDCard.cardConvert(vv)
            local cardView = PokerCardView.new(type, value, vv)
            local cardBgView = PokerCardView.new(type, value, vv)
            local size = cardView:getContentSize()
            cardView:setVisible(false)
            cardBgView:showAsBackBg()
            self.m_pWidget:addChild(cardView, 2, tagName..index)
            self.m_pWidget:addChild(cardBgView, 2, tagName..index+10)
            cardView:getLayoutParameter():setMargin({left = startPosX - size.width/2 + (index - 1)*200, top = display.cy-size.height})
            cardBgView:getLayoutParameter():setMargin({left = startPosX - size.width/2 + (index - 1)*200, top = display.cy-size.height})
            cardView:getParent():requestDoLayout()
        end
    end

    if count == index then
        for i = 1, index do
            local cardView = self.m_pWidget:getChildByName(tagName..i)
            local cardBg = self.m_pWidget:getChildByName(tagName..i+10)
            local time = 0.2
            if cardBg then
                cardBg:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1)
                    , cc.OrbitCamera:create(time,1,0,0,90,0,0)
                    , cc.RemoveSelf:create()
                ))
            end
            if cardView then
                cardView:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1+time)
                    , cc.Show:create()
                    , cc.OrbitCamera:create(time,1,0,270,90,0,0)
                    , cc.DelayTime:create(1)
                    , cc.CallFunc:create(function()
                        if i == index then
                            self:moveToPlayer(info, tagName, hasReceHGID)
                        end
                    end)
                ))
            end
        end
    else
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    end
end

function GDRoom:moveToPlayer(info, tagName, hasReceHGID)
    local index = 1
    for k,v in pairs(info) do
        for kk,vv in pairs(v) do
            local PlayerModel = DataMgr:getInstance():getPlayerInfo(tonumber(kk))
            local seat = PlayerModel:getProp(GDDefine.SITE)
            local player = self.m_seatViews[seat]
            local posX,posY = player:getPlayerPosition()
            local node = self.m_pWidget:getChildByName(tagName..index)
            posX = posX + node:getContentSize().width/2
            posY = posY + node:getContentSize().height/2
            local mt = cc.MoveTo:create(0.5, cc.p(posX, posY))
            local call = cc.CallFunc:create(function()
                node:removeFromParent()
                player:addGongCard(vv)
                local seatID = DataMgr:getInstance():getSeatByPlayerId(tonumber(kk))
                local hasRecept = false
                if tagName == "huanGong" and hasReceHGID then
                    for k,v in pairs(hasReceHGID) do
                        if tonumber(v) == tonumber(kk) then
                            hasRecept = true
                        end
                    end
                end
                if not hasRecept then
                    self.m_handCardViews[seatID]:addCard({vv})
                end
                self.m_handCardViews[GDConst.SEAT_MINE].m_handCardView:grayGongCards()
                if (not VideotapeManager.getInstance():isPlayingVideo())
                    and tonumber(kk) ~= HallAPI.DataAPI:getUserId() then
                    PlayerModel:addCards({-1})
                end
                
                if tagName ~= "huanGong" then
                    self.m_oprationViews[seatID]:showOpration()

                    local HuanGongMap = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_HUANGONGMAP)
                    local myData = HuanGongMap[tostring(kUserInfo:getUserId())]
                    if HuanGongMap and myData and not next(myData) then
                        self.imgTxtTip:setVisible(true)
                    end
                else
                    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                end
            end)
            local seq = cc.Sequence:create(mt, call)
            node:runAction(seq)
            index = index + 1
        end
    end
end

--------------------------------------------------------------
-- @desc 根据当前游戏状态显示操作结果
-- @pram palyerId:玩家id
--       info:相关信息
--       isReconnect:是否重连
--------------------------------------------------------------
function GDRoom:showOprationResult(playerId, info, isReconnect)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    Log.i("GDRoom:showOprationResult seat", seat)
    Log.i("GDRoom:showOprationResult info ", info)
    Log.i("GDRoom:showOprationResult playerId ", playerId)
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration()
        self.m_oprationResultViews[seat]:hideOprationResult()

        local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
        local sex = GDConst.MALE
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId)
        if PlayerModel then
            sex = PlayerModel:getProp(GDDefine.SEX)
        end
        
        if gameStatus == GDConst.STATUS_ON_OUT_CARD then
            self.m_oprationResultViews[seat]:onPlayCard(info, isReconnect)--音效统一在此函数内播放
            self.m_handCardViews[seat]:onPlayCard(info, isReconnect, sex)
            if not info.cards then return end
            --fl 0 不出   1 出
            if info.fl == 0 or isReconnect then
            else
                self:showCardType(seat, info.cardType, #info.cards)   
            end

            local nextSeat = seat + 1
            if nextSeat > 4 then
                nextSeat = 1
            end
            local rankData = DataMgr:getInstance():getPlayerRank()
            local hideRank = 0
            for k,v in pairs(rankData) do
                local playerModel = DataMgr:getInstance():getPlayerInfo(v)
                local firstSeat = playerModel:getProp(GDDefine.SITE)--头游玩家位置
                self.m_seatViews[firstSeat]:showRank(k, playerId)

                if firstSeat == GDConst.SEAT_MINE then
                    if k == 1 then
                        self.imgTxtTip:setVisible(true)
                        self.imgTxtTip:loadTexture("guandan_tips_rank_first.png", ccui.TextureResType.plistType)
                    elseif k == 2 then
                        self.imgTxtTip:loadTexture("guandan_tips_rank_second.png", ccui.TextureResType.plistType)
                        self.imgTxtTip:setVisible(true)
                    end
                end
                if seat ~= firstSeat and nextSeat == firstSeat then
                    hideRank = k
                    self.m_oprationResultViews[firstSeat]:hideOprationResult()
                end
            end
            --头游、二游玩家都出来了
            if hideRank == 1 and #rankData >= 2 then
                local playerModel = DataMgr:getInstance():getPlayerInfo(rankData[2])
                local secondSeat = playerModel:getProp(GDDefine.SITE)--二游玩家位置
                if seat ~= secondSeat 
                    and (math.abs(secondSeat-nextSeat) == 1 
                         or math.abs(secondSeat-nextSeat) == 3) 
                    then
                    self.m_oprationResultViews[secondSeat]:hideOprationResult()
                end
            end
        elseif gameStatus == GDConst.STATUS_ON_GAMEOVER then
            self.m_oprationResultViews[seat]:onGameOver(info, playerId, sex)
            self.m_handCardViews[seat]:onGameOver(info, playerId, sex)
            self:showCardType(seat, info.cardType, #info.cards)   
            self.imgNoBigger:setVisible(false)
        end
    end
end


----------------------------------------------
-- @desc 牌型动画 
-- @pram seat :玩家座位id
--       cardType:牌型
--       cardLength:牌的长度
----------------------------------------------
function GDRoom:showCardType(seat, cardType, cardLength)
    self.m_AnimView:showCardTypeAnim(seat, cardType, cardLength)
end
-------------------------------------------------------
-- @desc 开始打牌
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function GDRoom:onRecvStartPlay(packetInfo)
    -- Log.i("GDRoom",packetInfo)
    packetInfo = checktable(packetInfo)

    self:hideAllOpration()
    self:hideAllOprationResult()

    local info = {}
    info.isMustOut = true
    self:showOpration(packetInfo.fiPI, info)
    --我先打牌 显示该你出牌了
    if packetInfo.fiPI == kUserInfo:getUserId() then
        self.imgYouPlay:setVisible(true)
    end
    --mapInfos 为调试牌型用的
end

-------------------------------------------------------
-- @desc 出牌
-- @return 无
-- @pram packetInfo 网络包
-------------------------------------------------------
function GDRoom:onRecvOutCard(packetInfo, isReconnect)
    Log.i("GDRoom:onRecvOutCard",packetInfo)
    self.imgYouPlay:setVisible(false)
    packetInfo = checktable(packetInfo)

    self:hideOpration(packetInfo.usI)

    if not isReconnect then
        kPokerSoundPlayer:playEffect("card_out")
        local cards = packetInfo.plC or {}
        local cardType = packetInfo.ouCT
        keyCard = cards and next(cards) and cards[1] or 0
        local outCardInfo = {}
        outCardInfo.cards = cards
        outCardInfo.cardType = packetInfo.ouCT
        _,outCardInfo.keyCardValue = GDCard.cardConvert(keyCard)
        outCardInfo.fl = packetInfo.fl--fl 0 不出   1 出
        outCardInfo.usI = packetInfo.usI
        outCardInfo.mapInfos = packetInfo.mapInfos
        self:showOprationResult(packetInfo.usI, outCardInfo, isReconnect)
    else
        local cardsList = packetInfo.gplC or {}
        for k,v in pairs(cardsList) do
            if v.cards and next(v.cards) then
                --fl 0 不出   1 出
                packetInfo.fl = 1
            else
                packetInfo.fl = 0
            end
            
            local cards = v.cards or {}
            local cardType = packetInfo.ouCT
            keyCard = cards and next(cards) and cards[1] or 0

            local outCardInfo = {}
            outCardInfo.cards = v.cards
            outCardInfo.cardType = v.cardType
            _,outCardInfo.keyCardValue = GDCard.cardConvert(keyCard)
            outCardInfo.fl = packetInfo.fl
            outCardInfo.usI = v.userId
            outCardInfo.mapInfos = packetInfo.mapInfos
            self:showOprationResult(outCardInfo.usI, outCardInfo, isReconnect)
        end
    end
    --nep 下一个出牌用户
    if packetInfo.neP > 0 then
        local info = {}
        info.isMustOut = false
        info.playCard = true
        info.jieFengFlag = packetInfo.jieFengFlag
        if packetInfo.neP == HallAPI.DataAPI:getUserId() then
            local lastOutCards = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS)
            local cardType = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_LASTCARDTYPE)
            if not lastOutCards or #lastOutCards == 0 then
                info.isMustOut = true
            elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
                --上手牌天王炸 自动不出
                info.autoNotOut = true
            end
            local handCardView = self.m_handCardViews[GDConst.SEAT_MINE]
            local isBigger = handCardView.m_handCardView:checkIsBiggerCard()
            info.isBigger = isBigger
        end
        self:showOpration(packetInfo.neP, info)
    end
end
--PokerRoomBase:gameOverUICallBack 中可能会调用此方法
---------------------------------------
function GDRoom:OnRecvRoomReWard()
    local totalData = DataMgr.getInstance():getObjectByKey(PokerDataConst.DataMgrKey_FRIENDTOTALDATA)
    PokerUIManager.getInstance():popToWnd(GDRoom)
    totalData.param.halfWayDis = self.halfWayDis
    local gameoverView = PokerUIManager.getInstance():pushWnd(GDPKGameoverView, totalData.param)
end
-------------------------------------------------------
-- @desc 叫地主
-- @return 无
-- @pram packetInfo 网络包
--       sp (spring)
-------------------------------------------------------
function GDRoom:onRecvGameOver(packetInfo, isReconnect)
    local disTime = 2
    if isReconnect then
        disTime = 0
    end
    self.m_pWidget:performWithDelay(function ()
        packetInfo.overType = 1
        PokerUIManager.getInstance():pushWnd(GDPKGameoverView, packetInfo)
    end, disTime)
    for i = 1, GDConst.PLAYER_NUM  do
        self:updatePlayerInfo(i)
    end
    --展示 剩余牌
    if self.m_rightHandCardView then
        self.m_rightHandCardView:removeFromParent()
        self.m_rightHandCardView = nil
    end
    if self.m_topHandCardView then
        self.m_topHandCardView:removeFromParent()
        self.m_topHandCardView = nil
    end
    if self.m_leftHandCardView then
        self.m_leftHandCardView:removeFromParent()
        self.m_leftHandCardView = nil
    end
    if not VideotapeManager.getInstance():isPlayingVideo() then
        local topPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_TOP)
        local rightPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_RIGHT)
        local leftPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_LEFT)
        for k,v in pairs(packetInfo.plI1) do
            if v.ca and #v.ca > 0 then
                if v.plI == rightPlayerID then
                    self.m_oprationResultViews[GDConst.SEAT_RIGHT]:hideOprationResult()
                    local pan_handCard2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard2")
                    pan_handCard2:setVisible(true)
                    self.m_rightHandCardView = GDOverHandCardView.new(pan_handCard2, -210, 60, GDConst.SEAT_RIGHT)
                    self.m_rightHandCardView:dealCard(v.ca)
                    pan_handCard2:addChild(self.m_rightHandCardView)
                elseif v.plI == leftPlayerID then
                    self.m_oprationResultViews[GDConst.SEAT_LEFT]:hideOprationResult()
                    local pan_handCard4 = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard4")
                    pan_handCard4:setVisible(true)
                    self.m_leftHandCardView = GDOverHandCardView.new(pan_handCard4, 190, 60, GDConst.SEAT_LEFT)
                    self.m_leftHandCardView:dealCard(v.ca)
                    pan_handCard4:addChild(self.m_leftHandCardView)
                elseif v.plI == topPlayerID then
                    self.m_oprationResultViews[GDConst.SEAT_TOP]:hideOprationResult()
                    local pan_handCard3 = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard3")
                    pan_handCard3:setVisible(true)
                    self.m_topHandCardView = GDOverHandCardView.new(pan_handCard3, -380, 60, GDConst.SEAT_TOP)
                    self.m_topHandCardView:dealCard(v.ca)
                    pan_handCard3:addChild(self.m_topHandCardView)
                end
            end
        end
    end
end

function GDRoom:GameContinue()
    -- 锁定还未解除
    local disMissFlag = DataMgr:getInstance():getDisMissFlag()
    if not self.isLockContinue or disMissFlag then
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

----------------------------------------------
-- @desc 显示总结算界面 
-- @pram packetInfo :网络消息
----------------------------------------------
function GDRoom:onRecvRoomEnd(packetInfo)
    self.super.onRecvRoomEnd(self, packetInfo)
    self.halfWayDis = true
end

-- 开启一个调度器,判断牌局是否结束
function GDRoom:GameTotalOver()
    if self.m_getGameTotalOverThread then
        scheduler.unscheduleGlobal(self.m_getGameTotalOverThread)
    end
    self.m_getGameTotalOverThread = scheduler.scheduleGlobal(function()
        if HallAPI.DataAPI:isGameEnd() then
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
            scheduler.unscheduleGlobal(self.m_getGameTotalOverThread)
            self.m_getGameTotalOverThread = nil
        end
    end, 0.1)
end

----------------------------------------------
-- @desc 游戏托管 
-- @pram packetInfo :网络消息
--##            托管玩家id maPI
--##            是否被托管 isM
----------------------------------------------
function GDRoom:onRecvTuoGuan(packetInfo)
    -- Log.i("GDRoom onRecvTuoGuan packetInfo", packetInfo)
    PokerUIManager.getInstance():popToWnd(self)
    self:onTuoGuanChange(packetInfo.maPI, packetInfo)
end

----------------------------------------------
-- @desc 添加底牌 
-- @pram playerId :玩家id
--       packetInfo :网络消息
----------------------------------------------
function GDRoom:onTuoGuanChange(playerId, packetInfo)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    -- Log.i("GDRoom:onTuoGuanChange ", seat)
    if self:isLegalSeat(seat) then
        local tuoguanState = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
        Log.i("tuoguanState", tuoguanState)
        self.m_handCardViews[seat]:onTuoGuanChange(playerId)
        self.m_oprationViews[seat]:onTuoGuanChange()
        -- self.m_seatViews[seat]:onTuoGuanChange(packetInfo)
    end
end

----------------------------------------------
-- @desc 重连成功 
-- @pram packetInfo :网络消息
----------------------------------------------
function GDRoom:onRecvReconnect(packetInfo)
    -- Log.i("onRecvReconnect packetInfo", packetInfo)
    packetInfo = checktable(packetInfo)
    -- PokerToast.getInstance():show("恢复对局成功")
    self:clearDesk()
    self:hideAllReady()
    self:updateGradeTips(true)
    for i = 1, GDConst.PLAYER_NUM  do
        self:updatePlayerInfo(i)
    end

    self:onLineUpdate()

    self:dealCard(packetInfo.plI1, true)

    for k, v in pairs(packetInfo.plI1) do
       self:updateTips(v.plI, v)
    end

    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if gameStatus ~= GDConst.STATUS_ON_GAMEOVER then
        if self.m_rightHandCardView then
            self.m_rightHandCardView:removeFromParent()
            self.m_rightHandCardView = nil
        end
        if self.m_topHandCardView then
            self.m_topHandCardView:removeFromParent()
            self.m_topHandCardView = nil
        end
        if self.m_leftHandCardView then
            self.m_leftHandCardView:removeFromParent()
            self.m_leftHandCardView = nil
        end
    end
end

--函数功能：   重登更新叫地主，抢地主，加倍等提示
--返回值：     无
--playerId：   玩家id
--info：       玩家信息
function GDRoom:updateTips(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    if self:isLegalSeat(seat) then
        self.m_oprationResultViews[seat]:hideOprationResult()
    end
end
----------------------------------------------
-- @desc 退出结果 
-- @pram packetInfo :网络消息
----------------------------------------------
function GDRoom:onRecvExitRoom(packetInfo)
    self:onExitRoom()
end

----------------------------------------------
-- @desc 退出到大厅 
----------------------------------------------
function GDRoom:onExitRoom()
    Log.i("GDRoom:onExitRoom")
    -- Toast.releaseInstance()
    -- LoadingView.releaseInstance()
    HallAPI.DataAPI:clearRoomData()
    PokerUIManager.getInstance():popAllWnd()
    cc.Director:getInstance():popScene()
end

---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function GDRoom:onRecvSayChat(packetInfo)
    Log.i("GDRoom say chat packetInfo:",packetInfo)
    if packetInfo.ty == GDConst.CHATTYPE.VOICECHAT then
        if packetInfo.co then
            local status = kSettingInfo:getPlayerVoiceStatus()
            if status and packetInfo.usI ~= HallAPI.DataAPI:getUserId() then
               Log.i("关闭玩家语音。。。。。。。。")
            else
                self:showSpeaking(packetInfo)
            end
        end
    elseif packetInfo.ty == GDConst.CHATTYPE.CUSTOMCHAT then
        local seat = DataMgr:getInstance():getSeatByPlayerId(packetInfo.usI)
        if self:isLegalSeat(seat) then
            info = {}
            info.ty = GDConst.TEXTTYPE
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
function GDRoom:onRecvFriendContinue(packetInfo)
    Log.i("GDRoom:onRecvFriendContinue", packetInfo)
    for i,v in ipairs(packetInfo.usI) do
        local seat = DataMgr.getInstance():getSeatByPlayerId(v)
        if self.m_seatViews[seat] then
            self.m_seatViews[seat]:reset()
            self.m_seatViews[seat]:showReady()
        end
    end
    self.imgTxtTip:setVisible(false)
end

---------------------------------------
function GDRoom:hideAllReady()
    for i=1,GDConst.PLAYER_NUM do
        if self.m_seatViews[i] then
            self.m_seatViews[i]:hideReady()
        end
    end  
end

---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function GDRoom:showSpeaking(packetInfo)
    Log.i("GDRoom showSpeaking",packetInfo)
    if not YY_IS_LOGIN then
        return 
     end
     Log.i("**************************** showSpeaking1")
     if self.m_speaking or self.m_isTouchBegan then
        Log.i("**************************** showSpeaking2")
         if #self.m_speakTable < nMaxVoiceNum then
             table.insert(self.m_speakTable, packetInfo)
         end
     else
         --local playerInfos = kFriendRoomInfo:getRoomInfo()
         --Log.i("**************************** showSpeaking1",playerInfos)
         local playerInfos = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
         Log.i("**************************** showSpeaking3",#playerInfos)
         for k, v in pairs(playerInfos) do
             if v:getProp(GDDefine.USERID) == packetInfo.usI then
                Log.i("v:getProp(GDDefine.SITE)", v:getProp(GDDefine.SITE))
                 if self.m_seatViews[v:getProp(GDDefine.SITE)] then
                     self.m_speaking = true
                     self.m_seatViews[v:getProp(GDDefine.SITE)]:showSpeaking()
                     --
                     audio.pauseMusic()
                     --
                     local data = {}
                     data.cmd = NativeCall.CMD_YY_PLAY
                     data.fileUrl = packetInfo.co
                     data.usI = packetInfo.usI .. ""--转字符串，不然IOS会报错。
                     NativeCall.getInstance():callNative(data)
 
                     self:getSpeakingStatus()
 
                     --防止没有收到播放结束回调
                     self.btn_voice_chat:stopAllActions()
                     self.btn_voice_chat:performWithDelay(function()
                         self:hideSpeaking()
                     end, nDefHideSpeakTime)
                 end
                 break
             end
         end
     end
end

---------------------------------------
-- 函数功能：    隐藏聊天
-- playerId      玩家id
---------------------------------------
function GDRoom:hideSpeaking(playerId)
    -- Log.i("GDRoom:hideSpeaking", playerId)
    playerId = playerId or "0"
    local playerInfos = DataMgr.getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    for k, v in pairs(playerInfos) do
        if v:getProp(GDDefine.USERID) == tonumber(playerId) then

            if self.m_seatViews[v:getProp(GDDefine.SITE)] then

                self.m_seatViews[v:getProp(GDDefine.SITE)]:hideSpeaking()
            end
            break
        end
    end
    self.m_speaking = false
    audio.resumeMusic()
    self:showNextSpeaking()
end

---------------------------------------
-- 函数功能：    开始播放下一条语音
-- 返回值：      无
---------------------------------------
function GDRoom:showNextSpeaking()
    if not self.m_speaking and #self.m_speakTable > 0 then
        --Log.i("开始说下一条语音")
        self:showSpeaking(table.remove(self.m_speakTable, 1))
    end
end
---------------------------------------
-- 函数功能：    检测语音播放状态
-- 返回值：      无
---------------------------------------
function GDRoom:getSpeakingStatus()
    Log.i("GDRoom:getSpeakingStatus")
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread)
    end
    self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
        local data = {}
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self)
    end, 0.5)
end

function GDRoom:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI)
    if info.usI then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread)
        self.m_getSpeakingThread = nil
        self:hideSpeaking(info.usI)
    end
end

----------------------------------------------
-- @desc 请求换桌 
-- @pram isReq 是否请求换桌
----------------------------------------------
function GDRoom:reqChangeDesk(isReq)
    Log.i("GDRoom:reqChangeDesk ", isReq)
    self:playBgMusic()
    if not isReq then
        Log.i("GDRoom:reqChangeDesk1 ", isReq)
        return
    end
    Log.i("GDRoom:reqChangeDesk2 ", isReq)

    PokerUIManager.getInstance():popToWnd(GDRoom)
    if DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS) > GDConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS) == GDConst.STATUS_ON_GAMEOVER then
        Log.i("GDRoom:reqChangeDesk 3", isReq)
        self:clearDesk()
    end
end

----------------------------------------------
-- @desc 内置聊天 
-- @pram packetInfo :网络消息
----------------------------------------------
function GDRoom:onRecvDefaultChat(packetInfo)
    if packetInfo.re == 1 then
        self:showDefaultChat(packetInfo.usI, packetInfo)
    else
        PokerToast.getInstance():show("发送失败")
    end
end

----------------------------------------------
-- @desc 内置聊天 
-- @pram playerId :玩家id
--       packetInfo :网络消息
----------------------------------------------
function GDRoom:showDefaultChat(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    if self:isLegalSeat(seat) then
        info.seat = seat
        if info.ty == 3 then
        else
            local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId)
            local sex = PlayerModel:getProp(GDDefine.SEX)
            info.sex = sex
            if info.ty == 2 then
                info.content = self:getChatContent(sex, info.emI)
            end
            self.chatView:showDefaultChat(info)
        end
    end
end

----------------------------------------------
-- @desc 续局 
----------------------------------------------
function GDRoom:reqContinueGame()
    Log.i("GDRoom:reqContinueGame : ")
    self:playBgMusic()

    PokerUIManager.getInstance():popToWnd(GDRoom)
    local status = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if status > GDConst.STATUS_NONE or status == GDConst.STATUS_ON_GAMEOVER then
        self:clearDesk()
        self:updateRoomJushuInfo()
    end
end

----------------------------------------------
-- @desc 發牌結束的一些處理 --当第四轮的时候 直接默认给后台发送不叫 
----------------------------------------------
function GDRoom:onDealcardEnd()
    local firstID = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_OPERATESEATID)
    -- self.panelGameGradeTips:setVisible(false)
    self:showOpration(firstID)
    self:onDealGong()
end

----------------------------------------------
-- @desc 收起更多頁面 
----------------------------------------------
function GDRoom:hideMoreLayer()
    self.btn_menu:setRotation(0)
    self.moreLayer:hidehide()
end

----------------------------------------------
-- @desc 显示设置 
----------------------------------------------
function GDRoom:showSetting()
    PokerUIManager:getInstance():pushWnd(PokerRoomSettingView)
end

----------------------------------------------
-- @desc 是否显示"没有牌过的上大家" 
-- @pram isShow:是否显示
----------------------------------------------
function GDRoom:showNoBigger(isShow)
    self.imgNoBigger:setVisible(isShow)
end

----------------------------------------------
-- @desc 被踢下线 
-- @pram packetInfo :网络消息  暂时不用
----------------------------------------------
function GDRoom:onRecvBrocast(packetInfo)
    Log.i("GDRoom:onRecvBrocast packetInfo")
    if packetInfo.ti == GDConst.MULTILOGIN then
        SocketManager.getInstance():closeSocket()
        SocketManager.getInstance().m_status = NETWORK_EXCEPTION -- 设置网络状态, 使得在 MainScene:onEnter 函数中可以跳转到登录界面
        
        local data = {}
        data.type = 1
        data.title = "提示"
        data.contentType = COMNONDIALOG_TYPE_KICKED
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理"
        data.yesCallback = function ()
            Log.i("enter the tirne")
            PokerUIManager.getInstance():popAllWnd(true)
            self:onExitRoom()
        end
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data, 255)
    elseif packetInfo.ti == GDConst.CLOSESERVER then -- 关服通知
        local data = {}
        data.type = 1
        data.title = "提示"
        data.content = packetInfo.co
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data, 255)
    end
end

----------------------------------------------
-- @desc 清除牌桌 
----------------------------------------------
function GDRoom:clearDesk()
    self.imgNoBigger:setVisible(false)
    self:clearAllPlayer()
end

----------------------------------------------
-- @desc 清除玩家 
----------------------------------------------
function GDRoom:clearAllPlayer()
    self.m_playerInfos = {}
    for seat = 1, GDConst.PLAYER_NUM do
        if self.m_seatViews[seat] then
            self.m_seatViews[seat]:reset()
        end
        if self.m_oprationViews[seat] then
            self.m_oprationViews[seat]:hideOpration()
        end
        if self.m_handCardViews[seat] then
            self.m_handCardViews[seat]:reset()
        end
        if self.m_oprationResultViews[seat] then
            self.m_oprationResultViews[seat]:hideOprationResult()
        end
    end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function GDRoom:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.btn_back then
            self:keyBack()
        elseif pWidget == self.btn_menu then
            self.btn_menu:setRotation(-180)
            self.moreLayer:showshow()
            NativeCallUmengEvent(UmengClickEvent.GDMoreButton)
        elseif pWidget == self.btn_chat then
            PokerUIManager.getInstance():pushWnd(PokerRoomChatView, self.gameChatTxtCfg, 0)
            NativeCallUmengEvent(UmengClickEvent.GDGameChatText)
        elseif pWidget == self.btn_jiesan then
            NativeCallUmengEvent(UmengClickEvent.GDGameDissmissRoom)
            self:jiesanBtnEvent()
        end
    end
end


---------------------------------------------------
-- @desc点击语音按钮
-- @pram pWidget :点击的ui
--       EventType:点击的类型
---------------------------------------------------
function GDRoom:onTouchSayButton(pWidget, EventType)
    Log.i("************")
    if EventType == ccui.TouchEventType.began then
        NativeCallUmengEvent(UmengClickEvent.GDGameVoiceInput)
        if not self.m_isTouching then
            self.m_isTouchBegan = true
            --开始录音
            local data = {}
            data.cmd = NativeCall.CMD_YY_START
            NativeCall.getInstance():callNative(data)
            self:showMic()
            HallAPI.SoundAPI:stopMusic()
            -- self.beginSayTxt:setString("松开 发送")
        end

    elseif EventType == ccui.TouchEventType.ended then
        if self.m_isTouchBegan then
            --停止录音
            local data = {}
            data.cmd = NativeCall.CMD_YY_STOP
            data.send = 1
            NativeCall.getInstance():callNative(data)
            self:hideMic()
            -- self.beginSayTxt:setString("按住 说话")
            self:playBgMusic()
            if YY_IS_LOGIN then
                self:getUploadStatus()
            else
                PokerToast.getInstance():show("功能未初始化完成，请稍后")
            end

            self.m_isTouchBegan = false
            self.m_isTouching = true
            self.m_pWidget:performWithDelay(function ()
                self.m_isTouching = false
            end, 0.5)
        end
    elseif EventType == ccui.TouchEventType.canceled then
        if  self.m_isTouchBegan then
            --停止录音
            local data = {}
            data.cmd = NativeCall.CMD_YY_STOP
            data.send = 0
            NativeCall.getInstance():callNative(data)
            self:hideMic()
            self:playBgMusic()
            -- self.beginSayTxt:setString("按住 说话")

            self.m_isTouchBegan = false
        end
    end
end

---------------------------------------
-- 函数功能：  显示录音动画
-- 返回值：    无
---------------------------------------
function GDRoom:showMic()
    self.img_mic:stopAllActions()
    self.panel_mic:setVisible(true)
    self.panel_mic_index = 0
    self.img_mic:performWithDelay(function ()
        self:updateMic()
    end, 0.2)
end

---------------------------------------
-- 函数功能：  播放语音动画
-- 返回值：    无
---------------------------------------
function GDRoom:updateMic()
    Log.i("*******************",self.panel_mic_index)
    self.panel_mic_index = self.panel_mic_index + 1
    if self.panel_mic_index > 4 then
        self.panel_mic_index = 0
    end
    self.img_mic:loadTexture("common/" .. self.panel_mic_index .. ".png" , ccui.TextureResType.plistType)
    self.img_mic:performWithDelay(function ()
        self:updateMic()
    end, 0.2)
 end

 ---------------------------------------
-- 函数功能：  停止语音动画
-- 返回值：    无
---------------------------------------
function GDRoom:hideMic()
    self.panel_mic:setVisible(false)
    self.img_mic:stopAllActions()
end


---------------------------------------
-- 函数功能：  检测语音上传状态
-- 返回值：    无
---------------------------------------
function GDRoom:getUploadStatus()
    Log.i("*************************GDRoom:getUploadStatus 1791")
    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread)
        self.m_getUploadThread = nil
    end
    self.m_getUploadThread = scheduler.scheduleGlobal(function()
        Log.i("*************************GDRoom:getUploadStatus 1797")
        local data = {}
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self)
    end, 0.1)
end

---------------------------------------
-- 函数功能：  检测完成发送语音消息
-- 返回值：    无
---------------------------------------
function GDRoom:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus 1", info.fileUrl)
    if info.fileUrl then
        scheduler.unscheduleGlobal(self.m_getUploadThread)
        self.m_getUploadThread = nil
        local matchStr = string.match(info.fileUrl,"http://")
        Log.i("--------onUpdateUploadStatus 2", matchStr, HallAPI.DataAPI:getRoomId())

         --发送语音聊天
         if matchStr and HallAPI.DataAPI:getRoomId() then
            local tmpData  ={}
            tmpData.usI = HallAPI.DataAPI:getUserId()
            tmpData.niN = HallAPI.DataAPI:getUserName()
            tmpData.roI = HallAPI.DataAPI:getRoomInfo().roI
            tmpData.ty = GDConst.CHATTYPE.VOICECHAT
            tmpData.co = info.fileUrl
            Log.i("dispatch say event")
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,tmpData)
        end

    end
end

----------------------------------------------
-- @desc 显示底注 
----------------------------------------------
function GDRoom:showBase()
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        self:updateRoomJushuInfo()
    end
end

----------------------------------------------
-- @desc 显示设置 
----------------------------------------------
function GDRoom:showSettingView()
    local settingView = PokerUIManager.getInstance():pushWnd(RoomMenuView)
    settingView:setDelegate(self)
end

----------------------------------------------
-- @desc 返回 
----------------------------------------------
function GDRoom:keyBack()
    if self:isInGame() then
        local data = {}
        data.type = 2
        data.title = "提示"                        
        data.yesTitle  = "退出游戏"
        data.cancelTitle = "关闭"
        data.content = "现在离开会由笨笨的机器人代打哦！\n\n 输了不能怪它哟！"
        data.yesCallback = function()
            HallAPI.EventAPI:dispatchEvent(GDGameEvent.REQEXITROOM)
        end
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
    else
        HallAPI.EventAPI:dispatchEvent(GDGameEvent.REQEXITROOM)
    end
end

----------------------------------------------
-- @desc 是否在游戏中 
----------------------------------------------
function GDRoom:isInGame()
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if gameStatus >= GDConst.STATUS_ON_JINGONG and gameStatus <= GDConst.STATUS_ON_OUT_CARD then
        return true
    end
    return false
end

----------------------------------------------
-- @desc 初始化聊天内容 
----------------------------------------------
function GDRoom:init_gameChatCfg()
    local sex = HallAPI.DataAPI:getUserSex()
    if sex == GDConst.FEMALE then
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
function GDRoom:getChatContent(sex, emjI)
    Log.i("------sex   emjI", sex, emjI)
    if sex == GDConst.MALE then
        return csvConfig.maleChatList[emjI].content
    else
        return csvConfig.femaleChatList[emjI].content
    end
end

----------------------------------------------
-- @desc 重值底牌
----------------------------------------------
function GDRoom:resetHandCardView()
    for seat=1,GDConst.PLAYER_NUM do
        if self.m_handCardViews[seat] then
            self.m_handCardViews[seat]:reset()
        end
    end
end

----------------------------------------------
-- @desc 隐藏操作结果 
----------------------------------------------
function GDRoom:hideAllOprationResult()
    for seat = 1, GDConst.PLAYER_NUM do
        self.m_oprationResultViews[seat]:hideOprationResult()
    end
end

----------------------------------------------
-- @desc 隐藏操作结果 
-- @pram playerId :玩家id
----------------------------------------------
function GDRoom:hideOpration(playerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration()
    end
end

----------------------------------------------
-- @desc 隐藏操作 
----------------------------------------------
function GDRoom:hideAllOpration()
    for seat = 1, GDConst.PLAYER_NUM do
        self.m_oprationViews[seat]:hideOpration()
    end
end

----------------------------------------------
-- @desc 更新操作 
-- @pram playerId :玩家id
--       info:更新相关信息
----------------------------------------------
function GDRoom:updateOpration(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    Log.i("GDRoom:updateOpration ", seat)
    Log.i("GDRoom:updateOpration info", info)
    self.imgYouPlay:setVisible(false)
    --第一局 我先打牌 显示该你出牌了
    local status = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    if seat == GDConst.SEAT_MINE and status == GDConst.STATUS_ON_OUT_CARD then
        local myPlayer = DataMgr:getInstance():getMyPlayerModel()
        local myCards = myPlayer:getProp(GDDefine.HAND_CARDS)
        if #myCards == 27 then
            local topPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_TOP)
            local rightPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_RIGHT)
            local leftPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_LEFT)
            local topPlayer = DataMgr:getInstance():getPlayerInfo(topPlayerID)
            local rPlayer = DataMgr:getInstance():getPlayerInfo(rightPlayerID)
            local lPlayer = DataMgr:getInstance():getPlayerInfo(leftPlayerID)
            local topCards = topPlayer:getProp(GDDefine.HAND_CARDS)
            local rCards = rPlayer:getProp(GDDefine.HAND_CARDS)
            local lCards = lPlayer:getProp(GDDefine.HAND_CARDS)
            if #topCards == 27 and #rCards == 27 and #lCards == 27 then
                self.imgYouPlay:setVisible(true)
            end
        end 
    end
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:updateOpration(info, self.m_handCardViews[GDConst.SEAT_MINE])
        self.m_handCardViews[seat]:updateOpration(info)
    end
end


---------------------------------------
-- 函数功能：    更新房间信息
-- 返回值：      无
---------------------------------------
function GDRoom:updateRoomJushuInfo()
    self.lab_roomId:setString(string.format("房间号:%d",HallAPI.DataAPI:getRoomId()))
end

function GDRoom:sendLocationInfo()
    -- 牌局开始时获取一次定位
    Log.i("sunbin:------ GDRoom:sendLocationInfo")
    NativeCall.getInstance():callNative({cmd = NativeCall.CMD_LOCATION}, function(info)
        local tmpData = {}
        tmpData.jiD = info.longitude
        tmpData.weD = info.latitude
        Log.i("sunbin:------ GDRoom:sendLocationInfo -- send")
        HallAPI.DataAPI:send(CODE_TYPE_HALL, GDSocketCmd.CODE_SEND_LOCATION, tmpData)
    end)
end

function GDRoom:showExchangeHead(call)
    local LastPlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST_LAST)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    if LastPlayerModelList and next(LastPlayerModelList) then
        local topPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_TOP)
        local rightPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_RIGHT)
        local leftPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_LEFT)
        local seatTab = {}
        local playerTab = {}
        for k,v in pairs(LastPlayerModelList) do
            local seat = v:getProp(GDDefine.SITE)
            local id = v:getProp(GDDefine.USERID)
            if seat == GDConst.SEAT_TOP then
                if id ~= topPlayerID then
                    table.insert(seatTab, id)
                    table.insert(playerTab, self.m_seatViews[seat])
                    self.m_seatViews[seat]:hide()
                end
            elseif seat == GDConst.SEAT_RIGHT then
                if id ~= rightPlayerID then
                    table.insert(seatTab, id)
                    self.m_seatViews[seat]:hide()
                    table.insert(playerTab, self.m_seatViews[seat])
                end
            elseif seat == GDConst.SEAT_LEFT then
                if id ~= leftPlayerID then
                    table.insert(seatTab, id)
                    self.m_seatViews[seat]:hide()
                    table.insert(playerTab, self.m_seatViews[seat])
                end
            end
            if #seatTab >= 2 then break end
        end
        if next(seatTab) then
            self.m_AnimView:headExchange(seatTab, playerTab, call)
        else
            if call then call() end
        end
    else
        if call then call() end
    end
end

return GDRoom