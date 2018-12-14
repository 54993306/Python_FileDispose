--
-- Author: Your Name
-- Date: 2017-05-23 20:06:43
--

local commonGameLayer = import("app.games.common.ui.gamelayer.GameLayer")
local huaijimjGameLayer = class("huaijimjGameLayer", commonGameLayer)

function huaijimjGameLayer:ctor()
	huaijimjGameLayer.super.ctor(self,"huaijimjGameLayer")

end

function huaijimjGameLayer:on_continueReady(userIds)
    if self.m_playerHeadNode == nil then
        return
    end
    for i=1, #userIds do
        local site = self.gameSystem:getPlayerSiteById(userIds[i])
        self.m_playerHeadNode:showReadySpr(site)
    end
    local players   = self.gameSystem:gameStartGetPlayers()
    for i=1,#players do
        self.m_playerHeadNode:refreshFortune(i)
        self.m_playerHeadNode:showTinPaiOp(i, false)
        self.m_playerHeadNode:showZhuangOp(i, false)
        self.m_playerHeadNode:showLapaozupOp(i, false)
    end
    
    self._bgLayer:hideShengyuStr()
    -- local continueDatas = self.gameSystem:getContinueDatas()
    -- for i=1, #continueDatas.userIds do
    --     local site = self.gameSystem:getPlayerSiteById(userIds[i])
    --     self.m_playerHeadNode:showReadySpr(site)
    -- end

end

return huaijimjGameLayer