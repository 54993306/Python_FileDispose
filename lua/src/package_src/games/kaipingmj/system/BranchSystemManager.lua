--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local SystemManager = require("app.games.common.system.SystemManager")

local GamePlaySystem    = require("app.games.common.system.gameplay.GamePlaySystem")
local ChatSystem        = require("app.games.common.system.chat.ChatSystem")
local OperateSystem     = require("package_src.games.kaipingmj.system.operate.BranchOperateSystem")
local FlowerOperateSystem      = require("app.games.common.system.flower.FlowerOperateSystem")
local ClockSystem       = require("app.games.common.system.clock.ClockSystem")
local SystemFacade      = require("app.games.common.system.SystemFacade")

local BranchSystemManager = class("BranchSystemManager",SystemManager)

function BranchSystemManager:ctor()
	self.systems = {}
    self:addSystem(GamePlaySystem.new(self))
    self:addSystem(ChatSystem.new(self))
    self:addSystem(OperateSystem.new(self))
    self:addSystem(FlowerOperateSystem.new(self))
    self:addSystem(ClockSystem.new(self))
end

return BranchSystemManager


--endregion
