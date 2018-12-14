--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local commonFriendTotalOverView = require("app.games.common.ui.gameover.FriendTotalOverView")

FriendTotalOverView = class("FriendTotalOverView",commonFriendTotalOverView)

function FriendTotalOverView:ctor(...)
    MjMediator.getInstance():setGameOverIsEnd(true)
    FriendTotalOverView.super.ctor(self.super,...)
    self.m_data = ...
end

------------------------
function FriendTotalOverView:addResultItems(listView, tmpData)
    local bgPath = tmpData.to > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, nil, tmpData.hu, bgPath)
    self:addCustomItem(listView, "抢杠胡总数", tmpData.qiangGangHuTotalCount, bgPath)
    self:addCustomItem(listView, "杠总数", tmpData.gangTotalCount, bgPath)
end


return FriendTotalOverView


--endregion
