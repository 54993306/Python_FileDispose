--
-- Author: Jinds
-- Date: 2017-06-14 10:50:49
--
 local OperateSystem = import("app.games.common.system.operate.OperateSystem")
 local shantoumjOperateSystem = class("shantoumjOperateSystem", OperateSystem)

function shantoumjOperateSystem:ctor(...)
    self.super.ctor(self, ...)
end

--[[
-- @brief  更新数据
-- @param  void
-- @return void
--]]
function shantoumjOperateSystem:setOperateSystemDatas(cmd, context)
    -- 重置动作
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
    self.operateData.buyHorses        = context.maiCard or {}  -- 买马列表

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
        -- local remainCards = SystemFacade:getInstance():getRemainPaiCount() - #self.operateData.buyHorses
        -- SystemFacade:getInstance():setRemainPaiCount(remainCards)
    end
end

--[[
-- @brief  获取操作的牌
-- @param  void
-- @return void
--]]
function shantoumjOperateSystem:getActions()
    local needActions = {}
    if #self.actionDatas.actions > 0  then
        for i=1,#self.actionDatas.actions do
            local v = self.actionDatas.actions[i]
            if v == enOperate.OPERATE_DIAN_PAO_HU 
                or v == enOperate.OPERATE_ZI_MO_HU
                or v == enOperate.OPERATE_QIANG_GANG_HU 
                or v == enOperate.OPERATE_MING_GANG
                or v == enOperate.OPERATE_AN_GANG 
                or v == enOperate.OPERATE_JIA_GANG 
                or v == enOperate.OPERATE_PENG
                or v == enOperate.OPERATE_CHI 
                or v == enOperate.OPERATE_TING
                or v == enOperate.OPERATE_TIAN_TING
                or v == enOperate.OPERATE_TIAN_HU
                or v == enOperate.OPERATE_DIAN_TIAN_HU 
                or v == enOperate.OPERATE_TING_RECONNECT
                or v == enOperate.OPERATE_DI_HU 
                or v == enOperate.OPERATE_DIAN_DI_HU
                or v == enOperate.OPERATE_HAI_DI_LAO
                or v == enOperate.OPERATE_DIAN_HAI_DI_LAO
                or v == enOperate.OPERATE_GANG_KAI
                or v == enOperate.OPERATE_GANG_HOU_PAO then
                needActions[#needActions + 1] = v
            end
        end
    end
    return needActions or {}
end

--[[
-- @brief  请求点地胡的操作
-- @param  void
-- @return void
--]]
function shantoumjOperateSystem:sendDianDiHuOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_DIAN_DI_HU, 
        1, 
        playCard)
end

function shantoumjOperateSystem:sendHaiDiLaoOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_HAI_DI_LAO, 
        1, 
        playCard)
end

function shantoumjOperateSystem:sendDianHaiDiLaoOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_DIAN_HAI_DI_LAO, 
        1, 
        playCard)
end

function shantoumjOperateSystem:sendGangkaiOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_GANG_KAI, 
        1, 
        playCard)
end

function shantoumjOperateSystem:sendGangHouPaoOperate()
    local playCard      = self:getDoorCard()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, 
        enMjMsgSendId.MSG_SEND_MJ_ACTION, 
        enOperate.OPERATE_GANG_HOU_PAO, 
        1, 
        playCard)
end

return shantoumjOperateSystem