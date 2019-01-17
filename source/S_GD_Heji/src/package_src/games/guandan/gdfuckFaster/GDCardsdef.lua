
-------------------------------------------------------------
--  @file   Cards.lua
--  @brief  扑克结构定义
--  @author 徐志军
--  @DateTime:2018-06-27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

-----------------------------------------------
--  牌值数据结构
-----------------------------------------------

--cc.exports.
-- 牌的点数
enmCardNumber = nil
-- 覆盖基础库中的牌面
enmCardNumber =
{
	ECN_NUM_NONE = 0,

	ECN_NUM_3 = 3,
	ECN_NUM_4 = 4,
	ECN_NUM_5 = 5,
	ECN_NUM_6 = 6,
	ECN_NUM_7 = 7,
	ECN_NUM_8 = 8,
	ECN_NUM_9 = 9,
	ECN_NUM_10 = 10,
	ECN_NUM_J = 11,
	ECN_NUM_Q = 12,
	ECN_NUM_K = 13,
	ECN_NUM_A = 14,				
	ECN_NUM_2 = 15,
	ECN_NUM_Joker = 16,		
	ECN_NUM_JOKER = 17,			-- 大王
}


-- --  基本牌型
-- -----------------------------------------------
-- 掼蛋牌型
enmCardType = nil
-- 覆盖基础库中的牌型
enmCardType = {
	EBCT_TYPE_NONE = 0, 					--无牌型
	EBCT_BASETYPE_SINGLE = 1, 			--单张
	EBCT_BASETYPE_PAIR = 2, 			--对子 KK
	EBCT_BASETYPE_3KIND = 3, 		    --三张 KKK
	EBCT_BASETYPE_3AND2 = 4, 		    --三带二 JJJ+KK
	EBCT_BASETYPE_SISTER = 5, 			--顺子 34567

	EBCT_CUSTOMERTYPE_PAIRS = 6, 		    --木板 		三连对(只能3个)		QQKKAA	
	EBCT_CUSTOMERTYPE_3KINDS = 7, 		    --钢板 		飞机(只能2个) 		JJJQQQ	
	EBCT_CUSTOMERTYPE_BOMB = 8, 		    --炸弹 		大于4个 				KKKK、QQQQQ、JJJJJJ
	EBCT_CUSTOMERTYPE_SISTER_BOMB = 9, 		    --同花顺		34567				5炸<同花顺<6炸
	EBCT_CUSTOMERTYPE_KING_BOMB = 10, 		    --天王炸 	大王*2+小王*2 		
} 

-----------------------------------------------
--  游戏部分规则设定结构
--  子玩法需要用到的时候，Clone这个table
-----------------------------------------------
-- 掼蛋修改
RULESETTING = nil
-- 覆盖基础库中的牌型
RULESETTING =
{
	unSign = 0x1FFF,    --!< 标志位 用于用户配置牌型,后13位从高到低分别标志eSingle到eKingsBomb牌型 */
	nHadJokers = true,	    --!< 玩法需要大小王 */
	nSetofCard = 2,		--!< 最多几幅牌的游戏 */
	nLimitSister = 5,	--!< 至少多少张牌构成顺子 */
	nLimitPairs = 3,	--!< 至少多少个对子构成连对 */	木板，只能3连对
	nLimit3Kinds = 2,	--!< 至少多少个三张构成三顺 */	钢板，只能2连，不能带
	nLimitBom  = 4,		--!< 至少多少张牌组成炸弹>
	nLevelCard = 15,		-- 级牌
}