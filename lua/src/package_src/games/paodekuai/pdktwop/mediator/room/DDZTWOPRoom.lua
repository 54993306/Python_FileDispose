-------------------------------------------------------------------------
-- Desc:   二人斗地主扑克牌房间主UI
-- Last:
-- Author:   faker
-- 2017-11-04  新建
-- 2017-11-07  展示动画和展示游戏处理结果
-------------------------------------------------------------------------
local DDZTWOPAllCards = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPAllCards")
local PokerRoomMenuView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomMenuView")
local DDZTWOPTopBarView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPTopBarView")
local DDZTWOPHandCardView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPHandCardView")
local DDZTWOPOprationResultView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPOprationResultView") 
local DDZTWOPOprationView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPOprationView")
local DDZPKGameoverView = require("package_src.games.paodekuai.pdkcommon.widget.DDZPKGameoverView")
local DDZPKTotalGameoverView =  require("package_src.games.paodekuai.pdkcommon.widget.DDZPKTotalGameoverView")
local DDZTWOPStartingView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPStartingView")
local DDZTWOPPlayerView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPPlayerView")
local PokerRoomBase = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomBase")
local DDZTWOPDefine = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPDefine")
local PokerRoomChatView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomChatView")
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local DDZTWOPGameEvent = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPGameEvent")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local PokerRoomRuleView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomRuleView")
local csvConfig = require("package_src.games.paodekuai.pdktwop.data.config_GameData")
local PokerRoomSettingView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomSettingView")
local DDZTWOPAnimView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPAnimView")
local PokerRoomChatSay = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomChatSay")
local DDZTWOPConst = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPConst")
local DDZTWOPCard = require("package_src.games.paodekuai.pdktwop.utils.card.DDZTWOPCard")
local DDZTWOPCardTypeAnalyzer = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCardTypeAnalyzer")

local DDZTWOPRoom = class("DDZTWOPRoom", PokerRoomBase);

function DDZTWOPRoom:ctor()
    self.super.ctor(self, "package_res/games/ddztwop/room2p.csb");
    self:init_gameChatCfg()
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMEID,HallAPI.DataAPI:getGameId())
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_ROOMID,HallAPI.DataAPI:getRoomId())
    self.m_brocastContent = {};
    self.moreShow = false
    -- 监听事件
	self.m_listeners = {} 
    self:registMsgs()
    --手牌UI
    self.m_handCardViews = {}  
    --操作UI
    self.m_oprationViews = {}  
    --操作结果UI
    self.m_oprationResultViews = {}  
    --动画层
    self.m_AnimView = nil 
    -- 头像UI
    self.m_seatViews = {} 
    --桌子上方UI
    self.m_topBarView = nil 
    --语音聊天队列
    self.m_speakTable = {}
    
	--朋友开房逻辑特殊处理
	if(HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM) then
        --Log.i("当前游戏是从朋友开房进入")
        --底注
        -- local baseNum = kFriendRoomInfo:getCurRoomBaseInfo().an; 
        -- DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BASEROOM, baseNum);
        -- local data ={}
        -- data.startGameWay = StartGameType.FIRENDROOM;
        -- data.m_delegate = self;
        -- data.roomGameType = FriendRoomGameType.DDZ;
        -- self.m_friendOpenRoom = PokerOpenRoomGame.new(data)
        --设置成朋友开房逻辑
        --self.GameLogic   
    else
        self.roomInfo = HallAPI.DataAPI:getRoomInfoById(HallAPI.DataAPI:getGameId(), HallAPI.DataAPI:getRoomId());
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BASEROOM, self.roomInfo.an);
    end
end

---------------------------------------
-- 函数功能：    注册UI事件消息  注意：所有注册的事件消息在退出游戏时必须清除
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        table.insert(self.m_listeners, nhandle)
    end

    addEvent(DDZTWOPGameEvent.ONGAMESTART)
    addEvent(DDZTWOPGameEvent.ONCALLLORD)
    addEvent(DDZTWOPGameEvent.ONROBLORD)
    addEvent(DDZTWOPGameEvent.ONDOUBLE)
    addEvent(DDZTWOPGameEvent.ONSTRATPLAY)
    addEvent(DDZTWOPGameEvent.ONOUTCARD)
    addEvent(DDZTWOPGameEvent.GAMEOVER)
    addEvent(DDZTWOPGameEvent.ONTUOGUAN)
    addEvent(DDZTWOPGameEvent.ONRECONNECT)
    addEvent(DDZTWOPGameEvent.ONEXITROOM)
    addEvent(DDZTWOPGameEvent.ONUSERDEFCHAT)
    addEvent(DDZTWOPGameEvent.RECVBROCAST)
    addEvent(DDZTWOPGameEvent.SHOWOPRATION)

    addEvent(DDZTWOPGameEvent.UPDATEOPERATION)
    addEvent(DDZTWOPGameEvent.TOTALGAMEOVER)
    addEvent(DDZTWOPGameEvent.FRIENDCONTINUE)
    addEvent(DDZTWOPGameEvent.ONRECVREQDISSMISS)
    addEvent(DDZTWOPGameEvent.ONRECVDISSMISSEND)

    --游戏内事件
    addEvent(DDZTWOPGameEvent.UIREQCONTINUE)
    addEvent(DDZTWOPGameEvent.UIREQCHANGEDESK)
    addEvent(DDZTWOPGameEvent.RESAYCHAT)
    addEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CLOSE)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONFAIL)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONWEAK)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONEXCEPTION)
    addEvent(PokerEventDef.GameEvent.GAME_NETWORK_RECONNECTED)

    --大厅事件  
   -- addEvent(HallAPI.EventAPI.SOCKET_EVENT_CLOSED)
   
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_CONNECT_FAILURE)
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_RECONNECTED)
    addEvent(HallAPI.EventAPI.SOCKET_EVENT_CONNECTWEAK)
    addEvent(HallAPI.EventAPI.EXIT_GAME_FORCE)
end

-- 函数功能：    取消注册监听事件消息
-- 返回值：      无
function DDZTWOPRoom:unRegistMsgs()
    for k,v in pairs(self.m_listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end
end

---------------------------------------
-- 函数功能：    监听UI事件消息
-- 返回值：      无
-- id:   事件id
---------------------------------------
function DDZTWOPRoom:ListenToEvent(id, ... )
    if id == DDZTWOPGameEvent.ONGAMESTART then
        self:onGameStart(...)
    elseif id == DDZTWOPGameEvent.ONCALLLORD then
        self:onCallLord(...)
    elseif id == DDZTWOPGameEvent.ONROBLORD then
        self:onRecvCallRob(...)
    elseif id == DDZTWOPGameEvent.ONSTRATPLAY then
        self:onRecvStartPlay(...)
    elseif id == DDZTWOPGameEvent.ONOUTCARD then
        self:onRecvOutCard(...)
    elseif id == DDZTWOPGameEvent.GAMEOVER then
        self:onRecvGameOver(...)
    elseif id == DDZTWOPGameEvent.ONTUOGUAN then
        self:onRecvTuoGuan(...)
    elseif id == DDZTWOPGameEvent.ONRECONNECT then
        self:onRecvReconnect(...)
    elseif id == DDZTWOPGameEvent.ONEXITROOM or id == PokerEventDef.GameEvent.GAME_EXIT_GAME then
        self:onRecvExitRoom(...)
    elseif id == DDZTWOPGameEvent.ONUSERDEFCHAT then
        self:onRecvDefaultChat(...)
    elseif id == DDZTWOPGameEvent.RECVBROCAST then
        self:onRecvBrocast(...)
    elseif id == DDZTWOPGameEvent.UPDATEOPERATION then
        self:updateOpration(...)
    elseif id == DDZTWOPGameEvent.UIREQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == DDZTWOPGameEvent.UIREQCONTINUE then
        self:reqContinueGame(...)
    elseif id == DDZTWOPGameEvent.SHOWOPRATION then
        self:onRecvShowopration()
    elseif id == HallAPI.EventAPI.EXIT_GAME_FORCE then
        self:onExitRoom()
    elseif id == DDZTWOPGameEvent.RESAYCHAT then
        self:onRecvSayChat(...)
    elseif id == DDZTWOPGameEvent.TOTALGAMEOVER then
        self:onRecvTotalGameover(...)
    elseif id == DDZTWOPGameEvent.FRIENDCONTINUE then
        self:onRecvFriendContinue(...)
    elseif id == DDZTWOPGameEvent.ONRECVREQDISSMISS then
        self:onRecvReqDismiss(...)
    elseif id == DDZTWOPGameEvent.ONRECVDISSMISSEND then
       self:onRecvDismissEnd(...)
    elseif id == PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER then
        self:gameOverUICallBack()
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
    end
end

---------------------------------------
-- 函数功能：    初始化二人斗地主roomUI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onInit()
    self.panel_allCards = DDZTWOPAllCards.new(self)
    self.panel_allCards:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_pWidget:addChild(self.panel_allCards)
    self.panel_allCards:setPosition(cc.p(display.cx, display.cy))
    for i = 1, DDZTWOPConst.PLAYER_NUM  do
        self.m_seatViews[i] = DDZTWOPPlayerView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_head" .. i),i)
        self.m_oprationViews[i] = DDZTWOPOprationView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration" .. i), i)
        self.m_oprationResultViews[i] = DDZTWOPOprationResultView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_opration_result" .. i), i)
        self.m_handCardViews[i] = DDZTWOPHandCardView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_handCard" .. i), i)
    end

    self.m_topBarView = DDZTWOPTopBarView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_topbar"))
    self.m_AnimView = DDZTWOPAnimView.new(self,ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_anim"))
    self.m_AnimView:show()

    local mWidget = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_starting");
    self.m_startingView = DDZTWOPStartingView.new(self, mWidget, 20);

    self.btn_menu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_menu")
    self.btn_menu:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chat")
    self.btn_chat:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_menu = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_menu")
    self.btn_menu:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_voice_chat = ccui.Helper:seekWidgetByName(self.m_pWidget,"voice_chat")
    self.btn_voice_chat:addTouchEventListener(handler(self,self.onTouchSayButton))

    -- self.btn_weixin = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_weixin")
    -- self.btn_weixin:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_tuoguan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_tuoguan")
    self.btn_tuoguan:addTouchEventListener(handler(self,self.onClickButton))
    self:hideTuoguanBtn()

    self.btn_help = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_help")
    self.btn_help:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_setting")
    self.btn_setting:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_jiesan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_jiean")
    self.btn_jiesan:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_drop_rule = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_drop_rule")
    self.btn_drop_rule:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_drop_jiesan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_drop_jiesan")
    self.btn_drop_jiesan:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_rule = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_help")
    self.btn_rule:addTouchEventListener(handler(self,self.onClickButton))

    self.morePanel = ccui.Helper:seekWidgetByName(self.m_pWidget,"morePanel")
    self.morePanel:addTouchEventListener(handler(self,self.onClickMorePanel))

    --让牌提示
    self.lab_rangCards = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_11111")

    --底数
    self.bitmap_base = self:getWidget(self.m_pWidget,"BitmapLabel_base",{bold = true})
    self.img_base = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_base")

    self.room_id = self:getWidget(self.m_pWidget,"lbl_roomid",{bold = true})
    self.paytype = self:getWidget(self.m_pWidget,"lbl_paytype",{bold = true})

    self.btn_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_touch")
    self.btn_root:addTouchEventListener(handler(self, self.onClickButton))

    self.panel_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_say")
    self.panel_mic:setVisible(false)
    self.img_mic = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_say1")

    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self.btn_voice_chat:setVisible(false)
        self:hideTuoguanBtn()
    end
end

---------------------------------------
-- 函数功能：    展示二人斗地主roomUI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onShow()
   -- PokerUIManager.getInstance():pushWnd(DDZPKTotalGameoverView, packetInfo);
--[[
    local gameid = HallAPI.DataAPI:getGameId()
    local roomid = HallAPI.DataAPI:getRoomId()
    local data = {}
    data.opS = 2
    data.gaI = gameid
    data.plT = 1;
    data.roI = roomid
    data.ty = 1;
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZTWOPSocketCmd.CODE_SEND_GAMESTART, data);
]]
    --修改为开局流程由大厅来处理
    --HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,0);

    self.m_pWidget:setTouchEnabled(false)
    self.m_pWidget:setTouchSwallowEnabled(false)
    self:clearDesk()
    Log.i("*************************************DDZTWOP onshow")
    HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    --背景音乐
    self.m_pWidget:performWithDelay(function()
        self:playBgMusic()
    end, 0.5);
	--朋友开房逻辑特殊处理
	if(HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM) then
       Log.i("当前游戏是从朋友开房进入")
       self:hideStarting()
       self:updateRoomJushuInfo()
       --self:showWeiXinBtn()
    else
        self:showStarting();
        --self:hideWeiXinBtn()
    end
end
---------------------------------------
-- 函数功能：    播放二人斗地主背景音乐
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:playBgMusic()
    --HallAPI.SoundAPI:preloadMusic(DDZTWOPConst.BGMUSICPATH)
    HallAPI.SoundAPI:playMusic(DDZTWOPConst.BGMUSICPATH, true);
    -- if not HallAPI.SoundAPI:getMusicMute() and HallAPI.SoundAPI:getMusicVolume() <= 0 then
    --     HallAPI.SoundAPI:pauseMusic()
    -- end
end

---------------------------------------
-- 函数功能：    更新房间信息
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:updateRoomJushuInfo()
    self.img_base:setVisible(true)
    local roomInfo = HallAPI.DataAPI:getRoomInfo()
    self.bitmap_base:setString(string.format(DDZTWOPConst.ROOMINFODES,1,HallAPI.DataAPI:getJuNowCnt(),HallAPI.DataAPI:getJuTotal()))
    self.room_id:setString(string.format(DDZTWOPConst.ROOMIDDES,HallAPI.DataAPI:getRoomId()))
    if roomInfo.RoJST == DDZTWOPConst.PAYTYPE1 or roomInfo.RoJST == DDZTWOPConst.PAYTYPE2 then
        self.paytype:setString(DDZTWOPConst.PAYTYPEDES[roomInfo.RoJST])
    elseif roomInfo.RoJST == DDZTWOPConst.PAYTYPE3 then
        self.paytype:setString(string.format(DDZTWOPConst.PAYTYPEDES[DDZTWOPConst.PAYTYPE3],math.ceil( roomInfo.RoFS / roomInfo.plS )))
    end
end


---------------------------------------
-- 函数功能：    关闭二人斗地主roomUI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onClose()
    --Log.i("DDZTWOPRoom:onClose")
    HallAPI.SoundAPI:stopMusic()

    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
    end

    self:unRegistMsgs()
    for i,v in ipairs(self.m_handCardViews) do
        v:dtor()
    end
    for i,v in ipairs(self.m_oprationResultViews) do
        v:dtor()
    end
    for i,v in ipairs(self.m_seatViews) do
        v:dtor()
    end
end

---------------------------------------
-- 函数功能：   退出房间处理
-- 返回值：      无
--packetInfo:   退出房间消息内容封装
---------------------------------------
function DDZTWOPRoom:onRecvExitRoom(packetInfo)
    self:onExitRoom();
end

---------------------------------------
-- 函数功能：    退出到大厅
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onExitRoom()
    PokerUIManager.getInstance():popAllWnd();
    cc.Director:getInstance():popScene();
end

---------------------------------------
-- 函数功能：    请求换桌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:reqChangeDesk()
    self:playBgMusic();
    self:showStarting();

    PokerUIManager.getInstance():popToWnd(DDZTWOPRoom);
    if DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) > DDZTWOPConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) == DDZTWOPConst.STATUS_GAMEOVER then
        self:clearDesk();
    end
end

---------------------------------------
-- 函数功能：    聊天结果处理
-- 返回值：      无
--packetInfo:   封装聊天结果内容
--[[
    参数：
    usI           玩家id
    reI           接收对象id（type 3 适用）
    re            发送结果（0：失败  1：成功）
    serializeType  序列化类型
    emI           表情id 
    gaPI          对局ID
    ty            聊天类型（1：内置emoji 2：内置语言 3：付费道具表情）
]]
---------------------------------------
function DDZTWOPRoom:onRecvDefaultChat(packetInfo)
    if packetInfo.re == 1 then
        if packetInfo.ty == 1 or packetInfo.ty == 2 then 
            self:showDefaultChat(packetInfo.usI, packetInfo);
        else
            self:showDefaultChat(packetInfo.usI, packetInfo, packetInfo.reI);
        end
    else
        HallAPI.ViewAPI:showToast("发送失败");
    end
end

---------------------------------------
-- 函数功能：    展示聊天结果
-- 返回值：      无
--[[
    参数：
    playerId：  玩家id
    info：      聊天数据
    dplayerId:  聊天对象id  针对魔法表情
]]
---------------------------------------
function DDZTWOPRoom:showDefaultChat(playerId, info, dplayerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId);
        local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)
        if info.ty == 2 then
            info.content = self:getChatContent(sex, info.emI)
        end
        self.m_seatViews[seat]:showDefaultChat(info);
    end
end

---------------------------------------
-- 函数功能：    清除牌桌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:clearDesk()
    local tgState = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    self:clearAllPlayer()
    self:hideBase()
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:resetTopBar()
    end
end

---------------------------------------
-- 函数功能：    UI点击事件处理
-- 返回值：      无
--[[
    参数：
    pWidget:    点击对象
    EventType:  点击事件
]]
---------------------------------------
function DDZTWOPRoom:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        if pWidget == self.btn_menu then
           self:updateMenuPanel()
        elseif pWidget == self.btn_setting then
            local data = {}
            data.gamepath = self.gamepath
            PokerUIManager:getInstance():pushWnd(PokerRoomSettingView, data)
        elseif pWidget == self.btn_drop_rule then
            local info = {}
            info.gamepath = "ddztwop"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView,info);
        elseif pWidget == self.btn_drop_jiesan then
            self:jiesanBtnEvent()
        elseif pWidget == self.btn_tuoguan then
            self:onClickTuoGuan()
        elseif pWidget == self.btn_help then
            local info = {}
            info.gamepath = "ddztwop"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView,info);
        elseif pWidget == self.btn_jiesan then
            self:jiesanBtnEvent()
        elseif pWidget == self.btn_reconnect then
            local data = {};
            data.plI = DDZTWOPGameManager.getInstance():getGamePlayId();
            SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME, data);
        elseif pWidget == self.btn_chat then
            local chatView = PokerUIManager.getInstance():pushWnd(PokerRoomChatView, self.gameChatTxtCfg, 0);
        elseif pWidget == self.btn_root then
            self:onClickRoot();
        end;
    end
end

---------------------------------------
-- 函数功能：  检测语音上传状态
-- 返回值：    无
---------------------------------------
function DDZTWOPRoom:getUploadStatus()
    Log.i("*************************PokerRoomChatSay4")
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

---------------------------------------
-- 函数功能：  检测完成发送语音消息
-- 返回值：    无
---------------------------------------
function DDZTWOPRoom:onUpdateUploadStatus(info)
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
        self.m_getUploadThread = nil;
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus", matchStr);

         --发送语音聊天
         if matchStr and HallAPI.DataAPI:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = HallAPI.DataAPI:getUserId();
            tmpData.niN = HallAPI.DataAPI:getUserName();
            tmpData.roI = HallAPI.DataAPI:getRoomInfo().roI;
            tmpData.ty = DDZTWOPConst.CHATTYPE.VOICECHAT
            tmpData.co = info.fileUrl;
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,tmpData)
        end

    end
end

function DDZTWOPRoom:onTouchSayButton(pWidget, EventType)
    Log.i("************")
    if EventType == ccui.TouchEventType.began then
        if not self.m_isTouching then
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

            if YY_IS_LOGIN then
                self:getUploadStatus();
            else
                Toast.getInstance():show("功能未初始化完成，请稍后");
            end
            self:playBgMusic()
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
            -- self.beginSayTxt:setString("按住 说话");
            self:playBgMusic()

            self.m_isTouchBegan = false;
        end
    end
end

---------------------------------------
-- 函数功能：  显示录音动画
-- 返回值：    无
---------------------------------------
function DDZTWOPRoom:showMic()
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
function DDZTWOPRoom:updateMic()
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
 function DDZTWOPRoom:hideMic()
    self.panel_mic:setVisible(false);
    self.img_mic:stopAllActions();
end

---------------------------------------
-- 函数功能：  切换菜单面板显示状态
-- 返回值：    无
---------------------------------------
function DDZTWOPRoom:updateMenuPanel()
    self.morePanel:setVisible(not self.morePanel:isVisible())
    local rotation = self.morePanel:isVisible() and 180 or 0
    self.btn_menu:setRotation(rotation)
    self.isMorePanel = self.morePanel:isVisible()
end

---------------------------------------
--函数功能：退出房间
--返回值：  无
---------------------------------------
function DDZTWOPRoom:onClickExitRoom()
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        local data = {}
        data.title = "提示" 
        data.type = 2
        data.content = DDZTWOPConst.FRIENDGAMEINGTIPS
        data.yesCallback = function() 
        --[[
            type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
            ##  usI  long  玩家id
            ##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
            ##  niN  String  发起的用户昵称
            ##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
            local tmpData={}
            tmpData.usI =  HallAPI.DataAPI:getUserId()
            tmpData.re = 1
            tmpData.niN = HallAPI.DataAPI:getUserName()
            tmpData.isF = 0
            -- HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT, tmpData)
        end

        data.cancalCallback = function()
        end

        data.closeCallback = function()
        end
        PokerUIManager:getInstance():pushWnd(PokerRoomDialogView, data) 
    else
        if DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_GAMESTART) then
            local data = {}
            data.type = 2
            data.title = "提示"                        
            data.content = DDZTWOPConst.GAMEINGTIPS
            data.yesCallback = function()
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
            end
            PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
        else
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
        end
    end
end

--------------------------------------
-- 函数功能： 点击托管
-- 返回值：   无
--------------------------------------
function DDZTWOPRoom:onClickTuoGuan()
    local tuoguanStates =  DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    if tuoguanStates[HallAPI.DataAPI:getUserId()] and (tuoguanStates[HallAPI.DataAPI:getUserId()] == DDZTWOPConst.TUOGUAN_STATE_1) then
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_TUOGUAN, 0)
    else
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_TUOGUAN, 1)
    end
end
---------------------------------------
-- 函数功能：    点击牌以外的地方重选牌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onClickRoot()
    self.root_click_time = self.root_click_time or 0;
    self.root_click_time = self.root_click_time + 1;
    if self.m_clear_click_time then
        self.m_pWidget:stopAction(self.m_clear_click_time);
        self.m_clear_click_time = nil;
    end 
    if self.root_click_time == 2 then
        self.root_click_time = 0;
        local info = {};
        info.action = "chongxuan";
        HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
    else
        self.m_clear_click_time = self.m_pWidget:performWithDelay(function()
            self.root_click_time = 0;
        end, 0.5);
    end 
end


---------------------------------------
--函数功能：   点击morepanel弹回菜单
---------------------------------------
function DDZTWOPRoom:onClickMorePanel()
    if self.isMorePanel then
        self:onClickButton(self.btn_menu,ccui.TouchEventType.ended)
    end
end

---------------------------------------
-- 函数功能：    显示游戏速配倒计时
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showStarting()
    --if not self.m_data or not self.m_data.isRusumeGame then
        self.m_startingView:show();
    --else
    --    self.m_data.isRusumeGame = false;
    --end
    self.btn_chat:setVisible(false); 
end

---------------------------------------
-- 函数功能：    隐藏游戏速配倒计时
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:hideStarting()
    if self.m_startingView then
        self.m_startingView:hide();
    end
    self.btn_chat:setVisible(true);
end

---------------------------------------
-- 函数功能：    显示微信邀请按钮
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showWeiXinBtn()
    --self.btn_weixin:setVisible(true);
end

---------------------------------------
-- 函数功能：    隐藏微信邀请按钮
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:hideWeiXinBtn()
    --self.btn_weixin:setVisible(false);
end
---------------------------------------
-- 函数功能：   重置roomUI顶部TopbarView
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:resetTopBar()
    if not self.m_topBarView then
        local mWidget = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_topbar");

        self.m_topBarView = DDZTWOPTopBarView.new(self, mWidget);
        self.m_topBarView:show();
        self.m_topBarView:hideBottomCard();
    end
    self.m_topBarView:hideBottomCard();
end

---------------------------------------
-- 函数功能：    清楚所有玩家
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:clearAllPlayer()
    self.m_playerInfos = {};
    for seat = 1, DDZTWOPConst.PLAYER_NUM do
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

---------------------------------------
-- 函数功能：    接受返回键事件
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:keyBack()
    if self.isMorePanel then
        self:onClickButton(self.btn_menu,ccui.TouchEventType.ended)
    else
        if DataMgr.getInstance():getBoolByKey(DDZTWOPConst.DataMgrKey_GAMESTART) then
            local data = {}
            data.type = 2
            data.title = "提示"                       
            data.content = DDZTWOPConst.GAMEINGTIPS
            data.yesCallback = function()
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
            end
            PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
        else
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
        end
    end
end

---------------------------------------
-- 函数功能：    游戏开始消息处理
-- 返回值：      无
--packetInfo:   封装游戏开始消息内容
--firstID:      第一个操作玩家id
---------------------------------------
function DDZTWOPRoom:onGameStart(packetInfo,firstID)
    self.m_isShowGameOverUI = false
    self:hideAllOprationResult()
    self:updateRoomJushuInfo()
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:hideStarting()
        self:showBase()
        self:showTuoguanBtn()
    else
        self:hideAllReady()
    end
    for i = 1, DDZTWOPConst.PLAYER_NUM  do
        self.m_seatViews[i]:updatePlayerInfo() 
    end
    for k,v in pairs(self.m_seatViews) do
        v:setDouble()
    end
    -- if self.m_topBarView then
    --     self.m_topBarView:showBottomCard();
    --     self.m_topBarView:showTopPan();
    -- end
    self.panel_allCards:dealCard(false)
    self:dealCard(false)
    --self:showOpration(firstID); 
end

---------------------------------------
-- 函数功能：    发牌函数
-- 返回值：      无
--isReconnect:  是否重新连接
---------------------------------------
function DDZTWOPRoom:dealCard(isReconnect)
    if not isReconnect then
        kPokerSoundPlayer:playEffect("fapai");
    end

    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        local seat = v:getProp(DDZTWOPDefine.SITE)
        self.m_handCardViews[seat]:dealCard(isReconnect);  
    end
end

---------------------------------------
-- 函数功能：    叫地主消息处理
-- 返回值：      无
--packetInfo:   封装叫地主消息内容
--[[
    参数：
    uiI             玩家ID
    rangPaiCount    让牌数量
    fl              是否叫地主（0：不叫  1：叫地主）
    fl0             是否确定地主（0：继续叫地主  1：确定地主）
    neP             nextPlayer  fl0 =0,为下一个叫牌玩家ID；fl0 = 1,为下一个抢地主或者是出牌玩家ID
    gaPI            对局房间id
]]
---------------------------------------
function DDZTWOPRoom:onCallLord(packetInfo)
    self:showOprationResult(packetInfo.usI, packetInfo,true);  
    --叫地主
    if packetInfo.fl == 1 then
        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end
    end

    --已确定地主
    if packetInfo.fl0 == 1 then
        local lordId = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID)
        self:setRole()
        if self.m_topBarView then
            self.m_topBarView:showBottomCard()
        end
        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end
        local info = {};
        info.isMustOut = true;
        self:showOpration(packetInfo.neP,info)
        self:addBottomCard(lordId);
    else
        self:showOpration(packetInfo.neP);
    end
    self:showRangCards()
end

---------------------------------------
-- 函数功能：    处理抢地主消息
-- 返回值：      无
-- packetInfo   封装抢地主消息内容
--[[
    参数：
    uiI                玩家id
    rangPaiCount        让牌数量
    f1                  是否抢地主（0：继续抢地主  1：抢地主）
    fl0                 (0:继续抢地主 1：确定地主)
    cuD                 当前倍数
    dipaiDouble          底牌倍数
    neP                  下一个操作玩家ID
    gaPI                 对局ID
    dipaiType             底牌类型
]]
---------------------------------------
function DDZTWOPRoom:onRecvCallRob(packetInfo)
    self:showOprationResult(packetInfo.usI, packetInfo);
    if packetInfo.fl == 1 then
        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end
    end
    if packetInfo.fl0 == 1 then
        local lordId = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID)
        self:setRole();
        if self.m_topBarView then
            self.m_topBarView:showBottomCard();
        end
        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end
        self:addBottomCard(lordId);
    else
        self:showOpration(packetInfo.neP);
    end
    self:showRangCards()
end

---------------------------------------
-- 函数功能：    开始打牌
-- 返回值：      无
-- packetInfo： 封装开始打牌消息内容
--[[
    参数：
    rangPaiCount         让牌数量
    fiPI                  首先打牌id
    serialize             序列化类型
    dipaiDouble            底牌加倍倍数
    dipaiType              底牌类型
    debug                  是否开启debug模式 （开启名牌模式）
    mpInfos                明牌数据类型
    la                     赖子牌     
]]
---------------------------------------
function DDZTWOPRoom:onRecvStartPlay(packetInfo)
    packetInfo = checktable(packetInfo)
    
    self:hideAllOpration();
    self:hideAllOprationResult();

    local info = {};
    info.isMustOut = true;
    self:showOpration(packetInfo.fiPI,info);
    if packetInfo.mapInfos then
        for k,v in pairs(packetInfo.mapInfos) do
            if tonumber(k) ~= HallAPI.DataAPI:getUserId() then
                self:showOprationResult(tonumber(k),packetInfo);
            end
        end
    end 
    self:showTipCount()
end

---------------------------------------
-- 函数功能：    出牌
-- 返回值：      无
-- packetInfo:  封装出牌消息内容
--[[
    参数：
    usI           玩家ID
    countCards     记牌数据
    serializeType   序列化类型
    mpInfos         明牌数据  （用于测试）
    f1              是否出牌 （0 不出 1 出牌）
    cuD             加倍倍数
    neP             下一个出牌玩家ID
    plC             出牌数据
    laC             赖子数据
    gaPI            对局ID
]]
---------------------------------------
function DDZTWOPRoom:onRecvOutCard(packetInfo, isReconnect)
    -- Log.i("DDZRoom:onRecvOutCard",packetInfo)
    packetInfo = checktable(packetInfo);

    if packetInfo.optSuc == DDZTWOPConst.SERVEROUTCARDSTATUS0 or packetInfo.optSuc == DDZTWOPConst.SERVEROUTCARDSTATUS1 then
        HallAPI.ViewAPI:showToast(DDZTWOPConst.CARDTYPETIPS);
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    elseif packetInfo.optSuc == DDZTWOPConst.SERVEROUTCARDSTATUS2 and not packetInfo.firstOutCard then
        self:hideOpration(packetInfo.usI);
        local cards = packetInfo.plC or {};
        local cardValues = {};
        for k, v in pairs(cards) do
            local type, val = DDZTWOPCard.cardConvert(v);
            table.insert(cardValues, val);
        end
        local cardType, keyCard = DDZTWOPCardTypeAnalyzer.getCardType(cardValues);
        if cardType >= DDZTWOPCard.CT_BOMB then
            Log.i("Classical:onRecvOutCard", packetInfo);
            for k,v in pairs(self.m_seatViews) do
                v:setDouble()
            end
        end
    
        local outCardInfo = {};
        outCardInfo.cards = cards;
        outCardInfo.cardValues = cardValues;
        outCardInfo.cardType = cardType;
        outCardInfo.keyCardValue = keyCard;
        outCardInfo.fl = packetInfo.fl;
        outCardInfo.usI = packetInfo.usI
        outCardInfo.mapInfos = packetInfo.mapInfos
        self:showOprationResult(packetInfo.usI, outCardInfo, isReconnect);
    end

    --最后一手牌打出判断游戏是否结束
    if packetInfo.gameover then
        return
    end

    if packetInfo.neP > 0 then
        local info = {};
        info.isMustOut = false;
        info.playCard = true
        if packetInfo.neP == HallAPI.DataAPI:getUserId() then
            local lastOutCards = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_LASTOUTCARDS)
            if (not lastOutCards) or (#lastOutCards == 0) then
                info.isMustOut = true;
            elseif cardType == DDZTWOPCard.CT_MISSILE then
                info.autoNotOut = true;
            end
            local handCardView = self.m_handCardViews[DDZTWOPConst.SEAT_MINE]
            local isBigger = handCardView.m_handCardView:checkIsBiggerCard()
            info.isBigger = isBigger
        end 
        self:showOpration(packetInfo.neP,info,isReconnect);
    end
    
end

---------------------------------------
-- 函数功能：    游戏结束
-- 返回值：      无
--packetInfo:   封装游戏结束消息内容
--[[
    参数：
    wiID               赢家ID
    plI1               玩家信息列表
    {
        fo             玩家财富
        bankruptcy     是否封顶
        isB            是否破产 (0没破产 1破产)
        foC            财富发生变化
        plI            玩家ID
        ca             展示手牌
        cuD            加倍倍数
        winFull        是否封顶 
    }
    cuD0               自定义加倍
    mu                 总倍数
    wiT                输赢类型（0：游戏豆 1：积分）
    baUID              地主ID
    foB                游戏房间底注
    serializeType      序列化类型
    anS                是否反春（0：不是  1：是）
    sp                 是否春天（0：不是 1：是）
    boT                炸弹次数
    gaPI               游戏对局ID
    grT                抢地主次数
    dipaiType          底牌类型
]]
---------------------------------------
function DDZTWOPRoom:onRecvGameOver(packetInfo)
    --Log.i("onRecvGameOver packetInfo",packetInfo)
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:onTuoGuanChangeAll();
        self:hideTuoguanBtn()
    end
    self:onClickMorePanel()
    scheduler.performWithDelayGlobal(function()
        for k, v in pairs(packetInfo.plI1) do
           self:showOprationResult(v.plI, v, false, packetInfo.wiID);
        end
        if packetInfo.sp == DDZTWOPConst.SPRINGSTATUS2 then
            self:showGameAnim(DDZTWOPConst.SEAT_MINE, DDZTWOPConst.SPRINGSTATUS2);
        elseif packetInfo.anS == DDZTWOPConst.SPRINGSTATUS2 then
            self:showGameAnim(DDZTWOPConst.SEAT_MINE, DDZTWOPConst.SPRINGSTATUS2);
        end

        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end

        --显示结算界面
        scheduler.performWithDelayGlobal(function()
           -- PokerUIManager.getInstance():popToWnd(DDZTWOPRoom);
            local gameoverView = PokerUIManager.getInstance():pushWnd(DDZPKGameoverView, packetInfo);
            gameoverView:setDelegate(self);
            
        end, DDZTWOPConst.DELAY_SHOW_CARD, true); 
    end, DDZTWOPConst.DELAY_LAST_CARD, true);
end

function DDZTWOPRoom:onRecvTotalGameover(packetInfo)
    self:onClickMorePanel()
    scheduler.performWithDelayGlobal(function()
        for k, v in pairs(packetInfo.plL) do
           self:showOprationResult(v.usI, v, false, packetInfo.winners[1],true);
        end
        if packetInfo.sp == DDZTWOPConst.SPRINGSTATUS2 then
            self:showGameAnim(DDZTWOPConst.SEAT_MINE, DDZTWOPConst.SPRINGSTATUS2);
        elseif packetInfo.anS == DDZTWOPConst.SPRINGSTATUS2 then
            self:showGameAnim(DDZTWOPConst.SEAT_MINE, DDZTWOPConst.SPRINGSTATUS2);
        end

        for k,v in pairs(self.m_seatViews) do
            v:setDouble()
        end

        --显示结算界面
        scheduler.performWithDelayGlobal(function()
            PokerUIManager.getInstance():popToWnd(DDZTWOPRoom);
            local gameoverView = PokerUIManager.getInstance():pushWnd(DDZPKTotalGameoverView, packetInfo);
        end, DDZTWOPConst.DELAY_SHOW_CARD, true); 
    end, DDZTWOPConst.DELAY_LAST_CARD, true);
end

---------------------------------------
-- 函数功能：    续局重置头像
-- 返回值：      无
-- packetInfo:   服务器返回数据
---------------------------------------
function DDZTWOPRoom:onRecvFriendContinue(packetInfo)
    for i,v in ipairs(packetInfo.usI) do
        local seat = DataMgr.getInstance():getSeatByPlayerId(v)
        if self.m_seatViews[seat] then
            self.m_seatViews[seat]:reset()
            self.m_seatViews[seat]:showReady()
        end
    end
    self.m_topBarView:hideBottomCard()
end

---------------------------------------
-- 函数功能：    弹出总结算界面
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:OnRecvRoomReWard()
    local totalData = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_FRIENDTOTALDATA)
    PokerUIManager.getInstance():popToWnd(DDZTWOPRoom);
    local gameoverView = PokerUIManager.getInstance():pushWnd(DDZPKTotalGameoverView, totalData.param);
end

---------------------------------------
-- 函数功能：    续局重置头像
-- 返回值：      无
-- packetInfo:   服务器返回数据
---------------------------------------
function DDZTWOPRoom:hideAllReady()
    for i=1,DDZTWOPConst.PLAYER_NUM do
        if self.m_seatViews[i] then
            self.m_seatViews[i]:hideReady()
        end
    end
    
end

---------------------------------------
-- 函数功能：    检查所有玩家托管状态
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onTuoGuanChangeAll()
    for i =1, DDZTWOPConst.PLAYER_NUM do
        self.m_seatViews[i]:onTuoGuanChange();
    end
end

---------------------------------------
-- 函数功能：    show动画
-- 返回值：      无
--[[
    参数:
    seat:       玩家座位
    type：      牌组类型
]]
---------------------------------------
function DDZTWOPRoom:showGameAnim(seat, type)
    self.m_AnimView:showGameAnim(seat, type);
end

---------------------------------------
-- 函数功能：    游戏托管消息处理
-- 返回值：      无
-- packetInfo:  封装游戏托管消息内容 maPI(托管玩家id) isM(0没有托管1托管)
--[[
    参数：
    maPI            托管玩家ID
    isM             是否托管（0：不托管  1：托管）
    serializeType   序列化类型
]]
---------------------------------------
function DDZTWOPRoom:onRecvTuoGuan(packetInfo)
    --## 托管玩家id maPI
    --## 是否被托管 isM
    Log.i("DDZTWOPRoom onRecvTuoGuan packetInfo", packetInfo);
    if packetInfo.maPI == HallAPI.DataAPI:getUserId() then
        --self:setTouchEnabled(packetInfo.isM == 1)
    end
    PokerUIManager.getInstance():popToWnd(self)
    self:onTuoGuanChange(packetInfo.maPI, packetInfo);
end

function DDZTWOPRoom:onTuoGuanChange(playerId, packetInfo)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    Log.i("DDZTWOPRoom:onTuoGuanChange ", seat);
    if self:isLegalSeat(seat) then
        self.m_handCardViews[seat]:onTuoGuanChange(playerId);
        self.m_oprationViews[seat]:onTuoGuanChange(playerId,self.m_handCardViews[DDZTWOPConst.SEAT_MINE]);
        self.m_seatViews[seat]:onTuoGuanChange(packetInfo);
    end
end

---------------------------------------
-- 函数功能：   设置托管按钮状态
-- 返回值：     无
--[[
    参数： 
    tuoguanState:     游戏托管状态
]]
---------------------------------------
function DDZTWOPRoom:setTuoGuanBtnState(tuoguanState)
    self.btn_tuoguan:setTouchEnabled(tuoguanState)
end

---------------------------------------
-- 函数功能：    玩家重连成功
-- 返回值：      无
-- packetInfo:  封装重连成功消息内容
--[[
    参数:
    bo         斗地主底牌数据
    remainTimeOut    游戏正在操作时间倒计时
    wiT              游戏输赢类型（0游戏豆 1积分）
    dipaiDouble      底牌加倍倍数
    exD              附加数据
    fiPUID           开始玩家操作ID
    plI1             玩家数据列表
    {
        qi           玩家是否抢地主
        to           总场次
        plI          玩家头像Id
        heU          玩家头像连接
        ca0          玩家手牌数据
        isM          玩家是否是托管状态
        ca           玩家是否叫地主
        mi           玩家是否明牌
        wi           玩家胜场次数
        se           玩家性别
        plN          玩家名称
        cuD          玩家加倍倍数
        le           玩家获得称号
        fo           玩家拥有的财富
    }
]]
---------------------------------------
function DDZTWOPRoom:onRecvReconnect(packetInfo)
    Log.i("onRecvReconnect packetInfo", packetInfo)
    packetInfo = checktable(packetInfo);
    self.roomInfo = HallAPI.DataAPI:getRoomInfoById(HallAPI.DataAPI:getGameId(), HallAPI.DataAPI:getRoomId());
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BASEROOM, self.roomInfo.an);
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:hideStarting()
        self:showBase()
        self:showTuoguanBtn()
    end
    for i = 1, DDZTWOPConst.PLAYER_NUM  do
        self.m_seatViews[i]:updatePlayerInfo() 
        self.m_seatViews[i]:onTuoGuanChange()
    end
    if self.m_topBarView then
        self.m_topBarView:showBottomCard(true);
    end
    for k,v in pairs(self.m_seatViews) do
        v:setDouble()
    end
    if packetInfo.loI and packetInfo.loI > 0 then
        self:setRole( packetInfo.loI, 1);
    end
    self:dealCard(true);

    local gameState = DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    if packetInfo.jqstatus == DDZTWOPConst.RECONNECTSTATUS0 then
        self:showOpration(packetInfo.fiPUID,packetInfo,true)
    end
end

---------------------------------------
-- 函数功能：    展示玩家操作UI
-- 返回值：      无
--[[
    参数：
    playerId      玩家id
    info          操作信息
    isReconnect   是否是重新连接
]]
---------------------------------------
function DDZTWOPRoom:showOpration(playerId, info, isReconnect)
    local isExist = DataMgr:getInstance():isPlayerExist(playerId);
    if not isExist then
        return 
    end
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_OPERATESEATID, seat)
        self.m_oprationResultViews[seat]:hideOprationResult();
        self.m_oprationViews[seat]:hideOpration();
        self.m_oprationViews[seat]:showOpration(info,nil,isReconnect,self.m_handCardViews[DDZTWOPConst.SEAT_MINE]);
        self.m_handCardViews[seat]:showOpration(info);
    end
end

---------------------------------------
-- 函数功能：    检查座位是否合法
-- 返回值：      无
-- seat：        玩家座位
---------------------------------------
function DDZTWOPRoom:isLegalSeat(seat)
    if seat and seat >= 1 and seat <= DDZTWOPConst.PLAYER_NUM then
        return true;
    end
    return false;
end

---------------------------------------
-- 函数功能：    设置玩家头像
-- 返回值：      无
-- playerId:    操作玩家id
---------------------------------------
function DDZTWOPRoom:setRole()
    for k, v in pairs(self.m_seatViews) do
        v:setRole();
    end
end

---------------------------------------
-- 函数功能：    展示所有玩家操作UI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showAllOpration()
    for seat = 1, DDZTWOPConst.PLAYER_NUM do
        self.m_oprationResultViews[seat]:hideOprationResult();
        self.m_oprationViews[seat]:hideOpration();
        self.m_oprationViews[seat]:showOpration(nil,nil,nil,self.m_handCardViews[DDZTWOPConst.SEAT_MINE]);
    end
end

---------------------------------------
-- 函数功能：    展示玩家操作结果
-- 返回值：      无
--[[
    playerId       玩家id
    info           显示玩家操作结果信息
    isReconnect    是否是重新连接
    wiId           赢家的id
]]
---------------------------------------
function DDZTWOPRoom:showOprationResult(playerId, info, isReconnect,wiID,isTotalGameover)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    local state = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration();
        if state ~= DDZTWOPConst.STATUS_GAMEOVER or (not wiID and playerId ~= wiID) or (info.ca and #info.ca > 0) then
            self.m_oprationResultViews[seat]:hideOprationResult();
        end

        local gameStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
        local sex = DDZTWOPConst.MALE
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(playerId)
        if PlayerModel then
            sex = PlayerModel:getProp(DDZTWOPDefine.SEX)
        end
        if gameStatus == DDZTWOPConst.STATUS_CALL or (gameStatus == DDZTWOPConst.STATUS_ROB and isReconnect) then
            self.m_oprationResultViews[seat]:onCallLord(info.fl)
        elseif gameStatus == DDZTWOPConst.STATUS_ROB then        
            self.m_oprationResultViews[seat]:onRobLord(info.fl)
        elseif gameStatus == DDZTWOPConst.STATUS_PLAY then
            --删除玩家手牌
            PlayerModel:delCards(info.cards, true) 
            self.m_oprationResultViews[seat]:onPlayCard(info)
            if not info.cards then return end
            if info.fl == DDZTWOPConst.OUTCARDSTATUS0 then
            else
                self:showCardType(seat, info.cardType, #info.cards)   
            end
            self:showTipCount()
        elseif gameStatus == DDZTWOPConst.STATUS_GAMEOVER then
            self.m_oprationResultViews[seat]:onGameOver(info, playerId, sex)
            self.m_handCardViews[seat]:onGameOver(info, playerId, sex)
        end
        
    end
end

---------------------------------------
-- 函数功能：    展示牌型动画
-- 返回值：      无
--[[
    seat        玩家座位
    cardType    牌组类型
    cardLenght  牌组长度   多少张牌
]]
---------------------------------------
function DDZTWOPRoom:showCardType(seat, cardType, cardLenght)
    self.m_AnimView:showCardTypeAnim(seat, cardType, cardLenght);
end

---------------------------------------
-- 函数功能：    初始化话聊天内容
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:init_gameChatCfg()
    local sex = HallAPI.DataAPI:getUserSex();
    if sex == DDZTWOPConst.FEMALE then
        self.gameChatTxtCfg = csvConfig.maleChatList
    else
        self.gameChatTxtCfg = csvConfig.femaleChatList    
    end
end

---------------------------------------
-- 函数功能：    获取游戏聊天内容
-- 返回值：      无
--[[
    参数
    sex         玩家性别
    emjI        内置聊天数据标记
]]
---------------------------------------
function DDZTWOPRoom:getChatContent(sex, emjI)
    if sex == DDZTWOPConst.MALE then
        return csvConfig.maleChatList[emjI].content
    else
        return csvConfig.femaleChatList[emjI].content
    end
end

---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onRecvSayChat(packetInfo)
    Log.i("DDZTWOPRoom say chat packetInfo:",packetInfo)
    if packetInfo.ty == DDZTWOPConst.CHATTYPE.VOICECHAT then
        if packetInfo.co then
            local status = kSettingInfo:getPlayerVoiceStatus()
            if status and packetInfo.usI ~= HallAPI.DataAPI:getUserId() then
               Log.i("关闭玩家语音。。。。。。。。");
            else
                self:showSpeaking(packetInfo);
            end
        end
    elseif packetInfo.ty == DDZTWOPConst.CHATTYPE.CUSTOMCHAT then
        local seat = DataMgr:getInstance():getSeatByPlayerId(packetInfo.usI);
        if self:isLegalSeat(seat) then
            info = {}
            info.ty = DDZTWOPConst.CHATTYPE2
            info.content = packetInfo.co 
            self.m_seatViews[seat]:showCustomChat(info)
        end
    end
end


---------------------------------------
-- 函数功能：    语音聊天事件回调
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showSpeaking(packetInfo)
    Log.i("DDZTWOPRoom showSpeaking",packetInfo)
    if not YY_IS_LOGIN then
        return ;
     end
     Log.i("**************************** showSpeaking1",packetInfo)
     if self.m_speaking or self.m_isTouchBegan then
        Log.i("**************************** showSpeaking2",packetInfo)
         if #self.m_speakTable < 10 then
             table.insert(self.m_speakTable, packetInfo);
         end
     else
         --local playerInfos = kFriendRoomInfo:getRoomInfo();
         --Log.i("**************************** showSpeaking1",playerInfos)
         local playerInfos = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
         --Log.i("**************************** showSpeaking3",playerInfos)
         for k, v in pairs(playerInfos) do
             if v:getProp(DDZTWOPDefine.USERID) == packetInfo.usI then
                 if self.m_seatViews[v:getProp(DDZTWOPDefine.SITE)] then
                     self.m_speaking = true;
                     self.m_seatViews[v:getProp(DDZTWOPDefine.SITE)]:showSpeaking();
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
                     end, 60);
                 end
                 break;
             end
         end
     end
 
end

function DDZTWOPRoom:hideSpeaking(playerId)
    Log.i("DDZTWOPRoom:hideSpeaking", playerId)
    playerId = playerId or "0"
    local playerInfos = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k, v in pairs(playerInfos) do
    Log.i("DDZTWOPRoom:hideSpeaking1")

        if v:getProp(DDZTWOPDefine.USERID) == tonumber(playerId) then
    Log.i("DDZTWOPRoom:hideSpeaking2")

            if self.m_seatViews[v:getProp(DDZTWOPDefine.SITE)] then
    Log.i("DDZTWOPRoom:hideSpeaking3")

                self.m_seatViews[v:getProp(DDZTWOPDefine.SITE)]:hideSpeaking()
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
function DDZTWOPRoom:showNextSpeaking()
    if not self.m_speaking and #self.m_speakTable > 0 then
	    --Log.i("开始说下一条语音");

        self:showSpeaking(table.remove(self.m_speakTable, 1));
    end
end
---------------------------------------
-- 函数功能：    检测语音播放状态
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:getSpeakingStatus()
    if self.m_getSpeakingThread then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
    end
    self.m_getSpeakingThread = scheduler.scheduleGlobal(function()
        local data = {};
        data.cmd = NativeCall.CMD_YY_PLAY_FINISH;
        NativeCall.getInstance():callNative(data, self.onUpdateSpeakingStatus, self);
    end, 0.5);
end

function DDZTWOPRoom:onUpdateSpeakingStatus(info)
    Log.i("--------onUpdateSpeakingStatus", info.usI);
    if info.usI then
        scheduler.unscheduleGlobal(self.m_getSpeakingThread);
        self.m_getSpeakingThread = nil;
        self:hideSpeaking(info.usI);
    end
end

---------------------------------------
-- 函数功能：    重置玩家手牌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:resetHandCardView()
    for seat=1,DDZTWOPConst.PLAYER_NUM do
        if self.m_handCardViews[seat] then
            self.m_handCardViews[seat]:reset();
        end
    end
end

---------------------------------------
-- 函数功能：   设置基础倍数
-- 返回值：     无
---------------------------------------
function DDZTWOPRoom:setBaseNum()
    local baseNum =  DataMgr.getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_BASEROOM)
    self.bitmap_base:setString("底数:" .. baseNum);
end

---------------------------------------
-- 函数功能：   显示基础倍数
-- 返回值：     无
---------------------------------------
function DDZTWOPRoom:hideBase()
    self.img_base:setVisible(false)
end

---------------------------------------
-- 函数功能：   隐藏基础倍数
-- 返回值：     无
---------------------------------------
function DDZTWOPRoom:showBase()
    self.img_base:setVisible(true)
    self:setBaseNum()
end


---------------------------------------
-- 函数功能：    隐藏所有玩家操作结果UI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:hideAllOprationResult()
    for seat = 1, DDZTWOPConst.PLAYER_NUM do
        self.m_oprationResultViews[seat]:hideOprationResult();
    end
end

---------------------------------------
-- 函数功能：    隐藏玩家操作UI
-- 返回值：      无
-- playerId:    玩家Id
---------------------------------------
function DDZTWOPRoom:hideOpration(playerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:hideOpration();
    end
end

---------------------------------------
-- 函数功能：    隐藏所有玩家操作UI
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:hideAllOpration()
    for seat = 1, DDZTWOPConst.PLAYER_NUM do
        self.m_oprationViews[seat]:hideOpration();
    end
end

---------------------------------------
-- 函数功能：   更新玩家操作UI
-- 返回值：      无
--[[
    参数：
    playerId    玩家id
    info        更新玩家信息封装
]]
---------------------------------------
function DDZTWOPRoom:updateOpration(playerId, info)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId);
    if self:isLegalSeat(seat) then
        self.m_oprationViews[seat]:updateOpration(info, self.m_handCardViews[DDZTWOPConst.SEAT_MINE]);
        self.m_handCardViews[seat]:updateOpration(info);
    end
end

---------------------------------------
-- 函数功能：   续局处理
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:reqContinueGame()
    self:playBgMusic()
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:showStarting()
        if DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) > DDZTWOPConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) == DDZTWOPConst.STATUS_GAMEOVER then
            self:clearDesk()
        end
    else
        self:clearDesk()
        self:updateRoomJushuInfo()
        --self.m_seatViews[DDZTWOPConst.SEAT_MINE]:showReady()
    end
    PokerUIManager.getInstance():popToWnd(DDZTWOPRoom)
end

---------------------------------------
-- 函数功能：   确定地主后处理底牌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:onBottomCardsDispensed()
    local info = {}
    info.isMustOut = true
    info.isMeLord = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) == HallAPI.DataAPI:getUserId()
    if info.isMeLord then
        self:showAllOpration(info);    
    end
    self:addBottomCard(DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID))
end

---------------------------------------
-- 函数功能：    增加游戏底牌到手牌中
-- 返回值：      无
-- playerId:     玩家id
---------------------------------------
function DDZTWOPRoom:addBottomCard(playerId)
    local seat = DataMgr:getInstance():getSeatByPlayerId(playerId)
    if self:isLegalSeat(seat) then
        self.m_handCardViews[seat]:addBottomCard();
        --self:showTipCount();
    end
end

---------------------------------------
-- 函数功能：   让牌提示和设置让的牌的状态
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showTipCount()
    self.m_handCardViews[DDZTWOPConst.SEAT_MINE]:showTipCount();
    self.m_handCardViews[DDZTWOPConst.SEAT_RIGHT]:setRangCardsStatus();
end

---------------------------------------
-- 函数功能：   让牌显示
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:showRangCards()
    self.m_handCardViews[DDZTWOPConst.SEAT_RIGHT]:setRangCardsStatus();
end

---------------------------------------
-- 函数功能：   重置对手的牌为背景牌
-- 返回值：      无
---------------------------------------
function DDZTWOPRoom:resetCardsAsBg()
    self.m_handCardViews[DDZTWOPConst.SEAT_RIGHT]:resetCardsStatus();
end


---------------------------------------
-- 函数功能：  在需要显示操作面板是调用
-- 返回值： 无
---------------------------------------
function DDZTWOPRoom:onRecvShowopration()
    local firstID = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_OPERATESEATID)
    self:showOpration(firstID)
end

---------------------------------------
-- 函数功能：  显示托管按钮
-- 返回值： 无
---------------------------------------
function DDZTWOPRoom:showTuoguanBtn()
    self.btn_tuoguan:setVisible(true)
end

---------------------------------------
-- 函数功能：  隐藏托管按钮
-- 返回值： 无
---------------------------------------
function DDZTWOPRoom:hideTuoguanBtn()
    self.btn_tuoguan:setVisible(false)
end


----------------------------------------------
-- @desc 被踢下线 
-- @pram packetInfo :网络消息  暂时不用
----------------------------------------------
function DDZTWOPRoom:onRecvBrocast(packetInfo)
    Log.i("DDZTWOPRoom:onRecvBrocast packetInfo")
    if packetInfo.ti == DDZTWOPConst.MULTILOGIN then
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
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data);
    elseif packetInfo.ti == DDZTWOPConst.CLOSESERVER then -- 关服通知
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data);
    end
end


return DDZTWOPRoom