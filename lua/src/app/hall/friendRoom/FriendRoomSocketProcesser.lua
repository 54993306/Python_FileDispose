--礼包网络
FriendRoomSocketProcesser = class("FriendRoomSocketProcesser", SocketProcesser)

 
--type = 2,code=22004, 创建邀请房请求
--##  coI  int  房间配置id
--##  re  int  结果（-1 =创建失败不够资源，-2 =创建失败无可用房间， 非0 = 房间密码）

function FriendRoomSocketProcesser.sendRoomCreate(tmpData)

   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_CREATE,tmpData);
end
  
--type = 2,code=20015, 获取邀请房信息   client  <--> server
function FriendRoomSocketProcesser.sendRoomGetRoomInfo(tmpData)
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_GETROOMINFO,tmpData);
end

function FriendRoomSocketProcesser:recvRoomGetRoomInfo(cmd, packetInfo)
    Log.i("获取邀请房信息结果")
	packetInfo = checktable(packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

--type = 2,code=20010, 邀请房关闭
--##  ti  String   提示
function FriendRoomSocketProcesser:recvRoomEnd(cmd, packetInfo)
    Log.i("接收邀请房关闭信息")
    --Toast.getInstance():show(packetInfo.ti)
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end 

--type = 2,code=20005, 进入邀请房请求
--##  pa  int  房间密码
--##  re  int  结果（-1 =人数已经满，-2 = 无可用房间，1 成功）
function FriendRoomSocketProcesser.sendRoomEnter(tmpData)
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_ENTER,tmpData);
end

function FriendRoomSocketProcesser:recvRoomEnter(cmd, packetInfo)
    Log.i("接收进入邀请房请求结果")
    packetInfo = checktable(packetInfo)
	  kFriendRoomInfo:setSelectRoomInfo(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo)
end


--type = 2,code=20006, 邀请房信息  client  <--  server
--PlayerInfo		
--##    niN  String  昵称
--##    usI  long  玩家id
--##    le  int  等级
--##    ti  String  称号
--##    sc  int  积分
--##    ra  int  排名（仅桌内人）

--##   gaN  String  游戏名称
--##   roI  int   房间ID
--##   pa  int  房间
--##   coI  int   房间config id
--##   noRS  int  已经完成的局数
--##   owN  String   房主
--##  pl:[PlayerInfo]  pl  List<PlayerInfo>   玩家列表

function FriendRoomSocketProcesser:recvRoomSceneInfo(cmd, packetInfo)
    Log.i("FriendRoomSocketProcesser 接收邀请房信息",packetInfo)
    packetInfo = checktable(packetInfo)
	kFriendRoomInfo:setRoomInfo(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

-- 20007--type = 2,code=20007, 退出邀请房请求 Client <--> Server
--usI  long  玩家id
--##  niN  String  玩家昵称
--re  int  结果（-1 失败，1 成功）
function FriendRoomSocketProcesser.sendRoomQuit(tmpData)
   SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT,tmpData);
end

function FriendRoomSocketProcesser:recvRoomQuit(cmd, packetInfo)
   Log.i("退出邀请房结果")
   packetInfo = checktable(packetInfo)
   self.m_delegate:handleSocketCmd(cmd,packetInfo)
   
end

--type = 2,code=20009, 邀请房排行奖励
--##  ra  int  名次
--##  itI  int   道具id
--##  su  int   数量
--##  ti  String   提示
function FriendRoomSocketProcesser:recvRoomReWard(cmd, packetInfo)
    Log.i("接收邀请房排行奖励",packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

--type = 2,code=20016, 邀请房对局开始
function FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData)
	SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_SEND_FRIEND_ROOM_START, tmpData);
end

--type = 2,code=20016, 邀请房对局开始结果
function FriendRoomSocketProcesser:recvFriendRoomStartGame(cmd, packetInfo)
    Log.i("服务端检测到游戏要求人数已满,开始游戏...................")
	packetInfo = checktable(packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function FriendRoomSocketProcesser:recvAddNewPlayerToRoom(cmd,packetInfo)
    Log.i("房间新增加玩家消息...................")
--	packetInfo = checktable(packetInfo)
--	self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

--[[
type = 2,code=23000, 私有房聊天
##  usI  int   玩家ＩＤ
##  niN  String  玩家昵称
##  roI  int  房间ID
##  ty  int  类型 0文字 1语音
##  co  String   chat 内容]]
function FriendRoomSocketProcesser.sendSayMsg(tmpData)
    Log.i("私有房聊天消息:",tmpData)
    SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG,tmpData);
end

function FriendRoomSocketProcesser:recvSayMsg(cmd, packetInfo)
  Log.i("------FriendRoomSocketProcesser:recvSayMsg", packetInfo);
	packetInfo = checktable(packetInfo);
  self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function FriendRoomSocketProcesser.sendFriendRoomLeaveGame(tmpData)
	local tmpData={}
	tmpData.usI =  kUserInfo:getUserId()
	tmpData.re= 1
	tmpData.niN =kUserInfo:getUserName()
	tmpData.isF=0
	SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
	Log.i("发送解散桌子消息",tmpData)
end

function FriendRoomSocketProcesser:recvFriendRoomLeaveGame(cmd,packetInfo)
    Log.i("解散桌子消息",packetInfo)
	packetInfo = checktable(packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo);
end

function FriendRoomSocketProcesser:recClubModels(cmd , packageinfo)
    packageinfo = checktable(packageinfo)
    self.m_delegate:handleSocketCmd(cmd , packageinfo )
end

function FriendRoomSocketProcesser:recClubModelCreate(cmd , info )
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd , info)
end
	
FriendRoomSocketProcesser.s_severCmdEventFuncMap = {
[HallSocketCmd.CODE_RECV_FRIEND_ROOM_END] = FriendRoomSocketProcesser.recvRoomEnd; 	--InviteRoomEnd	 邀请房结束
[HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = FriendRoomSocketProcesser.recvRoomEnter; --InviteRoomEnter	 进入邀请房结果
[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomSocketProcesser.recvRoomSceneInfo; --InviteRoomInfo	 邀请房信息
[HallSocketCmd.CODE_RECV_FRIEND_ROOM_REWARD] = FriendRoomSocketProcesser.recvRoomReWard; 	--InviteRoomRankAward	 邀请房排行奖励
[HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = FriendRoomSocketProcesser.recvRoomQuit; --退出邀请房请求
[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START] = FriendRoomSocketProcesser.recvFriendRoomStartGame; --邀请房对局开始
--[HallSocketCmd.CODE_FRIEND_ROOM_GETROOMINFO] = FriendRoomSocketProcesser.recvRoomGetRoomInfo; --获取邀请房信息
[HallSocketCmd.CODE_RECV_FRIEND_ROOM_ADDPLAYER] = FriendRoomSocketProcesser.recvAddNewPlayerToRoom; --新增玩家到房间
[HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = FriendRoomSocketProcesser.recvSayMsg; --私有房聊天
[HallSocketCmd.CODE_FRIEND_ROOM_LEAVE] = FriendRoomSocketProcesser.recvFriendRoomLeaveGame;--解散桌子信息


[HallSocketCmd.CODE_REC_QUERYCLUBINFO] = FriendRoomSocketProcesser.directForward;
[HallSocketCmd.CODE_REC_JOINEDCLUBLIST] = FriendRoomSocketProcesser.directForward;

[HallSocketCmd.CODE_REC_CLUBMODEL] = FriendRoomSocketProcesser.recClubModels;
[HallSocketCmd.CODE_REC_CREATECLUBMODEL] = FriendRoomSocketProcesser.recClubModelCreate;

};
