-----------------------------------------------
-- @desc 主要用于处理三人斗地主的网络事件
-----------------------------------------------
local ProxyDelegate = require("package_src.games.guandan.gdcommon.network.ProxyDelegate");
local GD_ProxyDelegate = class("GD_ProxyDelegate", ProxyDelegate)
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local GDGameEvent = require("package_src.games.guandan.gd.data.GDGameEvent")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local PlayerModel = require("package_src.games.guandan.gdcommon.model.PlayerModel")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDSocketCmd = require("package_src.games.guandan.gd.proxy.delegate.GDSocketCmd")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDRoom = require("package_src.games.guandan.gd.mediator.room.GDRoom")

--------------------------------------------------
--构造函数
--------------------------------------------------
function GD_ProxyDelegate:ctor()
    -- Log.i("GD_ProxyDelegate:ctor")
    local gameid = HallAPI.DataAPI:getGameId()
    local roomid = HallAPI.DataAPI:getRoomId()
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEID, gameid);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_ROOMID, roomid);

    GD_ProxyDelegate.super.ctor(self, GDSocketCmd.queuecmd, GDSocketCmd.instantcmd)
    self.m_listeners = {}
    self:registMsgs()
    self.hasJGTab = {}
    self.hasHGTab = {}
    self.hasReceHGID = {}--断线重连回来标记已经收到还贡牌的玩家ID
end

--------------------------------------------------
--析构函数 (需手动调用)
--------------------------------------------------
function GD_ProxyDelegate:dtor()
    Log.i("GD_ProxyDelegate:dtor")
    for k,v in pairs(self.m_listeners) do
        Log.i("GD_ProxyDelegate:dtor v", v)
        HallAPI.EventAPI:removeEvent(v)
    end

    self.super.dtor(self)
end

--注册监听事件
function GD_ProxyDelegate:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        Log.i("GD_ProxyDelegate:registMsgs ", id)

        table.insert(self.m_listeners, nhandle)
    end

    addEvent(GDGameEvent.REQCHANGEDESK)
    addEvent(GDGameEvent.REQEXITROOM)
    addEvent(GDGameEvent.REQSENDDEFCHAT)
    addEvent(GDGameEvent.REQTUOGUAN)
        
    addEvent(PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT)
    addEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_TUOGUAN)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT)
    addEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE)

    -- addEvent(HallAPI.EventAPI.GAME_SOCKET_CLOSE)
    -- addEvent(HallAPI.EventAPI.GAME_ON_NETWORK_CONNECT_FAIL)
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        addEvent(HallAPI.EventAPI.START_GAME_COMPLETE)
        addEvent(HallAPI.EventAPI.EXIT_GAME)
        addEvent(HallAPI.EventAPI.RESUME_GAME_REQUEST)
    end

end

----------------------------------------------------------
-- @desc 处理监听事件
-- @pram id 需要监听的事件
--       ... 收到的事件参数
----------------------------------------------------------
function GD_ProxyDelegate:ListenToEvent(id, ... )
    Log.i("GD_ProxyDelegate:ListenToEvent id", id)
    if id == GDGameEvent.REQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == GDGameEvent.REQEXITROOM
        or id == PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT
        or id == HallAPI.EventAPI.EXIT_GAME
        then
        self:requestExitRoom()
    elseif id == GDGameEvent.REQSENDDEFCHAT or id == PokerEventDef.GameEvent.REQSENDDEFCHAT then
        self:sendDefaultChat(...)
    elseif id == GDGameEvent.REQTUOGUAN or id == PokerEventDef.GameEvent.GAME_REQ_TUOGUAN then
        self:requestTuoguan(...)
    -- elseif id == HallAPI.EventAPI.GAME_SOCKET_CLOSE then
    --     self:onNetWorkClosed()
    -- elseif id == HallAPI.EventAPI.GAME_ON_NETWORK_CONNECT_FAIL then
    --     self:onNetWorkConnectFail()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT then
        self:sendSayMsg(...)
    elseif id == PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE then
        self:reqContinueGame()
    elseif id == HallAPI.EventAPI.START_GAME_COMPLETE then
        self:onStartGameComplete()
    elseif id == HallAPI.EventAPI.RESUME_GAME_REQUEST then
        self:onNetWorkReconnected()
    end
end

-- 函数功能：    解析服务器消息
-- 返回值：      无
-- eventdata:   封装过的消息体
function GD_ProxyDelegate:ReadServerStructInfor(eventdata)
    Log.i("GD_ProxyDelegate:ReadServerStructInfor eventdata.cmd", eventdata.cmd)
    --游戏开始
    if eventdata.cmd == GDSocketCmd.CODE_REC_GAMESTART then
        self:onGameStart(eventdata.packetInfo)

    -- 进贡
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_JINGONG then
        self:onRecvJingong(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 还贡
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_HUANGONG then
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, false)
        self:onRecvHuanGong(eventdata.packetInfo)

    -- 开始打牌
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_STARTPLAY then
        self:onRecvStartPlay(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 出牌
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_OUTCARD then
        self:onRecvOutCard(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 单局游戏结束
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_GAMEOVER then
        -- 还是需要解析数据，在ddzroom里面不去调用单局结算界面
        -- if HallAPI.DataAPI:isGameEnd() then
        --     Log.i("****************************end")
        --     HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
        -- else
        --     Log.i("****************************not end")
        --     HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        --     HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE,1)
        -- end
        -- 斗地主的情况
        self:onRecvGameOver(eventdata.packetInfo)
        -- HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        
    --朋友房本次开放结束
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_TOTAL_GAME_OVER then
        self:onRecvTotalGameOver(eventdata.packetInfo)
        -- 下面的改到了ddzroom单局结算的地方去处理
        -- HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
        --HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)  

    -- 退出房间
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_ExitRoom then
        self:onRecvExitRoom(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    --重连
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_RECONNECT then
        self:onRecvReconnect(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    elseif eventdata.cmd == GDSocketCmd.CODE_TUOGUAN then
        self:onRecvTuoGuan(eventdata.packetInfo)

    --聊天
    elseif eventdata.cmd == GDSocketCmd.CODE_DEFAULT_CHAT then
        self:onRecvDefaultChat(eventdata.packetInfo)

    --房间信息
    elseif eventdata.cmd == GDSocketCmd.CODE_RECV_FRIEND_ROOM_INFO then
        self:onRecvFriendRoomInfo(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_UPDATE_CASH then
        self:onUserMoneyUpdate(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_REC_BROCAST then
        self:onRecvBrocast(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_REC_DOLE_INFO then
        self:onRecvDole(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_REC_POKERDIALOG then
        self:onRecvTips(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_REC_ENTERROOM then
        self:onRecvEnterRoom(eventdata.packetInfo)

    --请求解散房间
    elseif eventdata.cmd == GDSocketCmd.CODE_FRIEND_ROOM_LEAVE then
        self:onRecvReqDismiss(eventdata.packetInfo)

    --解散房间结果
    elseif eventdata.cmd == GDSocketCmd.CODE_RECV_FRIEND_ROOM_END then
        DataMgr:getInstance():setDisMissFlag(false)
        self:onRecvDismissRes(eventdata.packetInfo)

    elseif eventdata.cmd == GDSocketCmd.CODE_REC_CONTINUE then
        self:onRecvFriendContinue(eventdata.packetInfo)

    --收到语音消息
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_SAY_CHAT then
        self:onRecvSayChat(eventdata.packetInfo)

    -- 更新玩家定位信息
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_LOCATION then
        self:onLocationUpdate(eventdata.packetInfo)

    -- 收到服务器下发的重连消息
    elseif eventdata.cmd == GDSocketCmd.CODE_REC_RESUMEGAME then
        self:onRoomResume(eventdata.packetInfo)
    -- 收到服务器下发的重连消息
    elseif eventdata.cmd == GDSocketCmd.CODE_PLAYER_ROOM_STATE then
        self:FriendRoomExit(eventdata.packetInfo)
    end
end

--玩家解散
function GD_ProxyDelegate:FriendRoomExit(packetInfo)
    -- 收到服务器的消息,退出到大厅
    Log.i("--wangzhi--收到服务器发过来的解散消息--",packetInfo)
    if packetInfo and (packetInfo.gaT == 0  or packetInfo.gaT == 6) then
        -- MjMediator:getInstance():exitGame()
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
    end    
end

-- 函数功能：    游戏开始
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onGameStart(packetInfo)
    -- 给开局设置一个时间戳，用于判断进贡还贡的消息乱序
    self.hasReceHGID = {}
    Log.i("--wangzhi--onGameStart.sendTime--",packetInfo.sendTime,type(packetInfo.sendTime))
    if packetInfo.sendTime then
        DataMgr:getInstance():setGameStartTime(packetInfo.sendTime)
    end
    self.hasJGTab = {}
    self.hasHGTab = {}
    DataMgr:getInstance():resetPlayerRank()
    Log.i("GD_ProxyDelegate:onGameStart", packetInfo)
    --packetInfo.bo字段为底牌，掼蛋没用
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_SELECARDLEGAL, false)
    if VideotapeManager.getInstance():isPlayingVideo() then
        for k, v in pairs(packetInfo.plI1) do
            v.ca0 = {}
            local videoPlayerInfo = kPlaybackInfo:getStartGameContentByid(v.plI)
            for k1,v1 in ipairs(videoPlayerInfo.plI1) do
                if v1.plI == v.plI then
                    for k2,v2 in pairs(v1.ca0) do
                        v.ca0[k2] = GDCard.ConvertToLocal(v2); 
                    end
                end

            end
        end
    else
        for k, v in pairs(packetInfo.plI1) do
            v.ca0 = checktable(v.ca0)
            for k1, v1 in pairs(v.ca0) do
                if v1 ~= -1 then
                    v.ca0[k1] = GDCard.ConvertToLocal(v1);
                end
            end
        end
    end

    packetInfo = checktable(packetInfo);
    if packetInfo and packetInfo.wanfa then
        DataMgr:getInstance():setWanfaData(packetInfo.wanfa)
    end 
    --是否是抗贡状态   2表示抗贡状态
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_KANG_GONG_FLAG, packetInfo.kangGongFlag)
    -- 增加本局打谁的级牌的ID
    Log.i("--wangzhi--jiPaiUserId--",packetInfo.jiPaiUserId)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LEVEL_USER, packetInfo.jiPaiUserId or {});
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEID, packetInfo.gaI);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID)--正在操作玩家ID
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LIMITTIME, GDConst.DEFOPETIME);
    else
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LIMITTIME, packetInfo.plTO or GDConst.DEFOPETIME);
    end
    --packetInfo.inD倍数
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, packetInfo.st)--游戏状态
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_TUOGUANSTATE, GDConst.TUOGUAN_STATE_0)

    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTCARDS, {});
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTYPE, enmCardType.EBCT_TYPE_NONE);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTIPS, {});
    
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    if PlayerModelList and next(PlayerModelList) then
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_PLAYERLIST_LAST, PlayerModelList)
    end
    local function call()
        HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONGAMESTART)
        self:dealGong(packetInfo, false, false, true)
    end
    self:initPlayer(packetInfo.plI1)
    self:updateGrade(packetInfo.jiPaiUserId)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.SHOWEXCHANGEHEAD, call)

    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTSEAT, GDConst.SEAT_NONE)
    DataMgr:getInstance():SetPlayerScore()

end

-------------------------------------------------------
-- @desc 判断玩家seat是否合法
-------------------------------------------------------
function GD_ProxyDelegate:isLegalSeat(seat)
    if seat and seat >= 1 and seat <= GDConst.PLAYER_NUM then
        return true;
    end
    return false;
end

-------------------------------------------------------
-- @desc 根据玩家userid获取玩家位置
-- @pram playerId 玩家id
-------------------------------------------------------
function GD_ProxyDelegate:getSeatByPlayerId(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(GDDefine.USERID) == playerId then
            return v:getProp(GDDefine.SITE)
        end
    end
end


------------------------------------------------------
-- @desc 初始化玩家信息
-- @pram playerInfos
--[[{
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
        jiD          玩家经度
        weD          玩家纬度
        ipA          玩家ip
}
--]]
------------------------------------------------------
function GD_ProxyDelegate:initPlayer(playerInfos)
   local myIndex = 1;
    for k, v in pairs(playerInfos) do
        if v.plI == HallAPI.DataAPI:getUserId() then
            myIndex = k;
        end
    end

    local playerList = {}
    for k, v in pairs(playerInfos) do
        local seat = k - (myIndex - 1);
        if seat < 1 then
            seat = seat + GDConst.PLAYER_NUM;
        end

        local player = PlayerModel:new()
        player:setProp(GDDefine.USERID, v.plI)
        player:setProp(GDDefine.NAME, v.plN)
        player:setProp(GDDefine.SEX, v.se == GDConst.FEMALE and GDConst.MALE or GDConst.FEMALE)
        player:setProp(GDDefine.MONEY, v.fo)
        player:setProp(GDDefine.ICON_ID, v.heU)
        player:setProp(GDDefine.CARD_NUM, #v.ca0)
        player:setProp(GDDefine.HAND_CARDS, v.ca0)
        player:setProp(GDDefine.JING_DU,v.jiD)
        player:setProp(GDDefine.WEI_DU,v.weD)
        player:setProp(GDDefine.IP,v.ipA)
        player:setProp(GDDefine.SITE, seat)
        player:setProp(GDDefine.LEVEL, v.le)
        player:setProp(GDDefine.HASTUOGUAN, v.isM or GDConst.TUOGUAN_STATE_0)
        -- 增加级牌的数据
        player:setProp(GDDefine.OUR_GRADE, v.myJiPai)
        player:setProp(GDDefine.OTHER_GRADE, v.youJiPai)
        table.insert(playerList, player)
    end

    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_PLAYERLIST, playerList);
end

--函数功能： 进入房间
--返回值： 无
--packetInfo: 封装进入房间的消息
function GD_ProxyDelegate:onRecvEnterRoom(packetInfo)
    Log.i("GD_ProxyDelegate enterRoom:",packetInfo)
    
    local roomInfo =  HallAPI.DataAPI:getRoomInfoById(packetInfo.gaI, packetInfo.roI);
    if roomInfo then
        local roomid = HallAPI.DataAPI:getRoomId()
        --重新设置房间类型
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_ROOMID, roomid)
        --重新设置房间底数
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_BASEROOM, roomInfo.an)
    end
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVENTERROOM)
end

-- 函数功能：    进贡
function GD_ProxyDelegate:onRecvJingong(packetInfo)
    Log.i("GD_ProxyDelegate:onRecvJingong", packetInfo)

    Log.i("--wangzhi--onRecvJingong.sendTime--",packetInfo.sendTime)
    if packetInfo.sendTime then
        local gameStartTime = DataMgr:getInstance():getGameStartTime()
        Log.i("--wangzhi--进贡时间--")
        if packetInfo.sendTime < gameStartTime then
            Log.d("--wangzhi--消息乱序--对进贡不进处理了--")
            return
        end
    end


    if VideotapeManager.getInstance():isPlayingVideo() then
        local tmpJinGongMap = clone(packetInfo.JinGongMap)
        for k,v in pairs(tmpJinGongMap) do
            local jingongplayerID
            local jingongplayerID2
            local jingongCard = {}
            jingongplayerID = k
            for kk,vv in pairs(v) do
                if vv then
                    jingongplayerID2 = kk
                    if vv then
                        local localCard = GDCard.ConvertToLocal(vv)
                        table.insert(jingongCard,localCard)
                    end
                end
            end
            if jingongplayerID and jingongplayerID2 and tonumber(jingongplayerID) ~= 0 and tonumber(jingongplayerID2) ~= 0 then
                local player1 = DataMgr:getInstance():getPlayerInfo(tonumber(jingongplayerID))
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(player1:getProp(GDDefine.USERID)))
                if #jingongCard > 0 then 
                    player1:delCards(jingongCard, seat)
                end
                local player2 = DataMgr:getInstance():getPlayerInfo(tonumber(jingongplayerID2))
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(player2:getProp(GDDefine.USERID)))
                if #jingongCard > 0 then 
                    player2:addCards(jingongCard, seat)
                end
            end
        end

        
    end

    self:dealGong(packetInfo, true)
end

-- 函数开局:  获取玩家信息
-- 参数: playerId:玩家id
function GD_ProxyDelegate:getPlayerInfo(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        Log.i("v:getProp(GDDefine.USERID)", v:getProp(GDDefine.USERID))
        if v:getProp(GDDefine.USERID) == playerId then
            return v
        end
    end
end

-- 函数功能：    还贡返回
function GD_ProxyDelegate:onRecvHuanGong(packetInfo)
    Log.i("GD_ProxyDelegate:onRecvHuanGong",packetInfo)

    packetInfo = checktable(packetInfo)

    Log.i("--wangzhi--onRecvHuanGong.sendTime--",packetInfo.sendTime)
    if packetInfo.sendTime then
        local gameStartTime = DataMgr:getInstance():getGameStartTime()
        Log.i("--wangzhi--还贡时间--",gameStartTime)
        if packetInfo.sendTime < gameStartTime then
            Log.d("--wangzhi--消息乱序--对还贡不进处理了--")
            return
        end
    end

    if VideotapeManager.getInstance():isPlayingVideo() then
        local player = DataMgr:getInstance():getPlayerInfo(packetInfo.usI)
        local tmpHuanGongMap = clone(packetInfo.HuanGongMap)
        for k,v in pairs(tmpHuanGongMap) do
            local huangongplayerID
            local huangongplayerID2
            local huangongCard = {}
            huangongplayerID = k
            for kk,vv in pairs(v) do
                if vv then
                    huangongplayerID2 = kk
                    if vv then
                        local localCard = GDCard.ConvertToLocal(vv)
                        table.insert(huangongCard,localCard)
                    end
                end
            end
            if huangongplayerID and huangongplayerID2 and tonumber(huangongplayerID) ~= 0 and tonumber(huangongplayerID2) ~= 0 then
                local player1 = DataMgr:getInstance():getPlayerInfo(tonumber(huangongplayerID))
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(player1:getProp(GDDefine.USERID)))
                if #huangongCard > 0 then 
                    player1:delCards(huangongCard, seat)
                end
                local player2 = DataMgr:getInstance():getPlayerInfo(tonumber(huangongplayerID2))
                local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(player2:getProp(GDDefine.USERID)))
                if #huangongCard > 0 then 
                    player2:addCards(huangongCard, seat)
                end
            end
        end
    end

    self:dealGong(packetInfo, false, true)
end

-- 函数功能：    开始打牌
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvStartPlay(packetInfo)
    Log.i("onRecvStartPlay",packetInfo)
    packetInfo = checktable(packetInfo)
    --packetInfo.deb 1为需要处理debug
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, GDConst.STATUS_ON_OUT_CARD)

    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONSTRATPLAY, packetInfo)  
end

-- 函数功能：    出牌
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvOutCard(packetInfo, isReconnect)
    Log.i("onRecvOutCard",packetInfo,isReconnect)
    packetInfo = checktable(packetInfo);
    --plc打出的牌
    if packetInfo.plC and #packetInfo.plC  > 0 then
        for k, v in pairs(packetInfo.plC) do
            packetInfo.plC[k] = GDCard.ConvertToLocal(v);
        end
    end

    ---重登对玩家打出的牌进行处理
    local putOutCards = {}
    if packetInfo.gplC and table.nums(packetInfo.gplC) > 0 then
        for k, v in pairs(packetInfo.gplC) do
            local info = {}
            info.userId = tonumber(k)
            local list_info = {}
            if v.playCard then
                for key, value in pairs(v.playCard) do
                    if value ~= 0 then
                        list_info[key] = GDCard.ConvertToLocal(value)
                    else
                        list_info[key] = value
                    end
                end
            end
            info.cards = list_info
            info.cardType = self:changeToLocalCardType(v.cardPatternId)
            putOutCards[#putOutCards + 1] = info
        end
        packetInfo.gplC = putOutCards
    end

    packetInfo.ouCT = self:changeToLocalCardType(packetInfo.ouCT)
    local cards = packetInfo.plC or {};
    local lastCardType = packetInfo.ouCT
    if lastCardType ~= GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_PAIRS then
        lastCardType = nil
    end

    if packetInfo.usI == HallAPI.DataAPI:getUserId() then
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTCARDS, {});
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTYPE, enmCardType.EBCT_TYPE_NONE);
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTIPS, {});
    else
        if isReconnect then
            for k,v in pairs(packetInfo.gplC) do
                if v.userId == packetInfo.usI then
                    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTCARDS, v.cards)
                    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTYPE, v.cardType)
                end
            end
        else
            if packetInfo.ouCT ~= enmCardType.EBCT_TYPE_NONE then
                DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTOUTCARDS, cards);
                DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LASTCARDTYPE, packetInfo.ouCT);
            end
        end
    end

    local player = DataMgr:getInstance():getPlayerInfo(packetInfo.usI)
    local isExist = DataMgr:getInstance():isPlayerExist(packetInfo.usI)
    Log.i("========fff====isExist==========ffffffffffffffffffff",isExist)
    if not isExist then
        HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONOUTCARD, packetInfo)  
        return 
    end

    -- Log.i("player before", player)
    if not isReconnect then
        if player:getProp(GDDefine.USERID) == HallAPI.DataAPI:getUserId() then
            player:delCards(packetInfo.plC, true)
        elseif VideotapeManager.getInstance():isPlayingVideo() then
            local seat = DataMgr:getInstance():getSeatByPlayerId(tonumber(player:getProp(GDDefine.USERID)))
            player:delCards(packetInfo.plC, seat)
        else
            --如果不是地主则设置为-1
            local tb = {}
            for i = 1, #packetInfo.plC do
                table.insert(tb, -1)
            end
            player:delCards(tb, true)
        end
    end
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONOUTCARD, packetInfo, isReconnect)  
end

-- 函数功能：    游戏结束
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvGameOver(packetInfo)
    Log.i("onRecvGameOver packetInfo",packetInfo)
    packetInfo = checktable(packetInfo);

    for k, v in pairs(packetInfo.plI1) do
        if v.ca then
            for k1, v1 in pairs(v.ca) do
                if v1 ~= -1 then
                    v.ca[k1] = GDCard.ConvertToLocal(v1);
                end
            end
        end
    end
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)
    local isReconnect = false
    if gameStatus == GDConst.STATUS_ON_GAMEOVER then
        isReconnect = true
    end
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, GDConst.STATUS_ON_GAMEOVER)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_TUOGUANSTATE, GDConst.TUOGUAN_STATE_0)

    for k, v in pairs(packetInfo.plI1) do
       local PlayerModel = DataMgr:getInstance():getPlayerInfo(v.plI)
       local seat = PlayerModel:getProp(GDDefine.SITE)
       PlayerModel:setProp(GDDefine.MONEY, v.fo, true, seat)
    end

    -- 增加牌局记录
    if packetInfo and packetInfo.AGR then
        -- DataMgr:getInstance():setMatchRecord(packetInfo.AGR)
        local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()
        table.insert(matchTotalInfo,packetInfo.AGR)
        DataMgr:getInstance():setMatchTotalRecord(matchTotalInfo)
    end 
 
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.GAMEOVER, packetInfo, isReconnect) 
end

---------------------------------------------------------
-- @desc 游戏总结算
-- @pram packetInfo:收到的网络消息
---------------------------------------------------------
function GD_ProxyDelegate:onRecvTotalGameOver(packetInfo)
    Log.i("GD_ProxyDelegate onRecvTotalGameOver:",packetInfo)
    packetInfo = checktable(packetInfo)
    -- Log.i("设置牌局结束的状态:")
    HallAPI.DataAPI:setGameEnd(true) --需要添加API
    --缓存总结算消息
    local tmpData = {}
    packetInfo.overType = 2
    tmpData.param = packetInfo
    DataMgr.getInstance():setObject(GDDataConst.DataMgrKey_FRIENDTOTALDATA, tmpData)
    -- HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVTOTALGAMEOVER, packetInfo)
end


-- 游戏托管
-- packetInfo:网络消息
function GD_ProxyDelegate:onRecvTuoGuan(packetInfo)
    Log.i("onRecvTuoGuan packetInfo", packetInfo)
    if packetInfo.maPI == HallAPI.DataAPI:getUserId() then
        DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_TUOGUANSTATE, packetInfo.isM)
    end

    local isExist = DataMgr:getInstance():isPlayerExist(packetInfo.maPI)
    if isExist then
        local player = DataMgr:getInstance():getPlayerInfo(packetInfo.maPI)
        local seat = player:getProp(GDDefine.SITE)
        player:setProp( GDDefine.HASTUOGUAN, packetInfo.isM)
    end

    --## 托管玩家id maPI
    --## 是否被托管 isM
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONTUOGUAN, packetInfo)
end
----------------------------------------------------------
-- @desc 重连成功
-- @pram packetInfo 玩家重连后收到的牌局数据
----------------------------------------------------------
function GD_ProxyDelegate:onRecvReconnect(packetInfo)
    Log.i("重连成功=================onRecvReconnect packetInfo", packetInfo)

    Log.i("--wangzhi--onRecvReconnect.sendTime--",packetInfo.sendTime,type(packetInfo.sendTime))
    if packetInfo.sendTime then
        DataMgr:getInstance():setGameStartTime(packetInfo.sendTime)
    end

    packetInfo = checktable(packetInfo);
    DataMgr:getInstance():SetPlayerScore()
    DataMgr:getInstance():resetPlayerRank()
    for k,v in pairs(packetInfo.leaveDeskList) do
        if v ~= -1 then
            DataMgr:getInstance():setPlayerRank(v)
        end
    end
    
    --扑克玩法数据
    if packetInfo and packetInfo.wfS then
        DataMgr:getInstance():setWanfaData(packetInfo.wfS)
    end

    --跑得快战绩数据
    if packetInfo and packetInfo.LiAGR then
        DataMgr:getInstance():setMatchTotalRecord(packetInfo.LiAGR)
    end
    --packetInfo.bo字段为底牌，掼蛋没用
    
    for k, v in pairs(packetInfo.plI1) do
        if v.ca0 then
            for k1, v1 in pairs(v.ca0) do
                if v1 ~= -1 then
                    v.ca0[k1] = GDCard.ConvertToLocal(v1);
                end
            end
        end
    end

    DataMgr:getInstance():init()
    -- 增加本局打谁的级牌的ID
    Log.i("--wangzhi--jiPaiUserId--",packetInfo.jiPaiUserId)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LEVEL_USER, packetInfo.jiPaiUserId or {});
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEID, packetInfo.gaI);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID);

    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LIMITTIME, packetInfo.plTO);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, packetInfo.st);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_TUOGUANSTATE, GDConst.TUOGUAN_STATE_0);
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_LEFTTIME, packetInfo.wt);
   
    self:initPlayer(packetInfo.plI1);
    self:updateGrade(packetInfo.jiPaiUserId)
    -- packetInfo.loI 地主id 掼蛋不需要
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECONNECT, packetInfo)

    if packetInfo.st == GDConst.STATUS_ON_OUT_CARD then
        local info = {};
        info.usI = packetInfo.prPI--上一手牌玩家id
        info.neP = packetInfo.fiPUID--开始玩家ＩＤ
        info.gplC = packetInfo.gplC;
        info.fl = 0
        if packetInfo.prC and #packetInfo.prC > 0 then
            info.fl = 1
        end
        info.plC = packetInfo.prC;--打出的牌
        self:onRecvOutCard(info, true)
    end

    self:dealGong(packetInfo, false, false, false, true)
end

-- 函数功能：    处理进贡、还贡消息
function GD_ProxyDelegate:dealGong(packetInfo, JGBack, HGBack, isStart, isReconnect)
    if isReconnect then
        for k,v in pairs(packetInfo.JinGongMap) do
            if next(v) then
                --已经进贡的玩家
                self.hasJGTab[k] = 1
            end
        end
        for k,v in pairs(packetInfo.HuanGongMap) do
            if next(v) then
                --已经还贡的玩家
                self.hasHGTab[k] = 1
                for kk,vv in pairs(v) do
                    table.insert(self.hasReceHGID, tonumber(kk))
                end
            end
        end
    end

    local allHasJinGong = true
    for k,v in pairs(packetInfo.JinGongMap) do
        if not next(v) then
            allHasJinGong = false
        end
        local playerJinGong = DataMgr:getInstance():getPlayerInfo(tonumber(k))
        for kk, vv in pairs(v) do
            local cardValue = GDCard.ConvertToLocal(vv)
            --删除进贡的牌
            if JGBack and not self.hasJGTab[k] then
                if tonumber(k) == kUserInfo:getUserId() then
                    playerJinGong:delCards({cardValue}, true)
                else
                    playerJinGong:delCards({-1}, true)
                end
                local seat = playerJinGong:getProp(GDDefine.SITE)
                HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONPLAYERCARD, seat)
                self.hasJGTab[k] = 1
            end

            --添加进贡的牌 --加牌统一在移动动作(GDRoom:moveToPlayer)之后
            packetInfo.JinGongMap[string.format("%s",k)][string.format("%s",kk)] = cardValue
        end
    end

    local allHasHuanGong = true
    for k,v in pairs(packetInfo.HuanGongMap) do
        if not next(v) then
            allHasHuanGong = false
        end
        local playerHuanGong = DataMgr:getInstance():getPlayerInfo(tonumber(k))
        for kk, vv in pairs(v) do
            local cardValue = GDCard.ConvertToLocal(vv)
            --删除还贡的牌
            if HGBack and not self.hasHGTab[k] then
                if tonumber(k) == kUserInfo:getUserId() then
                    playerHuanGong:delCards({cardValue}, true)
                else
                    playerHuanGong:delCards({-1}, true)
                end
                local seat = playerHuanGong:getProp(GDDefine.SITE)
                HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONPLAYERCARD, seat)
                self.hasHGTab[k] = 1
            end
            --添加还贡的牌 --加牌统一在移动动作(GDRoom:moveToPlayer)之后
            packetInfo.HuanGongMap[string.format("%s",k)][string.format("%s",kk)] = cardValue
        end
    end
    
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_JINGGONGMAP, packetInfo.JinGongMap)
    DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_HUANGONGMAP, packetInfo.HuanGongMap)
    if next(packetInfo.JinGongMap) then
        if not allHasJinGong then
            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, GDConst.STATUS_ON_JINGONG)
        elseif not allHasHuanGong then
            DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, GDConst.STATUS_ON_HUANGONG)
        end
        if not isStart then
            local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS);
            if allHasJinGong and allHasHuanGong and gameStatus ~= GDConst.STATUS_ON_GAMEOVER then
                DataMgr:getInstance():setObject(GDDataConst.DataMgrKey_GAMESTATUS, GDConst.STATUS_ON_OUT_CARD)
            end
            HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONDEALGONG, JGBack, HGBack, isReconnect, self.hasReceHGID)
        end
    end
end
-- 函数功能：    退出房间
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvExitRoom(packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONEXITROOM, packetInfo)
end

--请求解散房间
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvReqDismiss(packetInfo)
    -- Log.i("--wangzhi--分发解散消息--")
    local ddzRoomLoaded = PokerUIManager.getInstance():getWnd(GDRoom);
    if ddzRoomLoaded == nil then
        scheduler.performWithDelayGlobal(function()
            HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVREQDISSMISS, packetInfo)  
        end, 0.6);
    else
        HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVREQDISSMISS, packetInfo)
    end
end

--解散房间结果
-- packetInfo:  封装过的消息内容
function GD_ProxyDelegate:onRecvDismissRes(packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVDISSMISSEND, packetInfo)
end

-----------------------------------------
-- 函数功能：    朋友房续局
-- 返回值：      无
-----------------------------------------
function GD_ProxyDelegate:onRecvFriendContinue(packetInfo)
    Log.i("GD_ProxyDelegate onRecvFriendContinue:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONRECVFRIENDCONTINUE,packetInfo)
end

-----------------------------------------
-- 函数功能：    语音聊天
-- 返回值：      无
-----------------------------------------
function GD_ProxyDelegate:onRecvSayChat(packetInfo)
    Log.i("GD_ProxyDelegate onRecvSayChat:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.RESAYCHAT, packetInfo)
end


--更新玩家金豆
function GD_ProxyDelegate:onUserMoneyUpdate(packetInfo)
    Log.i("GD_ProxyDelegate:onUserMoneyUpdate", packetInfo)
    local userId = packetInfo.usI
    local money = packetInfo.ca
    local PlayerModel = DataMgr:getInstance():getPlayerInfo(userId)
    local seat = PlayerModel:getProp(GDDefine.SITE)
    PlayerModel:setProp(GDDefine.MONEY, money, true, seat)
end

--接受朋友房信息
function GD_ProxyDelegate:onRecvFriendRoomInfo(packetInfo)
    Log.i("GD_ProxyDelegate:onRecvFriendRoomInfo", packetInfo)
    HallAPI.DataAPI:setRoomInfo(packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONLINE, packetInfo)
end 


--收到后台提示
function GD_ProxyDelegate:onRecvTips(packetInfo)
    Log.i("GD_ProxyDelegate:onRecvTips",packetInfo)
    PokerToast.getInstance():show(packetInfo.text)
end

--收到广播?
function GD_ProxyDelegate:onRecvBrocast(packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.RECVBROCAST, packetInfo)
end

-- 网络重连成功
function GD_ProxyDelegate:onNetWorkReconnected()
    Log.i("------Classical:onNetWorkReconnected");
    self.super:onNetWorkReconnected()
    scheduler.performWithDelayGlobal(function()
        -- LoadingView.getInstance():hide();
        local data = {};
        data.plI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMEPLAYID)
        --HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_SEND_RESUMEGAME, data);
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_RESUME_GAME,data.plI)
    end, 1);
    
end

-- 网络关闭 数据暂无处理
function GD_ProxyDelegate:onNetWorkClosed(...)
    self.super:onNetWorkClosed(...)
end

-- 网络连通失败  数据暂无处理
function GD_ProxyDelegate:onNetWorkConnectFail()
    self.super:onNetWorkConnectFail()
end

--请求换桌
function GD_ProxyDelegate:reqChangeDesk()
    HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,2);
end

--续局
function GD_ProxyDelegate:reqContinueGame()
    Log.i("GD_ProxyDelegate:reqContinueGame ")

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        ---[[
        local data = {};
        -- data.gaI = GDGameManager.getInstance():getGameId();
        data.opS = 2
        data.gaI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMEID)
        data.plT = 1;
        data.roI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_ROOMID)
        data.ty = 1;-- 1 续局 2 换桌
        HallAPI.DataAPI:send(CODE_TYPE_ROOM, GDSocketCmd.CODE_SEND_GAMESTART, data)

        HallAPI.EventAPI:dispatchEvent(GDGameEvent.UIREQCONTINUE, isReq)
        --]]
    else
        --请求续局,交由大厅统一处理
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,1);
    end
end

--开始游戏完成
function GD_ProxyDelegate:onStartGameComplete()
    Log.i("GD_ProxyDelegate:onStartGameComplete")
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.UIREQCONTINUE, true)
end

--发送语音消息
function GD_ProxyDelegate:sendSayMsg(tmpData)
    Log.i("私有房聊天消息:",tmpData)
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, GDSocketCmd.CODE_REC_SAY_CHAT,tmpData);
end

--退出房间
function GD_ProxyDelegate:requestExitRoom()
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, GDSocketCmd.CODE_SEND_ExitRoom, {});
    -- LoadingView.getInstance():show("正在退出游戏，请稍后...")
end

--------------------------------------------
-- @desc 托管
-- @pram tuoguanState：  1托管   0取消托管  
--------------------------------------------    
function GD_ProxyDelegate:requestTuoguan(tuoguanState)
    Log.i("GD_ProxyDelegate:requestTuoguan", tuoguanState)
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS);
    if gameStatus == GDConst.STATUS_NONE or gameStatus == GDConst.STATUS_ON_GAMEOVER then
        Log.i("quxiaotuoguan filed!!!",gameStatus)
        return;
    end
    local isM = tuoguanState or GDConst.TUOGUAN_STATE_0;
    local data = {};
    data.maPI = HallAPI.DataAPI:getUserId();
    data.isM = isM;
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_TUOGUAN, data);
end

--发送内置聊天短语和表情
function GD_ProxyDelegate:sendDefaultChat(type, index)
    Log.i("--wangzhi--发送消息的类型--",type)
    local data = {};
    data.gaPI = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_GAMEPLAYID)
    data.usI = HallAPI.DataAPI:getUserId();
    data.ty = type;
    data.emI = index;
    HallAPI.DataAPI:send(CODE_TYPE_GAME, GDSocketCmd.CODE_DEFAULT_CHAT, data);
end

--内置聊天
function GD_ProxyDelegate:onRecvDefaultChat(packetInfo)
    HallAPI.EventAPI:dispatchEvent(GDGameEvent.ONUSERDEFCHAT, packetInfo)
end

--更新玩家经纬度数据
function GD_ProxyDelegate:onLocationUpdate(packetInfo)
    local playerId = packetInfo.usI
    local player = DataMgr:getInstance():getPlayerInfo(playerId)
    if player ~= nil then
        player:refreshLocationInfo(packetInfo)
    end
end

--收到服务器下发的重连消息
function GD_ProxyDelegate:onRoomResume(packetInfo)
    if packetInfo.re == 1 then
        -- Toast.getInstance():show("重连成功");
    else
        local ddzRoomLoaded = PokerUIManager.getInstance():getWnd(GDRoom)
        PokerUIManager.getInstance():popAllWnd(true)
        ddzRoomLoaded:onExitRoom()

        -- 返回大厅后弹对局结束提示
        scheduler.performWithDelayGlobal(function()
            Toast.getInstance():show("对局已结束")
        end, 0.5)
    end
end

--更新级牌
function GD_ProxyDelegate:updateGrade(jiPaiUserId)
    -- 默认为别人的级牌等级
    local myUserId = HallAPI.DataAPI:getUserId()
    local ourGrade = 0
    local otherGrade = 0
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        local userId = v:getProp(GDDefine.USERID)
        if myUserId == userId then
            ourGrade = v:getProp(GDDefine.OUR_GRADE)
            otherGrade = v:getProp(GDDefine.OTHER_GRADE)
        end
    end
    local grade = otherGrade
    for i,v in ipairs(jiPaiUserId) do
        if myUserId == v then
            -- 改为自己的级牌等级
            grade = ourGrade 
        end
    end
    RULESETTING.nLevelCard = grade
end

function GD_ProxyDelegate:changeToLocalCardType(cardType)
    if cardType == GDConst.CARDSTYPE.EBCT_TYPE_NONE then
        return enmCardType.EBCT_TYPE_NONE
    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_SINGLE then
        return enmCardType.EBCT_BASETYPE_SINGLE
    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_PAIR then
        return enmCardType.EBCT_BASETYPE_PAIR
    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_3KIND then
        return enmCardType.EBCT_BASETYPE_3KIND
    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_3AND2 then
        return enmCardType.EBCT_BASETYPE_3AND2
    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_SISTER then
        return enmCardType.EBCT_BASETYPE_SISTER
    elseif cardType == GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_PAIRS then
        return enmCardType.EBCT_CUSTOMERTYPE_PAIRS
    elseif cardType == GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_3KINDS then
        return enmCardType.EBCT_CUSTOMERTYPE_3KINDS
    elseif cardType == GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_KING_BOMB then
        return enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB

    elseif cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB 
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB5
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB6
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB7
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB8
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB9
            or cardType == GDConst.CARDSTYPE.EBCT_BASETYPE_BOMB10
            then
        return enmCardType.EBCT_CUSTOMERTYPE_BOMB
    elseif cardType == GDConst.CARDSTYPE.EBCT_CUSTOMERTYPE_SISTER_BOMB then
        return enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB
    end
end

return GD_ProxyDelegate