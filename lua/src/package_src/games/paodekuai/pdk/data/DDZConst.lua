--
-- 斗地主中的一些常量
--

local DDZConst = {};

DDZConst.PLAYER_NUM = 3;

--座位
DDZConst.SEAT_NONE = 0
DDZConst.SEAT_MINE = 1;
DDZConst.SEAT_RIGHT = 2;
DDZConst.SEAT_LEFT = 3;

DDZConst.CERTAINLORD = 1; -- 确定叫地主
DDZConst.CERTAINLORD = 0; -- 不叫地主

--性别
DDZConst.MALE = 0
DDZConst.FEMALE = 1

--托管状态
DDZConst.TUOGUAN_STATE_0 = 0
DDZConst.TUOGUAN_STATE_1 = 1

--打牌过程状态
DDZConst.STATUS_NONE = 0;
DDZConst.STATUS_CALL = 1;  --叫地主
DDZConst.STATUS_ROB = 2;	--抢地主
DDZConst.STATUS_DOUBLE = 3;  --加倍
DDZConst.STATUS_MINGPAI = 4;  --明牌
DDZConst.STATUS_PLAY = 5;     --开始
DDZConst.STATUS_GAMEOVER = 6;  --结束

--结算延迟
DDZConst.DELAY_LAST_CARD = 1.5;    --玩家最后一手牌时间
DDZConst.DELAY_SHOW_CARD = 1.0;    --玩家摊出剩余牌时间

--聊天类型
DDZConst.FACETYPE 				= 1--表情聊天
DDZConst.TEXTTYPE 				= 2--文字聊天
DDZConst.CHATTYPE = {
    CUSTOMCHAT = 0,
    VOICECHAT = 1,
}


--消息监听命令
DDZConst.EVENT_SUBSIDYWND = "event_subsidywnd";
DDZConst.EVENT_FASTCHARGE = "event_fastCharge"

--斗地主默认牌张数
DDZConst.DEFCARDSNUM	= 17

--踢人的类型
DDZConst.MULTILOGIN = 4 --多次登录 
DDZConst.CLOSESERVER = 5 --关服踢人

--每次操作默认时间
DDZConst.DEFOPETIME = 15

DDZConst.CARDSTYPE = {
	EBCT_TYPE_NONE = 1100, 				--无牌型
	EBCT_BASETYPE_SINGLE = 1001, 			--单张
	EBCT_BASETYPE_PAIR = 1002, 			--对子 KK
	EBCT_BASETYPE_SISTER = 1004, 			--顺子 34567...
	EBCT_BASETYPE_PAIRS = 1030, 		    --连对 QQKKAA...
	EBCT_BASETYPE_3KIND = 1013, 		    --三张 KKK
	EBCT_BASETYPE_3KINDS = 1023, 		    --三顺 JJJQQQ...
	EBCT_BASETYPE_3AND1 = 1014, 		    --三带一 JJJ+K
	EBCT_BASETYPE_3AND2 = 1027, 		    --三带二 JJJ+KK
	EBCT_BASETYPE_3ANDX = 1031,				--三带X 
	EBCT_BASETYPE_3KINDSAND1 = 1021, 		--三顺带一 JJJQQQ...+KA...
	EBCT_BASETYPE_3KINDSAND2 = 1022, 		--三顺带二 JJJQQQ...+KKAA...
	EBCT_BASERTYPE_3KINDSANDX = 1023,		--三顺带X
	EBCT_BASETYPE_BOMB = 2001, 		    --炸弹 KKKK...
	EBCT_BASETYPE_AAA = 2002,			--炸弹三个A
	EBCT_BASETYPE_KINGBOMB = 12, 		--王炸
	EBCT_BASETYPE_4KINDSAND2 = 1011,		--四带二
	-- 缺少最后一手飞机带X
	-- 缺少最后一手4带X
	-- 缺少AAA 炸弹


} 

return DDZConst
