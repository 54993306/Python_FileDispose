-------------------------------------------------------------
--  @file   PlayerRightPanel.lua
--  @brief  lua 类定义
--  @author Zhu Can Qin
--  @DateTime:2016-08-18 14:07:36
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 		= require "app.games.common.Define"
local Mj    		= require "app.games.common.mahjong.Mj"
local currentModuleName = ...
local PlayerPanelBase = import(".PlayerPanelBase", currentModuleName)
local PlayerRightPanel = class("PlayerRightPanel", PlayerPanelBase)

-----------------拿到手的牌相关系数------------------------
local kIndentNormal   = 36
-- 最后一个牌的偏移量
local kLastOffset     = 20
local kGroupCardNum     = 4 -- 每组牌的个数
-----------------------------------------------------------
--------------------盖起来的牌相关-------------------------
-- 盖起来的牌x轴放大系数
local kScaleX 		= 1
-- 盖起来的牌y轴的放大系数
local kScaleY 		= 1
-- 盖着入牌时间
local kMoveTime 	= 0.1
-- 盖起来的牌的两个牌间的缩进间距
local kIndentClose  = 3
-- 出牌动画的起始位置
local KOutStartPos  = cc.p(display.cy, display.cx)
-----------------------------------------------------------

-------------------------出牌相关---------------------------
-- 出牌运行的时间
local kOutRunTime  		= 0.1
-- 每一行摆放牌个数
local kOutCardEachRow   = 10
-- 打出去的牌行间隙
local kOutRowGap    	= 1
-- 打出去的牌列间隙
local kOutColGap   	 	= 15

------------------------------------------------------------
---------------------------麻将组相关-----------------------
local kGroupGap   		= 10 -- 麻将组间隔
------------------------------------------------------------
local putOutObjNumber = 0; --获取打出牌的个数（跟打出对比防止删除了还取操作）

--打牌动画参数
local outCardMoveToPosX = display.width + 240
local outCardMoveTargetTime = 0.06 
local outCardTargetScale = 0.3
local outCardSineInTime = 0.06
local outCardStayTime = 0.5
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function PlayerRightPanel:ctor(mjgroups)
	PlayerRightPanel.super.ctor(self)
	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	self.operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	self.playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	KOutStartPos = cc.p(visibleWidth / 2, visibleHeight / 2)
	-- 存储所有盖起来的牌的对象
	self.closeCardObj 	= {}
	-- 存储打出去的牌的对象
	self.putOutObj   	= {}
	-- 存储结算明牌的对象
	self.overCObj   	= {}
	self.mjGroups 	= mjgroups

	--初始化起始位置
	Define.mj_rightCards_position_x = Define.visibleWidth - 180
	Define.mj_rightCards_position_y = Define.visibleHeight / 2 - 158
	Define.g_right_pai_start_y = Define.visibleHeight / 2 - 160
    Define.g_right_action_pai_start_y = Define.visibleHeight / 2 - 200
    Define.g_right_pai_out_x = Define.visibleWidth / 2 + 235
    Define.g_right_pai_out_y = Define.visibleHeight / 2 - 65
    Define.g_right_pai_x = Define.visibleWidth  - 192
    Define.g_right_pai_action_x = Define.visibleWidth - 280
    Define.g_right_show_pai_x = Define.visibleWidth - 227

	self.m_showMjBg = nil

	self.mjLocalZOrder = 1 --  麻将层级
	self.handCardStartY = Define.mj_rightCards_position_y

	--获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

	self.outMjCount = self.playerCount == 3 and 12 or kOutCardEachRow
	self.outMjStartPosY = self.playerCount == 3 and Define.g_right_pai_out_y + 58 or Define.g_right_pai_out_y

	self.site = enSiteDirection.SITE_RIGHT
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function PlayerRightPanel:dtor()
	self:removeAllMj()
end
--[[
-- @brief  移除所有麻将对象
-- @param  void
-- @return void
--]]
function PlayerRightPanel:removeAllMj()
	self:removeOpenCards()
	self:removeCloseCards()
	self:removePutOutCards()
	self:removeOverCards()
	-- self.mjGroups:release()
end

--[[
-- @brief  移除打开的牌的对象
-- @param  void
-- @return void
--]]
function PlayerRightPanel:removeOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:removeFromParent()
		v = nil
	end
	self.handCardsObjs = {}
end

function PlayerRightPanel:onDingqueResult(result)
	if VideotapeManager.getInstance():isPlayingVideo() then
		for k, v in pairs(self.handCardsObjs) do
			v:setDingQueType(result)
		end
		self:reSortMjListPosition();
	end
end

--[[
-- @brief  移除关闭的牌的对象
-- @param  void
-- @return void
--]]
function PlayerRightPanel:removeCloseCards()
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
function PlayerRightPanel:removePutOutCards()
	for k, v in pairs(self.putOutObj) do
		v:removeFromParent()
		v = nil
	end
	self.putOutObj = {}

    if self.m_showMjBg ~= nil then
        self.m_showMjBg:removeFromParent();
        self.m_showMjBg = nil;
    end
end

--[[
-- @brief  移除结算明的牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:removeOverCards()
	for k, v in pairs(self.overCObj) do
		v:removeFromParent()
		v = nil
	end
	self.overCObj = {}
end

--[[
-- @brief  创建盖起来的牌
-- @param  cardsNum 盖起来的牌的数量
-- @return void
--]]
function PlayerRightPanel:createMyselfCloseCards(cardsNum)
	for i=1, cardsNum do
		-- 创建麻将对象
		local mjElement = Mj.new(enMjType.EMPTY_RIGHT_GANG)
		self:addChild(mjElement, -#self.closeCardObj)
		-- 由于盖上的牌没有那么大所以要放大
		mjElement:setScaleX(kScaleX)
		mjElement:setScaleY(kScaleY)
		-- local posY = Define.mj_rightCards_position_y
		local posY = Define.mj_rightCards_position_y + 8
		-- 第一个就设置在起始位置
		if nil == self.closeCardObj[#self.closeCardObj] then

		else
			-- 获取前一个麻将的大小
			local size = self.closeCardObj[#self.closeCardObj]:getContentSize()
			posY = self.closeCardObj[#self.closeCardObj]:getPositionY() + size.height * kScaleY - kIndentClose
		end
		mjElement:setPosition(cc.p(Define.mj_rightCards_position_x, posY))
		table.insert(self.closeCardObj, mjElement)

		local players   = self.playSystem:gameStartGetPlayers()
    	local dingqueVal = players[enSiteDirection.SITE_RIGHT]:getProp(enCreatureEntityProp.DINGQUE_VAL);
    	mjElement:setDingQueType(dingqueVal);
	end
end

--[[
-- @brief  运行开始发牌动画
-- @param  mjList:麻将table数组
-- @return
--]]
function PlayerRightPanel:runStartDistrAction(mjList, callBack)
	local temp = {}
	-- 将牌分成不同组，以四个为一组
	for i=1,#mjList do
		local index = math.modf((i-1) / kGroupCardNum)
		if nil == temp[index + 1] then
			temp[index + 1] = {}
		end
		table.insert(temp[index + 1], mjList[i])
	end
	local sizeHeight = 0
	local totalDelayTime = 0
	for i=1,#temp do
		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(kMoveTime * i),
			cc.CallFunc:create(function ()
				-- 创建分发麻将动画
				local group = self:createCloseMjDistrAction(
					#temp[i],
					enMjType.EMPTY_HENG_PAI,
					KOutStartPos,
					cc.p(Define.mj_rightCards_position_x,
						Define.mj_rightCards_position_y + (i - 1) * (RIGHT_HAND_CARD_HEIGHT * kGroupCardNum)),
					kMoveTime
				)
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
			self:runStartSortAction(mjList)
			callBack()
			-- -- -- 测试出牌逻辑
			-- local mjList = {15, 27, 36, 44, 15, 27, 36, 44, 15, 27, 36, 44, 15, 27, 35, 34, 33, 32, 31, 31}
			-- self:initPutOutMj(mjList)
		end)
		)
	)
end

--[[
-- @brief  恢复游戏时初始化已经打出去的牌
-- @param  mjList:麻将数值
-- @return
--]]
function PlayerRightPanel:initPutOutMj(mjList)
	-- 麻将对象列表
	for i=1,#mjList do
		local mjElement = Mj.new(enMjType.RIGHT_OUT, mjList[i], false)
		self:addChild(mjElement, -#self.putOutObj)
		local size = mjElement:getContentSize()
		table.insert(self.putOutObj, mjElement)
		local rowNum = math.modf((#self.putOutObj - 1) / self.outMjCount )
		local column = math.fmod((#self.putOutObj - 1), self.outMjCount )
		mjElement:setPosition(cc.p(
			Define.g_right_pai_out_x + rowNum * (size.width - kOutRowGap),
			self.outMjStartPosY + column * (size.height - kOutColGap)))
	end
end

--[[
-- @brief  发盖着的牌的动画
-- @param  cardNum 发盖起来牌的张数
-- @param  mjType 麻将类型
-- @param  startPos 起始位置
-- @param  endPos 结束位置
-- @return node 牌组的结点
--]]
function PlayerRightPanel:createCloseMjDistrAction(cardNum, mjType, startPos, endPos, time)
	-- 创建发牌的节点
 	local node = display.newNode()
 	node:setAnchorPoint(cc.p(0, 0))
	local mjElementList = {}
	-- 宽度
	local mjHeight = 0
	self:addChild(node)
	node:setPosition(startPos)
	for i=1, cardNum do
		-- 创建麻将对象
		local mjElement = Mj.new(mjType)
		node:addChild(mjElement, -i)
		mjElement:setScaleX(kScaleX)
		mjElement:setScaleY(kScaleY)
		local posY = 0
		-- 第一个就设置在起始位置
		if nil == mjElementList[#mjElementList] then

		else
			-- 获取前一个麻将的大小
			local size = mjElementList[#mjElementList]:getContentSize()
			posY = size.height * kScaleY + mjElementList[#mjElementList]:getPositionY() - kIndentClose

		end
		local mjSize = mjElement:getContentSize()
		mjHeight = mjHeight + mjSize.height * kScaleY - kIndentClose
		mjElement:setPosition(cc.p(0, posY))
		table.insert(mjElementList, mjElement)
		node:setContentSize(cc.size( mjSize.width, mjHeight))
	end

	node:runAction(cc.Sequence:create(
		cc.MoveTo:create(time, endPos),
		cc.CallFunc:create(function ()
			node:removeFromParent()
		end)
		)
	)
	return node
end

--[[
-- @brief  创建手牌手牌
-- @param  mjList 牌列表
-- @return void
--]]
function PlayerRightPanel:createMyselfOpenCards(mjList)
	local list = 0
	-- 如果是只传进来一个麻将需要转换成table
	if type(mjList) == "number" then
		list = mjList
	elseif type(mjList) == "table" then
		list = #mjList
	else
		printError("PlayerRightPanel:createMyselfOpenCards 无效的数组类型%s", mjList)
	end
	for i=1, list do
		-- 创建麻将对象
		----------------回放相关-------------------
		local mjElement
		local gap = 0
		self.mjLocalZOrder = self.mjLocalZOrder - 1
		if VideotapeManager.getInstance():isPlayingVideo() then
			mjElement = Mj.new(enMjType.RIGHT_PENG, mjList[i], true)
			-- self.mjLocalZOrder = self.mjLocalZOrder - 1
			-- mjElement:setLocalZOrder(self.mjLocalZOrder)
			gap = -20

			local players   = self.playSystem:gameStartGetPlayers()
    		local dingqueVal = players[enSiteDirection.SITE_RIGHT]:getProp(enCreatureEntityProp.DINGQUE_VAL);
    		mjElement:setDingQueType(dingqueVal);
		else
			mjElement = Mj.new(enMjType.EMPTY_RIGHT_IDLE)
			-- self.mjLocalZOrder = self.mjLocalZOrder + 1
			mjElement:setLocalZOrder(self.mjLocalZOrder)
		end
		----------------------------------------------
		-- local mjElement = Mj.new(enMjType.EMPTY_RIGHT_IDLE)
		if IsPortrait then -- TODO
			self:addChild(mjElement,1)
		else
			self:addChild(mjElement)
		end
		mjElement:setLocalZOrder(self.mjLocalZOrder)
		local posY = Define.mj_rightCards_position_y
		-- 第一个就设置在起始位置
		if nil == self.handCardsObjs[#self.handCardsObjs] then

		else
			-- 获取最后一个麻将的大小
			local size = self.handCardsObjs[#self.handCardsObjs]:getContentSize()
			-- posY = self.handCardsObjs[#self.handCardsObjs]:getPositionY() - kIndentNormal + size.height
			posY = self.handCardsObjs[#self.handCardsObjs]:getPositionY() + size.height + gap
		end
		mjElement:setPosition(cc.p(Define.mj_rightCards_position_x, posY))
		-------------回放加入癞子显示------------------------
		-- 设置癞子
		local laiziList = self.playSystem:getGameStartDatas().laizi
		local value = mjElement:getValue()
		for k, v in pairs(laiziList)  do
			if value == v then
				local laiziPng  = display.newSprite(kLaiziPng)
				local size 		= mjElement:getContentSize()
				local pngSize 	= laiziPng:getContentSize()
				laiziPng:setPosition(cc.p(size.width / 2 - pngSize.width / 2, size.height / 2 - pngSize.height / 2))
				mjElement:addChild(laiziPng)
				--因为要从小到大排所以这里要做处理,倒序
				local laiziValue = -100 + value
				mjElement:setSortValue(laiziValue)
			end
		end
		table.insert(self.handCardsObjs, mjElement)
	end
end

-- --[[
-- -- @brief  正式开始游戏时分发手牌
-- -- @param  cardsList 牌列表 如：{15, 27, 36, 44}
-- -- @return void
-- --]]
-- function PlayerRightPanel:distrMyselfMj(cardsList)
-- 	self:createMyselfOpenCards(cardsList)
-- 	if #self.handCardsObjs > 1 then
-- 		self.handCardsObjs[#self.handCardsObjs]:setPosition(cc.p(
-- 			self.handCardsObjs[#self.handCardsObjs]:getPositionX(),
-- 			self.handCardsObjs[#self.handCardsObjs]:getPositionY() + kLastOffset
-- 			)
-- 		)
-- 	end
-- end

--[[
-- @brief  运行排序动画
-- @param  void
-- @return
--]]
function PlayerRightPanel:runStartSortAction(mjList)
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
				----------------回放相关-----------------------
				if VideotapeManager.getInstance():isPlayingVideo() then
					self:reSortMjListPosition()
				end
				---------------------------------------------
				self:showOpenCards()
				-- 移除盖上的牌
				self:removeCloseCards()
			end),
			cc.CallFunc:create(function ()
				-- 如果发到14张才需要移位
				if not VideotapeManager.getInstance():isPlayingVideo() and #myCards == 14 then
					self:moveLastMj()
				end
			end)
		)
	)
end

--[[
-- @brief  出牌动作
-- @param  startPos:出牌的起始坐标
-- @param  OutValue:打出去的牌值
-- @param  indexof:出牌在手里牌的位置的索引
-- @return
--]]
function PlayerRightPanel:runPlayOutAction(startPos, OutValue, indexof)
	local mjElement = Mj.new(enMjType.RIGHT_OUT, OutValue, false)
	if mjElement == nil then
		printError("PlayerRightPanel:runPlayOutAction 麻将对象为空")
	end
	self:addChild(mjElement, -#self.putOutObj)
	-- 获取出牌的位置
	-- local posx, posy = mjObj:getPosition()
	mjElement:setPosition(startPos)
	mjElement:setPositionY(mjElement:getPositionY()+40)
	-- mjElement:setLocalZOrder(100)
	table.insert(self.putOutObj, mjElement)

	putOutObjNumber = #self.putOutObj

	---添加打出牌放大版
	if self.m_showMjBg ~= nil then
		self.m_showMjBg:removeFromParent()
		self.m_showMjBg = nil
	end

	-- self.m_showMjBg = display.newSprite("real_res/1004303.png")
	-- self.m_showMjBg:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	

	self.m_showMjBg = Mj.new(enMjType.MYSELF_OUT, OutValue, true)
	self.m_showMjBg:setScale(2)
	-- local offsetY = 20
	self.m_showMjBg:setPosition(cc.p(Define.g_right_show_pai_x-30, self.handCardsObjs[#self.handCardsObjs]:getPositionY())):addTo(self,100)
	-- self.m_showMjBg:addChild(temp,100)
	-- self.m_showMjBg:setScale(0.45)
	self:putDownMjAction(mjElement, putOutObjNumber)
end

function PlayerRightPanel:putDownMjAction( mjElement, putOutObjNumber)
	-- if self.m_showMjBg then
	-- 	self.m_showMjBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create( function()
	-- 		self.m_showMjBg:removeFromParent()
	-- 		self.m_showMjBg = nil
	-- 	end )))
	-- end
	
	if self.putOutObj[#self.putOutObj] ~= mjElement or #self.putOutObj < putOutObjNumber then
	  	return
	end

	local size = mjElement:getContentSize()
	local rowNum = math.modf((#self.putOutObj - 1) / self.outMjCount )
	local column = math.fmod((#self.putOutObj - 1), self.outMjCount )
	local pos = cc.p(
		Define.g_right_pai_out_x + rowNum * (size.width - kOutRowGap),
		self.outMjStartPosY + column * (size.height - kOutColGap))

	
	self.m_showMjBg:runAction(cc.Sequence:create(
		cc.MoveTo:create(outCardMoveTargetTime,cc.p(Define.g_right_show_pai_x-30,display.cy+100)),
		cc.DelayTime:create(outCardStayTime),
		cc.Spawn:create(cc.FadeOut:create(outCardSineInTime) ,cc.MoveTo:create(outCardSineInTime,pos),cc.ScaleTo:create(outCardSineInTime,outCardTargetScale)),
		 cc.CallFunc:create( function()
			self.m_showMjBg:removeFromParent()
			self.m_showMjBg = nil
		end )))
	
	
	mjElement:setPosition(pos)
	mjElement:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.001),
		cc.CallFunc:create(function ()
			-- 移除最后一个麻将
			-- self:removeHandMjByIndex(indexof)
			--------------回放相关----------------------
			if VideotapeManager.getInstance():isPlayingVideo() then
				self:reSortMjListPosition()
			end
			--------------------------------------------
		end),
		-- cc.MoveTo:create(kOutRunTime, pos),
		cc.CallFunc:create(function ()
			-- 发送出牌落地结束消息
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, enSiteDirection.SITE_RIGHT, pos.x, pos.y)
		end)
		)
	)
end

--[[
-- @brief  开始游戏时重新排列麻将位置
-- @param  obj 新牌对象
-- @return void
--]]
function PlayerRightPanel:reSortMjListPosition(obj)
	-- 排序
	local function sortCard(x, y)
		if x:getSortValue() < y:getSortValue() then
			return true
		elseif x:getSortValue() > y:getSortValue() then
			return false
		end
		-- 牌的显示是从下到上
		return x:getPositionY() < y:getPositionY()
	end
	table.sort(self.handCardsObjs, sortCard)
	local inPos 	= cc.p(0, 0)
	local index 	= nil
	if obj then
		index = table.indexof(self.handCardsObjs, obj)
	end
	local posY = self.handCardStartY
	for i=1, #self.handCardsObjs do
		-- 第一个就设置在起始位置
		if i == 1 then

		else
			-- 获取最后一个麻将的大小
			local size = self.handCardsObjs[i]:getContentSize()
			posY = posY + size.height - 20
		end

		if obj then
			if index == i then
				inPos.x = Define.mj_rightCards_position_x
				inPos.y = posY
			else
				self.handCardsObjs[i]:setPosition(cc.p(Define.mj_rightCards_position_x, posY))
			end
		else
			self.handCardsObjs[i]:setPosition(cc.p(Define.mj_rightCards_position_x, posY))
		end
		self.mjLocalZOrder = self.mjLocalZOrder - 1
		self.handCardsObjs[i]:setLocalZOrder(self.mjLocalZOrder)
	end
	-- 可以出牌的情况下最后一个移位
	if self:isCanPlayCard(#self.handCardsObjs) then
		self:moveLastMj()
	end
	return inPos
end


--[[
-- @brief  显示打开的牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:showOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:setVisible(true)
	end
end

--[[
-- @brief  隐藏打开的牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:hideOpenCards()
	for k, v in pairs(self.handCardsObjs) do
		v:setVisible(false)
	end
end

--[[
-- @brief  显示盖下的牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:showCloseCards()
	for k, v in pairs(self.closeCardObj) do
		v:setVisible(true)
	end
end

--[[
-- @brief  隐藏盖下的牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:hideCloseCards()
	for k, v in pairs(self.closeCardObj) do
		v:setVisible(false)
	end
end

--[[
-- @brief  获取手牌列表
-- @param  void
-- @return self.handCardsObjs 手牌列表
--]]
function PlayerRightPanel:getHandCardsList()
	return self.handCardsObjs
end

--[[
-- @brief  通过索引从手牌里移除打出去的麻将函数
-- @param  index: 麻将索引
-- @return void
--]]
function PlayerRightPanel:removeHandMjByIndex(index)
	self.handCardsObjs[index]:removeFromParent()
	table.remove(self.handCardsObjs, index)
end

--[[
-- @brief  获取打出去的牌的对象列表
-- @param  void
-- @return void
--]]
function PlayerRightPanel:getPutOutCardsList()
	return self.putOutObj
end
--[[
-- @brief  获取动作后的牌的对象列表
-- @param  void
-- @return void
--]]
function PlayerRightPanel:getmjGroupsList()
    return self.mjGroups
end
--[[
-- @brief  创建明牌
-- @param  cardsList 牌列表 如：{15, 27, 36, 44}
-- @param  startX 起始X
-- @param  startY 起始Y
-- @return void
--]]
function PlayerRightPanel:mingPai(cardsList, startX, startY)
	self:removeOpenCards()
	local list = 0
	-- 如果是只传进来一个麻将需要转换成table
	if type(cardsList) == "number" then
		list = cardsList
	elseif type(cardsList) == "table" then
		list = #cardsList
	else
		printError("PlayerRightPanel:mingPai 无效的数组类型%s", cardsList)
	end
	local posY = self.handCardStartY
	local posX = startX
	for i=1, list do
		-- 创建麻将对象
		local mjElement = Mj.new(enMjType.RIGHT_PENG, cardsList[i], true)
		self:addChild(mjElement)

		-- 第一个就设置在起始位置
		if 0 == #self.overCObj then

		else
			-- 获取最后一个麻将的大小
			local size = self.overCObj[#self.overCObj]:getContentSize()
			posY = self.overCObj[#self.overCObj]:getPositionY() + size.height - 20
		end
		mjElement:setLocalZOrder(2-i)
		mjElement:setPosition(cc.p(posX, posY))
		table.insert(self.overCObj, mjElement)
	end
	return self.overCObj
end

--------------------------------------下面是吃碰杠等操作相关函数--------------------------------
--[[
-- @brief  手牌麻将X轴偏移
-- @param  void
-- @return void
--]]
function PlayerRightPanel:mjOffsetPos(offsetY)
	for i=1,#self.handCardsObjs do
		local x = self.handCardsObjs[i]:getPositionX()
		local y = self.handCardsObjs[i]:getPositionY()
		self.handCardsObjs[i]:setPosition(cc.p(x, y + offsetY - 4))
	end
end

--[[
-- @brief  合成麻将组和
-- @param  void
-- @return void
--]]
function PlayerRightPanel:composeMjGroup(content)
	local gap = 0
    -- local content = {
    -- 	mjs         = {12,12,12},  --麻将的列表
    --     actionType  = enOperate.OPERATE_PENG,    	--动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
    --     operator    = enSiteDirection.SITE_RIGHT,  --操作者的座次
    --     beOperator  = enSiteDirection.SITE_OTHER,  	--被操作的座位，暗杠和加杠不需要传进来
    -- }
    local groups  	= self.mjGroups:getMjGroupsBySite(enSiteDirection.SITE_RIGHT)
    local num 		= #groups
    local groupsSize = self.mjGroups:getMjGroupsSizeBySite(enSiteDirection.SITE_RIGHT)
    local group  	 = self.mjGroups:addMjGroup(content)
    self:addChild(group)
	if num > 0 then
    	group:setPosition(cc.p(
    		Define.mj_rightCards_position_x,
			groups[num]:getPositionY()
	    	+ groups[num]:getContentSize().height
	    	+ kGroupGap))
    	local zorder = groups[num]:getLocalZOrder()
    	group:setLocalZOrder(zorder - 1)
    else
    	group:setPosition(cc.p(
			Define.mj_rightCards_position_x,
			Define.mj_rightCards_position_y + group:getContentSize().height / 2))
    end
    -- 重设起始位置
   	self.handCardStartY = group:getPositionY() + group:getContentSize().height / 2 + kGroupGap
   	---------------回放相关-----------------------------
   	if VideotapeManager.getInstance():isPlayingVideo() then
		self:reSortMjListPosition()
	elseif #self.mjGroups:getMjGroupsBySite(enSiteDirection.SITE_RIGHT) == 1 then
		-- 第一组牌的偏移需要加上一个偏移量
		self:mjOffsetPos(group:getContentSize().height + 23)
	else
		self:mjOffsetPos(group:getContentSize().height + kGroupGap)
	end
	------------------------------------------------------
    -- self:mjOffsetPos(group:getContentSize().height + kGroupGap)
end

--[[
-- @brief  加杠显示处理
-- @param  void
-- @return void
--]]
function PlayerRightPanel:setGroupJiaGang(content)
    self.mjGroups:addJiaGangGroup(content)
end

-- --[[
-- -- @brief  移除手牌
-- -- @param  void
-- -- @return void
-- --]]
-- function PlayerRightPanel:removeHandMjAction(content)
-- 	-- 吃
-- 	if content.actionID == enOperate.OPERATE_CHI then
-- 		self:removeHandMjByNum(2)
-- 	elseif content.actionID == enOperate.OPERATE_PENG then
-- 		self:removeHandMjByNum(2)
-- 	elseif content.actionID == enOperate.OPERATE_MING_GANG then
-- 		self:removeHandMjByNum(3)
-- 	elseif content.actionID == enOperate.OPERATE_AN_GANG then
-- 		self:removeHandMjByNum(4)
-- 	elseif content.actionID == enOperate.OPERATE_JIA_GANG then
-- 		self:removeHandMjByNum(1)
-- 	elseif content.actionID == enOperate.OPERATE_BU_HUA then
-- 		self:removeHandMjByNum(1)
-- 	end
-- end

--[[
-- @brief  移除手牌
-- @param  void
-- @return void
--]]
function PlayerRightPanel:removeHandMjAction(content)
		----------------回放相关-------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:removeHandMjVideoAction(content)
	else
		-- 吃
		if content.actionID == enOperate.OPERATE_CHI then
			self:removeHandMjByNum(2)
		elseif content.actionID == enOperate.OPERATE_PENG then
			self:removeHandMjByNum(2)
		elseif content.actionID == enOperate.OPERATE_MING_GANG then
			self:removeHandMjByNum(3)
		elseif content.actionID == enOperate.OPERATE_AN_GANG then
			self:removeHandMjByNum(4)
		elseif content.actionID == enOperate.OPERATE_JIA_GANG then
			self:removeHandMjByNum(1)
		elseif content.actionID == enOperate.OPERATE_BU_HUA then
			self:removeHandMjByNum(1)
		end
	end
	----------------------------------------------
end

------------------------回放相关----------------------
--[[
-- @brief  移除手牌
-- @param  content
-- @return void
--]]
function PlayerRightPanel:removeHandMjVideoAction(content)
	local removeList 	= {} -- 需要移除的对象列表
	local handCardsList = {} -- 剩下手牌的对象列表
	-- 吃
	if content.actionID == enOperate.OPERATE_CHI then

		for i=1,#content.cbCards do
			for t=1, #self.handCardsObjs do
				if  self.handCardsObjs[t]:getValue() == content.cbCards[i] and not self:isContainsObj(removeList, content.cbCards[i]) then
					table.insert(removeList, self.handCardsObjs[t])
					table.removebyvalue(self.handCardsObjs,self.handCardsObjs[t])
					handCardsList = self.handCardsObjs
					break
				end
			end
		end
	elseif content.actionID == enOperate.OPERATE_PENG then
		local pengCardNum = 1 -- 碰只能移除两个
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:getValue() == content.actionCard
			and pengCardNum < 3 then
				pengCardNum = pengCardNum + 1
				table.insert(removeList, self.handCardsObjs[i])
			else
				table.insert(handCardsList, self.handCardsObjs[i])
			end
		end
	elseif content.actionID == enOperate.OPERATE_MING_GANG then
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:getValue() == content.actionCard then
				table.insert(removeList, self.handCardsObjs[i])
			else
				table.insert(handCardsList, self.handCardsObjs[i])
			end
		end
	elseif content.actionID == enOperate.OPERATE_AN_GANG then
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:getValue() == content.actionCard then
				table.insert(removeList, self.handCardsObjs[i])
			else
				table.insert(handCardsList, self.handCardsObjs[i])
			end
		end
	elseif content.actionID == enOperate.OPERATE_JIA_GANG then
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:getValue() == content.actionCard then
				table.insert(removeList, self.handCardsObjs[i])
			else
				table.insert(handCardsList, self.handCardsObjs[i])
			end
		end
	-- 补花
	elseif content.actionID == enOperate.OPERATE_BU_HUA then
		-- 移除补花的牌
		local buhuaFlag = true
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
	self.handCardsObjs = handCardsList
	if #removeList > 0 then
		-- 移除手牌麻将并重新排位
		self:actionMoveHandMj(removeList)
		-- 重新排序
		self:reSortMjListPosition()
	end
end

--[[
-- @brief  移除操作之后的麻将函数
-- @param  list 麻将列表
-- @return void
--]]
function PlayerRightPanel:actionMoveHandMj(list)
	for i,v in pairs(list) do
		self:removeHandMjObj(v)
	end
end

--[[
-- @brief  移除麻将对象函数
-- @param  obj 麻将对象
-- @return void
--]]
function PlayerRightPanel:removeHandMjObj(obj)
	local value = obj:getValue()
	obj:removeFromParent()
end
----------------------------------------------

--[[
-- @brief  移除麻将个数
-- @param  num: 移除的个数
-- @return void
--]]
function PlayerRightPanel:removeHandMjByNum(num)
	local removeList = {}
	local handCardsList = {}
	if num <= #self.handCardsObjs then
		for i=1, #self.handCardsObjs do
			if i <= #self.handCardsObjs - num then
				table.insert(handCardsList, self.handCardsObjs[i])
			else
				table.insert(removeList, self.handCardsObjs[i])
			end
		end
	else
		print("移除的个数超过了手牌数量 %d", num)
	end
	self.handCardsObjs = handCardsList
	for i=1,#removeList do
		removeList[i]:removeFromParent()
	end
end

--[[
-- @brief  移除打出的最后一张
-- @param  index: 麻将索引
-- @return void
--]]
function PlayerRightPanel:removeLastPutOutMj()
	self.putOutObj[#self.putOutObj]:removeFromParent()
	table.remove(self.putOutObj, #self.putOutObj)
end
--------------------------------------上面是吃碰杠等操作相关函数--------------------------------

function PlayerRightPanel:moveLastMj()
	local myCards = self:getHandCardsList()
	myCards[#myCards]:setPosition(cc.p(myCards[#myCards]:getPositionX(), myCards[#myCards]:getPositionY() + kLastOffset * kScaleY))
end

return PlayerRightPanel
