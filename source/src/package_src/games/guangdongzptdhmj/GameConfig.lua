--加载公共模块
require("app.games.common.GameConfig");
require("package_src.games.guangdongzptdhmj.GameAudioConfig");

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
GC_TurnLaiziPath = "games/common/mj/games/fanpai.png"

-- --  麻将角标
GC_TurnLaiziPath_2 = "package_res/games/guangdongzptdhmj/fanma/icon_guipai.png"

----红包广告
--_gameRedpacketAdPath = "games/maomingmj/image/ad_redPacket.png";

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

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
--关于相关字段
