
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
--花色大->小 （黑莓方红）
enmCardShape = 
{
    ECS_SHAPE_NONE = 0,         --大小王或无花色
	ECS_SHAPE_DIAMONDS = 1,			-- 方块
	ECS_SHAPE_CLUBS = 2,			-- 梅花
	ECS_SHAPE_HEARTS = 3,			-- 红桃
	ECS_SHAPE_SPADE = 4,			-- 黑桃
	ECS_SHAPE_JOKER = 5,			--王的类型
}

-- 牌的点数
enmCardNumber =
{
	ECN_NUM_NONE = 0,
	ECN_NUM_A = 1,				
	ECN_NUM_2 = 2,
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
	ECN_NUM_Joker = 14,		
	ECN_NUM_JOKER = 15			-- 大王
}


-----------------------------------------------
--  CCardsSet相关定义
-----------------------------------------------
--@brief 一个CCardsSet对象最多保存54个CARD对象
MAX_CARDS_LEN = 108

--@brief  0(大小王) 1(黑) 2(红) 3(梅) 4(方) 五种花色
COUNT_SHAPES = 5

--@brief  0 A 2 3 ... J Q K 小王 大王——共16种牌(0表示牌背)
COUNT_CARDNUM = 16

--@brief  0 A 2 3 ... J Q K 小王 大王——共16种牌(0表示牌背)
MAX_NUMBER_SPECIALTYPE = 17

--@brief 扑克牌张数（两幅）
NUM_CHAR_LEN = 128

-----------------------------------------------
--  基本牌型
-----------------------------------------------
enmCardType = {
	EBCT_TYPE_NONE = 0, 				--无牌型
	EBCT_BASETYPE_SINGLE = 1, 			--单张
	EBCT_BASETYPE_PAIR = 2, 			--对子 KK
	EBCT_BASETYPE_SISTER = 3, 			--顺子 34567...
	EBCT_BASETYPE_PAIRS = 4, 		    --连对 QQKKAA...
	EBCT_BASETYPE_3KIND = 5, 		    --三张 KKK
	EBCT_BASETYPE_3KINDS = 6, 		    --三顺 JJJQQQ...
	EBCT_BASETYPE_3AND1 = 7, 		    --三带一 JJJ+K
	EBCT_BASETYPE_3AND2 = 8, 		    --三带二 JJJ+KK
	EBCT_BASETYPE_3KINDSAND1 = 9, 		--三顺带一 JJJQQQ...+KA...
	EBCT_BASETYPE_3KINDSAND2 = 10, 		--三顺带二 JJJQQQ...+KKAA...
	EBCT_BASETYPE_4KINDSAND2 = 11,   	--9.四带两单，如：3333＋45，7777＋89
	EBCT_BASETYPE_4KINDSAND2s = 12,  	--10.四带两双，如：3333＋4455，7777＋8899
	EBCT_BASETYPE_BOMB = 13, 		    --炸弹 KKKK...
	EBCT_BASETYPE_KINGBOMB = 14, 		--王炸
} 

--! 比较函数返回值
enmTypeCompareResult =
{
	ETCR_OTHER = -2,		--/*!< 无法比较 */
	ETCR_LESS = -1,				--/*!< 小于目标cards */
	ETCR_EQUAL = 0,				--/*!< 等于于目标cards */
	ETCR_MORE = 1				--/*!< 大于目标cards */
}

-----------------------------------------------
--  游戏部分规则设定结构
--  子玩法需要用到的时候，Clone这个table
-----------------------------------------------
RULESETTING =
{
	unSign = 0x1FFF,    --!< 标志位 用于用户配置牌型,后13位从高到低分别标志eSingle到eKingsBomb牌型 */
	nHadJokers = true,	    --!< 玩法需要大小王 */
	nSetofCard = 1,		--!< 最多几幅牌的游戏 */
	nLimitSister = 5,	--!< 至少多少张牌构成顺子 */
	nLimitPairs = 2,	--!< 至少多少个对子构成连对 */
	nLimit3Kinds = 2,	--!< 至少多少个三张构成三顺 */
	nLimitBom  = 4,		--!< 至少多少张牌组成炸弹>
}