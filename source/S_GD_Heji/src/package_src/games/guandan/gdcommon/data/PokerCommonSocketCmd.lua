--
-- Author: Jan
-- Date: 2017-11-14 11:44:59
-- 扑克游戏，接受大厅消息通用消息
local PokerCommonSocketCmd = {}

PokerCommonSocketCmd.CODE_USERDATA_POINT 		= 1003;	 --更新玩家金豆
PokerCommonSocketCmd.CODE_PLAYER_ROOM_STATE    	= 20018; --type = 2,code=20018,有未完成对局,恢复游戏对局提示
PokerCommonSocketCmd.CODE_REC_ENTERROOM    		= 20011; --进入房间 
PokerCommonSocketCmd.CODE_SEND_GAMESTART		= 20011; --请求进入房间
PokerCommonSocketCmd.CODE_FRIEND_ROOM_LEAVE 	= 22020; --解散桌子信息
PokerCommonSocketCmd.CODE_RECV_FRIEND_ROOM_END 	= 22010; --邀请房结束
PokerCommonSocketCmd.CODE_REC_RESUMEGAME    	= 30005; --继续游戏结果
PokerCommonSocketCmd.CODE_SEND_RESUMEGAME    	= 30005; --请求继续游戏
PokerCommonSocketCmd.CODE_REC_DESKSEATINFO    	= 30030; --中途加入游戏，桌子信息
PokerCommonSocketCmd.CODE_REC_JOINDEASK    		= 30031; --中途加入游戏，中途玩家信息
PokerCommonSocketCmd.CODE_REC_LEAVEDESK    		= 30032; --离开桌子
PokerCommonSocketCmd.CODE_REC_DESKSEATSTATUS   	= 30033; --桌子状态信息
PokerCommonSocketCmd.CODE_REC_NEXTDESKINFO 		= 30034; --游戏下一局的准备信息
PokerCommonSocketCmd.CODE_SEND_ExitRoom 		= 20014; --请求退出房间
PokerCommonSocketCmd.CODE_REC_ExitRoom 			= 20014; --收到退出房间
PokerCommonSocketCmd.CODE_USER_Chat				= 30009; --聊天
PokerCommonSocketCmd.CODE_DEFAULT_CHAT 			= 30010; --默认聊天
PokerCommonSocketCmd.CODE_TUOGUAN				= 30008; --托管
PokerCommonSocketCmd.CODE_REC_BROCAST 			= 60009; --通知
-- PokerCommonSocketCmd.CODE_REC_PAOMADENG			= 60012; --跑马灯
PokerCommonSocketCmd.CODE_REC_SUPPLEMENTCOIN  	= 30035; --补充金豆
PokerCommonSocketCmd.CODE_REC_POKERDIALOG       = 30020; --公用提示
PokerCommonSocketCmd.CODE_REC_SAY_CHAT          = 23000; --语音聊天  
PokerCommonSocketCmd.CODE_REC_TOTAL_GAME_OVER   = 22009; --总结算
PokerCommonSocketCmd.CODE_REC_CONTINUE          = 30006; --续局
PokerCommonSocketCmd.CODE_RECV_FRIEND_ROOM_INFO = 22006; --InviteRoomInfo,邀请房信息
PokerCommonSocketCmd.CODE_SEND_LOCATION         = 10031  -- 上行客户端定位给服务端
PokerCommonSocketCmd.CODE_REC_LOCATION          = 10031  -- 下行服务端接收定位信息


return PokerCommonSocketCmd