--
-- Author: Jinds
-- Date: 2017-07-05 09:22:23
--
local Define 		= require "app.games.common.Define"
local timerProxy 	= require "app.common.TimerProxy".new()
local Mj    		= require "app.games.common.mahjong.Mj"
local LocalEvent 	= require "app.hall.common.LocalEvent"
local currentModuleName = ...
local HandCardsPanel = require("app.games.common.ui.playlayer.HandCardsPanel")
local zhaoqingmjHandCardsPanel = class("zhaoqingmjHandCardsPanel", HandCardsPanel)
------------------------手牌相关----------------------------------
-- 麻将正常缩进
local kIndentNormal 	= 0
-- 最后一个麻将缩进
local kIndentLast   	= -20
-- 触摸有效间隔
local kTouchInterval    = 0.1
-- 拖拽的牌打出去超过的高度
local kDragOutHeight    = 30
local kGroupCardNum     = 4 -- 每组牌的个数
local kLaiziPng  = "games/common/mj/games/laizijiaobiao.png"
-------------------------盖起来的牌相关---------------------------
-- 盖起来的牌x轴放大系数
local kScaleX 			= 1.661
-- 盖起来的牌y轴的放大系数
local kScaleY 			= 1.75
-- 发牌移动过程中的放大倍数
local kScaleTo          = 2.4
-- 盖着入牌时间
local kMoveTime 		= 0.3
-- 盖上的牌起始位置
local KOutStartPos 		= cc.p(display.cx, display.cy)
-- 盖上的牌移动到的高度
local kMoveEndHeight 	= 250
-------------------------出牌相关---------------------------

-- 出牌运行的时间
local kOutRunTime  		= 0.00025
-- 每一行摆放牌个数
local kOutCardEachRow   = 10
-- 打出去的牌行间距
local kOutRowGap    	= 16
-- 打出去的牌列间距
local kOutColGap   	 	= 1
-- 摆放出牌的X轴起始位置
-- local kPutOutOffsetX 	= 475
-- local kPutOutOffsetX 	= display.width / 2

-- 摆放出牌的Y轴起始位置
-- local kPutOutOffsetY 	= 265
-- 插入牌时间参数
local kInsertTime 		= 0.00025
------------------------------------------------------------
---------------------------麻将组相关-----------------------
local kGroupGap   		= 20 -- 麻将组间隔
------------------------------------------------------------


--[[
-- @brief  移动函数
-- @param  void
-- @return void
--]]
function zhaoqingmjHandCardsPanel:onTouchMoved(touch, event)

-- 增加最后一轮不让拖动牌
-----------------------------------------------------------------------------------------------------------
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    local remainCrads = SystemFacade:getInstance():getRemainPaiCount()
    if remainCrads < 0 then
        remainCrads = 0
    end

    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
	dump(palyingInfo.wa)
	local noOutLastFour = false;

	if string.find(palyingInfo.wa,"buchushou") then
		noOutLastFour = true
	end
	Log.d("<jinds>: noOutLastFour ", noOutLastFour)

	Log.d("<jinds>: refresh card: ", remainCrads, playerCount)
	local lastTurn = (remainCrads < playerCount) --是不是最后一轮

	if lastTurn then
		if noOutLastFour then
			Toast.getInstance():show("最后一轮不出手")
	    	return
	    end
	end

-----------------------------------------------------------------------------------------------

	Log.d("HandCardsPanel:onTouchMoved")
	if not self:isCanPlayCard(#self.handCardsObjs) or self._isDragMjAction then
		return
	end
	if self.canPlay then
		self.startPosX = self:getSelectedMj():getPositionX()
		self.startPosY = self:getSelectedMj():getPositionY()
	end

	-- 创建拖拽的牌
	if not tolua.isnull(self:getSelectedMj())then
--		if self:getSelectedMj():isContainsDragTouch(touch:getLocation().x, touch:getLocation().y) then
		local pt = touch:getLocation()
		
		if pt.y > Define.mj_myCards_position_y + enHandCardPos.STANDING_HEIGHT then
			if nil == self.dragMj then
				self:createDragCards(self:getSelectedMj():getValue())
				self.dragMj:setPosition(cc.p(pt.x, pt.y))
				-- self.dragMj = self:getSelectedMj()
				--设置位置
				self:setOperateMjPos(self.dragMj)
				self:getSelectedMj():setVisible(false)
			end
		end
	end
	-- 设置拖拽的牌的位置
	if self.dragMj then
		self.dragMj:setPosition(cc.p(touch:getLocation().x, touch:getLocation().y))
		return
	end
end



--[[
-- @brief  触摸开始函数
-- @param  void
-- @return void
--]]
function zhaoqingmjHandCardsPanel:onTouchBegan(touch, event)

-- 增加最后一轮不让出牌
-----------------------------------------------------------------------------------------------------------
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    local remainCrads = SystemFacade:getInstance():getRemainPaiCount()
    if remainCrads < 0 then
        remainCrads = 0
    end

    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
	dump(palyingInfo.wa)
	local noOutLastFour = false;

	if string.find(palyingInfo.wa,"buchushou") then
		noOutLastFour = true
	end
	Log.d("<jinds>: noOutLastFour ", noOutLastFour)

	Log.d("<jinds>: refresh card: ", remainCrads, playerCount)
	local lastTurn = (remainCrads < playerCount) --是不是最后一轮

	if lastTurn then
		if noOutLastFour then
			Toast.getInstance():show("最后一轮不出手")
	    	return
	    end
	end

-----------------------------------------------------------------------------------------------

	Log.d("HandCardsPanel:onTouchBegan")
	if self.canTouchFlag == false then
		return false
	end
	self.canTouchFlag = false
	local function touchBeganCanTouch()
		self.canTouchFlag = true
	end
	-- 触摸有效间隔
	timerProxy:addTimer("ww_mj_playLayer_onTouchBegan", touchBeganCanTouch, kTouchInterval)
	-- 隐藏规则显示
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_setRuleVisible, false)
	-- 动画播放状态不能出牌
	local currState = MjMediator:getInstance():getStateManager():getCurState()
	if currState == enGamePlayingState.STATE_ACT_ANIMATE or currState == enGamePlayingState.STATE_START then
		return false
	end
	--定缺完成才能出牌
    if self.playSystem:getIsHasDingQue() then
    	local players = self.playSystem :gameStartGetPlayers()

    	local dingqueVal = players[enSiteDirection.SITE_RIGHT]:getProp(enCreatureEntityProp.DINGQUE_VAL);
	    if dingqueVal == 0 then
	        return false;
	    end
    end
    local pt = touch:getLocation()
    self.m_touchBeganX = pt.x
    self.m_touchBeganY = pt.y
    --每次点击都把颜色设置为白色
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAPAI_NTF)
	-- 选中的麻将检测
	local contains = false
	for i=1, #self.handCardsObjs do
		if self.handCardsObjs[i]:isContainsTouch(touch:getLocation().x, touch:getLocation().y) then
			contains = true
			self.m_containsMJ = true; --点中麻将
			Log.d("--点中麻将");
			if self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_TOUCH_INVALID or self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_CANT_TOUCH then
				Log.d("不可出")
				return false
			end
		end

		if self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_SELECTED then
		 	self.handCardsObjs[i]:setMjState(enMjState.MJ_STATE_ALREADY_SELECTED)
		end
		--运行麻将凸起效果
		self:runActionOutStanding(touch, self.handCardsObjs[i])
	end

	if not contains then
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_TING_CARD_NTF)
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
	end
	return true
end


--[[
-- @brief  触摸结束函数
-- @param  void
-- @return void
--]]
function zhaoqingmjHandCardsPanel:onTouchEnd(touch, event)

-- 增加最后一轮不让出牌
-----------------------------------------------------------------------------------------------------------
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    local remainCrads = SystemFacade:getInstance():getRemainPaiCount()
    if remainCrads < 0 then
        remainCrads = 0
    end

    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
	dump(palyingInfo.wa)
	local noOutLastFour = false;

	if string.find(palyingInfo.wa,"buchushou") then
		noOutLastFour = true
	end
	Log.d("<jinds>: noOutLastFour ", noOutLastFour)

	Log.d("<jinds>: refresh card: ", remainCrads, playerCount)
	local lastTurn = (remainCrads < playerCount) --是不是最后一轮

	if lastTurn then
		if noOutLastFour then
			Toast.getInstance():show("最后一轮不出手")
	    	return
	    end
	end

-----------------------------------------------------------------------------------------------

	Log.d("HandCardsPanel:onTouchEnd")
	if(self:clickPaiGuoLogicHandle()) then
	   Log.d("当前麻将规则，过要二次确认才能出牌");
       return true;
    end
	-- 移除拖拽的麻将
	if self.dragMj and self:getSelectedMj() then
        local pt = touch:getLocation()
		-- 拖拽出牌条件
--        local selectMjPosX = self:getSelectedMj():getPositionX()
--        local selectMjPosY = self:getSelectedMj():getPositionY()
--        local selectMjSize = self:getSelectedMj():getContentSize()
        local difference_x = pt.x - self.m_touchBeganX
        local difference_y = pt.y - self.m_touchBeganY
        local cos =(difference_y) / math.abs(difference_x)
       Log.d("拖动牌的距离....",self.dragMj:getPositionX(),self.dragMj:getPositionY())
		local z_leng = math.sqrt(difference_x*difference_x + difference_y*difference_y)
		-- if not self._isDragMjAction then
		-- 	self.dragMj:setPosition(cc.p(pt.x,pt.y))
		-- 	self._isDragMjAction = true
		-- end
       Log.d("最终距离,",cos,z_leng)
        if ((cos >= 1 and z_leng > kDragOutHeight) 
            or (self.dragMj and self.dragMj:getPositionY() >= Define.mj_myCards_position_y + enHandCardPos.STANDING_HEIGHT))
			and not self:getWaitAction() and self:isCanPlayCard(#self.handCardsObjs) then
		    -- 发送开始出牌消息
		    self:dragOutMj(touch)
			-- 移除拖拽的牌
			self:removeDragCards()
		else
			self:onShowSelectMj()
			
		end
		
--	else
	end
	self:setSelectedMj(nil)
	--设置位置
	self:setOperateMjPos(nil)
	-- 双击出牌
	if not self:getWaitAction() and self:isCanPlayCard(#self.handCardsObjs) and not self._isDragMjAction then
		self:doubleClickPutOutMj(touch)
	end
	self.m_containsMJ = false;
	self._isDragMjAction = false
	return true
end


function zhaoqingmjHandCardsPanel:putOutCard(index, posX, posY)
    Log.d("zhaoqingmjHandCardsPanel:putOutCard", index, posX, posY)
	-- 增加最后一轮不让出牌
-----------------------------------------------------------------------------------------------------------
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    local remainCrads = SystemFacade:getInstance():getRemainPaiCount()
    if remainCrads < 0 then
        remainCrads = 0
    end

    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
	dump(palyingInfo.wa)
	local noOutLastFour = false;

	if string.find(palyingInfo.wa,"buchushou") then
		noOutLastFour = true
	end
	Log.d("<jinds>: noOutLastFour ", noOutLastFour)

	Log.d("<jinds>: refresh card: ", remainCrads, playerCount)
	local lastTurn = (remainCrads < playerCount) --是不是最后一轮

	if lastTurn then
		if noOutLastFour then
			Toast.getInstance():show("最后一轮不出手")
	    	return
	    end
	end
-----------------------------------------------------------------------------------------------

	local mjValue = self.handCardsObjs[index]:getValue()
	local player = self.playSystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)

	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF, 2);

	-- -- --查胡数据
	local huTable = self.operateSystem:getHuCardByTingCard(mjValue);
	if #huTable > 0 then
		Log.d("------putOutCard huTable", huTable);
		self.playSystem:gameStartLogic_setHuMjs(huTable);
	end

    -- 隐藏指示箭头
    self:performWithDelay(function()
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
        end, 0.05)

	-- 从队列里面移除打出去的麻将对象
	self:removeHandMjByIndex(index)
	-- 处理出牌逻辑，播放出牌动画
	self:runPlayOutAction(cc.p(posX, posY), mjValue, index, self:judgeIsHandBuHua(mjValue), delay)
	-- 手动补花的流程不同
	if self:judgeIsHandBuHua(mjValue) then
        self:sendBuHuaOperate(mjValue)
	else
		self:performWithDelay(function() -- 考虑到性能因素, 延迟0.2秒发送消息(以及其他处理)
				self:sendPlayOutOperate(mjValue)
			end, 0.2)
	end

	-- 打牌通知
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_PLAY_CARD_NTF, mjValue)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_TING_CARD_NTF)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
    -- 取消选中的麻将对象
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAPAI_NTF)
end




return zhaoqingmjHandCardsPanel