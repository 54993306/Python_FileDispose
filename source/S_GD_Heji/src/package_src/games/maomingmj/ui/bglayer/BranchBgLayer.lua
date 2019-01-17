--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BgLayer = require("app.games.common.ui.bglayer.BgLayer")

local BranchBgLayer = class("BranchBgLayer", BgLayer)

function BranchBgLayer:ctor()
    -- self:setRuleTip()

    BranchBgLayer.super.ctor(self)
end
function BranchBgLayer:setRuleTip()

    local playingInfo   = kFriendRoomInfo:getSelectRoomInfo().wa
    local ruleStr = ""
--    for k, v in pairs(playingInfo) do
--        ruleStr = ruleStr..v
--    end
    palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    local fenzhi = {
        [1] = "1f2f",
        [2] = "2f4f",
        [5] = "5f10f",
        [10] = "10f20f",
    }
    if palyingInfo.ji ~= nil then
        playingInfo= playingInfo.."|"..fenzhi[ tonumber(palyingInfo.ji)]
    end
    if palyingInfo.fa ~=nil and palyingInfo.fa ~= "0" then
--        ruleStr = ruleStr.." "..palyingInfo.fa.."马"
        playingInfo= playingInfo.."|"..palyingInfo.fa.."ma"
    end
    local roomInfo = kFriendRoomInfo:getSelectRoomInfo()
    roomInfo.wa = playingInfo
    kFriendRoomInfo:setSelectRoomInfo(roomInfo)
end
return BranchBgLayer
--endregion
