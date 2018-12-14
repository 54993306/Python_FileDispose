-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
--  override
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    -- 胡牌次数
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, self:getPathByKey(tmpData,"scoreItem"))

    -- 自摸次数
    self:addCustomItem(listView, "自摸次数", tmpData.zm, self:getPathByKey(tmpData,"scoreItem"))

    -- 翻出马总数
    self:addCustomItem(listView, "翻出马总数", tmpData.dp, self:getPathByKey(tmpData,"scoreItem"))
end