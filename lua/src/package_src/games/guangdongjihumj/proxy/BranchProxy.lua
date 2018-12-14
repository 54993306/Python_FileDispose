--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BranchProxy = class("BranchProxy",MjProxy)

function BranchProxy:ctor()
    BranchProxy.super.ctor(self)
    self:addListener()
end

function BranchProxy:addListener()
    enOperate.OPERATE_GENZHUANG          = 61;                          --剩余最后四张（收到这个数据不让打牌）
end
return BranchProxy

--endregion
