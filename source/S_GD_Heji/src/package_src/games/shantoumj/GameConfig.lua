--进入游戏界面
function enterGame(data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
    Log.i("common###########enterGame",data)

    MjMediator:getInstance():onGameEntry(data)

end

--加载公共模块
require("app.games.common.GameConfig");

require("package_src.games.shantoumj.GameAudioConfig");

-- CONFIG_GAEMID = 10023;--游戏ID
--是否支持用户自定义聊天
_gameUserChatTxt = true;
--游戏图标

-- 翻牌显示图片
GC_TurnLaiziPath = "games/common/mj/games/fanpai.png"


-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示钻
_isDiamondVisible = false
-- 是否显示方言
_isShowDialect    = false
--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};
--朋友开房的玩法
FriendRoomPalyingTable = {
    ["zimo"] = {[1]     ="自摸底翻番" ,  [2] = "自摸底不翻番"},
    ["dianpao"]={[1]    = "带点炮胡",    [2] = "不带点炮胡"},
    ["dianpao"]={[1] = "带点炮胡",[2]="不带点炮胡"},
}

-- 游戏玩法规则
-- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
_gamePalyingName={
    [1] = {title = "1fen",      ch = "1分2分"},
    [2] = {title = "2fen",      ch = "2分4分"},
    [3] = {title = "5fen",      ch = "5分10分"},
    [4] = {title = "10fen",      ch = "10分20分"},
    [5] = {title = "jm0",      ch = "奖马0马"},
    [6] = {title = "jm2",      ch = "奖马2马"},
    [7] = {title = "jm4",      ch = "奖马4马"},
    [8] = {title = "jm5",      ch = "奖马5马"},
    [9] = {title = "jm6",      ch = "奖马6马"},
    [10] = {title = "jm7",     ch = "奖马7马"},
    [11] = {title = "jm8",     ch = "奖马8马"},
    [12] = {title = "jm9",     ch = "奖马9马"},
    [13] = {title = "jm10",     ch = "奖马10马"},
    [14] = {title = "maima0",     ch = "买马0马"},
    [15] = {title = "maima1",     ch = "买马1马"},
    [16] = {title = "maima2",     ch = "买马2马"},
    [17] = {title = "maima3",     ch = "买马3马"},
    [18] = {title = "maima4",     ch = "买马4马"},
    [19] = {title = "maima5",     ch = "买马5马"},
    [20] = {title = "dahu*10",     ch = "天胡:大胡x10"},
    [21] = {title = "dahu*dice",     ch = "天胡:大胡x骰子数"},
    [22] = {title = "hzfanbei",     ch = "黄庄翻倍"},
    [23] = {title = "hziazjm",     ch = "黄庄加中奖马"},
    [24] = {title = "lzfanbei",     ch = "连庄翻倍"},
    [25] = {title = "l4zfanbei",     ch = "连四庄翻倍"},
    [26] = {title = "l3zjm",     ch = "连三庄加马"},
    [27] = {title = "jiangmabuliupai",     ch = "奖马不留牌"},
    [28] = {title = "hdlsdh",     ch = "海底捞算大胡"},
    [29] = {title = "daidihu",     ch = "带地胡"},
}

_gameHelpContentText = [[  您需要邀请3个好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！

一、麻将用具
“来来安阳麻将”由条、饼、万、东南西北中發白、春夏秋冬、梅兰菊竹组成，合计144张牌。

二、基本打法
1.以推倒胡为规则。
2.轮庄。起始东风玩家为庄，之后如果庄家胡牌或黄庄，上局庄家继续坐庄，如果闲家胡牌，下局则庄家的下家当庄。
3.有癞子（会），打色子确定癞子（翻起的牌加1为癞子，如果翻起的牌为花牌，则该张牌为癞子）（例：翻起的牌为4万，则5万为癞子；如果翻起的牌为红中，则红中为癞子）。
4.花牌不能被打出。
5.癞子牌可以被打出，对打出者没有影响。其他玩家不能吃碰这张牌。
6.翻出确定癞子的那张牌不能被抓走。
7.4会可碰、不可吃；7会不可吃，不可碰，不可明杠。
8.中、發、白、为花牌，抓到可直接选择杠（补花），打到什么风圈时什么是花。（例：东风圈时东风为花，西风圈时西风为花。）（起始为东风圈，每个人都当过庄后，坐东风玩家第二次上庄时为下一风圈，风圈顺序为东、南、西、北。）
9.剩下20张牌黄庄，有一个杠加2张（花牌不算）。剩下黄庄牌数时不能在杠（补花）。
10.4会只能自摸胡牌，7会自摸和放炮可胡。
]];

_gameChatTxtCfg = {};

-- 胡牌番型后缀
GC_PolicyWord = "番 "

-- 行牌时的赖子角标
-- GC_TurnLaiziPath_2 = "package_res/games/shantoumj/common/hunzi_big.png"

-- CAN_NOT_PUT_OUT_LAIZI = true

_isOpenWeiXin = true

-------------------------------
-- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--     -- Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
--     local paramData = {}
--     paramData[1] = playerInfo.pa .. ""
--     local title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)

--     local itemList=Util.analyzeString_2(selectSetInfo.wa);
--     if(#itemList>0) then
--         local str=""
--         for i=1,#itemList do
--             local st = string.format("%s,",FriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
--             Log.i("st", st)
--             str = str .. st
--         end
--         paramData[1] = str
--     else
--         paramData[1] = ""
--     end
--     --
--     local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
--     paramData[2] = playernum

--     paramData[2]= paramData[2] .. selectSetInfo.roS;
--     -- Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
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
