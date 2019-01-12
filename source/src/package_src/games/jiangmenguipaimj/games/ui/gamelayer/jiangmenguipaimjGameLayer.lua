--
-- Author: RuiHao Lin
-- Date: 2017-05-10 10:53:52
--

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")

local jiangmenguipaimjGameLayer = class("jiangmenguipaimjGameLayer", GameLayer)

--  override
function jiangmenguipaimjGameLayer:ctor()
    self.super.ctor(self)
end

--  override
--[[
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
--  移除GameUIView，创建加载DerivedGameUIView
function jiangmenguipaimjGameLayer:onShowUI()
    self.super.onShowUI(self)
end

--  override
--[[
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function jiangmenguipaimjGameLayer:onGameOver()
    --  为GameLayer中的全局变量FriendOverView重新赋值，从而实现调用DerivedFriendOverView类
    FriendOverView = require("package_src.games.jiangmenguipaimj.games.ui.gameover.DerivedFriendOverView")
    self.super.onGameOver(self)
    self:hideLaPaoZuoPanel()
end

--  隐藏拉跑坐图标
function jiangmenguipaimjGameLayer:hideLaPaoZuoPanel()
    local lPlayerHead = self.m_playerHeadNode.panel_heads
    for i = 1, #lPlayerHead do
        local lLaPanel = ccui.Helper:seekWidgetByName(lPlayerHead[i], "la_panel")   --拉或者坐
        lLaPanel:setVisible(false)
         local lPaoPanel = ccui.Helper:seekWidgetByName(lPlayerHead[i], "pao_panel")
        lPaoPanel:setVisible(false)
   end
end

return jiangmenguipaimjGameLayer