--
-- 游戏场景
--
local GDGameScene = class("GDGameScene",function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    return scene
end)

---------------------------------------------------------------
-- @desc 构造函数
---------------------------------------------------------------
function GDGameScene:ctor()
    cc.Director:getInstance():setAnimationInterval(1/40)
end

---------------------------------------------------------------
-- @desc 进入函数  框架会自动调用
---------------------------------------------------------------
function GDGameScene:onEnter()
    Log.i("------GDGameScene:onEnter")
    local GDRoom = require("package_src.games.guandan.gd.mediator.room.GDRoom")
    self.m_wnd = PokerUIManager:getInstance():pushWnd(GDRoom)
end

---------------------------------------------------------------
-- @desc 退出函数  框架会自动调用
---------------------------------------------------------------
function GDGameScene:onExit()
    Log.i("------GDGameScene:onExit")
    if self.m_wnd then
        self.m_wnd:onClose()
    end
    exitGame()
end

return GDGameScene