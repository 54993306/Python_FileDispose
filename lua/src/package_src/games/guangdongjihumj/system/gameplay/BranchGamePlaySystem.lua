--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GamePlaySystem = require("app.games.common.system.gameplay.GamePlaySystem")

local BranchGamePlaySystem = class("BranchGamePlaySystem",GamePlaySystem)

function BranchGamePlaySystem:ctor()
	BranchGamePlaySystem.super.ctor(self)
end

--[
-- @override
--]
function BranchGamePlaySystem:activate(context)
    self.myUserId = kUserInfo:getUserId() or 0
   	cc(self):addComponent("app.games.common.system.gameplay.GameStartLogic"):exportMethods()
   	cc(self):addComponent("package_src.games.guangdongjihumj.system.gameplay.BranchGameOverLogic"):exportMethods()
    cc(self):addComponent("app.games.common.system.gameplay.PlayCardLogic"):exportMethods()
    cc(self):addComponent("app.games.common.system.gameplay.GameSubstituteLogic"):exportMethods()
    cc(self):addComponent("app.games.common.system.gameplay.GameDispenseLogic"):exportMethods()
   	cc(self):addComponent("app.games.common.system.gameplay.ContinueLogic"):exportMethods()
end

--[
-- @override
--]
function BranchGamePlaySystem:deactivate()
   	cc(self):removeComponent("app.games.common.system.gameplay.GameStartLogic")
  	cc(self):removeComponent("package_src.games.guangdongjihumj.system.gameplay.BranchGameOverLogic")
    cc(self):removeComponent("app.games.common.system.gameplay.PlayCardLogic")
    cc(self):removeComponent("app.games.common.system.gameplay.GameSubstituteLogic")
    cc(self):removeComponent("app.games.common.system.gameplay.GameDispenseLogic")
   	cc(self):removeComponent("app.games.common.system.gameplay.ContinueLogic")
end

return BranchGamePlaySystem
--endregion
