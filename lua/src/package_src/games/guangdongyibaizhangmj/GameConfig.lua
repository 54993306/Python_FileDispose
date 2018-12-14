--加载公共模块
require("app.games.common.GameConfig");
require("package_src.games.guangdongyibaizhangmj.GameAudioConfig");

-- 胡牌番型描述后缀
GC_PolicyWord = "番 "

--是否支持用户自定义聊天
_gameUserChatTxt = true;

-- 是否选择服务器用于测试
-- _isChooseServerForTest = false

--游戏图标
--_gameTitlePath = "games/maomingmj/image/title.png";

--大厅广告图
--_gameHallAdPath = "games/maomingmj/image/ad_hall.png";

-- 翻牌显示图片
-- GC_TurnLaiziPath = "package_res/games/guangdongyibaizhangmj/fanma/guipai.png"

-- --  麻将角标
GC_TurnLaiziPath_2 = "package_res/games/guangdongyibaizhangmj/fanma/icon_guipai.png"

----红包广告
--_gameRedpacketAdPath = "games/maomingmj/image/ad_redPacket.png";

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

--GC_GameHallLogoPath = "games/maomingmj/hall/login/logo.png"
-- 翻牌显示图片
GC_TurnLaiziPath = "games/common/mj/games/fanpai.png"
-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示钻石
_isDiamondVisible = false

_isOpenWeiXin = true

--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};
-- 游戏玩法规则
-- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
-- _gamePalyingName={
--     [1] = {title = "keqianggh",                               ch = "可抢杠胡"},
--     [2] = {title = "minggangkq",                              ch = "明杠可抢"},
--     [3] = {title = "qgqb",                             ch = "抢杠全包"},
--     [4] = {title = "gangbaoqb",                               ch = "杠爆全包"},
--     [5] = {title = "sghp",                         ch = "四鬼胡牌"},
--     [6] = {title = "sghp2b",                         ch = "2倍"},
--     [7] = {title = "pph",                              ch = "碰碰胡2倍"},
--     [8] = {title = "qingyise",                                ch = "清一色4倍"},
--     [9] = {title = "yj",                                  ch = "幺九6倍"},
--     [10] = {title = "hyj",                              ch = "含19即可"},
--     [11] = {title = "quanfeng",                               ch = "全风8倍"},
--     [12] = {title = "hunyise",                                ch = "混一色2倍"},
--     [13] = {title = "qidui",                                  ch = "七对4倍"},
--     [14] = {title = "gz",                              ch = "跟庄"},
--     [15] = {title = "mgd",                                ch = "马跟底分"},
--     [16] = {title = "mgg",                              ch = "马跟杠"},
--     [17] = {title = "wg",                                  ch = "无鬼"},
--     [18] = {title = "bbzg",                           ch = "白板做鬼"},
--     [19] = {title = "fg",                                 ch = "翻鬼"},
--     [20] = {title = "wgjb",                            ch = "无鬼加倍"},
--     [21] = {title = "wuma",                                  ch = "无马"},
--     [22] = {title = "erma",                                   ch = "2马"},
--     [23] = {title = "sima",                                   ch = "4马"},
--     [24] = {title = "liuma",                                  ch = "6马"},
--     [25] = {title = "guipai",                                 ch = "鬼牌"},
--     [26] = {title = "mapai",                                  ch = "马牌"},
-- }

--进入游戏界面
function enterGame(data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    Log.i("suzhoumj###########enterGame",data)
--      MjMediator:getInstance():entryMj()
    MjMediator:getInstance():onGameEntry(data)
end

function loadGameRule(gameId)
    local Define = require "app.games.suzhoumj.Define"
    if gameId == Define.gameId_changzhou then
        _gameRuleStr = ""
    elseif gameId == Define.gameId_xuzhou then
        _gameRuleStr = ""
    else
        _gameRuleStr = ""
    end
end
-- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--     Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
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
--     local playernum = ((selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS) or 4) .. "人房,"
--     paramData[2] = playernum

--     paramData[2]= paramData[2] .. selectSetInfo.roS;

--     Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
--     local wanjiaStr = "";
--     for k, v in pairs(playerInfo.pl) do
--        local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
--        wanjiaStr = wanjiaStr .. retName .. ","
--     end
--     paramData[1] = paramData[1] .. wanjiaStr;

--     local retText = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})
--     local texts = {"房主付费", "大赢家付费", "AA付费"}
--     local charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
--     paramData[2] = paramData[2] .. "局," .. charge

--     local desc = Util.replaceFindInfo(roomInfo.shareDesc, 'd', paramData)
--     return title, desc
-- end
