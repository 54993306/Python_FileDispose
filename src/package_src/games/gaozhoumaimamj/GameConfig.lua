--加载公共模块
require("app.games.common.GameConfig");

require("package_src.games.gaozhoumaimamj.GameAudioConfig");

--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};

_gameChatTxtCfg = {};

-- 翻牌显示图片
GC_TurnLaiziPath = "package_res/games/gaozhoumaimamj/aniturncard/guipai.png"
--  麻将角标
GC_TurnLaiziPath_2 = "package_res/games/gaozhoumaimamj/aniturncard/icon_guipai.png"

--  是否为主游戏。true：主游戏；false：子游戏
local lIsMain = false

--  如果是主游戏则开启对应配置
if lIsMain then
    --  游戏名称
    GC_GameName = "高州买马麻将"
    -- 是否支持用户自定义聊天
    _gameUserChatTxt = true;
    -- 大厅广告图
    _gameHallAdPath = "package_res/games/gaozhoumaimamj/advertisement/ad_hall.png"
    -- 红包广告
    _gameRedpacketAdPath = "package_res/games/gaozhoumaimamj/advertisement/ad_redPacket.png"
    -- 是否显示房卡
    _isDiamondVisible = false
    -- 是否显示方言
    _isShowDialect = false
    --  是否显示微信图标
    _isOpenWeiXin = true
end
