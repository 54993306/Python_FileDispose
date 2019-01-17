--版本号
_gameVersion = VERSION;

local currentModuleName = ...
import(".GDConfig",currentModuleName)

local csvConfig = require("package_src.games.guandan.gd.data.config_GameData")
local GDProxyDelegate

--加载资源和配置文件
function loadResAndConfig()
    cc.FileUtils:getInstance():addSearchPath("res/package_res/games/guandan/")
    cc.FileUtils:getInstance():addSearchPath("package_res/games/guandan/")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/guandan/pokercommon.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/guandan/guandan.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/guandan/settlement.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/guandan/newPoker.plist")
    PokerSoundPlayer:setEffectCfg(csvConfig.musicList["effectpath"]["path"], csvConfig.musicList, csvConfig.musicList["bgpath"]["path"])
    HallAPI.SoundAPI:preloadMusic(csvConfig.musicList["bgpath"]["path"])
end

--进入游戏界面
function enterGame(data)
    local GDGameScene = require("package_src.games.guandan.gd.mediator.room.GDGameScene")
    local GD_ProxyDelegate = require("package_src.games.guandan.gd.proxy.delegate.GD_ProxyDelegate")

    --TODO 缓存消息
    -- UIManager.getInstance():popAllWnd(true)
    GDProxyDelegate = GD_ProxyDelegate.new()

    loadResAndConfig()
    HallAPI.ViewAPI:hideLoadingView()
    -- HallAPI.ViewAPI:releaseLoadingView()
    -- HallAPI.ViewAPI:changeToLandscape("FIXED_HEIGHT")
    SocketManager.getInstance().pauseDispatchMsg = true
    HallAPI.ViewAPI:changeToLandscape()
    local bg = display.newScale9Sprite("package_res/games/guandan/bg.jpg",display.width/2,display.height/2,cc.size(display.width,display.height))
    cc.Director:getInstance():getRunningScene():addChild(bg,999)
    
    scheduler.performWithDelayGlobal(function()
        bg:removeFromParent()
        UIManager.getInstance():popAllWnd(true)
        cc.Director:getInstance():pushScene(GDGameScene.new())
    end, 0.6); -- 这里对转屏的时候的场景绘制做了延时，导致如果有解散消息，来不及注册到监听，所以在GD_ProxyDelegate中对解散的分发做相同时间的延时
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

    for k,v in pairs(GDModules) do
        package.loaded[v] = nil
    end
    GDProxyDelegate:dtor()
end
