--
-- Author: Jinds
-- Date: 2017-11-06 14:43:51
--

local PokerEventDef = {}

--和大厅之间通讯的事件
local hallPrefix = "POKER.HALL."
PokerEventDef.HallEvent = 
{


}

--游戏内的事件
local gamePrefix = "POKER.GAME."
PokerEventDef.GameEvent = 
{
	PLAYER_PROP_CHANGE		= gamePrefix .. "PLAYER_PROP_CHANGE",
	PLAYER_HANDCARDS_ADD	= gamePrefix .. "PLAYER_HANDCARDS_ADD",
	PLAYER_HANDCARDS_DEL 	= gamePrefix .. "PLAYER_HANDCARDS_DEL",

	GAME_REQ_COIN_EXIT		= gamePrefix .. "GAME_REQ_COIN_EXIT",
	GAME_REQ_FRIEND_EXIT	= gamePrefix .. "GAME_REQ_FRIEND_EXIT",
	GAME_EXIT_GAME			= gamePrefix .. "GAME_EXIT_GAME",
	REQSENDDEFCHAT			= gamePrefix .. "REQSENDDEFCHAT",
	GAME_REQ_TUOGUAN		= gamePrefix .. "GAME_REQ_TUOGUAN",
	GAME_REQ_CHANGE			= gamePrefix .. "GAME_REQ_CHANGE",
	GAME_REQ_SAY_CHAT       = gamePrefix .. "GAME_REQ_SAY_CHAT",
	GAME_REQ_JIESAN       	= gamePrefix .. "GAME_REQ_JIESAN",
	GAME_REQ_REQCONTINUE 	= gamePrefix .. "REQCONTINUE",
	GAME_REQ_SHOWTOTALOVER 	= gamePrefix .. "GAME_REQ_SHOWTOTALOVER",

	--网络状况相关
	GAME_NETWORK_CLOSE			= gamePrefix .. "GAME_NETWORK_CLOSE",
	GAME_NETWORK_CONFAIL			= gamePrefix .. "GAME_NETWORK_CONFAIL",
	GAME_NETWORK_CONWEAK			= gamePrefix .. "GAME_NETWORK_CONWEAK",
	GAME_NETWORK_CONEXCEPTION		= gamePrefix .. "GAME_NETWORK_CONEXCEPTION",
	GAME_NETWORK_RECONNECTED		= gamePrefix .. "GAME_NETWORK_RECONNECTED",
	GAME_NETWORK_CONNECTHEALTHLY		= gamePrefix .. "GAME_NETWORK_CONNECTHEALTHLY",

	--及时结算
	GAME_SCORE_SETTLEMENT			= gamePrefix.."GAME_SCORE_SETTLEMENT",

}

return PokerEventDef