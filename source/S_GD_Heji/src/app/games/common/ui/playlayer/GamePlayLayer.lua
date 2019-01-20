-------------------------------------------------------------
--  @file   GamePlayLayer.lua
--  @brief  游戏层
--  @author Zhu Can Qin
--  @DateTime:2016-08-25 17:50:28
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 			= require "app.games.common.Define"
local UIFactory           = require "app.games.common.ui.UIFactory"
local PlayerLeftPanel 	= require("app.games.common.ui.playlayer.PlayerLeftPanel")
local PlayerRightPanel 	= require("app.games.common.ui.playlayer.PlayerRightPanel")
local PlayerOtherPanel 	= require("app.games.common.ui.playlayer.PlayerOtherPanel")
local MjGroups 			= require("app.games.common.ui.playlayer.exhibition.MjGroups")
local Robot 			= require ("app.games.common.ui.playlayer.Robot")
local MJTricks 			= require("app.games.common.custom.MJTricks")
local Mj    			= require "app.games.common.mahjong.Mj"
local MyselfTinPaiOperation  	= require("app.games.common.ui.operatelayer.MyselfTinPaiOperation")
local Indicator = require("app.games.common.ui.playlayer.Indicator")
local GameLayerBase     = import("..GameLayerBase")
local GamePlayLayer = class("GamePlayLayer", GameLayerBase)

--[[
-- @brief  构造函数
-- @param  isResume: 是否是恢复牌局
-- @return void
--]]
function GamePlayLayer:ctor()
	self.playerPannel 	= {}
	-- 获取游戏系统
    self.gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.operateSystem 	= MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
    -- 初始化
    self:initPlayers()

    self.m_handCardNum = -1
end

function GamePlayLayer:setDelegate(delegate)
    self.m_delegate = delegate;
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onShow()

end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onClose()
    -- 移除玩家监听
  	self:removeAllListener()
  	-- 移除桌面麻将
  	for i=1, #self.playerPannel do
  		self.playerPannel[i]:dtor()
  	end

  	if self.tingPanel then
		self.tingPanel:removeFromParent()
		self.tingPanel = nil
	end

    self.m_handCardNum = -1
end

--[[
-- @brief  注册玩家监听
-- @param  void
-- @return void
--]]
function GamePlayLayer:registerPlayerListener()
	self.myPlayerHandle = {}
	local players = self.gamePlaySystem:gameStartGetPlayers()
	-- 游戏开始事件
    table.insert(self.myPlayerHandle, players[enSiteDirection.SITE_MYSELF]:addCustomEventListener(
        enEntityEvent.ENTITY_STATE_CHANGED_NTF,
        handler(self, self.onChangeState)))

    for i=1, #players do
        if i ~= enSiteDirection.SITE_MYSELF then
            table.insert(self.myPlayerHandle, players[i]:addCustomEventListener(
            enEntityEvent.ENTITY_STATE_CHANGED_NTF, function (event)
                local stateid, value, oldvalue = unpack(event._userdata)
                if self.m_delegate ~= nil and self.m_delegate.updatePlayerStatus ~= nil then
                    self.m_delegate:updatePlayerStatus(i, stateid, value, oldvalue)
                end
            end))
        end
    end
end

--[[
-- @brief  注册监听
-- @param  void
-- @return void
--]]
function GamePlayLayer:registerHandleListener()
    Log.i("GamePlayLayer:registerHandleListener")
	self.handlers = {}
	-- 游戏开始事件
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_TING_NTF,
        handler(self, self.onTingBtnEvent)))
	--对牌的处理方式听都是一样的
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_TIAN_TING_NTF,
        handler(self, self.onTingBtnEvent)))

    -- 选择听牌通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_SELECTED_TING_CARD_NTF,
        handler(self, self.onSelectTingCardNtf)))

    -- 取消胡牌框通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_CANCEL_SELECTED_TING_CARD_NTF,
        handler(self, self.onCancelTingNtf)))

    -- 选择查胡通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_SELECTED_CHAHU_NTF,
        handler(self, self.onSelectChahuCardNtf)))

    -- 取消查胡框通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF,
        handler(self, self.onCancelChahuNtf)))

    -- 听牌箭头通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_TING_ARROW_NTF,
        handler(self, self.onTingArrowNtf)))

    --选中麻将检测打出去有相同的变色
    table.insert(self.handlers,MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_SELECTED_CHAPAI_NTF,
        handler(self,self.selectArrOutMj)
    ))

    table.insert(self.handlers,MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_CANCEL_SELECTED_CHAPAI_NTF,
        handler(self,self.canelSelectArrOutMj)
    ))

    table.insert(self.handlers,MjMediator.getInstance():getEventServer():addCustomEventListener(
        MJ_EVENT.MSG_SEND,
        handler(self,self.onMsgSend)
    ))
end

--[[
-- @brief  移除玩家监听
-- @param  void
-- @return void
--]]
function GamePlayLayer:removeAllListener()
   	self:removePlayerListener()
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end

--[[
-- @brief  移除玩家监听
-- @param  void
-- @return void
--]]
function GamePlayLayer:removePlayerListener()
    local players = self.gamePlaySystem:gameStartGetPlayers()
    if players[enSiteDirection.SITE_MYSELF] then
    	-- 移除监听
	    table.walk(self.myPlayerHandle, function(h)
	       players[enSiteDirection.SITE_MYSELF]:removeEventListener(h)
	    end)
    end
    self.myPlayerHandle = {}
end

--[[
-- @brief  初始化玩家版块函数
-- @param  void
-- @return void
--]]

function GamePlayLayer:initPlayers()
	Log.i("GamePlayLayer:initPlayers")
	self:registerPlayerListener()
	self:registerHandleListener()

	self.mjGroups = MjGroups.new()

    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.playerPannel[2] = UIFactory.createPlayerOtherPanel(_gameType, self.mjGroups)
            :addTo(self)
    elseif self.playerCount == 3 then
        self.playerPannel[2]   = UIFactory.createPlayerRightPanel(_gameType, self.mjGroups)
            :addTo(self)

        self.playerPannel[3]    = UIFactory.createPlayerLeftPanel(_gameType, self.mjGroups)
            :addTo(self)
    elseif self.playerCount == 4 then
        self.playerPannel[enSiteDirection.SITE_RIGHT]   = UIFactory.createPlayerRightPanel(_gameType, self.mjGroups)
            :addTo(self)

        self.playerPannel[enSiteDirection.SITE_OTHER]   = UIFactory.createPlayerOtherPanel(_gameType, self.mjGroups)
            :addTo(self)

        self.playerPannel[enSiteDirection.SITE_LEFT]    = UIFactory.createPlayerLeftPanel(_gameType, self.mjGroups)
            :addTo(self)
    end

	self.playerPannel[enSiteDirection.SITE_MYSELF]	= UIFactory.createHandCardsPanel(_gameType, self.mjGroups):addTo(self)
	-- 创建取消托管字，加入到游戏层
	self.substituteBtn = Robot.new()
	self.substituteBtn:setAnchorPoint(0.5,0.5)
	self.substituteBtn:addTo(self, Define.e_zorder_player_layer_substitute)
	-- 默认隐藏
	self.substituteBtn:setVisible(false)
	---------------------------- 测试---------------------------------------------
	-- self.playerPannel[enSiteDirection.SITE_MYSELF]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_RIGHT]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_LEFT]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_OTHER]:composeMjGroup({})
	------------------------------------------------------------------------------
end

--[[
-- @brief  游戏开始函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onGameStart(event)
  	self.substituteBtn:setVisible(false)

    self.m_gameResume = false
    self.m_handCardNum = -1 -- 出牌后就清理掉这个标识
end

--[[
-- @brief  游戏恢复函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onGameResume()
    -- 获取恢复游戏玩家数据
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    local startData = self.gamePlaySystem:getGameStartDatas()
    local status    = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.SUBSTITUTE)
    Log.i("GamePlayLayer:onGameResume", status)
    if status == enSubstitusStatus.SUBSTITUTE then
        Log.i("GamePlayLayer:onGameResume 托管中")
        self:setAutoPlay(true)
        self.substituteBtn:setVisible(true)
    else
        self.substituteBtn:setVisible(false)
    end

    -- 初始化桌面的牌
    self:initDeskCards()
    -- 初始化动作牌组
    self:initActionGroups()
    self:runFanziCard()
    -- 听牌状态灰掉牌
    local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    if players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING) == enTingStatus.TING_TRUE then
    	for i=1,#myCards do
    		myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
    	end
        if (#startData.actions == 0 or (#startData.actions == 1 and startData.actions[1] == enOperate.OPERATE_TING_RECONNECT)) and
             startData.doorCard > 0 then --听牌无动作把牌打出
            self:autoPlayCard(startData.doorCard)
            return
        end
    end

    --门牌恢复正常状态
    local doorCardIndex = 0;
    local tmpDoorCard = nil;
    for i = 1, #myCards do
        if startData.doorCard > 0 and startData.doorCard == myCards[i]:getValue() then
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_VALID);
            tmpDoorCard = myCards[i];
            doorCardIndex = i;
            break;
        end
    end
    --排序，把门牌放最后,手牌顺序前移
    if doorCardIndex > 0 then
        for i = doorCardIndex, #myCards - 1 do
            myCards[i] = myCards[i + 1];
        end
        myCards[#myCards] = tmpDoorCard;
        self.playerPannel[enSiteDirection.SITE_MYSELF]:resetMjListPosition();
    end

    self.m_gameResume = true
end
--[[
-- @brief  初始化桌面牌
-- @param  void
-- @return void
--]]
function GamePlayLayer:initDeskCards()
	local players   = self.gamePlaySystem:gameStartGetPlayers()
	local startData = self.gamePlaySystem:getGameStartDatas()
	for i=1,#players do
		self.playerPannel[i]:initPutOutMj(players[i]:getProp(enCreatureEntityProp.OUT_CARD))
		if i == enSiteDirection.SITE_MYSELF then
			-- 初始化自己的手牌
			self.playerPannel[i]:createMyselfOpenCards(startData.closeCards)
			-- 重新排序
   			self.playerPannel[i]:reSortMjListPosition()
		else
			-- 初始化其他玩家的手牌
			self.playerPannel[i]:createMyselfOpenCards(players[i]:getProp(enCreatureEntityProp.CARD_NUM))
		end
	end
end

--[[
-- @brief  初始动作的牌组
-- @param  void
-- @return void
--]]
function GamePlayLayer:initActionGroups()
    local players = self.gamePlaySystem:gameStartGetPlayers()
    for i = 1, #players do
        local firstCard = players[i]:getProp(enCreatureEntityProp.OPERATE_CARD)         -- 动作牌第一个牌
        local lCardList = players[i]:getProp(enCreatureEntityProp.OPERATE_CARD_LIST)    -- 动作牌数组
        local firstCard = players[i]:getProp(enCreatureEntityProp.OPERATE_CARD)         -- 动作牌第一个牌
        local actType = players[i]:getProp(enCreatureEntityProp.OPERATE_TYPE)           -- 动作类型
        local beopeid = players[i]:getProp(enCreatureEntityProp.BEOPERATER_ID)          -- 被操作玩家的用户id
        local actionCards = players[i]:getProp(enCreatureEntityProp.ACTION_CARD)        -- 动作的牌
        local isTing = players[i]:getState(enCreatureEntityState.TING)                  -- 断线重连时获取听的状态，有些动作牌的显示会根据是否报听有所区别，例如是否翻出牌值

        if #firstCard > 0 then
    		for t=1,#firstCard do
				local beoperateSite = self.gamePlaySystem:getPlayerSiteById(beopeid[t]) or 0
				local cardTable = {}
				if actType[t] == enOperate.OPERATE_CHI then
					cardTable = { firstCard[t], firstCard[t] + 1, firstCard[t] + 2 }
				elseif actType[t] == enOperate.OPERATE_PENG then
					cardTable = { firstCard[t], firstCard[t], firstCard[t] }
				elseif actType[t] == enOperate.OPERATE_MING_GANG
					or actType[t] == enOperate.OPERATE_AN_GANG
                    or actType[t] == enOperate.OPERATE_YANGMA
					or actType[t] == enOperate.OPERATE_JIA_GANG then
		            cardTable = { firstCard[t], firstCard[t], firstCard[t], firstCard[t] }
				end

				local content = {
			    	mjs         = cardTable,  		--麻将的列表
			        actionType  = actType[t],    	--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
			        operator    = i,  				--操作者的座次
			        beOperator  = beoperateSite, 	--被操作的座位，暗杠和加杠不需要传进来
                    actionCard = actionCards[t],         --碰，吃等操作的牌
                    isTing=isTing                        --是否报听
		    	}
	 			self.playerPannel[i]:composeMjGroup(content)
	    	end
        elseif #lCardList > 0 then
            for j, v in pairs(lCardList) do
                if v and #v > 0 then
                    local lBeoperateSite = self.gamePlaySystem:getPlayerSiteById(beopeid[j]) or 0
                    local content =
                    {
                        mjs = v,                        -- 麻将的列表
                        actionType = actType[j],        -- 动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
                        operator = i,                   -- 操作者的座次
                        beOperator = lBeoperateSite,    -- 被操作的座位，暗杠和加杠不需要传进来
                        actionCard = actionCards[j]     -- 碰，吃等操作的牌
                    }
                    self.playerPannel[i]:composeMjGroup(content)
                end
            end
        end --  if #firstCard > 0 then
    end
end

--[[
-- @brief  骰子结束开始发牌函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onTricksEnd()
	self:distrMj()
end
--[[
-- @brief  发麻将函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:distrMj()
	-- 获取游戏数据
	local data 		= self.gamePlaySystem:getGameStartDatas()
	-- 获取所有玩家
	local players   = self.gamePlaySystem:gameStartGetPlayers()
	local myCards 	= data.closeCards
	if data == nil or data == {} then
		return
	end

	-- 把各种发牌方式展现出来
	local diceValue = data.dice[1] + data.dice[2]
	local orderIndex = self:quickTriacks(diceValue)
	local mjTricks = MJTricks.new(1)
    mjTricks:initTriacksCard(orderIndex, diceValue)
	for i=1,#players do
		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.15*i),
				cc.CallFunc:create(function ()
					-- 创建玩家实体对象
					local site = (i - orderIndex + #players)%#players +1
					if enSiteDirection.SITE_MYSELF == site then
						self.playerPannel[site]:runStartDistrAction(self:getRandomCards(myCards), function() end)
                        -- 开局时设置是否有后续动作
                        self.playerPannel[site]:setWaitAction(data.isHaveNextAct)
					else
						if data.firstplay == players[site]:getProp(enCreatureEntityProp.USERID) then

							-------------------回放相关-------------------------------
							if VideotapeManager.getInstance():isPlayingVideo() then
								local userid = players[site]:getProp(enCreatureEntityProp.USERID)
								local palyerInfo = kPlaybackInfo:getStartGameContentByid(userid)
								self.playerPannel[site]:runStartDistrAction(self:getRandomCards(palyerInfo.clC), function() end)
							else
								-- 由于其他玩家没有牌的数据表所以这里虚拟了数据表
								local list = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
								self.playerPannel[site]:runStartDistrAction(list, function() end)
							end
							----------------------------------------------------------------------
							-- -- 由于其他玩家没有牌的数据表所以这里虚拟了数据表
							-- local list = {11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11}
							-- self.playerPannel[site]:runStartDistrAction(list, function() end)
						else
							-------------------回放相关-------------------------------
							if VideotapeManager.getInstance():isPlayingVideo() then
								local userid = players[site]:getProp(enCreatureEntityProp.USERID)
								local palyerInfo = kPlaybackInfo:getStartGameContentByid(userid)
								self.playerPannel[site]:runStartDistrAction(self:getRandomCards(palyerInfo.clC), function() end)
							else
								-- 由于其他玩家没有牌的数据表所以这里虚拟了数据表
								local list = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
								self.playerPannel[site]:runStartDistrAction(list, function() end)
							end
							----------------------------------------------------------------------
							-- local list = {11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11}
							-- self.playerPannel[site]:runStartDistrAction(list, function() end)
						end
					end
				end)
			)
		)
	end
end

--[[
-- @brief  骰子的值确定发牌位置函数
-- @param  void
-- @return 第一个拿牌的玩家id
--]]
function GamePlayLayer:quickTriacks(diceValue)
	-- 获取庄家的座次索引
	local bankerIndex = self.gamePlaySystem:gameStartGetBankerSite()
    if diceValue == 5 or diceValue == 9 then
        if bankerIndex == 1 then
            return 1
        elseif bankerIndex == 2 then
            return 4
        elseif bankerIndex == 3 then
            return 3
        elseif bankerIndex == 4 then
            return 2
        end
    elseif diceValue == 2 or diceValue == 6 or diceValue == 10 then
        if bankerIndex == 1 then
            return 2
        elseif bankerIndex == 2 then
            return 3
        elseif bankerIndex == 3 then
            return 4
        elseif bankerIndex == 4 then
            return 1
        end
    elseif diceValue == 3 or diceValue == 7 or diceValue == 11 then
        if bankerIndex == 1 then
            return 3
        elseif bankerIndex == 2 then
            return 4
        elseif bankerIndex == 3 then
            return 1
        elseif bankerIndex == 4 then
            return 2
        end
    elseif diceValue == 4 or diceValue == 8 or diceValue == 12 then
        if bankerIndex == 1 then
            return 2
        elseif bankerIndex == 2 then
            return 1
        elseif bankerIndex == 3 then
            return 4
        elseif bankerIndex == 4 then
            return 3
        end
    end
    return 1
end

--[[
-- @brief  首次发牌结束函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onMjDistrubuteEnd()
	if self._m_pListener then
		self._m_pListener:setEnabled(true)
	end
	-- 执行番子动画
	self:runFanziCard()
	local myPlayer 	= self.gamePlaySystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
	if myPlayer:getState(enCreatureEntityState.TING) == enTingStatus.TING_TRUE then
		-- 听状态灰掉牌
		local myCards 	= self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
		-- 恢复麻将状态
		for i = 1, #myCards do
			local node = myCards[i]
			node:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
		end
	end
end
--[[
-- @brief  运行番子动画
-- @param  void
-- @return void
--]]
function GamePlayLayer:runFanziCard()
	-- 获取游戏数据
	local data 		= self.gamePlaySystem:getGameStartDatas()
	assert(data ~= nil)
	if data.fanzi and data.fanzi > 0 then
		-- local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	    -- local visibleHeight = cc.Director:getInstance():getVisibleSize().height
		-- local mjElement = Mj.new(enMjType.MYSELF_OUT, data.fanzi)
		-- mjElement:setPosition(cc.p(visibleWidth / 2, visibleHeight / 2))
		-- self:addChild(mjElement)
		-- mjElement:runAction(cc.MoveTo:create(0.5, cc.p(visibleWidth / 2 - 400, visibleHeight - 40)))
        -- local turn = require("app.games.common.custom.MJTurnLaizigou")
        self.turnLaizigou = UIFactory.createMJTurnLaizigou(_gameType, data.fanzi)
        self.turnLaizigou:addTo(self)
	end
end

--[[
-- @brief  设置托管出牌函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:setAutoPlay(bResult)
	assert(type(bResult) == "boolean")
	-- 托管处理
	if bResult then
		Log.i("本家收到托管消息")
	else
		-- 取消托管处理
		Log.i("本家收到取消托管消息")
		local playData 	= self.gamePlaySystem:getPlayCardDatas()
		-- 获取自己对象的数据
		local myPlayer 	= self.gamePlaySystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
		if playData then
			if playData.nextplayerID == myPlayer:getProp(enCreatureEntityProp.USERID) then
				if #playData.actions > 0 then
					local card = playData.doorcard
					if card == 0 then
						card = playData.playCard
					end
					-- 取消托管有操作，点过
					MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_MJ_ACTION, playData.actions[1], 0, card)
				end
			end
		end
	end
end

--[[
-- @brief  打牌函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onPlayCard()
    Log.i("------GamePlayLayer:onPlayCard")
	local playCardData 	= self.gamePlaySystem:getPlayCardDatas()
    -- 收到打牌消息(包括操作栏消息)时设置动作已到达
    self.playerPannel[enSiteDirection.SITE_MYSELF]:setWaitAction(false)
	if playCardData.playCard == 0 then
		-- print("打出的牌值为0")
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, enSiteDirection.SITE_MYSELF)
        self.m_handCardNum = -1 -- 出牌后就清理掉这个标识
	else
		-- Log.i("处理出牌数据: %s打出牌: %s",playCardData, tostring(playCardData.playedbyID), tostring(playCardData.playCard))
        --通过userid获取座次
        local index = self.gamePlaySystem:getPlayerSiteById(playCardData.playedbyID)
		if playCardData.playedbyID == self.gamePlaySystem:getMyUserId() then
			-- 自己出牌落地,发送消息通知外部
			---------------------------回放相关--------------------------------------
			if VideotapeManager.getInstance():isPlayingVideo() then
				-- 打出相应座次的牌
				self:runOnPlayCard(index, playCardData.playCard)
			end
			-------------------------------------------------------------------------
            -- 断线重连后收到打牌消息, 做处理
            if self:needPlayCardAfterResume() then
                self:runOnPlayCard(index, playCardData.playCard)
            end
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, enSiteDirection.SITE_MYSELF)
            self.m_handCardNum = -1 -- 出牌后就清理掉这个标识
		else
			-- 打出相应座次的牌
			self:runOnPlayCard(index, playCardData.playCard)
		end
        local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(index);
        local sex = player:getProp(enCreatureEntityProp.SEX);
        _gamePlayMjEffect(sex or 2, playCardData.playCard);
	end
end
--[[
-- @brief  检测点击的牌是否已经打出或者有动作
-- @param  void
-- @return void
--]]
function GamePlayLayer:selectArrOutMj(event)
    Log.i("GamePlayLayer:selectArrOutMj....","有打出的麻将")
    local players = self.gamePlaySystem:gameStartGetPlayers()
    local mj = unpack(event._userdata)
    Log.i("麻将的值.....", mj:getValue())
    for i = 1, #players do
        local putCard = self.playerPannel[i]:getPutOutCardsList()
        if putCard ~= nil and #putCard > 0 then
            for j,k in pairs(putCard) do
                if k:getValue() == mj:getValue() then
                    k:setMjState(enMjState.MJ_STATE_TOUCH_OUT)
                end
            end
        end
    end
    local group = self.mjGroups:getPutOutObjs()
    if group ~= nil and #group > 0 then
        for m,n in pairs(group) do
            Log.i("n:getValue().........",n:getValue())
            if n:getValue() == mj:getValue() then
                n:setMjState(enMjState.MJ_STATE_TOUCH_OUT)
            end
        end
    end
end
--[[
-- @brief  检测如果手牌有变颜色则取消颜色
-- @param  void
-- @return void
--]]
function GamePlayLayer:canelSelectArrOutMj(event)
    local players   	= self.gamePlaySystem:gameStartGetPlayers()
    for i = 1,#players do
        local putCard = self.playerPannel[i]:getPutOutCardsList()
        if putCard ~= nil and #putCard > 0 then
            for j,k in pairs(putCard) do
                if k:getMjState() == enMjState.MJ_STATE_TOUCH_OUT then
                    k:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
                end
            end
        end
    end
    local group = self.mjGroups:getPutOutObjs()
    if group ~= nil and #group > 0 then
        for m,n in pairs(group) do
            if n:getMjState() == enMjState.MJ_STATE_TOUCH_OUT then
                n:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
            end
        end
    end
end
--[[
-- @brief  拿牌操作函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onDispenseCard()
    local dispenseData 	= self.gamePlaySystem:getDispenseCardDatas()
    -- Log.i("----------------------------GamePlayLayer__onDispenseCard",dispenseData)
    local players   	= self.gamePlaySystem:gameStartGetPlayers()
    for i=1, #players do
        if players[i]:getProp(enCreatureEntityProp.USERID) == dispenseData.userId then

        	if dispenseData.userId == self.gamePlaySystem:getMyUserId() then
                self.playerPannel[i]:hideGuoPai()
    		    -- 重新排序
    			self.playerPannel[i]:reSortMjListPosition()

                ---local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
                --重置查胡数据
                if players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING) ~= enTingStatus.TING_TRUE then
                    self.gamePlaySystem:gameStartLogic_setHuMjs();
                end
    	    end
			-- 创建手牌
            self.playerPannel[i]:createMyselfOpenCards({dispenseData.card})
            self.playerPannel[i]:moveLastMj()
            -- 拿牌结束
    		MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
            break
        end
    end
    if not dispenseData.isHaveNextAct then
    	local dispenseData 	= self.gamePlaySystem:getDispenseCardDatas()
        if players[enSiteDirection.SITE_MYSELF]:getProp(enCreatureEntityProp.USERID) == dispenseData.userId then
        	self:autoPlayCard(dispenseData.card)
            -- 摸牌时无后续动作, 允许出牌
            self.playerPannel[enSiteDirection.SITE_MYSELF]:setWaitAction(false)
        end
    else
        if players[enSiteDirection.SITE_MYSELF]:getProp(enCreatureEntityProp.USERID) == dispenseData.userId then
            -- 摸牌时有后续动作, 禁止出牌, 直至显示操作按钮
            self.playerPannel[enSiteDirection.SITE_MYSELF]:setWaitAction(true)
        end
    end
end

--[[
-- @brief  自动出牌
-- @param  card 打出牌的值
-- @return void
-- 请注意, 调用此函数前需确保操作对象是SITE_MYSELF!!!
--]]
function GamePlayLayer:autoPlayCard(card)
    if VideotapeManager.getInstance():isPlayingVideo() then
        return;
    end
	local gameDatas = self.gamePlaySystem:getGameStartDatas()
	local players   = self.gamePlaySystem:gameStartGetPlayers()

	-- 需要自动补花的
    local flowerCard = false
	if #gameDatas.isFlowers > 0 then
		for i=1,#gameDatas.isFlowers do
			if card == gameDatas.isFlowers[i] then
				flowerCard = true
			end
		end
    end
	--听牌且不是自动补的花牌, 就自动出牌 (将判断是否是自己出牌的逻辑放到调用此函数前)
    if players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING) == enTingStatus.TING_TRUE
    	and not flowerCard then

    	local myCards = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    	local index = #myCards
        if card ~= myCards[index]:getValue() then
            for i = 1, #myCards do
                if card == myCards[i]:getValue() then
                    index = i
                end
            end
        end
    	local posX  = myCards[index]:getPositionX()
    	local posY  = myCards[index]:getPositionY()
    	self.playerPannel[enSiteDirection.SITE_MYSELF]:putOutCard(index, posX, posY, 0.1)
    end
end
--[[
-- @brief  构造函数
-- @param  site 座位
-- @param  cardValue 牌值
-- @return void
--]]
function GamePlayLayer:runOnPlayCard(site, cardValue)
	-- 获取手牌队列
	local outIndex 	= 0
	local mjValue  	= 0
	local myCards 	= self.playerPannel[site]:getHandCardsList()
	assert(myCards ~= 0)
	mjValue 	= cardValue
	-- 自己出的牌需要到手牌里面检索
	-- if site == enSiteDirection.SITE_MYSELF then
	-- 	for i = 1, #myCards do
	-- 		assert(myCards[i] ~= nil)
	-- 		if myCards[i]:getValue() == cardValue then
	-- 			outIndex = i
	-- 			break
	-- 		end
	-- 	end
	-- else
	-- 	-- 托管打出最后一个牌
	-- 	outIndex = #myCards
	-- end

	if VideotapeManager.getInstance():isPlayingVideo() then
		for i = #myCards, 1, -1  do
			-- assert(myCards[i] ~= nil)
			if myCards[i]:getValue() then
				if myCards[i]:getValue() == cardValue then
					outIndex = i
					break
				end
			end
		end
	else
		if site == enSiteDirection.SITE_MYSELF then
			for i = 1, #myCards do
				-- assert(myCards[i] ~= nil)
				if myCards[i]:getValue() == cardValue then
					outIndex = i
					break
				end
			end
		else
			-- 托管打出最后一个牌
			outIndex = #myCards
		end
	end

	-- if site == enSiteDirection.SITE_MYSELF then
		-- for i = 1, #myCards do
		-- 	-- assert(myCards[i] ~= nil)
		-- 	if myCards[i]:getValue() then
		-- 		if myCards[i]:getValue() == cardValue then
		-- 			outIndex = i
		-- 			break
		-- 		end
		-- 	end
		-- end
	-- else
		-- 托管打出最后一个牌
		-- outIndex = #myCards
	-- end

	if outIndex == 0 then
		printError("GamePlayLayer:runOnPlayCard 无效的出牌索引 outIndex = %d site = %d #myCards = %d",
			outIndex, site, #myCards)
		return
	end
	local posx, posy = myCards[outIndex]:getPosition()
	-- 从队列里面移除打出去的麻将对象
	self.playerPannel[site]:removeHandMjByIndex(outIndex)
	-- 处理出牌逻辑，播放出牌动画
	self.playerPannel[site]:runPlayOutAction(cc.p(posx, posy), mjValue, outIndex)
end
--[[
-- @brief  吃碰杠等操作逻辑函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onAction()
	-- 显示吃碰杠摆放的牌
	local operateData 	= self.operateSystem:getOperateSystemDatas()
    -- Log.i("-------------------GamePlayLayer:onAction",operateData)
	self:runActionAnimation(operateData)
	local operateSite   = self.gamePlaySystem:getPlayerSiteById(operateData.userid)
    if operateData.actionID == enOperate.OPERATE_BU_HUA then
		local distrMj = {}
		table.insert(distrMj, operateData.playCard)
        if operateData.playCard > 0 then
    		self.playerPannel[operateSite]:createMyselfOpenCards(distrMj)
            if self.playerPannel[operateSite]:isCanPlayCard(#self.playerPannel[operateSite]:getHandCardsList()) then
        		self.playerPannel[operateSite]:moveLastMj()
            end
    		-- 判断是否有下一个操作
    		if not operateData.isHaveNextAct and operateSite == enSiteDirection.SITE_MYSELF then
    	    	self:autoPlayCard(operateData.playCard)
    	    end
        end
	elseif operateData.actionID ~= enOperate.OPERATE_XIA_PAO 
        and operateData.actionID ~= enOperate.OPERATE_LAZHUANG
        and operateData.actionID ~= enOperate.OPERATE_ZUO
        and operateData.actionID ~= enOperate.OPERATE_XIADI then
        if operateSite == enSiteDirection.SITE_MYSELF then
            if operateData.actionID ~= enOperate.OPERATE_ZI_MO_HU then
                -- 重新排序
                self.playerPannel[operateSite]:reSortMjListPosition();
            end
            --查胡数据
            if operateData.actionID == enOperate.OPERATE_PENG then
                self.gamePlaySystem:gameStartLogic_setHuMjs();
            end

	    end
	end
    -- 收到动作消息时无后续动作, 设置是否有后续补花
    if operateSite == enSiteDirection.SITE_MYSELF then
        self.playerPannel[enSiteDirection.SITE_MYSELF]:setWaitAction(operateData.isHaveNextAct)
    end
	-- 补花，吃，碰要时麻将要移位
	if operateData.actionID == enOperate.OPERATE_BU_HUA
		or operateData.actionID == enOperate.OPERATE_CHI
		or operateData.actionID == enOperate.OPERATE_PENG then
		-- self.playerPannel[operateSite]:moveLastMj()
	end

end

--[[
-- @brief  执行动作动画函数
-- @param  operateData = {
-- 		cbCards,  		--麻将的列表
--     	actionID,    	--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--     	userid,  		--操作者的座次
--     	lastPlayUserId,	--被操作的座位，暗杠和加杠不需要传进来
-- }
-- @return void
--]]
function GamePlayLayer:runActionAnimation(operateData)
	local beOperateSite = self.gamePlaySystem:getPlayerSiteById(operateData.lastPlayUserId)
	local operateSite   = self.gamePlaySystem:getPlayerSiteById(operateData.userid)
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerByUserid(operateData.userid);
    local sex = player:getProp(enCreatureEntityProp.SEX);

	local content = {
    	mjs         = operateData.cbCards,  		--麻将的列表
        actionType  = operateData.actionID,    		--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
        operator    = operateSite,  				--操作者的座次
        -- beOperator  = operateData.lastPlayUserId, --被操作的座位，暗杠和加杠不需要传进来
        beOperator  = beOperateSite, 				--被操作的座位，暗杠和加杠不需要传进来
        actionCard = operateData.actionCard         --操作的牌
    }

    if operateData.actionID == enOperate.OPERATE_JIA_GANG then
    	--content{
		--	mjs 	=  {},  麻将的列表
		--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
		--  operator		操作者的座次 参考 enSiteDirection
		-- }
        -- local lAniInfo = {}
        -- lAniInfo.ArmatureFile = "games/common/mj/armature/addAnimation7.csb"
        -- lAniInfo.Armature = "addAnimation7"
        -- lAniInfo.Animation = "AnimationBUGANG"
        -- self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1)

    	self.playerPannel[operateSite]:setGroupJiaGang(content)
    	-- 从手牌里面移除牌
		self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 0.8)
        --音效
        _GameEffectActionGang(sex);
        self:setHandMjINVAID(operateSite)
    elseif operateData.actionID == enOperate.OPERATE_YANGMA then
        --content{
        --  mjs     =  {},  麻将的列表
        --  actionType      动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
        --  operator        操作者的座次 参考 enSiteDirection
        -- }

        self.playerPannel[operateSite]:setGroupJiaGang(content)
        -- 从手牌里面移除牌
        self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 0.8)
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
        self.playerPannel[operateSite]:playActionAnimation("AnimationCHI", operateSite, 0.8)

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
        self.playerPannel[operateSite]:playActionAnimation("AnimationPENG", operateSite, 0.8)

        --音效
        _GameEffectActionPeng(sex);
    elseif operateData.actionID == enOperate.OPERATE_MING_GANG then
        -- local lAniInfo = {}
        -- lAniInfo.ArmatureFile = "games/common/mj/armature/addAnimation7.csb"
        -- lAniInfo.Armature = "addAnimation7"
        -- lAniInfo.Animation = "AnimationDIANGANG"
        -- self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1)

    	-- 合成麻将组
		self.playerPannel[operateSite]:composeMjGroup(content)
		-- 从打出去的牌里面移除牌
		self.playerPannel[beOperateSite]:removeLastPutOutMj()
		self:removeIndicator()
		-- 从手牌里面移除牌
		self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 0.8)
         --音效
        _GameEffectActionGang(sex);
        self:setHandMjINVAID(operateSite)
	elseif operateData.actionID == enOperate.OPERATE_AN_GANG then
        -- local lAniInfo = {}
        -- lAniInfo.ArmatureFile = "games/common/mj/armature/addAnimation7.csb"
        -- lAniInfo.Armature = "addAnimation7"
        -- lAniInfo.Animation = "AnimationANGANG"
        -- self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1)

		-- 合成麻将组
		self.playerPannel[operateSite]:composeMjGroup(content)
		-- 从手牌里面移除牌
		self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationGANG", operateSite, 0.8)
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
    elseif operateData.actionID == enOperate.OPERATE_DI_HU or
           operateData.actionID == enOperate.OPERATE_DIAN_DI_HU
        then
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
        _GameEffectActionHu(sex);
    elseif operateData.actionID == enOperate.OPERATE_DI_XIA_HU then
        --------------------------回放相关---------------------------
        local lAniInfo = {}
        lAniInfo.ArmatureFile = "games/common/mj/armature/ExtraAnimation03.csb"
        lAniInfo.Armature = "ExtraAnimation03"
        if operateData.HuType == enHuType.TYPE_DI_XIA_SHI_SAN_YAO then
            lAniInfo.Animation = "AnimationDXSHISANYAO"
        elseif operateData.HuType == enHuType.TYPE_SHI_FENG then
            lAniInfo.Animation = "AnimationSHIFENG"
        end

        if VideotapeManager.getInstance():isPlayingVideo() then
            self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1, false)
        else
            self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1)
        end
        --胡时把手牌全制为不能打出状态
        local myCards    = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        for i=1,#myCards do
            myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
        end
        --------------------------------------------------------------
        --音效
        _GameEffectActionHu(sex);
    elseif operateData.actionID == enOperate.OPERATE_GANG_KAI then
        --------------------------回放相关---------------------------
        -- local lAniInfo = {}
        -- lAniInfo.ArmatureFile = "games/common/mj/armature/addAnimation5.csb"
        -- lAniInfo.Armature = "addAnimation5"
        -- lAniInfo.Animation = "AnimationGANGKAI"
        if VideotapeManager.getInstance():isPlayingVideo() then
            -- self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1, false)
            self.playerPannel[operateSite]:playActionAnimation("AnimationHU", operateSite, 1, false)
        else
            -- self.playerPannel[operateSite]:playAnimation(lAniInfo, operateSite, 1)
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
        self.playerPannel[operateSite]:playActionAnimation("AnimationTING", operateSite, 0.8)

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
        self.playerPannel[operateSite]:playActionAnimation("AnimationTIANTING", operateSite, 0.8)

        --音效
        _GameEffectActionTing(sex);
	-- 补花
	elseif operateData.actionID == enOperate.OPERATE_BU_HUA then
		-- 从手牌里面移除牌
		self.playerPannel[operateSite]:removeHandMjAction(operateData)
        self.playerPannel[operateSite]:playActionAnimation("AnimationBUHUA", operateSite, 0.8)

        _GameEffectActionBuhua(sex or 2);
    elseif operateData.actionID == enOperate.OPERATE_CHANGE_FANZI then
        if operateData.actionCard > 0 then
            self:changeTurnLaizi(operateData.actionCard)
        end
        -- 以后需要改动对应的动画
        self.playerPannel[operateSite]:playActionAnimation(nil, operateSite, 0.1)

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
        -- Log.i("检查开始发牌========>>>", isTrue)
        if isTrue then
            -- print("game start======>>>>", enMjNtfEvent.GAME_CHECK_START_NTF, isTrue)
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHECK_START_NTF);
        end
    end
end

--[[
-- @brief  打出的麻将落地函数
-- @param  void
-- @return void
--]]
function GamePlayLayer:onPutDownMj(event)
	local index, x, y = unpack(event._userdata)
    Log.i("GamePlayLayer:onPutDownMj(event)", index, x, y)
    if not index or not x or not y then return end
    if not self.indicator then
        self.indicator = Indicator:new()
        self.indicator:addTo(self)
    end
    self.indicator:setVisible(true)
    self.indicator:setPosition(cc.p(x, y))
end

--[[
-- @brief  移除指示箭头数
-- @param  void
-- @return void
--]]
function GamePlayLayer:removeIndicator()
    if self.indicator then
        self.indicator:setVisible(false)
    end
end

--[[
-- @brief  明牌
-- @param  void
-- @return void
--]]
function GamePlayLayer:onGameOver(delayTime)
	local data 			= self.gamePlaySystem:getGameOverDatas()
	local winnerSite 	= self.gamePlaySystem:getPlayerSiteById(data.winnerId)
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local posX = {
        [Define.site_self] = Define.mj_myCards_position_x,
        [Define.site_right] = self.playerCount == 2 and Define.mj_otherCards_position_x or Define.mj_rightCards_position_x,
        [Define.site_other] = self.playerCount == 3 and Define.mj_leftCards_position_x or Define.mj_otherCards_position_x,
        [Define.site_left] = Define.mj_leftCards_position_x
    }

    local posY = {
        [Define.site_self] = Define.mj_myCards_position_y,
        [Define.site_right] = self.playerCount == 2 and Define.mj_otherCards_position_y or Define.mj_rightCards_position_y,
        [Define.site_other] = self.playerCount == 3 and Define.mj_leftCards_position_y or Define.mj_otherCards_position_y,
        [Define.site_left] = Define.mj_leftCards_position_y
    }
	for i=1, #self.gamePlaySystem:gameStartGetPlayers() do
        local handcards = self.playerPannel[i]:mingPai(data.score[i].closeCards, posX[i], posY[i])
    end
    -- 先要移除玩家的监听
	self:removePlayerListener()

    self:performWithDelay(function ()
        -- 移除桌面麻将
        for i=1, #self.playerPannel do
            self.playerPannel[i]:dtor()
        end
        self.mjGroups:release()
        if self.turnLaizigou then
            self.turnLaizigou:removeFromParent()
            self.turnLaizigou = nil
        end
        self:onCancelChahuNtf();
    end, delayTime)
end

--[[
-- @brief  属性变更通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onChangeState(event)
	local stateid, value, oldvalue = unpack(event._userdata)
	-- 托管状态改变
	if stateid == enCreatureEntityState.SUBSTITUTE then
		if value == enSubstitusStatus.SUBSTITUTE then
			self.substituteBtn:setVisible(true)
		elseif value == enSubstitusStatus.CANCEL then
			self.substituteBtn:setVisible(false)
		end
	elseif stateid == enCreatureEntityState.TING then
		local myCards 	= self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
		if value == enTingStatus.TING_TRUE  then
			for i = 1, #myCards do
				local node = myCards[i]
				node:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
			end
		elseif value == enTingStatus.TING_FALSE then
			-- 恢复麻将状态
			for i = 1, #myCards do
				local node = myCards[i]
				node:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
			end
		end
	end
end

--[[
-- @brief  听状态改变通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onTingBtnEvent(event)
	local myCards 	= self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
	local value = unpack(event._userdata)
	if value then
		local actionData 	= self.operateSystem:getActionDatas()
		local ting 			= actionData.tingCards
		dump(ting)
		-- 灰掉不能听的牌
		for i = 1, #myCards do
			local node = myCards[i]
			node:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
			for j = 0, #ting do
				local mj = ting[j]
				if node:getValue() == mj then
					node:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
					break
				else
					-- node:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
					-- break
				end
			end
		end
	-- 听状态改变
	else
		-- 恢复麻将状态
		for i = 1, #myCards do
			local node = myCards[i]
			node:setMjState(enMjState.MJ_STATE_TOUCH_VALID)
		end
	end
end

--[[
-- @brief  听牌箭头指示
-- @param  void
-- @return void
--]]
function GamePlayLayer:onTingArrowNtf(event)
    local value = unpack(event._userdata)
    local myCards   = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    -- 先清理原有的箭头
    for i = 1, #myCards do
        local arrow = myCards[i]:getChildByName("arrow")
        if arrow then
        	arrow:removeFromParent()
        end
    end

    -- 如果必须听牌后显示胡牌提示, 则在自己未听牌时不显示时直接return
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    local huHintNeedTing = self.gamePlaySystem:getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if huHintNeedTing and (tingState == enTingStatus.TING_FALSE or tingState == enTingStatus.TING_BTN_OFF) then
        return
    end

    local actions = self.operateSystem:getActions()
    local hasReTing = false
    for i, v in ipairs(actions) do
        if v == enOperate.OPERATE_TING_RECONNECT then
            hasReTing = true
            break
        end
    end

    if value and hasReTing and tingState == enTingStatus.TING_TRUE and self.operateSystem:getDoorCard() > 0 then
        for i = 1, #myCards do
            if myCards[i]:getMjState() ~= enMjState.MJ_STATE_TOUCH_INVALID then
                local arrow = display.newSprite("real_res/1004368.png")
                local nodeSize = myCards[i]:getContentSize()
                local arrowSize = arrow:getContentSize()
                arrow:setPosition(cc.p(0, nodeSize.height - 10))
                myCards[i]:addChild(arrow)
                arrow:setName("arrow")
            end
        end
        return
    end

    if value then
        local actionData    = self.operateSystem:getActionDatas()
        local ting          = actionData.tingCards
        if not IsPortrait then -- TODO
            if not ting then
                return
            end
        end
        -- 在能听的牌上面显示箭头
        for i = 1, #myCards do
            local mjValue = myCards[i]:getValue()
            for j = 1, #ting do
                if mjValue == ting[j] then
                    local arrow = display.newSprite("real_res/1004368.png")
                    local nodeSize = myCards[i]:getContentSize()
                    local arrowSize = arrow:getContentSize()
                    arrow:setPosition(cc.p(0, nodeSize.height - 10))
                    myCards[i]:addChild(arrow)
                    arrow:setName("arrow")
                    break
                end
            end
        end
    end
end
--[[
-- @brief  获取麻将剩余个数
-- @param  value
-- @return remain
--]]
function GamePlayLayer:getRemainCard(value)
	local allOutObjs = self:getAllPutOutCard()
	local count = 0
	for i=1,#allOutObjs do
		if allOutObjs[i] and allOutObjs[i].getValue and value == allOutObjs[i]:getValue()  then
			count = count + 1
		end
	end
	remain = 4 - count
	return remain
end

--[[
-- @brief  获取所有打出去的牌
-- @param
-- @return void
--]]
function GamePlayLayer:getAllPutOutCard()
    local allOutCardList = {}
    for i=1, #self.playerPannel do
        -- 遍历每个方位打出去的牌
        local tempOut = self.playerPannel[i]:getPutOutCardsList()
        for t=1, #tempOut do
            table.insert(allOutCardList, tempOut[t])
        end
    end
    local handCards =  self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    for i=1, #handCards do
        -- 遍历自己的手牌
        table.insert(allOutCardList, handCards[i])
    end

    local groupObjs = self.mjGroups:getPutOutObjs()
    for i=1, #groupObjs do
        -- 遍历成组的牌
        table.insert(allOutCardList, groupObjs[i])
    end
    local flowerCards = self.m_gameLayer.m_flowerNode:getFlowerCards()
    if flowerCards then
        for _, cards in pairs(flowerCards) do
            for i = 1, #cards do
                -- 遍历花牌
                table.insert(allOutCardList, cards[i].mjBg)
            end
        end
    end
	return allOutCardList
end

--[[
-- @brief  选中听牌通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onSelectTingCardNtf(event)
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
            remain = (fanzi == temp.value and remain > 0) and remain - 1 or remain --如果是翻子，减掉一张翻出的牌
            remain = (remain <= 0) and 0 or remain
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

--[[
-- @brief  取消听牌通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onCancelTingNtf(event)
	if self.tingPanel then
		self.tingPanel:removeFromParent()
		self.tingPanel = nil
	end
end

--[[
-- @brief  选中查胡通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onSelectChahuCardNtf()

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
            remain = (fanzi == temp.value and remain > 0) and remain - 1 or remain --如果是翻子，减掉一张翻出的牌
            remain = (remain <= 0) and 0 or remain
            temp.text  = "还有" .. remain .. "张"
            table.insert(tableData, temp)
        end
    end
    self.m_chahuPanel:createMjValueImage(tableData)
    --self.tingPanel:addToParent(posX, posY + 20)
    self.m_chahuPanel:addTo(display.getRunningScene())--
    self.m_chahuPanel:setAnchorPoint(cc.p(1, 0.5));
    self.m_chahuPanel:setPosition(cc.p(display.width - 118, Define.mj_ui_chahu_panel_y));
end

--[[
-- @brief  取消听牌通知
-- @param  void
-- @return void
--]]
function GamePlayLayer:onCancelChahuNtf(event)
    if self.m_chahuPanel then
        self.m_chahuPanel:removeFromParent()
        self.m_chahuPanel = nil
    end
end

------------------
-- 改变翻子值
function GamePlayLayer:changeTurnLaizi(mjValue)
    if self.turnLaizigou then
        self.turnLaizigou:changeTo(mjValue)
    end
end

----------------
-- 绑定gamelayer
function GamePlayLayer:setGameLayer(gameLayer)
    self.m_gameLayer = gameLayer
end

---------------
-- 生成乱序手牌
function GamePlayLayer:getRandomCards(cardList)
    local temp = clone(cardList)
    local randomCards = {}
    --把牌打乱
    for i = 1, #temp do
        local random = math.random(#temp)
        table.insert(randomCards, temp[random])
        table.remove(temp, random)
    end
    return randomCards
end

-------------------
-- 当玩家已经处于听牌状态下时, 若可以有其他操作, 则发送消息灰掉手牌
function GamePlayLayer:setHandMjINVAID(operateSite)
    Log.i("GamePlayLayer:setHandMjINVAID()", operateSite)
    if operateSite ~= enSiteDirection.SITE_MYSELF then return end
    local player = self.gamePlaySystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
    local tingState  = player:getState(enCreatureEntityState.TING)
    if tingState == enTingStatus.TING_TRUE then
        self.gamePlaySystem:gameStartLogic_setHuMjs()
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, true)
    end
end

-- 自己出牌后记录下出牌后的手牌数量
function GamePlayLayer:onMsgSend(event)
    if not event then return end
    local msgId = unpack(event._userdata)
    if msgId == enMjMsgSendId.MSG_SEND_TURN_OUT and self.playerPannel[enSiteDirection.SITE_MYSELF] then
        local handCards = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
        if type(handCards) == 'table' then
            self.m_handCardNum = #handCards
        end
    end
end

-- 恢复对局后出牌
function GamePlayLayer:needPlayCardAfterResume()
    if not self.m_gameResume then return false end
    if type(self.m_handCardNum) ~= 'number' or self.m_handCardNum < 1 then return false end

    local handCards = self.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    if type(handCards) ~= 'table' then return false end

    if #handCards % 3 == 2 and #handCards - self.m_handCardNum == 1 then
        return true
    end

    return false
end

return GamePlayLayer
