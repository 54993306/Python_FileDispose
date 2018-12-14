--游戏基类
OpenRoomGame = class("OpenRoomGame",UIWndBase)

--构造函数
function OpenRoomGame:ctor(...)
    self.super.ctor(self, "hall/null_layer.csb", ...);
    
	self.m_data = ...
	self.m_delegate = self.m_data.m_delegate
	self.roomGameType = self.m_data.roomGameType
	
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)

    self.m_socketInfo = nil;

    self.m_maintainCode = "009" -- 维护提示框代码

    -- (不用改) 网络重连框重连回调
    -- 网络重连框退出回调
    self.m_netDialogCloseCallback = function ()
        Log.i("OpenRoomGame.m_netDialogCloseCallback")
        MjMediator:getInstance():exitGame();
    end
    -- 网络退出框退出回调
    self.m_netDialogCancalCallback = self.m_netDialogCloseCallback

    self.handlers = {}
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_START_FINISH_NTF, 
        handler(self, self.onGameStartFinish)))

    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_RESUME_FINISH_NTF, 
        handler(self, self.onGameResumeFinish)))
end

--析构函数
function OpenRoomGame:dtor()
	if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
		self.m_timerProxy:removeTimer("continue_duration_timer")
		self.m_timerProxy=nil
    end
    if self.m_socketProcesser then
       SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
       self.m_socketProcesser = nil;
    end
	kFriendRoomInfo:clearData()

    -- (由于OpenRoomGame:dtor是在MjGameScene:onExit中被调用, 晚于MjMediator:exitGame, 所以需要在调用MjMediator:exitGame之前移除监听)
end

function OpenRoomGame:exitGame()
    Log.d("OpenRoomGame:exitGame()")
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end

--游戏初始化
function OpenRoomGame:init()
	Log.i("OpenRoomGame:init")
end

-- 网络关闭
function OpenRoomGame:onNetWorkClosed(event)
    Log.i("------OpenRoomGame:onNetWorkClosed")
    -- dump(event)
    self:showNetWorkClosedNotify("网络异常，请检查您的网络是否正常再进入游戏！代码-010", kLoginInfo:isServerMaintain(), event._forceReturnToLogin)
end

--查看总战绩
function OpenRoomGame:gameOverUICallBack(isMaintain)
    Log.i("OpenRoomGame:gameOverUICallBack", isMaintain)
    if self.m_socketInfo == nil then
        -- if isMaintain then
        --     if not UIManager.getInstance():getWnd(HallLogin) then
        --         UIManager.getInstance():recoverToDesignOrient();
        --         local info = {};
        --         info.isExit = true;
        --         UIManager.getInstance():replaceWnd(HallLogin, info);
        --     end
        -- else
            self:closeRoom();
        -- end
    else
        self.m_socketInfo.isMaintain = isMaintain
        self:OnRecvRoomReWard(self.m_socketInfo.param)
        self.m_socketInfo = nil;
    end
end

--总战绩
function OpenRoomGame:recvRoomReWard(packetInfo)
    Log.i("OpenRoomGame:recvRoomReWard", packetInfo)
    kFriendRoomInfo:setGameEnd(true)
    --缓存总结算消息
	local tmpData = {}
	tmpData.param = packetInfo
    self.m_socketInfo = tmpData
end

--处理总战绩
function OpenRoomGame:OnRecvRoomReWard(packetInfo)
    UIManager.getInstance():popWnd(OpenRoomGame)
	UIManager.getInstance():pushWnd(FriendTotalOverView, packetInfo);
end

--房间关闭
function OpenRoomGame:recvRoomEnd(packetInfo)
    Log.i("OpenRoomGame:recvRoomEnd")
    local dismissDeskView = UIManager.getInstance():getWnd(DismissDeskView);
    if dismissDeskView ~= nil then
        UIManager.getInstance():popWnd(DismissDeskView);
    end

    if self.m_isShowGameOverUI then--如果已经显示结算UI
		--self:onRecvRoomEnd(packetInfo)
    else
        --[[
         0.GameOver("游戏结束"),
         1.OwnerClose("房主已关闭房间"),
         2.VoteTimeOut("牌局投票解散时间到"),
         3.VoteClose("牌局投票解散所有人同意"),
         4.RoomTimeOut("游戏时间已到"),
         6.ApiKill("api解散"),
         7.Shutdown("关服前解散房间");
        ]]
        if packetInfo.ty ~= 0 then
            self:onRecvRoomEnd(packetInfo);
        end
    end
end

--处理房间关闭
function OpenRoomGame:onRecvRoomEnd(packetInfo)
    Log.i("OpenRoomGame:onRecvRoomEnd")
	local data = {}
	data.type = 1;
	data.title = "提示";
	data.content = packetInfo.ti;
    data.canKeyBack = false;
	data.closeCallback = function ()
        self:gameOverUICallBack(packetInfo.ty == 7);
	end
    if packetInfo.ty == 7 then
        data.contentType = COMNONDIALOG_TYPE_NETWORK
        scheduler.performWithDelayGlobal(function()
            SocketManager.getInstance():closeSocket();
            end, 0.1)
        local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
        if commonDialog then
            UIManager.getInstance():popWnd(CommonDialog);
        end
    end
	UIManager.getInstance():pushWnd(CommonDialog, data) 
end


--关闭房间
function OpenRoomGame:closeRoom(tmpData)
	MjMediator:getInstance():exitGame();
end

function OpenRoomGame:recvFriendRoomStartGame(packetInfo)
    LoadingView.getInstance():hide();
    self.m_isShowGameOverUI = false;
end

--玩家解散
function OpenRoomGame:recvFriendRoomLeaveGame(packetInfo)
    local dismissDeskView = UIManager.getInstance():getWnd(DismissDeskView);
    if dismissDeskView == nil then
        dismissDeskView = UIManager:getInstance():pushWnd(DismissDeskView, nil, 100, self)
	end
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    local dismissDeskViewLocalZOrder
    if commonDialog ~=nil then
        dismissDeskViewLocalZOrder = commonDialog.m_pBaseNode:getLocalZOrder()
        UIManager.getInstance():popWnd(commonDialog)
    else
        dismissDeskViewLocalZOrder = dismissDeskView.m_pBaseNode:getLocalZOrder()
    end
    dismissDeskView.m_pBaseNode:setLocalZOrder(dismissDeskViewLocalZOrder+1)
    dismissDeskView:updateUI(packetInfo)
end

--聊天
function OpenRoomGame:recvSayMsg(packetInfo)
    Log.i("------recvSayMsg", packetInfo);
    if packetInfo.ty == 1 then
        --语音聊天
        local status = kSettingInfo:getPlayerVoiceStatus()
        if status and packetInfo.usI ~= kUserInfo:getUserId() then
        else
            MjMediator:getInstance():on_speaking(packetInfo);          
        end
    else
		local status = kSettingInfo:getGameVoiceStatus()
		if status then
		  return;
		end
    end
    return true
end	

function OpenRoomGame:hideNetworkLoadingView()
    LoadingView.getInstance():hide("networkState")
    self.isConnectException = false
end

-- 网络重连成功
function OpenRoomGame:onNetWorkReconnected()
    Log.d("------OpenRoomGame:onNetWorkReconnected");
    LoadingView.getInstance():hide();
    if kFriendRoomInfo:isGameEnd() then
        self:hideNetworkLoadingView()
    end
	--游戏重连逻辑
	MjMediator:getInstance():onNetWorkReconnected();
end

function OpenRoomGame:onGameStartFinish()
    Log.d("------OpenRoomGame:onGameStartFinish");
    self:hideNetworkLoadingView()
end

function OpenRoomGame:onGameResumeFinish()
    Log.d("------OpenRoomGame:onGameResumeFinish");
    self:hideNetworkLoadingView()
end

-- 网络连通异常
function OpenRoomGame:onNetWorkConnectException()
    Log.d("------OpenRoomGame:onNetWorkConnectException");
    LoadingView.getInstance():show("网络异常，正在重连...",1000, true, "networkState");
    self.isConnectException = true
end

function OpenRoomGame:onNetWorkConnectHealthly()
    -- Log.i("------OpenRoomGame:onNetWorkConnectHealthly");
    if not self.isConnectException or kFriendRoomInfo:isGameEnd() then
        self:hideNetworkLoadingView()
    end
end

-- 网络连通失败
function OpenRoomGame:onNetWorkConnectFail()
    Log.d("------OpenRoomGame:onNetWorkConnectFail")
    self:showNetWorkClosedNotify("服务器连接失败，请检查您的网络或稍后尝试")
end

OpenRoomGame.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = OpenRoomGame.recvRoomQuit; --InviteRoomEnter	 退出邀请房结果
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_REWARD] = OpenRoomGame.recvRoomReWard; 	--InviteRoomRankAward	 邀请房排行奖励
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_END] = OpenRoomGame.recvRoomEnd; 	--InviteRoomEnd	 邀请房结束
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = OpenRoomGame.recvFriendRoomStartGame; --邀请房对局开始
	[HallSocketCmd.CODE_FRIEND_ROOM_LEAVE] = OpenRoomGame.recvFriendRoomLeaveGame;--解散桌子信息
    [HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = OpenRoomGame.recvSayMsg; --私有房聊天
};
