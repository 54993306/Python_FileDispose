
-- FriendTotalOverView = class("FriendTotalOverView", UIWndBase)

-- function FriendTotalOverView:ctor(...)
--     self.super.ctor(self.super, "games/common/game/mj_total_over.csb",...);
-- 	self.m_data = ...
-- 	Log.i("获取到奖励信息:",self.m_data.plL)
-- 	self:sortPlayerInfo()
-- end


require("app.games.common.ui.gameover.FriendTotalOverView")

function FriendTotalOverView:addResultItems(listView, tmpData)
    local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local gameOverDatas  = lGameSystem:getGameOverDatas()

            -- 胡牌次数
    local bgPath = tmpData.hu > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "胡牌次数", tmpData.hu, bgPath)

    local zmPath = tmpData.zm > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "自摸次数", tmpData.zm, zmPath)
            -- 胡牌次数
    local gaPath = tmpData.ga > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "杠的次数", tmpData.ga, gaPath)
             --自摸总数
    local dpPath = tmpData.dp > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "点炮次数", tmpData.dp, dpPath)

    local dianPaoHuSumPath = tmpData.dianPaoHuSum > 0 and "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png" or "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
    self:addCustomItem(listView, "点炮胡次数", tmpData.dianPaoHuSum, dianPaoHuSumPath)
end


return FriendTotalOverView
