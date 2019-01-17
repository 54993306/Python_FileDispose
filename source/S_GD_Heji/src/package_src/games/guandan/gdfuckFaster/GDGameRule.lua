
-- 手牌的操作
local CardSet = require('package_src.games.guandan.gdpoker.CardSet')

local GDGameRule = class("GDGameRule", require("package_src.games.guandan.gdpoker.GameRule"))

function GDGameRule:ctor()

	GDGameRule.super.ctor(self)

	--不同牌型间的大小关系数组（数组一维存储目标牌型，二维存储比目标牌型大的牌型）
	self.ms_arrMapCompare = {} 

	self:Initialize()
end

--函数功能：     初始化配置
function GDGameRule:Initialize()
	-- 获取玩法规则
	-- local stSetting = clone(RULESETTING)
	-- stSetting.unSign = 0x1B84

	-- 玩法规则设置
	-- self:Config(stSetting)

	-- 用于数据清理,
	self:CleanData()

	-- 初始化玩法规则
	self:updateWanFa()

	-- 设置癞子牌
	self:SetGhostCards()
end

--函数功能：     设置癞子的值
function GDGameRule:SetGhostCards()
	Log.i("--wangzhi--设置癞子值--")
	self.ghostCardList = {}
	-- local ghostCardValue = RULESETTING.nLevelCard * enmCardShape.ECS_SHAPE_HEARTS
	local ghostCardOriginalVal = 16*enmCardShape.ECS_SHAPE_HEARTS + RULESETTING.nLevelCard - 2
	Log.i("--wangzhi--设置癞子值--ghostCardOriginalVal--",ghostCardOriginalVal)
	table.insert(self.ghostCardList,ghostCardOriginalVal)
end

--函数功能：     获取癞子的值
function GDGameRule:GetGhostCards()
	-- Log.i("--wangzhi--癞子的值为--self.ghostCardList--",self.ghostCardList)
	if self.ghostCardList then
		return self.ghostCardList
	else
		self.ghostCardList = {}
		-- local ghostCardValue = RULESETTING.nLevelCard * enmCardShape.ECS_SHAPE_HEARTS
		local ghostCardOriginalVal = 16*enmCardShape.ECS_SHAPE_HEARTS + RULESETTING.nLevelCard - 2
		table.insert(self.ghostCardList,ghostCardOriginalVal)
		return self.ghostCardList
	end
end

--函数功能：     找出牌组中癞子的个数
function GDGameRule:GetCardsGhostList(obCards)
	-- self:SetGhostCards()
	-- self:GetGhostCards()
	local ghostCount = 0
	local ghostList = {}
	for i,v in ipairs(obCards:GetCards()) do
		for k,vv in pairs(self.ghostCardList) do
			if v.originalVal == vv then
				ghostCount = ghostCount + 1
				table.insert(ghostList,v)
			end
		end
	end
	Log.i("--wangzhi--癞子数量--",ghostCount)
	-- Log.i("--wangzhi--癞子牌组--",ghostList)
	return ghostCount,ghostList
end

-- 一张除了OriginalVal全都正常的牌，OriginalVal为癞子的值
function GDGameRule:CreateGhostCard(cardValue,isChangeLevel)
	Log.i("--wangzhi--CreateGhostCard--cardValue--",cardValue)
	local ghostCardOriginalVal = 16*enmCardShape.ECS_SHAPE_HEARTS + RULESETTING.nLevelCard - 2
	cardValue = cardValue or ghostCardOriginalVal
	local ghostCardlist = {}
	table.insert( ghostCardlist, cardValue)
	local obCards = CardSet.new()
	obCards:AddOriCards(ghostCardlist)
	if isChangeLevel then
		obCards = self:obCardsChangeLevel(obCards)
	end
	local tmpGhost = obCards:GetCards()[1]
	tmpGhost.originalVal = ghostCardOriginalVal
	return tmpGhost
end

-- 一张假的癞子,用于做填补
function GDGameRule:GetGhostOriginalVal()
	local ghostCardOriginalVal = 16*enmCardShape.ECS_SHAPE_HEARTS + RULESETTING.nLevelCard - 2
	return ghostCardOriginalVal
end


--函数功能：     找出牌组中非癞子牌个数
function GDGameRule:DelGhostList(obCards)
	tmpObCards = clone(obCards)
	local operationCardList = tmpObCards:GetCards()
	for i = #operationCardList,1,-1 do
		-- Log.i("--wangzhi--self:GetGhostCards()--",self:GetGhostCards())
		for k,v in pairs(self:GetGhostCards()) do
			if operationCardList[i].originalVal == v then
				tmpObCards:DelCard(i)
			end
		end

	end

	Log.i("--wangzhi--去掉癞子牌的张数--",#tmpObCards:GetCards())
	return tmpObCards
end


--函数功能：     获取进贡的牌
function GDGameRule:GetPutOutCard(selfCards)
	if #selfCards <=0 then
		return
	end
	Log.i("--wangzhi--GetPutOutCard--#selfCards--",#selfCards)
	local obCards = CardSet.new()
	obCards:AddOriCards(selfCards)
	-- 按权重排序
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local cardNumber = {}
	local cardLevel = {}
	Log.i("--wangzhi--GetPutOutCard--#exceptGhostList:GetCards()",#exceptGhostList:GetCards())
	for i,v in ipairs(exceptGhostList:GetCards()) do
		table.insert(cardNumber,v.number)
		table.insert(cardLevel,v.level)
	end
	Log.i("--wangzhi--GetPutOutCard--手牌对象--",cardNumber)
	Log.i("--wangzhi--GetPutOutCard--手牌权重--",cardLevel)
	Log.i("--wangzhi--GetPutOutCard--进贡的牌--",exceptGhostList:GetCards()[#exceptGhostList:GetCards()].number)
	local result = {}
	if exceptGhostList:GetCards()[#exceptGhostList:GetCards()].originalVal then
		for i,v in ipairs(exceptGhostList:GetCards()) do
			if v.number == exceptGhostList:GetCards()[#exceptGhostList:GetCards()].number then
				Log.i("--wangzhi--进贡的牌组(原值)--",v.originalVal)
				table.insert(result,v.originalVal)
			end
		end
		return result
	end
end

--函数功能：     获取还贡的牌
function GDGameRule:GetPutInCard(selfCards)
	if #selfCards <=0 then
		return
	end
	local obCards = CardSet.new()
	obCards:AddOriCards(selfCards)
	-- 按权重排
	obCards:SortCards(0)
	local cardNumber = {}
	local putInCardsOriginalVal = {}
	local putInCardsNumber = {}
	for i,v in ipairs(obCards:GetCards()) do
		if v.level<=8 then
			table.insert(putInCardsOriginalVal,v.originalVal)
			table.insert(putInCardsNumber,v.number)
		end
		table.insert(cardNumber,v.number)
	end
	local result = {}
	Log.i("--wangzhi--GetPutOutCard--手牌对象--值--",cardNumber)
	if #putInCardsOriginalVal<=0 then
		-- 如果没有10以下的牌，那么提供最小的牌。
		Log.i("--wangzhi--GetPutOutCard--还贡(没有10以下)--",obCards:GetCards()[1].number)

		for i,v in ipairs(obCards:GetCards()) do
			if v.number == obCards:GetCards()[1].number then
				table.insert(result,v.originalVal)
			end
		end
		return result
	else
		-- 如果有10以下的牌，返回所有10以下，给玩家自己选。
		Log.i("--wangzhi--GetPutOutCard--还贡(有10以下)--",putInCardsNumber)
		return putInCardsOriginalVal
	end
end


--函数功能：     清理数据
function GDGameRule:CleanData()
	-- 清理玩法设置
	self.ghostCardList = nil
end

--函数功能：     初始化玩法规则
function GDGameRule:updateWanFa()
	-- 设置或更新玩法设置
	self:SetGhostCards()
end

--函数功能：	查能压的牌
--selfCards:	手牌
--obCards:	   需要压的牌
--isMove		是否是滑动选牌
function GDGameRule:PressCard(selfCards,obCards,isDesc,isMuban,lastCardsType)
    if not selfCards then
		return 
	end

	-- 将手牌组进行处理
	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(selfCards)
	
	-- 将出牌组进行处理
	local obCardsSet = nil
	if obCards and #obCards > 0 then
		obCardsSet = CardSet.new()
		obCardsSet:AddOriCards(obCards)
	end
	-- tipsType = tipsType or 1
	local result = {}
	-- 获取牌型提示
	isDesc = isDesc or false
	local cardTips = self:GetCardTips(selfCardSet,obCardsSet,isDesc,isMuban,lastCardsType)
	Log.i("--wangzhi--cardTips--")
	for i,v in ipairs(cardTips) do
		result[i] = result[i] or {}
		for j,jv in ipairs(v) do
			if isDesc then
				if jv.originalVal == self:GetGhostOriginalVal() then
					jv.originalVal =16*jv.shape + jv.number - 2
				end
				-- 返回被癞子替换后的值,用于显示
				table.insert(result[i],jv.originalVal)
			else
				-- 如果有癞子加进去,会返回癞子
				table.insert(result[i],jv.originalVal)
			end
		end
	end

	-- 重置
	if selfCardSet then
		selfCardSet:ClearAll()
	end
	-- 重置
	if obCardsSet then
		obCardsSet:ClearAll()
	end
	if isDesc and #result>=1 then
		local tmpResult = {}
		table.insert(tmpResult,result[#result])
		result = tmpResult
	end
	return result
end

--函数功能：     获取牌型提示列表
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function GDGameRule:GetCardTips(obCards, last_cards,isDesc,isMuban,lastCardsType)
	local result = {}
	local kingBombs ={}
	local sisterBombs ={}
	local bombs ={}
	local unBombs ={}

	if lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
		Log.i("--wangzhi--上一手牌--天王炸")
		return result
	elseif lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
		Log.i("--wangzhi--上一手牌--同花顺")
		kingBombs = self:GetKingBombStyle(obCards, last_cards,isDesc,lastCardsType)
		if table.nums(kingBombs) > 0 then
			DiyalTool.Tab_insertto(result, kingBombs)
			return result
		end
		sisterBombs = self:GetSisterBombStyle(obCards, last_cards,isDesc,lastCardsType)
		if table.nums(sisterBombs) > 0 then
			DiyalTool.Tab_insertto(result, sisterBombs)
			return result
		end
		-- 如果上一手是同花顺,必须6张以上的普通炸弹
		bombs = self:GetBombStyle(obCards, last_cards,isDesc,lastCardsType,6)
		if table.nums(bombs) > 0 then
			DiyalTool.Tab_insertto(result, bombs)
			return result			
		end
	elseif lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
		Log.i("--wangzhi--上一手牌--同花顺")
		kingBombs = self:GetKingBombStyle(obCards, last_cards,isDesc,lastCardsType)
		if table.nums(kingBombs) > 0 then
			DiyalTool.Tab_insertto(result, kingBombs)
			return result
		end
		-- 6炸一下才需要判断同花顺
		if last_cards and #last_cards <=5 then
			sisterBombs = self:GetSisterBombStyle(obCards, last_cards,isDesc,lastCardsType)
			if table.nums(sisterBombs) > 0 then
				DiyalTool.Tab_insertto(result, sisterBombs)
				return result
			end
		end

		local count = #(last_cards:GetCards())
		bombs = self:GetBombStyle(obCards, last_cards,isDesc,lastCardsType,count)
		if table.nums(bombs) > 0 then
			DiyalTool.Tab_insertto(result, bombs)
			return result			
		end

	elseif lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS or
		lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS or
		lastCardsType == enmCardType.EBCT_BASETYPE_SISTER or
		lastCardsType == enmCardType.EBCT_BASETYPE_3AND2 or
		lastCardsType == enmCardType.EBCT_BASETYPE_3KIND or
		lastCardsType == enmCardType.EBCT_BASETYPE_PAIR or
		lastCardsType == enmCardType.EBCT_BASETYPE_SINGLE then

		kingBombs = self:GetKingBombStyle(obCards, last_cards,isDesc,lastCardsType)
		if table.nums(kingBombs) > 0 then
			DiyalTool.Tab_insertto(result, kingBombs)
			return result
		end

		sisterBombs = self:GetSisterBombStyle(obCards, last_cards,isDesc,lastCardsType)
		if table.nums(sisterBombs) > 0 then
			DiyalTool.Tab_insertto(result, sisterBombs)
			return result
		end

		bombs = self:GetBombStyle(obCards, last_cards,isDesc,lastCardsType,4)
		if table.nums(bombs) > 0 then
			DiyalTool.Tab_insertto(result, bombs)
			return result			
		end

		unBombs = self:GetCommonStyle(obCards, last_cards,isDesc,isMuban)
		if table.nums(unBombs) > 0 then
			DiyalTool.Tab_insertto(result, unBombs)
			return result			
		end
	end

	-- 当需要查出所有可以压的牌型,进行牌型提示的时候用下面的这一段
	-- local kingBombs = self:GetKingBombStyle(obCards, last_cards,isDesc,lastCardsType)
	
	-- -- 获取同花顺牌型
	-- local sisterBombs = self:GetSisterBombStyle(obCards, last_cards,isDesc,lastCardsType)

	-- -- 获取普通炸弹牌型
	-- local bombs = self:GetBombStyle(obCards, last_cards,isDesc,lastCardsType)

	-- -- 获取不是炸弹的牌型
	-- local unBombs = self:GetCommonStyle(obCards, last_cards,isDesc,isMuban,lastCardsType)

	-- local tmpResult = {}
	-- if table.nums(kingBombs) > 0 then
	-- 	for i,v in ipairs(kingBombs) do
	-- 		table.insert(tmpResult,v)
	-- 	end
	-- end

	-- if table.nums(sisterBombs) > 0 then
	-- 	for i,v in ipairs(sisterBombs) do
	-- 		table.insert(tmpResult,v)
	-- 	end
	-- end

	-- if table.nums(bombs) > 0 then
	-- 	for i,v in ipairs(bombs) do
	-- 		table.insert(tmpResult,v)
	-- 	end
	-- end

	-- if table.nums(unBombs) > 0 then
	-- 	for i,v in ipairs(unBombs) do
	-- 		table.insert(tmpResult,v)
	-- 	end
	-- end

	-- 用于打印出选出的结果
	-- self:printResult(tmpResult,last_cards)

	-- DiyalTool.Tab_insertto(result, unBombs)
	-- DiyalTool.Tab_insertto(result, bombs)
	-- DiyalTool.Tab_insertto(result, sisterBombs)
	-- DiyalTool.Tab_insertto(result, kingBombs)

	return result

end

--函数功能：     获取非炸弹牌型提示
--obCards:      目标牌集
--last_cards:   参照牌集
--isDesc:		是否找最大值
--isMuban:		要压的牌是否是木板(2个癞子的情况下,木板需要特殊处理。不然会被判定为钢板)
--返回值：       分析出来的
function GDGameRule:GetCommonStyle(obCards, last_cards,isDesc,isMuban,lastCardsType)
	local result = {}
	-- 如果是所选牌压上手,普通类型情况下牌数必须相同
	if isDesc and last_cards then
		if obCards:CurrentLength() ~= last_cards:CurrentLength() then
			return result
		end
	end
	last_cards = last_cards or obCards
	local last_card_type = self:CardsType(last_cards)

	local tmp_cards1 = {}
	Log.i("--wangzhi--last_card_type--",last_card_type)
	if isMuban == true then
		last_card_type = enmCardType.EBCT_CUSTOMERTYPE_PAIRS
	end
	--找出非炸弹牌型
	-- 单张
	if last_card_type == enmCardType.EBCT_BASETYPE_SINGLE then
		tmp_cards1 = self:FindPressAllSingle(obCards)
		Log.i("--wangzhi--查找到的单张为")
	-- 对子
	elseif last_card_type == enmCardType.EBCT_BASETYPE_PAIR then
		tmp_cards1 = self:FindPressAllPair(obCards)
		Log.i("--wangzhi--查找到的对子为")
	-- 三张
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3KIND then
		tmp_cards1 = self:FindPressAll3Kind(obCards)
		Log.i("--wangzhi--查找到的三张为")
	-- 三带二
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3AND2 then
		tmp_cards1 = self:FindPressAll3And2(obCards)
		Log.i("--wangzhi--查找到的三带二为")
	-- 顺子	只能五张
	elseif last_card_type == enmCardType.EBCT_BASETYPE_SISTER then
		tmp_cards1 = self:FindPressAllSister(obCards,5)
		Log.i("--wangzhi--查找到的顺子为")
	-- 钢板,优先钢板,钢板更难被压
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
		tmp_cards1 = self:FindPressAll3Kinds(obCards,2)
		Log.i("--wangzhi--查找到的钢板为")
	-- 木板
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
		tmp_cards1 = self:FindPressAllPairs(obCards,3)
		Log.i("--wangzhi--查找到的木板为")
	end

	if last_cards and last_card_type == enmCardType.EBCT_BASETYPE_SISTER then
	 	-- 如果是顺子,那么判断是否是A2345,如果是,不用做筛选处理
		local cardType,isA2345sister = self:Find_SISTER(last_cards)
		if cardType and isA2345sister then
			Log.i("--wangzhi--判断为A2345顺子,所有顺子都可以压")
			return tmp_cards1
		end
	elseif last_cards and  last_card_type == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
		-- 先判断是否是AA2233的连对
		local cardType,isAA2233sister = self:Find_PAIRS(last_cards)
		if cardType and isAA2233sister then
			Log.i("--wangzhi--判断为AA2233木板,所有木板都可以压")
			return tmp_cards1
		end
	elseif last_cards and  last_card_type == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
		-- 先判断是否是AAA222的连对
		local cardType,isAAA222kinds = self:Find_3KINDS(last_cards)
		if cardType and isAAA222kinds then
			Log.i("--wangzhi--判断为AAA222钢板,所有钢板都可以压")
			return tmp_cards1
		end
	end
	
	-- 如果判断压不压的起的时候,需要选的张数和要出的张数一样多
	if isDesc and last_cards then
		-- local tmp_cards2 = {}
		-- for k, v in ipairs(tmp_cards1) do
		-- 	if #v == obCards:CurrentLength() and #v == last_cards:CurrentLength() then
		-- 		table.insert(tmp_cards2, v)
		-- 	end
		-- end
		-- tmp_cards1 = tmp_cards2
		if obCards:CurrentLength() == last_cards:CurrentLength() then
			
		else
			tmp_cards1 = {}
		end
	end

	--筛选
	if last_cards and #tmp_cards1>=1 then
		-- for k, v in ipairs(tmp_cards1) do
			local cardSet = require("package_src.games.guandan.gdpoker.CardSet"):new()
			-- cardSet:AddCards(v)
			cardSet:AddCards(tmp_cards1[#tmp_cards1])

			-- 对牌型进行比较，大于压牌的才加入
			-- 通过调一次压牌,将癞子筛选出作为了什么牌
			local tmpCardSet = self:GetMaxCard(cardSet,last_card_type)
			local tmpLast_cards = self:GetMaxCard(last_cards,last_card_type)

			-- tmpLast_cards:SortCards(0)
			local cmpRlt = self:Compare(tmpCardSet, tmpLast_cards)
			-- local cmpRlt = self:Compare(cardSet, last_cards)
			if cmpRlt == enmTypeCompareResult.ETCR_MORE then
				print(cmpRlt)
				table.insert(result, tmp_cards1[#tmp_cards1])
			end
		-- end
	end

	if isDesc and #result>=1 then
		local tmpResult = {}
		table.insert(tmpResult,result[#result])
		result = tmpResult
	end

	return result
end

--函数功能：     将权重转换为对比顺子权重()
--obCards:      参照的目标牌集
--返回值：       转换权重后的牌集
function GDGameRule:obCardsChangeLevel(obCards)
	local tmpObCards = obCards:GetCards()
	for i,v in ipairs(tmpObCards) do
		v.level = self:cardChangeLevel(v.number)
	end
	return obCards
end





--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GDGameRule:cardChangeLevel(oldNum)
	local afterNum = 0
	-- 现将2调换到最小
	if oldNum == enmCardNumber.ECN_NUM_NONE then
		afterNum = 0
	-- 2为最小的牌
	elseif oldNum == enmCardNumber.ECN_NUM_2 then
		afterNum = oldNum - 14
	else
		afterNum = oldNum - 1
	end
	return afterNum
	-- return oldNum - 2
end


--函数功能：     将权重转换为掼蛋压牌权重()
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GDGameRule:obCardsBackLevel(obCards)
	local tmpObCards = obCards:GetCards()
	for i,v in ipairs(tmpObCards) do
		v.level = self:cardBackLevel(v.number)
	end
	return obCards
end

--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GDGameRule:cardBackLevel(oldNum)
	local afterNum = 0
	
	if oldNum == enmCardNumber.ECN_NUM_NONE then
		afterNum = 0
	-- -- 现将2调换到最小,2为最小的牌
	elseif oldNum == enmCardNumber.ECN_NUM_2 then
		afterNum = oldNum - 12
	elseif oldNum == enmCardNumber.ECN_NUM_Joker then
		afterNum = oldNum
	elseif oldNum == enmCardNumber.ECN_NUM_JOKER then
		afterNum = oldNum
	else
		afterNum = oldNum
	end
	-- 然后集体减少2
	if RULESETTING.nLevelCard == 15 then
		afterNum = afterNum - 2
	elseif oldNum < RULESETTING.nLevelCard then
		afterNum = afterNum - 1
	elseif oldNum > RULESETTING.nLevelCard then
		afterNum = afterNum - 2
	end

	-- 这里RULESETTING.nLevelCard为自定义的掼蛋级牌概念。
	if oldNum == RULESETTING.nLevelCard then
		afterNum = 13
	end

	return afterNum
end

--函数功能：     将权重转换为对比顺子权重()
--obCards:      参照的目标牌集
--返回值：       转换权重后的牌集
function GDGameRule:obCardsChangeLevelA23(obCards)
	local tmpObCards = obCards:GetCards()
	for i,v in ipairs(tmpObCards) do
		v.level = self:cardChangeLevelA23(v.number)
	end
	return obCards
end

--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GDGameRule:cardChangeLevelA23(oldNum)
	local afterNum = 0

	-- 现将2调换到最小
	if oldNum == enmCardNumber.ECN_NUM_NONE then
		afterNum = 0
	-- 将A和2的权重降到最低用于判断A23
	elseif oldNum == enmCardNumber.ECN_NUM_2 or oldNum == enmCardNumber.ECN_NUM_A then
		afterNum = oldNum - 13
	else
		afterNum = oldNum
	end
	return afterNum
end

-- --函数功能：     根据level对两牌集的比较
-- --selfCards:    被比较的牌集
-- --obCards:      参照的目标牌集
-- --返回值：       比较结果 int
-- function GDGameRule:cardBackLevelA23(oldNum)
-- 	local afterNum = 0

-- 	if oldNum == enmCardNumber.ECN_NUM_NONE then
-- 		afterNum = 0
-- 	-- 顺子判断完后,复原A和2的权重
-- 	elseif oldNum == enmCardNumber.ECN_NUM_2 or oldNum == enmCardNumber.ECN_NUM_A then
-- 		afterNum = oldNum + 13
-- 	end
-- 	return afterNum
-- end


--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GDGameRule:Compare(selfCards, obCards)

	local result = enmTypeCompareResult.ETCR_OTHER
	local tmpSelfCards = selfCards
	local tmpObCards = obCards
	local selfType = self:CardsType(tmpSelfCards)
	local obType = self:CardsType(tmpObCards)
	if (selfType ~= enmCardType.EBCT_TYPE_NONE) and (obType ~= enmCardType.EBCT_TYPE_NONE) then
		if selfType == obType then --牌型相同时的比较
			if selfType == enmCardType.EBCT_BASETYPE_SINGLE
				or selfType == enmCardType.EBCT_BASETYPE_PAIR
				or selfType == enmCardType.EBCT_BASETYPE_SISTER
				or selfType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
				result = self:Compare_ByMinLevel(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_BASETYPE_3KIND
				or selfType == enmCardType.EBCT_BASETYPE_3AND2
				or selfType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
				result = self:Compare_ByMinLevel3Kind(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
				-- result = self:Compare_Bomb(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
				-- result = self:Compare_ByMinLevel(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
				--todo
			else
				result = self:Compare_BetweenTypes(selfType,obType)
			end
		end
	end
	return result
end


--函数功能：     获取炸弹牌型提示
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function GDGameRule:GetBombStyle(obCards, last_cards,isDesc,lastCardsType,count)
	local result = {}
	if last_cards then
		last_cards:SortCards(0)
	end
	--找出普通炸
	local bomCount = count or 4
	local hand_cards_bombs = self:FindPressAllBOMB(obCards,isDesc,bomCount)
	-- wwdump(hand_cards_bombs)
	-- DiyalTool.Tab_insertto(result,hand_cards_bombs,hand_cards_kings)
	if hand_cards_bombs and #hand_cards_bombs > 0 then
		for i,v in ipairs(hand_cards_bombs) do
			table.insert( result,v)
		end
	else
		return result
	end

	if last_cards and lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
		for i = #result,1,-1 do
			if #result[i] > #(last_cards:GetCards()) then
				Log.i("--wangzhi--有几个跳过了")
			else
				-- Log.i("--wangzhi--last_cards:GetCards()[1].level--",last_cards:GetCards()[1].level)
				if (#result[i]<(#last_cards:GetCards())) or result[i][1].level <= last_cards:GetCards()[1].level then
					table.remove(result,i)
				end
			end
		end
	elseif last_cards and lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
		for i = #result,1,-1 do
			if #result[i] <= #(last_cards:GetCards()) then
				Log.i("炸弹张数太少，压不住同花顺",#result[i],#(last_cards:GetCards()))
				table.remove(result,i)
			end
		end
	elseif last_cards and lastCardsType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
		result = {}
	end

	if isDesc and #result>=1 then
		local tmpResult = {}
		table.insert(tmpResult,result[#result])
		result = tmpResult
	end

	return result
end

--函数功能：     获取同花顺牌型
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:GetSisterBombStyle(obCards,last_cards,isDesc,lastCardsType)
	return self:FindPressAllSisterBombs(obCards,last_cards,5,isDesc,lastCardsType)
end

--函数功能：     查找天王炸牌型
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:GetKingBombStyle(obCards,last_cards,isDesc,lastCardsType)
	return self:FindPressAllKingBombs(obCards,last_cards,isDesc,lastCardsType)
end

--函数功能：     查找所有的单张
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllSingle(obCards)
	-- 增加癞子判断
	obCards:SortCards(0)
	local result = {}
	local tmpObCards = clone(obCards)
	if table.nums(tmpObCards) >= 1  then
		local tmpTable = self:GetCountsByLevel(tmpObCards, 1)
		--将查出来的3张以上取出前两张
		for i,v in ipairs(tmpTable) do
			if #v > 1 then
				local newTable = {}
				table.insert(newTable, v[1])
				table.insert(result, newTable)
			else
				table.insert(result, v)
			end
		end
	end
	return result

end

--函数功能：     查找所有的对子
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllPair(obCards)
	-- 增加癞子判断
	obCards:SortCards(0)
	local result = {}
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	if ghostCount >= 1 and table.nums(exceptGhostList) >= 1  then
		Log.i("--wangzhi--对子--单张+癞子--")
		local tmpTable = self:GetCountsByLevel(exceptGhostList,1,1)
		for i,v in ipairs(tmpTable) do
			if v[1].number < 16 then
				local tmpGhostCard = clone(v[1])
				tmpGhostCard.originalVal = self:GetGhostOriginalVal()
				table.insert(v,tmpGhostCard)
				table.insert(result, v)
			end
		end
	end
	if table.nums(tmpObCards) >= 2  then
		local tmpTable = self:GetCountsByLevel(tmpObCards, 2)
		--将查出来的3张以上取出前两张
		for i,v in ipairs(tmpTable) do
			if #v > 2 then
				local newTable = {}
				table.insert(newTable, v[1])
				table.insert(newTable, v[2])
				table.insert(result, newTable)
			else
				table.insert(result, v)
			end
		end
	end
	return result
end

--函数功能：     查找所有的三张
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAll3Kind(obCards)
---------------------------------------------------------------------
	-- 增加癞子判断
	obCards:SortCards(0)
	local result = {}
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	if ghostCount >= 1 and table.nums(exceptGhostList) >= 2  then
		Log.i("--wangzhi--对子--单张+癞子--")
		local tmpTable = self:GetCountsByLevel(exceptGhostList,2,1)
		for i,v in ipairs(tmpTable) do
			if v[1].number < 16 then
				local tmpGhostCard = clone(v[1])
				tmpGhostCard.originalVal = self:GetGhostOriginalVal()
				table.insert(v,tmpGhostCard)
				table.insert(result, v)
			end
		end
	end

	if ghostCount >= 2 and table.nums(exceptGhostList) >= 1  then
		Log.i("--wangzhi--对子--单张+癞子--")
		local tmpTable = self:GetCountsByLevel(exceptGhostList,1,1)
		for i,v in ipairs(tmpTable) do
			if v[1].number < 16 then
				local tmpGhostCard = clone(v[1])
				tmpGhostCard.originalVal = self:GetGhostOriginalVal()
				table.insert(v,tmpGhostCard)
				table.insert(v,tmpGhostCard)
				table.insert(result, v)
			end
		end
	end

	if table.nums(tmpObCards) >= 3  then
		local tmpTable = self:GetCountsByLevel(tmpObCards,3)
		--将查出来的3张以上取出前三张
		for i,v in ipairs(tmpTable) do
			if #v > 3 then
				local newTable = {}
				table.insert(newTable, v[1])
				table.insert(newTable, v[2])
				table.insert(newTable, v[3])
				table.insert(result, newTable)
			else
				table.insert(result, v)
			end
		end
	end
	return result
end

--函数功能：     查找所有的三带二
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAll3And2(obCards)

	-- 增加癞子判断
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local result = {}
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	-- 判断癞子数量为1的时候
	if ghostCount >= 1 and table.nums(exceptGhostList) >= 4  then
		local tmpTable = self:GetCountsByLevel(exceptGhostList,2,1)
		local tmpTable1 = self:GetCountsByLevel(exceptGhostList,3,1)
		local tmpTable2 = self:GetCountsByLevel(exceptGhostList,1,1)
		if table.nums(tmpTable1) >= 1 and table.nums(tmpTable2) >= 1 then
			for i,v in ipairs(tmpTable1) do
				if tmpTable2[1][1].number < 16 then
					table.insert(v, tmpTable2[1][1])
					-- 补一张癞子
					local tmpGhostCard = clone(tmpTable2[1][1])
					tmpGhostCard.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard)
					table.insert(result, v)
				end
			end
		end

		if table.nums(tmpTable) >= 2 then
			for i,v in ipairs(tmpTable) do
				if i == 1 and tmpTable[i][1].number < 16 then
					-- 补对子
					table.insert(v, tmpTable[2][1])
					table.insert(v, tmpTable[2][2])
					-- 补三个
					local tmpGhostCard = clone(tmpTable[i][1])
					tmpGhostCard.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard)
					table.insert(result, v)
				elseif i>1 and tmpTable[i][1].number < 16 and tmpTable[1][1].number < 16 then
					-- 补对子
					table.insert(v, tmpTable[1][1])
					table.insert(v, tmpTable[1][2])
					-- 补三个
					local tmpGhostCard = clone(tmpTable[i][1])
					tmpGhostCard.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard)
					table.insert(result, v)
				end
			end
		end
	end

	-- 判断癞子数量为0的时候
	if ghostCount >= 0 and table.nums(exceptGhostList) >= 5  then
		local tmpTable = self:GetCountsByLevel(exceptGhostList,2,1)
		local tmpTable1 = self:GetCountsByLevel(exceptGhostList,3,1)

		if table.nums(tmpTable) >= 1 and table.nums(tmpTable1) >= 1 then
			for i,v in ipairs(tmpTable1) do
				table.insert(v, tmpTable[1][1])
				table.insert(v, tmpTable[1][2])
				table.insert(result, v)
			end
		end

		if table.nums(tmpTable1) >= 2 and table.nums(tmpTable) <= 0 then
			for i,v in ipairs(tmpTable1) do
				if i == 1 then
					table.insert(v, tmpTable1[2][1])
					table.insert(v, tmpTable1[2][2])
					table.insert(result, v)
				else
					table.insert(v, tmpTable1[1][1])
					table.insert(v, tmpTable1[1][2])
					table.insert(result, v)
				end
			end
		end

	end

	-- 判断癞子数量为2的时候
	if ghostCount >= 2 and table.nums(exceptGhostList) >= 3  then
		local tmpTable = self:GetCountsByLevel(exceptGhostList,2,1)
		local tmpTable1 = self:GetCountsByLevel(exceptGhostList,3,1)
		local tmpTable2 = self:GetCountsByLevel(exceptGhostList,1,1)
		-- 3+0 ,直接可以判断成五炸
		if table.nums(tmpTable1) >= 1 and table.nums(tmpTable2) == 0 then
			for i,v in ipairs(tmpTable1) do
				if tmpTable1[i][1].number < 16 then
					table.insert(v, ghostList[1])
					table.insert(v, ghostList[2])
					table.insert(result, v)
				end
			end
		end

		-- 2+1
		if table.nums(tmpTable) >= 1 and table.nums(tmpTable2) >= 1 then
			local result1 ={}
			for i,v in ipairs(tmpTable) do
				if tmpTable[i][1].number < 16 and tmpTable2[1][1].number < 16 then
					-- 两个补成三个
					local tmpGhostCard = clone(tmpTable[i][1])
					tmpGhostCard.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard)
					-- 单个补成对子
					local tmpGhostCard2 = clone(tmpTable2[1][1])
					tmpGhostCard2.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard2)

					table.insert(result1, v)
					table.insert(result, v)
				end
			end
			local result2 ={}
			for i,v in ipairs(tmpTable2) do
				if tmpTable2[i][1].number < 16 then
					-- 单个补成三个
					local tmpGhostCard = clone(tmpTable2[i][1])
					tmpGhostCard.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard)
					local tmpGhostCard2 = clone(tmpTable2[i][1])
					tmpGhostCard2.originalVal = self:GetGhostOriginalVal()
					table.insert(v,tmpGhostCard2)
					-- 插入对子
					-- 对子如果不用癞子补充,可以不用判断是否小于16
					table.insert(v, tmpTable[1][1])
					table.insert(v, tmpTable[1][2])

					table.insert(result2, v)
					table.insert(result, v)
				end
			end

			if obCards:CurrentLength() == 5 then
				result = {}
				if tmpTable[1][1].level > tmpTable2[1][1].level and #result1 >0 then
					result = result1
				elseif #result2 >0 then
					result = result2
				end
			end
		end
	end

	return result
end

--函数功能：     查找所有的顺子
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllSister(obCards,count)
	
	-- A2345的顺子压不起其它顺子,不用选出来了。

	-- 增加癞子判断
	local result = {}
	obCards = self:obCardsChangeLevel(obCards)
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local cards = exceptGhostList:GetCards()

	local tmp_cards = {}

	-- local counter = 1
	for i,v in pairs(cards) do
		if i == 1 and v.level>1 then
			local firstCount =  v.level - 1 
			for ii=1,firstCount do
				tmp_cards = tmp_cards or {}
				-- local tmpCardValue = 16 + ii
				-- 从2开始补充
				local tmpCardValue = 16 +15 - 2 + ii - 1
				if tmpCardValue - 16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end 
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards, tmpGhostCard)
			end
		end
		if i <= 1 then
			tmp_cards = tmp_cards or {}
			table.insert(tmp_cards, v)
		elseif v.level ~= cards[i - 1] .level then
			-- if ghostCount <= 0 then
			-- 	counter = counter + 1
			-- 	tmp_cards = tmp_cards or {}
			-- 	table.insert(tmp_cards, v)
			-- elseif ghostCount >= 1 then
				local count  = v.level - 1 - cards[i-1].level
				-- 差多少个,补几个癞子
				for ii=1,count do
					-- 补充一个假牌,其实是癞子牌
					local tmpCardValue = cards[i-1].originalVal + ii
					if tmpCardValue - cards[i-1].shape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else
	
					end
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
				table.insert(tmp_cards, v)
			-- end
		end
		if i == table.nums(cards) and v.level<=13 then
			-- 后面需要补癞子
			local lastCount =  13 - v.level 
			for ii=1,lastCount do
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = v.originalVal + ii
				if tmpCardValue - v.shape*16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end
				Log.i("--wangzhi--tmpCardValue--",tmpCardValue,ii)
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards, tmpGhostCard)
			end
		end
	end

	--判断出超出顺子个数的牌集
	cards = {}
	-- for i,v in pairs(tmp_cards) do
		-- if (table.nums(v) >= RULESETTING.nLimitSister) 
		-- 	and (table.nums(v) >= count) then
			if count > 0 then
				local cardObj = self:SizerCards(tmp_cards,count)
				for j,jv in pairs(cardObj) do
					table.insert( cards, jv)
				end
			else
				table.insert( cards, v)
			end
		-- end
	-- end

	for i,v in ipairs(cards) do
		local count = 0
		for ii,vv in ipairs(v) do
			if vv.originalVal == self:GetGhostOriginalVal() then
				count = count + 1
			end
		end
		if count <= ghostCount then
			table.insert(result,v)
		end
	end
	obCards = self:obCardsBackLevel(obCards)

	return result
end


--函数功能：     查找所有的连对	木板，只能3连
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllPairs(obCards,count)

	-- AA2233的木板压不起其它的木板,不需要判断

	-- 增加癞子判断
	local result = {}
	obCards = self:obCardsChangeLevel(obCards)
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local cards = exceptGhostList:GetCards()

	local tmp_cards = {}

	local counter = 1
	for i,v in pairs(cards) do
		if i == 1 and v.level>1  then
			local firstCount =  v.level - 1 
			for ii=1,firstCount do
				tmp_cards[counter] = tmp_cards[counter] or {}
				-- 补充一个假牌,其实是癞子牌
				-- local tmpCardValue = 16 + ii
				-- 从2开始补充
				local tmpCardValue = 16 +15 - 2 + ii - 1
				if tmpCardValue - 16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end 
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
		end
		if i <= 1 then
			tmp_cards[counter] = tmp_cards[counter] or {}
			-- -- 如果加入下一张不同的牌时,数量不是偶数,那么需要给前一张牌补充一张癞子
			-- if table.nums(tmp_cards[counter])%2 == 1 then
			-- 	-- 补充一个假牌,其实是癞子牌
			-- 	local tmpCardValue = cards[i-1].originalVal
			-- 	local tmpGhostCard = self:CreateGhostCard(tmpCardValue)
			-- 	table.insert(tmp_cards[counter], tmpGhostCard)
			-- end
			table.insert(tmp_cards[counter], v)
		elseif v.level ~= cards[i - 1] .level then
			-- 如果有跳过的时候，先判断是否要补一个癞子给上一张牌
			if table.nums(tmp_cards[counter])%2 == 1 then
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = cards[i-1].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			local count  = v.level - 1 - cards[i-1].level
			-- 差多少个,补几个癞子
			for ii=1,count do
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = cards[i-1].originalVal + ii
				if tmpCardValue - cards[i-1].shape*16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			table.insert(tmp_cards[counter], v)
		elseif v.level == cards[i - 1] .level then
			-- 如果连续三张一样，那么后面的不加入。
			if i==2 then
				table.insert(tmp_cards[counter], v)
			elseif i>=3 and v.level ~= cards[i - 2] .level then
				table.insert(tmp_cards[counter], v)
			end
		end
		if i == table.nums(cards) and v.level<=13  then
			-- 如果有跳过的时候，先判断是否要补一个癞子给上一张牌
			if table.nums(tmp_cards[counter])%2 == 1 then
				-- 补充一个假牌,其实是癞子牌
				-- 如果只有一张牌会报错
				-- local tmpCardValue = cards[i-1].originalVal
				local tmpCardValue = tmp_cards[counter][#tmp_cards[counter]].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			-- 后面需要补癞子
			local lastCount =  13 - v.level 
			for ii=1,lastCount do
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = v.originalVal + ii
				if tmpCardValue - v.shape*16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
		end
	end

	--判断出超出顺子个数的牌集
	cards = {}
	for i,v in pairs(tmp_cards) do
		-- 肯定是满的,不需要判断长度
		-- if (table.nums(v) >= RULESETTING.nLimitSister) 
		-- 	and (table.nums(v) >= count) then
			if count > 0 then
				local cardObj = self:SizerCardsStep2(v,count*2)
				for j,jv in pairs(cardObj) do
					table.insert( cards, jv)
				end
			else
				table.insert( cards, v)
			end
		-- end
	end

	for i,v in ipairs(cards) do
		local count = 0
		for ii,vv in ipairs(v) do
			if vv.originalVal == self:GetGhostOriginalVal() then
				count = count + 1
			end
		end
		if count <= ghostCount then
			table.insert(result,v)
		end
	end

	obCards = self:obCardsChangeLevel(obCards)
	return result
end

--函数功能：     查找所有的飞机	钢板，2连，不能带
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAll3Kinds(obCards,count)
	
	-- AAA222的钢板压不起其它的钢板,不需要判断

	-- 增加癞子判断
	local result = {}
	obCards = self:obCardsChangeLevel(obCards)
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local cards = exceptGhostList:GetCards()

	local tmp_cards = {}

	local counter = 1
	for i,v in pairs(cards) do
		if i == 1 and v.level>1  then
			local firstCount =  v.level - 1 
			for ii=1,firstCount do
				tmp_cards[counter] = tmp_cards[counter] or {}
				-- 补充一个假牌,其实是癞子牌
				-- local tmpCardValue = 16 + ii
				-- 从2开始补充
				local tmpCardValue = 16 +15 - 2 + ii - 1
				if tmpCardValue - 16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end 
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
		end
		if i <= 1 then
			tmp_cards[counter] = tmp_cards[counter] or {}
			-- -- 如果加入下一张不同的牌时,数量不是偶数,那么需要补充一张癞子
			-- if table.nums(tmp_cards[counter])%3 == 1 then
			-- 	-- 补充一个假牌,其实是癞子牌
			-- 	local tmpCardValue = cards[i-1].originalVal
			-- 	local tmpGhostCard = self:CreateGhostCard(tmpCardValue)
			-- 	table.insert(tmp_cards[counter], tmpGhostCard)
			-- 	table.insert(tmp_cards[counter], tmpGhostCard)
			-- elseif table.nums(tmp_cards[counter])%3 == 2 then
			-- 	-- 补充一个假牌,其实是癞子牌
			-- 	local tmpCardValue = cards[i-1].originalVal
			-- 	local tmpGhostCard = self:CreateGhostCard(tmpCardValue)
			-- 	table.insert(tmp_cards[counter], tmpGhostCard)
			-- end
			table.insert(tmp_cards[counter], v)
		elseif v.level ~= cards[i - 1] .level then
			-- 如果有跳过的时候，先判断是否要补一个癞子给上一张牌
			if table.nums(tmp_cards[counter])%3 == 1 then
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = cards[i-1].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			elseif table.nums(tmp_cards[counter])%3 == 2 then
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = cards[i-1].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			local count  = v.level - 1 - cards[i-1].level
			-- 差多少个,补几个癞子
			for ii=1,count do
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = cards[i-1].originalVal + ii
				if tmpCardValue - cards[i-1].shape*16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			table.insert(tmp_cards[counter], v)
		elseif v.level == cards[i - 1] .level then
			-- 如果连续三张一样，那么后面的不加入。	
			if i==2 or i==3 then
				table.insert(tmp_cards[counter], v)
			elseif i>=4 and v.level ~= cards[i - 3] .level then
				table.insert(tmp_cards[counter], v)
			end

		end
		if i == table.nums(cards) and v.level<=13  then
			-- 如果有跳过的时候，先判断是否要补一个癞子给上一张牌
			if table.nums(tmp_cards[counter])%3 == 1 then
				-- 补充一个假牌,其实是癞子牌
				-- local tmpCardValue = cards[i-1].originalVal
				local tmpCardValue = tmp_cards[counter][#tmp_cards[counter]].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			elseif table.nums(tmp_cards[counter])%3 == 2 then
				-- 补充一个假牌,其实是癞子牌
				-- local tmpCardValue = cards[i-1].originalVal
				local tmpCardValue = tmp_cards[counter][#tmp_cards[counter]].originalVal
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
			-- 后面需要补癞子
			local lastCount =  13 - v.level 
			for ii=1,lastCount do
				-- 补充一个假牌,其实是癞子牌
				local tmpCardValue = v.originalVal + ii
				if tmpCardValue - v.shape*16 + 2 > 15 then
					Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
					tmpCardValue = tmpCardValue - 13
				else

				end
				local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
				table.insert(tmp_cards[counter], tmpGhostCard)
			end
		end
	end

	--判断出超出顺子个数的牌集
	cards = {}
	for i,v in pairs(tmp_cards) do
		-- if (table.nums(v) >= RULESETTING.nLimitSister) 
		-- 	and (table.nums(v) >= count) then
			if count > 0 then
				local cardObj = self:SizerCardsStep3(v,count*3)
				for j,jv in pairs(cardObj) do
					table.insert( cards, jv)
				end
			else
				table.insert( cards, v)
			end
		-- end
	end

	for i,v in ipairs(cards) do
		local count = 0
		for ii,vv in ipairs(v) do
			if vv.originalVal == self:GetGhostOriginalVal() then
				count = count + 1
			end
		end
		if count <= ghostCount then
			table.insert(result,v)
		end
	end

	obCards = self:obCardsChangeLevel(obCards)
	return result


end

--函数功能：     查找所有的普通炸弹	多张相同牌
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllBOMB(obCards,isDesc,count)
	
	-- 增加癞子判断
	local result = {}
	if (count > obCards:CurrentLength()) then
		return result
	end
	obCards:SortCards(0)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local tmp_cards = self:GetCountsByLevel(exceptGhostList,4-ghostCount)
	Log.i("--wangzhi--table.nums(tmp_cards)--",table.nums(tmp_cards))
	-- 这里不能直接判断为数量1,因为输入牌的值大于等于了4张,则不会返回值
	if table.nums(tmp_cards) >= 1 then
		for i,v in ipairs(tmp_cards) do
			local tmpCard = {}
			if v[1].number < 16 then
				for ii,vv in ipairs(v) do
					table.insert(tmpCard,vv)
					if #tmpCard>=4 then
						local tmpBom = clone(tmpCard)
						table.insert(result, tmpBom)
					end
					if ii == table.nums(v) then
						for i=1,ghostCount do
							-- 补充一个假牌,其实是癞子牌
							local tmpCardValue = vv.originalVal
							local tmpGhostCard = self:CreateGhostCard(tmpCardValue)
							table.insert(tmpCard, tmpGhostCard)
							if #tmpCard>=4 then
								local tmpBom = clone(tmpCard)
								table.insert(result, tmpBom)
							end
						end
					end
				end
			end
			-- table.insert(result, tmpCard)
		end
	end
	if isDesc then
		local tmp_cards2 = {}
		for k, v in ipairs(result) do
			if #v == obCards:CurrentLength() then
				table.insert(tmp_cards2, v)
			end
		end
		result = tmp_cards2
	end
	return result

end

--函数功能：	根据权值统计操作对象中大于或等于给定张数的牌的点数
--obCards:		目标牌集
--nCount:		给定张数
--mod:			模式（取0时，将张数大于nCount的数组保存，取1时将张数等于nCount的数组保存）
--返回值：		符合条件的牌组
function GDGameRule:GetCountsByLevel(obCards,nCount,mod)
	mod = mod or 0

	local fenxi = self:CardsFenXi(obCards)
	local tmp_cards = {}
	for i,v in pairs(fenxi) do
		-- 判断是否寻找的是炸弹，如果不是则不能拆炸弹，如果是直接找比炸弹多的牌则直接检测炸弹
		local vNum = table.nums(v)

		-- 需要拆炸弹
		-- local minBomLevel = mod == 0 and (vNum >= nCount and vNum < RULESETTING.nLimitBom) or vNum == nCount
		local minBomLevel = mod == 0 and (vNum >= nCount) or vNum == nCount
		local maxBomLevel = mod == 0 and vNum >= nCount  or vNum == nCount
		-- Log.i("--wangzhi--minBomLevel--",minBomLevel)
		-- Log.i("--wangzhi--maxBomLevel--",maxBomLevel)
		if (nCount < RULESETTING.nLimitBom and minBomLevel)
			 or ( nCount >= RULESETTING.nLimitBom and maxBomLevel ) then
			table.insert(tmp_cards,v)
		end
	end
	return tmp_cards
end


--函数功能：	排除二以上的牌
--obCards:		目标牌集
--cardLevel:	需要排除的牌
--返回值：		处理后的牌集
function GDGameRule:OperationCard(obCards,cardLevel)
	cardLevel = cardLevel or 13
	obCards:SortCards(0)
	obCards = clone(obCards)
	local operationCardList = obCards:GetCards()
	for i = #operationCardList,1,-1 do
		if operationCardList[i].level > cardLevel then
			obCards:DelCard(i)
		else
			break
		end
	end
	return obCards
end


--函数功能：     查找所有的同花顺
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllSisterBombs(obCards,last_cards,count,isDesc,lastCardsType)
	--把所有相连的牌都放一起
	local result = {}

	-- 如果判断所选牌是否可以压,需要所选牌符合当前判定牌的张数
	if isDesc then
		if obCards:CurrentLength() ~=5 then
			return result
		end
	end

	obCards = self:obCardsChangeLevel(obCards)
	obCards:SortCards(0)
	local ghostCount,ghostList =self:GetCardsGhostList(obCards)
	local tmpObCards = clone(obCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	local cards = exceptGhostList:GetCards()

	local shapeCards = {}
	for i,v in ipairs(cards) do
		-- Log.i("--wangzhi--shape--level--",cards[i].shape,cards[i].level)
		if cards[i].shape == 1 then
			if not shapeCards[1] then
			 	shapeCards[1] = {}
			end
			table.insert(shapeCards[1],cards[i])
		elseif cards[i].shape == 2 then
			if not shapeCards[2] then
			 	shapeCards[2] = {}
			end
			table.insert(shapeCards[2],cards[i])
		elseif cards[i].shape == 3 then
			if not shapeCards[3] then
			 	shapeCards[3] = {}
			end
			table.insert(shapeCards[3],cards[i])
		elseif cards[i].shape == 4 then
			if not shapeCards[4] then
			 	shapeCards[4] = {}
			end
			table.insert(shapeCards[4],cards[i])
		else
			
		end
	end

	local sisterBombs = {}
	-- local counter = 1
	for k,vv in pairs(shapeCards) do
		local cardShape = k
		local cards = vv
		local tmp_cards = {}
		for i,v in pairs(cards) do
			if i == 1 and v.level>1 then
			-- if i == 1 and v.level>1 and ghostCount >= 1 then
				local firstCount =  v.level - 1 
				for ii=1,firstCount do
					tmp_cards = tmp_cards or {}
					-- 从2开始补充
					local tmpCardValue = 16*(cardShape) +15 - 2 + ii - 1
					if tmpCardValue - cardShape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else

					end 
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
			end
			if i <= 1 then
				tmp_cards = tmp_cards or {}
				table.insert(tmp_cards, v)
			elseif v.level ~= cards[i - 1].level then
				-- if ghostCount <= 0 then
				-- 	counter = counter + 1
				-- 	tmp_cards = tmp_cards or {}
				-- 	table.insert(tmp_cards, v)
				-- elseif ghostCount >= 1 then
					local count  = v.level - 1 - cards[i-1].level
					-- 差多少个,补几个癞子
					-- if count <= 2 then
						for ii=1,count do
							local tmpCardValue = cards[i-1].originalVal + ii
							if tmpCardValue - cards[i-1].shape*16 + 2 > 15 then
								Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
								tmpCardValue = tmpCardValue - 13
							else
		
							end 
							local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
							table.insert(tmp_cards, tmpGhostCard)
						end
						table.insert(tmp_cards, v)
					-- end
				-- end
			end
			-- if i == table.nums(cards) and v.level<12 and ghostCount >= 1 then
			if i == table.nums(cards) and v.level<=13 then
				-- 后面需要补癞子
				local lastCount =  13 - v.level 
				for ii=1,lastCount do
					local tmpCardValue = v.originalVal + ii
					if tmpCardValue - v.shape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else
	
					end
					Log.i("--wangzhi--tmpCardValue--",tmpCardValue,ii)
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
			end
		end
		table.insert(sisterBombs,tmp_cards)
	end


	--判断出超出顺子个数的牌集
	cards = {}
	count = count or 0
	for k,vv in ipairs(sisterBombs) do
		-- local tmp_cards = vv
		-- for i,v in pairs(tmp_cards) do
			-- 肯定是满的,不需要判断长度
			-- if (table.nums(v) >= RULESETTING.nLimitSister) 
			-- 	and (table.nums(v) >= count) then
				if count > 0 then
					local cardObj = self:SizerCards(vv,count)
					for j,jv in pairs(cardObj) do
						table.insert( cards, jv)
					end
				else
					table.insert(cards, vv)
				end
			-- end
		-- end
	end

	for i,v in ipairs(cards) do
		local count = 0
		for ii,vv in ipairs(v) do
			if vv.originalVal == self:GetGhostOriginalVal() then
				count = count + 1
			end
		end
		if count <= ghostCount then
			table.insert(result,v)
		end
	end


	obCards = self:obCardsBackLevel(obCards)

	-- return result
-----------------------------------------------------------------------------------------
	-- 将权重进行改变,改为12345依次的权重
	obCards = self:obCardsChangeLevelA23(obCards)
	local tmpObCards2 = clone(obCards)
	-- 将5以上权重的牌排除,只留下A2345
	tmpObCards2 = self:OperationCard(tmpObCards2,5)
	local exceptGhostList2 = self:DelGhostList(tmpObCards2)
	local cards2 = exceptGhostList2:GetCards()

	--把所有相连的牌都放一起
	local shapeCards2 = {}

	for i,v in ipairs(cards2) do
		-- Log.i("--wangzhi--shape--level--",cards[i].shape,cards[i].level)
		if cards2[i].shape == 1 then
			if not shapeCards2[1] then
			 	shapeCards2[1] = {}
			end
			table.insert(shapeCards2[1],cards2[i])
		elseif cards2[i].shape == 2 then
			if not shapeCards2[2] then
			 	shapeCards2[2] = {}
			end
			table.insert(shapeCards2[2],cards2[i])
		elseif cards2[i].shape == 3 then
			if not shapeCards2[3] then
			 	shapeCards2[3] = {}
			end
			table.insert(shapeCards2[3],cards2[i])
		elseif cards2[i].shape == 4 then
			if not shapeCards2[4] then
			 	shapeCards2[4] = {}
			end
			table.insert(shapeCards2[4],cards2[i])
		else
			
		end
	end

	local sisterBombs2 = {}
	for k,vv in pairs(shapeCards2) do
		local cardShape = k
		local cards = vv
		local tmp_cards = {}
		for i,v in pairs(cards) do
			if i == 1 and v.level>1 then
				local firstCount =  v.level - 1 
				for ii=1,firstCount do
					tmp_cards = tmp_cards or {}
					-- 从2开始补充
					local tmpCardValue = 16*(cardShape) +15 - 2 + ii - 1
					if tmpCardValue - cardShape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else

					end 
					Log.i("--wangzhi--tmpCardValue--",tmpCardValue,ii)
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
			end
			if i <= 1 then
				tmp_cards = tmp_cards or {}
				table.insert(tmp_cards, v)
			elseif v.level ~= cards[i - 1] .level then
				local count  = v.level - 1 - cards[i-1].level
				-- 差多少个,补几个癞子
				for ii=1,count do
					local tmpCardValue = cards[i-1].originalVal + ii
					if tmpCardValue - cards[i-1].shape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了002--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else

					end 
					Log.i("--wangzhi--tmpCardValue--",tmpCardValue,ii)
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
				table.insert(tmp_cards, v)
			end
			if i == table.nums(cards) and v.level<=5 then
				-- 后面需要补癞子
				local lastCount =  5 - v.level 
				for ii=1,lastCount do
					local tmpCardValue = v.originalVal + ii
					-- 大于15了说明已经过了2了,那么下一张应该为3,故减少13
					if tmpCardValue - v.shape*16 + 2 > 15 then
						Log.i("--wangzhi--tmpCardValue--轮回了003--",tmpCardValue,ii)
						tmpCardValue = tmpCardValue - 13
					else

					end 
					Log.i("--wangzhi--tmpCardValue--",tmpCardValue,ii)
					local tmpGhostCard = self:CreateGhostCard(tmpCardValue,true)
					table.insert(tmp_cards, tmpGhostCard)
				end
			end
		end
		table.insert(sisterBombs2,tmp_cards)
	end

	--判断出超出顺子个数的牌集
	cards = {}
	count = count or 0
	for k,vv in ipairs(sisterBombs2) do
		-- local tmp_cards = vv
		-- for i,v in pairs(tmp_cards) do
			-- 肯定是满的,不需要判断长度
			-- if (table.nums(v) >= RULESETTING.nLimitSister) 
			-- 	and (table.nums(v) >= count) then
				if count > 0 then
					local cardObj = self:SizerCards(vv,count)
					for j,jv in pairs(cardObj) do
						table.insert( cards, jv)
					end
				else
					table.insert(cards, vv)
				end
			-- end
		-- end
	end
	local sisterBombs12345 = {}
	for i,v in ipairs(cards) do
		local count = 0
		for ii,vv in ipairs(v) do
			if vv.originalVal == self:GetGhostOriginalVal() then
				count = count + 1
			end
		end
		if count <= ghostCount then
			-- sisterBombs12345 = v
			table.insert(sisterBombs12345,v)
		end
	end

	obCards = self:obCardsBackLevel(obCards)
	
-- -----------------------------------------------------------------------------------------
-- 	obCards = self:obCardsBackLevel(obCards)
	result = self:Compare_Sister_Bomb(result,last_cards,sisterBombs12345,lastCardsType)
	
	if isDesc then
		local tmp_cards2 = {}
		for k, v in ipairs(result) do
			if #v == obCards:CurrentLength() then
				table.insert(tmp_cards2, v)
			end
		end
		result = tmp_cards2
	end


	if isDesc and #result>=1 then
		local tmpResult = {}
		table.insert(tmpResult,result[#result])
		result = tmpResult
	end

	return result
end

--函数功能：     打印出可以压的牌
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:Compare_Sister_Bomb(obCards,last_cards,sisterBombs12345,lastCardsType)
	local result = {}
	if last_cards then
		last_cards = self:obCardsChangeLevel(last_cards)
	else
		-- 如果没有要对比的牌,直接加入就好了
		result = obCards
		if #sisterBombs12345 > 0 then
			for i,v in ipairs(sisterBombs12345) do
				table.insert(result,v)
			end
		end
		return result
	end
	local lastCardType = lastCardsType
	if lastCardType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
		if #(last_cards:GetCards())>=6 then
			result = {}
			Log.i("--wangzhi--炸弹大于6个--同花顺压不住")
		else
			result = obCards
			if #sisterBombs12345 > 0 then
				for i,v in ipairs(sisterBombs12345) do
					table.insert(result,v)
				end
			end	
		end
	elseif lastCardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
		result = {}
	elseif lastCardType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
		Log.i("--wangzhi--同花顺压同花顺")
		--筛选
		-- last_cards = self:obCardsChangeLevel(last_cards)
		local tmp_last_cards = clone(last_cards)
		tmp_last_cards = self:obCardsChangeLevelA23(tmp_last_cards)
		local cardType,isA2345sister = self:Find_SISTER_BOMB(last_cards)
		if isA2345sister then
			result = obCards
			return result
		end
		

		if #obCards>=1 then
		-- 不进行遍历了,直接取最大的进行对比
		-- for k, v in ipairs(obCards) do
			local cardSet = require("package_src.games.guandan.gdpoker.CardSet"):new()
			-- cardSet:AddCards(v)
			cardSet:AddCards(obCards[#obCards])
			local cmpRlt = enmTypeCompareResult.ETCR_OTHER
			if cardSet:CurrentLength() == last_cards:CurrentLength() then
				local tmpCardSet = self:GetMaxCard(cardSet,lastCardType)
				local selfMinLvl = self:GetMinLevel(tmpCardSet)
				-- 将一组带癞子的牌转换成要替代的牌

				local tmpLast_cards = self:GetMaxCard(last_cards,lastCardType)
				-- tmpLast_cards:SortCards(0)
				local obMinLvl = self:GetMinLevel(tmpLast_cards)
				-- local obMinLvl = self:GetMinLevel(last_cards)
				if selfMinLvl > obMinLvl then
					cmpRlt = enmTypeCompareResult.ETCR_MORE
				elseif selfMinLvl < obMinLvl then
					cmpRlt = enmTypeCompareResult.ETCR_LESS
				else
					cmpRlt = enmTypeCompareResult.ETCR_EQUAL
				end
			end
			if cmpRlt == enmTypeCompareResult.ETCR_MORE then
				print(cmpRlt)
				table.insert(result, obCards[#obCards])
			end
		end
		-- end
	else
		result = obCards
		if #sisterBombs12345 > 0 then
			for i,v in ipairs(sisterBombs12345) do
				table.insert(result,1,v)
			end
		end
	end
	if last_cards then
		last_cards = self:obCardsBackLevel(last_cards)
	end
	return result
end

--函数功能：     打印出可以压的牌
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:printResult(obCards,last_cards)
		if #obCards <= 0 then
			Log.i("--wangzhi--为什么return")
			return
		end
		local CardNumber = {}
		local CardShape = {}
		Log.i("--wangzhi--printResult--#obCards--",#obCards)
		for k,v in pairs(obCards) do
			local number = {}
			local shape = {}
			Log.i("--wangzhi--printResult--#v--",#v)
			for i,v2 in ipairs(v) do
				Log.i("--wangzhi--printResult--v2--",v2)
				table.insert(number,v2.number)
				table.insert(shape,v2.shape)
			end
			table.insert(CardNumber,number)
			table.insert(CardShape,shape)
		end
		Log.i("--wangzhi--提示的内容为(筛选后)001--",CardNumber)
		-- Log.i("--wangzhi--提示的内容花色为(筛选后)--",CardShape)

		-- local yaCardNumber = {}
		-- local yaCardShape = {}
		-- for i=1,(last_cards:CurrentLength()) do
		-- 	table.insert(yaCardNumber,last_cards:Card(i).number)
		-- 	table.insert(yaCardShape,last_cards:Card(i).shape)
		-- end
		-- Log.i("--wangzhi--需要压的牌002--",yaCardNumber)
end


--函数功能：     查找所有的天王炸
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GDGameRule:FindPressAllKingBombs(obCards,last_cards,isDesc,lastCardsType)
	Log.i("--wangzhi--判断是否是天王炸--")
	local result = {}
	if last_cards then
		local lastCardType = lastCardsType
		if lastCardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
			return result
		end
	end

	-- 如果判断所选牌是否可以压,需要所选牌符合当前判定牌的张数
	if isDesc then
		if obCards:CurrentLength() ~=4 then
			return result
		end
	end


	local kingBomb = {}
	local JokerCount = 0
	local JOKERCount = 0
	for i,v in ipairs(obCards:GetCards()) do
		if v.number ~= enmCardNumber.ECN_NUM_Joker and v.number ~= enmCardNumber.ECN_NUM_JOKER then
			-- return result
		end
		if v.number == enmCardNumber.ECN_NUM_Joker and JokerCount <=1 then
			JokerCount = JokerCount + 1
			table.insert(kingBomb,v)
		elseif v.number == enmCardNumber.ECN_NUM_JOKER and JOKERCount <=1  then
			JOKERCount = JOKERCount + 1
			table.insert(kingBomb,v)
		end
	end
	if JokerCount >= 2 and JOKERCount >= 2 then
		-- for i,v in ipairs(kingBomb) do
		-- 	Log.i("--wangzhi--v.number--",v.number)
		-- end
		table.insert(result,kingBomb)
		Log.i("--wangzhi--#result--",#result)
		Log.i("--wangzhi--找到天王炸")
		-- return result
	else
		Log.i("--不是2张大王和2个小王--")
		-- return result
	end
	

	if last_cards then
		local lastCardType = lastCardsType
		if lastCardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
			result = {}
		end
	end

	-- 如果判断压不压的起的时候,需要选的张数和要出的张数一样多
	if isDesc then
		local tmp_cards2 = {}
		for k, v in ipairs(result) do
			if #v == obCards:CurrentLength() then
				table.insert(tmp_cards2, v)
			end
		end
		result = tmp_cards2
	end

	return result
end

--函数功能：     牌型判断
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 int
function GDGameRule:CardsType(obCards,lastCardType)
	if not obCards then
		return
	end
	-- print(debug.traceback())
	-- Log.i("--wangzhi--进入牌的类型判断--",CardNumber)
	local CardNumber = {}
	local CardShape = {}
	for i=1,(obCards:CurrentLength()) do
		table.insert(CardNumber,obCards:Card(i).number)
		table.insert(CardShape,obCards:Card(i).shape)
	end
	-- Log.i("--wangzhi--判断牌的花色--",CardShape)
	-- Log.i("--wangzhi--判断牌的类型--",CardNumber)

	local cardType = enmCardType.EBCT_TYPE_NONE
	if obCards:CurrentLength() > 0 then
		local tmpCards = clone(obCards) --生成临时变量
		-- 牌类型判断
		if self:Find_KING_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB
			Log.i("--wangzhi--判断为--天王炸")
		elseif self:Find_SISTER_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB
			Log.i("--wangzhi--判断为--同花顺")
		elseif self:Find_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_CUSTOMERTYPE_BOMB
			Log.i("--wangzhi--判断为--普通炸弹")
		elseif self:Find_3KINDS(tmpCards) and lastCardType ~= enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
			cardType = enmCardType.EBCT_CUSTOMERTYPE_3KINDS
			Log.i("--wangzhi--判断为--钢板")
		elseif self:Find_PAIRS(tmpCards) then
			cardType = enmCardType.EBCT_CUSTOMERTYPE_PAIRS
			Log.i("--wangzhi--判断为--木板")
		elseif self:Find_SISTER(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SISTER
			Log.i("--wangzhi--判断为--顺子")
		elseif self:Find_3AND2(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3AND2
			Log.i("--wangzhi--判断为--三代二")
		elseif self:Find_3KIND(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KIND
			Log.i("--wangzhi--判断为--三个")
		elseif self:Find_PAIR(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_PAIR
			Log.i("--wangzhi--判断为--对子")
		elseif self:Find_SINGLE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SINGLE
			Log.i("--wangzhi--判断为--单张")
		end
	end
	return cardType 
end

--函数功能：     牌型判断 	单张
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_SINGLE(obCards)
	-- 单张不用增加癞子判断
	return (1 == obCards:CurrentLength())
end

--函数功能：     牌型判断 	对子
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_PAIR(obCards)

	-- 增加癞子判断
	if (2 ~= obCards:CurrentLength()) then
		return false
	end
	obCards:SortCards(0)
	local result = false
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList =self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	if ghostCount == 1 and exceptGhostList:GetCards()[1].number < 16 then
		Log.i("--wangzhi--对子--单张+癞子--")
		return true
	elseif ghostCount == 2 then
		return true
	else
		if (tmpObCards:Card(1).level == tmpObCards:Card(2).level) then
			result = true
			Log.i("--wangzhi--对子--普通对子--")
		end
	end

	return result

end

--函数功能：     牌型判断 	三张
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_3KIND(obCards)

	-- 增加癞子判断
	if (3 ~= obCards:CurrentLength()) then
		return false
	end
	local result = false
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	if ghostCount>0 then
		if ghostCount == 1 then
			local tmp_cards = self:GetCountsByLevel(exceptGhostList,2)
			if table.nums(tmp_cards) > 0 and tmp_cards[1][2].number < 16 then
				Log.i("--wangzhi--三张--对子+癞子--")
				return true
			end
		elseif ghostCount == 2 then
			Log.i("--wangzhi--exceptGhostList:GetCards()[1].number--",exceptGhostList:GetCards()[1].number)
			if exceptGhostList:GetCards()[1].number < 16 then
				Log.i("--wangzhi--三张--单张+癞子*2")
				return true
			end
		end
	else
		local tmp_cards = self:GetCountsByLevel(tmpObCards,3)
		if table.nums(tmp_cards) > 0 then
			Log.i("--wangzhi--三张--三张相同")
			return true
		end
	end
	return result

end

--函数功能：     牌型判断 	三带二
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_3AND2(obCards)

	if (5 ~= obCards:CurrentLength()) then
		return false
	end
	local result = false
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)
	if ghostCount>0 then
		if ghostCount == 1 then
			local tmp_cards = self:GetCountsByLevel(exceptGhostList,2)
			if table.nums(tmp_cards) == 2 and (tmp_cards[1][1].number < 16 or tmp_cards[2][1].number < 16) then
				Log.i("--wangzhi--三带二--2对子+癞子--")
				return true
			end
			local tmp_cards1 = self:GetCountsByLevel(exceptGhostList,3,1)
			local tmp_cards2 = self:GetCountsByLevel(exceptGhostList,1,1)
			-- 单张不能为王，癞子不能当癞子
			if table.nums(tmp_cards1) == 1 and (tmp_cards2[1][1].number < 16) then
				Log.i("--wangzhi--三带二--3张+单张(小于王)+癞子--")
				return true
			end

		elseif ghostCount == 2 then
			-- 可以判断为炸弹了
			-- local tmp_cards = self:GetCountsByLevel(exceptGhostList,3,1)
			-- if table.nums(tmp_cards) == 1 then
			-- 	Log.i("--wangzhi--三带二--3张+2癞子--")
			-- 	return true
			-- end
			local tmp_cards1 = self:GetCountsByLevel(exceptGhostList,2,1)
			local tmp_cards2 = self:GetCountsByLevel(exceptGhostList,1,1)
			if table.nums(tmp_cards1) == 1 and (tmp_cards2[1][1].number < 16) then
				Log.i("--wangzhi--三带二--对子+单张+2癞子--")
				return true
			end
		end
	else
		local tmp_cards = self:GetCountsByLevel(tmpObCards,3,1)
		if 1 == table.nums(tmp_cards) then
			local tmp_cards1 = self:GetCountsByLevel(tmpObCards,2,1)
			if 1 == table.nums(tmp_cards1) then
				return true
			end
		end
	end

end

--函数功能：     牌型判断 	顺子
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_SISTER(obCards)

	-- 顺子时,级牌没有用
	if (5 ~= obCards:CurrentLength()) then
		return false
	end
	obCards = self:obCardsChangeLevel(obCards)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)

	tmpObCards:SortCards(0)
	local result = false
	if (ghostCount + exceptGhostList:CurrentLength()) >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(exceptGhostList,1,1)
		if table.nums(tmp_cards) == exceptGhostList:CurrentLength() then
			local bSucc = true
			local isShape = true
			for i=2, exceptGhostList:CurrentLength() do
				-- 在牌的基础上增加花色判断
				if exceptGhostList:Card(i).shape ~= exceptGhostList:Card(i-1).shape then
					Log.i("--wangzhi--花色不一样，不是同花顺")
					isShape = false
				end
				if ((exceptGhostList:Card(i).level - 1) ~= exceptGhostList:Card(i-1).level) and (exceptGhostList:Card(i).level <=13) then
					local count = (exceptGhostList:Card(i).level -1) - exceptGhostList:Card(i-1).level
					Log.i("--wangzhi--两牌相差--",count)
					ghostCount = ghostCount - count
					if ghostCount < 0 then
						Log.i("--wangzhi--癞子不够填补--")
						bSucc = false
						break
					end
				end
			end
			result = bSucc
			-- 顺子的同时,判断是否为同花顺
			if isShape then
				Log.i("--wangzhi--此牌型为同花顺,不归在顺子类")
				result = false
			end
		end
	end

	obCards = self:obCardsBackLevel(obCards)

	if result then
		Log.i("--wangzhi--普通顺子--")
		return result
	end


------------------------------------------------------------------------------

	-- 将权重进行改变,改为12345依次的权重
	obCards = self:obCardsChangeLevelA23(obCards)
	local tmpObCards2 = clone(obCards)
	local ghostCount2,ghostList2 = self:GetCardsGhostList(tmpObCards2)
	-- 将5以上权重的牌排除,只留下A2345
	tmpObCards2 = self:OperationCard(tmpObCards2,5)
	local exceptGhostList2 = self:DelGhostList(tmpObCards2)
	local cards2 = exceptGhostList2:GetCards()

	if (ghostCount2 + exceptGhostList2:CurrentLength()) >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(exceptGhostList2,1,1)
		if table.nums(tmp_cards) == exceptGhostList2:CurrentLength() then
			local bSucc = true
			local isShape = true
			for i=2, exceptGhostList2:CurrentLength() do
				-- 在牌的基础上增加花色判断
				if exceptGhostList2:Card(i).shape ~= exceptGhostList2:Card(i-1).shape then
					Log.i("--wangzhi--花色不一样，不是同花顺")
					isShape = false
				end
				if ((exceptGhostList2:Card(i).level - 1) ~= exceptGhostList2:Card(i-1).level) and (exceptGhostList2:Card(i).level <=5) then
					local count = (exceptGhostList2:Card(i).level -1) - exceptGhostList2:Card(i-1).level
					Log.i("--wangzhi--两牌相差--",count)
					ghostCount2 = ghostCount2 - count
					if ghostCount2 < 0 then
						Log.i("--wangzhi--癞子不够填补--")
						bSucc = false
						break
					end
				end
			end
			result = bSucc
			-- 顺子的同时,判断是否为同花顺
			if isShape then
				Log.i("--wangzhi--此牌型为同花顺,不归在顺子类")
				result = false
			end
		end
	end

	obCards = self:obCardsBackLevel(obCards)
	if result then
		Log.i("--wangzhi--A2345顺子--")
		return result ,true
	end

	return result

end

--函数功能：     牌型判断 	木板(3连对)
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_PAIRS(obCards)

--------------------------------------------------------------------------------------------
	if (6 ~= obCards:CurrentLength()) then
		return false
	end
	obCards:SortCards(0)
	obCards = self:obCardsChangeLevel(obCards)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)

	local result = false
	local bSucc = true
	local tmp_cards = self:GetCountsByLevel(exceptGhostList,1)
	local tmp_cards1 = self:GetCountsByLevel(exceptGhostList,2,1)
	local tmp_cards2 = self:GetCountsByLevel(exceptGhostList,3)
	-- 不同的牌小于3张,并且不能有3张及以上的牌
	if table.nums(tmp_cards) <= 3 and table.nums(tmp_cards) >= 2 and table.nums(tmp_cards2) <= 0 then
		-- 三种不同牌面时,必须连续
		if table.nums(tmp_cards) == 3 then
			for i=2, table.nums(tmp_cards) do
				if ((tmp_cards[i][1].level - 1) ~= tmp_cards[i-1][1].level) or tmp_cards[i][1].level >13 then
					-- local count = (tmp_cards[i][1].level -1) - tmp_cards[i-1][1].level
					-- Log.i("--wangzhi--两牌相差--",count)
					-- ghostCount = ghostCount - count
					-- if ghostCount < 0 then
					-- 	Log.i("--wangzhi--癞子不够填补--")
					-- 	bSucc = false
					-- 	break
					-- end
					bSucc = false
					break
				end
			end
			-- Log.i("--wangzhi--木板--三种牌--")
		end

		-- 两种牌时,必须有2个癞子
		if table.nums(tmp_cards) == 2 and ghostCount == 2 then
			if math.abs((tmp_cards[1][1].level) - tmp_cards[2][1].level) > 2 then
				bSucc = false
			end
			-- Log.i("--wangzhi--木板--2对子+2癞子--")
		end
		result = bSucc
	end

	obCards = self:obCardsBackLevel(obCards)
	if result then
		Log.i("--wangzhi--普通的连对--")
		return result
	end

-----------------------------------------------------------------------------
	-- AA2233连对
	obCards = self:obCardsChangeLevelA23(obCards)
	local tmpObCards2 = clone(obCards)
	local ghostCount2,ghostList2 = self:GetCardsGhostList(tmpObCards2)
	tmpObCards2 = self:OperationCard(tmpObCards2,3)
	if tmpObCards2:CurrentLength() + ghostCount2 < 6 then
		Log.i("--wangzhi--不全是A23--")
		return false
	end
	local exceptGhostList2 = self:DelGhostList(tmpObCards2)

	obCards:SortCards(0)
	result = false
	bSucc = true
	local tmp2_cards = self:GetCountsByLevel(exceptGhostList2,1)
	local tmp2_cards1 = self:GetCountsByLevel(exceptGhostList2,2,1)
	local tmp2_cards2 = self:GetCountsByLevel(exceptGhostList2,3)
	-- 不同的牌小于3张,并且不能有3张及以上的牌
	if table.nums(tmp2_cards) <= 3 and table.nums(tmp2_cards) >= 2 and table.nums(tmp2_cards2) <= 0 then
		-- 三种不同牌面时,必须连续
		if table.nums(tmp2_cards) == 3 then
			for i=2, table.nums(tmp2_cards) do
				if ((tmp2_cards[i][1].level - 1) ~= tmp2_cards[i-1][1].level) or tmp2_cards[i][1].level >13 then
					-- local count = (tmp2_cards[i][1].level -1) - tmp2_cards[i-1][1].level
					-- Log.i("--wangzhi--两牌相差--",count)
					-- ghostCount2 = ghostCount2 - count
					-- if ghostCount2 < 0 then
					-- 	Log.i("--wangzhi--癞子不够填补--")
					-- 	bSucc = false
					-- 	break
					-- end
					bSucc = false
					break
				end
			end
			-- Log.i("--wangzhi--木板--三种牌--")
		end

		-- 两种牌时,必须有2个癞子
		if table.nums(tmp2_cards) == 2 and ghostCount2 == 2 then
			if math.abs((tmp2_cards[1][1].level) - tmp2_cards[2][1].level) > 2 then
				bSucc = false
			end
			-- Log.i("--wangzhi--木板--2对子+2癞子--")
		end
		result = bSucc
	end

	obCards = self:obCardsBackLevel(obCards)
	
	if result then
		Log.i("--wangzhi--A23的连对--")
		return result,true
	end
	return result
end

--函数功能：     牌型判断 	钢板(2连飞机)
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_3KINDS(obCards)
	
----------------------------------------------------------------------------
	if (6 ~= obCards:CurrentLength()) then
		return false
	end
	obCards:SortCards(0)
	obCards = self:obCardsChangeLevel(obCards)
	local tmpObCards = clone(obCards)
	-- 不能排除牌,王也可以被带出去
	-- tmpObCards = self:OperationCard(tmpObCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)

	local result = false
	local bSucc = true
	local tmp_cards = self:GetCountsByLevel(exceptGhostList,1)
	local tmp_cards2 = self:GetCountsByLevel(exceptGhostList,4)
	-- 不同的牌必须是2张,不能有4张相同的
	if table.nums(tmp_cards) == 2 and table.nums(tmp_cards2) <= 0 then
		-- 两种不同牌面时,必须连续
		for i=2, table.nums(tmp_cards) do
			if ((tmp_cards[i][1].level - 1) ~= tmp_cards[i-1][1].level) or tmp_cards[i][1].level >13  then
				bSucc = false
				break
			end
		end
		result = bSucc
		-- Log.i("--wangzhi--木板--三种牌--")
	end

	obCards = self:obCardsBackLevel(obCards)
	if result then
		Log.i("--wangzhi--普通的钢板--")
		return result
	end

-----------------------------------------------------------------
	obCards = self:obCardsChangeLevelA23(obCards)
	local tmpObCards2 = clone(obCards)
	local ghostCount2,ghostList2 = self:GetCardsGhostList(tmpObCards2)
	tmpObCards2 = self:OperationCard(tmpObCards2,3)
	if tmpObCards2:CurrentLength() < 6 then
		Log.i("--wangzhi--不全是A23--")
		return false
	end
	result = false
	bSucc = true
	-- local ghostCount2,ghostList2 = self:GetCardsGhostList(tmpObCards2)
	local exceptGhostList2 = self:DelGhostList(tmpObCards2)
	local tmp2_cards = self:GetCountsByLevel(exceptGhostList2,1)
	local tmp2_cards2 = self:GetCountsByLevel(exceptGhostList2,4)
	-- 不同的牌必须是2张,不能有4张相同的
	if table.nums(tmp2_cards) == 2 and table.nums(tmp2_cards2) <= 0 then
		-- 两种不同牌面时,必须连续
		for i=2, table.nums(tmp2_cards) do
			if ((tmp2_cards[i][1].level - 1) ~= tmp2_cards[i-1][1].level) or tmp2_cards[i][1].level >3  then
				bSucc = false
				break
			end
		end
		result = bSucc
		-- Log.i("--wangzhi--木板--三种牌--")
	end

	obCards = self:obCardsBackLevel(obCards)
	if result then
		Log.i("--wangzhi--AAA222的钢板--")
		return result,true
	end
	return result
end

--函数功能：     牌型判断 	炸弹
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_BOMB(obCards)

----------------------------------------------------------
	if (4 > obCards:CurrentLength()) then
		return false
	end
	obCards:SortCards(0)
	local ghostCount,ghostList = self:GetCardsGhostList(obCards)
	local exceptGhostList = self:DelGhostList(obCards)
	local tmp_cards = self:GetCountsByLevel(exceptGhostList,1)
	Log.i("--wangzhi--table.nums(tmp_cards)--",table.nums(tmp_cards))
	-- 这里不能直接判断为数量1,因为输入牌的值大于等于了4张,则不会返回值
	if table.nums(tmp_cards) == 1 and  tmp_cards[1][1].number < 16 then
		return true
	else
		Log.i("--wangzhi--不是炸弹")
	end
	return false
end

--函数功能：     牌型判断 	同花顺(大于5炸，小于6炸)
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_SISTER_BOMB(obCards)
	
-----------------------------------------------------------------
	-- 顺子时,级牌没有用
	if (5 ~= obCards:CurrentLength()) then
		return false
	end
	obCards:SortCards(0)
	obCards = self:obCardsChangeLevel(obCards)
	local tmpObCards = clone(obCards)
	local ghostCount,ghostList = self:GetCardsGhostList(tmpObCards)
	tmpObCards = self:OperationCard(tmpObCards)
	local exceptGhostList = self:DelGhostList(tmpObCards)

	local result = false
	if(ghostCount + exceptGhostList:CurrentLength()) >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(exceptGhostList,1,1)
		if table.nums(tmp_cards) == exceptGhostList:CurrentLength() then
			local bSucc = true
			for i=2, exceptGhostList:CurrentLength() do
				-- 在牌的基础上增加花色判断
				if exceptGhostList:Card(i).shape ~= exceptGhostList:Card(i-1).shape then
					Log.i("--wangzhi--花色不一样，不是同花顺")
					bSucc = false
					break
				end
				if ((exceptGhostList:Card(i).level - 1) ~= exceptGhostList:Card(i-1).level) and exceptGhostList:Card(i).level <=13 then
					local count = (exceptGhostList:Card(i).level -1) - exceptGhostList:Card(i-1).level
					Log.i("--wangzhi--两牌相差--",count)
					ghostCount = ghostCount - count
					if ghostCount < 0 then
						Log.i("--wangzhi--癞子不够填补--")
						bSucc = false
						break
					end
				end
			end
			result = bSucc
		end
	end

	obCards = self:obCardsBackLevel(obCards)

	if result then
		return result
	end
	---------------------------------------------------------------

	obCards:SortCards(0)
	obCards = self:obCardsChangeLevelA23(obCards)
	local tmpObCards2 = clone(obCards)
	-- tmpObCards2 = self:OperationCard(tmpObCards2,6)
	local ghostCount2,ghostList2 = self:GetCardsGhostList(tmpObCards2)
	tmpObCards2 = self:OperationCard(tmpObCards2,5)
	local exceptGhostList2 = self:DelGhostList(tmpObCards2)

	local result = false
	if (ghostCount2 + exceptGhostList2:CurrentLength()) >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(exceptGhostList2,1,1)
		if table.nums(tmp_cards) == exceptGhostList2:CurrentLength() then
			local bSucc = true
			for i=2, exceptGhostList2:CurrentLength() do
				-- 在牌的基础上增加花色判断
				if exceptGhostList2:Card(i).shape ~= exceptGhostList2:Card(i-1).shape then
					Log.i("--wangzhi--花色不一样，不是同花顺")
					bSucc = false
					break
				end
				if ((exceptGhostList2:Card(i).level - 1) ~= exceptGhostList2:Card(i-1).level) and exceptGhostList2:Card(i).level <=5 then
					local count = (exceptGhostList2:Card(i).level -1) - exceptGhostList2:Card(i-1).level
					Log.i("--wangzhi--两牌相差--",count)
					ghostCount2 = ghostCount2 - count
					if ghostCount2 < 0 then
						Log.i("--wangzhi--癞子不够填补--")
						bSucc = false
						break
					end
				end
			end
			result = bSucc
		end
	end

	obCards = self:obCardsBackLevel(obCards)

	if result then
		Log.i("--wangzhi--A2345--同花顺--")
		return result ,true
	end

	return result
end

--函数功能：     牌型判断 	天王炸(2个大王+2个小王)
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 bool
function GDGameRule:Find_KING_BOMB(obCards)
	if 4 == obCards:CurrentLength() then
		local JokerCount = 0
		local JOKERCount = 0
		for i,v in ipairs(obCards:GetCards()) do
			if v.number ~= enmCardNumber.ECN_NUM_Joker and v.number ~= enmCardNumber.ECN_NUM_JOKER then
				return false
			end
			if v.number == enmCardNumber.ECN_NUM_Joker then
				JokerCount = JokerCount + 1
			elseif v.number == enmCardNumber.ECN_NUM_JOKER then
				JOKERCount = JOKERCount + 1
			end
		end
		if JokerCount == 2 and JOKERCount == 2 then
			return true
		else
			Log.i("--不是2张大王和2个小王--")
			return false
		end
	end
	return false
end

--函数功能：     获取首发出牌(提示按钮情况下)
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function GDGameRule:GetFirst(obCards)
	--todo
end

--函数功能：     获取首发出牌(滑选情况下)
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function GDGameRule:GetMoveFirst(obCards)
	--todo
end

--函数功能： 判断两张牌的level是否相同
--selfCards: 手牌的值
--obCards:  目标牌值
--返回值：  是否相等
function GDGameRule:CompareCardLevel(selfCard,obCard)
	local card_1 = PokerUtil.parseSvrDataCard(selfCard)
	local card_2 = PokerUtil.parseSvrDataCard(obCard)
		if card_1.level == card_2.level then
			return true
		end
	return false
end


--函数功能：     获取牌类型
--obCards:      目标牌集
--返回值：       分析出来的
function GDGameRule:GetCardType(obCards,lastCardType)
	-- 将出牌组进行处理
	local obCardsSet = nil
	if obCards and #obCards > 0 then
		obCardsSet = CardSet.new()
		obCardsSet:AddOriCards(obCards)
	end
	local cardType = self:CardsType(obCardsSet,lastCardType)
	-- 重置
	if obCardsSet then
		obCardsSet:ClearAll()
	end
	return cardType
end

--函数功能：	筛选所有等于给定张数的牌集
--cards:		给定的牌集
--index:		开始位置
--obCards:		保存的牌集
--返回值：		筛选后的牌
function GDGameRule:SizerCardsStep2(cardsObj,counter)
	local obCards = {}
	local function find_sizer_sisiter(cards,index,count)
		if #cards - index + 1 < count then
			return obCards
		end
		local sisiter = {}
		for j = index,#cards do
			if j <= count+(index - 1) then
				table.insert( sisiter, cards[j])
				if j == #cards then
					table.insert( obCards, sisiter)
				end
			else
				table.insert( obCards, sisiter)
				if #cards - index >= count then
					return find_sizer_sisiter(cards,index + 2,count)
				else
					return obCards
				end
			end
		end
	end
	find_sizer_sisiter(cardsObj,1,counter)
	--没有截取内容的就直接取值
	if not obCards and #obCards <= 0 then
		obCards = cardsObj
	end
	return obCards
end

--函数功能：	筛选所有等于给定张数的牌集
--cards:		给定的牌集
--index:		开始位置
--obCards:		保存的牌集
--返回值：		筛选后的牌
function GDGameRule:SizerCardsStep3(cardsObj,counter)
	local obCards = {}
	local function find_sizer_sisiter(cards,index,count)
		if #cards - index + 1 < count then
			return obCards
		end
		local sisiter = {}
		for j = index,#cards do
			if j <= count+(index - 1) then
				table.insert( sisiter, cards[j])
				if j == #cards then
					table.insert( obCards, sisiter)
				end
			else
				table.insert( obCards, sisiter)
				if #cards - index >= count then
					return find_sizer_sisiter(cards,index + 3,count)
				else
					return obCards
				end
			end
		end
	end
	find_sizer_sisiter(cardsObj,1,counter)
	--没有截取内容的就直接取值
	if not obCards and #obCards <= 0 then
		obCards = cardsObj
	end
	return obCards
end

--函数功能：	筛选所有等于给定张数的牌集
--cards:		给定的牌集
--index:		开始位置
--obCards:		保存的牌集
--返回值：		筛选后的牌
function GDGameRule:GetMaxCard(lastCard,lastType)
	local last_card_type
	local tmp_cards1 = {}
	Log.i("--wangzhi--last_card_type--",last_card_type)
	if lastType then
		last_card_type = lastType
	else
		last_card_type = self:CardsType(lastCard)
	end
	--找出非炸弹牌型
	-- 单张
	if last_card_type == enmCardType.EBCT_BASETYPE_SINGLE then
		tmp_cards1 = self:FindPressAllSingle(lastCard)
		Log.i("--wangzhi--查找到的单张为")
	-- 对子
	elseif last_card_type == enmCardType.EBCT_BASETYPE_PAIR then
		tmp_cards1 = self:FindPressAllPair(lastCard)
		Log.i("--wangzhi--查找到的对子为")
	-- 三张
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3KIND then
		tmp_cards1 = self:FindPressAll3Kind(lastCard)
		Log.i("--wangzhi--查找到的三张为")
	-- 三带二
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3AND2 then
		tmp_cards1 = self:FindPressAll3And2(lastCard)
		Log.i("--wangzhi--查找到的三带二为")
	-- 顺子	只能五张
	elseif last_card_type == enmCardType.EBCT_BASETYPE_SISTER then
		tmp_cards1 = self:FindPressAllSister(lastCard,5)
		Log.i("--wangzhi--查找到的顺子为")
	-- 钢板,优先钢板,钢板更难被压
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
		tmp_cards1 = self:FindPressAll3Kinds(lastCard,2)
		Log.i("--wangzhi--查找到的钢板为")
	-- 木板
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
		tmp_cards1 = self:FindPressAllPairs(lastCard,3)
		Log.i("--wangzhi--查找到的木板为")
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
		tmp_cards1 = self:GetKingBombStyle(lastCard, false,true,last_card_type)
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
		tmp_cards1 = self:GetSisterBombStyle(lastCard, false,true,last_card_type)
	elseif last_card_type == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
		tmp_cards1 = self:GetBombStyle(lastCard, false,true,last_card_type)
	end

	local tmpLastCards = {}
	if #tmp_cards1>0 then
		for i,v in pairs(tmp_cards1[#tmp_cards1]) do
			local CardOriginalVal = 16*v.shape + v.number - 2
			table.insert( tmpLastCards,CardOriginalVal)
		end
	end

	-- 将出牌组进行处理
	local obCardsSet = nil
	if tmpLastCards and #tmpLastCards > 0 then
		obCardsSet = CardSet.new()
		obCardsSet:AddOriCards(tmpLastCards)
		if last_card_type == enmCardType.EBCT_BASETYPE_SISTER or 
		last_card_type == enmCardType.EBCT_CUSTOMERTYPE_3KINDS or 
		last_card_type == enmCardType.EBCT_CUSTOMERTYPE_PAIRS or 
		last_card_type == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
			obCardsSet = self:obCardsChangeLevel(obCardsSet)
		end
		Log.i("--wangzhi--tmp_cards1--")
	end

	return obCardsSet
end


return GDGameRule