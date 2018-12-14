-----------------------------------------------
-- @desc 主要用于处理三人斗地主的网络事件
-----------------------------------------------
local ProxyDelegate = require("package_src.games.paodekuai.pdkcommon.network.ProxyDelegate");
local DDZ_ProxyDelegate = class("DDZ_ProxyDelegate", ProxyDelegate)
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local DDZPKCardTypeAnalyzer = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZCard = require("package_src.games.paodekuai.pdk.utils.card.DDZCard")
local Facade = require("package_src.games.paodekuai.pdkcommon.control.Facade");
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local PlayerModel = require("package_src.games.paodekuai.pdkcommon.model.PlayerModel")
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local DDZSocketCmd = require("package_src.games.paodekuai.pdk.proxy.delegate.DDZSocketCmd")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local DDZRoom = require("package_src.games.paodekuai.pdk.mediator.room.DDZRoom")

--------------------------------------------------
--构造函数
--------------------------------------------------
function DDZ_ProxyDelegate:ctor()
    Log.i("DDZ_ProxyDelegate:ctor")

    local gameid = HallAPI.DataAPI:getGameId()
    local roomid = HallAPI.DataAPI:getRoomId()
    Log.i("DDZRoom DataMgrKey_GAMEID 1", gameid)
    Log.i("DDZRoom DataMgrKey_GAMEID 1", roomid)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEID, gameid);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_ROOMID, roomid);

    DDZ_ProxyDelegate.super.ctor(self, DDZSocketCmd.queuecmd, DDZSocketCmd.instantcmd)
    self.m_listeners = {}
    self:registMsgs()
end

--------------------------------------------------
--析构函数 (需手动调用)
--------------------------------------------------
function DDZ_ProxyDelegate:dtor()
    Log.i("DDZ_ProxyDelegate:dtor")
    for k,v in pairs(self.m_listeners) do
        Log.i("DDZ_ProxyDelegate:dtor v", v)
        HallAPI.EventAPI:removeEvent(v)
    end

    self.super.dtor(self)
end

--注册监听事件
function DDZ_ProxyDelegate:registMsgs()
    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToEvent(id, ...)
        end)
        Log.i("DDZ_ProxyDelegate:registMsgs ", id)

        table.insert(self.m_listeners, nhandle)
    end

    addEvent(DDZGameEvent.REQCHANGEDESK)
    addEvent(DDZGameEvent.REQEXITROOM)
    addEvent(DDZGameEvent.REQSENDDEFCHAT)
    addEvent(DDZGameEvent.REQTUOGUAN)
        
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
function DDZ_ProxyDelegate:ListenToEvent(id, ... )
    Log.i("DDZ_ProxyDelegate:ListenToEvent id", id)
    if id == DDZGameEvent.REQCHANGEDESK then
        self:reqChangeDesk(...)
    elseif id == DDZGameEvent.REQEXITROOM then
        self:requestExitRoom()
    elseif id == DDZGameEvent.REQSENDDEFCHAT or id == PokerEventDef.GameEvent.REQSENDDEFCHAT then
        self:sendDefaultChat(...)
    elseif id == DDZGameEvent.REQTUOGUAN or id == PokerEventDef.GameEvent.GAME_REQ_TUOGUAN then
        self:requestTuoguan(...)
    -- elseif id == HallAPI.EventAPI.GAME_SOCKET_CLOSE then
    --     self:onNetWorkClosed()
    -- elseif id == HallAPI.EventAPI.GAME_ON_NETWORK_CONNECT_FAIL then
    --     self:onNetWorkConnectFail()

    elseif id == PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT then
        self:requestExitRoom()
    elseif id == PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT then
        self:sendSayMsg(...)
    elseif id == PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE then
        self:reqContinueGame()
    elseif id == HallAPI.EventAPI.START_GAME_COMPLETE then
        self:onStartGameComplete()
    elseif id == HallAPI.EventAPI.EXIT_GAME then
        self:requestExitRoom()
    elseif id == HallAPI.EventAPI.RESUME_GAME_REQUEST then
        self:onNetWorkReconnected()

    
    -- elseif id == DDZGameEvent. then
    -- elseif id == DDZGameEvent. then
        
    end
end

-- 函数功能：    解析服务器消息
-- 返回值：      无
-- eventdata:   封装过的消息体
function DDZ_ProxyDelegate:ReadServerStructInfor(eventdata)
    Log.i("DDZ_ProxyDelegate:ReadServerStructInfor eventdata.cmd", eventdata.cmd)
    --游戏开始
    if eventdata.cmd == DDZSocketCmd.CODE_REC_GAMESTART then
        self:onGameStart(eventdata.packetInfo)

    -- 叫地主
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_CALLLORD then
        self:onRecvCallLord(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 加倍
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_DOUBLE then
        self:onRecvDouble(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 抢地主
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_ROBLORD then
        self:onRecvCallRob(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 开始打牌
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_STARTPLAY then
        self:onRecvStartPlay(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 出牌
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_OUTCARD then
        self:onRecvOutCard(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    -- 单局游戏结束
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_GAMEOVER then
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
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
        
    --朋友房本次开放结束
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_TOTAL_GAME_OVER then
        self:onRecvTotalGameOver(eventdata.packetInfo)
        -- 下面的改到了ddzroom单局结算的地方去处理
        -- HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
        --HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)  

    -- 退出房间
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_ExitRoom then
        self:onRecvExitRoom(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    --重连
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_RECONNECT then
        self:onRecvReconnect(eventdata.packetInfo)
        HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)

    elseif eventdata.cmd == DDZSocketCmd.CODE_TUOGUAN then
        self:onRecvTuoGuan(eventdata.packetInfo)

    --聊天
    elseif eventdata.cmd == DDZSocketCmd.CODE_DEFAULT_CHAT then
        self:onRecvDefaultChat(eventdata.packetInfo)

    --房间信息
    elseif eventdata.cmd == DDZSocketCmd.CODE_RECV_FRIEND_ROOM_INFO then
        self:onRecvFriendRoomInfo(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_UPDATE_CASH then
        self:onUserMoneyUpdate(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_BROCAST then
        self:onRecvBrocast(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_DOLE_INFO then
        self:onRecvDole(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_POKERDIALOG then
        self:onRecvTips(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_USERDATA_POINT then
        self:onMoneyUpdate(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_ENTERROOM then
        self:onRecvEnterRoom(eventdata.packetInfo)

    --请求解散房间
    elseif eventdata.cmd == DDZSocketCmd.CODE_FRIEND_ROOM_LEAVE then
        self:onRecvReqDismiss(eventdata.packetInfo)

    --解散房间结果
    elseif eventdata.cmd == DDZSocketCmd.CODE_RECV_FRIEND_ROOM_END then
        DataMgr:getInstance():setDisMissFlag(false)
        self:onRecvDismissRes(eventdata.packetInfo)

    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_CONTINUE then
        self:onRecvFriendContinue(eventdata.packetInfo)

    --收到语音消息
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_SAY_CHAT then
        self:onRecvSayChat(eventdata.packetInfo)

    -- 更新玩家定位信息
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_LOCATION then
        self:onLocationUpdate(eventdata.packetInfo)

    -- 收到服务器下发的重连消息
    elseif eventdata.cmd == DDZSocketCmd.CODE_REC_RESUMEGAME then
        self:onRoomResume(eventdata.packetInfo)

    end

end

-- 函数功能：    游戏开始
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onGameStart(packetInfo)
    Log.i("DDZ_ProxyDelegate:onGameStart", packetInfo)
    if packetInfo.bo then
        for k, v in pairs(packetInfo.bo) do
            if v ~= -1 then
                packetInfo.bo[k] = DDZCard.ConvertToLocal(v);
            end
        end
    end

    if VideotapeManager.getInstance():isPlayingVideo() then
        for k, v in pairs(packetInfo.plI1) do
            v.ca0 = {}
            local videoPlayerInfo = kPlaybackInfo:getStartGameContentByid(v.plI)
            for k1,v1 in ipairs(videoPlayerInfo.plI1) do
                if v1.plI == v.plI then
                    for k2,v2 in pairs(v1.ca0) do
                        v.ca0[k2] = DDZCard.ConvertToLocal(v2); 
                    end
                end

            end
            Log.i("--wangzhi--替换完牌后--",v.ca0)
        end
    else
        for k, v in pairs(packetInfo.plI1) do
            if v.ca0 then
                for k1, v1 in pairs(v.ca0) do
                    if v1 ~= -1 then
                        v.ca0[k1] = DDZCard.ConvertToLocal(v1);
                    end
                end
            end
        end
    end

    packetInfo = checktable(packetInfo);

    if packetInfo and packetInfo.wanfa then
        DataMgr:getInstance():setWanfaData(packetInfo.wanfa)
    end 
    
    Log.i("DDZ_ProxyDelegate DataMgrKey_GAMEID 1", packetInfo.gaI)

    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEID, packetInfo.gaI);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.loI);
    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LIMITTIME, DDZConst.DEFOPETIME);
    else
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LIMITTIME, packetInfo.plTO or DDZConst.DEFOPETIME);
    end
    
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BOTTOMCADS, packetInfo.bo);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE, packetInfo.inD);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, packetInfo.st);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_TUOGUANSTATE, DDZConst.TUOGUAN_STATE_0)

    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTOUTCARDS, {});
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTYPE, DDZCard.CT_ERROR);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTIPS, {});
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTKEYCARDS, nil);

    local bujiaoNum = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_BUJIAONUM)
    if bujiaoNum and bujiaoNum == 3 then
        PokerToast.getInstance():show("3人都不叫地主，重新发牌");
        local nocall = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_NOCALLTURN);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_NOCALLTURN, nocall + 1);
    end
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BUJIAONUM, 0)
    self:initPlayer(packetInfo.plI1);
    self:setPlayerMutiple(packetInfo.prB)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTOUTSEAT, DDZConst.SEAT_NONE)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONGAMESTART, packetInfo.plI1, packetInfo.fiPUID)
    DataMgr:getInstance():SetPlayerScore()
end

-------------------------------------------------------
-- @desc 判断玩家seat是否合法
-------------------------------------------------------
function DDZ_ProxyDelegate:isLegalSeat(seat)
    if seat and seat >= 1 and seat <= DDZConst.PLAYER_NUM then
        return true;
    end
    return false;
end

-------------------------------------------------------
-- @desc 根据玩家userid获取玩家位置
-- @pram playerId 玩家id
-------------------------------------------------------
function DDZ_ProxyDelegate:getSeatByPlayerId(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.USERID) == playerId then
            return v:getProp(DDZDefine.SITE)
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
function DDZ_ProxyDelegate:initPlayer(playerInfos)
    Log.i("--wangzhi--获取玩家的经纬度--")
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
            seat = seat + DDZConst.PLAYER_NUM;
        end

        local player = PlayerModel:new()
        player:setProp(DDZDefine.USERID, v.plI)
        player:setProp(DDZDefine.NAME, v.plN)
        player:setProp(DDZDefine.SEX, v.se == DDZConst.FEMALE and DDZConst.MALE or DDZConst.FEMALE)
        player:setProp(DDZDefine.MONEY, v.fo)
        player:setProp(DDZDefine.ICON_ID, v.heU)
        player:setProp(DDZDefine.CARD_NUM, #v.ca0)
        player:setProp(DDZDefine.HAND_CARDS, v.ca0)
        player:setProp(DDZDefine.JING_DU,v.jiD)
        player:setProp(DDZDefine.WEI_DU,v.weD)
        player:setProp(DDZDefine.IP,v.ipA)
        player:setProp(DDZDefine.SITE, seat)
        player:setProp(DDZDefine.LEVEL, v.le)
        player:setProp(DDZDefine.HASTUOGUAN, v.isM or DDZConst.TUOGUAN_STATE_0)


        table.insert(playerList, player)
        Log.i("--wangzhi--获取玩家的经纬度--",v.jiD,v.weD)
    end

    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_PLAYERLIST, playerList);
end

--函数功能： 刷新玩家倍数
--返回值：   玩家倍数
--info:      玩家倍数
function DDZ_ProxyDelegate:setPlayerMutiple(info)
    if not info then
        return nil 
    end
    DataMgr:getInstance():setPlayerMultiple(info)
end


--函数功能： 进入房间
--返回值： 无
--packetInfo: 封装进入房间的消息
function DDZ_ProxyDelegate:onRecvEnterRoom(packetInfo)
    Log.i("DDZ_ProxyDelegate enterRoom:",packetInfo)
    
    local roomInfo =  HallAPI.DataAPI:getRoomInfoById(packetInfo.gaI, packetInfo.roI);

    if roomInfo then
        local roomid = HallAPI.DataAPI:getRoomId()
        --重新设置房间类型
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_ROOMID, roomid)
        --重新设置房间底数
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BASEROOM, roomInfo.an)
    end
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVENTERROOM)
end

-- 函数功能：    叫地主
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvCallLord(packetInfo)
    Log.i("DDZ_ProxyDelegate:onRecvCallLord", packetInfo)
    if packetInfo.ca then
        for k, v in pairs(packetInfo.ca) do
            if v ~= -1 then
                packetInfo.ca[k] = DDZCard.ConvertToLocal(v);
            end
        end
    end

    --叫地主
    if packetInfo.fl == 1 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.usI);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_ROB);
    else
        local bujiao = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_BUJIAONUM)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BUJIAONUM, bujiao + 1);
    end

    --已确定地主
    if packetInfo.fl0 == 1 then
        Log.i("--wangzhi--可以确定设定地主--")
        -- DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.usI);
        DataMgr:getInstance():setSureLordFlag()
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_NOCALLTURN, 0);
        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BOTTOMCADS, packetInfo.ca)        
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(lordId)
        -- Log.i("PlayerModel before", PlayerModel)
        if lordId == HallAPI.DataAPI:getUserId() then
            PlayerModel:addCards(packetInfo.ca)    
        else
            --如果不是地主则设置为-1
            local tb = {}
            for i = 1, #packetInfo.ca do
                table.insert(tb, -1)
            end
            PlayerModel:addCards(tb)
        end
        local PlayerModel1 = DataMgr:getInstance():getPlayerInfo(lordId)
        -- Log.i("PlayerModel after", PlayerModel1)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_DOUBLE);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_OPERATESEATID, -1);
    end

    self:setPlayerMutiple(packetInfo.prB)

    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONCALLLORD, packetInfo)

end

-- 函数开局:  获取玩家信息
-- 参数: playerId:玩家id
function DDZ_ProxyDelegate:getPlayerInfo(playerId)
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        Log.i("v:getProp(DDZDefine.USERID)", v:getProp(DDZDefine.USERID))
        if v:getProp(DDZDefine.USERID) == playerId then
            return v
        end
    end
end

-- 函数功能：    加倍
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvDouble(packetInfo)
    Log.i("DDZ_ProxyDelegate:onRecvDouble",packetInfo)

    local totalCount = 0
    -- if packetInfo.prB then
    --     for k,v in pairs(packetInfo.prB) do
    --         totalCount = totalCount + v
    --     end
    --     for k,v in pairs(packetInfo.prB) do
    --         if v == totalCount/2 then
    --             -- 按照最多倍数的人确认地主
    --             Log.i("--wangzhi--根据倍数确定地主--",k)
    --             Log.i("--wangzhi--根据倍数确定地主--",type(k))
    --             DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, tonumber(k));
    --         end
    --     end
    -- end

    -- DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.usI);
    packetInfo = checktable(packetInfo);
    if packetInfo.cuD > 1 then
        local multi = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_MUTIPLE)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE, multi * packetInfo.cuD);
    end

    if packetInfo.usI == HallAPI.DataAPI:getUserId() then
       DataMgr:getInstance():setObject( DDZDataConst.DataMgrKey_DOUBLESTATUS, packetInfo.cuD)
    end

    self:setPlayerMutiple(packetInfo.prB)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONDOUBLE, packetInfo)
end

-- 函数功能：    抢地主
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvCallRob(packetInfo)
    Log.i("DDZ_ProxyDelegate:onRecvCallRob",packetInfo)
    packetInfo = checktable(packetInfo);
    if packetInfo.ca then
        for k, v in pairs(packetInfo.ca) do
            if v ~= -1 then
                packetInfo.ca[k] = DDZCard.ConvertToLocal(v);
            end
        end
    end

    if packetInfo.fl == 1 then
        local multi = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_MUTIPLE)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE, multi * 2);
    end

    if packetInfo.fl == 1 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.usI);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_ROB);
    else
        local bujiao = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_BUJIAONUM)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BUJIAONUM, bujiao + 1);
    end
    if packetInfo.fl0 == 1 then
        -- DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.usI);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_NOCALLTURN, 0);
        local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        DataMgr:getInstance():setSureLordFlag()
        -- local totalCount = 0
        -- local lordId = 0
        -- if packetInfo.prB then
        --     for k,v in pairs(packetInfo.prB) do
        --         totalCount = totalCount + v
        --     end
        --     for k,v in pairs(packetInfo.prB) do
        --         if v == totalCount/2 then
        --             -- 按照最多倍数的人确认地主
        --             Log.i("--wangzhi--根据倍数确定地主001--",k)
        --             Log.i("--wangzhi--根据倍数确定地主002--",type(k))
        --             DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, tonumber(k));
        --             lordId = tonumber(k)
        --         end
        --     end
        -- end
        -- local lordId = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LORDID)
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BOTTOMCADS, packetInfo.ca)
        local PlayerModel = DataMgr:getInstance():getPlayerInfo(lordId)
        -- Log.i("PlayerModel before", PlayerModel)
        Log.i("--wangzhi--地主的ID是--",lordId)
        if lordId == HallAPI.DataAPI:getUserId() then
            PlayerModel:addCards(packetInfo.ca)    
        else
            --如果不是地主则设置为-1
            local tb = {}
            for i = 1, #packetInfo.ca do
                table.insert(tb, -1)
            end
            PlayerModel:addCards(tb)
        end
        -- local PlayerModel1 = DataMgr:getInstance():getPlayerInfo(lordId)
        -- Log.i("PlayerModel after", PlayerModel1)

        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_DOUBLE);
    end

    self:setPlayerMutiple(packetInfo.prB)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONROBLORD, packetInfo) 
end

-- 函数功能：    开始打牌
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvStartPlay(packetInfo)
    Log.i("onRecvStartPlay",packetInfo)
    packetInfo = checktable(packetInfo)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_DEBUGSTATE, packetInfo.deb == 1)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_PLAY)

    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONSTRATPLAY, packetInfo)  
end

-- 函数功能：    出牌
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvOutCard(packetInfo, isReconnect)
    
    Log.i("onRecvOutCard",packetInfo,isReconnect)
    packetInfo = checktable(packetInfo);

    if packetInfo.plC and #packetInfo.plC  > 0 then
        for k, v in pairs(packetInfo.plC) do
            packetInfo.plC[k] = DDZCard.ConvertToLocal(v);
        end
    end

    ---重登对玩家打出的牌进行处理
    local putOutCards = {}
    if packetInfo.gplC and table.nums(packetInfo.gplC) > 0 then
        for k, v in pairs(packetInfo.gplC) do
            local info = {}
            info.userId = tonumber(k)
            local list_info = {}
            for key, value in pairs(v) do
                if value ~= 0 then
                    list_info[key] = DDZCard.ConvertToLocal(value)
                else
                    list_info[key] = value
                end
            end
            info.cards = list_info
            putOutCards[#putOutCards + 1] = info
        end
        packetInfo.gplC = putOutCards
    end
    

    local cards = packetInfo.plC or {};
    local cardValues = {};
    -- for k, v in pairs(cards) do
    --     local type, val = DDZCard.cardConvert(v);
    --     table.insert(cardValues, val);
    -- end
    Log.i("--wangzhi--根据牌值判断类型--",cardValues)
    if packetInfo.usI ~= HallAPI.DataAPI:getUserId() then
        DDZGUIZE.isSiteMy = false
    end
    local cardType, keyCard = DDZPKCardTypeAnalyzer.getCardType(cards);
    _,keyCard = DDZCard.cardConvert(keyCard)
    Log.i("DDZ_ProxyDelegate:onRecvOutCard cardType", cardType)
    Log.i("DDZ_ProxyDelegate:onRecvOutCard keyCard", keyCard)
    if cardType >= DDZCard.CT_BOMB then
        local multi = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_MUTIPLE)
        packetInfo.cuD = packetInfo.cuD or 2
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE , multi * packetInfo.cuD)
    end

    if packetInfo.usI == HallAPI.DataAPI:getUserId() then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTOUTCARDS, {});
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTYPE, DDZCard.CT_ERROR);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTIPS, {});
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTKEYCARDS, nil);
    else
        if cardType ~= DDZCard.CT_ERROR then
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTOUTCARDS, cards);
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTCARDTYPE, cardType);
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LASTKEYCARDS, keyCard);
        end
    end

    local player = DataMgr:getInstance():getPlayerInfo(packetInfo.usI)
    local isExist = DataMgr:getInstance():isPlayerExist(packetInfo.usI)
    Log.i("========fff====isExist==========ffffffffffffffffffff",isExist)
    if not isExist then
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONOUTCARD, packetInfo)  
        return 
    end

    -- Log.i("player before", player)
    if not isReconnect then
        if player:getProp(DDZDefine.USERID) == HallAPI.DataAPI:getUserId() then
            player:delCards(packetInfo.plC)    
        else
            --如果不是地主则设置为-1
            local tb = {}
            for i = 1, #packetInfo.plC do
                table.insert(tb, -1)
            end
            player:delCards(tb)
        end
    end
    if packetInfo.DprB and table.nums(packetInfo.DprB) > 0 then
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_SCORE_SETTLEMENT, packetInfo)  
        self:setPlayerMutiple(packetInfo.DprB)
    end
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONOUTCARD, packetInfo, isReconnect)  
end

-- 函数功能：    游戏结束
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvGameOver(packetInfo)
    Log.i("onRecvGameOver packetInfo",packetInfo)
    packetInfo = checktable(packetInfo);

    for k, v in pairs(packetInfo.plI1) do
        if v.ca then
            for k1, v1 in pairs(v.ca) do
                if v1 ~= -1 then
                    v.ca[k1] = DDZCard.ConvertToLocal(v1);
                end
            end
        end
    end
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_GAMEOVER)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_TUOGUANSTATE, DDZConst.TUOGUAN_STATE_0)
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_DEBUGSTATE, false)

    -- for k, v in pairs(packetInfo.plI1) do
    --    local PlayerModel = DataMgr:getInstance():getPlayerInfo(v.plI)
    --    local seat = PlayerModel:getProp(DDZDefine.SITE)
    --    PlayerModel:setProp(DDZDefine.MONEY, v.fo, true, seat)
    -- end
   
    local multi = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_MUTIPLE)
    Log.i("multi is:", multi)
    if packetInfo.sp == 2 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE , multi * 2)
    elseif packetInfo.anS == 2 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE , multi * 2)
    end

    -- 增加牌局记录
    if packetInfo and packetInfo.AGR then
        -- DataMgr:getInstance():setMatchRecord(packetInfo.AGR)
        local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()
        table.insert(matchTotalInfo,packetInfo.AGR)
        DataMgr:getInstance():setMatchTotalRecord(matchTotalInfo)
    end 
 
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.GAMEOVER, packetInfo) 
end

---------------------------------------------------------
-- @desc 游戏总结算
-- @pram packetInfo:收到的网络消息
---------------------------------------------------------
function DDZ_ProxyDelegate:onRecvTotalGameOver(packetInfo)
    Log.i("DDZ_ProxyDelegate onRecvTotalGameOver:",packetInfo)
    packetInfo = checktable(packetInfo)
    Log.i("设置牌局结束的状态:")
    HallAPI.DataAPI:setGameEnd(true) --需要添加API
    --缓存总结算消息
    local tmpData = {}
    tmpData.param = packetInfo
    DataMgr.getInstance():setObject(DDZDataConst.DataMgrKey_FRIENDTOTALDATA, tmpData)
    -- HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVTOTALGAMEOVER, packetInfo)
end


-- 游戏托管
-- packetInfo:网络消息
function DDZ_ProxyDelegate:onRecvTuoGuan(packetInfo)
    Log.i("onRecvTuoGuan packetInfo", packetInfo)
    if packetInfo.maPI == HallAPI.DataAPI:getUserId() then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_TUOGUANSTATE, packetInfo.isM)
    end

    local isExist = DataMgr:getInstance():isPlayerExist(packetInfo.maPI)
    if isExist then
        local player = DataMgr:getInstance():getPlayerInfo(packetInfo.maPI)
        local seat = player:getProp(DDZDefine.SITE)
        player:setProp( DDZDefine.HASTUOGUAN, packetInfo.isM)
    end

    --## 托管玩家id maPI
    --## 是否被托管 isM
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONTUOGUAN, packetInfo)
end
----------------------------------------------------------
-- @desc 重连成功
-- @pram packetInfo 玩家重连后收到的牌局数据
----------------------------------------------------------
function DDZ_ProxyDelegate:onRecvReconnect(packetInfo)
    Log.i("重连成功=================onRecvReconnect packetInfo", packetInfo)
    packetInfo = checktable(packetInfo);
    DataMgr:getInstance():SetPlayerScore()
    --扑克玩法数据
    if packetInfo and packetInfo.wfS then
        DataMgr:getInstance():setWanfaData(packetInfo.wfS)
    end

    --跑得快战绩数据
    if packetInfo and packetInfo.LiAGR then
        DataMgr:getInstance():setMatchTotalRecord(packetInfo.LiAGR)
    end

    if packetInfo.bo then
        for k, v in pairs(packetInfo.bo) do
            if v ~= -1 then
                packetInfo.bo[k] = DDZCard.ConvertToLocal(v);
            end
        end
    end
    
    for k, v in pairs(packetInfo.plI1) do
        if v.ca0 then
            for k1, v1 in pairs(v.ca0) do
                if v1 ~= -1 then
                    v.ca0[k1] = DDZCard.ConvertToLocal(v1);
                end
            end
        end
    end

    DataMgr:getInstance():init()
    Log.i("DDZRoom DataMgrKey_GAMEID 3", packetInfo.gaI)
    
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEID, packetInfo.gaI);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMEPLAYID, packetInfo.gaPI);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_OPERATESEATID, packetInfo.fiPUID);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.loI);

    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LIMITTIME, packetInfo.plTO);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_BOTTOMCADS, packetInfo.bo);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_MUTIPLE, packetInfo.inD);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, packetInfo.st);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_TUOGUANSTATE, DDZConst.TUOGUAN_STATE_0);
    DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LEFTTIME, packetInfo.wt);

   

    --取消托管
    -- self:requestTuoguan(DDZConst.TUOGUAN_STATE_0)
    -- local multi = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_MUTIPLE)
    self:initPlayer(packetInfo.plI1);
    self:setPlayerMutiple(packetInfo.prB)

    if packetInfo.loI and packetInfo.loI > 0 then
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LORDID, packetInfo.loI);
        -- 断线重连设置确认地主没
        Log.i("--wangzhi--断线重连地主确认没--")
        if packetInfo.st >=5 then
            DataMgr:getInstance():setSureLordFlag()
        end
    end

    local info = {};
    info.usI = packetInfo.prPI;
    info.neP = packetInfo.fiPUID;
    info.gplC = packetInfo.gplC;


    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECONNECT, packetInfo)


    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    Log.i("gameStatus is ",gameStatus)
    if gameStatus == DDZConst.STATUS_PLAY or gameStatus == DDZConst.STATUS_ROB then
        info.usI = packetInfo.prPI;
        info.neP = packetInfo.fiPUID;
        info.fl = 0;
        if packetInfo.prC and #packetInfo.prC > 0 then
            info.fl = 1;
        end
        info.plC = packetInfo.prC;
        --if info.usI ~= 0 then
        self:onRecvOutCard(info, true);
        --end

    ---加倍阶段
    elseif gameStatus == DDZConst.STATUS_DOUBLE then
        for k, v in pairs(packetInfo.plI1) do
            if v.plI == HallAPI.DataAPI:getUserId() then
                DataMgr:getInstance():setObject( DDZDataConst.DataMgrKey_DOUBLESTATUS, v.cuD)
            end
        end
    end

    if packetInfo.prB and table.nums(packetInfo.prB) > 0 then
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_SCORE_SETTLEMENT, packetInfo,true)  
        self:setPlayerMutiple(packetInfo.prB)
    end
end

-- 函数功能：    退出房间
-- 返回值：      无
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvExitRoom(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONEXITROOM, packetInfo)
end

--请求解散房间
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvReqDismiss(packetInfo)
    Log.i("--wangzhi--分发解散消息--")
    local ddzRoomLoaded = PokerUIManager.getInstance():getWnd(DDZRoom);
    if ddzRoomLoaded == nil then
        scheduler.performWithDelayGlobal(function()
              HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVREQDISSMISS, packetInfo)  
        end, 0.6);
    else
        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVREQDISSMISS, packetInfo)
    end
end

--解散房间结果
-- packetInfo:  封装过的消息内容
function DDZ_ProxyDelegate:onRecvDismissRes(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVDISSMISSEND, packetInfo)
end

-----------------------------------------
-- 函数功能：    朋友房续局
-- 返回值：      无
-----------------------------------------
function DDZ_ProxyDelegate:onRecvFriendContinue(packetInfo)
    Log.i("DDZ_ProxyDelegate onRecvFriendContinue:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONRECVFRIENDCONTINUE,packetInfo)
end

-----------------------------------------
-- 函数功能：    语音聊天
-- 返回值：      无
-----------------------------------------
function DDZ_ProxyDelegate:onRecvSayChat(packetInfo)
    Log.i("DDZ_ProxyDelegate onRecvSayChat:",packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.RESAYCHAT, packetInfo)
end


--更新玩家金豆
function DDZ_ProxyDelegate:onUserMoneyUpdate(packetInfo)
    Log.i("DDZ_ProxyDelegate:onUserMoneyUpdate", packetInfo)
    local userId = packetInfo.usI
    local money = packetInfo.ca
    local PlayerModel = DataMgr:getInstance():getPlayerInfo(userId)
    local seat = PlayerModel:getProp(DDZDefine.SITE)
    PlayerModel:setProp(DDZDefine.MONEY, money, true, seat)
end

--接受朋友房信息
function DDZ_ProxyDelegate:onRecvFriendRoomInfo(packetInfo)
    Log.i("DDZ_ProxyDelegate:onRecvFriendRoomInfo", packetInfo)
    HallAPI.DataAPI:setRoomInfo(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONLINE, packetInfo)
end 


--收到后台提示
function DDZ_ProxyDelegate:onRecvTips(packetInfo)
    Log.i("DDZ_ProxyDelegate:onRecvTips",packetInfo)
    PokerToast.getInstance():show(packetInfo.text)
end


--更新玩家金豆
function DDZ_ProxyDelegate:onMoneyUpdate(packetInfo)
    -- Log.i("DDZ_ProxyDelegate:onMoneyUpdate", packetInfo)
    -- for k,v in pairs(packetInfo) do
    --     local userId = tonumber(v.keyID)
    --     local money = tonumber(v.takenCash)
    --     local player = DataMgr:getInstance():getPlayerInfo(userId)
    --     local seat = player:getProp(DDZDefine.SITE)
    --     PlayerModel:setProp(DDZDefine.MONEY, money, true, seat)
    -- end
end

--收到广播?
function DDZ_ProxyDelegate:onRecvBrocast(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.RECVBROCAST, packetInfo)
end

-- 网络重连成功
function DDZ_ProxyDelegate:onNetWorkReconnected()
    Log.i("------Classical:onNetWorkReconnected");
    self.super:onNetWorkReconnected()
    scheduler.performWithDelayGlobal(function()
        -- LoadingView.getInstance():hide();
        local data = {};
        data.plI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
        --HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_RESUMEGAME, data);
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_RESUME_GAME,data.plI)
    end, 1);
    
end

-- 网络关闭 数据暂无处理
function DDZ_ProxyDelegate:onNetWorkClosed(...)
    self.super:onNetWorkClosed(...)
end

-- 网络连通失败  数据暂无处理
function DDZ_ProxyDelegate:onNetWorkConnectFail()
    self.super:onNetWorkConnectFail()
end

--续局，换桌结果
function DDZ_ProxyDelegate:repGameStart(packetInfo)
    Log.i("Classical:repGameStart", packetInfo);
--[[
    local desc = nil;
    if (packetInfo.ty == 1 or packetInfo.ty == 2) then
        if packetInfo.re == 1 then
            DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_GAMESTATUS, DDZConst.STATUS_NONE);
            -- DDZGameManager.getInstance():setStatus(DDZConst.STATUS_NONE);
            PokerUIManager.getInstance():popToWnd(DDZRoom);
            self:clearDesk();
        elseif packetInfo.re == 3 then
            desc = "您的金豆太多了，请选择其他房间进行游戏！";
        elseif packetInfo.re == 4 then
            desc = "您的金豆不足，请选择其他房间进行游戏！";
        end
        if desc then
            local data = {};
            data.type = 1;
            data.title = "提示";
            data.content = desc;
            data.closeTitle = "退出游戏";
            data.closeCallback = function ( ... )
                self:requestExitRoom();
            end
            data.canKeyBack = false;
            PokerUIManager.getInstance():pushWnd(CommonDialog, data);
        end
    end
]]
end

--请求换桌
function DDZ_ProxyDelegate:reqChangeDesk()

    HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,2);
end

--续局
function DDZ_ProxyDelegate:reqContinueGame()
    Log.i("DDZ_ProxyDelegate:reqContinueGame ")

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        ---[[
        local data = {};
        -- data.gaI = DDZGameManager.getInstance():getGameId();
        data.opS = 2
        data.gaI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEID)
        data.plT = 1;
        data.roI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_ROOMID)
        data.ty = 1;-- 1 续局 2 换桌
        HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_GAMESTART, data)

        HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UIREQCONTINUE, isReq)
        --]]
    else
        --请求续局,交由大厅统一处理
        HallAPI.EventAPI:dispatchEvent(HallAPI.EventAPI.START_GAME,1);
    end
end

--开始游戏完成
function DDZ_ProxyDelegate:onStartGameComplete()
    Log.i("DDZ_ProxyDelegate:onStartGameComplete")
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UIREQCONTINUE, true)
end

--朋友开房续局
function DDZ_ProxyDelegate:friendRoomRequestContinueGame()
    --朋友开房逻辑特殊处理,如果当前游戏是从朋友开房进入的,完成一局游戏,游戏局数加1
    self:playBgMusic();
    Log.i("朋友开房游戏中点击继续按钮..............")
    self.m_friendOpenRoom:onContinueButton()

    if DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS) > DDZConst.STATUS_NONE or DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS) == DDZConst.STATUS_GAMEOVER then
       self:clearDesk();
    end

    if self.m_topBarView then
        self.m_topBarView:setRoomjushu()
    end
end

--发送语音消息
function DDZ_ProxyDelegate:sendSayMsg(tmpData)
    Log.i("私有房聊天消息:",tmpData)
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_REC_SAY_CHAT,tmpData);
end

--退出房间
function DDZ_ProxyDelegate:requestExitRoom()
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_ExitRoom, {});
    -- LoadingView.getInstance():show("正在退出游戏，请稍后...")
end

--------------------------------------------
-- @desc 托管
-- @pram tuoguanState：  1托管   0取消托管  
--------------------------------------------    
function DDZ_ProxyDelegate:requestTuoguan(tuoguanState)
    Log.i("DDZ_ProxyDelegate:requestTuoguan", tuoguanState)
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS);
    if gameStatus == DDZConst.STATUS_NONE or gameStatus == DDZConst.STATUS_GAMEOVER then
        Log.i("quxiaotuoguan filed!!!",gameStatus)
        return;
    end
    local isM = tuoguanState or DDZConst.TUOGUAN_STATE_0;
    local data = {};
    data.maPI = HallAPI.DataAPI:getUserId();
    data.isM = isM;
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_TUOGUAN, data);
end

--发送内置聊天短语和表情
function DDZ_ProxyDelegate:sendDefaultChat(type, index)
    Log.i("--wangzhi--发送消息的类型--",type)
    local data = {};
    data.gaPI = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
    data.usI = HallAPI.DataAPI:getUserId();
    data.ty = type;
    data.emI = index;
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_DEFAULT_CHAT, data);
end

--内置聊天
function DDZ_ProxyDelegate:onRecvDefaultChat(packetInfo)
    HallAPI.EventAPI:dispatchEvent(DDZGameEvent.ONUSERDEFCHAT, packetInfo)
end

--更新玩家经纬度数据
function DDZ_ProxyDelegate:onLocationUpdate(packetInfo)
    local playerId = packetInfo.usI
    local player = DataMgr:getInstance():getPlayerInfo(playerId)
    if player ~= nil then
        player:refreshLocationInfo(packetInfo)
    end
end

--收到服务器下发的重连消息
function DDZ_ProxyDelegate:onRoomResume(packetInfo)
    if packetInfo.re == 1 then
        -- Toast.getInstance():show("重连成功");
    else
        local ddzRoomLoaded = PokerUIManager.getInstance():getWnd(DDZRoom)
        PokerUIManager.getInstance():popAllWnd(true)
        ddzRoomLoaded:onExitRoom()

        -- 返回大厅后弹对局结束提示
        scheduler.performWithDelayGlobal(function()
                Toast.getInstance():show("对局已结束")
            end, 0.5)
    end
end
return DDZ_ProxyDelegate