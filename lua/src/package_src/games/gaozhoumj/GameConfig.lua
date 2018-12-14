--进入游戏界面
function enterGame(data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    Log.i("common###########enterGame",data)

    MjMediator:getInstance():onGameEntry(data)

end

--加载公共模块
require("app.games.common.GameConfig");

require("package_src.games.gaozhoumj.GameAudioConfig");

-- CONFIG_GAEMID = 10006;--游戏ID
--是否支持用户自定义聊天
_gameUserChatTxt = true;
-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

-- 翻牌显示图片
GC_TurnLaiziPath = "package_res/games/gaozhoumj/game/guipai.png"
GC_TurnLaiziPath_2 = "package_res/games/gaozhoumj/game/icon_guipai.png"

-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示房卡
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

--游戏玩法规则

--_gamePalyingName={
--    [1] = {title = "1di2di",                                        ch = "1分2分"},
--    [2] = {title = "2di4di",                                        ch = "2分4分"},
--    [3] = {title = "5di10di",                                       ch = "5分10分"},
--    [4] = {title = "10di20di",                                      ch = "10分20分"},
--    [5] = {title = "fanmabywinner",                                 ch = "谁胡谁翻马"},
--    [6] = {title = "bufanma",                                       ch = "不翻马"},
--    [7] = {title = "huangzhuangzhuawei",                            ch = "黄庄抓尾坐庄"},
--    [8] = {title = "huangzhuangbuhuan",                             ch = "黄庄不换庄"},
--    [9] = {title = "gangbucangyuma",                                ch = "杠不参与马"},
--    [10] = {title = "gangcangyuma",                                 ch = "杠参与马"},
--    [11] = {title = "4ma",                                          ch = "4马"},
--    [12] = {title = "6ma",                                          ch = "6马"},
--    [13] = {title = "8ma",                                          ch = "8马"},
--    [14] = {title = "12ma",                                         ch = "12马"},

--}


--_gamePalyingName={
--    [13]={title="sgshp", ch="4鬼算胡牌"},
--    [1] = {title = "biangui",           ch = "变鬼"},
--    [2] = {title = "wugui",          ch = "无鬼"},
--    [3] = {title = "bdssy",                 ch = "不带十三幺"},
--    [4] = {title = "dssy",                 ch = "带十三幺"},
--    [5] = {title = "qghmpc2",                ch = "抢杠胡马牌x2"},
--    [6] = {title = "qghmpc4",           ch = "抢杠胡马牌x4"},
--    [7] = {title = "wghj2m",                ch = "无鬼胡加2马"},
--    [8] = {title = "wghj1f",           ch = "无鬼胡加一番"},
--    [9] = {title = "4ma",           ch = "4马"},
--    [10] = {title = "6ma",          ch = "6马"},
--    [11] = {title = "2ma",           ch = "2马"},
--    [12] = {title = "1ma",          ch = "1马"},
--}
_isOpenWeiXin = true

_gameChatTxtCfg = {};

-- 微信AppID
-- WX_APP_ID = "wx2e52c2ba5f6c918e";

-- -- 版本号
-- VERSION = "1.0.3";

-- 胡牌番型后缀
GC_PolicyWord = " "

-------------------------------
-- 获取分享信息
--function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--    Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
--    local paramData = {}
--    paramData[1] = playerInfo.pa .. ""
--    local title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)

--    local itemList=Util.analyzeString_2(selectSetInfo.wa);
--    if(#itemList>0) then
--        local str=""
--        for i=1,#itemList do
--            local st = string.format("%s,",FriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
--            Log.i("st", st)
--            str = str .. st
--        end
--        paramData[1] = str
--    else
--        paramData[1] = ""
--    end
--    --
--    paramData[2]=selectSetInfo.roS;

--    Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
--    local wanjiaStr = "";
--    for k, v in pairs(playerInfo.pl) do
--       local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
--       wanjiaStr = wanjiaStr .. retName .. ","
--    end
--    paramData[1] = paramData[1] .. wanjiaStr

--    local texts = {"房主付费", "大赢家付费", "AA付费"}
--    local charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
--    paramData[2] = paramData[2] .. "局," .. charge

--    local s = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})

--    local desc = Util.replaceFindInfo(s, 'd', paramData)

--    return title, desc
--end
