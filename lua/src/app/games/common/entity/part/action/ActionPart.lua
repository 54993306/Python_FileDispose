---------------------------------------------------------------
--      @file  ActionPart.lua
--     @brief  行为部件
--
--    @author  VyronLee (Vyron), vyron@xunshantec.com
--
--  @internal
--    Created  2015/5/8
--    Company  Xunshantec LLC.
--  Copyright  Copyright (c) 2015, VyronLee
--===============================================================
local Define = require "app.games.mj.mediator.game.Define"
local ActionAnGang      = import(".ActionAnGang")
local ActionMingGang    = import(".ActionMingGang")
local ActionJiaGang     = import(".ActionJiaGang")
local ActionHu          = import(".ActionHu")
local ActionChi         = import(".ActionChi")
local ActionPeng        = import(".ActionPeng")
local ActionQi          = import(".ActionQi")
local ActionTing        = import(".ActionTing")

local BasePart = import("..BasePart")
local ActionPart = class("ActionPart", BasePart)

function ActionPart:ctor(owner)
    ActionPart.super.ctor(self, owner)

    self.handlers = {}
    self.handlers[Define.enCreatureActionDef.AN_GANG]   = ActionAnGang.new(self)
    self.handlers[Define.enCreatureActionDef.MING_GANG] = ActionMingGang.new(self)
    self.handlers[Define.enCreatureActionDef.JIA_GANG]  = ActionJiaGang.new(self)
    self.handlers[Define.enCreatureActionDef.HU]        = ActionHu.new(self)
    self.handlers[Define.enCreatureActionDef.CHI]       = ActionChi.new(self)
    self.handlers[Define.enCreatureActionDef.PENG]      = ActionPeng.new(self)
    self.handlers[Define.enCreatureActionDef.TING]      = ActionTing.new(self)
    self.handlers[Define.enCreatureActionDef.QI]        = ActionQi.new(self)
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function ActionPart:release()
    self:deactivate()

    table.walk(self.handlers, function(handler)
        handler:release()
    end)
    self.handlers = nil

    ActionPart.super.release(self)
end

--[
-- @brief  激活部件
-- @param  void
-- @return true/false
--]
function ActionPart:activate()
    return true
end

--[
-- @brief  反激活部件
-- @param  void
-- @return true/false
--]
function ActionPart:deactivate()
    table.walk(self.handlers or {}, function(handler)
        handler:stop()
    end)
    return true
end

--[
-- @brief  执行行为命令
-- @param  actionId 行为ID，见enCreatureActionDef
-- @param  context 现场
-- @return
--]
function ActionPart:runAction(actionId, context)
    if nil == self.handlers[actionId] then
        printError("ActionPart:runAction - 未定义对应的行为处理器，ID=%s", actionId)
        return false
    end
    local ret = self.handlers[actionId]:run(context)
    if not ret then
        printError("ActionPart:runAction - 动作执行失败，ID=%s, 现场: %s",
            actionId, json.encode(context or {}))
        return false
    end
    return true
end

--[
-- @brief  取得部件ID
-- @param  void
-- @return id
--]
function ActionPart:getPartId()
    return Define.enPartDef.ACTION_PART
end

return ActionPart

