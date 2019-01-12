-------------------------------------------------------------
--  @file   MessageDef.lua
--  @brief  消息定义
--  @author Zhu Can Qin
--  @DateTime:2016-08-30 17:09:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

--发送消息Id
enMjMsgSendId = 
{
	MSG_SEND_SUBSTITUTE 	= 30008,	--请求托管
	MSG_SEND_TURN_OUT		= 31002,	--请求出牌
	MSG_SEND_XIA_PAO    	= 31012,	--下炮
	MSG_SEND_MJ_ACTION  	= 31004,	--请求特殊操作
    MSG_SEND_USER_CHAT  	= 30009,    --用户自定义输入
    MSG_SEND_DEFAULT_CHAT 	= 30010,	--用户使用系统操作
}

--接收消息Id
enMjMsgReadId = 
{
	MSG_READ_GAME_START 	= 31001,		--开局
	MSG_READ_PLAY_CARD  	= 31003,		--打牌
	MSG_READ_MJ_ACTION  	= 31004,		--特殊操作
	MSG_READ_GAME_OVER 		= 31006,		--结算
	MSG_READ_FLOWER 		= 31008,		--补花
	MSG_READ_SUBSTITUTE 	= 30008,		--托管
	MSG_READ_GAME_RESUME 	= 31009,		--恢复对局响应
	MSG_READ_DISPENSE_CARD 	= 31011,		--摸牌
   	MSG_READ_XIA_PAO 		= 31012,		--下炮
   	MSG_READ_CONTINUE 		= 30006,		--玩家确定续局
    MSG_READ_USER_CAHT 		= 30009,      	--用户自定义输入
    MSG_READ_DEFAULT_CHAT 	= 30010,   		--用户使用系统操作
    MSG_READ_UPDATE_TAKEN_CASH = 30002 , 	--更新携带
    MSG_READ_DISMISS_DESK 	= 30012 ,  		--散桌
    MSG_READ_PLAYER_LEAVE_STATUE = 30017 ,  --玩家离桌状态
	MSG_READ_PROMPT_INFO = 30020 , -- 麻将信息提示 1 包牌提示 2 不能胡提示
    MSG_READ_JIESUAN_IMMEDIATELY = 22021,   -- 立即结算
}
