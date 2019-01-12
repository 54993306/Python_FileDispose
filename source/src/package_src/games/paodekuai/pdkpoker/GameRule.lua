-------------------------------------------------------------
--  @file   GameRule.lua
--  @brief  牌类游戏规则类
--  @author 徐志军
--  @DateTime:2018-06-29
--  Version: 1.0.0
--  Note: 包括一些基本牌型的定义及其比较，以及牌型和比较方法的扩展
--  Copyright  Copyright (c) 2018
--============================================================

local GameRule = class("package_src.games.paodekuai.pdkpoker.GameRule")

function GameRule:ctor()
	--不同牌型间的大小关系数组（数组一维存储目标牌型，二维存储比目标牌型大的牌型）
	self.ms_arrMapCompare = {} 

	--玩法规则设置
	self.ms_stRuleSetting = {}

	--添加的特殊牌型
	self.ms_arrSpecialType = {}
	self.ms_nCountSpecialType = 0
end

--函数功能：     牌型判断
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 int
function GameRule:CardsType(obCards)
	local cardType = enmCardType.EBCT_TYPE_NONE
	if obCards:CurrentLength() > 0 then
		local tmpCards = clone(obCards) --生成临时变量

		if self:Find_SINGLE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SINGLE
		elseif self:Find_PAIR(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_PAIR
		elseif self:Find_SISTER(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SISTER
		elseif self:Find_PAIRS(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_PAIRS
		elseif self:Find_THREEKIND(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KIND
		elseif self:Find_THREEKINDS(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KINDS
		elseif self:Find_THREEANDONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3AND1
		elseif self:Find_THREEANDTWO(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3AND2
		elseif self:Find_THREEKINDSANDONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KINDSAND1		
		elseif self:Find_THREEKINDSANDTWO(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KINDSAND2
		elseif self:Find_BOMBANDTOWONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_4KINDSAND2
		elseif self:Find_BOMBANDTOWTWO(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_4KINDSAND2s
		elseif self:Find_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_BOMB
		elseif self:Find_King_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_KINGBOMB
		else
			--拓展特殊牌型
			-- for i,v in ipairs(self.ms_nCountSpecialType) do
			if self.ms_nCountSpecialType and self.ms_nCountSpecialType > 0 then
				for i=1, self.ms_nCountSpecialType do
					if self.ms_arrSpecialType[i] ~= nil then
						cardType = self.ms_arrSpecialType[i]:CardsType(tmpCards)
						if cardType ~= enmCardType.EBCT_TYPE_NONE then
							break
						end
					end
				end
			end
		end
	end
	return cardType
end

--函数功能：	分析牌型并组合
--obCards:	   牌型集
--返回值：		分析后的牌集
function GameRule:GetAnalyzeCards(obCards)
	local result = {}

	local tmp_cards = clone(obCards)
	--删除牌集里面所有相同的牌
	local function removeCards(cards)
		for i,v in pairs(tmp_cards:GetCards()) do
			for j, k in pairs(cards) do
				if v.number == k[1].number then
					tmp_cards:DelCard(i)
					return removeCards(cards)
				end
				
			end
		end
	end
	
	--删除指定的单张牌并返回(也可以是所有相同的牌)
	--number:要删除的牌值
	--count：给定删除的个数
	local function sortAndRemoveCard(number,count)
		local cards = {}
		local cardsObj = tmp_cards:GetCards()
		count = count or #cardsObj
		local index = 0
		for i = #cardsObj,1,-1 do
			if cardsObj[i].number == number then
				table.insert( cards,cardsObj[i])
				tmp_cards:DelCard(i)
				index = index + 1
			end
			if index >= count then
				return cards
			end
		end
		return cards
	end
	--根据牌型权重排列出牌型
	--查找所有的炸弹并从牌里排除
	local bombs = self:GetBombStyle(tmp_cards)
	if bombs and #bombs > 0 then
		--因为王炸两张不相同，所以只能自己循环
		for i = #bombs,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_BOMB
			data.cards = bombs[i]
			table.insert( result, 1, data)
			for j,k in ipairs(bombs[i]) do
				sortAndRemoveCard(k.number)
			end
		end
	end

	--查找是否有大小王
	local JOKER = sortAndRemoveCard(enmCardNumber.ECN_NUM_JOKER)
	if JOKER and #JOKER > 0 then
		local data = {}
		data.name = enmDDZCardType.EBCT_BASETYPE_JOKER
		data.cards = JOKER
		table.insert( result,1,data)
	end
	local Joker = sortAndRemoveCard(enmCardNumber.ECN_NUM_Joker)
	if Joker and #Joker > 0 then
		local data = {}
		data.name = enmDDZCardType.EBCT_BASETYPE_Joker
		data.cards = Joker
		table.insert( result,1,data)
	end
	--查找所有的二并排除
	local er = sortAndRemoveCard(enmCardNumber.ECN_NUM_2)
	if er and #er > 0 then
		local data = {}
		data.name = enmDDZCardType.EBCT_BASETYPE_ER
		data.cards = er
		table.insert( result,1,data)
	end
	--查找所有的飞机
	local all3KINDS = self:FindAll3KINDS(tmp_cards)
	if all3KINDS and #all3KINDS > 0 then
		for i = #all3KINDS ,1, -1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_3KINDS
			data.cards = all3KINDS[i]
			table.insert( result, 1, data )
		end
		for i,v in ipairs(all3KINDS) do
			for j, k in ipairs(v) do
				sortAndRemoveCard(k.number,1)
			end
		end
	end
	

	--查找所有的连对
	local allPAIRS = self:FindAllPAIRS(tmp_cards)
	if allPAIRS and #allPAIRS > 0 then
		for i = #allPAIRS,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_PAIRS
			data.cards = allPAIRS[i]
			table.insert( result, 1, data)
			for j, k in ipairs(allPAIRS[i]) do
				sortAndRemoveCard(k.number,1)
			end
		end
	end
	--查找所有的顺子
	local allSISTER = self:FindAllSISTER(tmp_cards)
	if allSISTER and #allSISTER > 0 then
		for i = #allSISTER,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_SISTER
			data.cards = allSISTER[i]
			table.insert( result, 1, data)
			for j,k in ipairs(allSISTER[i]) do
				sortAndRemoveCard(k.number,1)
			end
		end
		
	end
	--查找所有的三张
	local all3KIND = self:FindAll3KIND(tmp_cards)
	if all3KIND and #all3KIND > 0 then
		for i = #all3KIND,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_3KIND
			data.cards = all3KIND[i]
			table.insert( result, 1, data )
		end
		removeCards(all3KIND)
	end
	

	--查找所有的对子
	local allPAIR = self:FindAllPAIR(tmp_cards)
	if allPAIR and #allPAIR > 0 then
		for i = #allPAIR,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_PAIR
			data.cards = allPAIR[i]
			table.insert( result, 1, data)
		end
		removeCards(allPAIR)
	end
	

	--查找所有的单张
	local allSingle = self:FindAllSingle(tmp_cards)
	if allSingle and #allSingle > 0 then
		for i=#allSingle,1,-1 do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_SINGLE
			data.cards = allSingle[i]
			table.insert( result, 1, data)
		end
		removeCards(allSingle)
	end
	

	return result
end

--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function GameRule:Compare(selfCards, obCards)

	local reslt = enmTypeCompareResult.ETCR_OTHER
	local tmpSelfCards = selfCards
	local tmpObCards = obCards
	local selfType = self:CardsType(tmpSelfCards)
	local obType = self:CardsType(tmpObCards)
	if (selfType ~= enmCardType.EBCT_TYPE_NONE) and (obType ~= enmCardType.EBCT_TYPE_NONE) then
		if selfType == obType then --牌型相同时的比较
			if selfType == enmCardType.EBCT_BASETYPE_SINGLE
				or selfType == enmCardType.EBCT_BASETYPE_PAIR
				or selfType == enmCardType.EBCT_BASETYPE_PAIRS
				or selfType == enmCardType.EBCT_BASETYPE_SISTER then
				reslt = self:Compare_ByMinLevel(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_BASETYPE_3KINDS
				or selfType == enmCardType.EBCT_BASETYPE_3KIND
				or selfType == enmCardType.EBCT_BASETYPE_3AND1
				or selfType == enmCardType.EBCT_BASETYPE_3AND2
				or selfType == enmCardType.EBCT_BASETYPE_3KINDSAND1
				or selfType == enmCardType.EBCT_BASETYPE_3KINDSAND2 then
				reslt = self:Compare_ByMinLevel3Kind(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_BASETYPE_BOMB then
				reslt = self:Compare_Bomb(tmpSelfCards,tmpObCards)
			else
				reslt = self:Compare_BetweenTypes(selfType,obType)
			end
		end
	end
	return reslt
end

--函数功能：     向GameRule添加扩展牌型
--pCardsType:   添加的牌型接口指针 ICardsType类型对象  ICardsType类型的对象
--返回值：       添加结果 BOOL
function GameRule:AddCardsType(pCardsType)
	local bSucc = false
	if (self.ms_nCountSpecialType < MAX_NUMBER_SPECIALTYPE) and pCardsType then
		self.ms_arrSpecialType[self.ms_nCountSpecialType] = pCardsType --在特殊牌型集合中添加一个扩展对象
		self.ms_nCountSpecialType = self.ms_nCountSpecialType + 1
		bSucc = true
	end
	return bSucc
end

--函数功能：     配置GameRule
--stRuleSetting:   牌类游戏规则配置，例如，配置游戏支持的基本牌型 RULESETTING
--返回值：       比较结果 BOOL
function GameRule:Config(stRuleSetting)
	self.ms_stRuleSetting = stRuleSetting
end

--[[↓protected]]--
--函数功能：     查找单张 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_SINGLE(obCards)
	return (1 == obCards:CurrentLength())
end

--函数功能：     查找对子 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_PAIR(obCards)
	obCards:SortCards(0)
	local reslt = false
	if (2 == obCards:CurrentLength()) 
		and (obCards:Card(1).level == obCards:Card(2).level) then
		reslt = true
	end
	return reslt
end

--函数功能：     查找顺子 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_SISTER(obCards)
	obCards:SortCards(0)
	local result = false
	if obCards:CurrentLength() >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(obCards,1,1)
		if table.nums(tmp_cards) == obCards:CurrentLength() then
			local bSucc = true
			for i=2, obCards:CurrentLength() do
				if ((obCards:Card(i).level - (i-1)) ~= obCards:Card(1).level) or obCards:Card(i).number == enmCardNumber.ECN_NUM_2 then
					bSucc = false
					break
				end
			end
			result = bSucc
		end
	end
	return result
end

--函数功能：     查找连对 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_PAIRS(obCards)
	if RULESETTING.nLimitPairs <= obCards:CurrentLength()/2 and obCards:CurrentLength()%2 == 0 then
		obCards:SortCards(0)
		--TODO 确定选
		--获取对子的个数
		--确定对子个数是否大于连队个数并且是否等于牌张的一半
		local tmp_cards = self:GetCountsByLevel(obCards,2)
		if table.nums(tmp_cards) >= RULESETTING.nLimitPairs and table.nums(tmp_cards) == obCards:CurrentLength()/2 then
			local nCount = 0
			for i = 2,table.nums(tmp_cards) do
				if (tmp_cards[i][1].level - (i-1) ~= tmp_cards[1][1].level) then
					return false
				else
					nCount = nCount + 1
					if nCount >= RULESETTING.nLimitPairs - 1 and nCount == table.nums(tmp_cards) -1 then
						return true
					end
				end
			end
		end
	end
	return false
end

--函数功能：     查找三张 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEKIND(obCards)
	if 3 == obCards:CurrentLength() then
		local tmp_cards = self:GetCountsByLevel(obCards,3)
		if table.nums(tmp_cards) > 0 then
			return true
		end
	end
	return false
end

--函数功能：     查找三顺 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEKINDS(obCards)
	local result = false
	if RULESETTING.nLimit3Kinds <= obCards:CurrentLength()/3 and obCards:CurrentLength()%3 == 0 then
		local tmp_cards = self:GetCountsByLevel(obCards,3,1)
		local count_3Kind = 0
		if table.nums(tmp_cards) > 1 then
			for i = 2,table.nums(tmp_cards) do
				if tmp_cards[i][1].level - (i-1) ~= tmp_cards[1][1].level then
					return false
				else
					count_3Kind = count_3Kind + 1
					if count_3Kind >= RULESETTING.nLimit3Kinds - 1 and count_3Kind == table.nums(tmp_cards) -1  then
						result = true
					end
				end
			end
		end
	end
	return result
end

--函数功能：     查找三带一 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEANDONE(obCards)
	if 4 == obCards:CurrentLength() then
		local tmp_cards = self:GetCountsByLevel(obCards,3,1)
		if 1 == table.nums(tmp_cards) then
			return true
		end
	end
	return false
end

--函数功能：     查找三带二 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEANDTWO(obCards)
	if 5 == obCards:CurrentLength() then
		local tmp_cards = self:GetCountsByLevel(obCards,3,1)
		if 1 == table.nums(tmp_cards) then
			local tmp_cards1 = self:GetCountsByLevel(obCards,2,1)
			if 1 == table.nums(tmp_cards1) then
				return true
			end
		end
	end
	return false
end

--函数功能：     查找三顺带一 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEKINDSANDONE(obCards)
	obCards:SortByLevel()
	local count_3Kind = self:GetCountsByLevel(obCards,3,1)
	local count_bomb = self:GetCountsByLevel(obCards,4)
	--检查是否是大于三顺的最小牌型，并且带的单张是否是等于三顺的个数
	if table.nums(count_3Kind) >= RULESETTING.nLimit3Kinds then
		local nCount = 0
		for i = 2, table.nums(count_3Kind) do
			if count_3Kind[i][1].level - (i-1) ~= count_3Kind[1][1].level then
				if i > RULESETTING.nLimit3Kinds and obCards:CurrentLength()-((i-1)*3) == i - 1 then
					return true
				end
				return false
			else
				nCount = nCount + 1
				if nCount >= RULESETTING.nLimit3Kinds - 1 and nCount == table.nums(count_3Kind) -1  then
					if i < RULESETTING.nLimit3Kinds or obCards:CurrentLength()-(i*3) ~= i then
						return false
					end
					return true
				end
			end
		end
	elseif #count_3Kind <= 0 and count_bomb and #count_bomb > 1 and #count_bomb * RULESETTING.nLimitBom == obCards:CurrentLength() then
		--相连的四炸也是三顺带一
		for i = 2, table.nums(count_bomb) do
			if count_bomb[i][1].level - (i-1) ~= count_bomb[1][1].level then
				return false
			end
			if i == #count_bomb then
				return true

			end
		end

	end
	return false
end

--函数功能：     查找三顺带二 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_THREEKINDSANDTWO(obCards)
	--判断三张和对子是否是一样，并且牌值是否是一样
	--判断三张是否是连续的
	--查看牌的张数是否跟传入的牌张数相同
	local count_3Kind = self:GetCountsByLevel(obCards,3,1)
	local count_Pair = self:GetCountsByLevel(obCards,2,1)
	local bom_cards = self:GetCountsByLevel(obCards,4)
	if table.nums(count_3Kind) >= RULESETTING.nLimit3Kinds 
		and (table.nums(count_3Kind) == table.nums(count_Pair) or table.nums(count_3Kind)/2 == table.nums(bom_cards) )
		and (3*table.nums(count_3Kind) + 2*table.nums(count_Pair) == obCards:CurrentLength()
			or 3*table.nums(count_3Kind) + 4*table.nums(bom_cards) == obCards:CurrentLength()) then
			for i= 2,table.nums(count_3Kind) do
				if count_3Kind[i][1].level - (i-1) ~= count_3Kind[1][1].level then
					return false
				end
			end
			return true
	end
	return false
end

--函数功能：     查找炸弹 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_BOMB(obCards)
	--判断牌张数是否大于炸弹
	--判断是否是相同的牌并且向东的张数是否大于炸弹最小数
	if obCards:CurrentLength() >= RULESETTING.nLimitBom then
		local fenxi = self:CardsFenXi(obCards)
		local fenxiNum = table.getn(fenxi)
		local counter = 0
		for i,v in pairs(fenxi) do
			counter = table.nums(v)
		end
		if table.nums(fenxi) == 1 and counter >= RULESETTING.nLimitBom then
			return true
		end
	end
	return false
end

--函数功能：	查找四带二
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_BOMBANDTOWONE(obCards)
	local count_bom = self:GetCountsByLevel(obCards,RULESETTING.nLimitBom)
	if 1 <= table.nums(count_bom) and obCards:CurrentLength()-table.nums(count_bom)*RULESETTING.nLimitBom == 2 then
		return true
	end
	return false
end


--函数功能：	查找四带二对
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_BOMBANDTOWTWO(obCards)
	local count_bom = self:GetCountsByLevel(obCards,RULESETTING.nLimitBom)
	local count_pair = self:GetCountsByLevel(obCards,2,0)
	if (1 <= table.nums(count_bom) and 2 == table.nums(count_pair)) or 2 == table.nums(count_bom) then
		return true
	end
	return false
end


--函数功能：     查找王炸 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Find_King_BOMB(obCards)
	if 2 == obCards:CurrentLength() then

		for i,v in ipairs(obCards:GetCards()) do
			if v.number ~= enmCardNumber.ECN_NUM_Joker and v.number ~= enmCardNumber.ECN_NUM_JOKER then
				return false
			end
		end
		return true
	end
	return false
end

--[[↓Compare]]--

--函数功能：     通过Level进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function GameRule:Compare_ByMinLevel(selfCards, obCards)
	local reslt = enmTypeCompareResult.ETCR_OTHER
	if selfCards:CurrentLength() == obCards:CurrentLength() then
		local selfMinLvl = self:GetMinLevel(selfCards)
		local obMinLvl = self:GetMinLevel(obCards)

		if selfMinLvl > obMinLvl then
			reslt = enmTypeCompareResult.ETCR_MORE
		elseif selfMinLvl < obMinLvl then
			reslt = enmTypeCompareResult.ETCR_LESS
		else
			reslt = enmTypeCompareResult.ETCR_EQUAL
		end
		
	end
	return reslt
end	

--函数功能：     通过Level3Kind进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function GameRule:Compare_ByMinLevel3Kind(selfCards,obCards)
	local reslt = enmTypeCompareResult.ETCR_OTHER
	if selfCards:CurrentLength() == obCards:CurrentLength() then
		local self3Kind = self:GetCountsByLevel(selfCards,3)
		local ob3Kind = self:GetCountsByLevel(obCards,3)
		if self3Kind and #self3Kind > 0 and ob3Kind and #ob3Kind > 0 then
			if self3Kind[#self3Kind][1].level > ob3Kind[#ob3Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_MORE
			elseif self3Kind[#self3Kind][1].level < ob3Kind[#ob3Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_LESS
			else
				reslt = enmTypeCompareResult.ETCR_EQUAL
			end
		end

	end
	return reslt
end

--函数功能：	通过Level4Kind进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function GameRule:Compare_ByMinLevel4Kind(selfCards,obCards)
	local reslt = enmTypeCompareResult.ETCR_OTHER
	if selfCards:CurrentLength() == obCards:CurrentLength() then
		local self4Kind = self:GetCountsByLevel(selfCards,4)
		local ob4Kind = self:GetCountsByLevel(obCards,4)
		if self4Kind and #self4Kind > 0 and ob4Kind and #ob4Kind > 0 then
			if self4Kind[#self4Kind][1].level > ob4Kind[#ob4Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_MORE
			elseif self4Kind[#self4Kind][1].level < ob4Kind[#ob4Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_LESS
			else
				reslt = enmTypeCompareResult.ETCR_EQUAL
			end
		end

	end
	return reslt
end

--函数功能：     通过Bomb进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function GameRule:Compare_Bomb(selfCards,obCards)
	local reslt = enmTypeCompareResult.ETCR_OTHER 
	if selfCards:CurrentLength() == obCards:CurrentLength() then
		local selfBomb = self:GetCountsByLevel(selfCards,4)
		local obBomb = self:GetCountsByLevel(obCards,4)
		if selfBomb and #selfBomb > 0 and obBomb and #obBomb > 0 then
			if selfBomb[#selfBomb][1].level > obBomb[#obBomb][1].level then
				reslt = enmTypeCompareResult.ETCR_MORE
			elseif selfBomb[#selfBomb][1].level < obBomb[#obBomb][1].level then
				reslt = enmTypeCompareResult.ETCR_LESS
			else
				reslt = enmTypeCompareResult.ETCR_EQUAL
			end
		end
	end
	return reslt
end

--函数功能：     通过BetweenTypes进行比较
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function GameRule:Compare_BetweenTypes(selfType,obType)
	local reslt = enmTypeCompareResult.ETCR_OTHER
	local j = 1;
	for i,v in pairs(self.ms_arrMapCompare) do
		if v[j] == selfType then
			for j = 2,#v do
				if (v[j] == 0) then
					j = 1 
					break
				end
				if (v[j] == obType) then
					reslt = enmTypeCompareResult.ETCR_LESS
					i = #self.ms_arrMapCompare
					break;
				end
			end
		end
	end
	return reslt
end

-- --函数功能：	寻找分析相同牌值
-- --返回值：		牌值集合
function GameRule:CardsFenXi(obCards)
	local tmp_cards = {}
	for i,v in ipairs(obCards:GetCards()) do
		local lev = v.level
		if tmp_cards[lev] == nil then
			tmp_cards[lev] = {}
		end
		table.insert( tmp_cards[lev],v)
	end
	--偶尔有乱序的情况这边按照index去排序
	local reslt = {}
	for i,v in pairs(tmp_cards) do
		local data = {}
		data.index = i
		data.cards = v
		table.insert(reslt,data)
	end
	tmp_cards = {}
	table.sort(reslt,function(a,b) return a.index < b.index end)
	for i,v in pairs(reslt) do
		table.insert(tmp_cards,v.cards)
	end
	return tmp_cards
end

--函数功能：	根据权值统计操作对象中大于或等于给定张数的牌的点数
--obCards:		目标牌集
--nCount:		给定张数
--mod:			模式（取0时，将张数大于nCount的数组保存，取1时将张数等于nCount的数组保存）
--返回值：		符合条件的牌组
function GameRule:GetCountsByLevel(obCards,nCount,mod)
	mod = mod or 0

	local fenxi = self:CardsFenXi(obCards)
	local tmp_cards = {}
	for i,v in pairs(fenxi) do
		--判断是否寻找的是炸弹，如果不是则不能拆炸弹，如果是直接找比炸弹多的牌则直接检测炸弹
		local vNum = table.nums(v)
		local minBomLevel = mod == 0 and (vNum >= nCount and vNum < RULESETTING.nLimitBom) or vNum == nCount
		local maxBomLevel = mod == 0 and vNum >= nCount  or vNum == nCount
		if (nCount < RULESETTING.nLimitBom and minBomLevel)
			 or ( nCount >= RULESETTING.nLimitBom and maxBomLevel ) then
			table.insert(tmp_cards,v)
		end
	end
	return tmp_cards
end

--[[↓FindAll]]--
--函数功能：     查找所有的单张
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAllSingle(obCards)
	return self:GetCountsByLevel(obCards,1,1)
end

--函数功能：     查找所有的对子
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAllPAIR(obCards, mod)
	mod = mod or 0
	local reslt = {}
	if mod == 0 then
		local tmpTable = self:GetCountsByLevel(obCards, 2)

		--将查出来的3张以上取出前两张
		for i,v in ipairs(tmpTable) do
			if #v > 2 then
				local newTable = {}
				table.insert(newTable, v[1])
				table.insert(newTable, v[2])
				table.insert(reslt, newTable)
			else
				table.insert(reslt, v)
			end
		end
	else
		reslt = self:GetCountsByLevel(obCards, 2, 1)
	end
	return reslt
end

--函数功能：     查找所有的顺子
--obCards:      目标牌集
--count:        最大张数
--返回值：       找出的所有牌值
function GameRule:FindAllSISTER(obCards, count)
	obCards = self:OperationCard(obCards)
	--把所有相连的牌都放一起
	local tmp_cards = {}
	local counter = 1
	count = count or 0
	local cards = obCards:GetCards()
	
	for i,v in pairs(cards) do
		if i <= 1 or v.level - 1 == cards[i-1].level then
			tmp_cards[counter] = tmp_cards[counter] or {}
			table.insert(tmp_cards[counter], v)
		else
			if v.level ~= cards[i - 1] .level then
				counter = counter + 1
				tmp_cards[counter] = tmp_cards[counter] or {}
				table.insert(tmp_cards[counter], v)
			end
		end
	end

	--判断出超出顺子个数的牌集
	
	cards = {}
	for i,v in pairs(tmp_cards) do
		if (table.nums(v) >= RULESETTING.nLimitSister) 
			and (table.nums(v) >= count) then
			if count > 0 then
				local cardObj = self:SizerCards(v,count)
				for j,jv in pairs(cardObj) do
					table.insert( cards, jv)
				end
			else
				table.insert( cards, v)
			end
		end
	end
	return cards
end

--函数功能：     查找所有的连对
--obCards:      目标牌集
--count:        最大张数
--返回值：       找出的所有牌值
function GameRule:FindAllPAIRS(obCards,count)
	obCards = self:OperationCard(obCards)

	local reslt = {}
	--因为对子都是两张所以需要除2来确定多少对
	count = count or 0
	local tmp_cards = {}
	local counter = 1

	local pairs_cards = self:GetCountsByLevel(obCards,2)
	local re_cards = clone(pairs_cards)
	--去除两张以上的
	for i,v in pairs(re_cards) do
		if table.nums(v) > 2  then
			for j,k in pairs(v) do
				if j > 2 then
					--这里只是看要删除多少次（从最后开始删）
					table.remove( pairs_cards[i], #pairs_cards[i])
				end
			end
		end
	end
	re_cards = nil

	local cards = pairs_cards
	--查找是否是顺子
	for i,v in pairs(pairs_cards) do
		if i <= 1 or v[1].level - 1 == cards[i-1][1].level then
			tmp_cards[counter] = tmp_cards[counter] or {}
			table.insert(tmp_cards[counter], v)
		else
			counter = counter + 1
			tmp_cards[counter] = tmp_cards[counter] or {}
			table.insert(tmp_cards[counter], v)
		end
	end
	--判断出超出顺子个数的牌集
	cards = {}
	for i,v in pairs(tmp_cards) do
		if table.nums(v) >= RULESETTING.nLimitPairs
			and table.nums(v) >= count then
				if count > 0 then
					local cards_count = self:SizerCards(v,count)
					for j,jv in pairs(cards_count) do
						table.insert( cards, jv)
					end
				else
					table.insert( cards, v)
				end
		end
	end
	--把所有查出来的顺子整合到一起
	for i,v in ipairs(cards) do
		for j,k in ipairs(v) do
			reslt[i] = reslt[i] or {}
			for m,n in ipairs(k) do
				table.insert( reslt[i],n)
			end
		end
	end
	return reslt
end

--函数功能：	筛选所有等于给定张数的牌集
--cards:		给定的牌集
--index:		开始位置
--obCards:		保存的牌集
--返回值：		筛选后的牌
function GameRule:SizerCards(cardsObj,counter)
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
					return find_sizer_sisiter(cards,index + 1,count)
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

--函数功能：     查找所有的三张
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAll3KIND(obCards)
	return self:GetCountsByLevel(obCards, 3,1)
end

--函数功能：     查找所有的三顺（三连）
--obCards:      目标牌集
--count:        连续点数
--返回值：       找出的所有牌值
function GameRule:FindAll3KINDS(obCards, count)
	obCards = self:OperationCard(obCards)

	local reslt = {}
	local cards = {}
	count = count or 0
	--find all 3kind
	local kind3 = self:GetCountsByLevel(obCards, 3, 1)
	--filter out continuouss
	for i = 1, #kind3 do
		local cc = 1
		local tmp = {}
		table.insert(tmp, kind3[i])
		if i <= #kind3 - 1 then
			for j = i + 1, #kind3 do --calc from i+1
				if kind3[j][1].level == kind3[j - 1][1].level + 1 then
					-- wwdump(kind3[i], "kind3[i]")
					cc = cc + 1
					table.insert(tmp, kind3[j])
					if cc == count or count == 0 then
						table.insert(cards, tmp)
						break
					end
				else
					break
				end
			end
		end
	end
	--把所有查出来的顺子整合到一起
	for i,v in ipairs(cards) do
		for j,k in ipairs(v) do
			reslt[i] = reslt[i] or {}
			for m,n in ipairs(k) do
				table.insert( reslt[i],n)
			end
		end
	end
	return reslt
end

--函数功能：	排除二以上的牌
--obCards:		目标牌集
--返回值：		处理后的牌集
function GameRule:OperationCard(obCards)
	obCards:SortCards(0)
	obCards = clone(obCards)
	local operationCard = obCards:GetCards()
	for i = #operationCard,1,-1 do
		if operationCard[i].level >= 13 then
			obCards:DelCard(i)
		else
			break
		end
	end
	return obCards
end


--函数功能：     查找所有的三带一
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAll3AND1(obCards)
	local reslt = {}
	local tmp_cards = clone(obCards)
	--find all 3kind
	local kind3s = self:FindAll3KIND(tmp_cards)
	--find all single
	local function removeCards(cards)
		for i,v in pairs(tmp_cards:GetCards()) do
			for j, k in pairs(cards) do
				if v.number == k[1].number then
					tmp_cards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(kind3s)
	
	if kind3s and (#kind3s > 0) then
		for ii,vv in ipairs(kind3s) do
			local singles = self:GetExcludeSingles(tmp_cards,vv,1)
			if not singles or #singles <= 0 then
				break
			end
			table.insert(reslt, vv)
			for i,v in ipairs(singles) do
				table.insert(reslt[#reslt], v)
			end
		end
	end

	return reslt
end
--函数功能：	获取排除自己的单张
--obCards:		目标牌型
--tmp_cards:	需要排除的牌
--count:		需要获取的数量
--返回值：		获取的单张
function GameRule:GetExcludeSingles(obCards,tmp_cards,count)
	obCards = clone(obCards)
	local function removeCards(cards)
		for i,v in pairs(obCards:GetCards()) do
			for k = 1,#cards/3 do
				if v.number == cards[k*3].number then
					obCards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(tmp_cards)
	return self:GetAnalyzeSingle(self:GetAnalyzeCards(obCards),count)
end

--函数功能：     查找所有的三带二
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAll3AND2(obCards)
	local reslt = {}
	--find all 3kind
	local tmp_cards = clone(obCards)
	local kind3s = self:FindAll3KIND(tmp_cards)
	--find all pair

	if kind3s and (#kind3s > 0)  then
		for ii,vv in ipairs(kind3s) do
			local pairArray = self:GetExcludePair(tmp_cards,vv,1)
			if not pairArray or #pairArray <= 0 then
				break
			end
			table.insert(reslt, vv)
			for i,v in ipairs(pairArray) do
				for j,jv in ipairs(v) do
					table.insert(reslt[#reslt], jv)
				end
			end
		end
	end

	return reslt
end
--函数功能：	获取排除自己的对子
--obCards:		目标牌型
--tmp_cards:	需要排除的牌
--count:		需要获取的数量
--返回值：		获取的对子
function GameRule:GetExcludePair(obCards,tmp_cards,count)
	local ec_cards = clone(obCards)
	local function removeCards(cards)
		for i,v in pairs(ec_cards:GetCards()) do
			for k = 1,#cards/3 do
				if v.number == cards[k*3].number then
					ec_cards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(tmp_cards)
	return self:GetAnalyzePair(self:GetAnalyzeCards(ec_cards),count)
end

--函数功能：     查找所有的三顺带一 JJJQQQ...+KA...
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAll3KINDSAND1(obCards,count)
	local reslt = {}
	local cards = {}
	count = count or 0
	local tmp_cards = clone(obCards)
	tmp_cards:SortByLevel()
	local kind3s = self:FindAll3KINDS(tmp_cards,count)
	-- local singles = self:GetAnalyzeSingle(self:GetAnalyzeCards(tmp_cards),count > 0 and count or tmp_cards:CurrentLength())
	if count > 0 then
		if kind3s and #kind3s > 0 then
			for j, jv in ipairs(kind3s) do
				local singles = self:GetExcludeSingles(tmp_cards,jv,count > 0 and count or tmp_cards:CurrentLength())
				if not singles or #singles <= 0 or #singles < #kind3s then
					break
				end
				local tmp = clone(jv)
				for i=1, #singles do	
					table.insert(tmp, singles[i])	
					--获取不大于三顺个数的单牌
					if i >= count or i >= #jv/3 then
						table.insert(reslt, tmp)
						break
					end
				end
			end
		end
	else
		if kind3s and (#kind3s > 0) then
			for j, jv in ipairs(kind3s) do
				local tmp = clone(jv)
				local singles = self:GetExcludeSingles(tmp_cards,jv,count > 0 and count or tmp_cards:CurrentLength())
				if not singles or #singles <= 0 or #singles < #kind3s then
					break
				end
				for i=1, #singles do	
					table.insert(tmp, singles[i])	
					--获取不大于三顺个数的单牌
					if i >= #jv/3 then
						table.insert(reslt, tmp)
						break
					end
				end
			end
		end
	end
	
	return reslt
end

--函数功能：     查找所有的 三顺带二 JJJQQQ...+KKAA...
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAll3KINDSAND2(obCards,count)
	local reslt = {}
	local cards = {}
	count = count or 0
	local tmp_cards = clone(obCards)
	local kind3s = self:FindAll3KINDS(tmp_cards,count)
	
	if count > 0 then
		if kind3s and #kind3s > 0 then
			for j, jv in ipairs(kind3s) do
				local Pair = self:GetExcludePair(tmp_cards,jv,count > 0 and count or tmp_cards:CurrentLength()/2)
				if not Pair or #Pair <= 0 or #Pair < #kind3s then
					break
				end
				local tmp = clone(jv)
				for i=1, #Pair do
					for k,kv in ipairs(Pair[i]) do
						table.insert(tmp,kv)	
					end
					--获取不大于三顺个数的单牌
					if i >= count or i >= #jv/3 then
						table.insert(reslt, tmp)
						break
					end
				end
			end
		end
	else
		if kind3s and (#kind3s > 0) then
			for j, jv in ipairs(kind3s) do
				local Pair = self:GetExcludePair(tmp_cards,jv,count > 0 and count or tmp_cards:CurrentLength()/2)
				if not Pair or #Pair <= 0 or #Pair < #kind3s then
					break
				end
				local tmp = clone(jv)
				for i=1, #Pair do	
					for k,kv in ipairs(Pair[i]) do
						table.insert(tmp,kv)	
					end
					--获取不大于三顺个数的单牌
					if i >= #jv/3 then
						table.insert(reslt, tmp)
						break
					end
				end
			end
		end
	end

	return reslt
end

--函数功能：     查找所有的 炸弹
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAllBOMB(obCards)
	--其它特殊牌型，如510作为炸弹，可以取得FindAllBOMB和特殊牌型组合使用
	obCards:SortByLevel()
	return self:GetCountsByLevel(obCards, 4)
end

--函数功能：     查找所有的 王炸
--obCards:      目标牌集
--返回值：       找出的所有牌值
function GameRule:FindAllKINGBOMB(obCards)
	local save1, counter1 = obCards:CountNum(enmCardNumber.ECN_NUM_Joker)
	-- wwdump(save1, counter1)
	local save2, counter2 = obCards:CountNum(enmCardNumber.ECN_NUM_JOKER)
	-- wwdump(save2, counter2)

	local reslt = {}
	if counter1 + counter2 == 2 and save1 and save2 then
		for i,v in pairs(save1) do
			table.insert(reslt, v)
		end

		for ii,vv in pairs(save2) do
			table.insert(reslt, vv)
		end
	end
	-- wwdump(reslt)
	return reslt
end

--函数功能：	查找所有的四带二
--mod:		   1为四带两张，2为四带两对
--返回值：		满足条件的牌
function GameRule:FindAll4KingAnd2(obCards,mod)
	local reslt = {}
	local bombs = self:FindAllBOMB(obCards)
	local tmp_cards = clone(obCards)
	--删除牌集里面所有相同的牌
	local function removeCards(cards)
		for i,v in pairs(tmp_cards:GetCards()) do
			for j, k in pairs(cards) do
				if v.number == k[1].number then
					tmp_cards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(bombs)

	local daipai = {}
	daipai = self:GetAnalyzeSingle(self:GetAnalyzeCards(tmp_cards),2)
	if #daipai < 2 then
		return reslt
	end
	
	for i,v in ipairs(bombs) do
		local cards = {}
		for j,jv in pairs(v) do
			table.insert(cards,jv)
		end

		for j,jv in ipairs(daipai) do
			if j<= 2 then
				table.insert(cards,jv)
			end
		end
		table.insert(reslt,cards)
	end
	

	
	return reslt
end

--函数功能：	查找所有的四带二对
--返回值：		满足条件的牌
function GameRule:findAll4KingAnd2s(obCards)
	local reslt = {}
	local bombs = self:FindAllBOMB(obCards)
	local tmp_cards = clone(obCards)
	--删除牌集里面所有相同的牌
	local function removeCards(cards)
		for i,v in pairs(tmp_cards:GetCards()) do
			for j, k in pairs(cards) do
				if v.number == k[1].number then
					tmp_cards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(bombs)

	local daipai = {}
	daipai = self:GetAnalyzePair(self:GetAnalyzeCards(tmp_cards),2)
	
	if #daipai <= 2 then
		return reslt
	end
	for i,v in pairs(bombs) do
		local cards = {}
		for j,jv in pairs(v) do
			table.insert(cards,jv)
		end
		for j,jv in pairs(daipai) do
			if j <= 2 then
				for k,kv in ipairs(jv) do
					table.insert(cards,kv)
				end
			end
		end
		table.insert(reslt,cards)
	end

	
	return reslt
end

--函数功能：	获取组合的所有单张（按牌型权重排）
--cards:	   传入的牌组
--count:		需要多少单张(防止查询太多)
--返回值：		分析后的牌组
function GameRule:GetAnalyzeSingle(cards,count)
	count = count or 0
	local reslt = {}
	local index = 0
	for i,v in ipairs(cards) do
		if v.name ~= enmCardType.EBCT_BASETYPE_BOMB and v.name ~= enmCardType.EBCT_BASETYPE_KINGBOMB then
			for j,jv in ipairs(v.cards) do
				index = index + 1
				if index > count then
					return reslt
				end
				table.insert(reslt,jv)
			end
		end

	end
	return reslt
end

--函数功能：	获取组合内所有的对子（按牌型权重排）
--cards:		传入的牌组
--count:		需要多少对子（防止查询太多）
--返回值：		分析后的牌组
function GameRule:GetAnalyzePair(cards,count)
	if not count or count == 0 then
		count = 1
	end
	local result = {}
	for i,v in ipairs(cards) do
		if (result[#result] and #result[#result] > 0) or not result[1] then
			result[#result+1] = {}
		end
		if v.name == enmCardType.EBCT_BASETYPE_PAIR then
			for j,jv in ipairs(v.cards) do
				table.insert(result[#result],jv)
				if #result > count then
					return result
				end
			end
		elseif v.name == enmCardType.EBCT_BASETYPE_3KIND then
			for j,jv in ipairs(v.cards) do
				if j % 3 ~= 0 then
					table.insert(result[#result],jv)
				end
				if #result > count then
					return result
				end
			end
		elseif v.name == enmCardType.EBCT_BASETYPE_PAIRS then
			--收集所有对子的牌样
			for j,jv in ipairs(v.cards) do
				table.insert(result[#result],jv)
				if j % 2 == 0 then
					result[#result+1] = result[#result+1] or {}
				end
				if #result > count then
					return result
				end
			end
		elseif v.name == enmCardType.EBCT_BASETYPE_3KINDS then
			--取所有三张的牌样
			for j,jv in ipairs(v.cards) do
				if j%3 ~= 0 then
					table.insert(result[#result],jv)
					if j % 3 == 2 and j ~= #v.cards - 1 then
						result[#result+1] = result[#result+1] or {}
					end
				end
				if #result > count then
					return result
				end
			end
		elseif v.name == enmDDZCardType.EBCT_BASETYPE_ER then
			if #v.cards >= 2 then
				table.insert(result[#result],v.cards[1])
				table.insert(result[#result],v.cards[2])
			end
		end
		if #result > count then
			return result
		end
		if i == #cards and #result[#result] <= 0 then
			table.remove(result,#result)
		end
		if result and #result >= count and #result[count] > 0 then
			if #result[#result] <= 0 then
				table.remove(result,#result)
			end
			return result
		end
	end
	return result
end


--函数功能：     获得某条件下最小权值level
--mod:          排序模式
--取值为0，获取所有牌中最小的level
--取值为1，获取单张中最小的level
--取值为2，获取对子中最小的level
--取值为3，获取三张中最小的level
--取值为4，获取炸弹中最小的level
--取值为5，获取顺子中最小的level
--返回值：       对应条件的了level
function GameRule:GetMinLevel(obCards,mod)
	if not mod then
		mod = 0
	end
	local reslt = 0
	if obCards.m_nCurrentLength > 0 then
		obCards:SortByLevel(0)
		if mod == 0 then
			reslt = obCards.m_Cards[1].level
		elseif mod == 1 then
			local allSingle = self:FindAllSingle(obCards)
			if allSingle and table.nums(allSingle) > 0 then
				reslt = allSingle[1][1].level
			end
		elseif mod == 2 then
			local allPAIR = self:FindAllPAIR(obCards)
			if allPAIR and table.nums(allPAIR) > 0 then
				reslt = allPAIR[1][1].level
			end
		elseif mod == 3 then
			local all3KIND = self:FindAll3KIND(obCards)
			if all3KIND and table.nums(all3KIND) > 0 then
				reslt = all3KIND[1][1].level
			end
		elseif mod == 4 then
			local allBOMB = self:FindAllBOMB(obCards)
			if allBOMB and table.nums(allBOMB) > 0 then
				reslt = allBOMB[1][1].level
			end
		elseif mod == 5 then
			local allSister = self:FindAllSISTER(obCards)
			if allSister then
				reslt = allSister[1][1].level
			end
		end
	end
	return reslt
end


return GameRule

