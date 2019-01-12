--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayLayer = require("app.games.common.ui.playlayer.GamePlayLayer")

local Define 			= require "app.games.common.Define"
local MjGroups 			= require("app.games.common.ui.playlayer.exhibition.MjGroups")
local Robot 			= require ("app.games.common.ui.playlayer.Robot")

local FanMaAnimation = require "package_src.games.shaoguanzpmj.ui.fanma.FanMaAnimation"

local BranchGamePlayLayer = class("BranchGamePlayLayer",GamePlayLayer)

function BranchGamePlayLayer:ctor()
    self.super.ctor(self)
end
--[[
-- @brief  吃碰杠等操作逻辑函数
-- @param  void
-- @return void
--]]
function BranchGamePlayLayer:onAction()
    local operateData 	= self.operateSystem:getOperateSystemDatas()
--    if operateData.actionID == enTingStatus.FAN_MA_ANIMATION then
--        self:addFanMaAction(operateData)
--        return
--    end
    if operateData.actionID == enOperate.OPERATE_JIA_GANG 
         and (operateData.losIds ~= nil and #operateData.losIds > 0) then
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
            return
    end
    self.super.onAction(self)
end
function BranchGamePlayLayer:addFanMaAction(operateData)
    self.m_fanma = FanMaAnimation.new(operateData.fanmas,operateData.isQuanMa):addTo(self:getParent(),20)
end


return BranchGamePlayLayer


--endregion
