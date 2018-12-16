local GamePlayLayer = import("app.games.common.ui.playlayer.GamePlayLayer")
local jieyangmjGamePlayLayer = class("jieyangmjGamePlayLayer", GamePlayLayer)
local UIFactory           = require "app.games.common.ui.UIFactory"
local Robot             = require ("app.games.common.ui.playlayer.Robot")
local MyselfTinPaiOperation     = require("app.games.common.ui.operatelayer.MyselfTinPaiOperation")
local Define            = require "app.games.common.Define"

function jieyangmjGamePlayLayer:ctor(data)
    self.super.ctor(self, data)
end

--[[
-- @brief  执行动作动画函数
-- @param  operateData = {
--      cbCards,        --麻将的列表
--      actionID,       --动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--      userid,         --操作者的座次
--      lastPlayUserId, --被操作的座位，暗杠和加杠不需要传进来
-- }
-- @return void
--]]
function jieyangmjGamePlayLayer:runActionAnimation(operateData)
     -- dump(operateData,"<janlog> operateData 2222222222222222222222")
    local beOperateSite = self.gamePlaySystem:getPlayerSiteById(operateData.lastPlayUserId)
    local operateSite   = self.gamePlaySystem:getPlayerSiteById(operateData.userid)
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerByUserid(operateData.userid);
    local sex = player:getProp(enCreatureEntityProp.SEX);

    local content = {
        mjs         = operateData.cbCards,          --麻将的列表
        actionType  = operateData.actionID,         --动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
        operator    = operateSite,                  --操作者的座次
        -- beOperator  = operateData.lastPlayUserId, --被操作的座位，暗杠和加杠不需要传进来
        beOperator  = beOperateSite,                --被操作的座位，暗杠和加杠不需要传进来
        actionCard = operateData.actionCard         --操作的牌
    }

    if operateData.actionID == enOperate.OPERATE_JIA_GANG then
        --content{
        --  mjs     =  {},  麻将的列表
        --  actionType      动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
        --  operator        操作者的座次 参考 enSiteDirection
        -- }

        self.playerPannel[operateSite]:setGroupJiaGang(content)
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)
        --音效
        _GameEffectActionGang(sex);
        self:setHandMjINVAID(operateSite)
    elseif operateData.actionID == enOperate.OPERATE_CHI then
        -- 合成麻将组
        self.playerPannel[operateSite]:composeMjGroup(content)
        --移除吃了别家的牌，防止删除手中相同牌
        table.removebyvalue(operateData.cbCards,operateData.actionCard)
        -- 移除牌中吃的牌

        -- 从打出去的牌里面移除牌
        self.playerPannel[beOperateSite]:removeLastPutOutMj()
        self:removeIndicator()
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationCHI", operateSite, 1)

        --音效
        _GameEffectActionChi(sex)
    elseif operateData.actionID == enOperate.OPERATE_PENG then
        -- 合成麻将组
        self.playerPannel[operateSite]:composeMjGroup(content)
        -- 从打出去的牌里面移除牌
        self.playerPannel[beOperateSite]:removeLastPutOutMj()
        self:removeIndicator()
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationPENG", operateSite, 1)

        --音效
        _GameEffectActionPeng(sex);
    elseif operateData.actionID == enOperate.OPERATE_MING_GANG then
        -- 合成麻将组
        self.playerPannel[operateSite]:composeMjGroup(content)
        -- 从打出去的牌里面移除牌
        self.playerPannel[beOperateSite]:removeLastPutOutMj()
        self:removeIndicator()
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)

         --音效
        _GameEffectActionGang(sex);
        self:setHandMjINVAID(operateSite)
    elseif operateData.actionID == enOperate.OPERATE_AN_GANG then
        -- 合成麻将组
        self.playerPannel[operateSite]:composeMjGroup(content)
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)

         --音效
        _GameEffectActionGang(sex);
        self:setHandMjINVAID(operateSite)
    elseif operateData.actionID == enOperate.OPERATE_ZI_MO_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_TIAN_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationTIANHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationTIANHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_DIAN_TIAN_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionHu(sex);
    elseif operateData.actionID == enOperate.OPERATE_DI_HU  or
           operateData.actionID == enOperate.OPERATE_DIAN_DI_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_DIAN_DI_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_DIAN_PAO_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionHu(sex);
    -- 听牌
    elseif operateData.actionID == enOperate.OPERATE_TING then
        self.playerPannel[operateSite]:playActionAnimation("AnimationTING", operateSite, 1)

        --音效
        _GameEffectActionTing(sex);
    elseif operateData.actionID == enOperate.OPERATE_CANCEL_TING then
        local players   = self.gamePlaySystem:gameStartGetPlayers()
        players[operateSite]:setState(enCreatureEntityState.TING, enTingStatus.TING_FALSE)
        if operateSite == enSiteDirection.SITE_MYSELF then
            self.gamePlaySystem:gameStartLogic_setHuMjs()
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, false)
            self:onSelectChahuCardNtf()
        end
        -- 以后需要改动对应的动画
        self.playerPannel[operateSite]:playActionAnimation(nil, operateSite, 1)
    elseif operateData.actionID == enOperate.OPERATE_TIAN_TING then
        self.playerPannel[operateSite]:playActionAnimation("AnimationTIANTING", operateSite, 1)

        --音效
        _GameEffectActionTing(sex);
    -- 补花
    elseif operateData.actionID == enOperate.OPERATE_BU_HUA then
        -- 从手牌里面移除牌
        -- self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation()

        -- _GameEffectActionBuhua(sex or 2);
        -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)

    elseif operateData.actionID == enOperate.OPERATE_CHANGE_FANZI then
        if operateData.actionCard > 0 then
            self:changeTurnLaizi(operateData.actionCard)
        end
        -- 以后需要改动对应的动画
        self.playerPannel[operateSite]:playActionAnimation(nil, operateSite, 1)
     elseif operateData.actionID == enOperate.OPERATE_QIANG_GANG_HU then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);

    elseif operateData.actionID == enOperate.OPERATE_DINGQUE then
        local players = self.gamePlaySystem:gameStartGetPlayers()
        players[operateSite]:setProp(enCreatureEntityProp.DINGQUE_VAL, operateData.actionCard or 0);

        if operateSite == enSiteDirection.SITE_MYSELF and not VideotapeManager.getInstance():isPlayingVideo() then
        else
            local wp = nil;
            if operateSite == enSiteDirection.SITE_LEFT then
               wp = cc.p(320, display.height/2);
            elseif operateSite == enSiteDirection.SITE_OTHER then
               wp = cc.p(display.width/2, display.height - 110);
            elseif operateSite == enSiteDirection.SITE_RIGHT then
               wp = cc.p(display.width - 320, display.height/2);
            elseif operateSite == enSiteDirection.SITE_MYSELF then
               wp = cc.p(display.width/2, 240);
            end
            if wp then
                local deWp = self.m_delegate:getDingQueResultPosition(operateSite);
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_dingque_Anim_start, operateData.actionCard, operateSite, wp, deWp);
            end
        end
        self.playerPannel[operateSite]:onDingqueResult(operateData.actionCard);

        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
    elseif operateData.actionID == enOperate.OPERATE_XIA_PAO
        or operateData.actionID == enOperate.OPERATE_LAZHUANG
        or operateData.actionID == enOperate.OPERATE_ZUO
        or operateData.actionID == enOperate.OPERATE_XIADI then
        -- 拉跑坐事件

        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, operateData.actionID, operateData.actionCard, operateSite);

        -- 发送结束当前状态
        local curState = MjMediator.getInstance():getStateManager():getCurState()
        local stateNtfs = {
            [enGamePlayingState.STATE_START]        = enMjNtfEvent.GAME_FINISH_NTF,
            [enGamePlayingState.STATE_RESUME]       = enMjNtfEvent.GAME_RESUME_FINISH_NTF,
            [enGamePlayingState.STATE_PLAY_CARD]    = enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF,
            [enGamePlayingState.STATE_ACT_ANIMATE]  = enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,
            [enGamePlayingState.STATE_DISTR]        = enMjNtfEvent.GAME_DISPENSE_FINISH_NTF,
        }
        if stateNtfs[curState] then
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(stateNtfs[curState])
        end

        local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local isTrue = playSystem:checkGameStart()
        Log.i("检查开始发牌========>>>", isTrue)
        if isTrue then
            print("game start======>>>>", enMjNtfEvent.GAME_CHECK_START_NTF, isTrue)
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHECK_START_NTF);
        end
    elseif operateData.actionID == enOperate.OPERATE_HAI_DI_LAO then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_DIAN_HAI_DI_LAO then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_GANG_KAI then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    elseif operateData.actionID == enOperate.OPERATE_GANG_HOU_PAO then
        --------------------------回放相关---------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else                              
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionZimo(sex);
    end

end

function jieyangmjGamePlayLayer:onSelectChahuCardNtf()

    print("<janlog> jieyangmjGamePlayLayer:onSelectChahuCardNtf")

    if self.m_chahuPanel then
        self.m_chahuPanel:removeFromParent()
        self.m_chahuPanel = nil
    end
    -- 如果在听之后才能显示胡牌提示, 那么非听牌状态直接return
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    local huHintNeedTing = self.gamePlaySystem:getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if huHintNeedTing and (tingState == enTingStatus.TING_FALSE or tingState == enTingStatus.TING_BTN_OFF) then
        return
    end

    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM);
    local huTable = playSystem:gameStartLogic_getHuMjs();
    Log.i("------GamePlayLayer:onSelectChahuCardNtf", huCards);
    if #huTable == 0 then
        return
    end
    self.m_chahuPanel = MyselfTinPaiOperation.new();
    local tableData = {}
    for i = 1, #huTable do
        if huTable[i] > 0 then --只处理大于0的牌值
            local temp = {
                value = 0,
                text  = "",
            }
            local remain = self:getRemainCard(huTable[i])
            temp.value = huTable[i]
            local fanzi = self.gamePlaySystem:getGameStartDatas().fanzi

            local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
            local itemList = Util.analyzeString_2(palyingInfo.wa);
            for _,v in ipairs(itemList) do
                if v == "baibanzuogui" then
                    fanzi = nil;
                end

                if v == "zhongzuogui" then
                    fanzi = nil;
                end
            end
            remain = (fanzi == temp.value and remain > 0) and remain - 1 or remain --如果是翻子，减掉一张翻出的牌
            temp.text  = "还有" .. remain .. "张"
            table.insert(tableData, temp)
        end
    end
    self.m_chahuPanel:createMjValueImage(tableData)
    --self.tingPanel:addToParent(posX, posY + 20)
    self.m_chahuPanel:addTo(display.getRunningScene())--
    self.m_chahuPanel:setAnchorPoint(cc.p(1, 0.5));
    self.m_chahuPanel:setPosition(cc.p(display.width - 118, 345));
end

function jieyangmjGamePlayLayer:onSelectTingCardNtf(event)
    local value, posX, posY = unpack(event._userdata)
    local huTable = self.operateSystem:getHuCardByTingCard(value)

    if self.tingPanel then
        self.tingPanel:removeFromParent()
        self.tingPanel = nil
    end

    if self.m_gameLayer ~= nil and self.m_gameLayer.getCanDoCardSite then
        if self.m_gameLayer:getCanDoCardSite() ~= enSiteDirection.SITE_MYSELF then
            return
        end
    end
    
    -- 如果在听之后才能显示胡牌提示, 那么非听牌状态直接return
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    local huHintNeedTing = self.gamePlaySystem:getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if huHintNeedTing and (tingState == enTingStatus.TING_FALSE or tingState == enTingStatus.TING_BTN_OFF) then
        return
    end

    if #huTable == 0 then
        return
    end
    self.tingPanel = MyselfTinPaiOperation.new();
    -- self.tingPanel:addTo(self)
    local tableData = {}
    for i=1,#huTable do
        if huTable[i] > 0 then --只处理大于0的牌值
            local temp = {
                value = 0,
                text  = "",
            }

            local remain = self:getRemainCard(huTable[i])
            temp.value = huTable[i]
            local fanzi = self.gamePlaySystem:getGameStartDatas().fanzi

            local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
            local itemList = Util.analyzeString_2(palyingInfo.wa);
            for _,v in ipairs(itemList) do
                if v == "baibanzuogui" then
                    fanzi = nil;
                end

                if v == "zhongzuogui" then
                    fanzi = nil;
                end
            end
            
            remain = (fanzi == temp.value and remain > 0) and remain - 1 or remain --如果是翻子，减掉一张翻出的牌
            temp.text  = "还有"..remain.."张"
            table.insert(tableData, temp)
        end
    end
    self.tingPanel:createMjValueImage(tableData)
    --self.tingPanel:addToParent(posX, posY + 20)
    self.tingPanel:addTo(display.getRunningScene())--
    self.tingPanel:setAnchorPoint(cc.p(0.5,0));
    --self.tingPanel:setPosition(cc.p(display.width*0.5,posY + 25));
    if tableData and #tableData > 30 then
        self.tingPanel:setPosition(cc.p(display.width*0.5, posY));
    else
        self.tingPanel:setPosition(cc.p(display.width*0.5, posY + 25));
    end
end



return jieyangmjGamePlayLayer