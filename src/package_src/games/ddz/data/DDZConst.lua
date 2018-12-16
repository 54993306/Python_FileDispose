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


return DDZConst
