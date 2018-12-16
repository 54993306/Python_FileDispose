-------------------------------------------------------------
--  @file   Indicator.lua
--  @brief  指示器
--  @author Zhu Can Qin
--  @DateTime:2016-09-07 16:30:01
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Indicator = class("Indicator", function()
	return display.newNode()
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function Indicator:ctor()
	if self.pointSprite then
        self.pointSprite:removeFromParent()
        self.pointSprite = nil
    end
    self.pointSprite = display.newSprite("games/common/mj/games/out_poker_point.png")
    self:addChild(self.pointSprite)

    self.pointSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)),cc.MoveBy:create(0.5, cc.p(0, -5)))))
    self:setLocalZOrder(enZorderDef.SUBSTITUTE_LAYER)
    -- 隐藏
    -- self:setVisible(false)
end

-- --[[
-- -- @brief  设置位置函数
-- -- @param  void
-- -- @return void
-- --]]
-- function Indicator:indicatorSetPosition(pos)
--     self:setPosition(pos)
-- end

return Indicator
