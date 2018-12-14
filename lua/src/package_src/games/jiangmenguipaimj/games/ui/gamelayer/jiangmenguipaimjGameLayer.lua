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
-- @brief  ��ʾUI����
-- @param  void
-- @return void
--]]
--  �Ƴ�GameUIView����������DerivedGameUIView
function jiangmenguipaimjGameLayer:onShowUI()
    self.super.onShowUI(self)
end

--  override
--[[
-- @brief  ��Ϸ��������
-- @param  void
-- @return void
--]]
function jiangmenguipaimjGameLayer:onGameOver()
    --  ΪGameLayer�е�ȫ�ֱ���FriendOverView���¸�ֵ���Ӷ�ʵ�ֵ���DerivedFriendOverView��
    FriendOverView = require("package_src.games.jiangmenguipaimj.games.ui.gameover.DerivedFriendOverView")
    self.super.onGameOver(self)
    self:hideLaPaoZuoPanel()
end

--  ����������ͼ��
function jiangmenguipaimjGameLayer:hideLaPaoZuoPanel()
    local lPlayerHead = self.m_playerHeadNode.panel_heads
    for i = 1, #lPlayerHead do
        local lLaPanel = ccui.Helper:seekWidgetByName(lPlayerHead[i], "la_panel")   --��������
        lLaPanel:setVisible(false)
         local lPaoPanel = ccui.Helper:seekWidgetByName(lPlayerHead[i], "pao_panel")
        lPaoPanel:setVisible(false)
   end
end

return jiangmenguipaimjGameLayer