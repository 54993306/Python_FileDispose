
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
--  跑得快牌形
--  跑得快没有特殊拓展牌型，直接用Cardsdef这个定义
--	防止跟基础牌型相同使用30开始
-----------------------------------------------
enmDDZCardType = {
	EBCT_BASETYPE_ER = 31,				--牌型提示2要单独提出
	EBCT_BASETYPE_AAA = 32,				--三个A的特殊牌型
	EBCT_BASETYPE_3ANDX = 15,			--三带X（兼容后端）
	EBCT_BASETYPE_3KINDSANDX = 16,		--飞机带x（兼容后端）
} 

--提出一些特殊牌的元值
enmCardOriginalVal = {
	Spades3 = 65,                       --黑桃三的元值
	cardsnumber = 16,					--每个人的手牌张数
	cardsA = 14,						--A的number值
	cards2 = 15,						--2的number值
}



------------------------------------
-----------
--  游戏部分规则设定结构
-----------------------------------------------
DDZRULESETTING =
{
	unSign = 0x1FFF,    --!< 标志位 用于用户配置牌型,后13位从高到低分别标志eSingle到eKingsBomb牌型 */
	nHadJokers = false,	    --!< 玩法需要大小王 */
	nSetofCard = 1,		--!< 最多几幅牌的游戏 */
	nLimitSister = 5,	--!< 至少多少张牌构成顺子 */
	nLimitPairs = 2,	--!< 至少多少个对子构成连对 */
	nLimit3Kinds = 2,	--!< 至少多少个三张构成三顺 */
	nLimit3Kinds = 2,	--!< 玩法规则里面 */
}

--规则
DDZGUIZE = {
	stRule3kinds = 2,
	isWhole = false,

	nCountSpecialType = 0,
	--是否需要出黑桃三
	isSpades3 = false,

	iskindsWhole = false,
	--是否是赢家先手
	yinjiaxianshou = false,

	selfCardsNumber = 0,

	AkindsAndBomb = false,
	--四带二
	is4Kinds2 = false,
	isSiteMy = true,

}


MAX_3Kinds = 3           --三带一的张数

-- cc.exports.