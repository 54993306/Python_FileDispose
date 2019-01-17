--
-- 斗地主中的一些常量
--

local GDConst = {};

GDConst.PLAYER_NUM = 4;

--座位
GDConst.SEAT_NONE = 0
GDConst.SEAT_MINE = 1;
GDConst.SEAT_RIGHT = 2;
GDConst.SEAT_TOP = 3;
GDConst.SEAT_LEFT = 4;

--性别
GDConst.MALE = 0
GDConst.FEMALE = 1

--托管状态
GDConst.TUOGUAN_STATE_0 = 0
GDConst.TUOGUAN_STATE_1 = 1

--打牌过程状态
GDConst.STATUS_NONE = 0; --没有开始
GDConst.STATUS_ON_JINGONG = 1  --进贡阶段
GDConst.STATUS_ON_HUANGONG = 2  --还贡阶段
GDConst.STATUS_ON_OUT_CARD = 5  --正在出牌
GDConst.STATUS_ON_GAMEOVER = 6  --游戏结束

--结算延迟
GDConst.DELAY_LAST_CARD = 1.5;    --玩家最后一手牌时间
GDConst.DELAY_SHOW_CARD = 1.0;    --玩家摊出剩余牌时间

--聊天类型
GDConst.FACETYPE 				= 1--表情聊天
GDConst.TEXTTYPE 				= 2--文字聊天
GDConst.CHATTYPE = {
    CUSTOMCHAT = 0,
    VOICECHAT = 1,
}


--消息监听命令
GDConst.EVENT_SUBSIDYWND = "event_subsidywnd";
GDConst.EVENT_FASTCHARGE = "event_fastCharge"

--斗地主默认牌张数
GDConst.DEFCARDSNUM	= 17

--踢人的类型
GDConst.MULTILOGIN = 4 --多次登录 
GDConst.CLOSESERVER = 5 --关服踢人

--每次操作默认时间
GDConst.DEFOPETIME = 15

GDConst.CARDSTYPE = {
	EBCT_TYPE_NONE = 1100, 				--无牌型
	EBCT_BASETYPE_SINGLE = 1001, 			--单张
	EBCT_BASETYPE_PAIR = 1002, 			--对子 KK
	EBCT_BASETYPE_3KIND = 1013, 		    --三张 KKK
	EBCT_BASETYPE_3AND2 = 1031,				--三带对
	EBCT_BASETYPE_SISTER = 1032,				--顺子
	EBCT_CUSTOMERTYPE_PAIRS = 1033,		--木板
	EBCT_CUSTOMERTYPE_3KINDS = 1034,		--钢板
	EBCT_BASETYPE_BOMB = 2001, 	--四炸
	EBCT_BASETYPE_BOMB5 = 2003, --五炸
	EBCT_CUSTOMERTYPE_SISTER_BOMB = 2005, --同花顺五炸
	EBCT_BASETYPE_BOMB6 = 2007, --六炸
	EBCT_BASETYPE_BOMB7 = 2009, --七炸
	EBCT_BASETYPE_BOMB8 = 2011, --八炸
	EBCT_BASETYPE_BOMB9 = 2013, --九炸
	EBCT_BASETYPE_BOMB10 = 2015, --十炸
	EBCT_CUSTOMERTYPE_KING_BOMB = 2100, --天王炸
} 

GDConst.GAME_UP_TYPE = {
	UP_GRADE = 1,--升级场
    NO_UP_GRADE = 2,--不升级场
}

return GDConst
