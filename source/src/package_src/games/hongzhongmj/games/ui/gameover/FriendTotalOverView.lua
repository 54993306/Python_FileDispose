-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    -- 胡牌次数
    local bgPath = tmpData.hu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, bgPath)
    -- 自摸次数
    local zmPath = tmpData.zm > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "自摸次数", tmpData.zm, zmPath)
    -- 杠牌次数
    local gaPath = tmpData.ga > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "杠牌次数", tmpData.ga, gaPath)
    -- 全马次数
    local quPath = tmpData.qu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "全马次数", tmpData.qu, quPath)
end