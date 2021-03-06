--
-- 斗地主游戏场景
--

local DDZGameScene = class("DDZGameScene",function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    scene.name = "DDZGameScene";
    return scene;
end)

---------------------------------------------------------------
-- @desc 构造函数
---------------------------------------------------------------
function DDZGameScene:ctor()
    self.isEnter = false;
    self.m_msgs = {};
    cc.Director:getInstance():setAnimationInterval(1/40); 
end

---------------------------------------------------------------
-- @desc 进入函数  框架会自动调用
---------------------------------------------------------------
function DDZGameScene:onEnter()
    Log.i("------DDZGameScene:onEnter");
    local DDZRoom = require("package_src.games.ddz.mediator.room.DDZRoom")
    self.m_wnd = PokerUIManager:getInstance():pushWnd(DDZRoom);
    self.isEnter = true;
end

---------------------------------------------------------------
-- @desc 退出函数  框架会自动调用
---------------------------------------------------------------
function DDZGameScene:onExit()
    Log.i("------DDZGameScene:onExit");
    if self.m_wnd then
        self.m_wnd:onClose()
    end
    exitGame()
end

return DDZGameScene