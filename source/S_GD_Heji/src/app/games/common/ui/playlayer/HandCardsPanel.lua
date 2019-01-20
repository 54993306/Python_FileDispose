-------------------------------------------------------------
--  @file   HandCardsPanel.lua
--  @brief  手牌版块
--  @author Zhu Can Qin
--  @DateTime:2016-08-11 12:01:08
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 		= require "app.games.common.Define"
local timerProxy 	= require "app.common.TimerProxy".new()
local Mj    		= require "app.games.common.mahjong.Mj"
local LocalEvent 	= require "app.hall.common.LocalEvent"
local currentModuleName = ...
local PlayerPanelBase = import(".PlayerPanelBase", currentModuleName)
local HandCardsPanel = class("HandCardsPanel", PlayerPanelBase)
------------------------手牌相关----------------------------------
-- 麻将正常缩进
local kIndentNormal 	= 0
-- 第一个麻将偏移
local kIndentFirst = 10
-- 最后一个麻将缩进
local kIndentLast   	= -20
-- 触摸有效间隔
local kTouchInterval    = 0.1
-- 拖拽的牌打出去超过的高度
local kDragOutHeight    = 40
--local kDragOutWidth     = 60
local kGroupCardNum     = 4 -- 每组牌的个数
local kLaiziPng  = "real_res/1004352.png"
-------------------------盖起来的牌相关---------------------------
-- 盖起来的牌x轴放大系数
local kScaleX 			= 1.661
-- 盖起来的牌y轴的放大系数
local kScaleY 			= 1.75
-- 发牌移动过程中的放大倍数
local kScaleTo          = 2.4
-- 盖着入牌时间
local kMoveTime 		= 0.1
-- 盖上的牌起始位置
local KOutStartPos 		= cc.p(display.cx, display.cy)
-- 盖上的牌移动到的高度
local kMoveEndHeight 	= 250
-------------------------出牌相关---------------------------

-- 出牌运行的时间
local kOutRunTime  		= 0.0001
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
if IsPortrait then -- TODO
	kInsertTime 		= 0.0002
end
------------------------------------------------------------
---------------------------麻将组相关-----------------------
local kGroupGap   		= 20 -- 麻将组间隔
------------------------------------------------------------

--打出牌的动作参数
local outCardMoveToPosY = 260
local outCardMoveTargetTime = 0.12
local outCardTargetScale = 0.7
local outCardSineInTime = 0.1			
local outCardStayTime = 0.5
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:ctor(mjgroups)
	HandCardsPanel.super.ctor(self)

	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	KOutStartPos = cc.p(visibleWidth / 2, visibleHeight / 2)
	-- 存储所有盖起来的牌的对象
	self.closeCardObj 	= {}
	-- 存储打出去的牌的对象
	self.putOutObj   	= {}
	-- 存储结算明牌的对象
	self.overCObj   	= {}
	-- 本地消息表
	self.LocalEvent = {}
	self.handlers = {}
	-- 点击麻将的间隔
	self.clickTimeInterval      = 0
	self.selectedMj 	= nil
	-- 拖拽的麻将对象
	self.dragMj         = nil
	-- 听按钮状态
	self.tingBtnState   = false

	--初始化起始位置
	Define.ViewSizeType = 0
    if Util.isBezelLess() then
        Define.ViewSizeType = 1
    end

    Define.g_pai_out_x = Define.visibleWidth / 2 - 173
    Define.g_pai_out_x_two_player = Define.visibleWidth / 2 - 390
    Define.g_pai_out_x_three_player = Define.visibleWidth / 2 - 214
	Define.g_pai_out_y = Define.visibleHeight / 2 - 60
	
	Define.mj_myCards_position_x = 70
	Define.mj_myCards_position_y = 125
	
    Define.mj_myCards_action_x = Define.visibleWidth / 2 - 560
	Define.mj_myCards_action_y = 125
	
	-- 吃碰杠操作显示起始X轴
    Define.g_action_start_x =       Define.visibleWidth - 160
    -- 吃碰杠操作显示起始Y轴
    Define.g_action_start_y =       140
    if Define.ViewSizeType == 1 then
        Define.mj_myCards_scale = 1
        Define.mj_myCards_position_x = (Define.visibleWidth-1280)/2 + Define.mj_myCards_position_x
        Define.mj_common_scale = 1
        Define.mj_buhua_pos_scale = 1
    end

	-- 手牌起始位置
	self.handCardStartX = Define.mj_myCards_position_x

	self.operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	self.playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	-- 用来标记是否已经是弹起来的麻将，为了方便双击出牌逻辑
	self:onEnter()

	self.mjGroups = mjgroups
	self.m_showGuoQueRen=false;--是否显示过二次确认框

    self.outMjCount = kOutCardEachRow
	self.outMjStartPosX = Define.g_pai_out_x
	
	self._isDragMjAction = false			--是否在执行出牌动画

    -- 正在打牌的动作
    self.m_isPlayingAction = false
    local playerCount = self.playSystem:getGameStartDatas().playerNum
    if playerCount == 2 then
    	self.outMjCount = 20
    	self.outMjStartPosX = Define.g_pai_out_x_two_player
	elseif playerCount == 3 then
		self.outMjCount = 12
		self.outMjStartPosX = Define.g_pai_out_x_three_player
	end
	self:initPassImg()

	
end

function HandCardsPanel:initPassImg()
	self.img_pass = display.newSprite("real_res/1004236.png")
	self.img_pass:setScale(0.9)
	self.img_pass:setVisible(false)
	self.img_pass:setAnchorPoint(0, 0.5)
	self:addChild(self.img_pass)
	local mjElement = Mj.new(enMjType.MYSELF_NORMAL, 11, false)
	local posX = display.width - self.outMjStartPosX + 25
	local posY = mjElement:getContentSize().height + 80
	self.img_pass:pos(posX,posY)

	local passEvent = cc.EventListenerCustom:create(LocalEvent.PassCard, handler(self,self.PassCardState))
	table.insert(self.LocalEvent,passEvent)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(passEvent, 1)

	--监听玩家回到游戏
    table.insert(self.handlers,MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_SET_ENTER_FOREGROUND_NTF,
        handler(self,self.onEnterForeground)
    ))
    local isChooseGuo = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getIsChooseGuo()
	if isChooseGuo then
		self.img_pass:setVisible(true)
 	else
 		self.img_pass:setVisible(false)
	end
end

function HandCardsPanel:PassCardState(event)
	if event.isVisible then
		self.img_pass:setVisible(true)
 	else
 		self.img_pass:setVisible(false)
	end
end

function HandCardsPanel:hideGuoPai()
	self.img_pass:setVisible(false)
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:dtor()
	self:removeAllMj()

	table.walk(self.LocalEvent,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.LocalEvent = {}

    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end
function HandCardsPanel:setkLaiziPng(png)
    kLaiziPng = png
end
--[[
-- @brief  移除所有麻将对象
-- @param  void
-- @return void
--]]
function HandCardsPanel:removeAllMj()
	self:removeOpenCards()
	self:removeCloseCards()
	self:removePutOutCards()
	self:removeOverCards()
end

--[[
-- @brief  移除打开的牌的对象
-- @param  void
-- @return void
--]]
function HandCardsPanel:removeOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:removeFromParent()
		v = nil
	end
	self.handCardsObjs = {}
end

--[[
-- @brief  移除关闭的牌的对象
-- @param  void
-- @return void
--]]
function HandCardsPanel:removeCloseCards()
	for k, v in pairs(self.closeCardObj) do
		v:removeFromParent()
		v = nil
	end
	self.closeCardObj = {}
end

--[[
-- @brief  移除打出去的牌对象
-- @param  void
-- @return void
--]]
function HandCardsPanel:removePutOutCards()
	for k, v in pairs(self.putOutObj) do
		v:removeFromParent()
		v = nil
	end
	self.putOutObj = {}
end

--[[
-- @brief  移除结算明的牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:removeOverCards()
	for k, v in pairs(self.overCObj) do
		v:removeFromParent()
		v = nil
	end
	self.overCObj = {}
end


--[[
-- @brief  移除拖拽的麻将对象
-- @param  void
-- @return void
--]]
function HandCardsPanel:removeDragCards()
	if self.dragMj then
		self.dragMj:removeFromParent()
	end
	self.dragMj = nil
	self.dragMovePos = false
end


--[[
-- @brief  创建手牌手牌
-- @param  cardsList 牌列表 如：{15, 27, 36, 44}
-- @return void
--]]
function HandCardsPanel:createMyselfOpenCards(cardsList)
	local list = 0
	-- 如果是只传进来一个麻将需要转换成table
	if type(cardsList) == "number" then
		list = cardsList
	elseif type(cardsList) == "table" then
		list = #cardsList
	else
		printError("HandCardsPanel:createMyselfOpenCards 无效的数组类型%s", cardsList)
	end
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF, 1);
	for i=1, list do
		-- 创建麻将对象
		local mjElement = Mj.new(enMjType.MYSELF_NORMAL, cardsList[i] or 11, false)
		self:addChild(mjElement, 1)
		local posX = Define.mj_myCards_position_x
		-- 第一个就设置在起始位置
		if nil == self.handCardsObjs[#self.handCardsObjs] then
		else
			-- 获取最后一个麻将的大小
			local size = self.handCardsObjs[#self.handCardsObjs]:getContentSize()
			if self.m_isPlayingAction then -- 如果正在麻将移位中, 则新摸到的麻将的位置直接由手牌数量计算出来
				posX = self.handCardStartX + kIndentFirst + (size.width - kIndentNormal) * #self.handCardsObjs
			else
				posX = size.width + self.handCardsObjs[#self.handCardsObjs]:getPositionX() - kIndentNormal
			end
		end
		mjElement:setPosition(cc.p(posX, Define.mj_myCards_position_y))
		-- table.insert(self.handCardsObjs, mjElement)
		-- 设置癞子
		local laiziList = self.playSystem:getGameStartDatas().laizi
		for k, v in pairs(laiziList)  do
			if mjElement:getValue() == v then
				self:addLaizi(mjElement)
			end
		end
		self:addHandMjObj(mjElement)
	end
end

--[[
-- @brief  添加麻将右上角的赖子角标
-- @param  mjElement 麻将对象
-- @return void
--]]
function HandCardsPanel:addLaizi(mjElement)
    --改变图
    if(GC_TurnLaiziPath_2~=nil) then
	  kLaiziPng = GC_TurnLaiziPath_2
	end
	local laiziPng = display.newSprite(kLaiziPng)
	local size 		= mjElement:getContentSize()
	local pngSize 	= laiziPng:getContentSize()
	laiziPng:setPosition(cc.p(size.width / 2 - pngSize.width / 2, size.height / 2 - pngSize.height / 2))
	mjElement:addChild(laiziPng)
	--因为要从小到大排所以这里要做处理,倒序
	local laiziValue = -100 + mjElement:getValue()
	mjElement:setSortValue(laiziValue)
end

--[[
-- @brief  添加麻将对象，数据和麻将对应
-- @param  obj 麻将对象
-- @return void
--]]
function HandCardsPanel:addHandMjObj(obj)
	local value = obj:getValue()
	self.playSystem:addHandMj(value, 1)
	table.insert(self.handCardsObjs, obj)

	local players   = self.playSystem:gameStartGetPlayers()
    local dingqueVal = players[enSiteDirection.SITE_MYSELF]:getProp(enCreatureEntityProp.DINGQUE_VAL);
    obj:setDingQueType(dingqueVal);
end

--[[
-- @brief  发盖着的牌的动画
-- @param  cardNum 发盖起来牌的张数
-- @param  mjType 麻将类型
-- @param  startPos 起始位置
-- @param  endPos 结束位置
-- @return node 牌组的结点
--]]
function HandCardsPanel:createCloseMjDistrAction(cardNum, mjType, startPos, endPos, time)
	-- 创建发牌的节点
 	local node = display.newNode()
 	node:setAnchorPoint(cc.p(0, 0.5))
	local mjElementList = {}
	-- 宽度
	local mjWidth = 0
	local mjHeight = 0
	self:addChild(node)
	node:setPosition(startPos)
	for i=1, cardNum do
		-- 创建麻将对象
		local mjElement = Mj.new(mjType)
		node:addChild(mjElement)
		local posX = 0
		-- 第一个就设置在起始位置
		if nil == mjElementList[#mjElementList] then

		else
			-- 获取前一个麻将的大小
			local size = mjElementList[#mjElementList]:getContentSize()
			posX = size.width + mjElementList[#mjElementList]:getPositionX() - kIndentNormal
		end
		local mjSize = mjElement:getContentSize()
		mjWidth = mjWidth + mjSize.width * kScaleTo - kIndentNormal
		mjElement:setPosition(cc.p(posX, 0))
		table.insert(mjElementList, mjElement)
		mjHeight = mjSize.height
	end
	node:setContentSize(cc.size(mjWidth, mjHeight))
	node:runAction(cc.Sequence:create(
		-- 边放大边移动
		cc.Spawn:create(
			cc.ScaleTo:create(time, kScaleTo),
			cc.MoveTo:create(time, endPos)
		),
		cc.CallFunc:create(function ()
			node:removeFromParent()
		end)
		)
	)
	return node
end

--[[
-- @brief  创建盖起来的牌
-- @param  cardsNum 盖起来的牌的数量
-- @return void
--]]
function HandCardsPanel:createDistrCards(type, value)

end

--[[
-- @brief  创建盖起来的牌
-- @param  cardsNum 盖起来的牌的数量
-- @return void
--]]
function HandCardsPanel:createMyselfCloseCards(cardsNum)
	for i=1, cardsNum do
		-- 创建麻将对象
		local mjElement = Mj.new(enMjType.EMPTY_MYSELF_GANG)
		self:addChild(mjElement)
		-- 由于盖上的牌没有那么大所以要放大
		mjElement:setScaleX(kScaleX)
		mjElement:setScaleY(kScaleY)
		local posX = Define.mj_myCards_position_x
		-- 第一个就设置在起始位置
		if nil == self.closeCardObj[#self.closeCardObj] then

		else
			-- 获取前一个麻将的大小
			local size = self.closeCardObj[#self.closeCardObj]:getContentSize()
			posX = size.width * kScaleX + self.closeCardObj[#self.closeCardObj]:getPositionX() - kIndentNormal
		end
		local offsetY = 35
		mjElement:setPosition(cc.p(posX, Define.mj_myCards_position_y + offsetY))
		table.insert(self.closeCardObj, mjElement)
	end
end

--[[
-- @brief  创建拖拽的麻将
-- @param  void
-- @return void
--]]
function HandCardsPanel:createDragCards(value)
	self.dragMj = Mj.new(enMjType.MYSELF_NORMAL, value, false)
	self:addChild(self.dragMj,50)
end

--[[
-- @brief  显示打开的牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:showOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:setVisible(true)
	end
end

--[[
-- @brief  隐藏打开的牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:hideOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:setVisible(false)
	end
end

--[[
-- @brief  显示盖下的牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:showCloseCards()
	for k, v in pairs(self.closeCardObj) do
		v:setVisible(true)
	end
end

--[[
-- @brief  隐藏盖下的牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:hideCloseCards()
	for k, v in pairs(self.closeCardObj) do
		v:setVisible(false)
	end
end

--[[
-- @brief  获取手牌列表
-- @param  void
-- @return self.handCardsObjs 手牌列表
--]]
function HandCardsPanel:getHandCardsList()
	return self.handCardsObjs
end

--[[
-- @brief  获取打出去的牌的table列表
-- @param  void
-- @return self.putOutObj 打出去牌的列表
--]]
function HandCardsPanel:getPutOutCardsList()
	return self.putOutObj
end
--[[
-- @brief  获取动作后的牌的对象列表
-- @param  void
-- @return void
--]]
function HandCardsPanel:getmjGroupsList()
    return self.mjGroups
end
--[[
-- @brief  恢复游戏时初始化已经打出去的牌
-- @param  mjList:麻将数值
-- @return
--]]
function HandCardsPanel:initPutOutMj(mjList)
	-- 麻将对象列表
	for i=1,#mjList do
		local mjElement = Mj.new(enMjType.MYSELF_OUT, mjList[i], false)
		self:addChild(mjElement, 0)
		local size = mjElement:getContentSize()
		table.insert(self.putOutObj, mjElement)

		local rowNum = math.modf((#self.putOutObj - 1) / self.outMjCount )
		local column = math.fmod((#self.putOutObj - 1), self.outMjCount )

		mjElement:setPosition(cc.p(
			column * (size.width - kOutColGap) + self.outMjStartPosX,
			-rowNum * (size.height - kOutRowGap) + Define.g_pai_out_y))
	end
end

--[[
-- @brief  通过索引布局手牌函数
-- @param  indexValue:手牌排序索引值
-- @return void
--]]
function HandCardsPanel:layoutHandCardsByIndex(indexValue)

end

function HandCardsPanel:onEnter()
	Log.d("HandCardsPanel:onEnter#######################")
	self.touchListener = cc.EventListenerTouchOneByOne:create()
	self.touchListener:registerScriptHandler( function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	self.touchListener:registerScriptHandler( function(touch, event) return self:onTouchEnd(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
	self.touchListener:registerScriptHandler( function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
	local eventDispatcher = self:getEventDispatcher()

	eventDispatcher:addEventListenerWithSceneGraphPriority(self.touchListener, self)
	self.touchListener:setEnabled(true)

	-- if MjProxy:getInstance()._currRoom and MjProxy:getInstance()._currRoom.isResume == true then
	-- 	self.touchListener:setEnabled(true)
	-- else
	-- 	self.touchListener:setEnabled(false)
	-- end
end
--[[
-- @brief  触摸开始函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:onTouchBegan(touch, event)
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
function HandCardsPanel:onTouchEnd(touch, event)
	Log.d("HandCardsPanel:onTouchEnd")
	if(self:clickPaiGuoLogicHandle()) then
	   Log.d("当前麻将规则，过要二次确认才能出牌");
       return true;
	end
	Log.d("HandCardsPanel:onTouchEnd。。。。。。。。。。。")
	-- 移除拖拽的麻将
	if self.dragMj and self:getSelectedMj() then
		Log.d("抬手并且有拖动的牌...."..self.dragMj:getValue()..self:getSelectedMj():getValue())
		Log.d("有拖拽的牌拖拽出牌........")
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
			Log.d("开始拖拽出牌........")
			Log.d("开始拖拽出牌....")
		    -- 发送开始出牌消息
		    self:dragOutMj(touch)
			-- 移除拖拽的牌
			self:removeDragCards()			
		end
	end
	self:onShowSelectMj()
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

function HandCardsPanel:onEnterForeground()
	self:onShowSelectMj()
	self:setSelectedMj(nil)
	--设置位置
	self:setOperateMjPos(nil)
	self.m_containsMJ = false;
	self._isDragMjAction = false
end

--定缺检测合法
function HandCardsPanel:isDingqueCheckValid(mj)
	local isVilid = true;
	local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM);
    if playSystem:getIsHasDingQue() and not mj:isDingQueType() then
    	for i = 1, #self.handCardsObjs do
			if self.handCardsObjs[i]:isDingQueType() then
				MJToast.getInstance():show("请优先选择定缺牌打出",32);
				self:onShowSelectMj()
				isVilid = false;
				break;
	    	end
		end
    end
	return isVilid;
end
function HandCardsPanel:onShowSelectMj()
	Log.d("显示已经选中的牌")
	local selectMj = self:getSelectedMj()
	Log.d("tolua.type(selectMj).....",tolua.type(selectMj))
	if selectMj and tolua.type(selectMj) == "cc.Node" then
		Log.d("有选中的牌....")
		selectMj:setVisible(true)
	end
	if self.dragMj and tolua.type(self.dragMj) == "cc.Node" then
		self:removeDragCards()
	end
end

--[[
-- @brief  移动函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:onTouchMoved(touch, event)
	-- Log.d("HandCardsPanel:onTouchMoved")
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
			-- Log.d("拖动牌的纵坐标位置...."..pt.y)
			if nil == self.dragMj then
				self:createDragCards(self:getSelectedMj():getValue())
				self.dragMj:setPosition(cc.p(pt.x, pt.y))
				-- self.dragMj = self:getSelectedMj()
				--设置位置
				self:setOperateMjPos(self.dragMj)
				-- Log.d("nil == self.dragMj set false")
				self:getSelectedMj():setVisible(false)
				-- Log.d("创建完拖动牌后隐藏选择牌.."..self.dragMj:getValue())
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
-- @brief  双击出牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:doubleClickPutOutMj(touch)
	-- 判断双击
	-- local intervalTime = os.clock() - self.clickTimeInterval
	local cardIndex = 0
	-- 进入双击麻将处理逻辑
	-- if intervalTime <= 0.4 then
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:isContainsTouch(touch:getLocation().x, touch:getLocation().y)
			and self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
				local flowers = self.playSystem:getGameStartDatas().isFlowers
			    -- 判断是否为花牌
			    if flowers and #flowers > 0 then
		            for j=1, #flowers do
		                if self.handCardsObjs[i]:getValue() == flowers[j] then
							Toast.getInstance():show("花牌不能打出")
							self:onShowSelectMj()
		                	return
		                end
		            end
			    end
			    if self:isDingqueCheckValid(self.handCardsObjs[i]) then
					cardIndex = i
				end
				break;
	    	end
		end
    -- end
	if cardIndex > 0 then
		-- 存储要打出去的牌的数据
		local posx, posy = self.handCardsObjs[cardIndex]:getPosition()
		self:putOutCard(cardIndex, posx, posy)
	end
end

--[[
-- @brief  拖拽出牌
-- @param  void
-- @return void
--]]
function HandCardsPanel:dragOutMj(touch)
	local cardIndex = 0
	-- 进入双击麻将处理逻辑
	for i=1,#self.handCardsObjs do
		local flowers = self.playSystem:getGameStartDatas().isFlowers
	    -- 判断是否为花牌
	    if flowers and #flowers > 0 then
            for j=1, #flowers do
				if self.handCardsObjs[i]:getValue() == flowers[j] then
					Toast.getInstance():show("花牌不能打出")
					self:onShowSelectMj()
                	return
                end
            end
	    end
		if self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
			if self:isDingqueCheckValid(self.handCardsObjs[i]) then
				cardIndex = i
			end
		elseif self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_SELECTED then
			if self:isDingqueCheckValid(self.handCardsObjs[i]) then
				cardIndex = i
			end
		end
	end
	if cardIndex > 0 then
		-- self:setSelectedMj(self.handCardsObjs[cardIndex])
		self:putOutCard(cardIndex, touch:getLocation().x, touch:getLocation().y)
	end
end

--[[
-- @brief  初始化胡的数据
-- @param  void
-- @return void
--]]
function HandCardsPanel:initResumeHuCard(index)
	local mjValue = self.handCardsObjs[index]:getValue()
    local huTable = self.operateSystem:getHuCardByTingCard(mjValue);
    self.playSystem:gameStartLogic_setHuMjs(huTable);
end

------------------
-- 判断是否手动补花
function HandCardsPanel:judgeIsHandBuHua(mjValue)
	local handBuHua = self.playSystem:getGameStartDatas().handFlowers
    if handBuHua and #handBuHua>0 then
        for i = 1, #handBuHua do
            if mjValue == handBuHua[i] then
                return true
            end
        end
    end
    return false
end

--[[
-- @brief  出牌逻辑操作
-- @param  void
-- @return void
--]]
function HandCardsPanel:putOutCard(index, posX, posY, delay)
	Log.d("HandCardsPanel:putOutCard", index, posX, posY, delay)
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

------------------------
-- 发送补花操作
-- mjValue 麻将的值
function HandCardsPanel:sendBuHuaOperate(mjValue)
	Log.d("--sendGuo--HandCardsPanel--sendBuHuaOperate--")
	Log.d(debug.traceback())
    self:sendGuoOperate()

    MjMediator.getInstance():getEventServer():dispatchCustomEvent(
        MJ_EVENT.MSG_SEND,
        enMjMsgSendId.MSG_SEND_MJ_ACTION,
        enOperate.OPERATE_BU_HUA,
        1,
        mjValue,
        {mjValue})
end

------------------------
-- 发送出牌操作
-- mjValue 麻将的值
function HandCardsPanel:sendPlayOutOperate(mjValue)
	local player = self.playSystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
    -- 听状态发送听
	if player:getState(enCreatureEntityState.TING) == enTingStatus.TING_BTN_ON then
		self.operateSystem:sendTingOperate(mjValue)
	elseif player:getState(enCreatureEntityState.TING) == enTingStatus.TIAN_TING_BTN_ON then
		self.operateSystem:sendTianTingOperate(mjValue)
	else
		Log.d("--sendGuo--HandCardsPanel--sendPlayOutOperate--")
		Log.d(debug.traceback())
		self:sendGuoOperate()
		-- 发送打出牌的数据
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_TURN_OUT, mjValue)
	end
end

------------------------
-- 发送过的操作
function HandCardsPanel:sendGuoOperate()
	-- 有操作发送过牌操作
	local needActions = self.operateSystem:getActions()
	if #needActions > 0 then
		Log.d("--sendGuo--HandCardsPanel--sendGuoOperate--")
		Log.d(debug.traceback())
		self.operateSystem:sendGuoOperate()
	end
end

--[[
-- @brief  通过索引从手牌里移除打出去的麻将函数
-- @param  index: 麻将索引
-- @return void
--]]
function HandCardsPanel:removeHandMjByIndex(index)
	self:removeHandMjObj(self.handCardsObjs[index])
	table.remove(self.handCardsObjs, index)
end

--[[
-- @brief  设置选中麻将的对象函数
-- @param  obj 麻将对象
-- @return void
--]]
function HandCardsPanel:setSelectedMj(obj)
	Log.d("setSelectedMj..........",obj)
	-- 设置麻将为选中状态
	if obj then
		obj:setMjState(enMjState.MJ_STATE_SELECTED)
	end
	self.selectedMj = obj
end
--[[
    @brief: 记录被操作麻将的位置
    param:obj 麻将对象
    return void
]]
function HandCardsPanel:setOperateMjPos(obj)
	if obj then
		self._operateMjPosX,self._operateMjPosY = obj:getPosition()
	else
		self._operateMjPosX = 0
		self._operateMjPosY = 0
	end
	-- Log.d("setOperateMjPos........",self._operateMjPosX,self._operateMjPosY)
end
--[[
    @brief: 获取被操作麻将的位置
    param:obj 麻将对象
    return void
]]
function HandCardsPanel:getOperateMjPos()
	Log.d("getOperateMjPos============",self._operateMjPosX,self._operateMjPosY)
	return self._operateMjPosX,self._operateMjPosY
end
--[[
-- @brief  获取麻将的对象函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:getSelectedMj()
	return self.selectedMj
end

--------------------------------------下面是吃碰杠等操作相关函数--------------------------------
--[[
-- @brief  手牌麻将X轴偏移
-- @param  void
-- @return void
--]]
function HandCardsPanel:mjOffsetPos(offsetX)
	for i=1,#self.handCardsObjs do
		local x = self.handCardsObjs[i]:getPositionX()
		-- local y = self.handCardsObjs[i]:getPositionY()
		self.handCardsObjs[i]:setPosition(cc.p(x + offsetX, Define.mj_myCards_position_y))
	end
end

--[[
-- @brief  合成麻将组和
-- @param  void
-- @return void
--]]
function HandCardsPanel:composeMjGroup(content)
	-- 设置麻将组，设置偏移量
	local gap = 0
    -- local content = {
    -- 	mjs         = {32,32,32},  --麻将的列表
    --     actionType  = enOperate.OPERATE_PENG,    	--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
    --     operator    = enSiteDirection.SITE_MYSELF,  --操作者的座次
    --     beOperator  = enSiteDirection.SITE_RIGHT,  	--被操作的座位，暗杠和加杠不需要传进来
    -- }
    local groups  	= self.mjGroups:getMjGroupsBySite(enSiteDirection.SITE_MYSELF)
    local num 		= #groups
    local group  	 = self.mjGroups:addMjGroup(content)
    self:addChild(group)
    if num > 0 then
    	group:setPosition(cc.p(
			groups[num]:getPositionX()
	    	+ groups[num]:getContentSize().width
	    	+ kGroupGap,
			Define.mj_myCards_action_y - 24))
    else
    	group:setPosition(cc.p(
			Define.mj_myCards_action_x,
			Define.mj_myCards_action_y - 24))
    end
   	-- 重设起始位置
   	self.handCardStartX = group:getPositionX() + group:getContentSize().width + kGroupGap
   	-- 重新排序
   	self:reSortMjListPosition()
end

--[[
-- @brief  加杠显示处理
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--  operator		操作者的座次 参考 enSiteDirection
-- }
-- @return void
--]]
function HandCardsPanel:setGroupJiaGang(content)
    self.mjGroups:addJiaGangGroup(content)
end

--[[
-- @brief  移除手牌
-- @param  content
-- @return void
--]]
function HandCardsPanel:removeHandMjAction(content)
	local removeList 	= {} -- 需要移除的对象列表
	local handCardsList = {} -- 剩下手牌的对象列表
	-- 吃
	if content.actionID == enOperate.OPERATE_CHI then

		for i=1,#content.cbCards do
			for t=1, #self.handCardsObjs do
				if  self.handCardsObjs[t]:getValue() == content.cbCards[i] and not self:isContainsObj(removeList, content.cbCards[i]) then
					table.insert(removeList, self.handCardsObjs[t])
					break
				end
			end
		end
	elseif content.actionID == enOperate.OPERATE_PENG then
        --  根据牌组列表移除手牌
        local lCBCard = clone(content.cbCards)
        lCBCard[#lCBCard] = nil --  最后一张牌作为牌桌上的牌，需要先去除
		for i, v in pairs(self.handCardsObjs) do
            local isRemove = false
            for j, k in pairs(lCBCard) do
			    if v:getValue() == k then
				    table.insert(removeList, v)
                    lCBCard[j] = nil
                    isRemove = true
                    break
			    end
            end
            if not isRemove then
			    table.insert(handCardsList, v)
            end
		end
	elseif content.actionID == enOperate.OPERATE_MING_GANG then
        --  根据牌组列表移除手牌
        local lCBCard = clone(content.cbCards)
        lCBCard[#lCBCard] = nil --  最后一张牌作为牌桌上的牌，需要先去除
		for i, v in pairs(self.handCardsObjs) do
            local isRemove = false
            for j, k in pairs(lCBCard) do
			    if v:getValue() == k then
				    table.insert(removeList, v)
                    lCBCard[j] = nil
                    isRemove = true
                    break
			    end
            end
            if not isRemove then
			    table.insert(handCardsList, v)
            end
		end
	elseif content.actionID == enOperate.OPERATE_AN_GANG then
        --  根据牌组列表移除手牌
        local lCBCard = clone(content.cbCards)
		for i, v in pairs(self.handCardsObjs) do
            local isRemove = false
            for j, k in pairs(lCBCard) do
			    if v:getValue() == k then
				    table.insert(removeList, v)
                    lCBCard[j] = nil
                    isRemove = true
                    break
			    end
            end
            if not isRemove then
			    table.insert(handCardsList, v)
            end
		end
	elseif content.actionID == enOperate.OPERATE_JIA_GANG then
        --  根据牌组列表移除手牌
        local lCBCard = clone(content.cbCards)
        if not IsPortrait then -- TODO
	        --  补杠只需要第一张，其他的直接去掉，避免在移除麻将时误删
	        lCBCard[#lCBCard] = nil
	        lCBCard[#lCBCard] = nil
	        lCBCard[#lCBCard] = nil
	    end

		for i, v in pairs(self.handCardsObjs) do
            local isRemove = false
            for j, k in pairs(lCBCard) do
			    if v:getValue() == k then
				    table.insert(removeList, v)
                    lCBCard[j] = nil
                    isRemove = true
                    break
			    end
            end
            if not isRemove then
			    table.insert(handCardsList, v)
            end
		end
	-- 补花
	elseif content.actionID == enOperate.OPERATE_BU_HUA then
		-- 移除补花的牌
		local buhuaFlag = true
		-- 如果保存的补花序列号存在, 且对应的牌值等于花牌的值, 则不重复移除
		if self.buhuaTable and self.buhuaTable[content.actionCard] and #self.buhuaTable[content.actionCard] > 0 then
            table.remove(self.buhuaTable[content.actionCard], #self.buhuaTable[content.actionCard])
            buhuaFlag = false
        end
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:getValue() == content.actionCard
				and buhuaFlag then
				buhuaFlag = false
				table.insert(removeList, self.handCardsObjs[i])
			else
				table.insert(handCardsList, self.handCardsObjs[i])
			end
		end
	end
	-- self.handCardsObjs = handCardsList
	if #removeList > 0 then
		-- 移除手牌麻将并重新排位
		-- self:actionMoveHandMj(removeList)
		for i ,v in pairs(removeList) do
			Log.i("bbbbbb....",v:getValue())
			-- self:removeHandMjObj(v)
			for j,jv in pairs(self.handCardsObjs) do
				
				if self.handCardsObjs[j]:getValue() == v:getValue() then
					self:removeHandMjByIndex(j)
					-- self:removeHandMjObj(self.handCardsObjs[j])
					break
				end
			end
		end
		-- -- 补花会重新摸一张牌
		-- if content.actionID == enOperate.OPERATE_BU_HUA then
		-- 	local distrMj = {}
		-- 	table.insert(distrMj, content.playCard)
		-- 	self:createMyselfOpenCards(distrMj)
		-- end
		-- 重新排序
		self:reSortMjListPosition()
	end
end

--[[
-- @brief  移除打出的最后一张
-- @param  index: 麻将索引
-- @return void
--]]
function HandCardsPanel:removeLastPutOutMj()
	if self.putOutObj and #self.putOutObj > 0 then
		self.putOutObj[#self.putOutObj]:removeFromParent()
		table.remove(self.putOutObj, #self.putOutObj)
	end
end

--[[
-- @brief  移除操作之后的麻将函数
-- @param  list 麻将列表
-- @return void
--]]
function HandCardsPanel:actionMoveHandMj(list)
	for i=1,#list do
		self:removeHandMjObj(list[i])
	end
end

--[[
-- @brief  移除麻将对象函数
-- @param  obj 麻将对象
-- @return void
--]]
function HandCardsPanel:removeHandMjObj(obj)
	if tolua.isnull(obj) then
		return
	end
	if obj == self:getSelectedMj() then
		self:setSelectedMj(nil)
		self:removeDragCards()
	end
	local value = obj:getValue()
	self.playSystem:removeHandMj(value, 1)
	obj:removeFromParent()
end

-- --[[
-- -- @brief  打牌能标志函数
-- -- @param  void
-- -- @return remainder = 1 不可以打牌 remainder = 2 可以打牌
-- --]]
-- function HandCardsPanel:isCanPlayCard()
--     local myCards   = #self.handCardsObjs
--     local remainder = myCards % 3
--     return remainder
-- end

--[[
-- @brief  创建明牌
-- @param  cardsList 牌列表 如：{15, 27, 36, 44}
-- @param  startX 起始X
-- @param  startY 起始Y
-- @return void
--]]
function HandCardsPanel:mingPai(cardsList, startX, startY)
	return self.handCardsObjs
	-- local list = 0

	-- -- 如果是只传进来一个麻将需要转换成table
	-- if type(cardsList) == "number" then
	-- 	list = cardsList
	-- elseif type(cardsList) == "table" then
	-- 	list = #cardsList
	-- else
	-- 	printError("HandCardsPanel:mingPai 无效的数组类型%s", cardsList)
	-- end
	-- local posX = startX
	-- local posY = startY
	-- for i=1, list do
	-- 	-- 创建麻将对象
	-- 	local mjElement = Mj.new(enMjType.MYSELF_OUT, cardsList[i], false)
	-- 	self:addChild(mjElement)
	-- 	-- 第一个就设置在起始位置
	-- 	if 0 == #self.overCObj then

	-- 	else
	-- 		-- 获取最后一个麻将的大小
	-- 		local size = self.overCObj[#self.overCObj]:getContentSize()
	-- 		-- posX = size.width + self.overCObj[#self.overCObj]:getPositionX() - kIndentNormal
	-- 		posX = size.width + self.overCObj[#self.overCObj]:getPositionX()
	-- 	end
	-- 	table.insert(self.overCObj, mjElement)
	-- 	mjElement:setPosition(cc.p(posX, posY))
	-- end
	-- return self.overCObj
end

--[[
-- @brief  点击牌过的相关处理。
-- @param  void
-- @return void
--]]
function HandCardsPanel:clickPaiGuoLogicHandle(touch)
	if(self.m_showGuoQueRen) then --已经显示二次确认框
	  Log.d("已经显示二次确认框");
	  return true;
	end
	--选中的麻将检测
	if(self.m_containsMJ and self.playSystem:getIsHasGuoQueRen()) then --如果点中麻将，防止点中按钮导致逻辑响应处理。
		local actions 	= self.operateSystem:getActions()
		for i = 1, #actions do
			if(actions~=nil and #actions>0) then
				Log.d("获取当前动作",actions[i]);
				if ((actions[i] == enOperate.OPERATE_ZI_MO_HU
						or actions[i] == enOperate.OPERATE_DIAN_PAO_HU
						or actions[i] == enOperate.OPERATE_TIAN_HU) ) then
					if(self.playSystem:getGuoQueRenUIShowOnce() ==false) then --没显示过
						local data = {}
						data.type = 2;
						data.title = "提示";
						data.yesTitle  = "确定";
						data.cancelTitle = "取消";
						data.content = "您确定放弃胡牌吗?"
						data.yesCallback = function()
						   UIManager.getInstance():popWnd(CommonDialog, data);
						   self.m_showGuoQueRen=false;
						   MjMediator:getInstance()._gameLayer.operateLayer:finishStateAndHide()--隐藏操作ui
						end
						data.cancalCallback = function()
						   self.m_showGuoQueRen=false;
						end
						UIManager.getInstance():pushWnd(CommonDialog, data);
						self.playSystem:setGuoQueRenUIShowOnce(true);--对话框只出现一次
						self.m_showGuoQueRen=true;
						self.m_containsMJ=false;--取消点中
						Log.d("点击过要二次确认框");
						return true; --返回不出牌
					end
				end
			end
		end
	else
	  Log.d("没有点中麻将");
	end
	return false;
end

--------------------------------------上面是吃碰杠等操作相关函数--------------------------------
------------------------------------以下是运行动画相关接口----------------------------------------------

--[[
-- @brief  开始游戏时重新排列麻将位置
-- @param  obj 新牌对象
-- @return inPos 需要将obj移到到哪个位置
--]]
function HandCardsPanel:reSortMjListPosition(obj,outIndex)
	-- 设置选中麻将为空
	self:setSelectedMj(nil)
	-- 排序
	local function sortCard(x, y)
		local xValue = x:getSortValue()
		local yValue = y:getSortValue()
		if xValue == yValue then
			return x:getPositionX() < y:getPositionX()
		else
			return xValue < yValue
		end
	end
	table.sort(self.handCardsObjs, sortCard)
	local posY = Define.mj_myCards_position_y
	local inPos = cc.p(0, posY)
	local posX = self.handCardStartX + kIndentFirst
	local mjWidth = self.handCardsObjs[1]:getContentSize().width
	for i=1, #self.handCardsObjs do
		local mj = self.handCardsObjs[i]
		local mjState = mj:getMjState()
		-- 将被选中的牌重置为未选中(注意: 由于在setMjState中检测了Mj的posY, 如果posY == mj_myCards_position_y则无法设置为MJ_STATE_NORMAL, 所以必须先处理)
		if mjState == enMjState.MJ_STATE_ALREADY_SELECTED or mjState == enMjState.MJ_STATE_SELECTED then
			mj:setMjState(enMjState.MJ_STATE_NORMAL)
		end
		if obj == mj then
			inPos.x = posX
			inPos.y = posY
		elseif outIndex == nil 
			or (mj:getSortValue() >= obj:getSortValue() and i <= outIndex) 
			or (mj:getSortValue()<= obj:getSortValue() and i >= outIndex) then
		-- else
			mj:setPosition(cc.p(posX, posY))
		end
		posX = posX + mjWidth
		mj:setVisible(true)
	end
	-- -- 可以出牌的情况下最后一个移位
	if self:isCanPlayCard(#self.handCardsObjs) then
		self:moveLastMj()
		self:cancelHighLight()   --可以出牌时不需要进行高亮的处理
	end
    if not IsPortrait then -- TODO
	    -- --重新排序后表示没有选中的牌
	    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAPAI_NTF)
	end
	return inPos
end

--[[
-- @brief  重置麻将位置
-- @param  obj 新牌对象
-- @return void
--]]
function HandCardsPanel:resetMjListPosition()
	local posX = self.handCardStartX + kIndentFirst
	for i=1, #self.handCardsObjs do
		-- 第一个就设置在起始位置
		if i == 1 then

		else
			-- 获取最后一个麻将的大小
			local size = self.handCardsObjs[i]:getContentSize()
			-- posX = size.width * i - kIndentNormal
			posX = posX + size.width
		end
		self.handCardsObjs[i]:setPosition(cc.p(posX, Define.mj_myCards_position_y))
	end
	-- 可以出牌的情况下最后一个移位
	if self:isCanPlayCard(#self.handCardsObjs) then
		self:moveLastMj()
		self:cancelHighLight()
	end
end

--[[
-- @brief  运行排序动画
-- @param  void
-- @return
--]]
function HandCardsPanel:runStartSortAction(callBack)
	local myCards = self:getHandCardsList()
	-- 创建关闭的牌
	self:createMyselfCloseCards(#myCards)
	self:hideCloseCards()
	self:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.6),
			cc.CallFunc:create(function ()
				self:showCloseCards()
				self:hideOpenCards()
			end),
			cc.DelayTime:create(0.4),
			cc.CallFunc:create(function()
				self:reSortMjListPosition()
				self:showOpenCards()
				-- 移除盖上的牌
				self:removeCloseCards()
			end),
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(function ()
				-- 如果发到14张才需要移位
				if #myCards == 14 then
					myCards[#myCards]:runAction(cc.Sequence:create(
							cc.CallFunc:create(function()
								-- 发牌动画结束,发送消息通知外部
								MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_START_FINISH_NTF)
								callBack()
							end)
						)
					)
				else
					MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_START_FINISH_NTF)
				end
			end)
		)
	)
end

--[[
-- @brief  新模的牌高亮处理
-- @param  obj 麻将对象
-- @return void
--]]
function HandCardsPanel:newDispenseCard(list)
	local totalNum = #list
	for i = 1, totalNum do
		list[i]:highLight(i == totalNum)
	end
end

--[[
-- @brief  移动最后一个麻将
-- @param  mjList:麻将table数组
-- @return
--]]
function HandCardsPanel:moveLastMj()
	local myCards = self:getHandCardsList()
	myCards[#myCards]:setPosition(
		cc.p(myCards[#myCards]:getPositionX() + enHandCardPos.HAND_CARD_LAST_OFFSET,
			myCards[#myCards]:getPositionY()))
	self:newDispenseCard(myCards)
end
--[[
-- @brief  运行开始发牌动画, 外部调用
-- @param  mjList:麻将table数组
-- @return
--]]
function HandCardsPanel:runStartDistrAction(mjList, callBack)
	local temp = {}
	-- 将牌分成不同组，以四个为一组
	for i=1,#mjList do
		local index = math.modf((i-1) / kGroupCardNum)
		if nil == temp[index + 1] then
			temp[index + 1] = {}
		end
		table.insert(temp[index + 1], mjList[i])
	end
	-- local temp2 = {15, 27, 36, 44, 15, 27, 36, 44, 15, 27, 36, 44, 15, 27}
	local sizeWidth = 0
	local totalDelayTime = 0


	for i=1,#temp do
		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(kMoveTime * i),
			cc.CallFunc:create(function ()
				-- 创建分发麻将动画
				local group = self:createCloseMjDistrAction(
					#temp[i],
					enMjType.EMPTY_SHU_PAI,
					KOutStartPos,
					-- cc.p(Define.mj_myCards_position_x + sizeWidth, kMoveEndHeight),
					cc.p(Define.mj_myCards_position_x + (i - 1) * (SELF_HAND_CARD_WIDTH * kGroupCardNum) ,
						kMoveEndHeight),
					kMoveTime
				)
				local size = group:getContentSize()
				sizeWidth = sizeWidth + size.width
			end),
			cc.DelayTime:create(kMoveTime),
			cc.CallFunc:create(function ()
				self:createMyselfOpenCards(temp[i])
			end)
			)
		)
	end
	-- 计算发牌完成所需要的时间，座位播放排序动画的延时
	local delayTime = #temp * kMoveTime + kMoveTime
	-- 延时播放排序动画
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(delayTime),
		cc.CallFunc:create(function ()
			self:runStartSortAction(callBack)
			-- callBack()

		end)
		)
	)
end

--[[
-- @brief  出牌动作 这里的麻将移位逻辑比较麻烦，注意同步麻将表现位置和麻将的对象，这里没有做绑定
-- @param  startPos:出牌的起始坐标
-- @param  OutValue:打出去的牌值
-- @param  indexof:出牌在手里牌的位置的索引
-- @param  handBuhua:是否手动补花
-- @return
--]]
function HandCardsPanel:runPlayOutAction(startPos, OutValue, outIndex, handBuhua, delay)

	-- 设置选中麻将为空
	-- self:setSelectedMj(nil)
	Log.d("HandCardsPanel:runPlayOutAction",startPos, OutValue, outIndex, handBuhua)

	
    if delay == nil then delay = 0 end
    if handBuhua then
    	-- 将打出的补花牌记录下来
        if not self.buhuaTable then
            self.buhuaTable = {}
        end
        if not self.buhuaTable[OutValue] then
            self.buhuaTable[OutValue] = {}
        end
        table.insert(self.buhuaTable[OutValue], outIndex)

        -- 注意, 此时不传入posX和posY, 这样不会显示指示光标
        self:removeOutMj(outIndex)
        return
    end

	local mjElement = Mj.new(enMjType.MYSELF_OUT, OutValue, false)
	if mjElement == nil then
		printError("HandCardsPanel:runPlayOutAction 麻将对象为空")
	end

	self:addChild(mjElement, 0)
	-- 获取出牌的位置
	-- local posx, posy = mjObj:getPosition()
	mjElement:setPosition(startPos)
	table.insert(self.putOutObj, mjElement)
	local size = mjElement:getContentSize()
	local rowNum = math.modf((#self.putOutObj - 1) / self.outMjCount )
	local column = math.fmod((#self.putOutObj - 1), self.outMjCount )

	local endX = column * (size.width - kOutColGap) + self.outMjStartPosX
	local endY = -rowNum * (size.height - kOutRowGap) + Define.g_pai_out_y
	local pos = cc.p(endX, endY)
	Log.d("位置信息。。。。",#self.putOutObj,column,self.outMjStartPosX,endX)
	mjElement:setPosition(pos)
	
	self:removeOutMj(outIndex, endX, endY)
	-- 获取出的牌到结束点的距离，用来运算播放动画时间
	local runtime = 0.2 --math.abs(startPos.x - endX) * kOutRunTime
	-- if delay > 0 then
	-- 	mjElement:setVisible(false)
	-- end
	if tolua.isnull(delay) then
		delay = 1
	end
	
	local mjObj = Mj.new(enMjType.MYSELF_OUT, OutValue, false)
	mjObj:setScale(2)
	mjObj:setPosition(cc.p(startPos))
	self:addChild(mjObj,100)
	mjObj:setVisible(true)
	--由于可能跳帧所以运动完之后强制设置位置
	mjObj:runAction(cc.Sequence:create(
		cc.Spawn:create(cc.ScaleTo:create(outCardMoveTargetTime,outCardTargetScale),
			cc.FadeOut:create(outCardMoveTargetTime) ,
			cc.EaseSineOut:create(cc.MoveTo:create(outCardMoveTargetTime,pos))
		),
		cc.CallFunc:create(function ()
			mjObj:removeFromParent()
			self._isDragMjAction = false
		end)
	))
	-- mjObj:runAction(cc.Sequence:create(
	-- 	-- 播放出牌的动作
	-- 	cc.DelayTime:create(delay),
	-- 	cc.Spawn:create(
	-- 		cc.EaseExponentialOut:create(cc.MoveTo:create(runtime, pos)), -- 减速移动
	-- 		cc.CallFunc:create(function ()
	-- 			-- 设置选中麻将为空
	-- 			self:setSelectedMj(nil)
	-- 			-- 从队列里面移除打出去的麻将对象
	-- 			self:removeHandMjByIndex(outIndex)
	-- 			self:removeOutMj(outIndex, endX, endY)
	-- 		end)
	-- 		)
	-- 	)
	-- )

    -- if delay > 0 then
	-- 	local mjDelayElement = Mj.new(enMjType.MYSELF_NORMAL, OutValue, false)
	-- 	mjDelayElement:setPosition(startPos)
	-- 	self:addChild(mjDelayElement, 0)
	-- 	mjDelayElement:runAction(cc.Sequence:create(
	-- 		-- 播放出牌的动作
	-- 		cc.DelayTime:create(delay),
	-- 		cc.CallFunc:create(function ()
	-- 			mjDelayElement:removeFromParent()
	-- 		end)
	-- 		)
	-- 	)
    -- end
end

----------------------
-- 移除手上的麻将并通知外部
-- outIndex 打出牌的位置
-- posX 出牌指示光标的位置X
-- posY 出牌指示光标的位置Y
function HandCardsPanel:removeOutMj(outIndex, posX, posY)
	-- 取摸到的牌
	local getNewObj = self.handCardsObjs[#self.handCardsObjs]
	-- 重新排序
	local endPos = self:reSortMjListPosition(getNewObj,outIndex)
	-- 取得新牌在手牌里的索引
	local indexof = table.indexof(self.handCardsObjs, getNewObj)

	-- 判断是否是打出最后一个麻将，因为打出最后一个麻将不用处理移位逻辑
	-- 因为outIndex是没有移除打出牌时的索引，所以这里判断是大于号
	if outIndex > #self.handCardsObjs then
		-- 出最后的牌不用移位
	elseif indexof == #self.handCardsObjs then -- 如果新摸的牌可以直接移动到最后的位置, 则不需要插入
		getNewObj:setPosition(endPos)
	else
		-- 出牌结束处理逻辑,播放移动插入牌动画
		self:runMoveInsertAction(endPos, getNewObj)
	end

	self:cancelHighLight()
	-- 出牌落地,发送消息通知外部
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, enSiteDirection.SITE_MYSELF, posX, posY)
end

--[[
-- @brief  出牌后取消高亮处理
-- @param  void
-- @return void
--]]
function HandCardsPanel:cancelHighLight()
	local myCards = self:getHandCardsList()
	for _,mj in ipairs(myCards) do
			mj:highLight(false)
	end
end

--[[
-- @brief  运行麻将凸起动画函数
-- @param  void
-- @return void
--]]
function HandCardsPanel:runActionOutStanding(touchPoint, handCard)
	if handCard:isContainsTouch(touchPoint:getLocation().x, touchPoint:getLocation().y) then
         -- 设置选中的麻将对象

--        local data =
--    {
--        CardIDList = { 21, 22 },
--        Config =
--        {
--            MaxCol = 5,
--            ColGap = 1,
--            RowGap = 1,
--        }
--    }
--    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TURN_CARD_NTF, data)

		MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SELECTED_CHAPAI_NTF, handCard)
		--设置位置
		self:setOperateMjPos(handCard)
		if handCard:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
			-- 设置选中的麻将对象
			self:setSelectedMj(handCard)
		 	return
		end
		self:setSelectedMj(handCard)
		
         --选中了麻将
		-- 发送选中麻将通知
		local player     = self.playSystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)
		local actions 	 = self.operateSystem:getActions()
		for i=1,#actions do
			if actions[i] == enOperate.OPERATE_TING
				or actions[i] == enOperate.OPERATE_TIAN_TING
				or actions[i] == enOperate.OPERATE_TING_RECONNECT then

				if self.m_isPlayingAction then
					break
				end

				local posX = handCard:getPositionX()
				local posY = handCard:getPositionY()
				local value = handCard:getValue()
				MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SELECTED_TING_CARD_NTF, value, posX, posY)
				break
			end
		end
	else
		-- 设置麻将为正常状态
		handCard:setMjState(enMjState.MJ_STATE_NORMAL)
		-- self:setSelectedMj(nil)
	end
end
--[[
-- @brief  播放牌移位插入动画
-- @param  endPos: 结束位置
-- @param  moveObj:移动的对象
-- @return void
--]]
function HandCardsPanel:runMoveInsertAction(endPos, moveObj)
	if nil == moveObj then
		return
	end
	local startX = moveObj:getPositionX()
	local startY = moveObj:getPositionY()
	local runtime = 0.1 -- math.abs(startX - endPos.x) * kInsertTime
	if startY < Define.mj_myCards_position_y then
		startY = Define.mj_myCards_position_y
	end

	self.m_isPlayingAction = true
	moveObj:runAction(cc.Sequence:create(
		-- cc.DelayTime:create(0.1), -- 避免手牌排序时卡顿, 延后0.1秒执行动画
		-- 上升过程
		cc.MoveTo:create(0.05, cc.p(startX, startY + enHandCardPos.STANDING_HEIGHT + 80)),
		-- 右移过程
		cc.MoveTo:create(runtime, cc.p(endPos.x, startY + enHandCardPos.STANDING_HEIGHT + 80)),
		-- 下降过程
		cc.MoveTo:create(0.05, cc.p(endPos.x, startY)),
		-- 强制设置为默认高度
		cc.CallFunc:create(function()
			moveObj:setPosition(cc.p(endPos.x, Define.mj_myCards_position_y))
			self.m_isPlayingAction = false
			end)
		)
	)
end

function HandCardsPanel:onDingqueResult(result)
	for k, v in pairs(self.handCardsObjs) do
		v:setDingQueType(result)
	end
	self:reSortMjListPosition();
end



----------------------------
function HandCardsPanel:setWaitAction(needWaitAction)
	Log.d("setWaitAction", needWaitAction)
	self.needWaitAction = needWaitAction
end

function HandCardsPanel:getWaitAction()
	-- dump(self.needWaitAction)
	return self.needWaitAction or false
end
---------------------------------------------------------------------------------------------------

return HandCardsPanel
