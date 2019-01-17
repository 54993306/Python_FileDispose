--版本号
_gameVersion = VERSION
_gameName = "ddztwop"
local currentModuleName = ...
import(".DDZTWOPConfig",currentModuleName)
local csvConfig = require("package_src.games.ddztwop.data.config_GameData")
local DDZTWOPGameScene = require("package_src.games.ddztwop.mediator.room.DDZTWOPGameScene")
local DDZTWOP_ProxyDelegate = require("package_src.games.ddztwop.proxy.delegate.DDZTWOP_ProxyDelegate")

local DDZTWOPProxyDelegate

--加载资源和配置文件
function loadResAndConfig()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/pokercommon/pokercommon.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/ddztwop/ddztwop0.plist")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationZhadan3.csb")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationLight.csb")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/gameover/AnimationDDZ2.csb")
    PokerSoundPlayer:setEffectCfg(csvConfig.musicList["effectpath"]["path"], csvConfig.musicList, csvConfig.musicList["bgpath"]["path"])
end

--进入游戏界面
function enterGame(data)
    UIManager.getInstance():popAllWnd(true)
    DDZTWOPProxyDelegate = DDZTWOP_ProxyDelegate.new()
    HallAPI.ViewAPI:changeToLandscape()

    loadResAndConfig()
    
    cc.Director:getInstance():pushScene(DDZTWOPGameScene.new(data))
end

function removeTextureAndResetConfig()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    PokerSoundPlayer:setEffectCfg({}, {}, "")
end

--退出游戏界面
function exitGame()
    HallAPI.EventAPI:dispatchEvent( HallAPI.EventAPI.GAME_PAUSE_NET_DISPATCHMSG )
    HallAPI.DataAPI:clearRoomData()
    removeTextureAndResetConfig()

    for k,v in pairs(DDZTWOPModules) do
        package.loaded[v] = nil
    end
    DDZTWOPProxyDelegate:dtor()
    LoadingView.releaseInstance()
    HallAPI.ViewAPI:hideLoadingView()
end

-- -- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
--     Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
--     local paramData = {}
--     local gameId = HallAPI.DataAPI:getGameId()
--     paramData[1] = playerInfo.pa .. ""
--     local title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)
--     local itemList=Util.analyzeString_2(selectSetInfo.wa)
--     if(#itemList>0) then
--         local str=""
--         for i=1,#itemList do
--             local data = kFriendRoomInfo:getPlayingInfoByTitle(itemList[i])--HallAPI.DataAPI:getPlayingInfoByTitle(itemList[i],gameId)
--             if data then
--                 str = str .. data.ch.."," 
--             end
--         end
--         paramData[1] = str
--     else
--         paramData[1] = ""
--     end      
--     --
--     local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
--     paramData[2] = playernum  

--     paramData[2]= paramData[2] .. selectSetInfo.roS

--     Log.i("------roomInfo.shareDesc",roomInfo.shareDesc)
--     local wanjiaStr = ""
--     for k, v in pairs(playerInfo.pl) do
--        local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "")
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