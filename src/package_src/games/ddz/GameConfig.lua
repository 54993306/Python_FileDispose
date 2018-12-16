--版本号
_gameVersion = VERSION;

local currentModuleName = ...
import(".DDZConfig",currentModuleName)

local csvConfig = require("package_src.games.ddz.data.config_GameData")



local DDZProxyDelegate

--加载资源和配置文件
function loadResAndConfig()
    cc.FileUtils:getInstance():addSearchPath("res/package_res/games/ddz/")
    cc.FileUtils:getInstance():addSearchPath("package_res/games/ddz/")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/pokercommon/pokercommon.plist")
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/pokercommon/pokercommon1.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/ddz/ddz0.plist")
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationZhadan3.csb")
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationLight.csb")
    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/gameover/AnimationDDZ2.csb")
    PokerSoundPlayer:setEffectCfg(csvConfig.musicList["effectpath"]["path"], csvConfig.musicList, csvConfig.musicList["bgpath"]["path"])
    HallAPI.SoundAPI:preloadMusic(csvConfig.musicList["bgpath"]["path"])
end

--进入游戏界面
function enterGame(data)
    local DDZGameScene = require("package_src.games.ddz.mediator.room.DDZGameScene")
    local DDZ_ProxyDelegate = require("package_src.games.ddz.proxy.delegate.DDZ_ProxyDelegate")
    local DDZDataConst = require("package_src.games.ddz.data.DDZDataConst")
    -- 有几副牌
    DataMgr.getInstance():setObject(DDZDataConst.DataMgrKey_NUM_FULL_CARDS, 1)

    --TODO 缓存消息
    -- UIManager.getInstance():popAllWnd(true)
    DDZProxyDelegate = DDZ_ProxyDelegate.new()

    loadResAndConfig()
    HallAPI.ViewAPI:hideLoadingView()
    -- HallAPI.ViewAPI:releaseLoadingView()
    -- HallAPI.ViewAPI:changeToLandscape("FIXED_HEIGHT")
    SocketManager.getInstance().pauseDispatchMsg = true
    HallAPI.ViewAPI:changeToLandscape()
    local bg = display.newSprite("package_res/games/ddz/bg.jpg")--"package_res/games/pokercommon/standings/aaaaaa.png")
    cc.Director:getInstance():getRunningScene():addChild(bg,999)
    bg:setPosition(cc.p(display.width/2,display.height/2))
    bgCSize = bg:getContentSize()
    if display.width - bgCSize.width > display.height - bgCSize.height then
        bg:setScale(display.width/bgCSize.width)
    else
        bg:setScale(display.height/bgCSize.height)
    end

    scheduler.performWithDelayGlobal(function()
            bg:removeFromParent()
            UIManager.getInstance():popAllWnd(true)
            cc.Director:getInstance():pushScene(DDZGameScene.new());
            cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/pokercommon/pokercommon.plist")
    end, 0.6); -- 这里对转屏的时候的场景绘制做了延时，导致如果有解散消息，来不及注册到监听，所以在DDZ_ProxyDelegate中对解散的分发做相同时间的延时
end

function removeTextureAndResetConfig()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    PokerSoundPlayer:setEffectCfg({}, {}, "")
end

--退出游戏界面
function exitGame()
    Log.i("GameConfig exitGame")
    HallAPI.ViewAPI:hideLoadingView()
    HallAPI.EventAPI:dispatchEvent( HallAPI.EventAPI.GAME_PAUSE_NET_DISPATCHMSG )
    removeTextureAndResetConfig()

    for k,v in pairs(DDZModules) do
        package.loaded[v] = nil
    end
    DDZProxyDelegate:dtor()
end
-- local PokerUtils = require("package_src.games.pokercommon.commontool.PokerUtils")

-- -- 获取分享信息
-- function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
 
-- end