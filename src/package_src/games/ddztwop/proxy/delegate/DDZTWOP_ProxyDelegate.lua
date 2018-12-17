-------------------------------------------------------------------------
-- Desc:   二人斗地主扑克牌框架网络代理 继承自扑克公用网络代理ProxyDelegate
-- Last:
-- Author:   faker
-- Content:  因为底层代码原因，这里网络部分消息分发通过代理全部处理
-- 劫持注册的模块消息，抽离数据，只给到逻辑层。达到数据UI逻辑解耦合
-- 2017-11-04  新建
-- 2017-11-07  修改 区分队列消息和普通直传消息
-------------------------------------------------------------------------
local ProxyDelegate = require("package_src.games.pokercommon.network.ProxyDelegate")
local Facade = require("package_src.games.pokercommon.control.Facade")
local PokerCoreConst = require("package_src.games.pokercommon.data.PokerConst")
local DDZTWOPGameEvent = require("package_src.games.ddztwop.data.DDZTWOPGameEvent")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local PokerRoomDialogView = require("package_src.games.pokercommon.widget.PokerRoomDialogView")
local PlayerModel = require("package_src.games.pokercommon.model.PlayerModel")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPCardTypeAnalyzer = require("package_src.games.pokercommon.utils.card.DDZPKCardTypeAnalyzer")
local PokerUtils =require("package_src.games.pokercommon.commontool.PokerUtils")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local DDZTWOP_ProxyDelegate = class("DDZTWOP_ProxyDelegate", ProxyDelegate)

-----------------------------------------
-- 函数功能：    构造
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:ctor()
    --Log.debug("DDZTWOP_ProxyDelegate:ctor")
    DDZTWOP_ProxyDelegate.super.ctor(self,DDZTWOPSocketCmd.msgsBindRecv,DDZTWOPSocketCmd.msgsCommonBindRecv)
    self.m_listeners = {}
    self:registMsgs()
end

-----------------------------------------
-- 函数功能：    析构函数
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:dtor()
    for k,v in pairs(self.m_listeners) do
        HallAPI.EventAPI:removeEvent(v)
    end

    self.super.dtor(self)
end

-----------------------------------------
-- 函数功能：    注册事件消息 如请求续局、退出房间  注意：所有注册的事件消息在退出游戏时必须清除
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        table.insert(self.m_listeners, nhandle)
    end
    addEvent(DDZTWOPGameEvent.REQCHANGEDESK)
    addEvent(DDZTWOPGameEvent.REQEXITROOM)
    addEvent(DDZTWOPGameEvent.REQSENDDEFCHAT)
    addEvent(DDZTWOPGameEvent.REQTUOGUAN)
        
    addEvent(PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT)
    addEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_TUOGUAN)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE)
    
    --addEvent(HallAPI.EventAPI.GAME_SOCKET_CLOSE)
    --addEvent(HallAPI.EventAPI.GAME_ON_NETWORK_CONNECT_FAIL)
    addEvent(HallAPI.EventAPI.START_GAME_COMPLETE)
    addEvent(HallAPI.EventAPI.EXIT_GAME)
    addEvent(HallAPI.EventAPI.RESUME_GAME_REQUEST)
end

-----------------------------------------
-- 函数功能：    监听事件消息
-- 返回值：      无
-- id:   事件id
-----------------------------------------
function DDZTWOP_ProxyDelegate:ListenToEvent(id, ... )
    --Log.i("DDZTWOP_ProxyDelegate:ListenToEvent id", id)
    if id == DDZTWOPGameEvent.REQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == DDZTWOPGameEvent.REQEXITROOM or id == PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT then
        self:requestExitRoom()
    elseif id == DDZTWOPGameEvent.REQSENDDEFCHAT or id == PokerEventDef.GameEvent.REQSENDDEFCHAT then
        self:sendDefaultChat(...)
    elseif id == DDZTWOPGameEvent.REQTUOGUAN or id == PokerEventDef.GameEvent.GAME_REQ_TUOGUAN then
        self:requestTuoguan(...)
    -- elseif id == HallAPI.EventAPI.GAME_SOCKET_CLOSE then
    --     self:onNetWorkClosed()
    -- elseif id == HallAPI.EventAPI.GAME_ON_NETWORK_CONNECT_FAIL then
    --     self:onNetWorkConnectFail()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT then
        self:requestExitRoom()     
    elseif id ==PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE then
        self:reqContinueGame(...)
    elseif id == HallAPI.EventAPI.START_GAME_COMPLETE then
        self:onStartGameComplete()
    elseif id == HallAPI.EventAPI.EXIT_GAME then
        self:requestExitRoom() 
    elseif id == HallAPI.EventAPI.RESUME_GAME_REQUEST then
        self:onNetWorkReconnected()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT then
        self:sendSayMsg(...)
    end
end

-----------------------------------------
-- 函数功能：    解析服务器消息
-- 返回值：      无
-- eventdata:   封装过的消息体
-----------------------------------------
function DDZTWOP_ProxyDelegate:ReadServerStructInfor(eventdata)
    --游戏开始
    if eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_GAMESTART then
        Log.i("DDZTWOP_ProxyDelegate:ReadServerStructInfor CODE_REC_GAMESTART",POKERCONST_EVENT_NETDISPATCH)
        self:onGameStart(eventdata.packetInfo)
    -- 叫地主
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_CALLLORD then
        self:onRecvCallLord(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    -- 抢地主
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_ROBLORD then
        self:onRecvCallRob(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    -- 开始打牌
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_STARTPLAY then
        self:onRecvStartPlay(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    -- 出牌
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_OUTCARD then
        self:onRecvOutCard(eventdata.packetInfo)
    -- 游戏结束
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_GAMEOVER then
        self:onRecvGameOver(eventdata.packetInfo, self.m_playerInfos)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    -- 退出房间
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_ExitRoom then
        self:onRecvExitRoom()
   --重连
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_RECONNECT then
        self:onRecvReconnect(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
    --踢人
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_BROCAST then
        self:onRecvBrocast(eventdata.packetInfo)
    --托管
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_TUOGUAN then
        self:onRecvTuoGuan(eventdata.packetInfo)
    --内置聊天
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_DEFAULT_CHAT then
        self:onRecvDefaultChat(eventdata.packetInfo)

    --房间信息
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_RECV_FRIEND_ROOM_INFO then
        self:onRecvFriendRoomInfo(eventdata.packetInfo)

    --更新钻石
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_UPDATE_CASH then
        self:onUserMoneyUpdate(eventdata.packetInfo)
    --进入房间
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_ENTERROOM then
        self:enterRoom(eventdata.packetInfo)
    --消息提示
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_POKERDIALOG then
        self:onRecvDialog(eventdata.packetInfo)
    --自定义聊天
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_SAY_CHAT then
        self:onRecvSayChat(eventdata.packetInfo)
    --总结算
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_TOTAL_GAME_OVER then
        self:onRecvTotalGameOver(eventdata.packetInfo)
    --朋友房继续游戏
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_REC_CONTINUE then
        self:onRecvFriendContinue(eventdata.packetInfo)
    --请求解散房间
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_FRIEND_ROOM_LEAVE then
        self:onRecvReqDismiss(eventdata.packetInfo)
    --解散房间结果
    elseif eventdata.cmd == DDZTWOPSocketCmd.CODE_RECV_FRIEND_ROOM_END then
        self:onRecvDismissRes(eventdata.packetInfo)
    end
end

-----------------------------------------
-- 函数功能：    游戏开始
-- 返回值：      无
-- packetInfo:  封装过的消息内容
--[[
    参数：
    st           牌局状态
    gaI          游戏id
    fiPUID       开始玩家id
    deT          桌子类型
    plI1         玩家数据列表
    {
        fo          玩家财富
        to          总场次
        se          性别
        le          等级
        ca0         手牌数据
        heU         玩家头像
        mi          玩家是否明牌
        plN         玩家名称
        wi          胜场
        qi          玩家是否抢地主
        ca          玩家是否叫地主
        plI         玩家ID
    }
    plTO         单手牌超时时间（单位：秒）
    prPI         上一首牌玩家ID
    wiT          输赢类型（0：游戏豆  1：积分）
    dipaiDouble  底牌翻倍倍数
    gaPI         对局房间ID
    loI          地主ID
    la     laizi  赖子: 有效值1-13,依次表示345678910JQKA2,欢乐时为-1
]]
-----------------------------------------
function DDZTWOP_ProxyDelegate:onGameStart(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate:onGameStart", packetInfo)
   self:setAllPlayerHandCards(packetInfo.plI1)
    if packetInfo.bo then
        for k, v in pairs(packetInfo.bo) do
            if v ~= DDZTWOPCard.DEBUGCARD then
                packetInfo.bo[k] = DDZTWOPCard.ConvertToLocal(v)
            end
        end
    end
    for k, v in pairs(packetInfo.plI1) do
        if v.ca0 then
            for k1, v1 in pairs(v.ca0) do
                if v1 ~= DDZTWOPCard.DEBUGCARD then
                    v.ca0[k1] = DDZTWOPCard.ConvertToLocal(v1)
                end
            end
        end
    end


    packetInfo = checktable(packetInfo)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMEID, packetInfo.gaI)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.loI)
   -- DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LIMITTIME, packetInfo.plTO)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LIMITTIME, DDZTWOPConst.OPRATIONTIME)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BOTTOMCADS, packetInfo.bo)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE, packetInfo.inD)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, packetInfo.st)

    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTOUTCARDS, {})
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTYPE, DDZTWOPCard.CT_ERROR)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTIPS, {})
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTKEYCARDS, nil)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_DEBUGSTATE, packetInfo.debug)
    --DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_DEBUGSTATE, false)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_ISCERTAINLORD,false)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTART,true)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_MINGPAICARD,packetInfo.mingCardId)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_MINGPAIIDX,packetInfo.mingCardIdx)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTOUTSEAT,0)

    local bujiaoNum = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_BUJIAONUM)
    if bujiaoNum and bujiaoNum == DDZTWOPConst.PLAYER_NUM then
        HallAPI.ViewAPI:showToast(DDZTWOPConst.NOCALLLORDTIPS)
    end
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BUJIAONUM, 0)
    self:initPlayer(packetInfo.plI1)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONGAMESTART, packetInfo.plI1, packetInfo.fiPUID)
end

-----------------------------------------
-- 函数功能：    提示信息
-- 返回值：      无
--packetInfo    封装提示信息内容
--[[
    text        提示内容
    playerId    玩家id
    type        提示信息类型
]]
function DDZTWOP_ProxyDelegate:onRecvDialog(packetInfo)
    HallAPI.ViewAPI:showToast(packetInfo.text)
end

-----------------------------------------
-- 函数功能：    进入房间
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:enterRoom(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate enterRoom:",packetInfo)
    
    local roomInfo =  HallAPI.DataAPI:getRoomInfoById(packetInfo.gaI, packetInfo.roI);
    if roomInfo then
        --重新设置房间类型
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_ROOMID, packetInfo.roI)
        --重新设置房间底数
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BASEROOM, roomInfo.an)
    end
     
end

-----------------------------------------
-- 函数功能：    检查座位是否合法
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:isLegalSeat(seat)
    if seat and seat >= DDZTWOPConst.SEAT_MINE and seat <= DDZTWOPConst.PLAYER_NUM then
        return true
    end
    return false
end

-----------------------------------------
-- 函数功能：    By玩家ID获取玩家座位
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:getSeatByPlayerId(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZTWOPDefine.USERID) == playerId then
            return v:getProp(DDZTWOPDefine.SITE)
        end
    end
end

-----------------------------------------
-- 函数功能：    初始化游戏玩家数据
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:initPlayer(playerInfos)
    local playerList = {}
    for k, v in pairs(playerInfos) do
        local seat
        if v.plI == HallAPI.DataAPI:getUserId() then
            seat = DDZTWOPConst.SEAT_MINE
        else
            seat = DDZTWOPConst.SEAT_RIGHT
        end

        local PlayerModel = PlayerModel:new()
        PlayerModel:setProp(DDZTWOPDefine.USERID, v.plI)
        PlayerModel:setProp(DDZTWOPDefine.NAME, v.plN)
        PlayerModel:setProp(DDZTWOPDefine.SEX, v.se == DDZTWOPConst.FEMALE and DDZTWOPConst.MALE or DDZTWOPConst.FEMALE)
        PlayerModel:setProp(DDZTWOPDefine.MONEY, v.fo)
        PlayerModel:setProp(DDZTWOPDefine.ICON_ID, v.heU)
        PlayerModel:setProp(DDZTWOPDefine.CARD_NUM, #v.ca0)
        PlayerModel:setProp(DDZTWOPDefine.SITE, seat)
        PlayerModel:setProp(DDZTWOPDefine.LEVEL, v.le)
        PlayerModel:setProp(DDZTWOPDefine.ISTUOGUAN,DDZTWOPConst.TUOGUAN_STATE_0)
        PlayerModel:setProp(DDZTWOPDefine.HAND_CARDS, v.ca0)
        PlayerModel:setProp(DDZTWOPDefine.JING_DU,v.jiD)
        PlayerModel:setProp(DDZTWOPDefine.WEI_DU,v.weD)
        PlayerModel:setProp(DDZTWOPDefine.IP,v.ipA)
        table.insert(playerList, PlayerModel)
    end
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_PLAYERLIST, playerList)
end

-----------------------------------------
-- 函数功能：   得到所有玩家牌集合
-- 返回值：     所有玩家手牌集合
--[[
    playerList       服务器返回玩家信息列表
]]
-----------------------------------------
function DDZTWOP_ProxyDelegate:setAllPlayerHandCards(playerList)
    local handCards = {}
    for k,info in pairs(playerList) do
        for i,v in ipairs(info.ca0) do
            if v then
                table.insert(handCards,v)
            end
        end
    end
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_ALLHANDCARDS,handCards)
end

-----------------------------------------
-- 函数功能：    叫地主
-- 返回值：      无
-- packetInfo:  封装过的消息内容
--[[
    参数：
    uiI             玩家ID
    rangPaiCount    让牌数量
    fl              是否叫地主（0：不叫  1：叫地主）
    fl0             是否确定地主（0：继续叫地主  1：确定地主）
    neP             nextPlayer  fl0 =0,为下一个叫牌玩家ID；fl0 = 1,为下一个抢地主或者是出牌玩家ID
    gaPI            对局房间id
]]
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvCallLord(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate:onRecvCallLord", packetInfo)
    if packetInfo.ca then
        for k, v in pairs(packetInfo.ca) do
            if v ~= DDZTWOPCard.DEBUGCARD then
                packetInfo.ca[k] = DDZTWOPCard.ConvertToLocal(v)
            end
        end
    end

    --叫地主
    if packetInfo.fl == DDZTWOPConst.CALLLORDSTATUS1 then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.usI)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_ROB)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE , packetInfo.mu)
    else
        local bujiao = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_BUJIAONUM)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BUJIAONUM, bujiao + 1)
    end

    if packetInfo.rangPaiCount then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_RANGPAICOUNT,packetInfo.rangPaiCount)
    end
    --已确定地主
    if packetInfo.fl0 == DDZTWOPConst.CALLLORDSTATUS1 then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_ISCERTAINLORD,true)
        local lordId = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_PLAY)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BOTTOMCADS, packetInfo.ca)        
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(lordId)
        PlayerModel:addCards(packetInfo.ca)
    end

    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONCALLLORD, packetInfo)
end

function DDZTWOP_ProxyDelegate:getPlayerInfo(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZTWOPDefine.USERID) == playerId then
            return v
        end
    end
end

-----------------------------------------
-- 函数功能：    抢地主
-- 返回值：      无
-- packetInfo:  封装过的消息内容
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvCallRob(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate:onRecvCallRob",packetInfo)
    packetInfo = checktable(packetInfo)
    if packetInfo.ca then
        for k, v in pairs(packetInfo.ca) do
            if v ~= -1 then
                packetInfo.ca[k] = DDZTWOPCard.ConvertToLocal(v)
            end
        end
    end

    if packetInfo.rangPaiCount then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_RANGPAICOUNT,packetInfo.rangPaiCount)
    end
    if packetInfo.fl == DDZTWOPConst.ROBLORDSTATUS1 then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE , packetInfo.cuD)

        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.usI)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_ROB)
    elseif packetInfo.fl == DDZTWOPConst.ROBLORDSTATUS0 then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.neP)
    end
    if packetInfo.fl0 == DDZTWOPConst.ROBLORDSTATUS1 then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_ISCERTAINLORD,true)
        local lordId = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_LORDID)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_PLAY)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BOTTOMCADS, packetInfo.ca)
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(lordId)
        PlayerModel:addCards(packetInfo.ca)
    end

    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONROBLORD, packetInfo) 
end

-----------------------------------------
-- 函数功能：    开始打牌
-- 返回值：      无
-- packetInfo:  封装过开始打牌消息内容
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvStartPlay(packetInfo)
    Log.i("onRecvStartPlay",packetInfo)
    packetInfo = checktable(packetInfo)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_PLAY)
    if packetInfo.rangPaiCount then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_RANGPAICOUNT,packetInfo.rangPaiCount)
    end

    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONSTRATPLAY, packetInfo)  
end

-----------------------------------------
-- 函数功能：出牌
-- 返回值：  无
-- packetInfo:  封装出牌的消息内容
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvOutCard(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate onRecvOutCard",packetInfo)
    packetInfo = checktable(packetInfo)

    if packetInfo.plC then
        for k, v in pairs(packetInfo.plC) do
            packetInfo.plC[k] = DDZTWOPCard.ConvertToLocal(v)
        end
    end

    local cards = packetInfo.plC or {}
    local cardValues = {}
    for k, v in pairs(cards) do
        local type, val = DDZTWOPCard.cardConvert(v)
        table.insert(cardValues, val)
    end

    local cardType, keyCard = DDZTWOPCardTypeAnalyzer.getCardType(cardValues)
    if cardType >= DDZTWOPCard.CT_BOMB then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE , packetInfo.cuD)
    end

    if packetInfo.usI == HallAPI.DataAPI:getUserId() then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTOUTCARDS, {})
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTYPE, DDZTWOPCard.CT_ERROR)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTIPS, {})
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTKEYCARDS, nil)
    else
        if cardType ~= DDZTWOPCard.CT_ERROR then
            DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTOUTCARDS, cards)
            DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTCARDTYPE, cardType)
            DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LASTKEYCARDS, keyCard)
        end
    end

    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONOUTCARD, packetInfo,packetInfo.isReconnect)  
end

-----------------------------------------
-- 函数功能：    游戏结束
-- 返回值：      无
-- packetInfo:  封装游戏结束的消息内容
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvGameOver(packetInfo)
    Log.i("onRecvGameOver packetInfo",packetInfo)
    packetInfo = checktable(packetInfo)
    for k, v in pairs(packetInfo.plI1) do
        if v.ca then
            for k1, v1 in pairs(v.ca) do
                if v1 ~= DDZTWOPCard.DEBUGCARD then
                    v.ca[k1] = DDZTWOPCard.ConvertToLocal(v1)
                end
            end
        end
    end
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_GAMEOVER)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_TUOGUANSTATE,{})
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTART,false)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_ALLHANDCARDS,{})

    HallAPI.DataAPI:setGameEnd(packetInfo.over)
    for k, v in pairs(packetInfo.plI1) do
       local PlayerModel = DataMgr:getInstance():getPlayerInfo(v.plI)
       local seat = PlayerModel:getProp(DDZTWOPDefine.SITE)
       PlayerModel:setProp(DDZTWOPDefine.MONEY, v.fo, true, seat)
    end

    if packetInfo.sp == DDZTWOPConst.SPRINGSTATUS2 then
        local multi = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MUTIPLE)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE , multi * DDZTWOPConst.GAMEDOUBLE)
    elseif packetInfo.anS == DDZTWOPConst.SPRINGSTATUS2 then
        local multi = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MUTIPLE)
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE , multi * DDZTWOPConst.GAMEDOUBLE)
    end
 
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.GAMEOVER, packetInfo) 
end

function DDZTWOP_ProxyDelegate:onRecvTotalGameOver(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate onRecvTotalGameOver:",packetInfo)
    packetInfo = checktable(packetInfo)

    HallAPI.DataAPI:setGameEnd(true) --需要添加API
    --缓存总结算消息
    local tmpData = {}
    tmpData.param = packetInfo
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_FRIENDTOTALDATA, tmpData)
end

-----------------------------------------
-- 函数功能：    托管
-- 返回值：      无
-- packetInfo:  封装托管的消息内容
--[[
    参数：
    maPI            托管玩家ID
    isM             是否托管（0：不托管  1：托管）
    serializeType   序列化类型
]]
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvTuoGuan(packetInfo)
    Log.i("onRecvTuoGuan packetInfo", packetInfo)
    local tuoguanStates = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    if not tuoguanStates then tuoguanStates = {} end
    tuoguanStates[packetInfo.maPI] = packetInfo.isM
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_TUOGUANSTATE,tuoguanStates)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONTUOGUAN, packetInfo)
end

-----------------------------------------
-- 函数功能：    重连
-- 返回值：      无
-- packetInfo:  封装重连的消息内容
--[[
    参数:
    bo         斗地主底牌数据
    remainTimeOut    游戏正在操作时间倒计时
    wiT              游戏输赢类型（0游戏豆 1积分）
    dipaiDouble      底牌加倍倍数
    exD              附加数据
    fiPUID           开始玩家操作ID
    jqstate          玩家当前操作状态 1叫2不叫3抢4不抢
    plI1             玩家数据列表
    {
        qi           玩家是否抢地主
        to           总场次
        plI          玩家Id
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvReconnect(packetInfo)
    Log.i("onRecvReconnect packetInfo000000", packetInfo)
    DataMgr:getInstance():init()
    packetInfo = checktable(packetInfo)
    if packetInfo.bo then
        for k, v in pairs(packetInfo.bo) do
            if v ~= DDZTWOPCard.DEBUGCARD then
                packetInfo.bo[k] = DDZTWOPCard.ConvertToLocal(v)
            end
        end
    end
    
    for k, v in pairs(packetInfo.plI1) do
        if v.ca0 then
            for k1, v1 in pairs(v.ca0) do
                if v1 ~= DDZTWOPCard.DEBUGCARD then
                    v.ca0[k1] = DDZTWOPCard.ConvertToLocal(v1)
                end
            end
        end
        local tuoguanStates = DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
        if not tuoguanStates then tuoguanStates = {} end
        tuoguanStates[v.plI] = v.isM
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_TUOGUANSTATE,tuoguanStates)
    end

    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMEID, packetInfo.gaI)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.loI)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LIMITTIME, DDZTWOPConst.OPRATIONTIME)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BOTTOMCADS, packetInfo.bo)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_MUTIPLE, packetInfo.inD)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, packetInfo.st)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_RECONNECTTIME,DDZTWOPConst.OPRATIONTIME)
    DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTART,packetInfo.st > DDZTWOPConst.STATUS_NONE and packetInfo.st < DDZTWOPConst.STATUS_GAMEOVER)
    DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_DEBUGSTATE, packetInfo.debug)

    if packetInfo.rangPaiCount then
        DataMgr.getInstance():setObject(DDZTWOPConst.DataMgrKey_RANGPAICOUNT,packetInfo.rangPaiCount)
    end
    self:initPlayer(packetInfo.plI1)
    if packetInfo.loI and packetInfo.loI > 0 then
        DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_LORDID, packetInfo.loI)
    end

    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONRECONNECT, packetInfo)
    if packetInfo.jqstatus == DDZTWOPConst.RECONNECTSTATUS0 then return end
    
    --恢复对局打牌
    local info = {}
    info.usI = packetInfo.prPI
    info.neP = packetInfo.fiPUID
    info.isReconnect = true
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    local jqstatus = self:getPlayerStatus(packetInfo.plI1,packetInfo.prPI)
    if gameStatus == DDZTWOPConst.STATUS_PLAY then
        info.fl = DDZTWOPConst.OUTCARDSTATUS0
        if packetInfo.prC and #packetInfo.prC > 0 then
            info.fl = DDZTWOPConst.OUTCARDSTATUS1
        end
        info.firstOutCard = packetInfo.firstOutCard
        info.optSuc = DDZTWOPConst.SERVEROUTCARDSTATUS2
        info.plC = packetInfo.prC
        self:onRecvOutCard(info, true)
    elseif gameStatus == DDZTWOPConst.STATUS_CALL or jqstatus == DDZTWOPConst.RECONNECTSTATUS1 or jqstatus == DDZTWOPConst.RECONNECTSTATUS2 then
        local info = {}
        info.rangPaiCount = packetInfo.rangPaiCount
        info.usI = packetInfo.prPI
        info.neP = packetInfo.fiPUID
        info.mu = packetInfo.inD
        info.fl = (jqstatus == DDZTWOPConst.RECONNECTSTATUS1 and DDZTWOPConst.CALLLORDSTATUS1) or (jqstatus == DDZTWOPConst.RECONNECTSTATUS2 and DDZTWOPConst.CALLLORDSTATUS0)
        self:onRecvCallLord(info)
    elseif gameStatus == DDZTWOPConst.STATUS_ROB or jqstatus == DDZTWOPConst.RECONNECTSTATUS3 or jqstatus == DDZTWOPConst.RECONNECTSTATUS4 then
        local info = {}
        info.rangPaiCount = packetInfo.rangPaiCount
        info.usI = packetInfo.prPI
        info.neP = packetInfo.fiPUID
        info.mu = packetInfo.inD
        info.fl = (jqstatus == DDZTWOPConst.RECONNECTSTATUS3 and DDZTWOPConst.ROBLORDSTATUS1) or (jqstatus == DDZTWOPConst.RECONNECTSTATUS4 and DDZTWOPConst.ROBLORDSTATUS0)
        self:onRecvCallRob(info)
    end
end
-----------------------------------------
-- 函数功能：    返回玩家当前的操作状态
-- 返回值：      玩家当前操作状态
-----------------------------------------
function DDZTWOP_ProxyDelegate:getPlayerStatus(players,usrId)
    for k, v in pairs(players) do
        Log.i("*****************************************************getPlayerStatus",v.plI)
        if v.plI == usrId then
            return v.jqstatus
        end
    end
end


-----------------------------------------
-- 函数功能：    退出房间
-- 返回值：      无
-- packetInfo:  封装退出房间的消息内容
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvExitRoom(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONEXITROOM, packetInfo)
end

-----------------------------------------
-- 函数功能：    更新玩家钻石数据
-- 返回值：      无
-- packetInfo:  封装更新玩家钻石消息内容
-----------------------------------------
function DDZTWOP_ProxyDelegate:onUserMoneyUpdate(packetInfo)
    local userId = packetInfo.usI
    local money = packetInfo.ca
    local PlayerModel = DataMgr:getInstance():getPlayerInfo(userId)
    if PlayerModel then
        local seat = PlayerModel:getProp(DDZTWOPDefine.SITE)
        PlayerModel:setProp(DDZTWOPDefine.MONEY, money, true, seat)
    end
end

function DDZTWOP_ProxyDelegate:onRecvBrocast(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.RECVBROCAST, packetInfo)
end

-----------------------------------------
-- 函数功能：    语音聊天
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvSayChat(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate onRecvSayChat:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.RESAYCHAT,packetInfo)
end

-----------------------------------------
-- 函数功能：    朋友房续局
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvFriendContinue(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate onRecvFriendContinue:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.FRIENDCONTINUE,packetInfo)
end

-----------------------------------------
-- 函数功能：    请求解散朋友房
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvReqDismiss(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONRECVREQDISSMISS, packetInfo)
end

-----------------------------------------
-- 函数功能：    解散朋友房结果
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvDismissRes(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONRECVDISSMISSEND, packetInfo)
end

-----------------------------------------
-- 函数功能：    网络重连成功
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onNetWorkReconnected()
    Log.i("------Classical:onNetWorkReconnected");
    self.super:onNetWorkReconnected()
    scheduler.performWithDelayGlobal(function()
        -- LoadingView.getInstance():hide();
        local data = {};
        data.plI = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
        --HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_RESUMEGAME, data);
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_RESUME_GAME,data.plI)
    end, 1);
    
end

-----------------------------------------
-- 函数功能：    网络关闭处理
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onNetWorkClosed(...)
    self.super:onNetWorkClosed(...)
end

-----------------------------------------
-- 函数功能：    网络联通失败
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:onNetWorkConnectFail()
    self.super:onNetWorkConnectFail()
end

-- -----------------------------------------
-- -- 函数功能：    续局结果处理
-- -- 返回值：      无
-- -- packetInfo:  封装续局结果处理消息内容
-- -----------------------------------------
-- function DDZTWOP_ProxyDelegate:repGameStart(packetInfo)
--     --Log.i("Classical:repGameStart", packetInfo)
--     local desc = nil
--     if (packetInfo.ty == 1 or packetInfo.ty == 2) then
--         if packetInfo.re == 1 then
--             DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_GAMESTATUS, DDZTWOPConst.STATUS_NONE)
--             -- DDZGameManager.getInstance():setStatus(DDZTWOPConst.STATUS_NONE)
--             PokerUIManager.getInstance():popToWnd(DDZRoom)
--             self:clearDesk()
--         elseif packetInfo.re == 3 then
--             desc = "您的钻石太多了，请选择其他房间进行游戏！"
--         elseif packetInfo.re == 4 then
--             desc = "您的钻石不足，请选择其他房间进行游戏！"
--         end
--         if desc then
--             local data = {}
--             data.type = 1
--             data.title = "提示"
--             data.content = desc
--             data.closeTitle = "退出游戏"
--             data.closeCallback = function ( ... )
--                 self:requestExitRoom()
--             end
--             data.canKeyBack = false
--             PokerUIManager.getInstance():pushWnd(CommonDialog, data)
--         end
--     end
-- end

-- -----------------------------------------
-- -- 函数功能：    恢复对局
-- -- 返回值：      无
-- -- packetInfo:  封装恢复对局消息内容
-- -----------------------------------------
-- function DDZTWOP_ProxyDelegate:repResumeGame(packetInfo)
--     --Log.i("Classical:repResumeGame", packetInfo)
--     if packetInfo.re == 1 then
--         HallAPI.ViewAPI:showToast("重连成功")
--     else
--         self:onExitRoom()
--         HallAPI.ViewAPI:showToast("对局已结束")
--     end
-- end

-----------------------------------------
-- 函数功能：    请求换桌
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:reqChangeDesk()
    --请求换桌,交由大厅统一处理
    HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,2);
end

-- -----------------------------------------
-- -- 函数功能：    检查玩家进入房间钻石上下线
-- -- 返回值：      无
-- -----------------------------------------
-- function DDZTWOP_ProxyDelegate:checkRoomLimit()
--     local desc = nil
--     local gameid=  DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEID)
--     local roomInfo = HallAPI.DataAPI:getRoomInfo()

--     if HallAPI.DataAPI:getMoney() >= roomInfo.thM then
--         if (roomInfo.thM0 == -1 or HallAPI.DataAPI:getMoney() <= roomInfo.thM0) then
--             return true
--         else   
--             local tmpRoomInfo = HallAPI.DataAPI:getFastRoomInfo(gameid)
--             Log.i("***********************************************tmpRoomInfo",tmpRoomInfo)
--             if tmpRoomInfo then
--                 local data = {}
--                 data.type = 2
--                 data.title = "提示"                        
--                 data.yesTitle  = "去" 
--                 data.cancelTitle = "不去"
--                 data.content = "您的钻石已超过本房间最高要求，将进入" .. tmpRoomInfo.na .. "游戏"
--                 data.yesCallback = function()
--                     --重新设置房间类型
--                     DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_ROOMID, tmpRoomInfo.id)
--                     --重新设置房间底数
--                     DataMgr:getInstance():setObject(DDZTWOPConst.DataMgrKey_BASEROOM, tmpRoomInfo.an)
--                     HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.REQCONTINUE)
--                 end
--                 data.cancelCallback = function()
--                     self:requestExitRoom()
--                 end
--                 PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
--             end
--         end
--     else
--         local gameid = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEID)
--         local roomid = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_ROOMID)
--         -- local chargeItem = GameManager.getInstance():getChargeItem(roomInfo.thM)
--         -- if chargeItem then
--         --     kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_BREAK, gameid, roomid)
--         --     chargeItem.notChargeExit = true
--         --     local roomChargeView = PokerUIManager.getInstance():pushWnd(RoomChargeView, chargeItem, true)
--         --     roomChargeView:setDelegate(self)
--         -- else
--         --     self:requestExitRoom()
--         -- end
--     end
-- end

-----------------------------------------
-- 函数功能：    请求续局
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:reqContinueGame(ctype)
    --请求续局,交由大厅统一处理
    local data = {};
    data.gaI = HallAPI.DataAPI:getGameId()
    data.roI = HallAPI.DataAPI:getRoomId()
    data.ty = ctype -- 1 续局 2 换桌
    Log.i("MjMediator:continueGame data=", data)
    SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_GAMESTART, data)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UIREQCONTINUE);
end

function DDZTWOP_ProxyDelegate:onStartGameComplete()
    Log.i("DDZTWOP_ProxyDelegate:onStartGameComplete")
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.UIREQCONTINUE)
end

-----------------------------------------
-- 函数功能：    朋友开房续局请求
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:friendRoomRequestContinueGame()
    --朋友开房逻辑特殊处理,如果当前游戏是从朋友开房进入的,完成一局游戏,游戏局数加1
    self:playBgMusic()
    self.m_friendOpenRoom:onContinueButton()

    if DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) > DDZTWOPConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS) == DDZTWOPConst.STATUS_GAMEOVER then
       self:clearDesk()
    end

    if self.m_topBarView then
        self.m_topBarView:setRoomjushu()
    end
end

-----------------------------------------
-- 函数功能：    请求退出房间
-- 消息id： 23000
-- tmpData:     发送语音聊天数据
--[[ 参数：{
   usI: 玩家ID
   niN： 玩家昵称
   roI: 房间Id
   ty: 类型 0文字  1 语音
   co： chat内容 
}]]
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:sendSayMsg(tmpData)
    Log.i("私有房聊天消息:",tmpData)
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZTWOPSocketCmd.CODE_REC_SAY_CHAT,tmpData);
end

-----------------------------------------
-- 函数功能：    请求退出房间
-- 返回值：      无
-----------------------------------------
function DDZTWOP_ProxyDelegate:requestExitRoom()
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZTWOPSocketCmd.CODE_SEND_ExitRoom, {})
end

-----------------------------------------
-- 函数功能：    请求托管
-- 参数：tuoguanState  0(取消托管) 1(请求托管)
-- 返回值：      无   
-----------------------------------------
function DDZTWOP_ProxyDelegate:requestTuoguan(tuoguanState)
    ---Log.i("DDZTWOP_ProxyDelegate:requestTuoguan", tuoguanState)
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    if gameStatus == DDZTWOPConst.STATUS_NONE or gameStatus == DDZTWOPConst.STATUS_GAMEOVER then
        return
    end
    local isM = tuoguanState or DDZTWOPConst.TUOGUAN_STATE_1
    local data = {}
    data.maPI = HallAPI.DataAPI:getUserId()
    data.isM = isM
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_TUOGUAN, data)
end

-----------------------------------------
-- 函数功能：    内置聊天
-- 参数：type  聊天类型   index   聊天内容标记
-- 返回值：      无  
-----------------------------------------
function DDZTWOP_ProxyDelegate:sendDefaultChat(type, index)
    local data = {}
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
    data.usI = HallAPI.DataAPI:getUserId()
    data.ty = type
    data.emI = index
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_DEFAULT_CHAT, data)
end

-----------------------------------------
-- 函数功能：    自定义聊天
-- 参数：type  聊天类型   index   聊天内容标记
-- 返回值：      无  
-----------------------------------------
function DDZTWOP_ProxyDelegate:sendUserChat(type, index)
    local data = {}
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMEPLAYID)
    data.usI = HallAPI.DataAPI:getUserId()
    data.ty = type
    data.emI = index
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZTWOPSocketCmd.CODE_USER_CHAT, data)
end

-----------------------------------------
-- 函数功能：    聊天消息处理
-- 返回值：      无  
-- packetInfo:  封装聊天消息内容
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
-----------------------------------------
function DDZTWOP_ProxyDelegate:onRecvDefaultChat(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZTWOPGameEvent.ONUSERDEFCHAT, packetInfo)
end

--接受朋友房信息
function DDZTWOP_ProxyDelegate:onRecvFriendRoomInfo(packetInfo)
    Log.i("DDZTWOP_ProxyDelegate:onRecvFriendRoomInfo", packetInfo)
    HallAPI.DataAPI:setRoomInfo(packetInfo)
end

return DDZTWOP_ProxyDelegate