--加载公共模块
require("app.games.common.GameConfig");
require("package_src.games.shaoguantdhmj.GameAudioConfig");

-- 胡牌番型描述后缀
GC_PolicyWord = "番 "

--是否支持用户自定义聊天
_gameUserChatTxt = true;


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
-- 规则获取放在这儿, 方便不同游戏修改规则文本
-- @return table: {ch = "xx"}
function kGetPlayingFenInfoByTitle(title)
    for k, v in pairs(_gamePalyingFenName) do
        if (v.title == title) then
            return v
        end
    end
    return nil
end
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