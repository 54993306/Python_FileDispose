-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

--  override
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    -- 胡牌次数
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, self:getPathByKey(tmpData,"scoreItem"))

    -- 抢杠胡次数
    self:addCustomItem(listView, "抢杠胡次数", tmpData.qiangGangHuTotalCount, self:getPathByKey(tmpData,"scoreItem"))

    -- 杠总数
    self:addCustomItem(listView, "杠的总数", tmpData.gangTotalCount, self:getPathByKey(tmpData,"scoreItem"))
end