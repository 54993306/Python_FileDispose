local DDZTWOPConst = require("package_src.games.pokercommon.data.PokerDataConst")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")

DDZTWOPConst.PLAYER_NUM = 2

--允许都不叫地主次数
DDZTWOPConst.NOCALLLORDTIMES = 3

DDZTWOPConst.SEAT_MINE = 1
DDZTWOPConst.SEAT_RIGHT = 2

--字体
DDZTWOPConst.FONT = "package_res/games/pokercommon/font/main.ttf"

--背景音乐
DDZTWOPConst.BGMUSICPATH = "package_res/games/pokercommon/music/game_bg.mp3"

local defMale = "package_res/games/pokercommon/head/defaultHead_male.png"
local defFemale = "package_res/games/pokercommon/head/defaultHead_female.png"
local stencil = "package_res/games/pokercommon/head/cicleHead.png"
--牌局提示
DDZTWOPConst.CARDTYPETIPS = "您选择的牌不符合规则"
DDZTWOPConst.GAMEINGTIPS  = "现在离开会由笨笨的机器人代打哦！\n\n 输了不能怪它哟"
DDZTWOPConst.FRIENDGAMEINGTIPS = "确认申请解散牌局吗？\n\n解散后按目前得分最终排名"
DDZTWOPConst.NOCALLLORDTIPS = "2人都不叫地主，重新发牌"

DDZTWOPConst.ROOMINFODES = "底数:%d 局数:%d/%d"
DDZTWOPConst.ROOMIDDES = "房间号:%d"
DDZTWOPConst.PAYTYPE1 = 1 --房主付费
DDZTWOPConst.PAYTYPE2 = 2 --大赢家付费
DDZTWOPConst.PAYTYPE3 = 3 --AA付费

DDZTWOPConst.PAYTYPEDES = {
    "房主付费",
    "大赢家付费",
    "AA付费(每人%s钻石)"
}


DDZTWOPConst.CHATTYPE = {
    CUSTOMCHAT = 0,
    VOICECHAT = 1,
}

--默认男头像路径
DDZTWOPConst.DEFMALEFILEPATH = "package_res/games/pokercommon/head/defaultHead_male.png"
--默认女头像路径
DDZTWOPConst.DEFFEMALEFILEPATH = "package_res/games/pokercommon/head/defaultHead_female.png"
--裁剪头像图片路径
DDZTWOPConst.STENCILFILEPATH = "package_res/games/pokercommon/head/cicleHead.png"




--手牌动画资源路径
DDZTWOPConst.HANDANIMBGPATH = "package_res/games/pokercommon/anim/image/boost.png"
DDZTWOPConst.HANDANIMPATH = {
    [DDZTWOPCard.CT_THREE_LINE_TAKE_ONE] = "package_res/games/pokercommon/anim/image/threeTakeOne.png",
    [DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE] = "package_res/games/pokercommon/anim/image/threeTakeOne.png",
    [DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE] = "package_res/games/pokercommon/anim/image/foreTakeOne.png",
    [DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE] = "package_res/games/pokercommon/anim/image/foreTakeOne.png",
    [DDZTWOPCard.CT_ONE_LINE] = "package_res/games/pokercommon/anim/image/shunzi.png",
    [DDZTWOPCard.CT_DOUBLE_LINE] = "package_res/games/pokercommon/anim/image/liandui.png",
}

DDZTWOPConst.CALLLORDSTATUS0 = 0 --叫地主
DDZTWOPConst.CALLLORDSTATUS1 = 1 --不叫地主

DDZTWOPConst.ROBLORDSTATUS0 = 0 --不抢
DDZTWOPConst.ROBLORDSTATUS1 = 1 --抢地主

DDZTWOPConst.OUTCARDSTATUS0 = 0 --不出牌
DDZTWOPConst.OUTCARDSTATUS1 = 1 --出牌

DDZTWOPConst.GAMEDOUBLE = 2  --翻倍倍数

DDZTWOPConst.SPRINGSTATUS1 = 1 --不是春天不是反春
DDZTWOPConst.SPRINGSTATUS2 = 2 --春天或者反春

--恢复对局时上次操作状态
DDZTWOPConst.RECONNECTSTATUS0 = 0 --没有操作
DDZTWOPConst.RECONNECTSTATUS1 = 1 --叫地主
DDZTWOPConst.RECONNECTSTATUS2 = 2 --不叫
DDZTWOPConst.RECONNECTSTATUS3 = 3 --抢地主
DDZTWOPConst.RECONNECTSTATUS4 = 4 --不抢

--服务器出牌结果
DDZTWOPConst.SERVEROUTCARDSTATUS0 = 0 --出牌失败
DDZTWOPConst.SERVEROUTCARDSTATUS1 = -1 --牌型错误
DDZTWOPConst.SERVEROUTCARDSTATUS2 = 1 --出牌成功



--聊天类型
DDZTWOPConst.CHATTYPE1 = 1 --内置表情聊天
DDZTWOPConst.CHATTYPE2 = 2 --内置文字聊天

DDZTWOPConst.VIEWPACKAGEPATH = {
    ["ROOMVIEW"] = "package_src.games.ddztwop.mediator.room.DDZTWOPRoom",
    ["GAMEOVERVIEW"] = "package_src.games.ddztwop.mediator.widget.DDZTWOPGameOverView",
    ["RULEVIEW"] = "package_src.games.pokercommon.widget.PokerRoomRuleView",
    ["CHATVIEW"] = "package_src.games.pokercommon.widget.PokerRoomChatView",
    ["DIALOGVIEW"] = "package_src.games.pokercommon.widget.PokerRoomDialogView",
    ["SETTINGVIEW"] = "package_src.games.pokercommon.widget.PokerRoomSettingView"
}

--每次发牌时间间隔
DDZTWOPConst.DISPENSE_DELAY = 0.05

--性别
DDZTWOPConst.MALE = 0
DDZTWOPConst.FEMALE = 1

--托管状态
DDZTWOPConst.TUOGUAN_STATE_0 = 0
DDZTWOPConst.TUOGUAN_STATE_1 = 1

--踢人的类型
DDZTWOPConst.MULTILOGIN = 4 --多次登录 
DDZTWOPConst.CLOSESERVER = 5 --关服踢人

--打牌过程状态
DDZTWOPConst.STATUS_NONE = 0
DDZTWOPConst.STATUS_CALL = 1
DDZTWOPConst.STATUS_ROB = 2
DDZTWOPConst.STATUS_DOUBLE = 3
DDZTWOPConst.STATUS_MINGPAI = 4
DDZTWOPConst.STATUS_PLAY = 5
DDZTWOPConst.STATUS_GAMEOVER = 6

--手牌触摸高度系数
DDZTWOPConst.TOUCHSCALE = 1.2
--打出手牌缩放比例
DDZTWOPConst.OUTCARDSACLE = 0.7

--出牌倒计时
DDZTWOPConst.OPRATIONTIME = 15
--结算延迟
DDZTWOPConst.DELAY_LAST_CARD = 2.5   --玩家最后一手牌时间
DDZTWOPConst.DELAY_SHOW_CARD = 3.0    --玩家摊出剩余牌时间

--消息监听命令
DDZTWOPConst.EVENT_SUBSIDYWND = "event_subsidywnd"
DDZTWOPConst.EVENT_FASTCHARGE = "event_fastCharge"


--DataMgr 数据键值
DDZTWOPConst.DataMgrKey_LORDID			= 4	--地主ID
DDZTWOPConst.DataMgrKey_BOTTOMCADS		= 6	--底牌
DDZTWOPConst.DataMgrKey_BUJIAONUM		= 10--不叫地主的人数
DDZTWOPConst.DataMgrKey_BASEROOM 		= 13--底注
DDZTWOPConst.DataMgrKey_LASTOUTCARDS	= 15--上手牌？
DDZTWOPConst.DataMgrKey_LASTCARDTYPE	= 16--上手牌牌型？
DDZTWOPConst.DataMgrKey_LASTKEYCARDS	= 17--
DDZTWOPConst.DataMgrKey_LASTCARDTIPS	= 18--上手牌提示
DDZTWOPConst.DataMgrKey_LASTOUTSEAT		= 20--上个出牌的座位
DDZTWOPConst.DataMgrKey_MINECARDCOUNT   = 22 -- 自己手牌剩余数量
DDZTWOPConst.DataMgrKey_OTHERCARDCOUNT  = 23 -- 对家手牌剩余数量
DDZTWOPConst.DataMgrKey_RANGPAICOUNT    = 24 -- 让牌数量
DDZTWOPConst.DataMgrKey_RECONNECTTIME   = 100 --重新连接玩家操作时间
DDZTWOPConst.DataMgrKey_ISCERTAINLORD   = 101 --是否确定地主
DDZTWOPConst.DataMgrKey_GAMESTART       = 102 --游戏是否开始
DDZTWOPConst.DataMgrKey_ALLHANDCARDS    = 103 --所有玩家手牌集合
DDZTWOPConst.DataMgrKey_MINGPAICARD     = 104 --牌局中明牌的牌
DDZTWOPConst.DataMgrKey_MINGPAIIDX      = 105 --明牌索引
DDZTWOPConst.DataMgrKey_FRIENDTOTALDATA = 106 --总结算数据

return DDZTWOPConst
