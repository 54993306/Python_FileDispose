local Mj            = require "app.games.common.mahjong.Mj"
local Define        = require "app.games.common.Define"
local bgLayer = import("app.games.common.ui.bglayer.BgLayer")
local shantoumjBgLayer = class("shantoumjBgLayer", bgLayer)

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function shantoumjBgLayer:ctor(data)
    self.super.ctor(self, data)
end

function shantoumjBgLayer:showViews()
    Log.i("------BgLayer:showViews")
    -- 移除速配界面
    self:removeMatchLoading()
    -- 设置门风位置
    self._clock:setDoorDirect()
    -- 设置打牌玩家
    local startData = self.gamePlaySystem:getGameStartDatas()
    local site = self.gamePlaySystem:getPlayerSiteById(startData.firstplay)
    self._clock:setThePoint(site, enClockType.PLAY_CARD)

    self:refreshRemainCount()
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local isStarted = playSystem:checkGameStart()
    if isStarted then
        self:showShengyuStr()
    else
        self:hideShengyuStr()
    end
end

function shantoumjBgLayer:onCheckGameStart()
    self.super.onCheckGameStart(self)
    self:showShengyuStr()
end

return shantoumjBgLayer