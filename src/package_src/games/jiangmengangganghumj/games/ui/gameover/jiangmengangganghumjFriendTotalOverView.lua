-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    -- 胡牌次数
    Log.i("+++++++++++++++++++++++>>>>>结算界面")
    local bgPath = tmpData.hu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, bgPath)
    --自摸次数
    local zmPath = tmpData.zm > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "自摸次数", tmpData.zm, zmPath)
    --点炮次数
    local dpPath = tmpData.dp <= 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "点炮次数", tmpData.dp, dpPath)
end

return jiaozuohuanghuangFriendTotalOverView
