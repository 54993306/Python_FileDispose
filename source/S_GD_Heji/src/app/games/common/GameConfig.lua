--进入游戏界面
function enterGame(data)
    display.removeUnusedSpriteFrames()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
    Log.i("common###########enterGame",data)
--  MjMediator:getInstance():entryMj()

    MjMediator:getInstance():onGameEntry(data)
end

import(".CommonAudioConfig");

--[[
删除的全局配置变量:
FriendRoomPalyingTable
GC_BgLayerPath
GC_HideRule
GC_HideTingBtn
GC_ShowFlowerInOverView
_gameHelpContentText
_gameNewerContentText
_isDiamondVisible
以上变量最好不要复用, 以免IOS热更后取到旧包中的值
]]


------------------------------------以下都是所有麻将的默认设置, 不要轻易更改------------------------------------

if IsPortrait then -- TODO
    --游戏图标
    _gameTitlePath = "games/common/image/title.png";
end

--是否支持用户自定义聊天
_gameUserChatTxt = true;

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

if not IsPortrait then -- TODO
-- 翻牌显示图片
GC_TurnLaiziPath = "games/common/mj/games/fanpai.png"
GC_TurnLaiziPath_2 = nil

-- 胡牌番型后缀
GC_PolicyWord = "番 "

-- 聊天短语(用在房间等待界面, 游戏中会被MjProxy改写)
_gameChatTxtCfg = {
    "你这呆子！快点快点啊！",
    -- "",
    "不打的你满脸桃花开，你就不知道花儿为什么这样红！",
    "没了吧？用不用给你留点盘缠回家啊？",
    "哇！土豪，咱们做朋友吧!",
    "不是吧？这样都能赢！",
};
end
------------------------------------各自省包配置------------------------------------
-- 亲友圈分享背景图
_ClubShareBg = "package_res/config/image/club_bg.png"

-- 大厅广告图
_gameHallAdPath = "package_res/config/image/ad_hall.png"

-- 红包广告
_gameRedpacketAdPath = "package_res/config/image/ad_redPacket.png"

-- 登陆界面logo图
GC_GameHallLogoPath = "package_res/config/hall/login/logo.png"

-- 领取红包界面的微信名称图片
_WeChatNameImage = "package_res/config/image/img_wx_2.png"

------------------------------------------------------------------------------------
APP_NAME_PATCH = APP_NAME_PATCH or "dszy"   --app热更保存的文件路径（子麻将热更的路径写成该麻将的名字  xxxmj_region）
-- 是否显示方言
_isShowDialect = false;

--true表示报听后才翻出暗杠的牌,false表示暗杠就会显示出来，不需要报听后翻出来。
_isTingShowAnGangCards = false

--关于相关字段
_GameName = GC_GameName or "" --邮件中显示的运营方名字，不带官方

_CLUB = {}
_CLUB.WELFARE = {
    [1] = "加入亲友圈，约牌更方便，告别三缺一",
    [2] = "开房可直接使用亲友圈钻石，0钻石也能开房",
    [3] = "亲友圈开房功能，玩家更方便",
}

_CLUB.EXPLAIN = {
    [1] = "从管理员处获得他的亲友圈ID",
    [2] = "在下面输入亲友圈ID，向管理员申请加入亲友圈",
    [3] = "管理员审核通过即加入成功",
}

--游戏动画文件配置
_gameArmatureFileInfoCfg ={
    ["dianpao"] = "games/common/mj/armature/dianpao.csb",           --点炮
    ["hu"] = "games/common/mj/armature/jingdeng.csb",               --胡碰杠补花等
    ["liuju"] = "games/common/mj/armature/liuju.csb",               --流局
    ["yaoshaizi"] = "games/common/mj/armature/yaoshaizi.csb",       --摇塞子
    ["yipaoduoxiang"] = "games/common/mj/armature/yipaoduoxiang.csb"--一炮多响
};
if IsPortrait then -- TODO
    _gameArmatureFileInfoCfg ={
        ["dianpao"] = "请覆盖相关内容", --点炮
    };
end

-- 如果要重写，请放到自己麻将包的MjConfig里面
_gamePalyingName={
    [1] = {title = "请覆盖相关内容",ch = "请覆盖相关内容"},
}

--联系我们的微信公众号和微信号
--和10005的reT字段保持一致
--_gameContactInfo = "补充钻石，请联系管理员或客服微信kf66mj01|招募代理：请联系微信号kf66mj01"
_gameContactInfo = ""

-- print("111111111111")
-- 这个地方改到了config中,方便各个省包覆盖配置
-- --白名单URL Root
-- _WhiteListConfigUrlRoot = ""
-- if _is18Server then
--     _WhiteListConfigUrlRoot = "http://192.168.7.105:8089"
--     _WeChatSharedBaseUrl = "http://192.168.7.105:8099/Api/getConfig"    -- 请求微信分享数据后台链接
--     _WeCharSHaredBaseFeedBackUrl = "http://192.168.7.105:8060/Api/shareFeeback"    -- 反馈分享结果链接
--     _WechatSharedClicksNumberUrl = "http://192.168.7.105:8060/Api/shareLandFeeback"    -- 反馈分享结果链接
--     _HotMoreLinkURL = "http://192.168.7.6:8080/versiondown"
-- elseif _isPreReleaseEnv then
--     _WhiteListConfigUrlRoot = "http://pre-client-download-cdn.stevengame.com"
--     _WeChatSharedBaseUrl = "http://pre-app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
--     _WeCharSHaredBaseFeedBackUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
--     _WechatSharedClicksNumberUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareLandFeeback"   ---预发布分享次数统计调用
--     _HotMoreLinkURL = "http://112.74.174.12:36999"
-- else
--     _WhiteListConfigUrlRoot = "http://client-download-cdn.stevengame.com"
--     _WeChatSharedBaseUrl = "http://app75.stevengame.com/Api/getConfig"    -- 请求微信分享数据后台链接
--     _WeCharSHaredBaseFeedBackUrl = "http://client-sharedata-upload.stevengame.com/Api/shareFeeback"    -- 反馈分享结果链接
--     _WechatSharedClicksNumberUrl = "http://client-sharedata-upload.stevengame.com/Api/shareLandFeeback"   ---预发布分享次数统计调用
--     _HotMoreLinkURL = "http://download.stevengame.com/client-data/project_1/regengxin"
-- end

_NoDiamondTips = "您的钻石不足，购买钻石请添加客服微信"

--------------------------
-- 规则获取放在这儿, 方便不同游戏修改规则文本
-- 如果要重写，请放到自己麻将包的MjConfig里面
-- @return table: {ch = "xx"}
function kGetPlayingInfoByTitle(title, gameID)
    local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
    for k, v in pairs(MjGameConfigManager[gameID or kFriendRoomInfo:getGameID()]._gamePalyingName) do
        if (v.title == title) then
            return v
        end
    end
    return nil
end

-- 获取分享信息
function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    -- Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
    local paramData = {}
    paramData[1] = playerInfo.pa .. ""
    local title = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        title = Util.replaceFindInfo(roomInfo.shareTitle, '房间号', {'亲友圈房间号'})
        title = Util.replaceFindInfo(title, 'd', paramData)
    else
        title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)
    end

    local itemList=Util.analyzeString_2(selectSetInfo.wa);
    if(#itemList>0) then
        local str=""
        for i=1,#itemList do
            local st = string.format("%s,",kFriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
            Log.i("st", st)
            str = str .. st
        end
        paramData[1] = str
    else
        paramData[1] = ""
    end
    --
    local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
    paramData[2] = playernum

    paramData[2]= paramData[2] .. selectSetInfo.roS;
    -- Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
    local wanjiaStr = "";
    for k, v in pairs(playerInfo.pl) do
       local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
       wanjiaStr = wanjiaStr .. retName .. ","
    end
    paramData[1] = paramData[1] .. wanjiaStr
    local charge = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        charge = "亲友圈付费"
    else
        local texts = {"房主付费", "大赢家付费", "AA付费"}
        charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
    end
    paramData[2] = paramData[2] .. "局," .. charge

    local s = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})

    local desc = Util.replaceFindInfo(s, 'd', paramData)

    return title, desc
end

function getMagicWindowUrl(roomInfo, playerInfo, selectSetInfo)

    local magicWindowShareUrl={}

    --游戏名称1
    local gameName="&".."gameName="..GC_GameName

    --房主1
    local ownerName="&".."ownerName="..playerInfo.owN

    --房间ID1
    local roomID="&".."roomID="..playerInfo.roI

    --局数
    local gamesNumber="&".."gamesNumber="..selectSetInfo.roS

    --人数
    local playernum="&".."playernum="..(selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 )

    --付费
    local payType

    local charge = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        charge = "亲友圈付费"
    else
        local texts = {"房主付费", "大赢家付费", "AA付费"}
        charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
    end
    local payType="&".."payType="..charge


    --游戏玩法
    local gameWanfa="&".."gameWanfa="..playerInfo.gaN

    --本场玩法
    local benchangWanfa

    local itemList=Util.analyzeString_2(selectSetInfo.wa);
    if(#itemList>0) then
        local str=""
        for i=1,#itemList do
            local st = string.format("%s,",kFriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
            Log.i("st", st)
            str = str .. st
        end
        benchangWanfa = str
    else
        benchangWanfa = ""
    end

    benchangWanfa="&".."benchangWanfa="..benchangWanfa

    magicWindowShareUrl=gameName..ownerName..roomID..gamesNumber..playernum..payType..gameWanfa..benchangWanfa
    Log.i("--wamgzj--magicWindowShareUrl--",magicWindowShareUrl)

    return magicWindowShareUrl

end
