--加载公共模块
require("app.games.common.GameConfig");
require("package_src.games.zhongshanmj.GameAudioConfig");


-- 开局显示的翻赖子旁图片的路径
GC_TurnLaiziPath = "package_res/games/zhongshanmj/game/fanpai.png"
GC_TurnLaiziPath_2 = "package_res/games/zhongshanmj/game/icon_guipai.png"
GC_BgLayerPath = "package_src.games.zhongshanmj.game.zhongshanmjBgLayer"

-- 是否隐藏规则
GC_HideRule = true

-- 在结算界面显示花牌
GC_ShowFlowerInOverView = true

-- 隐藏听牌按钮
GC_HideTingBtn = true

--是否支持用户自定义聊天
_gameUserChatTxt = true;

-- 背景音乐
_gameBgMusicPath = "games/common/audio/mp3/music/bgMusic.mp3";

-- 新手引导提示
_gameNewerContentText = "小提示：找您身边正在玩本游戏的朋友，加入麻友群，在群里随时组局，立刻约战！\n或者您自己组建一个麻友群，多找些身边麻友，在群里发条消息，几十人中总会有空闲的，玩上十几分钟也能过过瘾！完全和去棋牌室一样哦！现在还能得66元现金红包，赶快联系客服吧！"

-- 是否显示房卡
_isDiamondVisible = false
-- -- 是否显示方言
-- _isShowDialect    = false
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
    [1] = {title = "1234",         ch = "1234"},
    [2] = {title = "2468",         ch = "2468"},
    [3] = {title = "mggkszm",      ch = "明杠杠开算自摸"},
    [4] = {title = "mggksdp",      ch = "明杠杠开算点炮"},
    [5] = {title = "hzhz",         ch = "黄庄换庄"},
    [6] = {title = "hzbhz",        ch = "黄庄不换庄"},
}

_gameHelpContentText = [[您需要邀请3个好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！

连云港麻将规则

麻将用具
由饼、条、万、东南西北中发白组成，合计136张牌。

庄家规则
轮庄。

黄庄规则
7柱黄庄。有一杠加一注。

基本玩法
能吃能碰能点炮。可一炮多响。

特殊玩法
1、七小对乘以4。
2、清一色乘以4。
3、十三幺147258359加东西南北，乘以4。
4、天胡乘以2。
5、暗杠10，明杠20，偏枪30，庄枪40。


胡牌规则
推倒胡。]];

_gameChatTxtCfg = {};

--进入游戏界面
function enterGame(data)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/shezi.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/flow.plist")
    Log.i("common###########enterGame",data)
--      MjMediator:getInstance():entryMj()

    MjMediator.getInstance():onGameEntry(data)

end



-- local rules={
        
--         yougui={
--             ["false"]="不带鬼",
--             ["true"]="带鬼",
--         },

--         wuguikechihu={
--             ["false"]="",
--             ["true"]="无鬼可吃胡",
--         },

--         paishu={
--             ["136"]="136张牌",
--             ["120"]="120张牌",
--             ["112"]="112张牌",
--             ["108"]="108张牌",
--         },

--         gui={
--             ["47"]="白板鬼",
--             ["45"]="红中鬼",
--         },

--         laizishima={
--             ["false"]="鬼按位置看马",
--             ["true"]="鬼算所有人的马",
--         },

--         wuguihumapaishu={
--             ["0"]="无鬼胡正常翻马",
--             ["2"]="无鬼胡马牌数+2",
--             ["4"]="无鬼胡马牌数+4",
--         },

--         zipaimashu={
--             ["5"]="玩1马时字牌为5马",
--             ["10"]="玩1马时字牌为10马",
--         },

--         mashu={
--             ["6"]="6马",
--             ["4"]="4马",
--             ["8"]="8马",
--             ["10"]="10马",
--             ["1"]="1马",
--         },

--         mapailiebiao={
--             ["true"]="1,5,9鬼为马",
--             ["false"]="按位置看马",
--         },

--         dpfen={
--             ["1"]="1分",
--             ["2"]="2分",
--             ["5"]="5分",
--             ["10"]="10分",
--         },

--         zmfen={
--             ["2"]="1分2分",
--             ["4"]="2分4分",
--             ["10"]="5分10分",
--             ["20"]="10分20分",
--         },
-- }

-------------------------------
-- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--     Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
--     local paramData = {}
--     paramData[1] = playerInfo.pa .. ""
--     local title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)


--     local itemList= json.decode(selectSetInfo.wa)--Util.analyzeString_2(wanfa)
--     -- dump(itemList)
--     -- Log.i("itemList.....",itemList)
--     local ruleStr = ""
--     -- if (#itemList > 0 ) then
--     for i, v in pairs(itemList) do
--             print (i)
--             print (tostring(v))
--             if rules[i] then
--                 local str=""
--                 if i=="dpfen" then

--                 elseif i== "zmfen" then
--                     if itemList.dpfen ==  v then
--                         str=rules["dpfen"][tostring(v)]
--                     else
--                         str=rules[i][tostring(v)]
--                     end
--                 elseif i=="paishu" then
--                     str=rules[i][tostring(v)]
--                     if v==112 then
--                         if itemList.mapailiebiao then
--                             str=str..rules["mapailiebiao"]["true"]
--                         else
--                             str=str..rules["mapailiebiao"]["false"]
--                         end
--                     end
--                 elseif i=="wuguikechihu" then
--                     -- error(itemList.yougui)
--                     -- error(i)

--                     if itemList.yougui==true then
--                         str=rules[i][tostring(v)]
--                     else
--                         -- error("....")
--                     end
--                 else
--                     str=rules[i][tostring(v)]
--                 end

--                 if str then
--                     ruleStr=ruleStr.." "..str
--                 end
--             end
--     end
    
--     paramData[1] = ruleStr

--      local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
--     paramData[2] = playernum

--     -- local itemList=Util.analyzeString_2(selectSetInfo.wa);
--     -- dump(ruleStr)
--     -- if(#itemList>0) then
--     --     local str=""
--     --     for i=1,#itemList do
--     --         local st = string.format("%s,",FriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
--     --         str = str .. st 
--     --     end
--     --     paramData[1] = str
--     -- else
--     --     paramData[1] = ""
--     -- end      
--     --
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
    
--     local desc = Util.replaceFindInfo(retText, 'd', paramData)
--     return title, desc
-- end

-- _isOpenWeiXin=true
-- PacketBuffer.DO_CRYPTO = true