--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BranchProxy = class("BranchProxy",MjProxy)

function BranchProxy:ctor()
    BranchProxy.super.ctor(self)
	self:addEnOperate()
end

function BranchProxy:addEnOperate()
    enTingStatus.FAN_MA_ANIMATION          = 61;                --更新听的状态（听牌时碰杠更新状态）
end
return BranchProxy

--endregion
