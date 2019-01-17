--加载公共模块
require("app.games.common.GameConfig");
require("package_src.games.maomingmj.GameAudioConfig");

-- 胡牌番型描述后缀
GC_PolicyWord = "番 "

--是否支持用户自定义聊天
_gameUserChatTxt = true;

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

--GC_GameHallLogoPath = "package_res/games/maomingmj/hall/login/logo.png"

-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示钻
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
_gamePalyingName={
    [1] = {title = "zhuangmaima",                           ch = "庄买马"},
    [2] = {title = "shuihushuifanma",                       ch = "谁胡谁翻马"},
    [3] = {title = "bufanma",                               ch = "不翻马"},
    [4] = {title = "zhigangbao",                            ch = "直杠杠爆全包"},
    [5] = {title = "huangjinbufanma",                       ch = "黄金不翻马"},
    [6] = {title = "shisanyaobufanma",                      ch = "十三幺不翻马"},
    [7] = {title = "genzhuang",                             ch = "跟庄"},
    [8] = {title = "1fen",                                  ch = "1分2分"},
    [9] = {title = "2fen",                                  ch = "2分4分"},
    [10] = {title = "5fen",                                 ch = "5分10分"},
    [11] = {title = "10fen",                                ch = "10分20分"},
    [12] = {title = "4ma",                                  ch = "4马"},
    [13] = {title = "6ma",                                  ch = "6马"},
    [14] = {title = "8ma",                                  ch = "8马"},
}

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