--
-- Author: Jinds
-- Date: 2017-06-14 10:50:49
--
 local OperateSystem = import("app.games.common.system.operate.OperateSystem")
 local jieyangmjOperateSystem = class("jieyangmjOperateSystem", OperateSystem)

function jieyangmjOperateSystem:ctor(...)
    self.super.ctor(self, ...)
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function jieyangmjOperateSystem:setOperateSystemDatas(cmd, context)
    -- 重置动作 
    dump(context, "<janlog> jieyangmjOperateSystem context ??>>>>")
    self:initActionDatas()
    self.operateData = {}
    self.operateData.actionCard     = context.acC0 or 0     -- 操作的牌
    self.operateData.actionID       = context.acID or 0     -- 动作id
    self.operateData.cbCards        = context.cbC or {}     -- 动作组成的牌型
    self.operateData.actionResult   = context.acR or 0      -- 操作结果
    self.operateData.userid         = context.usID or 0     -- 操作者id
    self.operateData.lastPlayUserId = context.laPUID or 0   -- 最后的操作者
    self.operateData.playCard       = context.ca or 0       -- 打牌
    self.operateData.isHaveNextAct  = context.haA or false  -- 是否有后续动作
    -- 买马信息
    self.operateData.buyHorses        = context.ZhuaMaCards or {}  -- 买马列表

    -- 重新改变玩家操作牌的属性数据
    self.gameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local players   = self.gameSystem:gameStartGetPlayers()
    local site      = self.gameSystem:getPlayerSiteById(context.usID)
    local firstCard = 0
    if context.cbC then
        if #context.cbC > 0 then
            firstCard = context.cbC[1] -- 取动作牌的第一个
        end
        local context = {
            firstCard       = firstCard or 0,
            operateType     = context.acID,
            beoperateUid    = context.laPUID or 0,
            operateCard     = context.acC0,
        }
        players[site]:changeActionProps(context)
    end
    -- 抢杠胡(现在是点炮胡的操作ID)移除被抢的杠
    if self.operateData.actionID == enOperate.OPERATE_DIAN_PAO_HU and self.operateData.actionCard > 0 then
        for i = 1, #players do
            players[i]:removeGang(self.operateData.actionCard)
        end
    end
    --- 拉跑坐属性更新
    if self.operateData.actionID == enOperate.OPERATE_XIADI 
        or self.operateData.actionID == enOperate.OPERATE_XIA_PAO
        or self.operateData.actionID == enOperate.OPERATE_LAZHUANG
        or self.operateData.actionID == enOperate.OPERATE_ZUO then
        local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
        player:changeLaPaoZuoProp({operateType = context.acID, operateCard = context.acC0})
    end
    -- 更新人物听状态
    if self.operateData.actionID == enOperate.OPERATE_TING or 
        self.operateData.actionID == enOperate.OPERATE_TIAN_TING then

        local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
        player:setState(enCreatureEntityState.TING, self.operateData.actionResult)
    end

    if self.operateData.actionID == enOperate.OPERATE_TING then
        local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
        player:setState(enCreatureEntityState.TING, self.operateData.actionResult)
    elseif self.operateData.actionID == enOperate.OPERATE_TIAN_TING then
        local player = self.gameSystem:gameStartGetPlayerByUserid(self.operateData.userid)
        player:setState(enCreatureEntityState.TIANTING, self.operateData.actionResult)
    end
    -- 补花的时候要重新设置一下剩余牌数，因为在补花里面会带一张牌
    if self.operateData.actionID == enOperate.OPERATE_BU_HUA and #self.operateData.buyHorses > 0 then
        local remainCards = SystemFacade:getInstance():getRemainPaiCount() - #self.operateData.buyHorses
        SystemFacade:getInstance():setRemainPaiCount(remainCards)
    end
end


return jieyangmjOperateSystem