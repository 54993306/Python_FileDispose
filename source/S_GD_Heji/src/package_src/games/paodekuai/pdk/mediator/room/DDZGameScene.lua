--
-- 斗地主游戏场景
--

local DDZGameScene = class("DDZGameScene",function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    scene:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
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
    cc(self):addComponent("app.games.common.components.SingleTouchSwallow"):exportMethods()
end

---------------------------------------------------------------
-- @desc 进入函数  框架会自动调用
---------------------------------------------------------------
function DDZGameScene:onEnter()
    Log.i("------DDZGameScene:onEnter");
    self:regSwallowTouchEvent()
    local DDZRoom = require("package_src.games.paodekuai.pdk.mediator.room.DDZRoom")
    self.m_wnd = PokerUIManager:getInstance():pushWnd(DDZRoom);
    self.isEnter = true;
end

---------------------------------------------------------------
-- @desc 退出函数  框架会自动调用
---------------------------------------------------------------
function DDZGameScene:onExit()
    Log.i(debug.traceback( ))
    Log.i("------DDZGameScene:onExit");
    self:releaseSwallowTouchEvent()
    self.m_wnd:onClose()
    if self.m_wnd then
    end
    exitGame()
end

return DDZGameScene