-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
------------------------
function FriendTotalOverView:addResultItems(listView, tmpData)
    local bgPath = tmpData.to > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, nil, tmpData.hu, bgPath)
    self:addCustomItem(listView, "自摸次数", tmpData.zm, bgPath)
    self:addCustomItem(listView, "抢杠胡次数", tmpData.QG, bgPath)
    self:addCustomItem(listView, "被抢杠次数", tmpData.BQG, bgPath)
    self:addCustomItem(listView, "直杠次数", tmpData.MingGang, bgPath)
    self:addCustomItem(listView, "补杠次数", tmpData.AddGang, bgPath)
    self:addCustomItem(listView, "暗杠次数", tmpData.AnGang, bgPath)
end

return FriendTotalOverView
