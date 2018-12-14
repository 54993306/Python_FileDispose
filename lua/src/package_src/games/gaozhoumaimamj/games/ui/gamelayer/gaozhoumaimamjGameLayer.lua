--
-- Author: RuiHao Lin
-- Date: 2017-05-10 10:53:52
--

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")

local gaozhoumaimamjGameLayer = class("gaozhoumaimamjGameLayer", GameLayer)

--  override
function gaozhoumaimamjGameLayer:ctor()
    self.super.ctor(self)
end

--  override
--[[
-- @brief  ��ʾUI����
-- @param  void
-- @return void
--]]
--  �Ƴ�GameUIView����������DerivedGameUIView
function gaozhoumaimamjGameLayer:onShowUI()
    self.super.onShowUI(self)
end

--  override
--[[
-- @brief  ��Ϸ��������
-- @param  void
-- @return void
--]]
function gaozhoumaimamjGameLayer:onGameOver()
    --  ΪGameLayer�е�ȫ�ֱ���FriendOverView���¸�ֵ���Ӷ�ʵ�ֵ���DerivedFriendOverView��
    FriendOverView = require("package_src.games.gaozhoumaimamj.games.ui.gameover.DerivedFriendOverView")
    self.super.onGameOver(self)
end

return gaozhoumaimamjGameLayer