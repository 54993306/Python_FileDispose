-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    Log.i("FriendTotalOverView:addResultItems ------ tmpData",tmpData)
    -- 胡牌次数
    local huPath = tmpData.hu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, huPath)
    --自摸次数
    local mgPath = tmpData.clearGangSum > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "明杠次数", tmpData.clearGangSum, mgPath)
    --点炮次数
    local bgPath = tmpData.addGangSum <= 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "补杠次数", tmpData.addGangSum, bgPath)
    
    --点炮次数
    local agPath = tmpData.anGangSum <= 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "暗杠次数", tmpData.anGangSum, agPath)
end

return FriendTotalOverView