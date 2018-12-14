-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")
------------------------
function FriendTotalOverView:addResultItems(listView, tmpData)
    local bgPath = tmpData.hu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, bgPath)
    self:addCustomItem(listView, "自摸次数", tmpData.zm, bgPath)
    self:addCustomItem(listView, "抢杠胡次数", tmpData.qiangGangSum, bgPath)
    self:addCustomItem(listView, "被抢杠次数", tmpData.beiQiangGangSum, bgPath)
    self:addCustomItem(listView, "直杠次数", tmpData.clearGangSum, bgPath)
    self:addCustomItem(listView, "补杠次数", tmpData.addGangSum, bgPath)
    self:addCustomItem(listView, "暗杠次数", tmpData.anGangSum, bgPath)
end

return FriendTotalOverView