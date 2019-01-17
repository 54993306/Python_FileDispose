--斗地主游戏场景

local DDZTWOPRoom = require("package_src.games.paodekuai.pdktwop.mediator.room.DDZTWOPRoom")

local DDZTWOPGameScene = class("DDZTWOPGameScene",function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    scene.name = "DDZTWOPGameScene"
    return scene
end)

function DDZTWOPGameScene:ctor()
    self.isEnter = false
    cc.Director:getInstance():setAnimationInterval(1/40)
end

function DDZTWOPGameScene:onEnter()
    Log.i("------DDZTWOPGameScene:onEnter")
    self.m_wnd = PokerUIManager:getInstance():replaceWnd(DDZTWOPRoom)
    self.isEnter = true
end

function DDZTWOPGameScene:onExit()
    Log.i("------DDZTWOPGameScene:onExit")
    exitGame()
end

function DDZTWOPGameScene:dtor()
    Log.i("------DDZTWOPGameScene:dtor")
end

return DDZTWOPGameScene
