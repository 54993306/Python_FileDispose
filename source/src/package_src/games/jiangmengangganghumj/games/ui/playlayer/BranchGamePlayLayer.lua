--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayLayer = require("app.games.common.ui.playlayer.GamePlayLayer")

local Define 			= require "app.games.common.Define"
local MjGroups 			= require("app.games.common.ui.playlayer.exhibition.MjGroups")
local Robot 			= require ("app.games.common.ui.playlayer.Robot")

local FanMaAnimation = require "package_src.games.jiangmengangganghumj.games.ui.fanma.FanMaAnimation"

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

--    local operateData 	= self.operateSystem:getOperateSystemDatas()
--    Log.i(" enTingStatus.FAN_MA_ANIMATION+++++++++",operateData)
--    if operateData.actionID == enTingStatus.FAN_MA_ANIMATION  and operateData.ma.fanMa then

--        self:addFanMaAction(operateData)

----       elseif operateData.actionID ==9 then
----         MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,"AnimationHU")
--    end

--    if not operateData.ma and operateData.actionID == 8 then 
--    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,"AnimationHU")
--    end

    if (operateData.actionID == enOperate.OPERATE_JIA_GANG 
         or operateData.actionID == enOperate.OPERATE_AN_GANG
         or operateData.actionID == enOperate.OPERATE_MING_GANG)
         and ( operateData.actionCard == 0 or operateData.actionCard == nil) then
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
            return
    end
    self.super.onAction(self)
end



--function BranchGamePlayLayer:addFanMaAction(operateData)

--    self.m_fanma = FanMaAnimation.new(operateData.ma,false):addTo(self:getParent(),20)
--end


return BranchGamePlayLayer


--endregion
