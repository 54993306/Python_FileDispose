HallSocketProcesser = class("HallSocketProcesser", SocketProcesser)

function HallSocketProcesser:repServerInfo(cmd, packetInfo)
    Log.i("HallSocketProcesser:repServerInfo..",packetInfo)
    packetInfo = checktable(packetInfo);
    kServerInfo:setData(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
    kUserData_userExtInfo:setDiamoundWechatID()
end

function HallSocketProcesser:clearUserData()
    kUserData_userInfo:release();
    kUserData_userExtInfo:release();
    kUserData_userPointInfo:release();
    kGiftData_logicInfo:release();
    kSystemConfig:release()
    kServerInfo:setAdTxt(nil)
end

function HallSocketProcesser:repLogin(cmd, packetInfo)
    -- self:clearUserData();

    packetInfo = checktable(packetInfo);
    kUserInfo.releaseInstance();
    kUserInfo = UserInfo.getInstance();
    kUserInfo:setUserId(packetInfo.usI);
    kUserInfo:setUserToken(packetInfo.to)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo1(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    kUserInfo:setActivityPub(packetInfo.content[1].pub)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo2(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repUserInfo3(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repGameStart(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repChargeList(cmd, packetInfo)
    info = checktable(packetInfo);
    kChargeListInfo:setChargeList(info.reL); 
end

function HallSocketProcesser:repResumeGame(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repBrocast(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repAdTxt(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repSystemConfig(cmd, packetInfo)
    info = checktable(packetInfo);
    kSystemConfig:setSystemConfigList(info.li);
end

--type = 2,code=20012, 邀请房列表请求
function HallSocketProcesser.sendRoomConfig(tmpData)
   tmpData.gaI = kFriendRoomInfo:getGameID()
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_FRIEND_ROOM_CONFIG,tmpData);
end

--type = 2,code=20013, 邀请房配置
--Config
--##    Id  int
--##    gaI  int  游戏ID
--##    roS  int  排行对局数
--##    roS0  int  总对局数
--##    exT  int  过期时间，单位分钟
--##    aw  String  排行发奖
--##    plS  int  游戏人数
--##    inS  int  初始积分
--##    an  int  底注
--##    roFT  int  房费类型（填入物品ID，可以是金豆和元宝，开钻石）
--##    roF  int  房费数量
--##  inRC:[Config]  inRC  List<Config>
function HallSocketProcesser:recvRoomConfig(cmd, packetInfo)
   packetInfo = checktable(packetInfo);
   kFriendRoomInfo:setAreaBaseInfo(packetInfo)
   self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:recvFriendRoomStartGame(cmd, packetInfo)
    Log.i("......接收邀请房开始对局消息.........")
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function HallSocketProcesser:recvRoomSceneInfo(cmd, packetInfo)
    Log.i("HallSocketProcesser:recvRoomSceneInfo.....")
    packetInfo = checktable(packetInfo)
	kFriendRoomInfo:setRoomInfo(packetInfo)
end

--
function HallSocketProcesser.sendPlayerGameState(tmpData)
   tmpData.usI = kUserInfo:getUserId();
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_PLAYER_ROOM_STATE,tmpData);
   LoadingView.getInstance():show("正在获取信息,请稍后...");
end

-- type = 2,code=20018,玩家游戏过程中状态    client  <-->  server
--##  usI  long  用户ID
--##  gaT  int   游戏类型(0:大厅  1:普通子游戏 2:朋友开房 3:比赛)
function HallSocketProcesser:recvPlayerGameState(cmd, packetInfo)
    Log.i("------HallSocketProcesser ", packetInfo);
	if not IsPortrait then -- TODO
        LoadingView.getInstance():hide();
    end
    packetInfo = checktable(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function HallSocketProcesser:recvOpenRoomMoney(cmd, packetInfo)
    Log.i("......接收到玩家有多少钻石消息.........")
    packetInfo = checktable(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
	kFriendRoomInfo:setMoneyInfo(packetInfo)
end

function HallSocketProcesser:recordInfo(cmd, packetInfo)
    -- Log.i("接收战绩记录信息",packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--[[
-- @brief  接收战绩详细记录
-- @param  void
-- @return void
--]]
function HallSocketProcesser:recordDetailedInfo(cmd, packetInfo)
    Log.i("......接收战绩详细记录信息",packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--已创建房间玩法信息
function HallSocketProcesser:recvRoomCreate(cmd, packetInfo)
    kFriendRoomInfo:setSelectRoomInfo(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

--已创建房间信息
function HallSocketProcesser:recvRoomSceneInfo(cmd, packetInfo)
    Log.i("HallSocketProcesser:recvRoomSceneInfo....")
    kFriendRoomInfo:setRoomInfo(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:recOrder(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end
--支付成功
function HallSocketProcesser:recChargeResult(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:recvRoomEnter(cmd, packetInfo)
    packetInfo = checktable(packetInfo)
    kFriendRoomInfo:setSelectRoomInfo(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

function HallSocketProcesser:recvGiftLogicInfo(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

function HallSocketProcesser:recvGiftList(cmd, packetInfo)
    packetInfo = checktable(packetInfo);
    kHallGiftInfo:setGiftBaseInfo(packetInfo);
end

function HallSocketProcesser:recvAgentInfo(cmd, packetInfo)

    packetInfo = checktable(packetInfo);
    --管理员信息
    kUserInfo:setAgentUrl(packetInfo.ur);
    kUserInfo:setAgentInfo(packetInfo.co);
end

function HallSocketProcesser:recvPlayerInfo(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

function HallSocketProcesser:updateEmail(cmd,packetInfo)
    Log.i("HallSocketProcesser updateEmail",packetInfo)
    packetInfo = checktable(packetInfo)
    kUserData_userExtInfo:setEmailData(packetInfo.li or {});
end
--当邮件面板不存在时,刷新邮件数据
function HallSocketProcesser:newMail(cmd,packetInfo)
    Log.i("HallSocketProcesser NewMail",packetInfo)
    packetInfo = checktable(packetInfo)
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    table.insert(_Data,1,packetInfo)                        --插入表中,后面的顺序变化
    Toast.getInstance():show("收到新消息");
end

--当邮件面板不存在时,刷新邮件数据
function HallSocketProcesser:deleteMail(cmd,packetInfo)
    Log.i("HallSocketProcesser deleteMail",packetInfo)
    packetInfo = checktable(packetInfo)
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    for k,v in pairs(_Data) do
        if v.maI == packetInfo.maI then
            Log.i("HallSocketProcesser------------deleteMail",v)
            table.remove(_Data,k)
            break
        end
    end
end

--[[
 type = 5,code=51006, 返回排行入口界面数据  Server->Client
]]
function HallSocketProcesser:recvRankingData(cmd, packetInfo)
	packetInfo = checktable(packetInfo)
	Log.i("接收到服务器排行入口界面数据",packetInfo)
	kRankingSystem:setPlayerRankingData(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

function HallSocketProcesser:repHallRefreshUI(cmd, packetInfo)
    info = checktable(packetInfo);
    kSystemConfig:setHallConfig(info);
	-- kRankingSystem:setRankingMainUIData(info)--保存排行榜红点和隐藏功能数据
    self.m_delegate:handleSocketCmd(cmd, info);
end

function HallSocketProcesser:exchangeResult(cmd, packetInfo)
    info = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, info);
end

function HallSocketProcesser.sendSelectCity(tmpData)
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_SELCITY,tmpData);
end

function HallSocketProcesser:recvCityList(cmd, packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function HallSocketProcesser:repYaoqingInfo(cmd , packetInfo)
    Log.i("---------------repYaoqingInfo",packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo)
end

function HallSocketProcesser:recMallInfo(cmd, packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo)
end

HallSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_SERVERINFO]   = HallSocketProcesser.repServerInfo;
    [HallSocketCmd.CODE_REC_LOGIN]      = HallSocketProcesser.repLogin;
    [HallSocketCmd.CODE_REC_MALLINFO]           = HallSocketProcesser.recMallInfo;

    [HallSocketCmd.CODE_USERDATA_USERINFO]   = HallSocketProcesser.repUserInfo1;
    [HallSocketCmd.CODE_USERDATA_EXT]   = HallSocketProcesser.repUserInfo2;
    [HallSocketCmd.CODE_USERDATA_POINT]   = HallSocketProcesser.repUserInfo3;
    [HallSocketCmd.CODE_USERDATA_QUEST]   = HallSocketProcesser.recvGiftLogicInfo;

    [HallSocketCmd.CODE_REC_RESUMEGAME]   = HallSocketProcesser.repResumeGame;
    [HallSocketCmd.CODE_REC_GAMESTART]   = HallSocketProcesser.repGameStart;
    [HallSocketCmd.CODE_REC_CHARGLIST]   = HallSocketProcesser.repChargeList;
    [HallSocketCmd.CODE_REC_BROCAST]   = HallSocketProcesser.repBrocast;
    [HallSocketCmd.CODE_REC_AD_TXT]   = HallSocketProcesser.repAdTxt;
    [HallSocketCmd.CODE_REC_USERDATA] = HallSocketProcesser.recvPlayerInfo;
    [HallSocketCmd.CODE_REC_MSGLIST] = HallSocketProcesser.updateEmail;
    [HallSocketCmd.CODE_REC_NEWMAIL] = HallSocketProcesser.newMail;
    [HallSocketCmd.CODE_SEND_PICKUP] = HallSocketProcesser.deleteMail;
    [HallSocketCmd.CODE_REC_QUERYCLUBINFO] = HallSocketProcesser.directForward;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST] = HallSocketProcesser.directForward;

    [HallSocketCmd.CODE_REC_SYSTEM_CONFIG]   = HallSocketProcesser.repSystemConfig;
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_CONFIG] = HallSocketProcesser.recvRoomConfig; 	--邀请房配置
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = HallSocketProcesser.recvRoomSceneInfo; --InviteRoomEnter	邀请房信
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = HallSocketProcesser.recvFriendRoomStartGame; --邀请房对局开始
	[HallSocketCmd.CODE_PLAYER_ROOM_STATE]       = HallSocketProcesser.recvPlayerGameState;--有未完成对局,恢复游戏对局提示
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_MONENY]       = HallSocketProcesser.recvOpenRoomMoney;--接收开房是否有钻石
    [HallSocketCmd.CODE_RECV_RECORD_INFO]       = HallSocketProcesser.recordInfo;--有未完成对局,恢复游戏对局提示

    [HallSocketCmd.CODE_FRIEND_ROOM_CREATE] = HallSocketProcesser.recvRoomCreate;     --InviteRoomCreate   创建邀请房结果
    [HallSocketCmd.CODE_REC_GETORDER]   = HallSocketProcesser.recOrder;
    [HallSocketCmd.CODE_REC_CHARGERESULT]   = HallSocketProcesser.recChargeResult;
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = HallSocketProcesser.recvRoomEnter; --InviteRoomEnter  进入邀请房结果

    [HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO]     = HallSocketProcesser.recordDetailedInfo;--详细战绩信息
    [HallSocketCmd.CODE_REC_GIFTLIST]   = HallSocketProcesser.recvGiftList;
    [HallSocketCmd.CODE_RECV_AGENT_INFO]   = HallSocketProcesser.recvAgentInfo;
	[HallSocketCmd.CODE_RECV_RANKING_GETRANKINGDATA ] = HallSocketProcesser.recvRankingData, --type = 5,code=51006, 返回排行入口界面数据  Server->Clien
    [HallSocketCmd.CODE_REC_HALL_REFRESH_UI]  = HallSocketProcesser.repHallRefreshUI;
    [HallSocketCmd.CODE_REC_EXCHANGE_CODE]   = HallSocketProcesser.exchangeResult;
    [HallSocketCmd.CODE_REC_CITYLIST] = HallSocketProcesser.recvCityList;
    [HallSocketCmd.CODE_SEND_SELCITY] = HallSocketProcesser.sendSelectCity;

    [HallSocketCmd.CODE_RECV_YAOQING_INFO]   = HallSocketProcesser.repYaoqingInfo;
};