--
-- 用于存储DataMgr中的键
-- Author: Machine
-- Date: 2017-11-13
--
local GDDataConst = require("package_src.games.guandan.gdcommon.data.PokerDataConst")
--DataMgr 数据键值
GDDataConst.DataMgrKey_OPERATESEATID	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 1 --正在操作玩家ID
GDDataConst.DataMgrKey_LIMITTIME		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 3	--操作时间
GDDataConst.DataMgrKey_GAMESTATUS		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 6	--游戏状态
GDDataConst.DataMgrKey_TUOGUANSTATE 	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 7	--托管状态
GDDataConst.DataMgrKey_PLAYERLIST 		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 9--玩家模型数据列表
GDDataConst.DataMgrKey_BASEROOM 		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 10--底注
GDDataConst.DataMgrKey_LASTOUTCARDS	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 12--上手牌？
GDDataConst.DataMgrKey_LASTCARDTYPE	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 13--上手牌牌型？
GDDataConst.DataMgrKey_LASTCARDTIPS	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 15--上手牌提示
GDDataConst.DataMgrKey_LASTOUTSEAT		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 17--上个出牌的座位
GDDataConst.DataMgrKey_SELECARDLEGAL	= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 18--选的牌是否合法
GDDataConst.DataMgrKey_LEFTTIME		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 19--恢复对局操作剩余时间
GDDataConst.DataMgrKey_JINGGONGMAP     = GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 22--进贡玩家
GDDataConst.DataMgrKey_HUANGONGMAP     = GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 23--还贡信息
GDDataConst.DataMgrKey_LEVEL_USER        = GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 24--本局级牌的玩家
GDDataConst.DataMgrKey_KANG_GONG_FLAG        = GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 25--是否是抗贡状态
GDDataConst.DataMgrKey_PLAYERLIST_LAST 		= GDDataConst.DataMgrKey_COMMON_ATTRIBUTE_NUM + 26--上局玩家模型数据列表
return GDDataConst