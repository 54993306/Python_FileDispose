--进入游戏界面
function enterGame(data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")

    MjMediator:getInstance():onGameEntry(data)

end

--加载公共模块
require("app.games.common.GameConfig");

require("package_src.games.kaipingmj.GameAudioConfig");

-- CONFIG_GAEMID = 10023;--游戏ID
--是否支持用户自定义聊天
_gameUserChatTxt = true;

--大厅广告图
-- _gameHallAdPath = "package_res/games/kaipingmj/hall/ad_hall.jpg";
-- _gameHallAdPath = "games/common/image/ad_hall.jpg";

--红包广告
-- _gameRedpacketAdPath = "package_res/games/kaipingmj/hall/ad_redPacket.jpg";
-- _gameRedpacketAdPath = "games/common/image/ad_redPacket.png";

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

-- 翻牌显示图片
GC_TurnLaiziPath = "games/common/mj/games/fanpai.png"


-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示房卡
_isDiamondVisible = false
-- 是否显示方言
_isShowDialect    = false
--  是否显示微信图标
_isOpenWeiXin = true
-- 是否选择服务器用于测试
_isChooseServerForTest = false

--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};
--朋友开房的玩法
-- _FriendRoomPalyingTable = {
--     [1] = {title = "kedianpao",  ch = "可点炮"},
--     [2] = {title = "zhuawanhuanzhuang",  ch = "抓完黄庄"},
--     [3] = {title = "liumahuanzhuang", ch = "留马黄庄"}

-- }

-- 游戏玩法规则  
-- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
-- _gamePalyingName={
--     [1] = {title = "kedianpao",            ch = "可点炮"},
--     [2] = {title = "zhuawanhuangzhuang",    ch = "抓完黄庄"},
--     [3] = {title = "liumahuangzhuang",      ch = "玩几马留几张"},
--     [4] = {title = "sima",                 ch = "4马",           number = 4},
--     [5] = {title = "bama",                 ch = "8马",           number = 8},
--     [6] = {title = "liuma",                ch = "6马",           number = 6},
--     [7] = {title = "erma",                 ch = "2马",           number = 2},
--     [8] = {title = "1",                    ch = "1分2分"},
--     [9] = {title = "2",                    ch = "2分4分"},
--     [10] = {title = "5",                  ch = "5分10分"},
--     [11] = {title = "10",                  ch ="10分20分"}

-- }

_gameHelpContentText = [[  您需要邀请3个好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！

一、麻将用具
“由条、饼、万、东南西北中发白组成，合计136张牌。

二、基本打法
1.黄庄：抓完所有的牌（也有留马数黄庄的）。杠了就有，点炮模式黄庄不黄杠；自摸模式黄庄黄杠，杠在游戏计算时结算；黄庄不下庄；多家抢杠胡被抢杠的人坐庄。
2.庄家：谁胡谁坐庄；多家抢杠胡被抢杠的人坐庄。自摸：三家输给赢家；点炮：付自己。
3.明杠：就是你手里有三张一样的牌，别人打出另外一张，你杠了。（手中有3张不杠先碰就不能再补杠了）；暗杠：自己抓到四张相同的牌杠下来，称为暗杠；暗杠要亮出。
4.补杠：你自己已经碰了的牌，自己在抓到最后一张杠了，称为补杠。出手：最后一张牌要去抓，但是不出手。
5.杠开：直杠杠开包三家（放杠的人包）；如果是直杠再杠再杠开也是放杠的人包。暗杠杠开或者补杠杠开不需要包三家，正常结算。
6.抢杠胡：抢杠胡包三家，多家抢杠胡，被抢杠者分别包三家，（杠积分不用包），多家抢杠胡，被抢杠者坐庄。多家抢杠胡，看被抢杠者的马来算。
7.不可一炮多响；不需要报听；无过圈碰胡；无杠后炮说法。
8.翻马：胡牌以后按照行牌顺序拿N张牌作为马牌，中马以庄家为東风的方位顺序来决定。胡牌后马不足有几马算几马，没马不算马。
]];

_gameChatTxtCfg = {};

-- 测试用登录ID前缀
GC_TestID =  "njx_test_id7s89456";

-- 胡牌番型后缀
GC_PolicyWord = "番"

-------------------------------
-- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--     local paramData = {}
--     paramData[1] = playerInfo.pa .. ""
--     local title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)

--     local itemList=Util.analyzeString_2(selectSetInfo.wa);
--     if(#itemList>0) then
--         local str=""
--         for i=1,#itemList do
--             local st = string.format("%s,",FriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
--             str = str .. st 
--         end
--         paramData[1] = str
--     else
--         paramData[1] = ""
--     end      
--     --
--     paramData[2]=selectSetInfo.roS;

--     local wanjiaStr = "";
--     for k, v in pairs(playerInfo.pl) do
--        local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
--        wanjiaStr = wanjiaStr .. retName .. ","
--     end
--     paramData[1] = paramData[1] .. wanjiaStr

--     local texts = {"房主付费", "大赢家付费", "AA付费"}
--     local charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
--     paramData[2] = paramData[2] .. "局," .. charge

--     local s = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})

--     local desc = Util.replaceFindInfo(s, 'd', paramData)

--     return title, desc
-- end
