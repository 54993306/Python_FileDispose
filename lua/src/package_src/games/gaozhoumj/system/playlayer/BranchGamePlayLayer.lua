
local GamePlayLayer = require("app.games.common.ui.playlayer.GamePlayLayer")

local Define 			= require "app.games.common.Define"
local MjGroups 			= require("app.games.common.ui.playlayer.exhibition.MjGroups")
local Robot 			= require ("app.games.common.ui.playlayer.Robot")

local FanMaAnimation = require "package_src.games.gaozhoumj.games.ui.fanma.FanMaAnimation"

local BranchGamePlayLayer = class("BranchGamePlayLayer",GamePlayLayer)

function BranchGamePlayLayer:ctor()
    self.super.ctor(self)
end


function BranchGamePlayLayer:onAction()
    self.super.onAction(self)
end



--function BranchGamePlayLayer:runActionAnimation(operateData)
--	local beOperateSite = self.gamePlaySystem:getPlayerSiteById(operateData.lastPlayUserId)
--	local operateSite   = self.gamePlaySystem:getPlayerSiteById(operateData.userid)
--    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerByUserid(operateData.userid);
--    local sex = player:getProp(enCreatureEntityProp.SEX);

--	local content = {
--    	mjs         = operateData.cbCards,  		--麻将的列表
--        actionType  = operateData.actionID,    		--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--        operator    = operateSite,  				--操作者的座次
--        -- beOperator  = operateData.lastPlayUserId, --被操作的座位，暗杠和加杠不需要传进来
--        beOperator  = beOperateSite, 				--被操作的座位，暗杠和加杠不需要传进来
--        actionCard = operateData.actionCard         --操作的牌
--    }

--    if operateData.actionID == enOperate.OPERATE_JIA_GANG then
--    	--content{
--		--	mjs 	=  {},  麻将的列表
--		--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--		--  operator		操作者的座次 参考 enSiteDirection
--		-- }

--    	self.playerPannel[operateSite]:setGroupJiaGang(content)
--    	-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)
--        --音效
--        _GameEffectActionGang(sex);
--        self:setHandMjINVAID(operateSite)
--    elseif operateData.actionID == enOperate.OPERATE_CHI then
--    	-- 合成麻将组
--		self.playerPannel[operateSite]:composeMjGroup(content)
--		--移除吃了别家的牌，防止删除手中相同牌
--		table.removebyvalue(operateData.cbCards,operateData.actionCard)
--        -- 移除牌中吃的牌

--		-- 从打出去的牌里面移除牌
--		self.playerPannel[beOperateSite]:removeLastPutOutMj()
--		self:removeIndicator()
--		-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationCHI", operateSite, 1)

--        --音效
--        _GameEffectActionChi(sex)
--    elseif operateData.actionID == enOperate.OPERATE_PENG then
--    	-- 合成麻将组
--		self.playerPannel[operateSite]:composeMjGroup(content)
--		-- 从打出去的牌里面移除牌
--		self.playerPannel[beOperateSite]:removeLastPutOutMj()
--		self:removeIndicator()
--		-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationPENG", operateSite, 1)

--        --音效
--        _GameEffectActionPeng(sex);
--    elseif operateData.actionID == enOperate.OPERATE_MING_GANG then
--    	-- 合成麻将组
--		self.playerPannel[operateSite]:composeMjGroup(content)
--		-- 从打出去的牌里面移除牌
--		self.playerPannel[beOperateSite]:removeLastPutOutMj()
--		self:removeIndicator()
--		-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)

--         --音效
--        _GameEffectActionGang(sex);
--        self:setHandMjINVAID(operateSite)
--	elseif operateData.actionID == enOperate.OPERATE_AN_GANG then
--		-- 合成麻将组
--		self.playerPannel[operateSite]:composeMjGroup(content)
--		-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 1)

--         --音效
--        _GameEffectActionGang(sex);
--        self:setHandMjINVAID(operateSite)
--	elseif operateData.actionID == enOperate.OPERATE_ZI_MO_HU then
--		--------------------------回放相关---------------------------
--		if VideotapeManager.getInstance():isPlayingVideo() then
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
--		else
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
--		end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--    	for i=1,#myCards do
--    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--    	end
--		--------------------------------------------------------------
--        --音效
--        _GameEffectActionZimo(sex);
--    elseif operateData.actionID == enOperate.OPERATE_TIAN_HU then
--		--------------------------回放相关---------------------------
--		if VideotapeManager.getInstance():isPlayingVideo() then
--			self.playerPannel[operateSite]:playActionAnimation("AnimationTIANHU", operateSite, 1, false)
--		else
--			self.playerPannel[operateSite]:playActionAnimation("AnimationTIANHU", operateSite, 1)
--		end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--    	for i=1,#myCards do
--    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--    	end
--		--------------------------------------------------------------
--        --音效
--        _GameEffectActionZimo(sex);
--    elseif operateData.actionID == enOperate.OPERATE_DI_HU then
--        --------------------------回放相关---------------------------
--        if VideotapeManager.getInstance():isPlayingVideo() then
--            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
--        else
--            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
--        end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--        for i=1,#myCards do
--            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--        end
--        --------------------------------------------------------------
--        --音效
--        _GameEffectActionZimo(sex);
--    elseif operateData.actionID == enOperate.OPERATE_DIAN_TIAN_HU then
--		--------------------------回放相关---------------------------
--		if VideotapeManager.getInstance():isPlayingVideo() then
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
--		else
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
--		end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--    	for i=1,#myCards do
--    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--    	end
--		--------------------------------------------------------------
--        --音效
--        _GameEffectActionHu(sex);




--        elseif operateData.actionID == enOperate.OPERATE_QIANG_GANG_HU then
--		--------------------------回放相关---------------------------
--		if VideotapeManager.getInstance():isPlayingVideo() then
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
--		else
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
--		end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--    	for i=1,#myCards do
--    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--    	end
--		--------------------------------------------------------------

--        --音效
--        _GameEffectActionHu(sex);








--	elseif operateData.actionID == enOperate.OPERATE_DIAN_PAO_HU then
--		--------------------------回放相关---------------------------
--		if VideotapeManager.getInstance():isPlayingVideo() then
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
--		else
--			self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1)
--		end
--        --胡时把手牌全制为不能打出状态
--        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
--    	for i=1,#myCards do
--    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
--    	end
--		--------------------------------------------------------------
--        --音效
--        _GameEffectActionHu(sex);
--	-- 听牌
--	elseif operateData.actionID == enOperate.OPERATE_TING then
--		self.playerPannel[operateSite]:playActionAnimation("AnimationTING", operateSite, 1)

--        --音效
--        _GameEffectActionTing(sex);
--    elseif operateData.actionID == enOperate.OPERATE_CANCEL_TING then
--        local players   = self.gamePlaySystem:gameStartGetPlayers()
--        players[operateSite]:setState(enCreatureEntityState.TING, enTingStatus.TING_FALSE)
--        if operateSite == enSiteDirection.SITE_MYSELF then
--            self.gamePlaySystem:gameStartLogic_setHuMjs()
--            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, false)
--            self:onSelectChahuCardNtf()
--        end
--        -- 以后需要改动对应的动画
--        self.playerPannel[operateSite]:playActionAnimation(nil, operateSite, 1)
--    elseif operateData.actionID == enOperate.OPERATE_TIAN_TING then
--		self.playerPannel[operateSite]:playActionAnimation("AnimationTIANTING", operateSite, 1)

--        --音效
--        _GameEffectActionTing(sex);
--	-- 补花
--	elseif operateData.actionID == enOperate.OPERATE_BU_HUA then
--		-- 从手牌里面移除牌
--		self.playerPannel[operateSite]:removeHandMjAction(operateData)
--		self.playerPannel[operateSite]:playActionAnimation("AnimationBUHUA", operateSite, 0.7)

--        _GameEffectActionBuhua(sex or 2);
--    elseif operateData.actionID == enOperate.OPERATE_CHANGE_FANZI then
--        if operateData.actionCard > 0 then
--            self:changeTurnLaizi(operateData.actionCard)
--        end
--        -- 以后需要改动对应的动画
--        self.playerPannel[operateSite]:playActionAnimation(nil, operateSite, 1)

--    elseif operateData.actionID == enOperate.OPERATE_DINGQUE then
--        local players = self.gamePlaySystem:gameStartGetPlayers()
--        players[operateSite]:setProp(enCreatureEntityProp.DINGQUE_VAL, operateData.actionCard or 0);

--        if operateSite == enSiteDirection.SITE_MYSELF and not VideotapeManager.getInstance():isPlayingVideo() then
--        else
--            local wp = nil;
--            if operateSite == enSiteDirection.SITE_LEFT then
--               wp = cc.p(320, display.height/2);
--            elseif operateSite == enSiteDirection.SITE_OTHER then
--               wp = cc.p(display.width/2, display.height - 110);
--            elseif operateSite == enSiteDirection.SITE_RIGHT then
--               wp = cc.p(display.width - 320, display.height/2);
--            elseif operateSite == enSiteDirection.SITE_MYSELF then
--               wp = cc.p(display.width/2, 240);
--            end
--            if wp then
--                local deWp = self.m_delegate:getDingQueResultPosition(operateSite);
--                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_dingque_Anim_start, operateData.actionCard, operateSite, wp, deWp);
--            end
--        end
--        self.playerPannel[operateSite]:onDingqueResult(operateData.actionCard);

--        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
--    elseif operateData.actionID == enOperate.OPERATE_XIA_PAO
--        or operateData.actionID == enOperate.OPERATE_LAZHUANG
--        or operateData.actionID == enOperate.OPERATE_ZUO
--        or operateData.actionID == enOperate.OPERATE_XIADI then
--        -- 拉跑坐事件
--        MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_LAPAOZUO_EVENT, operateData.actionID, operateData.actionCard, operateSite);

--        -- 发送结束当前状态
--        local curState = MjMediator.getInstance():getStateManager():getCurState()
--        local stateNtfs = {
--            [enGamePlayingState.STATE_START]        = enMjNtfEvent.GAME_FINISH_NTF,
--            [enGamePlayingState.STATE_RESUME]       = enMjNtfEvent.GAME_RESUME_FINISH_NTF,
--            [enGamePlayingState.STATE_PLAY_CARD]    = enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF,
--            [enGamePlayingState.STATE_ACT_ANIMATE]  = enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,
--            [enGamePlayingState.STATE_DISTR]        = enMjNtfEvent.GAME_DISPENSE_FINISH_NTF,
--        }
--        if stateNtfs[curState] then
--            MjMediator.getInstance():getEventServer():dispatchCustomEvent(stateNtfs[curState])
--        end

--        local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
--        local isTrue = playSystem:checkGameStart()
--        Log.i("检查开始发牌========>>>", isTrue)
--        if isTrue then
--            print("game start======>>>>", enMjNtfEvent.GAME_CHECK_START_NTF, isTrue)
--            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHECK_START_NTF);
--        end
--    end
--end




return BranchGamePlayLayer


