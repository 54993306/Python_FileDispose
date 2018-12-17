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
-- @brief  显示UI函数
-- @param  void
-- @return void
--]]
--  移除GameUIView，创建加载DerivedGameUIView
function gaozhoumaimamjGameLayer:onShowUI()
    self.super.onShowUI(self)
end

--  override
--[[
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function gaozhoumaimamjGameLayer:onGameOver()
    --  为GameLayer中的全局变量FriendOverView重新赋值，从而实现调用DerivedFriendOverView类
    FriendOverView = require("package_src.games.gaozhoumaimamj.games.ui.gameover.DerivedFriendOverView")
    self.super.onGameOver(self)
end

return gaozhoumaimamjGameLayer