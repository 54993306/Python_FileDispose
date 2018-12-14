--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
-- --加载公共模块
require("app.games.common.ui.gameover.FriendTotalOverView")

------------------------
--  override
-- 添加总结算信息
-- @listView 滚动列表 向下传递
-- @tmpData 个人结算信息
function FriendTotalOverView:addResultItems(listView, tmpData)
    --  胜利背景图
    local imgBGWin = "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png"
    --  失败背景图
    local imgBGFail = "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"

    -- 胡牌次数
    local bgPath = tmpData.hu > 0 and imgBGWin or imgBGFail
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, bgPath)

    -- 翻出马总数
    local lFanMaPath = tmpData.dp <= 0 and imgBGWin or imgBGFail
    self:addCustomItem(listView, "翻出马总数", tmpData.qu, lFanMaPath)
end

--endregion
