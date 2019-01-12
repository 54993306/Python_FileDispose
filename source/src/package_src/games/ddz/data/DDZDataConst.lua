--
-- 用于存储DataMgr中的键
-- Author: Machine
-- Date: 2017-11-13
--
local DDZDataConst = require("package_src.games.pokercommon.data.PokerDataConst")


--DataMgr 数据键值


DDZDataConst.DataMgrKey_OPERATESEATID	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 1 --正在操作玩家ID
DDZDataConst.DataMgrKey_LORDID			= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 2	--地主ID
DDZDataConst.DataMgrKey_LIMITTIME		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 3	--操作时间
DDZDataConst.DataMgrKey_BOTTOMCADS		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 4	--底牌
DDZDataConst.DataMgrKey_MUTIPLE			= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 5	--倍数
DDZDataConst.DataMgrKey_GAMESTATUS		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 6	--游戏状态
DDZDataConst.DataMgrKey_TUOGUANSTATE 	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 7	--托管状态
DDZDataConst.DataMgrKey_BUJIAONUM		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 8--不叫地主的人数
DDZDataConst.DataMgrKey_PLAYERLIST 		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 9--玩家模型数据列表
DDZDataConst.DataMgrKey_BASEROOM 		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 10--底注
DDZDataConst.DataMgrKey_DEBUGSTATE 		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 11--是否处理debug状态
DDZDataConst.DataMgrKey_LASTOUTCARDS	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 12--上手牌？
DDZDataConst.DataMgrKey_LASTCARDTYPE	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 13--上手牌牌型？
DDZDataConst.DataMgrKey_LASTKEYCARDS	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 14--
DDZDataConst.DataMgrKey_LASTCARDTIPS	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 15--上手牌提示
DDZDataConst.DataMgrKey_DOUBLESTATUS	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 16--加倍状态
DDZDataConst.DataMgrKey_LASTOUTSEAT		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 17--上个出牌的座位
DDZDataConst.DataMgrKey_SELECARDLEGAL	= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 18--选的牌是否合法
DDZDataConst.DataMgrKey_LEFTTIME		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 19--恢复对局操作剩余时间
DDZDataConst.DataMgrKey_NOCALLTURN		= DDZDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 20--多少轮没人叫地主
-- DDZDataConst.DataMgrKey_
-- DDZDataConst.DataMgrKey_





return DDZDataConst